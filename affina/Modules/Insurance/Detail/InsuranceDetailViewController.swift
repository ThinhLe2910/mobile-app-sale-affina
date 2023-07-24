//
//  InsuranceDetailViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 10/08/2022.
//

import UIKit

class InsuranceDetailViewController: BaseViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var additionalLabel: BaseLabel!
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var affiliateButton: BaseButton!
    
    @IBOutlet weak var termsButton: BaseButton!
    @IBOutlet weak var buyNowButton: BaseButton!
    
    @IBOutlet weak var benefitCollectionView: UICollectionView!
    @IBOutlet weak var benefitTableView: UITableView!
    @IBOutlet weak var additionTableView: UITableView!
    @IBOutlet weak var suggestCollectionView: UICollectionView!
    @IBOutlet weak var discountLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var feeLabel: BaseLabel!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var timeLabel: BaseLabel!
    @IBOutlet weak var timeView: BaseView!
    @IBOutlet weak var bottomView: BaseView!
    @IBOutlet weak var timeTextField: TextFieldAnimBase!
    
    @IBOutlet weak var bottomKeyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private let timePickerView: UIPickerView = UIPickerView()
    private let times: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    private var selectedTimeIndex: Int = 0
    private var presenter = InsuranceDetailViewPresenter()
    
    private var terms: InsuranceTermsModel?
    private var model: ProductDetailModel?
    var filterModel: FilterInsuranceModel?
    var product: FilterProductModel?
    var typeIndex: Int = -1
    var referralCode: String = ""
    
    private var selectedSides: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideHeaderBase()
        containerBaseView.hide()
        view.backgroundColor = .appColor(.blueUltraLighter)
        addBlurStatusBar()
        
        bottomView.backgroundColor = .clear
        addBlurEffect(bottomView)
        //        bottomView.applyGradientLayer(colors: [.init(r: 255, g: 255, b: 255, a: 0.65), .init(r: 255, g: 255, b: 255, a: 0.45)], orientation: .vertical2)
        
        setupViewPicker()
        
        // MARK: Set delegate
        presenter.setViewDelegate(delegate: self)
        
        benefitCollectionView.delegate = self
        benefitCollectionView.dataSource = self
        benefitCollectionView.register(UINib(nibName: InsuranceDetailMainTypeCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: InsuranceDetailMainTypeCollectionViewCell.cellId)
        
        benefitTableView.delegate = self
        benefitTableView.dataSource = self
        benefitTableView.register(UINib(nibName: InsuranceDetailMainProductTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InsuranceDetailMainProductTableViewCell.cellId)
        
        additionTableView.delegate = self
        additionTableView.dataSource = self
        additionTableView.register(UINib(nibName: InsuranceDetailSideProductTableViewCell.nib, bundle: nil), forCellReuseIdentifier: InsuranceDetailSideProductTableViewCell.cellId)
        
        timePickerView.delegate = self
        timeTextField.layer.opacity = 0
        timeTextField.isHidden = true
        
        // MARK: Set target
        backButton.addTarget(self, action: #selector(didClickLeftBaseButton), for: .touchUpInside)
        buyNowButton.addTarget(self, action: #selector(didTapBuyNowButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        timeView.addTapGestureRecognizer {
            self.timeTextField.becomeFirstResponder()
        }
        
        if let product = product, let filterModel = filterModel {
            presenter.getProductDetail(id: product.id, gender: filterModel.gender ?? 0, dob: Double(filterModel.dob))
            let listCoverImageProgram = LayoutBuilder.shared.getListSetupCoverImageProgram()
            for item in listCoverImageProgram {
                if item.programID == product.programId {
                    if let url = URL(string: API.STATIC_RESOURCE + (item.imageDetail ?? "")) {
                        CacheManager.shared.imageFor(url: url) { image, error in
                            if error != nil {
                                DispatchQueue.main.async {
                                    self.bgImageView.image = UIImage(named: "Card_4")
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.bgImageView.image = image
                            }
                        }
                        break
                    }
                }
            }
            let listLogo = LayoutBuilder.shared.getListSetupLogo()
            for item in listLogo {
                if item.companyID == product.companyId {
                    if let url = URL(string: API.STATIC_RESOURCE + (item.logo ?? "")) {
                        CacheManager.shared.imageFor(url: url) { image, error in
                            if error != nil {
                                DispatchQueue.main.async {
                                    self.logoImageView.image = UIImage(named: "pti_logo")
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.logoImageView.image = image
                            }
                        }
                        break
                    }
                    else {
                        DispatchQueue.main.async {
                            self.logoImageView.image = UIImage(named: "pti_logo")
                        }
                    }
                }
            }
        }
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomKeyboardConstraint.constant = keyboardSize.height
            //            scrollViewBottomConstraint.constant = keyboardSize.height
            //            let yOffset = (textField?.convert(textField?.frame.origin ?? .zero, to: contentView).y ?? 0)
            //            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + 74), animated: true)
        }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        bottomKeyboardConstraint.constant = 0
        //        scrollViewBottomConstraint.constant = 0
    }
    
    @objc private func didTapTermsButton() {
        guard let model = model else {
            return
        }
        presenter.getTerms(programId: model.programID)
    }
    
    @objc private func didTapBuyNowButton() {
        guard let model = model, let filterModel = filterModel
        else { return }
        var listSide: [String]? = []
        for i in 0..<selectedSides.count {
            listSide?.append(model.listProductSideBenefit[selectedSides[i]].id)
        }
        listSide = (listSide?.isEmpty ?? true) ? nil : listSide
        let vc = InsuranceCustomerInfoViewController()
        vc.productDetail = model
        vc.selectedSides = selectedSides
        vc.model = PaymentContractPeopleInfoRequestModel(productId: model.id,
                                                         listProductSideBenefit: listSide,
                                                         period: model.listFeeInsurance[selectedTimeIndex].periodType,
                                                         periodValue: model.listFeeInsurance[selectedTimeIndex].periodValue,
                                                         gender: filterModel.gender ?? 0,
                                                         name: nil,
                                                         dob: filterModel.dob, phone: nil, email: nil, cityCode: nil, districtsCode: nil, wardsCode: nil, address: nil, houseNumber: nil, street: nil, license: nil, licenseType: nil, licenseFront: nil, licenseBack: nil, buyHelp: nil, buyHelpRelationship: nil, buyHelpName: nil, buyHelpDob: nil, buyHelpGender: nil, buyHelpPhone: nil, buyHelpEmail: nil, buyHelpCityCode: nil, buyHelpDistrictsCode: nil, buyHelpWardsCode: nil, buyHelpStreet: nil, buyHelpHouseNumber: nil, buyHelpAddress: nil, buyHelpLicense: nil, buyHelpLicenseFront: nil, buyHelpLicenseBack: nil, buyHelpLicenseType: nil, referralCode: referralCode, pushKey: UserDefaults.standard.string(forKey: Key.pushKey.rawValue) ?? "")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func calcMaximumAmount() -> Int {
        guard let model = model else {
            return 0
        }
        var sum: Int = 0
        for i in 0..<model.listProductMainBenefit.count {
            if model.listProductMainBenefit[i].id != "-1" {
                sum += model.listProductMainBenefit[i].listMaximumAmountMainBenefit[selectedTimeIndex].maximumAmount
            }
        }
        for i in 0..<selectedSides.count {
            sum += model.listProductSideBenefit[selectedSides[i]].listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].maximumAmount
        }
        
        return sum
    }
    
    private func updateMaximumAmount() {
        priceLabel.text = "\(calcMaximumAmount().addComma()) vnd"
    }
    
    private func updateTotalFeeAmount() {
        guard let model = model else {
            discountLabel.text = "\((400000).addComma()) vnd"
            feeLabel.text = "0 vnd"
            return
        }
        
        var sum: Int = model.listFeeInsurance[selectedTimeIndex].fee
        
        for i in 0..<selectedSides.count {
            sum += model.listProductSideBenefit[selectedSides[i]].listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].fee
        }
        
        let normalText = " vnd"
        let boldText = "\(sum.addComma())"
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.append(normalString)
        
        discountLabel.text = "\((sum + 400000).addComma()) vnd"
        feeLabel.attributedText = attributedString
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

//MARK: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension InsuranceDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model?.listProductInProgram.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InsuranceDetailMainTypeCollectionViewCell.cellId, for: indexPath) as? InsuranceDetailMainTypeCollectionViewCell, let model = model else { return UICollectionViewCell() }
        cell.label.text = model.listProductInProgram[indexPath.row].packageName
        if model.listProductInProgram[indexPath.row].id == model.id && (typeIndex == -1 || typeIndex == indexPath.row) {
            typeIndex = indexPath.row
            cell.setSelectedColor()
        }
        else {
            cell.setUnSelectedColor()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (model?.listProductInProgram[indexPath.row].packageName.widthWithConstrainedHeight(height: 36, font: UIConstants.Fonts.appFont(.Bold, 14)) ?? 60) + 40, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size8 * 3 / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return UIPadding.size8 * 3 / 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let model = model, let filterModel = filterModel else { return }
        typeIndex = indexPath.row
        for i in 0..<model.listProductInProgram.count {
            (collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? InsuranceDetailMainTypeCollectionViewCell)?.setUnSelectedColor()
        }
        (collectionView.cellForItem(at: indexPath) as? InsuranceDetailMainTypeCollectionViewCell)?.setSelectedColor()
        
        selectedSides = []
        additionTableView.reloadData()
        benefitCollectionView.reloadData()
        
        updateMaximumAmount()
        presenter.getProductDetail(id: model.listProductInProgram[indexPath.row].id, gender: filterModel.gender ?? 0, dob: filterModel.dob)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension InsuranceDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else { return 0 }
        if tableView == benefitTableView {
            return model.listProductMainBenefit.count + 1
        }
        if tableView == additionTableView {
            return model.listProductSideBenefit.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == benefitTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InsuranceDetailMainProductTableViewCell.cellId, for: indexPath) as? InsuranceDetailMainProductTableViewCell, let model = model else { return UITableViewCell() }
            if indexPath.row == model.listProductMainBenefit.count + 1 - 1 {
                let item = ListProductSubBenefit(id: "-1", productMainBenefitID: "-1", subMainBenefitID: "-1", name: "MAXIMUM_AMOUNT_OF_PROTECTION".localize(), content: "", listMaximumAmountSubMainBenefit: [])
//                let item = ListProductMainBenefit(id: "-1", productID: "-1", mainBenefitID: "-1", name: "Số tiền bảo vệ tối đa", scope: -1, maximumAmount: calcMaximumAmount(), listProductSubMainBenefit: [])
                cell.nameLabel.text = item.name
                cell.priceLabel.text = "\(calcMaximumAmount().addComma()) vnd"
                cell.iconImageView.image = UIImage(named: "ic_drug_medicine")
            }
            else {
                cell.nameLabel.text = model.listProductMainBenefit[indexPath.row].name
                cell.priceLabel.text = "\(model.listProductMainBenefit[indexPath.row].listMaximumAmountMainBenefit[selectedTimeIndex].maximumAmount.addComma()) vnd"
                cell.nameLabel.sizeToFit()
                
                if let url = URL(string: getIconSetup(model.listProductMainBenefit[indexPath.row].mainBenefitID)) {
                    CacheManager.shared.imageFor(url: url) { image, error in
                        DispatchQueue.main.async {
                            if error != nil {
                                cell.iconImageView.image = UIImage(named: "ic_drug_medicine")
                                return
                            }
                            cell.iconImageView.image = image
                        }
                    }
                }
                else {
                    cell.iconImageView.image = UIImage(named: "ic_drug_medicine")
                }
            }

            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: InsuranceDetailSideProductTableViewCell.cellId, for: indexPath) as? InsuranceDetailSideProductTableViewCell else { return UITableViewCell() }
            cell.nameLabel.text = model?.listProductSideBenefit[indexPath.row].name ?? ""
                
            cell.priceLabel.text = "\(model?.listProductSideBenefit[indexPath.row].listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].maximumAmount.addComma() ?? "") vnd"
            cell.additionPriceLabel.text = "+ \(model?.listProductSideBenefit[indexPath.row].listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].fee.addComma() ?? "") vnd"
            cell.item = model?.listProductSideBenefit[indexPath.row].listProductSubSideBenefit ?? []
            cell.selectedTimeIndex = selectedTimeIndex
            cell.isAdded = !self.selectedSides.filter({ $0 == indexPath.row }).isEmpty
            
            if let url = URL(string: getIconSetup(model?.listProductSideBenefit[indexPath.row].sideBenefitID ?? "")) {
                CacheManager.shared.imageFor(url: url) { image, error in
                    DispatchQueue.main.async {
                        if error != nil {
                            cell.iconImageView.image = UIImage(named: "ic_drug_medicine")
                            return
                        }
                        cell.iconImageView.image = image
                    }
                }
            }
            else {
                cell.iconImageView.image = UIImage(named: "ic_drug_medicine")
            }
            cell.addCallBack = {
                self.selectedSides.append(indexPath.row)
                self.updateMaximumAmount()
                self.updateTotalFeeAmount()
                self.additionTableView.beginUpdates()
                self.additionTableView.endUpdates()
            }
            cell.removeCallBack = {
                self.selectedSides = self.selectedSides.filter({ $0 != indexPath.row })
                self.updateMaximumAmount()
                self.updateTotalFeeAmount()
                self.additionTableView.beginUpdates()
                self.additionTableView.endUpdates()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let model = model else {
//            return
//        }
//        if tableView == benefitTableView {
//            presenter.getTerms(programId: model.listProductMainBenefit[indexPath.row].id)
//        }
//        else if tableView == additionTableView {
//            presenter.getTerms(programId: model.listProductSideBenefit[indexPath.row].id)
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == benefitTableView {
            return UITableView.automaticDimension
        }
        else {
//            if (tableView.cellForRow(at: indexPath) as? InsuranceDetailSideProductTableViewCell)?.isAdded ?? false {
//                return 156
//            }
            return UITableView.automaticDimension
        }
    }
}

// MARK: InsuranceDetailViewDelegate
extension InsuranceDetailViewController: InsuranceDetailViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func showError() {
//        queueBasePopup(icon: <#T##UIImage?#>, title: <#T##String#>, desc: <#T##String#>, okTitle: <#T##String#>, cancelTitle: <#T##String#>, okHandler: <#T##() -> Void#>, handler: <#T##() -> Void#>)
    }
    
    func updateUI(model: ProductDetailModel) {
        self.model = model
        if model.listProductSideBenefit.count == 0 {
            self.additionalLabel.isHidden = true
        }
//        self.model?.listProductMainBenefit.append(ListProductMainBenefit(id: "-1", productID: "-1", mainBenefitID: "-1", name: "Số tiền bảo vệ tối đa", scope: -1, maximumAmount: calcMaximumAmount(), listProductSubMainBenefit: []))
        
        benefitCollectionView.reloadData()
        benefitTableView.reloadData()
        additionTableView.reloadData()
        for i in 0..<model.listProductInProgram.count {
            if let product = product, product.id == model.listProductInProgram[i].id {
                benefitCollectionView.scrollToItem(at: IndexPath(item: i, section: 0), at: .right, animated: true)
            }
        }
        
        nameLabel.text = "\(model.programName) - \(model.packageName)"
        
        let normalText = " vnd"
        let boldText = "\(model.listFeeInsurance[selectedTimeIndex].fee.addComma())"
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.append(normalString)
        feeLabel.attributedText = attributedString
        
        discountLabel.text = "\((model.listFeeInsurance[selectedTimeIndex].fee + 400000).addComma()) vnd"
        
        updateMaximumAmount()
        updateTotalFeeAmount()
        
        timePickerView.reloadInputViews()
        timeTextField.text = "\(model.listFeeInsurance[selectedTimeIndex].periodValue) \(ContractPeriod(rawValue: model.listFeeInsurance[selectedTimeIndex].periodType)?.toString() ?? "YEAR".localize())"
        timeLabel.text = "\(model.listFeeInsurance[selectedTimeIndex].periodValue) \(ContractPeriod(rawValue: model.listFeeInsurance[selectedTimeIndex].periodType)?.toString() ?? "YEAR".localize())"
    }
    
    func updateTerms(terms: InsuranceTermsModel) {
        self.terms = terms
        
        let popup = ExtraInfoView()
        popup.setTerms(terms: terms)
        bottomSheet.setContentForBottomSheet(popup)
        setNewBottomSheetHeight(550)
        showBottomSheet()
    }
    
}

// MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension InsuranceDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return model?.listFeeInsurance.count ?? 0   // times.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let model = model else { return }
        let str = "\(model.listFeeInsurance[row].periodValue) \(ContractPeriod(rawValue: model.listFeeInsurance[row].periodType)?.toString() ?? "YEAR".localize())"
        timeTextField.text = str
        timeLabel.text = str
        selectedTimeIndex = row
        
        self.updateMaximumAmount()
        self.updateTotalFeeAmount()
        benefitTableView.reloadData()
        additionTableView.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let model = model, !model.listFeeInsurance.isEmpty else { return "" }
        return "\(model.listFeeInsurance[row].periodValue) \(ContractPeriod(rawValue: model.listFeeInsurance[row].periodType)?.toString() ?? "YEAR".localize())"
    }
    
    private func setupViewPicker() {
        //        timePickerView.backgroundColor = UIColor.appColor(.whiteMain)
        
        timeTextField.inputView = timePickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(pickerViewValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        timeTextField.inputAccessoryView = doneToolbar
    }
    @objc private func pickerViewValueDone() {
        guard let model = model, !model.listFeeInsurance.isEmpty else { return }
        let str = "\(model.listFeeInsurance[selectedTimeIndex].periodValue) \(ContractPeriod(rawValue: model.listFeeInsurance[selectedTimeIndex].periodType)?.toString() ?? "YEAR".localize())"
        timeTextField.text = str
        timeLabel.text = str
        
        timeTextField.resignFirstResponder()
        self.updateMaximumAmount()
        self.updateTotalFeeAmount()
        benefitTableView.reloadData()
        additionTableView.reloadData()
    }
}
