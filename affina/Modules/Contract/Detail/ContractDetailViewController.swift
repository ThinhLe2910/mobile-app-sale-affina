//
//  ContractDetailViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import UIKit

class ContractDetailViewController: BaseViewController {
    
    static let nib = "ContractDetailViewController"
    private var customerType:Int?
    private var contractId: String?
    private var contractObjectId: String?
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var infoButton: BaseButton!
    @IBOutlet weak var stateButton: BaseButton!
   
    @IBOutlet weak var numberLabel: BaseLabel!
    @IBOutlet weak var ownerLabel: BaseLabel!
    @IBOutlet weak var expiredDateLabel: BaseLabel!
    @IBOutlet weak var insuranceMoneyLabel: BaseLabel!
    @IBOutlet weak var accountLabel: BaseLabel!
    
    @IBOutlet weak var stateButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var viewDownloadButton: BaseButton!
    @IBOutlet weak var viewTermsButton: BaseButton!
    
    private let presenter = ContractDetailViewPresenter()
    
    var contractObject: ListContractDetailObject? = nil
    private var items: [ContractListProductMainBenefit] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var sideItems: [ContractListProductSideBenefit] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var listCoverImageProgram = LayoutBuilder.shared.getListSetupCoverImageProgram()
    private var model: ContractDetailModel?
    var cardImage: UIImage? = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ContractDetailViewController")
//        accountLabel.isHidden = true
        hideHeaderBase()
        containerBaseView.hide()
        
        presenter.setViewDelegate(delegate: self)
        if let contractId = contractId {
            presenter.getContractDetail(contractId: contractId)
        }
        
        cardImageView.image = cardImage
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ContractDetailTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ContractDetailTableViewCell.cellId)
        
        addBlurStatusBar()
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        viewDownloadButton.addTarget(self, action: #selector(didTapViewDownloadButton), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        viewTermsButton.addTarget(self, action: #selector(didTapViewTermsButton), for: .touchUpInside)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        for item in listCoverImageProgram {
            if item.programID == model?.listContractObject[0].programID {
                if let url = URL(string: API.STATIC_RESOURCE + (item.imageDetail ?? "")) {
                    CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                        if error != nil {
                            DispatchQueue.main.async {
                                self?.cardImageView.image = self?.cardImage
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            self?.cardImageView.image = image
                        }
                    }
                    break
                }
            }
        }
        
        guard let contract = model else { return }
        
