//
//  CardClaimViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/08/2022.
//

import UIKit
struct HomeCategoryStruct{
    var data : HomeCategoryModel
    var name : String
    var disable : Bool
}
class CardClaimViewController: BaseViewController {
    
    
    static let nib = "CardClaimViewController"
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var infoButton: BaseButton!
    
    @IBOutlet weak var cardImageView: UIImageView!
    
    @IBOutlet weak var ownerLabel: BaseLabel!
    @IBOutlet weak var expiredDateLabel: BaseLabel!
    @IBOutlet weak var cardNameLabel: BaseLabel!
    
    @IBOutlet weak var emptyLabel: BaseLabel!
    
    @IBOutlet weak var cardsView: CardInsuranceCarouselView!
    private var cardData : [CardModel] = [] {
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    } // [CardInsuranceCarouselView.CarouselData]()
    
    @IBOutlet weak var noteLabel: BaseLabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var cardViewTopConstraint: NSLayoutConstraint!
    private var items : [HomeCategoryStruct] = [
        HomeCategoryStruct(data: HomeCategoryModel(id: 0, name: ClaimType.LABOR_ACCIDENT.string, imageURL: "ic_accident"), name: "ACCIDENT", disable: true),
        HomeCategoryStruct(data:  HomeCategoryModel(id: 1, name: ClaimType.ILLNESS.string, imageURL: "ic_bed"), name: "ILLNESS", disable: true),
        HomeCategoryStruct(data:  HomeCategoryModel(id: 2, name: ClaimType.DENTISTRY.string, imageURL: "ic_tooth"), name: "DENTAL", disable: true),
        HomeCategoryStruct(data:  HomeCategoryModel(id: 3, name: ClaimType.MATERNITY.string, imageURL: "ic_pregnant"), name: "MATERNITY", disable: true),
        HomeCategoryStruct(data:  HomeCategoryModel(id: 4, name: ClaimType.SUBSIDY_FOR_HOSPITAL_FEE_INCOME.string, imageURL: "ic_money"), name: "ALLOWANCE_INCOME", disable: true),
        HomeCategoryStruct(data:  HomeCategoryModel(id: 5, name: ClaimType.DEATH_BY_ACCIDENT_ILLNESS.string, imageURL: "ic_rip"), name: "DEATH_ILLNESS", disable: true),
    ]
    private var statusBM : Int = 0
//    private var items: [HomeCategoryModel] = [
//            HomeCategoryModel(id: 0, name: ClaimType.LABOR_ACCIDENT.string, imageURL: "ic_accident"),
//            HomeCategoryModel(id: 1, name: ClaimType.ILLNESS.string, imageURL: "ic_bed"),
//            HomeCategoryModel(id: 2, name: ClaimType.DENTISTRY.string, imageURL: "ic_tooth"),
//            HomeCategoryModel(id: 3, name: ClaimType.MATERNITY.string, imageURL: "ic_pregnant"),
//            HomeCategoryModel(id: 4, name: ClaimType.SUBSIDY_FOR_HOSPITAL_FEE_INCOME.string, imageURL: "ic_money"),
//            HomeCategoryModel(id: 5, name: ClaimType.DEATH_BY_ACCIDENT_ILLNESS.string, imageURL: "ic_rip")
//        ]
    
    private let claimTypes: [ClaimType] = [ClaimType.LABOR_ACCIDENT, ClaimType.OUTPATIENT, ClaimType.DENTISTRY, ClaimType.MATERNITY, ClaimType.HOSPITALIZATION_ALLOWANCE, ClaimType.DEAD]
    
    private let presenter = CardViewPresenter()
    
    private var currentCard: Int = 0
    
    var insuredName: String = "" {
        didSet {
            labelBaseTitle.text = insuredName
        }
    }
    var contractId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        hideHeaderBase()
        containerBaseView.hide()
        setupHeaderView()
        
        
        presenter.setViewDelegate(self)
        presenter.getListCardsByName(name: insuredName)
        
        let images = [UIImage(named: "carouselImage"), UIImage(named: "carouselImage"), UIImage(named: "carouselImage")]
        cardsView.pages = images.count
        cardsView.delegate = self
        cardsView.type = 0
        cardsView.configureView(with: cardData) // TODO:
        
        cardViewTopConstraint.constant = UIConstants.Layout.headerHeight + 20
        
       
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: CardClaimCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: CardClaimCollectionViewCell.cellId)
//        collectionView.collectionViewLayout = UICollectionViewLayout()
        
       
        
        view.backgroundColor = .appColor(.blueUltraLighter)
