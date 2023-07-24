//
//  CompanyViewController.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit

class CompanyViewController: BaseViewController {

    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var insuranceProvidedLabel: BaseLabel!
    @IBOutlet weak var detailBenefitsLabel: BaseLabel!
    @IBOutlet weak var availableBenefitsLabel: BaseLabel!
    
    @IBOutlet weak var ExchangedBenefitsLabel: BaseLabel!
    @IBOutlet weak var usedPointsLabel: BaseLabel!
    @IBOutlet weak var heartLabel: BaseLabel!
    @IBOutlet weak var voucherLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var maxPointLabel: BaseLabel!
    
    @IBOutlet weak var pointView: BaseView!
    @IBOutlet weak var voucherView: BaseView!
    @IBOutlet weak var heartView: BaseView!
    
    @IBOutlet weak var benefitTableView: ContentSizedTableView!
    @IBOutlet weak var insuranceCollectionView: UICollectionView!
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    
    private let presenter = FlexiViewPresenter()
    
    private var listBenefit: [FlexiBenefitModel] = []
    private var listCard: [CardModel] = []
    var cardLayouts: [ListSetupCard] = []
    private var iconBenefits: [ListSetupIconFlexi] = LayoutBuilder.shared.getListIconFlexi()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.delegate = self
        setLabel()
        setupHeaderView()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.backgroundLightGray)
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        benefitTableView.delegate = self
        benefitTableView.dataSource = self
        benefitTableView.register(UINib(nibName: CompanyBenefitTableViewCell.nib, bundle: nil), forCellReuseIdentifier: CompanyBenefitTableViewCell.cellId)
        
        insuranceCollectionView.delegate = self
        insuranceCollectionView.dataSource = self
        insuranceCollectionView.register(CardInsuranceCollectionViewCell.self, forCellWithReuseIdentifier: CardInsuranceCollectionViewCell.cellId)
        
        pointView.addTapGestureRecognizer {
            let vc = FlexiCategoriesViewController()
            vc.viewType = .company
            self.navigationController?.pushViewController(vc, animated: true)
        }
        voucherView.addTapGestureRecognizer {
            let vc = VoucherListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        heartView.addTapGestureRecognizer {
//            let vc = AppreciateViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    private func setLabel(){
        ExchangedBenefitsLabel.text = "EXCHANGED_BENEFITS".localize().capitalized
        ExchangedBenefitsLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        ExchangedBenefitsLabel.numberOfLines = 0
        usedPointsLabel.text = "USED_POINTS".localize().capitalized
        detailBenefitsLabel.text =
        "DETAIL_BENEFITS".localize().uppercased()
        insuranceProvidedLabel.text = "INSURANCE_PROVIDED".localize().uppercased()
        availableBenefitsLabel.text = "AVAILABLE_BENEFITS".localize().capitalized
    }
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "MY_COMPANY".localize().capitalized
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_search_black") // ?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.contentMode = .scaleAspectFit
        rightBaseImage.frame = CGRect(origin: rightBaseImage.frame.origin, size: .init(width: 20, height: 20))
        rightBaseImage.addTapGestureRecognizer {
            
        }
        rightBaseImage.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
        
        presenter.getSummary()
        presenter.getListFlexi()
        presenter.getListSmeCards(limit: 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateUI()
    }

    func updateUI() {
        guard let model = AppStateManager.shared.flexiSummary else { return }
        let dateText = "\((model.expiredAt ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
        let attrs = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 14)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: dateText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: "\("EXPIRY".localize()): ")
        attributedString.insert(normalString, at: 0)
        dateLabel.attributedText = attributedString
        
        let pointText = "\((model.point ?? 0).addComma()) "
        let attrs3 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 36)
        ] as [NSAttributedString.Key : Any]
        let attributedString3 = NSMutableAttributedString(string: pointText, attributes: attrs3)
        let normalString3 = NSMutableAttributedString(string: "POINT".localize())
        attributedString3.append(normalString3)
        maxPointLabel.attributedText = attributedString3
        
        let heartText = "\((model.usedPoint ?? 0).addComma()) "
        let attrs4 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)
        ] as [NSAttributedString.Key : Any]
        let attributedString4 = NSMutableAttributedString(string: heartText, attributes: attrs4)
        let normalString4 = NSMutableAttributedString(string: "POINT".localize())
        attributedString4.append(normalString4)
        heartLabel.attributedText = attributedString4
        
        let voucherText = "\((model.benefitCount ?? 0).addComma()) "
        let attrs5 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)
        ] as [NSAttributedString.Key : Any]
        let attributedString5 = NSMutableAttributedString(string: voucherText, attributes: attrs5)
        let normalString5 = NSMutableAttributedString(string: "vouchers")
        attributedString5.append(normalString5)
        voucherLabel.attributedText = attributedString5
        
    }
    
    func updateCardLayoutsNBenefitIcons(_ list: [ListSetupCard], _ icons: [ListSetupIconBenefit]) {
        cardLayouts = list
//        iconBenefits = icons
//        print(list)
//        DispatchQueue.main.async {
//            self.insuranceCollectionView.reloadData()
//        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension CompanyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBenefit.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyBenefitTableViewCell.cellId, for: indexPath) as? CompanyBenefitTableViewCell else { return UITableViewCell() }
        cell.item = listBenefit[indexPath.row]
        
        for icon in iconBenefits {
//            for ic in icon.listBenefit ?? [] {
//                if (ic.benefitID == (listBenefit[indexPath.row].benefitId ?? "")) && (ic.benefitType == (listBenefit[indexPath.row].type?.rawValue ?? 0)) {
//
//                }
//            }
            if icon.name == listBenefit[indexPath.row].benefitName {
                cell.iconString = icon.icon ?? ""
            }
        }
        
        cell.actionCallBack = { [weak self] in
            guard let self = self else { return }
            let view = ExchangeDayOffView()
            view.point = self.listBenefit[indexPath.row].point ?? 0
            view.usedDay = self.listBenefit[indexPath.row].isUse ?? 0
            view.maxDay = self.listBenefit[indexPath.row].maxDay ?? 0
            view.cancelCallBack = {
                self.hideBottomSheet(animated: true)
            }
            view.submitCallBack = { dayAmount in
                if dayAmount == 0 { return }
                self.presenter.exchangeDayOffs(benefitId: self.listBenefit[indexPath.row].benefitId ?? "", exchangeDays: dayAmount)
            }
            self.bottomSheet.topBarView.backgroundColor = .appColor(.blueUltraLighter)
            self.bottomSheet.view.backgroundColor = .appColor(.blueUltraLighter)
            self.bottomSheet.view.layer.cornerRadius = 32
            self.bottomSheet.setContentForBottomSheet(view)
            self.setNewBottomSheetHeight(420.height)
            self.showBottomSheet(animated: true)
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        <#code#>
//    }
}

// MARK: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension CompanyViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCard.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardInsuranceCollectionViewCell.cellId, for: indexPath) as? CardInsuranceCollectionViewCell else { return UICollectionViewCell() }
        cell.xPadding = 0
        //            let image = carouselData[indexPath.row].image
        //            cell.configure(image: image)
        cell.item = listCard[indexPath.row]
        cell.backgroundAsset = .appColor(.pinkLighter) // cardColors[indexPath.row]
        cell.requestCallBack = {
            let vc = CardClaimViewController()
            vc.insuredName = self.listCard[indexPath.row].peopleName
            self.navigationController?.pushViewController(vc, animated: true)
        }
        cell.editCallBack = {
            let vc = ContractDetailViewController()
            vc.setContractId(contractId: self.listCard[indexPath.row].contractId)
            vc.setContractObjectId(contractObjectId: self.listCard[indexPath.row].contractObjectId)
            vc.cardImage = UIImage(named: "Card_4")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        for cardLayout in cardLayouts {
            if LayoutBuilder.shared.isAbleToApplyCardLayout(card: listCard[indexPath.row], layout: cardLayout)
            {
                cell.updateCardLayout(cardLayout.listCardOrder ?? [])
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CardInsuranceCollectionViewCell.size
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return .init(top: 0, left: 0, bottom: 0, right: 0 )
//    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size16
    }

}

// MARK: UIScrollViewDelegate
extension CompanyViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

// MARK: FlexiViewDelegate
extension CompanyViewController: FlexiViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateSummary() {
        updateUI()
    }
    
    func updateListBenefit(list: [FlexiBenefitModel]) {
        listBenefit = list
        
        DispatchQueue.main.async {
            self.benefitTableView.reloadData()
        }
    }
    
    func updateListCardSME(list: [CardModel]) {
        listCard = list
        DispatchQueue.main.async {
            self.insuranceCollectionView.reloadData()
            self.heightConstraints.constant = 190.height * CGFloat(self.listCard.count + 1)
            self.view.layoutIfNeeded()
        }
    }
    
    func exchangeDayOffsSuccess(model: FlexiExchangeDaysModel) {
        
        self.hideBottomSheet(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.queueBasePopup(icon: UIImage(named: "ic_question_mark_circle"), title: "REDEEMED_SUCCESSFULLY".localize().capitalized, desc: "\(model.exchangeDays ?? 0) ngày phép của bạn đã được quy đổi thành \(((model.points ?? 0)).addComma()) đ", okTitle: "GOT_IT".localize(), cancelTitle: "") {
                self.hideBasePopup()
                self.presenter.getSummary()
                self.presenter.getListFlexi()
            } handler: {
            }
        }
        
    }
    
    func handleExchangeError(code: String, message: String) {
        self.hideBottomSheet(animated: true)    
        if code == "FLEXI_4001" {
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "User reached limit exchange days", okTitle: "GOT_IT".localize(), cancelTitle: "") {
                self.hideBasePopup()
            } handler: {
                
            }

        }
    }
}