//        ownerLabel.text = contract.listContractObject[0].peopleName
//        expiredDateLabel.text = "\((contract.contractEndDate)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
//        numberLabel.text = contract.listContractObject[0].contractObjectIdProvider
        
        let currentTime = Date().timeIntervalSince1970
        if currentTime > Double(contract.listContractObject[0].contractObjectEndDate ?? 0)/1000 {
            stateButton.setTitle("Hết hạn", for: .normal)
            stateButton.setImage(UIImage(named: "ic_reject_state"), for: .normal)
        }
        else if currentTime < Double(contract.listContractObject[0].contractObjectStartDate ?? 0)/1000 {
            stateButton.setTitle("NEWLY_CREATED".localize(), for: .normal)
            stateButton.setImage(UIImage(named: "ic_new_state"), for: .normal)
        }
        else {
            stateButton.setTitle("VALID".localize(), for: .normal)
            stateButton.setImage(UIImage(named: "ic_processing_state"), for: .normal)
        }
        
        stateButtonWidthConstraint.constant = (stateButton.title(for: .normal)?.widthWithConstrainedHeight(height: stateButton.frame.height, font: UIConstants.Fonts.appFont(.ExtraBold, 10)) ?? 0) + 32
    }
    
    func setContractId(contractId: String) {
        self.contractId = contractId
    }
    func setCustomertype(customerType: Int) {
        self.customerType = customerType
    }
    func setContractObjectId(contractObjectId: String) {
        self.contractObjectId = contractObjectId
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapInfoButton() {
        showInforPopup()
        
    }
    
    @objc private func didTapViewDownloadButton() {
        guard let model = model, let contractObject = model.listContractObject.first(where: {$0.contractObjectID == (self.contractObjectId != nil ? self.contractObjectId : model.listContractObject[0].contractObjectID)}), let contractObjectURL = contractObject.contractObjectURL else {
            return
        }
        let vc = WebViewController()
        if contractObjectURL.starts(with: "http"){
            vc.setUrl(url: contractObjectURL, canDownload: true)
        }else{
            vc.setUrl(url: API.STATIC_RESOURCE + contractObjectURL, canDownload: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapViewTermsButton() {
        guard let model = model, let contractObject = model.listContractObject.first(where: {$0.contractObjectID == (self.contractObjectId != nil ? self.contractObjectId : model.listContractObject[0].contractObjectID)}), let document = contractObject.document else {
            return
        }
        let vc = WebViewController()
        if document.starts(with: "http"){
            vc.setUrl(url: document, canDownload: true)
        }else{
            vc.setUrl(url: API.STATIC_RESOURCE + document, canDownload: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showInforPopup() {
        let dialogWidth = 344.0
        let dialogHeight = 460.0
        if contractObject == nil {
            contractObject = model?.listContractObject[0]
        }
        guard let contractObject = contractObject else{
            return
        }
        if successView == nil {
            DispatchQueue.main.async {
                self.view.addSubview(self.grayScreen)
                self.successView = ContractPersonalInforPopup(frame: .zero)//.instanceFromNib()
                guard let successView = self.successView else {
                    return
                }
                (successView as? ContractPersonalInforPopup)?.setInfo(name: contractObject.peopleName ?? "", gender: contractObject.peopleGender, cccd: contractObject.peopleLicense ?? "", dob: Double(contractObject.peopleDob), email: contractObject.peopleEmail ?? "", phone: contractObject.peoplePhone ?? "", address: contractObject.peopleAddress ?? "", relationship: contractObject.peopleRelationship ?? 0)
                (successView as? ContractPersonalInforPopup)?.callBack = {
                    self.hideInforPopup()
                    //                    closure()
                }
                //                successView.translatesAutoresizingMaskIntoConstraints = false
                successView.frame = CGRect(origin: .init(x: (UIConstants.Layout.screenWidth - dialogWidth) / 2, y: (UIConstants.Layout.screenHeight - dialogHeight)/2), size: .init(width: dialogWidth, height: dialogHeight))
                self.view.addSubview(successView)
                
                self.successView!.layer.opacity = 0
                self.successView!.isHidden = true
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    self.successView!.layer.opacity = 1
                    self.successView!.isHidden = false
                })
            }
        }
    }
    
    @objc func hideInforPopup() {
        if successView != nil {
            self.grayScreen.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.successView!.layer.opacity = 0
                self.successView!.isHidden = true
            }) { (_) in
                if self.successView != nil {
                    self.successView!.removeFromSuperview()
                    self.successView = nil
                }
            }
        }
    }
    
    func getIconSetup(_ id: String) -> String {
        let listIcon = LayoutBuilder.shared.getlistIconBenefit()
        for icon in listIcon {
            if let listBenefit = icon.listBenefit {
                for iconBenefit in listBenefit {
                    if id == iconBenefit.benefitID {
                        return API.STATIC_RESOURCE + (icon.icon ?? "")
                    }
                }
            }
        }
        
        return ""
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension ContractDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + sideItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContractDetailTableViewCell.cellId, for: indexPath) as? ContractDetailTableViewCell else { return UITableViewCell() }
        if indexPath.row < items.count{
            cell.item = items[indexPath.row]
            
            if let url = URL(string: getIconSetup(items[indexPath.row].mainBenefitId ?? "")) {
                CacheManager.shared.imageFor(url: url) { image, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            return
                        }
                        cell.iconImageView.image = image
                    }
                }
            }
        }
        else {
            cell.sideItem = sideItems[indexPath.row - items.count]
            if let url = URL(string: getIconSetup(sideItems[indexPath.row - items.count].sideBenefitId ?? "")) {
                CacheManager.shared.imageFor(url: url) { image, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            return
                        }
                        cell.iconImageView.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = model else { return }
        guard let contractObject = model.listContractObject.first(where: {$0.contractObjectID == self.contractObjectId}) else {return}
        Logger.Logs(message: model.listContractObject)
        var benefitString: String = ""
        let vc = ContractBenefitViewController()
        if indexPath.row < items.count {
            vc.benefitId =  getIconSetup(items[indexPath.row].mainBenefitId ?? "")
            vc.maximumAmount = contractObject.listProductMainBenefit[indexPath.row].listMaximumAmountMainBenefit[0].maximumAmount
            vc.benefitName = contractObject.listProductMainBenefit[indexPath.row].name
            if contractObject.listProductMainBenefit[indexPath.row].content != nil {
                benefitString = contractObject.listProductMainBenefit[indexPath.row].content ?? ""
            }
            else {
                let arr: [String] = (contractObject.listProductMainBenefit[indexPath.row].listProductSubMainBenefit ?? []).map({ ($0.name) + "\n" + ($0.content ?? "") })
                benefitString = arr.joined(separator: "")
            }
        }
        else {
            vc.benefitId =  getIconSetup(sideItems[indexPath.row - items.count].sideBenefitId ?? "")
            vc.maximumAmount = contractObject.listProductSideBenefit?[indexPath.row - items.count].listFeeAndMaximumAmountSideBenefit?[0].maximumAmount ?? 0
            vc.benefitName = contractObject.listProductSideBenefit?[indexPath.row - items.count].name ?? ""
            
            if contractObject.listProductSideBenefit?[indexPath.row - items.count].content != nil {
                benefitString = contractObject.listProductSideBenefit?[indexPath.row - items.count].content ?? ""
            }
            else {
                let arr: [String] = (contractObject.listProductSideBenefit?[indexPath.row - items.count].listProductSubSideBenefit ?? []).map({ ($0.name) + "\n" + ($0.content ?? "") })
                benefitString = arr.joined(separator: "")
            }
        }
        let terms = [
            [
                ContractTermModel(title:
                                    benefitString // indexPath.row >= model.listContractObject[0].listProductMainBenefit.count ? "" : (model.listContractObject[0].listProductMainBenefit[indexPath.row].content ?? "")
                                  , desc: "", subDescs: [])
            ],
//                     [ContractTermModel(title: model.listContractObject[0].termsApplicableObject ?? "", desc: "", subDescs: [])],
//                     [ContractTermModel(title: model.listContractObject[0].termsFeePaymentMethod ?? "", desc: "", subDescs: [])],
//                     model.listContractObject[0].listExclusionTerms?.map({ ContractTermModel(title: $0.name, desc: $0.content ?? "", subDescs: []) }) ?? [],
//                     model.listContractObject[0].listParticipationTerms?.map({ ContractTermModel(title: $0.name, desc: $0.content ?? "", subDescs: []) }) ?? []
        ]
        vc.terms = terms
        vc.contractId = contractObject.contractObjectIdProvider ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension ContractDetailViewController: ContractDetailViewDelegate {
    func updateTerms(terms: InsuranceTermsModel) {
        let popup = ExtraInfoView()
        popup.setTerms(terms: terms)
        bottomSheet.setContentForBottomSheet(popup)
        setNewBottomSheetHeight(670)
        showBottomSheet()
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateUI(contractDetail: ContractDetailModel) {
        model = contractDetail
        
        
        if  customerType == 3 {
                contractObject = contractDetail.listContractObject.first(where: {$0.contractObjectID == contractObjectId})
        }else {
            contractObject = contractDetail.listContractObject[0]
        }
        
        if customerType == 3{
            self.viewDownloadButton.isHidden = true
        }else if contractObject?.document == nil || contractObject!.document!.isEmpty{
            self.viewTermsButton.isHidden = true
        }
        
        guard let contractObject = contractObject else {return}
        items = contractObject.listProductMainBenefit
        sideItems = contractObject.listProductSideBenefit ?? []
        ownerLabel.text = contractObject.peopleName
        expiredDateLabel.text = "\((contractDetail.contractEndDate)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
        numberLabel.text = contractObject.contractObjectIdProvider
        
//        insuranceMoneyLabel.text = "\((contractObject.maximumAmount ?? 0).addComma()) vnd"
//        accountLabel.text = "0 vnd" // "\(contractDetail.listContractObject[0].maximumAmount.addComma()) vnd"
        
        stateButton.setTitle(contractDetail.contractStatus == ContractStatus.active.rawValue ? "VALID".localize() : "Chưa thanh toán", for: .normal)
    }
    
    func showAlert() {
        
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
