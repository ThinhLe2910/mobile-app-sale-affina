//
//  NotificationDetailViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/01/2023.
//

import UIKit

class NotificationDetailViewController: BaseViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var dateTimeLabel: BaseLabel!
//    @IBOutlet weak var contentLabel: BaseLabel!
    @IBOutlet weak var contentLabel: HyperlinkLabel!
    
    @IBOutlet weak var shareButton: BaseButton!
    @IBOutlet weak var interestButton: BaseButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var unavailableLabel: BaseLabel!
    
    var eventId: String = ""
    var notificationId: String = ""
    
    private var detailModel: NotificationDetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppStateManager.shared.isOpeningNotificationDetail = true
        
        headerBaseView.hide()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        addBlurStatusBar()
        
        backButton.addTapGestureRecognizer {
            self.didClickLeftBaseButton()
        }
        
        interestButton.addTarget(self, action: #selector(didClickInterestButton), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didClickShareButton), for: .touchUpInside)
        
        scrollView.isHidden = !UIConstants.isLoggedIn
        unavailableLabel.isHidden = UIConstants.isLoggedIn
        
        shareButton.isHidden = true
        interestButton.isHidden = true
        
        handleLoginStatus()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchNotiDetail()
        fetchEventDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.isHidden = !UIConstants.isLoggedIn
        unavailableLabel.isHidden = UIConstants.isLoggedIn
        
        updateUI()
    }
    
    private func fetchEventDetail() {
        if !eventId.isEmpty {
            self.lockScreen()
            let request = BaseApiRequest(path: API.Notification.GET_EVENT_DETAIL, method: .get, parameters: ["eventId":eventId], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
            APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<NotificationDetailModel>, ApiError>) in
                self?.unlockScreen()
                
                switch result {
                    case .success(let data):
                        self?.detailModel = data.data
                        self?.updateUI()
                    case .failure(let error):
                        Logger.Logs(message: error)
                        switch error {
                            case ApiError.invalidData(let sError, let data):
                                Logger.Logs(message: error)
                                guard let data = data else { return }
                                do {
                                    let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                                    if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                        self?.logOut()
                                        self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                            self?.hideBasePopup()
                                            self?.navigationController?.popToRootViewController(animated: true)
                                        } handler: {
                                            
                                        }
                                    }
                                }
                                catch let err{
                                    Logger.DumpLogs(event: .error, message: err)
                                }
                                
                            case .requestTimeout(let error):
                                self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                    self?.hideBasePopup()
                                } handler: {
                                    
                                }
                            default:
                                break
                        }
                }
            }
        }
        
    }
    
    private func fetchNotiDetail() {
        if !notificationId.isEmpty {
            self.lockScreen()
            let request = BaseApiRequest(path: API.Notification.GET_NOTIFICATION_DETAIL, method: .get, parameters: ["notificationId":notificationId], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
            APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<NotificationDetailModel>, ApiError>) in
                self?.unlockScreen()
                
                switch result {
                case .success(let data):
                    self?.detailModel = data.data
                    self?.updateUI()
                case .failure(let error):
                    Logger.Logs(message: error)
                    switch error {
                    case ApiError.invalidData(let sError, let data):
                        Logger.Logs(message: error)
                        guard let data = data else { return }
                        do {
                            let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                            if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                self?.logOut()
                                self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                    self?.hideBasePopup()
                                    self?.navigationController?.popToRootViewController(animated: true)
                                } handler: {
                                    
                                }
                            }
                        }
                        catch let err{
                            Logger.DumpLogs(event: .error, message: err)
                        }
                        
                        case .requestTimeout(let error):
                            self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                self?.hideBasePopup()
                            } handler: {
                                
                            }
                    default:
                        break
                    }
                }
            }
        }
    }

    override func didClickLeftBaseButton() {
        
        if AppStateManager.shared.isOpeningNotification {
            popViewController()
        }
        else {
            UIConstants.isInitHomeView = true
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
        }
    }
    
    private func updateUI() {
        guard let detailModel = detailModel else {
            return
        }
        
        titleLabel.text = eventId.isEmpty ? detailModel.title : detailModel.name
        dateTimeLabel.text = "\((detailModel.createdAt ?? 0) / 1000)".timestampToFormatedDate(format: "HH:mm - dd.MM.yyyy")
        contentLabel.attributedText = detailModel.contentLong?.htmlToAttributedString
        
        if !notificationId.isEmpty {
            if detailModel.contentType == 0 { // FIXED
                shareButton.isHidden = true
                interestButton.isHidden = true
            } else {
                if detailModel.contentType == 1 && detailModel.contentDynamicType == 0 { // DYNAMIC & NEWS
                    shareButton.isHidden = true
                    interestButton.isHidden = false
                    
                    interestButton.setTitle("SEE_NOW".localize(), for: .normal)
                }
                else {
                    shareButton.isHidden = false
                    interestButton.isHidden = false
                    
                }
            }
        }
        else if !eventId.isEmpty {
            shareButton.isHidden = false
            interestButton.isHidden = false
            
            interestButton.setTitle(detailModel.isCare == 0 ? "CARE".localize().capitalized : "UNCARE".localize().capitalized, for: .normal)
            interestButton.backgroundColor = detailModel.isCare == 0 ? .appColor(.pinkMain) : .appColor(.whiteMain)
            interestButton.colorAsset = detailModel.isCare == 0 ? "whiteMain" : "blackMain"
            
            if (detailModel.endTime ?? 0) < Date().timeIntervalSince1970*1000 {
                interestButton.disable()
                shareButton.disable()
            }
            else {
                interestButton.enable()
                shareButton.enable()
            }
        }

        
        guard let url = URL(string: API.STATIC_RESOURCE + (detailModel.image ?? "")) else { return }
        CacheManager.shared.imageFor(url: url) { image, error in
            if error != nil {
                DispatchQueue.main.async {
                    self.coverImageView.image = nil // UIImage(named: "newsWideImage")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.coverImageView.image = image
            }
        }
        
    }
    
    @objc private func didClickInterestButton() {
        guard let detailModel = detailModel else {
            return
        }
        
        if !eventId.isEmpty {
            careEvent(detailModel.isCare != nil && detailModel.isCare! == 1 ? 0 : 1)
        }
        else {
            if detailModel.contentType == 1 && detailModel.contentDynamicType == 0  {
                let vc = NewsDetailViewController()
                vc.id = detailModel.contentDynamicId ?? ""
               
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @objc private func didClickShareButton() {
        guard let url = URL(string: detailModel?.link ?? "") else {
            return
        }
//        let items = [url]
        let objectsToShare: URL = url // URL(string: "http://www.google.com")!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject]
        
        let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.message, UIActivity.ActivityType.mail]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func careEvent(_ status: Int) {
        if eventId.isEmpty { return }
        
        self.lockScreen()
        let fields: [String: Any] = ["eventId": eventId, "status": status]
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: fields, options: .prettyPrinted)
        } catch { }
        
        let request = BaseApiRequest(path: API.Notification.CARE_EVENT, method: .put, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<NilData>, ApiError>) in
            self?.unlockScreen()
            guard let self = self else { return }
            switch result {
                case .success(let data):
//                    self?.detailModel = data.data
                    self.fetchEventDetail()
//                    self.updateUI()
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
    
    private func handleLoginStatus() {
        let notFirstTimeLogin = UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue)
        let token = UserDefaults.standard.string(forKey: Key.token.rawValue)
        if token != nil { return }
        
        if !notFirstTimeLogin {
            let loginVC = WelcomeViewController()
            loginVC.loginCallback = {
                let notiVC = NotificationDetailViewController()
                notiVC.notificationId = self.notificationId
                if UIApplication.topViewController() is NotificationDetailViewController { return }
                UIApplication.topViewController()?.navigationController?.pushViewController(notiVC, animated: true)
            }
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .allowAnimatedContent) {
                
            } completion: { _ in
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
        else {
            let loginVC = InputPinCodeViewController()
            loginVC.loginCallback = {
                let notiVC = NotificationDetailViewController()
                notiVC.notificationId = self.notificationId
                UIApplication.topViewController()?.navigationController?.pushViewController(notiVC, animated: true)
            }
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .allowAnimatedContent) {
                
            } completion: { _ in
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }
    
}
