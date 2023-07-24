//
//  NotificationViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/01/2023.
//

import UIKit

class NotificationViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: ContentSizedTableView!

    @IBOutlet weak var emptyLabel: BaseLabel!
    
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    private var notifications: [NotificationModel] = []
    private var topics: [NotificationTopicModel] = []
    
    private let presenter = NotificationViewPresenter()
    
    private var currentTopic: Int = 0
    private var notificationId : String = ""
    private var contentDynamicId : String = ""
    private var isLoadingMore: Bool = false
    private var isEndReach: Bool = false
    private var detailModel: NotificationDetailModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        AppStateManager.shared.isOpeningNotification = true
        AppStateManager.shared.isOpeningNotificationDetail = false
        setupHeaderView()
        
        containerBaseView.hide()
        
        headerTopConstraint.constant = UIConstants.Layout.headerHeight
        
        view.backgroundColor = .appColor(.backgroundLightGray)
        
        scrollView.delegate = self
        
        presenter.delegate = self
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.getListTopics()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "NOTIFICATION".localize().capitalized
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.frame = CGRect(origin: rightBaseImage.frame.origin, size: .init(width: 20, height: 20))
        rightBaseImage.image = UIImage(named: "ic_search_black") // ?.withRenderingMode(.alwaysTemplate)
                                                                 //        rightBaseImage.tintColor = .appColor(.textBlack)
        rightBaseImage.addTapGestureRecognizer {
            
        }
        rightBaseImage.isHidden = true
        
    }
    
    override func initViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: NotificationTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: NotificationTableViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: NewsCategoryCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: NewsCategoryCollectionViewCell.description())
    }
    
    override func didClickLeftBaseButton() {
        let vc = (tabBarController as? BaseTabBarViewController) ?? BaseTabBarViewController()
        vc.customTabBar.switchTab(from: vc.customTabBar.activeItem, to: AppStateManager.shared.currentTabBar)
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.isTranslucent = true
        nav.view.backgroundColor = .clear
        kAppDelegate.window?.rootViewController = nav
        kAppDelegate.window?.makeKeyAndVisible()
        navigationController?.popToRootViewController(animated: true)
//        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate + UITableViewDataSource
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier, for: indexPath) as? NotificationTableViewCell else { return UITableViewCell() }
        
        cell.item = notifications[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        notificationId = notifications[indexPath.row].notificationId ?? ""
        if currentTopic == 0 {
             let vc = NotificationDetailViewController()
            vc.eventId = notifications[indexPath.row].eventId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            notificationId = notifications[indexPath.row].notificationId ?? ""
            fetchNotiDetail()
    }
}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension // 150
    }
    
}

// MARK: UICollectionViewDataSource + UICollectionViewDelegateFlowLayout
extension NotificationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return topics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCategoryCollectionViewCell.description(), for: indexPath) as? NewsCategoryCollectionViewCell else { return UICollectionViewCell() }
        cell.isPicked = currentTopic == indexPath.row
        cell.item = .init(name: topics[indexPath.row].name, id: topics[indexPath.row].id)
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 12
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: ((topics[indexPath.row].name ?? "").widthWithConstrainedHeight(height: 30, font: UIConstants.Fonts.appFont(.Bold, 14)) ?? 100) + 32 + 10, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let topic = topics[indexPath.row]
        currentTopic = indexPath.row
        
        isEndReach = false
        isLoadingMore = false
        
        if indexPath.row == 0 {
            presenter.getListEvents()
        }
        else {
            presenter.getListNotifications(topicId: topic.id ?? "")
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? NewsCategoryCollectionViewCell else { return }
        
//        cell.isPicked = true
        for i in 0..<topics.count {
            if let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? NewsCategoryCollectionViewCell {
                cell.isPicked = i == currentTopic
            }
        }
    }
}

extension NotificationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if !isLoadingMore && !isEndReach && (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
                let notification = notifications[notifications.count - 1]
                isLoadingMore = true
                presenter.getListNotifications(topicId: topics[currentTopic].id ?? "", createdAt: notification.createdAt, id: notification.id ?? "")
            }
        }
    }
}

extension NotificationViewController: NotificationViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateListTopics(topics: [NotificationTopicModel]) {
        self.topics = topics
        self.topics.insert(.init(id: "-1", name: "EVENT".localize()), at: 0)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        if self.topics.isEmpty { return }
        if currentTopic == 0 {
            presenter.getListEvents()
        } else {
            presenter.getListNotifications(topicId: self.topics[currentTopic].id ?? "", limit: 10 + notifications.count)
        }
    }
    
    func updateListNotifications(list: [NotificationModel]) {
        if isLoadingMore {
            notifications += list
        }
        else {
            notifications = list
        }
        isEndReach = list.isEmpty
        isLoadingMore = false
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.emptyLabel.isHidden = !self.notifications.isEmpty
            self.tableView.isHidden = self.notifications.isEmpty
            
        }
    }
    
    func handleError(error: ApiError) {
        switch error {
            case .expired:
                logOut()
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    self.navigationController?.popToRootViewController(animated: true)
                } handler: {
                    
                }
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
            default:
                break
        }
        
    }
    private func fetchNotiDetail() {
        if !notificationId.isEmpty {
            self.lockScreen()
            let request = BaseApiRequest(path: API.Notification.GET_NOTIFICATION_DETAIL, method: .get, parameters: ["notificationId":notificationId], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
            APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<NotificationDetailModel>, ApiError>) in
                guard let self = self else {
                    return
                }
                self.unlockScreen()
                
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        let vc = NewsDetailViewController()
                        vc.id = data.data?.contentDynamicId ?? ""
                        if(!vc.id.isEmpty){
                            self.navigationController?.pushViewController(vc, animated: true)
                        }else{
                            let vc1 = NotificationDetailViewController()
                            vc1.notificationId = self.notificationId
                            self.navigationController?.pushViewController(vc1, animated: true)
                        }
                    }
//                    self?.updateUI()
                case .failure(let error):
                    Logger.Logs(message: error)
                    switch error {
                    case ApiError.invalidData(let sError, let data):
                        Logger.Logs(message: error)
                        guard let data = data else { return }
                        do {
                            let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                            if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                self.logOut()
                                self.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                    self.hideBasePopup()
                                    self.navigationController?.popToRootViewController(animated: true)
                                } handler: {
                                    
                                }
                            }
                        }
                        catch let err{
                            Logger.DumpLogs(event: .error, message: err)
                        }
                        
                        case .requestTimeout(let error):
                            self.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                self.hideBasePopup()
                            } handler: {
                                
                            }
                    default:
                        break
                    }
                }
            }
        }
    }
}


