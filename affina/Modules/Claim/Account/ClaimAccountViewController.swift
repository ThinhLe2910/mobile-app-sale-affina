//
//  ClaimAccountViewController.swift
//  affina
//
//  Created by Dylan on 21/09/2022.
//

import UIKit

class ClaimAccountViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var benefitLabel: BaseLabel!
    
    @IBOutlet weak var paymentInforLabel: BaseLabel!
    @IBOutlet weak var bankNameTextField: TitleTextFieldBase!
    @IBOutlet weak var bankBranchTextField: TitleTextFieldBase!
    @IBOutlet weak var holderTextField: TitleTextFieldBase!
    @IBOutlet weak var accountTextField: TitleTextFieldBase!
    @IBOutlet weak var relationshipTextField: TitleTextFieldBase!
    
    @IBOutlet weak var agreeLabel: BaseLabel!
    
    var relationshipPickerView: UIPickerView = UIPickerView()
    var bankPickerView: UIPickerView = UIPickerView()
    var curPickerView: UIPickerView = UIPickerView()
    
    @IBOutlet weak var checkBoxButton: BaseButton!
    @IBOutlet weak var submitButton: BaseButton!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private let presenter: ProofViewPresenter = ProofViewPresenter()
    
    private var textField: TextFieldAnimBase!
    private var textFieldIndex = -1
    
    private var isAgree: Bool = false
    private var banks: [Bank] = []
    
    var licenseImages: [UIImage] = []
    
    private let relationships: [String] = ["APPLICANT".localize(), "PARENTS".localize(), "COUPLE".localize(), "CHILDREN".localize(), ]
    // ["Ông", "Bà", "Cha", "Mẹ", "Chồng", "Vợ", "Con", "Cháu", "Cô", "Dì", "Chú", "Bác", "Chắt", "Anh", "Chị", "Em"]
    
    var requestModel: ClaimRequestModel?
    
    var images: [UIImage] = []
    var benefit: String = ""
    
    private var selectedRelationship: Int = 0 {
        didSet {
            relationshipTextField.textField.text = ContractObjectPeopleRelationshipEnum(rawValue: selectedRelationship)?.value ?? "OTHER".localize() // relationships[selectedRelationship]
        }
    }
    private var selectedBank: Int = 0 {
        didSet {
            bankNameTextField.textField.text = banks[selectedBank].bankName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBlurStatusBar()
        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        paymentInforLabel.lineBreakMode = .byWordWrapping
        paymentInforLabel.numberOfLines = 0
            //________________
        setDropDownIcon(relationshipTextField.textField, isActive: true) {
            self.relationshipTextField.textField.becomeFirstResponder()
            self.curPickerView = self.relationshipPickerView
        }
        
        setDropDownIcon(bankNameTextField.textField, isActive: true) {
            self.bankNameTextField.textField.becomeFirstResponder()
            self.curPickerView = self.bankPickerView
        }
        
        bankPickerView.delegate = self
        relationshipPickerView.delegate = self
        setupViewPicker(pickerView: bankPickerView, textField: bankNameTextField.textField)
        setupViewPicker(pickerView: relationshipPickerView, textField: relationshipTextField.textField)
        //________________
        setupTextFields()
        
        benefitLabel.text = "BENEFIT".localize() + " \(benefit)"
        
        
        agreeLabel.attributedText = getAttributedString(
            arrayTexts: ["BY_CLICK_CONTINUE_I_READ_ACCEPTED_WITH".localize(), "TERMS".localize(), "AND".localize(), "PRIVACY".localize(), "OUR".localize()],
            arrayColors: [UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!],
            arrayFonts: [agreeLabel.font, UIConstants.Fonts.appFont(.Bold, 14), agreeLabel.font, UIConstants.Fonts.appFont(.Bold, 14), agreeLabel.font],
            arrayUnderlines: [false, true, false, true, false]
        )
        agreeLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNoteLabel))
        agreeLabel.addGestureRecognizer(tap)
        
        
        selectedRelationship = 0
        
        presenter.delegate = self
        backButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        if checkInfoIsFilled() {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
        
        presenter.getListBanks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        benefitLabel.text = "BENEFIT".localize() + " \(benefit)"
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        scrollViewBottomConstraint.constant = 0
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewBottomConstraint.constant = keyboardSize.height
            let yOffset = (textField?.convert(textField?.frame.origin ?? .zero, to: contentView).y ?? 0)
            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + 74), animated: true)
        }
    }
    
    @objc private func didTapNoteLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = agreeLabel.text else { return }
        view.endEditing(true)
        let termsRange = (text as NSString).range(of: "TERMS".localize())
        let privacyRange = (text as NSString).range(of: "PRIVACY".localize())
        
        if gesture.didTapAttributedTextInLabel(label: agreeLabel, targetRange: termsRange) {
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/dieu-khoan-kieu-kien")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gesture.didTapAttributedTextInLabel(label: agreeLabel, targetRange: privacyRange) {
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/chinh-sach-bao-mat")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func didTapButton(_ sender: BaseButton) {
        view.endEditing(true)
        switch sender {
            case backButton:
                self.popViewController()
            case checkBoxButton:
                isAgree.toggle()
                
                checkBoxButton.setImage(isAgree ? UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate) : nil, for: .normal)
                checkBoxButton.backgroundColor = .appColor(isAgree ? .blueMain : .whiteMain)
                
                if checkInfoIsFilled() {
                    enableSubmitButton()
                }
                else {
                    disableSubmitButton()
                }
                break
            case submitButton:
                requestModel?.bankBranch = bankBranchTextField.textField.text
                //                requestModel?.bankCode = "101" // bankNameTextField.textField.text
                requestModel?.relationship = selectedRelationship
                requestModel?.accountNumberBank = accountTextField.textField.text
                requestModel?.accountName = holderTextField.textField.text
                guard let requestModel = requestModel else {
                    return
                }
                if requestModel.claimType == .DEAD {
                    return
                }
                if images.isEmpty {
                    presenter.createClaimRequest(model: requestModel)
                }
                else {
                    presenter.uploadImages(images: images)
                }
                break
            default: break
        }
    }
    
    
}

