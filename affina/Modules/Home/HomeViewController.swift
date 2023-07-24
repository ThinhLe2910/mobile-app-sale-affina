//
//  HomeViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit
import SnapKit
import LocalAuthentication

class HomeViewController: BaseViewController {
    
    // MARK: Views
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var gradientView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBg"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customHeader: CustomHeaderHomeView = {
        let view = CustomHeaderHomeView.instanceFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var cardView: HomeFindingInsuranceView = {
        let view = HomeFindingInsuranceView.instanceFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var categoryCollectionView: BaseCollectionView<HomeCategoryCollectionViewCell, HomeCategoryModel> = {
        let view = BaseCollectionView<HomeCategoryCollectionViewCell, HomeCategoryModel>()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 78, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: HomeCategoryCollectionViewCell.nib)
        return view
    }()
    
    private lazy var promotionProductView: HomeProductCollectionView = {
        let view = HomeProductCollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollDirection = .horizontal
        view.sectionInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        view.moreButton.show()
        view.buyCallBack = { model in
            let vc = UINavigationController(rootViewController: InsuranceApproachViewController())
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        view.moreCallback = {
            let vc = ProductListViewController(nibName: ProductListViewController.nib, bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return view
    }()
    
    private var promotionBottomConstraint: Constraint!
    
    private lazy var bestSellerProductView: HomeProductCollectionView = {
        let view = HomeProductCollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.buyCallBack = { model in
            let vc = UINavigationController(rootViewController: InsuranceApproachViewController())
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        return view
    }()
    
    private lazy var eventPopupView: EventPopupView = {
        let popup = EventPopupView()
        //        popup.isHidden = true
        return popup
    }()
    
    // MARK: Properties
    private var myCardsView: HomeInsuranceCardView?
    private var cardData = [CardModel]()
    private var carouselView: HomeCarouselView?
    private var carouselData = [HomeCarouselView.HomeCarouselData]()
    private var bestSellerHeightConstraint: Constraint!
    
    private let presenter: HomeViewPresenter = HomeViewPresenter()
    private let cardPresenter = CardViewPresenter()
    private let voucherPresenter = VoucherPointViewDelegate()
    private var allCardLayout: [ListSetupCard] = [] {
        didSet {
            updateCardLayouts()
        }
    }
    private var cardLayout: [ListSetupCard] = []
    private var listPopup: [HomeEventModel] = []
    // MARK: Biometric
    private let biometry = BiometryAuth()
    private var biometricType: LAContext.BiometricType = .none
    
    private var iconBiometric: UIImage = UIImage()
    
    private var isFetchingCards: Bool = false
    private var isNeedToShowFirstCardPopup: Bool = false
    private var isShowingExpiredPopup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIConstants.isInitHomeView = true
        
        //add rotate gesture.
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(handleRotate))
        rotate.delegate = self
        view.addGestureRecognizer(rotate)
        
        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = UIColor.appColor(.backgroundLightGray)
        customHeader.delegate = self
        voucherPresenter.delegate = self
        categoryCollectionView.items = [
            //            HomeCategoryModel(id: 0, name: "MEDICINE_DOCTOR".localize(), imageURL: "ic_medicine"),
            HomeCategoryModel(id: 1, name: "LIST_CONTRACT".localize(), imageURL: "ic_contract"),
            HomeCategoryModel(id: 2, name: "USE_COINS".localize(), imageURL: "ic_crown"),
        ]
        categoryCollectionView.setDidSelectItemHandler { item in
            switch item.id {
            case 0 :
                //                    let vc = ContractViewControlleras(nibName: ContractViewController.nib, bundle: nil)
                //                    self.navigationController?.pushViewController(vc, animated: true)
                break
            case 1:
                let vc = ContractViewController(nibName: ContractViewController.nib, bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 2:
                let vc = VoucherPointViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                
            case 3:
                let vc = CompanyViewController()
                self.cardLayout = LayoutBuilder.shared.getListProviderCards(cardData: self.cardData)
                vc.updateCardLayoutsNBenefitIcons(self.cardLayout, LayoutBuilder.shared.getlistIconBenefit())
                vc.cardLayouts = self.cardLayout
                self.navigationController?.pushViewController(vc, animated: true)
                
            default: break
            }
        }
        
        promotionProductView.delegate = self
        promotionProductView.setData(items: [], title: "DEALS_FOR_YOU".localize())
        //
        bestSellerProductView.delegate = self
        bestSellerProductView.setData(items: [], title: "OUTSTANDING_PRODUCT".localize())
        
        categoryCollectionView.reloadData()
        
        
        myCardsView?.configureView(with: []) // TODO:
        carouselView?.configureView(with: carouselData)
        
        // MARK: Set up biometric
        let context = LAContext()
        biometricType = context.biometricType
        biometry.delegate = self
        
        CommonService().getConfig {[weak self] result in
            switch result {
            case .success(let response):
                if let configs = response.data {
                    for config in configs {
                        if config.keyName == "hostStaticResource" {
                            Logger.Logs(message: config.value)
                            API.STATIC_RESOURCE = config.value
                            
                            self?.presenter.getAllSetup()
                            self?.presenter.getListFeaturedProducts()
                        }
                    }
                }
            case .failure(_):
                Logger.Logs(event: .error, message: "Error")
            }
        }
        
        presenter.setViewDelegate(delegate: self)
        cardPresenter.setViewDelegate(self)
        
        presenter.getListProgramType()
        
        if UIConstants.requireLogin {
            didTapLoginButton()
        } else {
            //TODO: Comment this block to hide the new campaign flow
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                presenter.getBannerList()
                presenter.getPopupList()
            }
        }
    }
    
    @objc func handleRotate(_ rotate: UIRotationGestureRecognizer) {
        if API.networkEnvironment == .live { return }
        print("rotate.rotation: \(rotate.rotation)")
        self.present(ChangeEnvViewController(nibName: "ChangeEnvViewController", bundle: nil), animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showHideTabBar), name: Notification.Name(rawValue: "hideTabBar"), object: nil)
        
        showHideTabBar()
        
        if UIConstants.isLoggedIn {
            presenter.getNotificationStatus()
        }
        
        //        fetchAPIs()
        
        
        promotionProductView.setTitle(title: "DEALS_FOR_YOU".localize())
        bestSellerProductView.setTitle(title: "OUTSTANDING_PRODUCT".localize())
    }
    
    @objc private func showHideTabBar() {
        if UserDefaults.standard.bool(forKey: "hideTabBar") {
            (tabBarController as? BaseTabBarViewController)?.hideTabBar()
        }
        else {
            (tabBarController as? BaseTabBarViewController)?.showTabBar()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppStateManager.shared.isOpeningNotification = false
        AppStateManager.shared.isOpeningNotificationDetail = false
        
        if !UIConstants.isLoggedIn {
            categoryCollectionView.items = [
                //                HomeCategoryModel(id: 0, name: "MEDICINE_DOCTOR".localize().capitalized, imageURL: "ic_medicine"),
                HomeCategoryModel(id: 1, name: "LIST_CONTRACT".localize().capitalized, imageURL: "ic_contract"),
                HomeCategoryModel(id: 2, name: "USE_POINTS".localize().capitalized, imageURL: "ic_crown")
            ]
            
            self.categoryCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(cardView.snp_bottom).offset(UIPadding.size16)
                make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
                make.height.equalTo(120)
            }
        }
        else {
            let categoriesItems = [
                //                HomeCategoryModel(id: 0, name: "MEDICINE_DOCTOR".localize().capitalized, imageURL: "ic_medicine"),
                HomeCategoryModel(id: 1, name: "LIST_CONTRACT".localize().capitalized, imageURL: "ic_contract"),
                HomeCategoryModel(id: 2, name: "USE_POINTS".localize().capitalized, imageURL: "ic_crown"),
            ]
            categoryCollectionView.items = categoriesItems
        }
        
        
        categoryCollectionView.reloadData()
        
        updateUI()
        fetchAPIs()
        
        updateCardLayouts()
        //        myCardsView?.reloadData()
        
        guard biometricType != .none else {
            UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
            return
        }
        
        showBiometricPopup()
        
    }
    
    func showBiometricPopup() {
        if !UIConstants.isLoggedIn || UserDefaults.standard.bool(forKey: Key.biometricAuth.rawValue) || UserDefaults.standard.bool(forKey: Key.hasRequestedBiometricAuth.rawValue) {
            return
        }
        
        let typeStr = biometricType == .faceID ? "Face ID" : "Touch ID"
        let icon = biometricType == .faceID ? "faceId" : "touchId"
        queueBasePopup(icon: UIImage(named: icon), title: "\("USE".localize()) \(typeStr)", desc: "ALLOW_APP_TO_USE".localize().replace(string: "@", replacement: typeStr), okTitle: "AGREE".localize(), cancelTitle: "NONE".localize(), okHandler: {
            UserDefaults.standard.set(true, forKey: Key.hasRequestedBiometricAuth.rawValue)
            self.biometry.authWithBiometry()
        }, handler: {
            UserDefaults.standard.set(true, forKey: Key.hasRequestedBiometricAuth.rawValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
            }
            self.authFail(error: NSError.init(domain: "User cancel", code: LAError.userCancel.rawValue, userInfo: nil))
            
        }, priority: .high)
    }
    
    func showEventPopup(info: HomeEventModel) {
        let eventPopupView = EventPopupView()
            eventPopupView.data = info
            eventPopupView.callback = {
                let vc = CampaignDetailViewController(nibName: "CampaignDetailViewController", bundle: nil)
                vc.id = info.campaignId ?? ""
                vc.callback = {
                    //                guard var readPopup = UserDefaults.standard.array(forKey: Key.readPopup.rawValue) as? [String] else {return}
                    //                readPopup.appendIfNotContains(info.campaignId ?? "")
                    //                UserDefaults.standard.set(readPopup, forKey: Key.readPopup.rawValue)
                    EventPopupManager.shared.appendToList(id: info.campaignId ?? "")
                    PopupManager.shared.removePopup()
                    self.startShowPopup()
                }
                (self.tabBarController as? BaseTabBarViewController)?.navigationController?.pushViewController(vc, animated: true)
            }
            eventPopupView.onClose = {
                //            guard var readPopup = UserDefaults.standard.array(forKey: Key.readPopup.rawValue) as? [String] else {return}
                //            readPopup.appendIfNotContains(info.campaignId ?? "")
                //            UserDefaults.standard.set(readPopup, forKey: Key.readPopup.rawValue)
                EventPopupManager.shared.appendToList(id: info.campaignId ?? "")
                PopupManager.shared.removePopup()
                self.startShowPopup()
            }
            
            //        view.addSubview(eventPopupView)
            //        eventPopupView.snp.makeConstraints { make in
            //            make.edges.equalToSuperview()
            //        }
            PopupManager.isShowingPopup = true
            let popupNode = PriorityNode(name: "EVENT_POPUP",priority: .high, popup: eventPopupView)
            PopupManager.shared.queuePopup(popupNode)
       
    }
    
    private func updateCardLayouts() {
        cardLayout = LayoutBuilder.shared.getListAffinaCards(cardData: cardData)
        myCardsView?.updateCardLayouts(cardLayout)
    }
    
    func fetchAPIs() {
        
        self.presenter.getListFeaturedProducts()
        
        if UIConstants.isLoggedIn, !CacheManager.shared.isExistCacheWithKey(Key.profile.rawValue), let token = UserDefaults.standard.string(forKey: Key.token.rawValue), !token.isEmpty {
            presenter.getProfile { [weak self] model in
                self?.updateUI()
            }
        }
        
        if UIConstants.isLoggedIn, !CacheManager.shared.isExistCacheWithKey(Key.insuranceCards.rawValue), let token = UserDefaults.standard.string(forKey: Key.token.rawValue), !token.isEmpty, !isFetchingCards {
            isFetchingCards = true
            cardPresenter.getListCards(limit: 100)
        }
        if UIConstants.isLoggedIn {
            self.voucherPresenter.getVoucherSummary()
        }
    }
    override func initViews() {
        
        view.addSubview(gradientView)
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        
        containerView.addSubview(customHeader)
        containerView.addSubview(categoryCollectionView)
        
        containerView.addSubview(cardView)
        
        containerView.addSubview(categoryCollectionView)
        
        containerView.addSubview(promotionProductView)
        containerView.addSubview(bestSellerProductView)
        
        let images = ["placeholder"]
        carouselView = HomeCarouselView(pages: images.count, delegate: self)
        //TODO: Replace the param to hide/show the new campaign flow
        carouselData = images.map({ HomeCarouselView.HomeCarouselData(id: "", image: $0) })
        //        carouselData = images.map({ HomeCarouselView.HomeCarouselData(link: "", image: $0) })
        myCardsView = HomeInsuranceCardView()//(pages: images.count, delegate: self)
        myCardsView?.pages = images.count
        myCardsView?.delegate = self
        //        cardData = images.map({ HomeInsuranceCardView.HomeCarouselData(image: UIImage(named: $0)) })
        myCardsView?.isHidden = true
        containerView.addSubview(myCardsView!)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-UIApplication.shared.statusBarFrame.height)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(490.height)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top)
            make.bottom.equalTo(view.safeArea.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.bottom.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        
        customHeader.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp_top).offset(UIPadding.size24)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
            make.height.equalTo(50)
        }
        
        cardView.snp.makeConstraints { make in
            make.top.equalTo(customHeader.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
            make.height.equalTo(250)
        }
        
        myCardsView!.snp.makeConstraints { make in
            make.top.equalTo(customHeader.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
            make.height.equalTo(210)
        }
        
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
            make.height.equalTo(120)
        }
        
        guard let carouselView = carouselView else { return }
        containerView.addSubview(carouselView)
        carouselView.translatesAutoresizingMaskIntoConstraints = false
        carouselView.snp.makeConstraints({ make in
            make.top.equalTo(categoryCollectionView.snp_bottom).inset(-UIPadding.size8)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.height.equalTo(160)
        })
        
        promotionProductView.snp.makeConstraints { make in
            make.top.equalTo(carouselView.snp_bottom).inset(-UIPadding.size16)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()//.inset(UIPadding.size16)
            make.height.equalTo(340)
        }
        
        bestSellerProductView.snp.makeConstraints { make in
            promotionBottomConstraint = make.top.equalTo(promotionProductView.snp_bottom).inset(-UIPadding.size16).constraint
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
            bestSellerHeightConstraint = make.height.equalTo(200).constraint
            make.bottom.equalToSuperview()
        }
        
    }
    
    func showCongratFirstInsuranceCard() {
        if let shown = UserDefaults.standard.array(forKey: Key.shownCongratsHome.rawValue) as? [String], let phoneNumber = UserDefaults.standard.string(forKey: Key.phoneNumber.rawValue), let _ = shown.first(where: {$0 == phoneNumber}) {
            self.myCardsView?.show()
            self.myCardsView?.updateCardLayouts(self.cardLayout)
            return
        }
        self.cardView.hide()
        self.categoryCollectionView.snp.remakeConstraints { make in
            make.top.equalTo(self.myCardsView!.snp_bottom).offset(UIPadding.size24)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.height.equalTo(120)
        }
        
        DispatchQueue.main.async {
            self.view.addSubview(self.grayScreen)
            let width = UIConstants.widthConstraint(HomeInsuranceCardCell.size.width + 36)
            self.successView = HomeInsuranceCardCell(frame: .init(x: 42, y: 200, width: width, height: HomeInsuranceCardCell.size.height + 24))
            guard let successView = self.successView else {
                return
            }
            let label = UILabel(frame: .init(x: 42, y: 150, width: width - 48, height: 50))
            label.numberOfLines = 0
            label.textAlignment = .center
            let text = "CONGRAT_FIRST_INSURANCE_PRODUCT".localize()
            label.attributedText = self.getAttributedString(arrayTexts: text.split(separator: ".").map({ String($0) }), arrayColors: [UIColor.appColor(.whiteMain)!, UIColor.appColor(.whiteMain)!], arrayFonts: [UIConstants.Fonts.appFont(.Regular, 16), UIConstants.Fonts.appFont(.Bold, 16)])
            self.view.addSubview(label)
            
            self.view.addSubview(successView)
            (successView as? HomeInsuranceCardCell)?.setCardBackground()
            (successView as? HomeInsuranceCardCell)?.item = self.cardData[0]
            self.successView!.layer.opacity = 0
            self.successView!.isHidden = true
            
            PopupManager.isShowingPopup = true
            let popupNode = PriorityNode(name: "CONGRAT_FIRST_INSURANCE_PRODUCT", priority: .normal, popup: successView) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    if self.successView != nil {
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                            self.grayScreen.removeFromSuperview()
                            self.successView!.layer.opacity = 0
                            self.successView!.isHidden = true
                            label.layer.opacity = 0
                            label.isHidden = true
                        }) { (_) in
                            if self.successView != nil {
                                self.successView!.removeFromSuperview()
                                label.removeFromSuperview()
                                self.successView = nil
                                self.centerYAlertConstraint = nil
                                self.hideBasePopup()
                                self.myCardsView?.show()
                                PopupManager.isShowingPopup = true
                                
                                self.myCardsView?.updateCardLayouts(self.cardLayout)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                                    self.showCustomPopup(zPosition: 50,messages: ["YOU_CAN_SEND_CLAIM".localize(), "YOU_CAN_BUY_MORE".localize()], positions: [
                                        CGPoint(x: 24, y: self.myCardsView!.convert(self.myCardsView!.frame.origin, to: self.view).y + 210 / 2 - 8),
                                        CGPoint(x: self.view.frame.width - 16 - 252, y: self.myCardsView!.convert(self.myCardsView!.frame.origin, to: self.view).y + 52 - 8)
                                    ]) {
                                        if var shown = UserDefaults.standard.array(forKey: Key.shownCongratsHome.rawValue) as? [String], let phoneNumber = UserDefaults.standard.string(forKey: Key.phoneNumber.rawValue) {
                                            shown.appendIfNotContains(phoneNumber)
                                            UserDefaults.standard.set(shown, forKey: Key.shownCongratsHome.rawValue)
                                        }
                                    }
                                })
                            }
                        }
                    }
                })
            }
            PopupManager.shared.queuePopup(popupNode)
        }
    }
    
}

