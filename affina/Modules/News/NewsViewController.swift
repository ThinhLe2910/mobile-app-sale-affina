//
//  NewsViewController.swift
//  affina
//
//  Created by Intelin MacHD on 27/07/2022.
//

import UIKit
import SnapKit

class NewsViewController: BaseViewController {
    //MARK: DATA DECLARE
    static let nib = "NewsViewController"
    var categoriesArray = [NewsCategoryViewModel]() {
        didSet {
            categoryCollectionView.reloadData()
        }
    }
    var newsData = [NewsItemTableViewModel]()
    
    @IBOutlet weak var newsLabel: BaseLabel!
    var pickedItem = 0
    var endReached = false
    
    private lazy var newsPresenter: NewsPresenter = {
        let presenter = NewsPresenter()
        presenter.setDelegate(self)
        return presenter
    }()
    
    //MARK: VIEWS DECLARE
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    let categoryCollectionViewLayout : UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 40)
        //layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        return layout
    }()
    private var carouselView: NewsCarouselView?
    private var carouselData = [NewsCarouselView.NewsCarouselData]()
    @IBOutlet weak var scrollViewContainerView: UIView!
    private var newsView: NewsTableView?
    private var heightConstraint: Constraint!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var loginView: BaseView!
    @IBOutlet weak var loginLabel: BaseLabel!
    @IBOutlet weak var loginDesc: BaseLabel!
    @IBOutlet weak var loginButton: BaseButton!
    
    @IBOutlet weak var notiButton: UIImageView!
    @IBOutlet weak var notiBadgeIcon: UIImageView!
    
    
    private var isCallingRequest: Bool = false
    private var currentTopic: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCategoryCollectionView()
        // Do any additional setup after loading the view.
        setupData()
    }
    
    func setupView() {
        hideHeaderBase()
        containerBaseView.hide()
        scrollView.delegate = self
        noDataLabel.isHidden = true
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        notiButton.addTapGestureRecognizer {
            AppStateManager.shared.isOpeningNotification = true
            let token = UserDefaults.standard.string(forKey: Key.token.rawValue)
            if token == nil {
                (self.tabBarController as? BaseTabBarViewController)?.hideTabBar()
                let notFirstTimeLogin = UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue)

                if !notFirstTimeLogin {
                    let loginVC = WelcomeViewController()
                    loginVC.loginCallback = {
                     UIApplication.topViewController()?.navigationController?.pushViewController(NotificationViewController(), animated: true)
                    }

                    self.navigationController?.pushViewController(loginVC, animated: true)
                }
                else {
                    let loginVC = InputPinCodeViewController()
                    self.navigationController?.pushViewController(loginVC, animated: true)
                }
            }
            else {
                let vc = NotificationViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        newsLabel.text = "NEWS".localize().capitalized
        (tabBarController as? BaseTabBarViewController)?.showTabBar()
        
        
        loginLabel.text = "YOU_NEED_TO_LOGIN".localize()
        loginDesc.text = "SEE_INTERNAL_COMMUNICATIONS_FROM".localize()
        loginButton.localizeTitle = "LOG_IN_NOW".localize()
        
        notiBadgeIcon.isHidden = !AppStateManager.shared.hasUnReadNoti
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showHideLoginViewNEmptyLabel()
        
        if !UIConstants.isLoggedIn && pickedItem == categoriesArray.count - 1 {
            newsData.removeAll()
            carouselData.removeAll()

            carouselView?.configureView(with: carouselData)
            self.newsView?.data = self.newsData
            self.newsView?.reloadTable()
        }
        if !categoriesArray.isEmpty { // && categoriesArray[0].name == "COMPANY".localize() {
            categoriesArray.remove(at: categoriesArray.count - 1)
            categoriesArray.append(NewsCategoryViewModel(name: "COMPANY".localize(), id: UserDefaults.standard.string(forKey: Key.companyId.rawValue) ?? "NO_COMPANY_ID"))
            
            endReached = false
            fetchOutstandingNewsFromServer()
            fetchNewsFromServer()
            
        }
    }
    
    func setupCategoryCollectionView() {
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        categoryCollectionView.register(UINib(nibName: NewsCategoryCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: NewsCategoryCollectionViewCell.description())
        categoryCollectionView.backgroundColor = .clear
    }
    
    override func initViews() {
        carouselView = NewsCarouselView(pages: 5, delegate: self)
        newsView = NewsTableView()
        newsView?.setDelegate(self)
    }
    
    override func setupConstraints() {
        guard let carouselView = carouselView else { return }
        scrollViewContainerView.addSubview(carouselView)
        carouselView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            heightConstraint = make.height.equalTo(290 + 12 + 56).constraint
        }
        
        guard let newsView = newsView else { return }
        scrollViewContainerView.addSubview(newsView)
        newsView.snp.makeConstraints { make in
            make.top.equalTo(carouselView.snp_bottom).offset(UIPadding.size24)
            make.left.right.equalToSuperview().inset(UIPadding.size24)
            make.bottom.equalToSuperview().inset(75)
        }
    }
    
    func setupData() {
        fetchCategoryListFromServer()
    }
    
    private func showHideLoginViewNEmptyLabel() {
        loginView.isHidden = pickedItem == categoriesArray.count - 1 ? UIConstants.isLoggedIn : true // pickedItem != 0
        if loginView.isHidden {
            noDataLabel.isHidden = (newsData.count != 0 || carouselData.count != 0)
        }
        else {
            noDataLabel.isHidden = true
        }
    }
    
    @objc private func didTapLoginButton() {
        let vc = WelcomeViewController()
        presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
    }
    
}

