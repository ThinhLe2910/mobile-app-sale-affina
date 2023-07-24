//
//  InsuranceCustomerInfoViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/08/2022.
//

import UIKit

class InsuranceCustomerInfoViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var maleButton: BaseButton!
    @IBOutlet weak var femaleButton: BaseButton!
    @IBOutlet weak var nextButton: BaseButton!
    
    @IBOutlet weak var cccdButton: BaseButton!
    @IBOutlet weak var cmndButton: BaseButton!
    @IBOutlet weak var passportButton: BaseButton!
    @IBOutlet weak var requestorSwitch: UISwitch!
    
    @IBOutlet weak var fullNameTextField: TitleTextFieldBase!
    @IBOutlet weak var dobTextField: TitleTextFieldBase!
    var datePickerView: UIDatePicker = UIDatePicker()
    @IBOutlet weak var phoneTextField: TitleTextFieldBase!
    @IBOutlet weak var emailTextField: TitleTextFieldBase!
    @IBOutlet weak var cityTextField: TitleTextFieldBase!
    var cityPickerView: UIPickerView = UIPickerView()
    @IBOutlet weak var districtTextField: TextFieldAnimBase!
    var districtPickerView: UIPickerView = UIPickerView()
    @IBOutlet weak var wardTextField: TextFieldAnimBase!
    var wardPickerView: UIPickerView = UIPickerView()
    @IBOutlet weak var streetTextField: TextFieldAnimBase!
    @IBOutlet weak var numberTextField: TextFieldAnimBase!
    @IBOutlet weak var cccdTextField: TitleTextFieldBase!
    @IBOutlet weak var frontView: BaseView!
    @IBOutlet weak var backView: BaseView!
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    
    @IBOutlet weak var streetTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    let imagePicker = UIImagePickerController()
    
    private var textField: TextFieldAnimBase?
    private var textFieldIndex: CGFloat = 0
    private var isFrontImageView: Bool = false
    private var isUploadingFrontImage = false
    private var isUploadingBackImage = false
    
    private let presenter = InsuranceCustomerInfoViewPresenter()
    private let commonService = CommonService()
    
    private let relationships: [String] = ["PARENTS".localize(), "COUPLE".localize(), "SIBLINGS".localize(), "CHILDREN".localize(), "OTHER".localize()] // ["Ông", "Bà", "Cha", "Mẹ", "Chồng", "Vợ", "Con", "Cháu", "Cô", "Dì", "Chú", "Bác", "Chắt", "Anh", "Chị", "Em"]
    
    private let genders = ["MR".localize(), "MISS".localize()]
    
    private var isRequestor: Bool = true
    private var isMale: Bool = true {
        didSet {
            let blueColor = UIColor.appColor(.blueMain)
            let blueTextColor = UIColor.appColor(.blue)
            let whiteColor = UIColor.appColor(.whiteMain)
            maleButton.backgroundColor = isMale ? blueColor : whiteColor
            maleButton.setTitleColor(isMale ? whiteColor : blueTextColor, for: .normal)
            femaleButton.backgroundColor = !isMale ? blueColor : whiteColor
            femaleButton.setTitleColor(isMale ? blueTextColor : whiteColor, for: .normal)
            maleButton.isUserInteractionEnabled = !isMale
            femaleButton.isUserInteractionEnabled = isMale
        }
    }
    
    private var identityType: IdentityType = .cccd {
        didSet {
            let blueTextColor = UIColor.appColor(.blue)
            let selectedColor = UIColor.appColor(.blueMain)
            let unselectedColor = UIColor.appColor(.whiteMain)
            cccdButton.backgroundColor = unselectedColor
            cmndButton.backgroundColor = unselectedColor
            cccdButton.titleLabel?.numberOfLines = 0; // Dynamic number of lines
            cccdButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            cmndButton.titleLabel?.numberOfLines = 0; // Dynamic number of lines
            cmndButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            passportButton.backgroundColor = unselectedColor
            cccdButton.setTitleColor(blueTextColor, for: .normal)
            cccdButton.setTitleColor(blueTextColor, for: .highlighted)
            cccdButton.setTitleColor(blueTextColor, for: .disabled)
            cmndButton.setTitleColor(blueTextColor, for: .normal)
            cmndButton.setTitleColor(blueTextColor, for: .highlighted)
            cmndButton.setTitleColor(blueTextColor, for: .disabled)
            passportButton.setTitleColor(blueTextColor, for: .normal)
            passportButton.setTitleColor(blueTextColor, for: .highlighted)
            passportButton.setTitleColor(blueTextColor, for: .disabled)
            if identityType == .cccd {
                cccdButton.backgroundColor = selectedColor
                cccdButton.setTitleColor(unselectedColor, for: .normal)
                cccdButton.setTitleColor(unselectedColor, for: .highlighted)
                cccdButton.setTitleColor(unselectedColor, for: .disabled)
                cccdTextField.textField.keyboardType = .numberPad
            }
            else if identityType == .cmnd {
                cmndButton.backgroundColor = selectedColor
                cmndButton.setTitleColor(unselectedColor, for: .normal)
                cmndButton.setTitleColor(unselectedColor, for: .highlighted)
                cmndButton.setTitleColor(unselectedColor, for: .disabled)
                cccdTextField.textField.keyboardType = .numberPad
            }
            else if identityType == .passport {
                passportButton.backgroundColor = selectedColor
                passportButton.setTitleColor(unselectedColor, for: .normal)
                passportButton.setTitleColor(unselectedColor, for: .highlighted)
                passportButton.setTitleColor(unselectedColor, for: .disabled)
                cccdTextField.textField.keyboardType = .default
            }
        }
    }
    
    private var citys: [CityModel] = []
    private var districts: [DistrictModel] = []
    private var wards: [WardModel] = []
    private var street: String = ""
    
    var model: PaymentContractPeopleInfoRequestModel?
    var productDetail: ProductDetailModel?
    var selectedSides: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideHeaderBase()
        containerBaseView.hide()
        
        addBlurStatusBar()
        
        view.backgroundColor = UIColor.appColor(.blueUltraLighter)
        scrollView.backgroundColor = UIColor.appColor(.blueUltraLighter)
        
        setupLeftViewPhoneTextField()
        setDropDownIcon(cityTextField.textField, isActive: true) {
            self.cityTextField.textField.becomeFirstResponder()
        }
        setDropDownIcon(districtTextField) {
            self.districtTextField.becomeFirstResponder()
        }
        setDropDownIcon(wardTextField) {
            self.wardTextField.becomeFirstResponder()
        }
        
        requestorSwitch.onTintColor = .appColor(.blueMain)
        
        setupDatePicker(datePickerView: datePickerView, textField: dobTextField)
        
        setupViewPicker(pickerView: cityPickerView, textField: cityTextField.textField)
        setupViewPicker(pickerView: districtPickerView, textField: districtTextField)
        setupViewPicker(pickerView: wardPickerView, textField: wardTextField)
        
        setupTextFields()
        
        // MARK: Set delegate
        presenter.setViewDelegate(delegate: self)
        
        imagePicker.delegate = self
        
        cityPickerView.delegate = self
        districtPickerView.delegate = self
        wardPickerView.delegate = self
        
        districtTextField.disable()
        wardTextField.disable()
        streetTextField.disable()
        numberTextField.disable()
        
        
        // MARK: Set action
        contentView.addTapGestureRecognizer {
            self.view.endEditing(true)
        }
        
        nextButton.addTapGestureRecognizer {
            self.didTapSubmitButton()
        }
        
        requestorSwitch.addTarget(self, action: #selector(didSwitchValueChanged), for: .valueChanged)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        maleButton.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        
        cccdButton.addTarget(self, action: #selector(didTapIDButton(_:)), for: .touchUpInside)
        cmndButton.addTarget(self, action: #selector(didTapIDButton(_:)), for: .touchUpInside)
        passportButton.addTarget(self, action: #selector(didTapIDButton(_:)), for: .touchUpInside)
        
        frontView.addTapGestureRecognizer {
            self.isFrontImageView = true
            self.pickID()
        }
        backView.addTapGestureRecognizer {
            self.isFrontImageView = false
            self.pickID()
        }
        
        // MARK: Set default value
        isRequestor = false
        isMale = true
        identityType = .cccd
        
        //
        if !UIConstants.isRequestedProvinces {
            commonService.getListCity { [weak self] result in
                guard let self = self else { return }
                switch result {
                    case .success(let provinces):
                        UIConstants.isRequestedProvinces = true
                        self.citys = provinces
                        self.citys.sort { first, second in
                            first.cityName.localizedCaseInsensitiveCompare(second.cityName) == .orderedAscending
                        }
                        let cacheData = CacheData(json: Json.filterJson(self.citys))
                        CacheManager.shared.insertCacheWithKey(Key.provinces.rawValue, cacheData)
                        break
                    case .failure(let error):
                        Logger.Logs(event: .error, message: error.localizedDescription)
                        break
                }
            }
        }
        else {
            ParseCache.parseCacheToArray(key: Key.provinces.rawValue, modelType: CityModel.self) { result in
                switch result {
                    case .success(let provinces):
                        self.citys = provinces
                    case .failure(let error):
                        Logger.Logs(event: .error, message: error)
                }
            }
        }
        
        if let model = model {
            dobTextField.textField.text = "\(model.dob / 1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            isMale = model.gender == EnumGender.male.rawValue
            datePickerView.date = Date(timeIntervalSince1970: model.dob / 1000)
        }
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
        
        // REMOVE: 
//                fullNameTextField.textField.text = "Dinh Le Trieu Duong"
//                emailTextField.textField.text = "abc@abc.com"
//                datePickerView.date = Date(year: 1999, month: 06, day: 10)
//                phoneTextField.textField.text = "0854356665"
//                streetTextField.text = "aaaaa"
//                numberTextField.text = "bbbbbb"
//                cccdTextField.textField.text = "060099003584"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let model = model {
            dobTextField.textField.text = "\(model.dob / 1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            isMale = model.gender == EnumGender.male.rawValue
        }
    }
    
    func showInvalidInfoPopup(title: String = "THE_POLICYHOLDER_IS_UNDER_18_YEARS_OLD".localize().capitalized, message: String = "PLEASE_UNCHECK_THE_FUNCTION_\"THE_POLICYHOLDER_IS_ALSO_THE_INSURED\"_AND_RE-ENTER_THE_BUYER_INFORMATION".localize().capitalized) {
        let desc = getAttributedString(arrayTexts: [message], arrayColors: [.appColor(.blackMain) ?? .black], arrayFonts: [UIConstants.Fonts.appFont(.Regular, 16)])
        
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: title, desc: desc, okTitle: "CONFIRM".localize().uppercased(), cancelTitle: "CANCEL".localize().uppercased(), buttonStyles: [
            BaseButtonStyle(backgroundColor: .appColor(.pinkMain), textColor: .appColor(.whiteMain), borderColor: .clear, borderWidth: 0),
            BaseButtonStyle(backgroundColor: .clear, textColor: .appColor(.black), borderColor: .appColor(.grayBorder), borderWidth: 2),
        ], descText: message) {
            for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: InsuranceFilterViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }

            self.hideBasePopup()
        } handler: {
            
        }
    }
    func showInvalidPopup(title: String = "THE_POLICYHOLDER_IS_UNDER_18_YEARS_OLD".localize().capitalized, message: String = "PLEASE_UNCHECK_THE_FUNCTION_\"THE_POLICYHOLDER_IS_ALSO_THE_INSURED\"_AND_RE-ENTER_THE_BUYER_INFORMATION".localize().capitalized) {
        let desc = getAttributedString(arrayTexts: [message], arrayColors: [.appColor(.blackMain) ?? .black], arrayFonts: [UIConstants.Fonts.appFont(.Regular, 16)])
        
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: title, desc: desc, okTitle: "", cancelTitle: "GOT_IT".localize(), buttonStyles: [BaseButtonStyle(backgroundColor: .appColor(.pinkMain), textColor: .appColor(.whiteMain), borderColor: .clear, borderWidth: 0), BaseButtonStyle(backgroundColor: .clear, textColor: .appColor(.black), borderColor: .appColor(.grayBorder), borderWidth: 2)], descText: message) {
//            for controller in self.navigationController!.viewControllers as Array {
//                if controller.isKind(of: InsuranceFilterViewController.self) {
//                    self.navigationController!.popToViewController(controller, animated: true)
//                    break
//                }
//            }
            
//            self.hideBasePopup()
        } handler: {
            
        }
    }
    
    @objc private func didTapGenderButton(_ sender: UIButton) {
//        if let model = model, let productDetail = productDetail {
//            var isConstraintGender: Bool = false
//            if !selectedSides.isEmpty {
//                for i in selectedSides {
//                    if productDetail.listProductSideBenefit[i].applicableGender == model.gender {
//                        isConstraintGender = true
//                    }
//                }
//            }
//            if isConstraintGender {
//                if (isMale && model.gender == EnumGender.male.rawValue) || (!isMale && model.gender == EnumGender.female.rawValue) {
//                    showInvalidPopup()
//                }
//                return
//            }
//        }
        if sender == maleButton {
            isMale = true
        }
        else {
            isMale = false
        }
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
    }
    
    @objc private func didTapIDButton(_ sender: UIButton) {
        cccdTextField.textField.resignFirstResponder()
        if sender == cccdButton {
            identityType = .cccd
        }
        else if sender == cmndButton {
            identityType = .cmnd
        }
        else if sender == passportButton {
            identityType = .passport
        }
        
        textFieldDidChange(cccdTextField.textField)
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
    }
    
    @objc private func didSwitchValueChanged() {
        isRequestor = !requestorSwitch.isOn
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapSubmitButton() {
        view.endEditing(true)
        
        model?.name = fullNameTextField.textField.text
        model?.dob = datePickerView.date.timeIntervalSince1970 * 1000
        model?.phone = parsePhoneNumber(phoneNumber: phoneTextField.textField.text ?? "")
        model?.email = emailTextField.textField.text
        model?.street = streetTextField.text
        model?.houseNumber = numberTextField.text
        
        model?.gender = isMale ? 1 : 0
        
        model?.license = cccdTextField.textField.text?.replace(string: " ", replacement: "")
        model?.licenseType = identityType.rawValue
        
        model?.buyHelp = isRequestor ? 1 : 0
        
        model?.address = "\((numberTextField!.text ?? "").replace(string: ",", replacement: "")), \((streetTextField!.text ?? "").replace(string: ",", replacement: "")), \(wardTextField!.text ?? ""), \(districtTextField!.text ?? ""), \(cityTextField.textField.text ?? "")"
        
        guard let model = model else {
            return
        }
        Logger.Logs(message: model)
        
        let dict: [String: Any] = [
            "productId": model.productId,
            "listProductSideBenefit": model.listProductSideBenefit ?? [],
            "gender": model.gender,
            "dob": model.dob,
            "buyHelp": model.buyHelp
        ]
        presenter.checkIsValidInfo(model: dict)
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        scrollViewBottomConstraint.constant = 0
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewBottomConstraint.constant = keyboardSize.height
            let yOffset = (textField?.convert(([5, 6, 7, 8].contains(textFieldIndex) ? textField?.bounds.origin : textField?.frame.origin) ?? .zero, to: contentView).y ?? 0)
            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + 74), animated: true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case fullNameTextField.textField:
                textFieldIndex = 0
                self.textField = fullNameTextField.textField
                break
            case dobTextField.textField:
                textFieldIndex = 1
                self.textField = dobTextField.textField
                break
            case phoneTextField.textField:
                textFieldIndex = 2
                self.textField = phoneTextField.textField
                break
            case emailTextField.textField:
                textFieldIndex = 3
                self.textField = emailTextField.textField
                break
            case cityTextField.textField:
                textFieldIndex = 4
                self.textField = cityTextField.textField
                break
            case districtTextField:
                textFieldIndex = 5
                self.textField = districtTextField
                break
            case wardTextField:
                textFieldIndex = 6
                self.textField = wardTextField
                break
            case streetTextField:
                textFieldIndex = 7
                self.textField = streetTextField
                break
            case numberTextField:
                textFieldIndex = 8
                self.textField = numberTextField
                break
            case cccdTextField.textField:
                textFieldIndex = 9
                self.textField = cccdTextField.textField
                break
            default:
                break
        }
        
        return true
    }
    
    private func enableSubmitButton() {
        nextButton.isUserInteractionEnabled = true
        nextButton.isEnabled = true
        nextButton.backgroundColor = .appColor(.pinkMain)
        nextButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        nextButton.dropShadow(color: UIColor.appColor(.pinkLong) ?? UIColor(hex: "FF52DB"), opacity: 0.25, offset: .init(width: 0, height: 8), radius: 16, scale: true)
    }
    
    private func disableSubmitButton() {
        nextButton.isUserInteractionEnabled = false
        nextButton.isEnabled = false
        nextButton.backgroundColor = .appColor(.pinkUltraLighter)
        nextButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        nextButton.clearShadow()
    }
}