extension HomeViewController: CustomHeaderHomeViewDelegate {
    func didTapNoticeButton() {
        AppStateManager.shared.isOpeningNotification = true
        let token = UserDefaults.standard.string(forKey: Key.token.rawValue)
        if token == nil {
            (tabBarController as? BaseTabBarViewController)?.hideTabBar()
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
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTapLoginButton() {
        let notFirstTimeLogin = UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue)
        if !notFirstTimeLogin {
            let vc = BaseNavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
            vc.onDismissCallback = {
                DispatchQueue.global(qos: .userInitiated).async { [self] in
                    fetchAPIs()
                    presenter.getBannerList()
                    presenter.getPopupList()
                }
            }
            presentInFullScreen(vc, animated: true, completion: nil)
        }
        else {
            let vc = BaseNavigationController(rootViewController: InputPinCodeViewController(nibName: InputPinCodeViewController.nib, bundle: nil))
            vc.onDismissCallback = {
                DispatchQueue.global(qos: .userInitiated).async { [self] in
                    fetchAPIs()
                    presenter.getBannerList()
                    presenter.getPopupList()
                }
            }
            
            presentInFullScreen(vc, animated: true, completion: nil)
        }
    }
    
    func didTapSearchButton() {
        //        let arr = [1, 2, 3]
        //        let elem = arr[4]
    }
    
}

// MARK: HomeViewDelegate
extension HomeViewController: HomeViewDelegate {
    func showPopupFromList(list: [HomeEventModel]) {
        if list.count == 0 {return}
        listPopup = list
        startShowPopup()
    }
    
