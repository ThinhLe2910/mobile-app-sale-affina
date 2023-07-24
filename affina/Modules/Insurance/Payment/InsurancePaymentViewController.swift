//
//  InsurancePaymentViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/08/2022.
//

import UIKit
import PayooPayment
import PayooCore

class InsurancePaymentViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var backButton: BaseButton!
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var customerNameLabel: BaseLabel!
    @IBOutlet weak var dobLabel: BaseLabel!
    @IBOutlet weak var periodLabel: BaseLabel!
    @IBOutlet weak var originFeeView: BaseView!
    @IBOutlet weak var originFeeLabel: BaseLabel!
    @IBOutlet weak var contractVoucherView: BaseView!
    @IBOutlet weak var contractVoucherLabel: BaseLabel!
    @IBOutlet weak var feeLabel: BaseLabel!
    @IBOutlet weak var insuranceNameLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    
    @IBOutlet weak var benefitTableView: ContentSizedTableView!
    @IBOutlet weak var benefitTableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var payLabel: BaseLabel!
    
    @IBOutlet weak var redBillSwitch: UISwitch!
    
    @IBOutlet weak var dateTextField: TitleTextFieldBase!
    @IBOutlet weak var voucherView: BaseView!
    @IBOutlet weak var voucherLabel: BaseLabel!
    @IBOutlet weak var voucherIcon: UIImageView!
    
    @IBOutlet weak var redBillView: BaseView!
    @IBOutlet weak var companyNameTextField: TitleTextFieldBase!
    @IBOutlet weak var companyAddressTextField: TitleTextFieldBase!
    @IBOutlet weak var mstTextField: TitleTextFieldBase! // Ma so thue
    
    @IBOutlet weak var redBillBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var agreeButton: BaseButton!
    @IBOutlet weak var termPrivacyLabel: BaseLabel!
    
    @IBOutlet weak var paymentView: BaseView!
    @IBOutlet weak var paymentMethodTableView: ContentSizedTableView!
    
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private let paymentMethods: [String] = ["ATM_CARD".localize(), "CREDIT_CARD".localize(), "INSTALLMENT_VIA_CREDIT_CARD".localize()]//, "BUY_NOW_PAY_LATER".localize()]
    private let paymentTypes: [PayooMethod] = [.domesticCard, .internationCard, .installment]//, .payAtStore]
    private let paymentMethodValues: [PaymentMethod] = [.domesticCard, .internationalCard, .installment]//, .payAtStore]
    private let paymentMethodIcons: [String] = ["ic_atm", "ic_credit_card", "ic_installment"]//, "ic_cash"]
    private let datePickerView: UIDatePicker = UIDatePicker()
    
    private var isUploadingFrontImage = false
    private var isUploadingBackImage = false
    private var isUploadingBuyHelpFrontImage = false
    private var isUploadingBuyHelpBackImage = false
    
    private var textField: TextFieldAnimBase?
    private var textFieldIndex: CGFloat = 0
    
    var productDetail: ProductDetailModel?
    var selectedSides: [Int] = []
    var paymentInfoModel: PaymentContractPeopleInfoRequestModel?
    var paymentModel: PaymentContractRequestModel?
    var contractModel: InsuranceContractModel?
    var selectedTimeIndex: Int = 0
    private var voucher: MyVoucherModel?
    private var contractVoucher: ContractVoucherModel?
    private var vouchers: [String: MyVoucherModel] = [:]
    
    private let presenter: InsurancePaymentViewPresenter = InsurancePaymentViewPresenter()
    
    private var isRedBill: Bool = false
    private var paymentType: PayooMethod = .domesticCard
    private var isBNPL: Bool = false // Buy now pay later
    private var isAgree: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        voucherView.addTapGestureRecognizer {
            let vc = SelectVoucherViewController()
            vc.contractId = self.contractModel?.contractID ?? ""
            vc.selectedVouchers = self.vouchers
            vc.applyCallback = { [weak self] voucher, vouchers in
                if voucher == nil || vouchers.isEmpty {
                    self?.vouchers = [:]
                    self?.contractVoucher = nil
                    self?.voucher = nil
                    self?.voucherLabel.text = "COUPON_CODE".localize().capitalized
                    self?.updatePriceAndPaymentView()
                    return
                }
                self?.vouchers = vouchers
                self?.contractVoucher = voucher
                self?.voucher = vouchers.first?.value
                if self?.voucher == nil {
                    self?.voucher = MyVoucherModel(voucherID: nil, campaignID: nil, userID: nil,
                                                   code: vouchers.first?.key, serial: nil,
                                                   imageCode: nil, isUse: nil, expiredAt: nil, providerID: nil, voucherName: nil, voucherImage: nil, summary: nil, content: nil, totalRating: nil, totalRatingPoint: nil, ratingList: nil)
                }
                self?.updatePriceAndPaymentView()
                self?.voucherLabel.text = "Đã áp dụng \(vouchers.count) mã ưu đãi".localize().capitalized
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        voucherIcon.changeToColor(.appColor(.blackMain) ?? .black)
        
        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        addBlurStatusBar()
        
        setupDatePicker(datePickerView: datePickerView, textField: dateTextField)
        
        setupTextFields()
        
        redBillSwitch.onTintColor = .appColor(.blueMain)
        redBillSwitch.addTarget(self, action: #selector(valueSwitchChanged), for: .valueChanged)
        
        termPrivacyLabel.attributedText = getAttributedString(
            arrayTexts: ["I_AGREE".localize(), "TERMS".localize(), "AND".localize(), "PRIVACY".localize(), "OUR".localize()],
            arrayColors: [UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!],
            arrayFonts: [termPrivacyLabel.font, UIConstants.Fonts.appFont(.Bold, 14), termPrivacyLabel.font, UIConstants.Fonts.appFont(.Bold, 14), termPrivacyLabel.font],
            arrayUnderlines: [false, true, false, true, false]
        )
        termPrivacyLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNoteLabel))
        termPrivacyLabel.addGestureRecognizer(tap)
        
        agreeButton.addTarget(self, action: #selector(didTapAgreeButton(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didClickLeftBaseButton), for: .touchUpInside)
        
        presenter.setViewDelegate(delegate: self)
        
        redBillView.isHidden = !isRedBill
        redBillBottomConstraint.constant = isRedBill ? 335 : 20
        
        benefitTableView.dataSource = self
        benefitTableView.register(UINib(nibName: SideProductItemTableViewCell.nib, bundle: nil), forCellReuseIdentifier: SideProductItemTableViewCell.cellId)
        
        addBlurEffect(paymentView)
        paymentMethodTableView.delegate = self
        paymentMethodTableView.dataSource = self
        paymentMethodTableView.register(UINib(nibName: PaymentMethodTableViewCell.nib, bundle: nil), forCellReuseIdentifier: PaymentMethodTableViewCell.cellId)
        
        disablePaymentButtons()
        setupTextFields()
        
        if let contractModel = contractModel, let productDetail = productDetail {
            customerNameLabel.text = contractModel.name
            dobLabel.text = "\(contractModel.dob/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            periodLabel.text = "\(contractModel.periodValue) " + "\(ContractPeriod(rawValue: contractModel.period)?.toString() ?? "YEAR".localize())"
            
            
            insuranceNameLabel.text = "\(productDetail.packageName) - \(productDetail.programName)"
            payLabel.text = "\(contractModel.amountPay.addComma()) vnd"
            updateMaximumAmount()
            updateTotalFeeAmount()
            
            for i in 0..<productDetail.listFeeInsurance.count {
                let item = productDetail.listFeeInsurance[i]
                if item.periodValue == contractModel.periodValue && item.periodType == contractModel.period {
                    selectedTimeIndex = i
                    break
                }
            }
            
            benefitTableView.reloadData()
            
        }
        
        if let productDetail = productDetail {
            let listCoverImageProgram = LayoutBuilder.shared.getListSetupCoverImageProgram()
            for item in listCoverImageProgram {
                if item.programID == productDetail.programID {
                    if let url = URL(string: API.STATIC_RESOURCE + (item.imageFilter ?? "")) {
                        CacheManager.shared.imageFor(url: url) { image, error in
                            if error != nil {
                                DispatchQueue.main.async {
                                    self.bannerImageView.image = UIImage(named: "Card_4")
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                self.bannerImageView.image = image
                            }
                        }
                        break
                    }
                    else {
                        bannerImageView.image = UIImage(named: "Card_4")
                    }
                }
            }
            
            let listLogo = LayoutBuilder.shared.getListSetupLogo()
            for item in listLogo {
                if item.companyID == productDetail.companyID {
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
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.benefitTableViewBottomConstraint?.constant = self.benefitTableView.contentSize.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        //        buttonBottomKeyboardConstraint.constant = 24
        scrollViewBottomConstraint.constant = 0
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //            buttonBottomKeyboardConstraint.constant = keyboardSize.height
            scrollViewBottomConstraint.constant = keyboardSize.height
            let yOffset = (textField?.convert(textField?.frame.origin ?? .zero, to: contentView).y ?? 0)
            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + 74), animated: true)
        }
    }
    
    override func didClickLeftBaseButton() {
        if UIConstants.isLoggedIn {
            popViewController()
        }
        else {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            if paymentInfoModel?.buyHelp == 1 {
                for aViewController in viewControllers {
                    if aViewController is InsuranceRequestorInfoViewController {
                        self.navigationController!.popToViewController(aViewController, animated: true)
                    }
                }
            }
            else {
                for aViewController in viewControllers {
                    if aViewController is InsuranceCustomerInfoViewController {
                        self.navigationController!.popToViewController(aViewController, animated: true)
                    }
                }
            }
        }
    }
    
    private func calcMaximumAmount() -> Int {
        guard let model = productDetail else {
            return 0
        }
        var sum: Int = 0
        for i in 0..<model.listProductMainBenefit.count {
            sum += model.listProductMainBenefit[i].listMaximumAmountMainBenefit[selectedTimeIndex].maximumAmount
        }
        for i in 0..<selectedSides.count {
            sum += model.listProductSideBenefit[selectedSides[i]].listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].maximumAmount
        }
        return sum
    }
    private func calcTotalFee() -> Int {
        guard let model = productDetail else {
            return 0
        }
        
        var sum: Int = model.listFeeInsurance[selectedTimeIndex].fee
        
        for i in 0..<selectedSides.count {
            sum += model.listProductSideBenefit[selectedSides[i]].listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].fee
        }
        return sum
    }
    
    private func updateMaximumAmount() {
        priceLabel.text = "\(calcMaximumAmount().addComma()) vnd"
    }
    
    private func updateTotalFeeAmount() {
        let normalText = " vnd"
        let boldText = "\((contractModel?.feeInsurance ?? 0).addComma())" // "\(calcTotalFee().addComma())"
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.append(normalString)
        
        feeLabel.attributedText = attributedString
    }
    
    private func setupDatePicker(datePickerView: UIDatePicker, textField: TitleTextFieldBase) {
        //        datePickerView = UIDatePicker()
        datePickerView.locale = NSLocale(localeIdentifier: "vi_VN") as Locale
        datePickerView.backgroundColor = UIColor.appColor(.whiteMain)
        datePickerView.minimumDate = Date().addingTimeInterval(86400)
        datePickerView.maximumDate = Date().addingTimeInterval(86400000 * 3650)
        datePickerView.date = Date()
        datePickerView.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        textField.rightView.addTapGestureRecognizer {
            textField.textField.becomeFirstResponder()
        }
        textField.rightIconView.tintColor = .appColor(.whiteMain)
        
        textField.textField.inputView = datePickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(datePickerValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textField.textField.inputAccessoryView = doneToolbar
    }
    
    private func setDobValue() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateTextField.textField.text = dateFormatter.string(from: datePickerView.date)
    }
    
    @objc private func datePickerValueChanged() {
        setDobValue()
        dateTextField.hideError()
        
        if checkInfoIsFilled() {
            enablePaymentButtons()
        }
        else {
            disablePaymentButtons()
        }
        updatePriceAndPaymentView()
    }
    
    @objc private func datePickerValueDone() {
        setDobValue()
        dateTextField.hideError()
        dateTextField.textField.resignFirstResponder()
        
        if checkInfoIsFilled() {
            enablePaymentButtons()
        }
        else {
            disablePaymentButtons()
        }
        updatePriceAndPaymentView()
    }
    
    @objc private func valueSwitchChanged() {
        isRedBill = redBillSwitch.isOn
        
        redBillView.isHidden = !isRedBill
        
        redBillBottomConstraint.constant = !isRedBill ? 20 : (335 + 20 * ((companyNameTextField.isError ? 1 : 0) + (companyAddressTextField.isError ? 1 : 0) + (mstTextField.isError ? 1 : 0)))
        
        if checkInfoIsFilled() {
            enablePaymentButtons()
        }
        else {
            disablePaymentButtons()
        }
        updatePriceAndPaymentView()
    }
    
    @objc private func didTapAgreeButton(_ sender: BaseButton) {
        switch sender {
        case agreeButton :
            isAgree.toggle()
            agreeButton.setImage(isAgree ? UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate) : nil, for: .normal)
            agreeButton.backgroundColor = .appColor(isAgree ? .blueMain : .whiteMain)
            if checkInfoIsFilled() {
                enablePaymentButtons()
            }
            else {
                disablePaymentButtons()
            }
            updatePriceAndPaymentView()
            break;
        default:
            break;
        }
    }
    
    private func updatePriceAndPaymentView() {
        paymentMethodTableView.reloadData()
        
        originFeeView.isHidden = contractVoucher == nil
        contractVoucherView.isHidden = contractVoucher == nil
        
        guard let contractVoucher = contractVoucher else {
            payLabel.text = "\((contractModel?.amountPay ?? 0).addComma()) vnd"
            updateMaximumAmount()
            updateTotalFeeAmount()
            return
        }
        originFeeLabel.attributedText = getAttributedString(arrayTexts: [
            "\(Int((contractVoucher.amountPay ?? 0) + (contractVoucher.amountDiscount ?? 0)).addComma())",
            "vnd"
        ], arrayColors: [
            .appColor(.blueMain) ?? .black,
            .appColor(.blueMain) ?? .black
        ], arrayFonts: [
            UIConstants.Fonts.appFont(.ExtraBold, 16),
            UIConstants.Fonts.appFont(.Medium, 14),
        ])
        contractVoucherLabel.attributedText = getAttributedString(arrayTexts: [
            "\(Int(contractVoucher.amountDiscount ?? 0).addComma())",
            "vnd"
        ], arrayColors: [
            .appColor(.blueMain) ?? .black,
            .appColor(.blueMain) ?? .black
        ], arrayFonts: [
            UIConstants.Fonts.appFont(.ExtraBold, 16),
            UIConstants.Fonts.appFont(.Medium, 14),
        ])
        
        feeLabel.attributedText = getAttributedString(arrayTexts: [
            "\(Int((contractVoucher.amountPay ?? 0)).addComma())",
            "vnd"
        ], arrayColors: [
            .black,
            .black
        ], arrayFonts: [
            UIConstants.Fonts.appFont(.ExtraBold, 16),
            UIConstants.Fonts.appFont(.Medium, 14),
        ])
        
        payLabel.text = "\(Int(contractVoucher.amountPay ?? 0).addComma()) vnd"
    }
    
    @objc private func didTapNoteLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = termPrivacyLabel.text else { return }
        let termsRange = (text as NSString).range(of: "TERMS".localize())
        let privacyRange = (text as NSString).range(of: "PRIVACY".localize())
        
        if gesture.didTapAttributedTextInLabel(label: termPrivacyLabel, targetRange: termsRange) {
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/dieu-khoan-kieu-kien")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gesture.didTapAttributedTextInLabel(label: termPrivacyLabel, targetRange: privacyRange) {
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/chinh-sach-bao-mat")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case dateTextField.textField:
                textFieldIndex = 0
                self.textField = dateTextField.textField
                break
            case companyNameTextField.textField:
                textFieldIndex = 2
                self.textField = companyNameTextField.textField
                break
            case companyAddressTextField.textField:
                textFieldIndex = 3
                self.textField = companyAddressTextField.textField
                break
            case mstTextField.textField:
                textFieldIndex = 4
                self.textField = mstTextField.textField
                break
            default:
                break
        }
        
        return true
    }
    
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension InsurancePaymentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == benefitTableView {
            if let productDetail = productDetail {
                return productDetail.listProductMainBenefit.count + selectedSides.count //productDetail.listProductSideBenefit
            }
            return 0
        }
        return paymentMethods.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
    private func setAttributeText(label: BaseLabel, normalText: String, boldText: String) {
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 12)] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.append(normalString)
        label.attributedText = attributedString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == benefitTableView {
            guard let productDetail = productDetail, let cell = tableView.dequeueReusableCell(withIdentifier: SideProductItemTableViewCell.cellId, for: indexPath) as? SideProductItemTableViewCell else {
                return UITableViewCell()
            }
            if indexPath.row >= productDetail.listProductMainBenefit.count {
                let model = productDetail.listProductSideBenefit[selectedSides[indexPath.row - productDetail.listProductMainBenefit.count]]
                cell.nameLabel.text = model.name
                
                setAttributeText(label: cell.priceLabel, normalText: " vnd", boldText: "\(model.listFeeAndMaximumAmountSideBenefit[selectedTimeIndex].maximumAmount.addComma())")
            }
            else {
                cell.nameLabel.text = productDetail.listProductMainBenefit[indexPath.row].name
                
                setAttributeText(label: cell.priceLabel, normalText: " vnd", boldText: "\(productDetail.listProductMainBenefit[indexPath.row].listMaximumAmountMainBenefit[selectedTimeIndex].maximumAmount.addComma())")
            }
            
            cell.separator.isHidden = indexPath.row == (productDetail.listProductMainBenefit.count + selectedSides.count) - 1
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodTableViewCell.cellId, for: indexPath) as? PaymentMethodTableViewCell else { return UITableViewCell() }
            cell.nameLabel.text = paymentMethods[indexPath.row]
            cell.iconImageView.image = UIImage(named: paymentMethodIcons[indexPath.row])
            cell.enableView()
            if contractVoucher != nil {
                if contractVoucher?.paymentMethodVoucher == paymentMethodValues[indexPath.row].rawValue {
                    cell.enableView()
                }
                else {
                    cell.disableView()
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == paymentMethodTableView {
            if !checkInfoIsFilled() {
                if isRedBill {
                    textFieldDidChange(companyNameTextField.textField)
                    textFieldDidChange(companyAddressTextField.textField)
                    textFieldDidChange(mstTextField.textField)
                }
                textFieldDidChange(dateTextField.textField)
                
                redBillBottomConstraint.constant = !isRedBill ? 20 : (335 + 20 * ((companyNameTextField.isError ? 1 : 0) + (companyAddressTextField.isError ? 1 : 0) + (mstTextField.isError ? 1 : 0)))
                
                return
            }
            
            if let contractVoucher = contractVoucher {
                if contractVoucher.paymentMethodVoucher != paymentMethodValues[indexPath.row].rawValue { return }
            }
            
            guard  let contractModel = contractModel else {
                return
            }
            
            paymentType = paymentTypes[indexPath.row]
            isBNPL = paymentTypes[indexPath.row] == .payAtStore
            paymentModel = PaymentContractRequestModel(contractId: contractModel.contractID, startDate: datePickerView.date.timeIntervalSince1970 * 1000, voucherCode: voucher?.code, redBill: 0, redBillCompanyName: nil, redBillCompanyAddress: nil, redBillCompanyTaxNumber: nil, paymentMethod: PaymentMethod.getPaymentMethod(by: paymentType).rawValue)// paymentType == .internationCard ? 3 : (isBNPL ? 0 : 1))
            if isRedBill {
                if let nameText = companyNameTextField.textField.text, !nameText.isEmpty,
                   let addressText = companyAddressTextField.textField.text, !addressText.isEmpty,
                   let taxText = mstTextField.textField.text, !taxText.isEmpty {
                    paymentModel?.redBill = 1
                    paymentModel?.redBillCompanyName = companyNameTextField.textField.text
                    paymentModel?.redBillCompanyAddress = companyAddressTextField.textField.text
                    paymentModel?.redBillCompanyTaxNumber = mstTextField.textField.text
                }
                else {
                    queueBasePopup(icon: UIImage(named: "ic_warning"), title: "Vui lòng điền đủ thông tin", desc: "", okTitle: "GOT_IT".localize(), cancelTitle: "") {
                        self.hideBasePopup()
                    } handler: {
                        
                    }
                    return
                }
            }
            
            view.endEditing(true)
            
            Logger.Logs(message: paymentModel)
            
            if let model = paymentModel {
                if UIConstants.isLoggedIn {
                    presenter.updateContractWithToken(model: model)
                }
                else {
                    presenter.updateContract(model: model)
                }
            }
            return
        }
    }
}