// MARK: InsuranceCustomerInfoViewDelegate
extension InsuranceCustomerInfoViewController: InsuranceCustomerInfoViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unLockUI() {
        unlockScreen()
    }
    
    func showAlert() {
        
    }
    
    func showError(error: ApiError) {
        switch error {
            case .refresh:
                break
            case .expired:
                UIConstants.isBanned = true
                logOut()
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
//                    self.navigationController?.popToRootViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                } handler: {
                    
                }
                break
            case .conflict:
            queueBasePopup(icon: UIImage(named: "ic_warning"), title: "Gửi yêu cầu thất bại", desc: "Lỗi trùng lặp thẻ bảo hiểm, vui lòng tạo bảo hiểm khác", okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                    self.popToViewController(InsuranceListViewController())
                }, handler: {})
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
            default:
            queueBasePopup(icon: UIImage(named: "ic_warning"), title: "Lỗi", desc: "Đã có lỗi xảy ra!", okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                    self.hideBasePopup()
                }, handler: {})
                break
        }
    }
    
    func createSuccessful(contract: InsuranceContractModel) {
        let vc = InsurancePaymentViewController()
        vc.contractModel = contract
        vc.paymentInfoModel = self.model
        vc.productDetail = self.productDetail
        vc.selectedSides = self.selectedSides
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func goToOtp(otp: OtpResponseData) {
        let vc = InsuranceOtpViewController()
        vc.otpData = otp
        vc.paymentInfoModel = model
        vc.productDetail = self.productDetail
        vc.selectedSides = self.selectedSides
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func uploadImageSuccess(link: String, isFront: Bool) {
        if isFront {
            isUploadingFrontImage = false
            model?.licenseFront = link
            
        }
        else {
            isUploadingBackImage = false
            model?.licenseBack = link
        }
        
        guard let model = model else { return }
        if !isUploadingFrontImage && !isUploadingBackImage {
            Logger.Logs(message: model)
            if UIConstants.isLoggedIn {
                self.presenter.createContractWithToken(model: model)
            }
            else {
                self.presenter.createContract(model: model)
            }
        }
    }
    
    func isValidInfo(code: String, isValid: Bool, message: String) {
        if isValid {
            guard let productDetail = productDetail else { return }
            var listSide: [String]? = []
            for i in 0..<selectedSides.count {
                listSide?.append(productDetail.listProductSideBenefit[selectedSides[i]].id)
            }
            listSide = (listSide?.isEmpty ?? true) ? nil : listSide
            model?.listProductSideBenefit = listSide
            
            guard let model = model, let email = model.email, let phone = model.phone, let address = model.address else {
                return
            }
            let popup = InformationReviewView(frame: .zero)
            popup.setInfo(name: model.name!, gender: model.gender, cccd: model.license!, dob: model.dob, email: email, phone: phone, address: address.replace(string: ", , ", replacement: ", "))
            popup.confirmCallBack = {
                if self.isRequestor {
                    let vc = InsuranceRequestorInfoViewController(nibName: InsuranceRequestorInfoViewController.nib, bundle: nil)
                    vc.model = model
                    vc.productDetail = self.productDetail
                    vc.selectedSides = self.selectedSides
                    if self.frontImageView.image != nil {
                        vc.licenseImages["front"] = self.frontImageView.image!
                    }
                    if self.backImageView.image != nil {
                        vc.licenseImages["back"] = self.backImageView.image!
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    if self.frontImageView.image == nil && self.backImageView.image == nil {
                        if UIConstants.isLoggedIn {
                            self.presenter.createContractWithToken(model: model)
                        }
                        else {
                            self.presenter.createContract(model: model)
                        }
                    }
                    else {
                        if let frontImage = self.frontImageView.image {
                            self.isUploadingFrontImage = true
                            self.presenter.uploadImage(image: frontImage, isFront: true, isBuyHelp: false)
                            
                            if let backImage = self.backImageView.image {
                                self.isUploadingBackImage = true
                                self.presenter.uploadImage(image: backImage, isFront: false, isBuyHelp: false)
                            }
                        }
                    }
                }
            }
            popup.editCallBack = {
                self.hideBottomSheet(animated: true)
            }
            popup.translatesAutoresizingMaskIntoConstraints = false
            bottomSheet.setContentForBottomSheet(popup)
            bottomSheet.topView.hide()
            setNewBottomSheetHeight(640)
            disableBottomSheetDrag()
            showBottomSheet()
        }
        else {
            if code == "PRODUCT_4000" {
                showInvalidInfoPopup(title: "NOT_SUITABLE_FOR_THIS".localize(), message: "YOU_HAVE_JUST_CHANGED".localize())
            }
            else if code == "CONTRACT_4000" {
                showInvalidPopup(title: "THE_POLICYHOLDER_IS_UNDER_18_YEARS_OLD".localize(), message: "PLEASE_CORRECT_THE_BUYER_INFORMATION._BUYER_MUST_BE_OVER_18_YEARS_OLD_RE-ENTER_THE_BUYER_INFORMATION".localize())
            }
            else {
                showInvalidPopup(title: "THE_POLICYHOLDER_IS_UNDER_18_YEARS_OLD".localize().capitalized, message: message)
            }
        }
    }
}

// MARK: UIPickerViewDelegate
extension InsuranceCustomerInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cityPickerView {
            return citys.count
        }
        if pickerView == districtPickerView {
            return districts.count
        }
        if pickerView == wardPickerView {
            return wards.count
        }
        return 0
    }
    
    private func selectCity(_ index: Int) {
        cityTextField.textField.text = citys[index].cityName
        commonService.getListDistrict(cityCode: "\(citys[index].cityCode)") { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let districts):
                    UIConstants.isRequestedProvinces = true
                    self.districts = districts
                    self.districts.sort { first, second in
                        first.districtsName.localizedCaseInsensitiveCompare(second.districtsName) == .orderedAscending
                    }
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
                    break
            }
        }
        if let text = districtTextField.text, text.isEmpty {
            districtTextField.enable()
            (districtTextField.viewWithTag(22) as? UIImageView)?.tintColor = .appColor(.black)
        }
        districtTextField.text = ""
        wardTextField.text = ""
        wardTextField.disable()
        (wardTextField.viewWithTag(22) as? UIImageView)?.tintColor = .appColor(.grayLight)
        //        streetTextField.text = ""
        //        numberTextField.text = ""
        streetTextField.disable()
        numberTextField.disable()
    }
    
    private func selectDistrict(_ index: Int) {
        districtTextField.text = districts[index].districtsName
        commonService.getListWard(districtCode: "\(districts[index].districtsCode)") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let wards):
                self.wards = wards
                self.wards.sort { first, second in
                    first.wardsName.localizedCaseInsensitiveCompare(second.wardsName) == .orderedAscending
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription)
                break
            }
        }
        if let text = wardTextField.text, text.isEmpty {
            wardTextField.enable()
            (wardTextField.viewWithTag(22) as? UIImageView)?.tintColor = .appColor(.black)
        }
        wardTextField.text = ""
        //        streetTextField.text = ""
        //        numberTextField.text = ""
        streetTextField.disable()
        numberTextField.disable()
    }
    
    private func selectWard(_ index: Int) {
        wardTextField.text = wards.isEmpty ? "" : wards[index].wardsName
        //        if index == -1 {
        //            streetTextField.disable()
        //            numberTextField.disable()
        //        } else {
        streetTextField.enable()
        numberTextField.enable()
        //        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cityPickerView {
            model?.cityCode = citys[row].cityCode
            selectCity(row)
        }
        if pickerView == districtPickerView {
            model?.districtsCode = districts[row].districtsCode
            selectDistrict(row)
        }
        if pickerView == wardPickerView {
            model?.wardsCode = wards.isEmpty ? -1 : wards[row].wardsCode
            selectWard(row)
        }
        textFieldDidEndEditing(UITextField())
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cityPickerView {
            return citys[row].cityName
        }
        if pickerView == districtPickerView {
            return districts[row].districtsName
        }
        if pickerView == wardPickerView {
            return wards[row].wardsName
        }
        return citys[row].cityName
    }
    
    private func setupViewPicker(pickerView: UIPickerView, textField: TextFieldAnimBase) {
        //        pickerView.backgroundColor = UIColor.appColor(.whiteMain)
        
        textField.inputView = pickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(pickerViewValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        textField.inputAccessoryView = doneToolbar
    }
    
    @objc private func pickerViewValueDone() {
        if cityTextField.textField.isFirstResponder {
            model?.cityCode = citys[cityPickerView.selectedRow(inComponent: 0)].cityCode
            cityTextField.textField.resignFirstResponder()
            selectCity(cityPickerView.selectedRow(inComponent: 0))
        }
        else if districtTextField.isFirstResponder {
            model?.districtsCode = districts[districtPickerView.selectedRow(inComponent: 0)].districtsCode
            districtTextField.resignFirstResponder()
            selectDistrict(districtPickerView.selectedRow(inComponent: 0))
        }
        else if wardTextField.isFirstResponder {
            model?.wardsCode = wards.isEmpty ? -1 : wards[wardPickerView.selectedRow(inComponent: 0)].wardsCode
            wardTextField.resignFirstResponder()
            selectWard(wardPickerView.selectedRow(inComponent: 0))
        }
        textFieldDidEndEditing(UITextField())
    }
    
}