    func startShowPopup() {
        if listPopup.count > 0 {
            guard let info = listPopup.popLast() else {return}
            DispatchQueue.main.async {
                self.showEventPopup(info: info)
            }
        }
    }
    
    func updateBannersList(list: [HomeBannerModel]) {
        //TODO: Uncomment this block to enable new campaign flow
        carouselData = []
        if list.count == 0 {
            carouselData.append(HomeCarouselView.HomeCarouselData(id: "-1", image:  "https://static.affina.com.vn/affina/f395d2bd-50d7-499f-9ea8-0e29190e5c6c.jpg"))
            carouselView?.configureView(with: carouselData)
            return
        }
        do {
            for i in 0...list.count - 1 {
                guard let images = list[i].images else { continue }
                if images.count > 0 {
                    
                    let jsonArray = try JSONDecoder().decode([[String: String]].self, from: images.data(using: .utf16) ?? Data())
                    if let imageItem = jsonArray.first(where: {$0["name"] == "image_long_one"}) {
                        let url = (imageItem["link"] != nil) ? "\(API.STATIC_RESOURCE)\(imageItem["link"] ?? "")" : ""
                        carouselData.append(HomeCarouselView.HomeCarouselData(id: list[i].campaignId ?? "", image: url))
                    }
                } else {
                    carouselData.append(HomeCarouselView.HomeCarouselData(id: list[i].campaignId ?? "", image: ""))
                }
            }
        } catch (let e) {
            Logger.Logs(message: e.localizedDescription)
        }
        carouselView?.configureView(with: carouselData)
    }
    