// MARK: InsurancePaymentViewDelegate
extension InsurancePaymentViewController: InsurancePaymentViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unLockUI() {
        unlockScreen()
    }
    
    func handleCheckVoucherError(code: String, message: String) {
        
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: message.isEmpty ? "Error" : message, okTitle: "GOT_IT".localize(), cancelTitle: "") {
            self.hideBasePopup()
            
        } handler: {
            
        }

    }
    
    func updateSuccessful(contract: InsuranceContractModel) {
        contractModel = contract
        if isBNPL {
            guard contract.baoKimPaymentURL != nil else {
                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                                    desc: "Đã có lỗi xảy ra, vui lòng thử lại",
                                    okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                } handler: {
                }
                return
            }
            let vc = WebViewController()
            vc.setUrl(url: contract.baoKimPaymentURL!)
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        if paymentType == .internationCard {
            let webView = WebViewController()
            webView.setUrl(url: contract.smartPayUrl ?? "", canDownload: false)
            webView.setRedirectUrl(url: contract.redirectUrl ?? "", isRedirectedToApp: true)
            webView.redirectCallback = { [weak self] in
                self?.presenter.getSmartpayStatusOrder(transactionId: contract.transactionId ?? "")
            }
            navigationController?.pushViewController(webView , animated: true)
        }
        else {
            guard contract.payooOrder != nil, contract.payooChecksum != nil else {
                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                                    desc: "Đã có lỗi xảy ra, vui lòng thử lại",
                                    okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                } handler: {
                }
                return
            }
            
            presenter.payWithPayoo(contract: contract, paymentType: paymentType, viewController: self)
        }
    }
    
    func showAlert(message: String) {
        
    }
    
    func showError(error: ApiError) {
        var message = "Bad request, validation error" // "ERROR_CREATE_CONTRACT".localize()
        switch error {
            case .forbidden:
                message = ""
            case .notFound:
                message = ""
            case .conflict:
                message = ""
            case .internalServerError:
                message = ""
            case .invalidUrl:
                message = ""
            case .invalidData(_, _):
                message = ""
            case .noInternetConnection:
                message = "Lỗi Network Connection, vui lòng thử lại"
            case .notResponse:
                message = ""
            case .requestTimeout(_):
                message = "Timeout"
            case .otherError:
                message = "Lỗi {Error 10x29183}, vui lòng thử lại"
            case .expired:
                logOut()
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    self.navigationController?.popToRootViewController(animated: true)
                } handler: {
                    
                }
                return
            case .refresh:
                message = ""
        default: break
        }
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                       desc: message,
                       okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
            self.hideBasePopup()
        } handler: {
            
        }
    }
    
    func handlePayooStatus(status: GroupType, data: PaymentResponseObject) {
        switch status {
            case .success:
                Logger.Logs(message: "Success \(String(describing: data.message)) (\(data.code))")
                self.queueBasePopup(icon: UIImage(named: "ic_check_circle"), title: "SUBMIT_REQUEST_SUCCESSFULLY".localize(), desc: UIConstants.isLoggedIn ? "YOUR_REQUEST_HAS_BEEN_LOGGED".localize() : "YOUR_REQUEST_HAS_BEEN".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                    if let tokenRegister = self.contractModel?.tokenRegister {
                        let vc = SetUpPasswordViewController()
                        vc.tokenRegister = tokenRegister
                        UserDefaults.standard.set(self.contractModel?.buyPhone, forKey: Key.phoneNumber.rawValue)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        self.dismiss(animated: true, completion: {
                        })
                    }
                } handler: {
                }
            case .failure:
                Logger.Logs(message: "Failure \(String(describing: data.message)) (\(data.code))")
                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                                     desc: "Lỗi {\(String(describing: data.message ?? "Không thể xác định"))}, vui lòng thử lại",
                                     okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                } handler: {
                }
            case .unknown:
                Logger.Logs(message: "Unknown \(String(describing: data.message)) (\(data.code))")
                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                                     desc: "Lỗi {\(String(describing: data.message ?? "Không thể xác định"))}, vui lòng thử lại",
                                     okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                } handler: {
                }
            case .cancel:
                Logger.Logs(message: "Cancel! Cancelled by user.")
                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                                     desc: "Lỗi {\(String(describing: data.message ?? "Không thể xác định"))}, vui lòng thử lại",
                                     okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                } handler: {
                }
            @unknown default:
                Logger.Logs(message: "Unknown Default")
        }
    }
    
    func handleSmartpayOrder(order: SmartpayOrderModel) {
        switch order.status {
            case SmartpayOrderEnum.OPEN.rawValue:
                return
            case SmartpayOrderEnum.PAYED.rawValue:
                self.queueBasePopup(icon: UIImage(named: "ic_check_circle"), title: "SUBMIT_REQUEST_SUCCESSFULLY".localize(), desc: UIConstants.isLoggedIn ? "YOUR_REQUEST_HAS_BEEN_LOGGED".localize() : "YOUR_REQUEST_HAS_BEEN".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                    if let tokenRegister = self.contractModel?.tokenRegister {
                        let vc = SetUpPasswordViewController()
                        vc.tokenRegister = tokenRegister
                        UserDefaults.standard.set(self.contractModel?.buyPhone, forKey: Key.phoneNumber.rawValue)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    else {
                        self.dismiss(animated: true, completion: {
                        })
                    }
                } handler: {
                }
            case SmartpayOrderEnum.PAY_ERROR.rawValue:
                Logger.Logs(message: "Failure")
                self.queueBasePopup(icon: UIImage(named: "ic_warning"), title: "PAYMENT_FAILED".localize(),
                                    desc: "Lỗi {\("Không thể xác định")}, vui lòng thử lại",
                                    okTitle: "TRY_AGAIN".localize(), cancelTitle: "") {
                    self.hideBasePopup()
                } handler: {
                }
            default:
                return
        }
    }
}