// MARK: UIImagePickerControllerDelegate
extension InsuranceCustomerInfoViewController: UIImagePickerControllerDelegate {
    func convertBase64StringToImage(imageBase64String: String) -> UIImage {
        //        let imageData = Data(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let imageData = Data(base64Encoded: imageBase64String)
        let image = UIImage(data: imageData!)
        return image!
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    @objc func pickID() {
        AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
            UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            }),
            UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                self.imagePicker.sourceType = .photoLibrary
                self.present(self.imagePicker, animated: true, completion: nil)
            }),
            UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                
            })], completion: {
                
            })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        if isFrontImageView {
            self.frontImageView.image = image
            self.frontImageView.show()
            model?.licenseFront = ""
        }
        else {
            backImageView.image = image
            backImageView.show()
            model?.licenseBack = ""
        }
        self.imagePicker.allowsEditing = false
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            image = img
        }
        else if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            image = img
        }
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Cancel pick image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension InsuranceCustomerInfoViewController: UINavigationControllerDelegate {
    
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

// MARK: InsuranceCustomerInfoViewController
extension InsuranceCustomerInfoViewController {
    private func setDropDownIcon(_ textField: TextFieldAnimBase, isActive: Bool = false, callBack: @escaping () -> Void) {
        let view = UIView(frame: .init(x: 0, y: 0, width: 50, height: 50))
        let dropdown = UIImageView(frame: .init(x: 12, y: 12, width: 24, height: 24))
        dropdown.image = UIImage(named: "ic_dropdown_chev")?.withRenderingMode(.alwaysTemplate)
        dropdown.tintColor = isActive ? .appColor(.black) : .appColor(.grayLight)
        dropdown.tag = 22
        view.addSubview(dropdown)
        dropdown.center = view.center
        textField.rightViewMode = .always
        textField.rightView = view
        textField.defaultRightImage = dropdown.image ?? UIImage()
        view.addTapGestureRecognizer {
            callBack()
        }
    }
    
    private func setupLeftViewPhoneTextField() {
        //        phoneTextField.rightView.hide()
        let subView = BaseView()
        subView.translatesAutoresizingMaskIntoConstraints = false
        let flagIcon = UIImageView()
        flagIcon.translatesAutoresizingMaskIntoConstraints = false
        flagIcon.image = UIImage(named: "ic_flag")
        subView.addSubview(flagIcon)
        flagIcon.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.top.bottom.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "+84"
        label.font = UIConstants.Fonts.appFont(.Bold, 14)
        label.textColor = .appColor(.whiteMain)
        subView.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(flagIcon.snp_centerY)
            make.leading.equalTo(flagIcon.snp_trailing).offset(2)
            
        }
        let dropdownIcon = UIImageView()
        dropdownIcon.translatesAutoresizingMaskIntoConstraints = false
        dropdownIcon.image = UIImage(named: "ic_dropdown")?.withRenderingMode(.alwaysTemplate)
        dropdownIcon.tintColor = .appColor(.whiteMain)
        subView.addSubview(dropdownIcon)
        dropdownIcon.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.centerY.equalTo(flagIcon.snp_centerY)
            make.leading.equalTo(label.snp_trailing).offset(8)
            make.trailing.equalToSuperview().offset(8)
        }
        phoneTextField.leftView.backgroundColor = .appColor(.blueMain)
        phoneTextField.leftView.addSubview(subView)
        phoneTextField.leftViewWidthConstraint.constant = 92
        phoneTextField.textField.keyboardType = .phonePad
        
    }
    
    private func setupDatePicker(datePickerView: UIDatePicker, textField: TitleTextFieldBase, isRequestor: Bool = false) {
        // datePickerView = UIDatePicker()
        datePickerView.locale = NSLocale(localeIdentifier: "vi_VN") as Locale
        datePickerView.backgroundColor = UIColor.appColor(.whiteMain)
        datePickerView.maximumDate = Date()
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
        dobTextField.textField.text = dateFormatter.string(from: datePickerView.date)
    }
    
    @objc private func datePickerValueChanged() {
        setDobValue()
    }
    
    @objc private func datePickerValueDone() {
        setDobValue()
        dobTextField.textField.resignFirstResponder()
    }
    
    func parsePhoneNumber(phoneNumber: String) -> String {
        if phoneNumber.isEmpty { return "" }
        let firstNumber = phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 0)]
        let phone = (firstNumber == "0" ? "" : "0") + (phoneNumber.replace(string: " ", replacement: ""))
        return phone
    }
    
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        if phoneNumber.isEmpty { return false }
        let firstNumber = phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 0)]
        if firstNumber == "0" && phoneNumber.count < 10 { return false }
        return Validation.isValidPhoneNumber(phone: phoneNumber)
    }
    
    private func checkInfoIsFilled() -> Bool {
        let nameCount = fullNameTextField.textField.count
        let dobCount = dobTextField.textField.count
        let cityCount = cityTextField.textField.count
        let districtCount = districtTextField.count
        let wardCount = wardTextField.count
        let streetCount = streetTextField.count
        let numberCount = numberTextField.count
        let cccdCount = cccdTextField.textField.count
        
        guard let phone = phoneTextField.textField.text, let email = emailTextField.textField.text, let cccd = cccdTextField.textField.text?.replace(string: " ", replacement: "") else { return false}
        if !isValidPhoneNumber(phoneNumber: parsePhoneNumber(phoneNumber: phone)) || !Validation.isValidEmail(email: email)
            || (!Validation.isValidCCCD(cccd) && identityType == .cccd)
            || (!Validation.isValidCMND(cccd) && identityType == .cmnd)
            || (!Validation.isValidPassport(cccd) && identityType == .passport)
        {
            return false
        }
        
        return nameCount > 0 && dobCount > 0 && phone.count > 0 && email.count > 0 && cityCount > 0 && districtCount > 0 && (wards.isEmpty ? true : wardCount > 0) && streetCount > 0 && numberCount > 0 && cccdCount > 0
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard !fullNameTextField.textField.isEmpty(),
              !dobTextField.textField.isEmpty(),
              !emailTextField.textField.isEmpty(),
              !phoneTextField.textField.isEmpty(),
              !cityTextField.textField.isEmpty(),
              !districtTextField.isEmpty(),
              //              !wardTextField.isEmpty(),
              !streetTextField.isEmpty(),
              !numberTextField.isEmpty(),
              !cccdTextField.textField.isEmpty(),
              checkInfoIsFilled() else {
                  disableSubmitButton()
                  return
              }
        if !wards.isEmpty && wardTextField.isEmpty() {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var phoneNumber = phoneTextField.textField.text?.replace(string: " ", replacement: ""),
              let cccd = cccdTextField.textField.text else { return false }
        
        let characterCount = phoneNumber.count
        let phoneCount = (characterCount + (string == "" ? -1 : 1))
        let cccdCount = (cccd.count + (string == "" ? -1 : 1))
        //        var count = string == "" ? -1 : 1
        
        if textField == phoneTextField.textField {
            if string == "" {
                phoneNumber.removeLast()
            }
            if (phoneCount == 3 || phoneCount == 6) && string != "" {
                phoneTextField.textField.text = (phoneTextField.textField.text ?? "") + " "
            }
            return phoneCount <= 12 // true
        }
        else if textField == cccdTextField.textField {
            if cccdCount % 4 == 0 && string != "" {
                cccdTextField.textField.text = (cccdTextField.textField.text ?? "") + (cccdCount <= 14 ? " " : "")
            }
            if cccdCount > 0 && checkInfoIsFilled() {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
            if identityType != .passport {
                return cccdCount <= 15 // 12 + 3 space
            }
            return cccdCount <= 10 || string == ""
        }
        
        return true
    }
    
    private func setupTextFields() {
        fullNameTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        dobTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        emailTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        phoneTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        cityTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        districtTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        wardTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        streetTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        numberTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        cccdTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        fullNameTextField.textField.delegate = self
        dobTextField.textField.delegate = self
        emailTextField.textField.delegate = self
        emailTextField.textField.keyboardType = .emailAddress
        phoneTextField.textField.delegate = self
        cityTextField.textField.delegate = self
        districtTextField.delegate = self
        wardTextField.delegate = self
        streetTextField.delegate = self
        numberTextField.delegate = self
        cccdTextField.textField.delegate = self
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case fullNameTextField.textField:
                fullNameTextField.hideError()
                if textField.isEmpty() {
                    fullNameTextField.showError("PLEASE_INPUT_FULL_NAME".localize())
                }
                break
            case dobTextField.textField:
                dobTextField.hideError()
                if textField.isEmpty() {
                    dobTextField.showError("PLEASE_SELECT_UR_DOB".localize())
                }
                break
            case emailTextField.textField:
                emailTextField.hideError()
                if textField.isEmpty() {
                    emailTextField.showError("PLEASE_INPUT_EMAIL".localize())
                }
                else if !Validation.isValidEmail(email: textField.text ?? "") {
                    emailTextField.showError("PLEASE_INPUT_VALID_EMAIL" .localize())
                }
                break
            case phoneTextField.textField:
                phoneTextField.hideError()
                if textField.isEmpty() {
                    phoneTextField.showError("ERROR_EMPTY_PHONE_NUMBER".localize())
                }
                else if !isValidPhoneNumber(phoneNumber: parsePhoneNumber(phoneNumber: textField.text ?? "")) {
                    phoneTextField.showError("PLEASE_INPUT_CORRECT_FORMAT".localize())
                }
                break
            case cityTextField.textField:
                cityTextField.hideError()
                if textField.isEmpty() {
                    cityTextField.showError("PLEASE_INPUT_PROVINCE_CITY".localize())
                }
                break
            case districtTextField:
                break
            case wardTextField:
                break
            case streetTextField:
                streetTextField.hideError()
                streetTextFieldBottomConstraint.constant = 8
                if textField.isEmpty() {
                    streetTextField.showError("PLEASE_INPUT_STREET_NAME".localize())
                    streetTextFieldBottomConstraint.constant = 28
                }
                break
            case numberTextField:
                numberTextField.hideError()
                if textField.isEmpty() {
                    numberTextField.showError("PLEASE_INPUT_HOUSE_NUMBER".localize())
                }
                break
            case cccdTextField.textField:
                cccdTextField.hideError()
                let cccd = textField.text?.replace(string: " ", replacement: "") ?? ""
                if textField.isEmpty() {
                    cccdTextField.showError("PLEASE_INPUT_INFORMATION".localize())
                }
                else if (!Validation.isValidCCCD(cccd) && identityType == .cccd)
                            || (!Validation.isValidCMND(cccd) && identityType == .cmnd)
                            || (!Validation.isValidPassport(cccd) && identityType == .passport) {
                    cccdTextField.showError("PLEASE_INPUT_CORRECT_FORMAT".localize())
                }
                break
            default: break
        }
        
        guard !fullNameTextField.textField.isEmpty(),
              !dobTextField.textField.isEmpty(),
              !emailTextField.textField.isEmpty(),
              !phoneTextField.textField.isEmpty(),
              !cityTextField.textField.isEmpty(),
              !districtTextField.isEmpty(),
              //              !wardTextField.isEmpty(),
              !streetTextField.isEmpty(),
              !numberTextField.isEmpty(),
              !cccdTextField.textField.isEmpty(),
              checkInfoIsFilled()
        else {
            disableSubmitButton()
            return
        }
        if !wards.isEmpty && wardTextField.isEmpty() {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }
    
}