    func updateListProgramType(list: [ProgramType]) {
        cardView.categories = [ProgramType(id: "-1", majorId: "ALL", name: "ALL".localize(), type: -1)]
        cardView.categories.append(contentsOf: list.filter({ $0.type == 0 }))
    }
    
    func updateListBanners(list: [ListSetupBanner]) {
        //        Logger.Logs(message: list.map({ "\(API.STATIC_RESOURCE)\($0.banner ?? "")" }))
        //                carouselData = list.map({ HomeCarouselView.HomeCarouselData(link: $0.link ?? "",image: "\(API.STATIC_RESOURCE)\($0.banner ?? "")") })
        //                carouselView?.configureView(with: carouselData)
    }
    
    func updateListFeaturedProducts(list: [HomeFeaturedProduct]) {
        
        promotionProductView.setData(items: list, title: "DEALS_FOR_YOU".localize())
        
        bestSellerProductView.setData(items: list, title: "OUTSTANDING_PRODUCT".localize())
        
        let rowCount: Int = list.count / 2 + list.count % 2
        bestSellerHeightConstraint.update(offset: CGFloat(288 * rowCount) + BaseTabBarViewController.TABBAR_HEIGHT)
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func unLockUI() {
        unlockScreen()
    }
    
    func updateUI() {
        updateDisplayName()
        promotionProductView.isHidden = !UIConstants.isLoggedIn
        promotionBottomConstraint.update(inset: !UIConstants.isLoggedIn ? promotionProductView.frame.height : -UIPadding.size16)
        
        if !UIConstants.isLoggedIn {
            myCardsView?.hide()
            cardView.show()
        }
        if CacheManager.shared.isExistCacheWithKey(Key.profile.rawValue) {
            ParseCache.parseCacheToItem(key: Key.profile.rawValue, modelType: ProfileModel.self) { result in
                switch result {
                case .success(let profile):
                    if profile.companyId != nil  {
                        if profile.isActiveFlexi == nil || profile.isActiveFlexi == true{
                            self.categoryCollectionView.items = [
                                //            HomeCategoryModel(id: 0, name: "MEDICINE_DOCTOR".localize(), imageURL: "ic_medicine"),
                                HomeCategoryModel(id: 1, name: "LIST_CONTRACT".localize(), imageURL: "ic_contract"),
                                HomeCategoryModel(id: 2, name: "USE_COINS".localize(), imageURL: "ic_crown"),
                                HomeCategoryModel(id: 3, name: "FLEXI_BENEFITS".localize().capitalized, imageURL: "ic_employer")
                            ]
                            self.categoryCollectionView.reloadData()
                        }
                    }
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
                }
            }
        }
    }
    
    func updateDisplayName() {
        if UIConstants.isLoggedIn {
            customHeader.updateUI()
        }
        else {
            customHeader.showGuestState()
        }
    }
    
    func showAlert() {
        
    }
    
    func showError(error: ApiError) {
        switch error {
        case .refresh:
            break
        case .expired:
            logOut()
            updateUI()
            break
        case .requestTimeout(let _):
            if isShowingExpiredPopup { return }
            isShowingExpiredPopup = true
            DispatchQueue.main.async {
                
                self.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    self.isShowingExpiredPopup = false
                    UIConstants.isLoggedIn = false
                    self.updateUI()
                } handler: {
                    
                }
            }
        default:
            break
        }
    }
    
