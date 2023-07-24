//
//  WelcomeViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 04/07/2022.
//

import UIKit

class WelcomeViewController: BaseViewController {

    static let nib = "WelcomeViewController"

    @IBOutlet weak var closeButton: BaseButton!
    @IBOutlet weak var labelTextField: BaseLabel!
    @IBOutlet weak var errorLabel: BaseLabel!
    @IBOutlet weak var phoneTextField: TextFieldAnimBase!
    @IBOutlet weak var continueButton: BaseButton!
    @IBOutlet weak var buttonBottomKeyboardConstraint: NSLayoutConstraint!

    var loginCallback: (() -> Void)?
    
    private let presenter: WelcomeViewPresenter = WelcomeViewPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()

        hideHeaderBase()
        containerBaseView.hide()

        disableSubmitButton()

        presenter.setViewDelegate(delegate: self)

        labelTextField.localizeText = "PHONE".localize().uppercased()
        phoneTextField.delegate = self
        phoneTextField.borderStyle = .none
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "12 345 6789", attributes: [NSAttributedString.Key.foregroundColor: UIColor.appColor(.blueSlider) ?? .black])
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phoneTextField.becomeFirstResponder()
        
        UIConstants.requireLogin = false
    }

    override func keyboardWillHide(notification: NSNotification) {
        buttonBottomKeyboardConstraint.constant = 24
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            buttonBottomKeyboardConstraint.constant = keyboardSize.height + 16
        }
    }

    @objc private func didTapCloseButton() {
        if AppStateManager.shared.isOpeningNotification {
            popViewController()
            return
        }
        dismiss(animated: true)
    }

    @objc private func didTapContinueButton() {
        errorLabel.isHidden = true
        phoneTextField.resignFirstResponder()
        guard let phoneNumber = phoneTextField.text?.replace(string: " ", replacement: "") else { return }
        if !Validation.isValidPhoneNumber(phone: parsePhoneNumber(phoneNumber: phoneNumber)) {
            showErrorPhone(type: .invalid)
            return
        }
        presenter.handleSubmitPhone(phoneNumber: parsePhoneNumber(phoneNumber: phoneNumber))
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard !phoneTextField.isEmpty(), let phone = phoneTextField.text, isValidPhoneNumber(phoneNumber: parsePhoneNumber(phoneNumber: phone)) else {
                  disableSubmitButton()
                  return
              }
        enableSubmitButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        errorLabel.isHidden = true
        guard var phoneNumber = textField.text?.replace(string: " ", replacement: "") else { return false }
        let characterCount = phoneNumber.count
        let count = (characterCount + (string == "" ? -1 : 1))
        if string == "" {
            phoneNumber.removeLast()
        }
        if count >= 9 && isValidPhoneNumber(phoneNumber: phoneNumber + string) {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }

        if (count == 3 || count == 6) && string != "" {
            phoneTextField.text = (phoneTextField.text?.trimmingWhiteSpaces() ?? "") + " "
        }

        return count <= 12

    }

    private func enableSubmitButton() {
        continueButton.isUserInteractionEnabled = true
        continueButton.backgroundColor = .appColor(.pinkMain)
        continueButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        continueButton.dropShadow(color: UIColor.appColor(.pinkLong) ?? UIColor(hex: "FF52DB"), opacity: 0.25, offset: .init(width: 0, height: 8), radius: 16, scale: true)
    }

    private func disableSubmitButton() {
        continueButton.isUserInteractionEnabled = false
        continueButton.backgroundColor = .appColor(.pinkUltraLighter)
        continueButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        continueButton.clearShadow()
    }

    func parsePhoneNumber(phoneNumber: String) -> String {
        if phoneNumber.isEmpty { return "" }
        let firstNumber = phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 0)]
        let phone = (firstNumber == "0" ? "" : "0") + (phoneNumber.replace(string: " ", replacement: ""))
        return phone
    }
    
    func isValidPhoneNumber(phoneNumber: String) -> Bool {
        let firstNumber = phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 0)]
        if firstNumber == "0" && phoneNumber.count < 10 { return false }
        return true
    }
}

extension WelcomeViewController: WelcomeViewDelegate {
    func lockUI() {
        lockScreen()
    }

    func unlockUI() {
        unlockScreen()
    }

    func showErrorPhone(type: PasswordError) {
//        phoneTextField.errorStatus()
        switch type {
        case .empty:
//            errorLabel.show()
//            errorLabel.text = "ERROR_EMPTY_PHONE_NUMBER".localize()
            break
        case .invalid:
            errorLabel.isHidden = false
            errorLabel.text = "ERROR_VALID".localize()
            break
        case .incorrect:
            break
        case .error:
//            errorLabel.show()
//            errorLabel.text = "ERROR_COMMON".localize()
            break
        case .expired:
            break
        case .accountBlocked:
//            errorLabel.show()
//            errorLabel.text = "ACCOUNT_HAVE_BEEN_BLOCKED".localize()
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ACCOUNT_HAVE_BEEN_BLOCKED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                self.hideBasePopup()
            } handler: {
                
            }
            break
        }
    }

    func goToRegister() {
        guard let phone = phoneTextField.text else { return }
        let vc = OtpViewController(nibName: OtpViewController.nib, bundle: nil)
        vc.phoneNumber = parsePhoneNumber(phoneNumber: phone)
        vc.isRegistering = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func goToLogin() {
        let vc = InputPinCodeViewController()
        vc.loginCallback = loginCallback
        navigationController?.pushViewController(vc, animated: true)
    }

    func authSuccessfully() {

    }
}