// MARK: URLSessionDelegate
extension InsurancePaymentViewController: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

// MARK: EXT InsurancePaymentViewController
extension InsurancePaymentViewController {
    private func checkInfoIsFilled() -> Bool {
        let startDateCount = dateTextField.textField.count
        //        let voucherCount = voucherTextField.textField.count
        let companyNameCount = companyNameTextField.textField.count
        let companyAddressCount = companyAddressTextField.textField.count
        let companyTaxCount = mstTextField.textField.count
        
        return isAgree && startDateCount > 0 && (isRedBill ? (companyNameCount > 0 && companyAddressCount > 0 && companyTaxCount > 0) : true)
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard !dateTextField.textField.isEmpty(),
              //              !voucherTextField.textField.isEmpty(),
              checkInfoIsFilled() else {
                  disablePaymentButtons()
                  return
              }
        if !isRedBill && companyNameTextField.textField.isEmpty() && companyAddressTextField.textField.isEmpty() && mstTextField.textField.isEmpty() {
            disablePaymentButtons()
            return
        }
        enablePaymentButtons()
    }
    
    func disablePaymentButtons() {
//        paymentMethodTableView.isUserInteractionEnabled = false
        paymentMethodTableView.layer.opacity = 0.5
    }
    
    func enablePaymentButtons() {
//        paymentMethodTableView.isUserInteractionEnabled = true
        paymentMethodTableView.layer.opacity = 1
    }
    