    func updateListCard(list: [ListSetupCard]) {
        allCardLayout = list
    }
    
    func updateNotificationStatus(status: Int) {
        if status == 1 { // SEEN
            customHeader.hideBadgeNoti()
        }
        else if status == 0 { // SENT
            customHeader.showBadgeNoti()
        }
    }
}

// MARK: CardViewDelegate
extension HomeViewController: CardViewDelegate {
    func unlockUI() {
        unlockScreen()
    }
    
    func updateUI(cards: [CardModel]) {
        self.isFetchingCards = false
        
        let cacheData = CacheData(json: Json.filterJson(cards))
        CacheManager.shared.insertCacheWithKey(Key.insuranceCards.rawValue, cacheData)
        
        guard !cards.isEmpty else { return }
        self.cardView.hide()
        self.cardData = cards
        self.myCardsView?.configureView(with: cards)
        self.updateCardLayouts()
        if !UserDefaults.standard.bool(forKey: Key.hasShownFirstCard.rawValue) {
            UserDefaults.standard.set(true, forKey: Key.hasShownFirstCard.rawValue)
            if !UserDefaults.standard.bool(forKey: Key.biometricAuth.rawValue) && !UserDefaults.standard.bool(forKey: Key.hasRequestedBiometricAuth.rawValue) && self.biometricType != .none {
                self.isNeedToShowFirstCardPopup = true
                return
            }
            
            self.showCongratFirstInsuranceCard()
        }
        else {
            self.cardView.hide()
            self.categoryCollectionView.snp.remakeConstraints { make in
                make.top.equalTo(self.myCardsView!.snp_bottom).offset(UIPadding.size24)
                make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
                make.height.equalTo(120)
            }
            self.myCardsView?.show()
        }
        
    }
    