// MARK: UIPickerViewDelegate
extension ClaimAccountViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == bankPickerView {
            return banks.count
        }
        return relationships.count
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == bankPickerView {
            selectedBank = row
            requestModel?.bankId = banks[row].bankId
            requestModel?.bankCode = banks[row].bankCode
            requestModel?.bankName = banks[row].bankName
            return
        }
        selectedRelationship = row
        requestModel?.relationship = row
        textFieldDidEndEditing(UITextField())
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == bankPickerView {
            return banks[row].bankName
        }
        return relationships[row]
    }

}

// MARK: Extension
extension ClaimAccountViewController {
    private func enableSubmitButton() {
        submitButton.isUserInteractionEnabled = true
        submitButton.isEnabled = true
        submitButton.backgroundColor = .appColor(.pinkMain)
        submitButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        submitButton.dropShadow(color: UIColor.appColor(.pinkLong) ?? UIColor(hex: "FF52DB"), opacity: 0.25, offset: .init(width: 0, height: 8), radius: 16, scale: true)
    }
    
    private func disableSubmitButton() {
        submitButton.isUserInteractionEnabled = false
        submitButton.isEnabled = false
        submitButton.backgroundColor = .appColor(.pinkUltraLighter)
        submitButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        submitButton.clearShadow()
    }
    
    private func checkInfoIsFilled() -> Bool {
        let bankNameCount = bankNameTextField.textField.count
        let bankBranchCount = bankBranchTextField.textField.count
        let holderCount = holderTextField.textField.count
        let accountCount = accountTextField.textField.count
        let relationshipCount = relationshipTextField.textField.count
        return bankNameCount > 0 && bankBranchCount > 0 && holderCount > 0 && accountCount > 0 && relationshipCount > 0 && isAgree
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard !bankNameTextField.textField.isEmpty(),
              !bankBranchTextField.textField.isEmpty(),
              !holderTextField.textField.isEmpty(),
              !accountTextField.textField.isEmpty(),
              !relationshipTextField.textField.isEmpty(),
              checkInfoIsFilled() else {
                  disableSubmitButton()
                  return
              }
        enableSubmitButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        guard var phoneNumber = phoneTextField.textField.text?.replace(string: " ", replacement: ""),
        //              let cccd = cccdTextField.textField.text else { return false }
        //
        //        let characterCount = phoneNumber.count
        //        let phoneCount = (characterCount + (string == "" ? -1 : 1))
        //        let cccdCount = (cccd.count + (string == "" ? -1 : 1))
        //        //        var count = string == "" ? -1 : 1
        //
        //        if textField == phoneTextField.textField {
        //            if string == "" {
        //                phoneNumber.removeLast()
        //            }
        //            if (phoneCount == 3 || phoneCount == 6) && string != "" {
        //                phoneTextField.textField.text = (phoneTextField.textField.text ?? "") + " "
        //            }
        //            return phoneCount <= 12 // true
        //        }
        //        else if textField == cccdTextField.textField {
        //            if cccdCount % 4 == 0 && string != "" {
        //                cccdTextField.textField.text = (cccdTextField.textField.text ?? "") + (cccdCount <= 14 ? " " : "")
        //            }
        //            if cccdCount > 0 && checkInfoIsFilled() {
        //                enableSubmitButton()
        //            }
        //            else {
        //                disableSubmitButton()
        //            }
        //            if identityType != .passport {
        //                return cccdCount <= 15 // 12 + 3 space
        //            }
        //            return cccdCount <= 10 || string == ""
        //        }
        
        return true
    }
    
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
        
        let searchBar = UISearchBar(frame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    }
    
