//
//  CardViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import UIKit

class CardViewController: BaseViewController {
    
    // MARK: Views
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addTapGestureRecognizer {
            self.view.endEditing(true)
        }
        return scrollView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var gradientView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "homeBg"))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emptyLabel: BaseLabel = {
        let label = BaseLabel()
        label.font = UIConstants.Fonts.appFont(.Medium, 24)
        label.text = "NO_INSURANCE_CARD".localize()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var hScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var hospitalButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 16
        button.backgroundAsset = "blue"
        button.colorAsset = "whiteMain"
        button.setTitle("LIST_OF_GURANTEE_HOSPITAL".localize(), for: .normal)
        button.titleLabel?.font = UIConstants.Fonts.appFont(.Bold, 14)
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        return button
    }()
    
    private lazy var blackListButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 16
        button.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        button.colorAsset = "subText"
        button.setTitle("BLACK_LIST".localize(), for: .normal)
        button.titleLabel?.font = UIConstants.Fonts.appFont(.Bold, 14)
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        return button
    }()
    
    private lazy var historyButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.cornerRadius = 16
        button.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        button.colorAsset = "subText"
        button.setTitle("HISTORY".localize() + "  ", for: .normal)
        button.titleLabel?.font = UIConstants.Fonts.appFont(.Bold, 14)
        button.clipsToBounds = true
        button.titleLabel?.textAlignment = .center
        //        if #available(iOS 15.0, *) {
        //            button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 8, trailing: -20)
        //        } else {
        // Fallback on earlier versions
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        //        }
        return button
    }()
    
    //    private lazy var historyNotiView: UIImageView = {
    //        let imageView = UIImageView(image: UIImage(named: "ic_badge"))
    //        imageView.translatesAutoresizingMaskIntoConstraints = false
    //        imageView.contentMode = .scaleAspectFit
    //        return imageView
    //    }()
    
    private lazy var hospitalView: CardHospitalListView = {
        let view = CardHospitalListView() //.instanceFromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigateCallBack = { [weak self] vc in
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        view.searchCallBack = { [weak self] text in
            guard let self = self else { return }
            self.presenter.getHospitalList(contractObjectId: self.cardData[self.selectedIndex].contractObjectId, search: text)
        }
        return view
    }()
    
    private lazy var historyView: CardCompensationHistoryView = {
        let view = CardCompensationHistoryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.navigationCallBack = { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.didFilterState = { [weak self] state in
            guard let self = self else { return }
            self.presenter.getClaimList(contractObjectId: self.cardData[self.selectedIndex].contractObjectId, status: state == -1 ? nil : state)
        }
        return view
    }()
    
    private lazy var blackListView: CardBlackListView = {
        let view = CardBlackListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.searchCallBack = { [weak self] text in
            guard let self = self else { return }
            self.presenter.getHospitalList(contractObjectId: self.cardData[self.selectedIndex].contractObjectId, isBlackList: true, search: text)
        }
        return view
    }()
    
    private var myCardsView: CardInsuranceCarouselView?
    private var cardData = [CardModel]() // [CardInsuranceCarouselView.CarouselData]()
    
    
    private var hospitals = [HospitalModel]()
    private var blackListHospitals = [HospitalModel]()
    private var claimHistory = [ClaimHistoryModel]()
    
    private let presenter = CardViewPresenter()
    
    var selectedIndex: Int = 0
    var currentTab: Int = 0
    private var firstView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubviewToBack(gradientView)
        view.backgroundColor = .appColor(.backgroundLightGray)
        viewBaseContent.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTitle), name: NSNotification.Name(rawValue: Key.changeLocalize.rawValue), object: nil)
        
        reloadTitle()
        
        historyButton.addTarget(self, action: #selector(didTapHistoryButton), for: .touchUpInside)
        hospitalButton.addTarget(self, action: #selector(didTapHospitalButton), for: .touchUpInside)
        blackListButton.addTarget(self, action: #selector(didTapBlackListButton), for: .touchUpInside)
        
        
        presenter.setViewDelegate(self)
        
        ParseCache.parseCacheToArray(key: Key.insuranceCards.rawValue, modelType: CardModel.self) { result in
            switch result {
                case .success(let cards):
                    //                    self.cardData = cards
                    self.updateUI(cards: cards)
                    if !cards.isEmpty {
                        self.presenter.getClaimList(contractObjectId: cards[self.selectedIndex].contractObjectId)
                        self.presenter.getHospitalList(contractObjectId: cards[self.selectedIndex].contractObjectId)
                        self.presenter.getHospitalList(contractObjectId: cards[self.selectedIndex].contractObjectId, isBlackList: true)
                        
                        self.myCardsView?.scrollTo(index: self.selectedIndex + 1)
                    }
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self.presenter.getListCards(limit: 100)
            }
        }
        
        blackListView.navigateCallBack = { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        updateCardLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !cardData.isEmpty {
            self.presenter.getClaimList(contractObjectId: cardData[self.selectedIndex].contractObjectId)
            self.presenter.getHospitalList(contractObjectId: cardData[self.selectedIndex].contractObjectId)
            self.presenter.getHospitalList(contractObjectId: cardData[self.selectedIndex].contractObjectId, isBlackList: true)
            
//            self.myCardsView?.scrollTo(index: self.selectedIndex + 1)
        }
    }
    
    override func initViews() {
        setupHeaderView()
        view.addTapGestureRecognizer {
            self.view.endEditing(true)
        }
        view.addSubview(gradientView)
        viewBaseContent.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubviews(emptyLabel)
        
        let images = [UIImage(named: "carouselImage"), UIImage(named: "carouselImage"), UIImage(named: "carouselImage")]
        myCardsView = CardInsuranceCarouselView()//(pages: images.count, delegate: self)
        myCardsView?.pages = images.count
        myCardsView?.delegate = self
        //        cardData = images.map({ CardInsuranceCarouselView.CarouselData(image: $0) })
        containerView.addSubview(myCardsView!)
        myCardsView?.configureView(with: cardData) // TODO:
        
        containerView.addSubview(hScrollView)
        hScrollView.addSubview(hospitalButton)
        hScrollView.addSubview(blackListButton)
        hScrollView.addSubview(historyButton)
        //        historyButton.addSubview(historyNotiView)
        
        containerView.addSubview(hospitalView)
        containerView.addSubview(blackListView)
        containerView.addSubview(historyView)
        
        historyView.hide(isImmediate: true)
        blackListView.hide(isImmediate: true)
    }
    
    override func setupConstraints() {
        gradientView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-UIApplication.shared.statusBarFrame.height)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(490.height)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(viewBaseContent.snp_top)
            make.bottom.equalTo(viewBaseContent.safeArea.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.bottom.trailing.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(44)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
        }
        
        guard let myCardsView = myCardsView else { return }
        myCardsView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp_top).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview()//.inset(UIPadding.size24)
            make.height.equalTo(210)
        }
        
        hScrollView.snp.makeConstraints { make in
            make.top.equalTo(myCardsView.snp_bottom).offset(UIPadding.size64)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        
        hospitalButton.snp.makeConstraints { make in
            make.top.equalTo(myCardsView.snp_bottom).offset(UIPadding.size64)
            make.leading.equalToSuperview().offset(UIPadding.size16)
            //            make.trailing.equalTo(containerView.snp_centerX).offset(-UIPadding.size8)
            make.height.equalTo(36)
            
        }
        
        blackListButton.snp.makeConstraints { make in
            make.top.equalTo(hospitalButton.snp_top)
            //            make.trailing.equalToSuperview().offset(-UIPadding.size16)
            make.leading.equalTo(hospitalButton.snp_trailing).offset(UIPadding.size16)
            make.height.equalTo(36)
        }
        
        historyButton.snp.makeConstraints { make in
            make.top.equalTo(hospitalButton.snp_top)
            make.leading.equalTo(blackListButton.snp_trailing).offset(UIPadding.size16)
            make.trailing.equalToSuperview().offset(-UIPadding.size16)
            make.height.equalTo(36)
        }
        
        hospitalView.snp.makeConstraints { make in
            make.top.equalTo(hospitalButton.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.bottom.equalToSuperview()
        }
        
        historyView.snp.makeConstraints { make in
            make.top.equalTo(historyButton.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.bottom.equalToSuperview()
        }
        
        blackListView.snp.makeConstraints { make in
            make.top.equalTo(hospitalButton.snp_bottom).offset(UIPadding.size16)
            make.leading.trailing.equalToSuperview().inset(UIPadding.size16)
            make.bottom.equalToSuperview()
        }
        
        //        historyNotiView.snp.makeConstraints { make in
        //            make.top.bottom.trailing.equalToSuperview().inset(UIPadding.size8*3/2)
        //            make.width.equalTo(UIPadding.size8*3/2)
        //        }
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "INSURANCE_CARD".localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_insurance")?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.tintColor = .appColor(.black)
        rightBaseImage.addTapGestureRecognizer {
            let vc = InsuranceApproachViewController()
            self.presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
        }
    }
    
    private func updateCardLayouts() {
        let editedCard = LayoutBuilder.shared.getListProviderCards(cardData: cardData)
        myCardsView?.updateCardLayouts(editedCard)
        
    }
    
    @objc private func didTapHospitalButton() {
        view.endEditing(true)
        currentTab = 0
        
        hospitalButton.backgroundAsset = "blueMain"
        hospitalButton.colorAsset = "whiteMain"
        historyButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        historyButton.colorAsset = "subText"
        historyView.hide(isImmediate: true)
        historyView.items = []
        blackListButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        blackListButton.colorAsset = "subText"
        blackListView.hide(isImmediate: true)
        blackListView.items = []
        hospitalView.show()
        hospitalView.items = hospitals
        
        let offset = CGPoint(x: 0, y: 0)
        hScrollView.setContentOffset(offset, animated: true)
    }
    
    @objc private func didTapHistoryButton() {
        view.endEditing(true)
        currentTab = 2
        
        historyButton.backgroundAsset = "blueMain"
        historyButton.colorAsset = "whiteMain"
        hospitalButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        hospitalButton.colorAsset = "subText"
        hospitalView.hide(isImmediate: true)
        hospitalView.items = []
        blackListButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        blackListButton.colorAsset = "subText"
        blackListView.hide(isImmediate: true)
        blackListView.items = []
//        if self.claimHistory.isEmpty {
//            historyView.hide()
//        }
//        else {
            historyView.show()
//        }
        historyView.items = claimHistory
        
        //        let bottomOffset = CGPoint(x: hScrollView.contentSize.width - hScrollView.bounds.width + hScrollView.contentInset.right, y: 0)
        //        hScrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    @objc private func didTapBlackListButton() {
        view.endEditing(true)
        currentTab = 1
        
        blackListButton.backgroundAsset = "blueMain"
        blackListButton.colorAsset = "whiteMain"
        hospitalButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        hospitalButton.colorAsset = "subText"
        hospitalView.hide(isImmediate: true)
        hospitalView.items = []
        historyButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        historyButton.colorAsset = "subText"
        historyView.hide(isImmediate: true)
        historyView.items = []
        blackListView.show()
        blackListView.items = blackListHospitals
    }
    
    @objc private func reloadTitle() {
        labelBaseTitle.text = "INSURANCE_CARD".localize()
    }
}

// MARK: CardInsuranceCarouselDelegate
extension CardViewController: CardInsuranceCarouselDelegate {
    func loadMoreCards(contractId: String, contractObjectId: String, createdAt: Double) {
        presenter.getMoreListCards(contractId: contractId, contractObjectId: contractObjectId, createdAt: createdAt)
    }
    
    func didTapEditButton(index: Int) {
        if cardData[index].customerType != nil {
            let vc = ContractDetailViewController(nibName: ContractDetailViewController.nib, bundle: nil)
            vc.setContractId(contractId: cardData[index].contractId)
            vc.setContractObjectId(contractObjectId: cardData[index].contractObjectId)
            vc.setCustomertype(customerType: cardData[index].customerType!)
            print("___")
            print(cardData[index].customerType)
    
            vc.cardImage = UIImage(named: "Card_4")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTapRequestButton(index: Int) {
        let vc = CardClaimViewController(nibName: CardClaimViewController.nib, bundle: nil)
        vc.insuredName = cardData[index].peopleName
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    func loadMoreCards(contractId: String, createdAt: Double) {
//        presenter.getMoreListCards(contractId: contractId, contractObjectId: <#String#>, createdAt: createdAt)
//    }
    
    func didSwipeCard(index: Int) {
        let card = cardData[index]
        
        selectedIndex = index
        
        historyView.resetStatusFilter()
        
        claimHistory = []
        hospitals = []
        blackListHospitals = []
        presenter.getClaimList(contractObjectId: card.contractObjectId)
        presenter.getHospitalList(contractObjectId: card.contractObjectId)
        presenter.getHospitalList(contractObjectId: card.contractObjectId, isBlackList: true)
    }
}

// MARK: CardViewDelegate
extension CardViewController: CardViewDelegate {
    func updateHospital(hospitals: [HospitalModel], isBlackList: Bool) {
        if !isBlackList {
            if hospitalView.isLoadingMore {
                self.hospitals += hospitals
            } else {
                self.hospitals = hospitals
            }
            hospitalView.isLoadingMore = false
            hospitalView.endReached = hospitals.isEmpty
            
            hospitalView.items = self.hospitals
            
            if self.hospitals.isEmpty {
                //            emptyLabel.show()
                //            myCardsView?.hide()
            }
            else {
                //            emptyLabel.hide()
                //            myCardsView?.show()
            }
        } else {
            self.blackListHospitals = hospitals
            if blackListView.isLoadingMore {
                self.blackListHospitals += hospitals
            } else {
                self.blackListHospitals = hospitals
            }
            blackListView.isLoadingMore = false
            blackListView.endReached = hospitals.isEmpty
            
            blackListView.items = self.blackListHospitals
            
            if self.blackListHospitals.isEmpty {
                //            emptyLabel.show()
                //            myCardsView?.hide()
            }
            else {
                //            emptyLabel.hide()
                //            myCardsView?.show()
            }
        }
    }
    
    func updateClaimHistory(history: [ClaimHistoryModel]) {
        if historyView.isLoadingMore {
            self.claimHistory += history
        } else {
            self.claimHistory = history
        }
        historyView.isLoadingMore = false
        historyView.endReached = history.isEmpty
        
        historyView.items = self.claimHistory
        
//        if self.claimHistory.isEmpty {
//            //            emptyLabel.show()
//            historyView.hide()
//        }
//        else
        if currentTab == 2 {
            //            emptyLabel.hide()
            historyView.show()
        }
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateUI(cards: [CardModel]) {
        if myCardsView?.isLoadingMore ?? false {
            cardData += cards
        }
        else {
            cardData = cards
        }
        myCardsView?.endReached = cards.isEmpty
        myCardsView?.configureView(with: cardData)
        
//        var index = 0
//        for i in 0..<cardData.count {
//            if cardData[i].contractId == contractId {
//                index = i
//            }
//        }
//        selectedIndex = index
        if !cards.isEmpty {
            self.presenter.getClaimList(contractObjectId: cards[self.selectedIndex].contractObjectId)
            self.presenter.getHospitalList(contractObjectId: cards[self.selectedIndex].contractObjectId)
            self.presenter.getHospitalList(contractObjectId: cards[self.selectedIndex].contractObjectId, isBlackList: true)
            
//            self.myCardsView?.scrollTo(index: self.selectedIndex + 1)
            self.updateCardLayouts()
        }
        
        self.myCardsView?.isLoadingMore = false
        
        self.myCardsView?.scrollTo(index: selectedIndex + 1)
        
        if cardData.isEmpty {
            emptyLabel.show()
            myCardsView?.hide()
        }
        else {
            emptyLabel.hide()
            myCardsView?.show()
        }
        
    }
    
    func showError(error: ApiError) {
        switch error {
            case .expired:
                logOut()
                if firstView {
                    queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                        self.hideBasePopup()
                        
                        self.navigationController?.popToRootViewController(animated: true)
                    } handler: {
                        
                    }
                }
                firstView = false
                
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
            default:
                break
        }
    }
    
    
}

extension CardViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            if !hospitalView.isHidden && !hospitalView.isLoadingMore && !hospitalView.endReached {
                if self.hospitals.isEmpty || self.cardData.isEmpty { return }
                hospitalView.isLoadingMore = true
                self.presenter.getHospitalList(contractObjectId: self.cardData[self.selectedIndex].contractObjectId, hospitalId: self.hospitals[self.hospitals.count - 1].id, createdAt: self.hospitals[self.hospitals.count - 1].createdAt)
            }
            if !blackListView.isHidden && !blackListView.isLoadingMore && !blackListView.endReached {
                if self.blackListHospitals.isEmpty || self.cardData.isEmpty { return }
                blackListView.isLoadingMore = true
                self.presenter.getHospitalList(contractObjectId: self.cardData[self.selectedIndex].contractObjectId, hospitalId: self.blackListHospitals[self.blackListHospitals.count - 1].id, createdAt: self.blackListHospitals[self.blackListHospitals.count - 1].createdAt, isBlackList: true)
            }
            if !historyView.isHidden && !historyView.isLoadingMore && !historyView.endReached {
                if self.claimHistory.isEmpty || self.cardData.isEmpty { return }
                historyView.isLoadingMore = true
                self.presenter.getClaimList(contractObjectId: self.cardData[self.selectedIndex].contractObjectId, claimId: self.claimHistory[self.claimHistory.count - 1].id, createdAt: self.claimHistory[self.claimHistory.count - 1].createdAt, status: historyView.statusFilter == -1 ? nil : historyView.statusFilter)
            }
        }
    }
}