//MARK: Collection view datasource + Delegates
extension NewsViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCategoryCollectionViewCell.description(), for: indexPath) as? NewsCategoryCollectionViewCell {
            cell.item = categoriesArray[indexPath.row]
            if indexPath.row == pickedItem {
                cell.isPicked = true
            } else {
                cell.isPicked = false
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (categoriesArray[indexPath.row].name?.widthWithConstrainedHeight(height: 30, font: UIConstants.Fonts.appFont(.Bold, 14)) ?? 100) + 32 + 10, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if pickedItem == indexPath.row { return }
        pickedItem = indexPath.row
        newsData.removeAll()
        carouselData.removeAll()
        endReached = false
        categoryCollectionView.reloadData()
        carouselView?.configureView(with: carouselData)
        self.newsView?.data = self.newsData
        self.newsView?.reloadTable()
        
        fetchOutstandingNewsFromServer()
        fetchNewsFromServer()
        
        showHideLoginViewNEmptyLabel()
    }
}

extension NewsViewController: NewsCarouselViewDelegate, NewsTableViewDelegate {
    func handleOnPressNewsItem(id: String) {
        let detailVC = NewsDetailViewController()
        detailVC.id = id
        detailVC.likeCallBack = { isLiked in
            self.likeNewsSuccess(newsId: id)
        }
        detailVC.commentCallBack = { comments in
            for index in 0..<self.newsData.count {
                if self.newsData[index].id == id {
                    
                    self.newsData[index].numberComments = comments.count
                    
                }
            }
            self.newsView?.data = self.newsData
            self.newsView?.reloadTable()
            
            for index in 0..<self.carouselData.count {
                if self.carouselData[index].id == id {
                    self.carouselData[index].numberComments = comments.count
                    
                }
            }
            self.carouselView?.configureView(with: self.carouselData)
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func likeNewsItem(id: String, isLiked: Bool) {
        if !UIConstants.isLoggedIn {
            queueBasePopup(icon: UIImage(named: "ic_lock"), title: "YOU_ARE_NOT_LOGGED_IN".localize(), desc: "TO_USE_FEATURE_NEED_TO_LOG_IN".localize(), okTitle: "LOG_IN".localize(), cancelTitle: "LATER".localize()) {
                self.hideBasePopup()
                let vc = UINavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
                self.presentInFullScreen(vc, animated: true, completion: nil)
            } handler: {
                
            }
            return
        }
        newsPresenter.likeNews(newsId: id, isLiked: isLiked)
    }
    
    func commentNewsItem(id: String) {
//        handleOnPressNewsItem(id: id)
    }
    
    func likeCarouselNewsItem(id: String, isLiked: Bool) {
        if !UIConstants.isLoggedIn {
            queueBasePopup(icon: UIImage(named: "ic_lock"), title: "YOU_ARE_NOT_LOGGED_IN".localize(), desc: "TO_USE_FEATURE_NEED_TO_LOG_IN".localize(), okTitle: "LOG_IN".localize(), cancelTitle: "LATER".localize()) {
                self.hideBasePopup()
                let vc = UINavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
                self.presentInFullScreen(vc, animated: true, completion: nil)
            } handler: {
                
            }
            return
        }
        newsPresenter.likeNews(newsId: id, isLiked: isLiked)
    }
    
    func commentCarouselNewsItem(id: String) {
        handleOnPressNewsItem(id: id)
    }
    
    func handleOnPressCarouselItem(id: String) {
        let detailVC = NewsDetailViewController()
        detailVC.id = id
        detailVC.likeCallBack = { isLiked in
            self.likeNewsSuccess(newsId: id)
        }
        detailVC.commentCallBack = { comments in
            for index in 0..<self.newsData.count {
                if self.newsData[index].id == id {
                    
                    self.newsData[index].numberComments = comments.count
                    
                }
            }
            self.newsView?.data = self.newsData
            self.newsView?.reloadTable()
            
            for index in 0..<self.carouselData.count {
                if self.carouselData[index].id == id {
                    self.carouselData[index].numberComments = comments.count
                    
                }
            }
            self.carouselView?.configureView(with: self.carouselData)
        }
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func currentPageDidChange(to page: Int) {
        
    }
}

// MARK: NewsPresenterDelegate
extension NewsViewController: NewsPresenterDelegate {
    func likeNewsSuccess(newsId: String) {
        for index in 0..<newsData.count {
            if newsData[index].id == newsId {
                if newsData[index].isLiked == IsLiked.YES.rawValue {
                    newsData[index].isLiked = IsLiked.NO.rawValue
                    newsData[index].numberLikes -= 1
                }
                else {
                    newsData[index].isLiked = IsLiked.YES.rawValue
                    newsData[index].numberLikes += 1
                }
            }
        }
        newsView?.data = newsData
        newsView?.reloadTable()
        
        for index in 0..<carouselData.count {
            if carouselData[index].id == newsId {
                if carouselData[index].isLiked == IsLiked.YES.rawValue {
                    carouselData[index].isLiked = IsLiked.NO.rawValue
                    carouselData[index].numberLikes -= 1
                }
                else {
                    carouselData[index].isLiked = IsLiked.YES.rawValue
                    carouselData[index].numberLikes += 1
                }
            }
        }
        carouselView?.configureView(with: carouselData)
    }
    
    func fetchNewsFromServer() {
        if isCallingRequest || endReached || categoriesArray.isEmpty { return }
        isCallingRequest = true
        newsPresenter.fetchNews(of: (categoriesArray[pickedItem].id == "NO_COMPANY_ID" ? "" : categoriesArray[pickedItem].id) ?? "", newsId: newsData.last?.id, createdAt: newsData.last?.createdAt)
    }
    
    func handleFetchNewsSuccess(_ list: [NewsItemTableViewModel]) {
        if list.count == 0 {
            endReached = true
        }
        newsData.append(contentsOf: list)
        newsView?.data = newsData
        showHideLoginViewNEmptyLabel()
        view.layoutIfNeeded()
        
        isCallingRequest = false
    }
    
    func fetchOutstandingNewsFromServer() {
        if categoriesArray.isEmpty { return }
        newsPresenter.fetchOutstandingNews(of: (categoriesArray[pickedItem].id == "NO_COMPANY_ID" ? "" : categoriesArray[pickedItem].id) ?? "")
    }
    
    func handleFetchOutstandingNewsSuccess(_ list: [NewsCarouselView.NewsCarouselData]) {
        carouselData = list
        if list.count == 0 {
            heightConstraint.update(offset: 0)
        } else {
            heightConstraint.update(offset: 290 + 12 + 42)
        }
        carouselView?.configureView(with: carouselData)
        
        showHideLoginViewNEmptyLabel()
    }
    
    func fetchCategoryListFromServer() {
        newsPresenter.fetchCategoryList()
    }
    
    func handleFetchCategoryListSuccess(_ list: [NewsCategoryViewModel]) {
        categoriesArray = list
        
        categoriesArray.append(NewsCategoryViewModel(name: "COMPANY".localize(), id: UserDefaults.standard.string(forKey: Key.companyId.rawValue) ?? "NO_COMPANY_ID"))
        fetchOutstandingNewsFromServer()
        fetchNewsFromServer()
    }
    
}

// MARK: UIScrollViewDelegate
extension NewsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            fetchNewsFromServer()
        }
    }
}

extension NewsViewController {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func showAlert() {
        
    }
    
    func showError(error: ApiError) {
        // avoid duplicate popup and block UI
        if PopupManager.isShowingPopup { return }
        PopupManager.isShowingPopup = true
        self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", okHandler: {
            self.hideBasePopup()
        }, handler: {})
    }
}