    @objc private func pickerViewValueDone() {
        if curPickerView == bankPickerView {
            selectedBank = bankPickerView.selectedRow(inComponent: 0)
            
            requestModel?.bankId = banks[selectedBank].bankId
            requestModel?.bankCode = banks[selectedBank].bankCode
            requestModel?.bankName = banks[selectedBank].bankName
            
            bankNameTextField.textField.resignFirstResponder()
            textFieldDidEndEditing(bankNameTextField.textField)
        }
        else {
            selectedRelationship = relationshipPickerView.selectedRow(inComponent: 0)
            relationshipTextField.textField.resignFirstResponder()
            textFieldDidEndEditing(relationshipTextField.textField)
        }
    }
    
    private func setupTextFields() {
        bankNameTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        bankBranchTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        holderTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        accountTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        relationshipTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        bankNameTextField.textField.delegate = self
        bankBranchTextField.textField.delegate = self
        holderTextField.textField.delegate = self
        accountTextField.textField.delegate = self
        relationshipTextField.textField.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case bankNameTextField.textField:
                bankNameTextField.hideError()
                if textField.isEmpty() {
                    bankNameTextField.showError("PLEASE_INPUT_BANK_NAME".localize())
                }
                break
            case bankBranchTextField.textField:
                bankBranchTextField.hideError()
                if textField.isEmpty() {
                    bankBranchTextField.showError("PLEASE_INPUT_BRANCH_NAME".localize())
                }
                break
            case holderTextField.textField:
                holderTextField.hideError()
                if textField.isEmpty() {
                    holderTextField.showError("PLEASE_INPUT_ACCOUNT_HOLDER".localize())
                }
                break
            case accountTextField.textField:
                accountTextField.hideError()
                if textField.isEmpty() {
                    accountTextField.showError("PLEASE_INPUT_ACCOUNT_NUMBER".localize())
                }
                break
            case relationshipTextField.textField:
                relationshipTextField.hideError()
                if textField.isEmpty() {
                    relationshipTextField.showError("PLEASE_INPUT_RELATIONSHIP".localize())
                }
                break
            default: break
        }
        
        guard !bankNameTextField.textField.isEmpty(),
              !bankBranchTextField.textField.isEmpty(),
              !holderTextField.textField.isEmpty(),
              !accountTextField.textField.isEmpty(),
              !relationshipTextField.textField.isEmpty(),
              checkInfoIsFilled()
        else {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case bankNameTextField.textField:
                textFieldIndex = 0
                self.textField = bankNameTextField.textField
                curPickerView = bankPickerView
                break
            case bankBranchTextField.textField:
                textFieldIndex = 1
                self.textField = bankBranchTextField.textField
                break
            case holderTextField.textField:
                textFieldIndex = 2
                self.textField = holderTextField.textField
                break
            case accountTextField.textField:
                textFieldIndex = 3
                self.textField = accountTextField.textField
                break
            case relationshipTextField.textField:
                textFieldIndex = 4
                self.textField = relationshipTextField.textField
                curPickerView = relationshipPickerView
                break
            default:
                break
        }
        return true
    }
    
}

// MARK: ProofViewDelegate
extension ClaimAccountViewController: ProofViewDelegate {
    func updateListTreatmentPlacesBaoMinh(list:PagedListDataRespone) {
        
    }
    

    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateUI() {
        
    }
    
    func showError(error: ApiError) {
        switch error {
            case .invalidData(let error, let optional):
                queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "IMAGE_SIZE_TO_BIG".localize(), okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                    self.hideBasePopup()
                }, handler: {})
                return
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
            default: break
        }
        
        handleAPIError(error: error)
        
    }
    
    func createClaimSuccess() {
        self.queueBasePopup2(icon: UIImage(named: "ic_check_circle"), title: "SUBMIT_REQUEST_SUCCESSFULLY".localize(), desc: UIConstants.isLoggedIn ? "YOUR_REQUEST_HAS_BEEN_LOGGED".localize() : "YOUR_REQUEST_HAS_BEEN".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "ADD_CLAIM_REQUEST".localize()) {
            self.hideBasePopup()
            UIView.animate(withDuration: 0.25, delay: 0.25) {
            } completion: { _ in
                if self.canPopToViewController(CardViewController()) {
                    self.popToViewController(CardViewController())
                }
                else {
                    self.dismiss(animated: true) {
                        let vc = CardViewController()
                        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        } handler: {
            self.popToViewController(CardClaimViewController())
        }
    }
    
    func uploadFilesSuccess(files: String) {
        requestModel?.upload = files
        guard let requestModel = requestModel, !files.isEmpty else { return }
        presenter.createClaimRequest(model: requestModel)
    }
    
    func updateListBanks(banks: [Bank]) {
        self.banks = banks
        bankPickerView.reloadAllComponents()
    }
    
    func updateListTreatmentPlaces(list: [CoSoYTeModel]) {
        
    }
}