//        viewBaseContent.backgroundColor = .clear
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        statusBM = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }

    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = insuredName
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_account")?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.tintColor = .appColor(.black)
        rightBaseImage.addTapGestureRecognizer {
            let vc = SelectInsuredViewController()
            vc.callback = { [weak self] model in
                self?.insuredName = model.name
                self?.presenter.getListCardsByName(name: model.name)
                self?.contractId = ""
                self?.currentCard = 0
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func updateCardLayouts() {
        let editedCard = LayoutBuilder.shared.getListProviderCards(cardData: cardData)
        cardsView.updateCardLayouts(editedCard)
    }
}

extension CardClaimViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardClaimCollectionViewCell.cellId, for: indexPath) as? CardClaimCollectionViewCell else { return UICollectionViewCell() }
        cell.item = items[indexPath.row].data
        if items[indexPath.row].disable {
            cell.viewDisable.isHidden = false
        }
        return cell
    }
    func checkCategory(cardData : CardModel,items:[HomeCategoryStruct]){
        guard let activeBenefits = cardData.activeBenefits else{
            return
        }
        for i in 0..<items.count{
            for y in 0..<activeBenefits.count{
                if items[i].name == activeBenefits[y]{
                    self.items[i].disable = false
                    self.statusBM += 1
                }
            }
        }
        if activeBenefits.count != 6 {
            let arrayStr = "TO_CONTINUE_YOU_NEED_BM".localize().split(separator: "@").map({ String($0) })
            noteLabel.attributedText = getAttributedString(arrayTexts: arrayStr,
                                                           arrayColors: [UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!],
                                                           arrayFonts: [noteLabel.font, UIConstants.Fonts.appFont(.Bold, 14), noteLabel.font])
        }else{
            let arrayStr = "TO_CONTINUE_YOU_NEED".localize().split(separator: "@").map({ String($0) })
            noteLabel.attributedText = getAttributedString(arrayTexts: arrayStr,
                                                           arrayColors: [UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!],
                                                           arrayFonts: [noteLabel.font, UIConstants.Fonts.appFont(.Bold, 14), noteLabel.font])
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let activeBenefits = self.cardData[self.currentCard].activeBenefits else{
            return
        }
        if !items[indexPath.row].disable{
                let model = ClaimRequestModel(contractObjectId: cardData[currentCard].contractObjectId, amountClaim: nil, bankCode: nil, bankBranch: nil, accountName: nil, accountNumberBank: nil, relationship: nil, claimType: claimTypes[indexPath.row], hospitalizedDate: nil, hospitalDischargeDate: nil, placeOfTreatment: nil, diagnostic: nil, upload: nil)
                if claimTypes[indexPath.row] == .DEAD {
                    let vc = ProofDeathViewController()
                    vc.requestModel = model
                    vc.cardModel = cardData[currentCard]
                    navigationController?.pushViewController(vc, animated: true)
                    return
                }
                let vc = ProofViewController()
                vc.activeBenefits = activeBenefits
                vc.type = claimTypes[indexPath.row]
                vc.requestModel = model
                vc.cardModel = cardData[currentCard]
                vc.index = indexPath.row
                navigationController?.pushViewController(vc, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize = CardClaimCollectionViewCell.size
        return CGSize(width: size.width, height: size.height + 12)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size16
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return UIPadding.size8
//    }

}

// MARK: CardInsuranceCarouselDelegate
extension CardClaimViewController: CardInsuranceCarouselDelegate {
    
    func loadMoreCards(contractId: String, contractObjectId: String, createdAt: Double) {
        presenter.getMoreListCardsByName(name: insuredName, contractId: contractId, contractObjectId: contractObjectId, createdAt: createdAt)
    }
    
    func didTapEditButton(index: Int) {
    }
    
    func didTapRequestButton(index: Int) {
    }
    
    func didSwipeCard(index: Int) {
        currentCard = index
        contractId = cardData[index].contractId
    }
}

// MARK: CardViewDelegate
extension CardClaimViewController: CardViewDelegate {
    func updateHospital(hospitals: [HospitalModel], isBlackList: Bool) {
        
    }
    
    func updateClaimHistory(history: [ClaimHistoryModel]) {
        
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateUI(cards: [CardModel]) {
        if cardsView.isLoadingMore {
            cardData += cards
        }
        else {
            cardData = cards
        }
        var index = 0
        for i in 0..<cardData.count {
            if cardData[i].contractId == contractId {
                index = i
            }
        }
        currentCard = index
        self.cardsView.endReached = cards.isEmpty
        self.cardsView.configureView(with: self.cardData)
        
        if !cards.isEmpty {
            self.updateCardLayouts()
        }
        
        self.cardsView.isLoadingMore = false
        
        
        self.cardsView.scrollTo(index: currentCard + 1)
        
        if cardData.isEmpty {
            emptyLabel.show()
            cardsView.hide()
        }
        else {
            emptyLabel.hide()
            cardsView.show()
        }
        checkCategory(cardData: cardData[currentCard], items: items)
        collectionView.reloadData()
    }
    
    func showError(error: ApiError) {
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
}