    private func setupTextFields() {
        dateTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        companyNameTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        companyAddressTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        mstTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        dateTextField.textField.delegate = self
        companyNameTextField.textField.delegate = self
        companyAddressTextField.textField.delegate = self
        mstTextField.textField.delegate = self
        
        dateTextField.textField.returnKeyType = .done
        companyNameTextField.textField.returnKeyType = .next
        companyAddressTextField.textField.returnKeyType = .next
        mstTextField.textField.returnKeyType = .done
        
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case companyNameTextField.textField:
                companyNameTextField.hideError()
                if textField.isEmpty() {
                    companyNameTextField.showError("PLEASE_ENTER_NAME".localize())
                }
                redBillBottomConstraint.constant = !isRedBill ? 20 : (335 + 20 * ((companyNameTextField.isError ? 1 : 0) + (companyAddressTextField.isError ? 1 : 0) + (mstTextField.isError ? 1 : 0)))
                break
            case companyAddressTextField.textField:
                companyAddressTextField.hideError()
                if textField.isEmpty() {
                    companyAddressTextField.showError("PLEASE_ENTER_ADDRESS".localize())
                }
                redBillBottomConstraint.constant = !isRedBill ? 20 : (335 + 20 * ((companyNameTextField.isError ? 1 : 0) + (companyAddressTextField.isError ? 1 : 0) + (mstTextField.isError ? 1 : 0)))
                break
            case mstTextField.textField:
                mstTextField.hideError()
                if textField.isEmpty() {
                    mstTextField.showError("Vui lòng nhập mã số thuế công ty!")
                }
                redBillBottomConstraint.constant = !isRedBill ? 20 : (335 + 20 * ((companyNameTextField.isError ? 1 : 0) + (companyAddressTextField.isError ? 1 : 0) + (mstTextField.isError ? 1 : 0)))
                break
            case dateTextField.textField:
                dateTextField.hideError()
                if textField.isEmpty() {
                    dateTextField.showError("Vui lòng chọn ngày bắt đầu!")
                }
                break
//            case voucherTextField.textField:
//                voucherTextField.hideError()
//                if textField.isEmpty() {
//                    voucherTextField.showError("Vui lòng nhập tỉnh/thành!")
//                }
//                break
            default: break
        }
        
        guard !dateTextField.textField.isEmpty(),
              //                !voucherTextField.textField.isEmpty(),
              checkInfoIsFilled() else {
                  disablePaymentButtons()
                  return
              }
        if !isRedBill && companyNameTextField.textField.isEmpty() && companyAddressTextField.textField.isEmpty() && mstTextField.textField.isEmpty() {
            disablePaymentButtons()
            return
        }
        enablePaymentButtons()
    }
}