    func updateClaimHistory(history: [ClaimHistoryModel]) {
        
    }
    
    func updateHospital(hospitals: [HospitalModel], isBlackList: Bool) {
        
    }
    
    
}

// MARK: CarouselViewDelegate
extension HomeViewController: CarouselViewDelegate {
    func currentPageDidChange(to page: Int) {
        UIView.animate(withDuration: 0.7) {
            
        }
    }
}

// MARK: HomeFindingInsuranceDelegate
extension HomeViewController: HomeFindingInsuranceDelegate {
    func didTapInsuranceList(_ id: String) {
        let filterVc = InsuranceFilterViewController()
        filterVc.isOpenedDirectly = true
        filterVc.selectedTypeId = id
        let vc = UINavigationController(rootViewController: filterVc)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func didTapInsuranceIcon() {
        let filterVc = InsuranceApproachViewController()
        let vc = UINavigationController(rootViewController: filterVc)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

// MARK: HomeInsuranceCardViewDelegate
extension HomeViewController: HomeInsuranceCardViewDelegate {
    func didTapInfoButton(index: Int) {
        
        let vc = CardViewController()
        vc.selectedIndex = index
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapRequestButton(index: Int) {
        
        let vc = CardClaimViewController()
        vc.insuredName = cardData[index].peopleName
        vc.contractId = cardData[index].contractId ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapAddButton() {
        let vc = UINavigationController(rootViewController: InsuranceApproachViewController())
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    //    func loadMoreCards(contractId: String, createdAt: Double) {
    //        cardPresenter.getMoreListCards(contractId: contractId, createdAt: createdAt)
    //    }
}

// MARK: BiometryAuthDelegate
extension HomeViewController: BiometryAuthDelegate {
    func authFail(error: Error?) {
        Logger.Logs(message: "AUTH FAIL")
        if isNeedToShowFirstCardPopup {
            isNeedToShowFirstCardPopup = false
            PopupManager.isShowingPopup = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showCongratFirstInsuranceCard()
            }
            
        }
        guard let error = error else {
            return
        }
        Logger.Logs(event: .error, message: error.localizedDescription)
        switch error._code {
        case LAError.authenticationFailed.rawValue:
            break
        case LAError.userCancel.rawValue:
            break
        default:
            break
        }
    }
    
    func authSuccessful() {
        Logger.Logs(message: "AUTH SUCCESSFUL")
        UserDefaults.standard.set(true, forKey: Key.biometricAuth.rawValue)
        self.hideBasePopup()
        
        if isNeedToShowFirstCardPopup {
            isNeedToShowFirstCardPopup = false
            PopupManager.isShowingPopup = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showCongratFirstInsuranceCard()
            }
            
        }
    }
    
    func deviceNotSupport() {
    }
}

// MARK: HomeProductCollectionViewDelegate
extension HomeViewController: HomeProductCollectionViewDelegate {
    func didTapBuyButton(item: HomeFeaturedProduct) {
        let filterVc = InsuranceFilterViewController()
        filterVc.isOpenedDirectly = true
        let vc = UINavigationController(rootViewController: filterVc)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension HomeViewController: PointViewDelegate {
    func updateVoucherSummary(summary: VoucherSummaryModel) {
        AppStateManager.shared.userCoin = summary.coin ?? 0
        customHeader.updateUI()
    }
    
    func updateListVoucher(list: [VoucherModel], showAt: VoucherTypeEnum) {}
    
    func updateListCategory(list: [VoucherCategoryModel]) {}
}
