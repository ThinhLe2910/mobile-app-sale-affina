//
//  ProofDeathViewController.swift
//  affina
//
//  Created by Dylan on 26/09/2022.
//

import UIKit

class ProofDeathViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var insuredNameTextField: TitleTextFieldBase!
    @IBOutlet weak var contactNameTextField: TitleTextFieldBase!
    @IBOutlet weak var phoneTextField: TitleTextFieldBase!
    @IBOutlet weak var emailTextField: TitleTextFieldBase!
    @IBOutlet weak var checkBoxButton: BaseButton!
    @IBOutlet weak var submitButton: BaseButton!
    
    @IBOutlet weak var buttonBottomKeyboardConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    private var textField: TextFieldAnimBase!
    private var textFieldIndex = -1
    
    private var isAgree: Bool = false
    var type: ClaimType = .DEAD
    var requestModel: ClaimRequestModel?
    
    var cardModel: CardModel?
    
    private let presenter: ProofViewPresenter = ProofViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBlurStatusBar()
        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        setupTextFields()
        
        setupLeftViewPhoneTextField()
        
        
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
        
        insuredNameTextField.textField.text = cardModel?.peopleName
        insuredNameTextField.textField.disable()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
    
    @objc private func didTapButton(_ sender: BaseButton) {
        if textField != nil {
            textField.resignFirstResponder()
        }
        switch sender {
            case backButton:
                queueBasePopup2(icon: UIImage(named: "ic_warning"), title: "YOUR_PROFILE_WILL_NOT".localize(), desc: "YOUR_INFORMATION_WILL_NOT".localize(), okTitle: "STAY".localize(), cancelTitle: "EXIT".localize()) {
                    self.hideBasePopup()
                } handler: {
                    self.popViewController()
                }
                
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
//                requestModel?.bankBranch = bankBranchTextField.textField.text
//                requestModel?.bankCode = "101" // bankNameTextField.textField.text
//                requestModel?.relationship = selectedRelationship
//                requestModel?.accountNumberBank = accountTextField.textField.text
//                requestModel?.accountName = holderTextField.textField.text
                
                requestModel?.name = contactNameTextField.text
                requestModel?.phone = phoneTextField.text
                requestModel?.email = emailTextField.text

                guard let model = requestModel else { return }
                Logger.Logs(message: model)
                
                presenter.createClaimRequest(model: model)
                break
            default: break
        }
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
        let insuredName = insuredNameTextField.textField.count
        let contactName = contactNameTextField.textField.count
        let phoneCount = phoneTextField.textField.count
        let emailCount = emailTextField.textField.count
        
        guard let phone = phoneTextField.textField.text, let email = emailTextField.textField.text else { return false }
        
        return insuredName > 0 && contactName > 0 && phoneCount > 0 && emailCount > 0 && isValidPhoneNumber(phoneNumber: parsePhoneNumber(phoneNumber: phone)) && Validation.isValidEmail(email: email) && isAgree
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard !insuredNameTextField.textField.isEmpty(),
              !contactNameTextField.textField.isEmpty(),
              !phoneTextField.textField.isEmpty(),
              !emailTextField.textField.isEmpty(),
              checkInfoIsFilled() else {
                  disableSubmitButton()
                  return
              }
        enableSubmitButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var phoneNumber = phoneTextField.textField.text?.replace(string: " ", replacement: "")
        else { return false }
        
        let characterCount = phoneNumber.count
        let phoneCount = (characterCount + (string == "" ? -1 : 1))
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
        
        return true
    }
    
    private func setupTextFields() {
        insuredNameTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        contactNameTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        phoneTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        emailTextField.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        insuredNameTextField.textField.delegate = self
        contactNameTextField.textField.delegate = self
        phoneTextField.textField.delegate = self
        phoneTextField.textField.keyboardType = .numberPad
        emailTextField.textField.delegate = self
        emailTextField.textField.keyboardType = .emailAddress
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
            case insuredNameTextField.textField:
                insuredNameTextField.hideError()
                if textField.isEmpty() {
                    insuredNameTextField.showError("PLEASE_INPUT_INSURED_NAME".localize())
                }
                break
            case contactNameTextField.textField:
                contactNameTextField.hideError()
                if textField.isEmpty() {
                    contactNameTextField.showError("PLEASE_INPUT_CONTACT_NAME".localize())
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
            case emailTextField.textField:
                emailTextField.hideError()
                if textField.isEmpty() {
                    emailTextField.showError("PLEASE_INPUT_EMAIL".localize())
                }
                else if !Validation.isValidEmail(email: textField.text ?? "") {
                    emailTextField.showError("PLEASE_INPUT_VALID_EMAIL".localize())
                }
                break
            default: break
        }
        
        guard !contactNameTextField.textField.isEmpty(),
              !insuredNameTextField.textField.isEmpty(),
              !phoneTextField.textField.isEmpty(),
              !emailTextField.textField.isEmpty(),
              checkInfoIsFilled()
        else {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
            case contactNameTextField.textField:
                textFieldIndex = 0
                self.textField = contactNameTextField.textField
                break
            case insuredNameTextField.textField:
                textFieldIndex = 1
                self.textField = insuredNameTextField.textField
                break
            case phoneTextField.textField:
                textFieldIndex = 2
                self.textField = phoneTextField.textField
                break
            case emailTextField.textField:
                textFieldIndex = 3
                self.textField = emailTextField.textField
                break
            default:
                break
        }
        
        return true
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
    
}

// MARK: ProofViewDelegateb
extension ProofDeathViewController: ProofViewDelegate {
    func updateListTreatmentPlacesBaoMinh(list: PagedListDataRespone) {
        
    }

    
    func updateUI() {
        
    }
    
    func showError(error: ApiError) {
        handleAPIError(error: error)
    }
    
    func updateListTreatmentPlaces(list: [CoSoYTeModel]) {
        
    }
    
    func uploadFilesSuccess(files: String) {
        
    }
    
    func createClaimSuccess() {
        
        self.queueBasePopup2(icon: UIImage(named: "ic_check_circle"), title: "SUBMIT_REQUEST_SUCCESSFULLY".localize(), desc: "AFFINA_HAS_RECEIVED_YOUR".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "ADD_CLAIM_REQUEST".localize()) {
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
    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
}
