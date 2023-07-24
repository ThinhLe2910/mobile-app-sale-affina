//
//  InputPinCodeViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import UIKit
import LocalAuthentication

class InputPinCodeViewController: BaseViewController {

    static let nib = "InputPinCodeViewController"

    @IBOutlet weak var pinTextField: OneTimeCodeTextField!

    @IBOutlet weak var forgotPinCode: BaseLabel!
    @IBOutlet weak var errorLabel: BaseLabel!

    @IBOutlet weak var buttonBottomKeyboardConstraint: NSLayoutConstraint!

    // MARK:
    private lazy var presenter: InputPinCodeViewPresenter = InputPinCodeViewPresenter()

    private var model: ProfileRegisterModel?
    private var pinCode: String = ""

    var loginCallback: (() -> Void)?
    
    var isRegistering: Bool = false
    var isLoggingIn: Bool = false

    // MARK: Biometric
    private let biometry = BiometryAuth()
    private var biometricType: LAContext.BiometricType = .none {
        didSet {
            guard biometricType != .none && UserDefaults.standard.bool(forKey: Key.biometricAuth.rawValue) else {
                return
            }
//            if #available(iOS 15.0, *) {
//                biometricButton.configuration?.image = UIImage(named: biometricType.rawValue)
//                biometricButton.configuration?.imagePadding = 12
//                if biometricType == .touchID {
//                    biometricButton.configuration?.imagePadding = 12
//                    biometricButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3)
//                }
//            } else {
//                // Fallback on earlier versions
//                biometricButton.setImage(UIImage(named: biometricType.rawValue), for: .normal)
//                if biometricType == .faceID {
//                    biometricButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
//                }
//                else if biometricType == .touchID {
//                    biometricButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
//                }
//            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.appColor(.blueUltraLighter)

        containerBaseView.hide()
        hideHeaderBase()

//        disableSubmitButton()

        pinTextField.isSecureTextEntry = true
        pinTextField.configure()
        pinTextField.otpDelegate = self

        forgotPinCode.addUnderline()

        biometry.delegate = self

        forgotPinCode.addTapGestureRecognizer {
            self.didTapForgotButton()
        }

        presenter.setViewDelegate(delegate: self)

        
        pinTextField.becomeFirstResponder()
        
        hideErrorLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(crashedAlert), name: Notification.Name(rawValue: Key.crashedNotificationKey.rawValue), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIConstants.requireLogin = false
        presenter.checkBannedAccount()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: Key.crashedNotificationKey.rawValue), object: nil)
    }

    @objc private func crashedAlert() {
        pinTextField.resignFirstResponder()
    }
    
    func setModel(model: ProfileRegisterModel) {
        self.model = model
    }

    @objc override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            buttonBottomKeyboardConstraint.constant = keyboardSize.height + 48 //16
        }
    }

    @objc override func keyboardWillHide(notification: NSNotification) {
        buttonBottomKeyboardConstraint.constant = 24
    }


    @objc private func didTapSubmitButton() {
        guard let password = pinTextField.text, !password.isEmpty, !isLoggingIn else {
            pinTextField.error()
//            showErrorPassword(type: .empty)
            return
        }
        isLoggingIn = true
        presenter.handleSubmitPassword(password: password, isUsingBiometric: false)
    }

    @objc private func didTapForgotButton() {
        let vc = OtpViewController()
        vc.isRegistering = false
        navigationController?.pushViewController(vc, animated: true)
    }

    override func hideErrorLabel() {
        errorLabel.hide()
    }
}

extension InputPinCodeViewController: OTPSubmitViewDelegate {
    func textDidEndEditing() {
        disableViews()
    }

    func textDidBeginEditing() {
//        enableViews()
//        hideErrorLabel()
    }

    func textDidChange(text: String) {
        if !text.isEmpty {
            hideErrorLabel()
        }
        if text.count >= 6 {
//            didTapSubmitButton()
        }
    }

    func didEnterLastDigit(string: String) {
//        enableViews()
        didTapSubmitButton()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}

// MARK: BiometryAuthDelegate
extension InputPinCodeViewController: BiometryAuthDelegate {
    func authFail(error: Error?) {
        Logger.Logs(message: "AUTH FAIL")
        isLoggingIn = false
        guard let error = error else {
            return
        }

//        let context = LAContext()
        switch error._code {
        case LAError.authenticationFailed.rawValue:
//            let typeString = context.biometricType == .faceID ? "FACEID".localize() : "TOUCHID".localize()
//            showCustomOKAlert(title: "ERROR_FAILURE_LOGIN".localize(), titleColor: AssetsColor.redError.toUIColor(), iconString: "ic_close", iconSize: 40, iconPadding: UIPadding.size32, message: "\(typeString) \("ERROR_BIOMETRIC_NOT_MATCH".localize())", buttonString: "CLOSE".localize(), padding: UIPadding.size32) {
//
//            }
            break
        case LAError.userCancel.rawValue:
            break
        default:
//            let typeString = context.biometricType == .faceID ? "FACEID".localize() : "TOUCHID".localize()
//            showCustomOKAlert(title: "ERROR_FAILURE_LOGIN".localize(), titleColor: AssetsColor.redError.toUIColor(), iconString: "ic_close", iconSize: 40, iconPadding: UIPadding.size32, message: "\(typeString) \("ERROR_BIOMETRIC_NOT_MATCH".localize())", buttonString: "CLOSE".localize(), padding: UIPadding.size32) {
//            }
            break
        }
    }

    func authSuccessful() {
        Logger.Logs(message: "AUTH SUCCESSFUL")
        UserDefaults.standard.set(false, forKey: "hideTabBar")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideTabBar"), object: self)
        isLoggingIn = true
        presenter.handleSubmitPassword(password: "", isUsingBiometric: true)
    }

    func deviceNotSupport() {
    }

}

extension InputPinCodeViewController: InputPinCodeViewDelegate {
    func lockUI() {
        lockScreen()
    }

    func unlockUI() {
        unlockScreen()
    }

    func showErrorPassword(type: PasswordError) {
        isLoggingIn = false
        pinTextField.clear()
        switch type {
        case .empty:
            break
        case .invalid:
            errorLabel.show()
            errorLabel.text = "ERROR_VALID".localize()
            break
        case .incorrect:
            errorLabel.show()
            errorLabel.text = "ERROR_PIN_NOT_CORRECT".localize()
            break
        case .error:
            errorLabel.show()
            errorLabel.text = "ERROR_COMMON".localize()
            break
        case .expired:
            errorLabel.show()
            errorLabel.text = "ERROR_EXPIRED".localize()
            break
        case .accountBlocked:
            errorLabel.show()
            errorLabel.text = "ACCOUNT_HAVE_BEEN_BLOCKED".localize()
            
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ACCOUNT_HAVE_BEEN_BLOCKED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                self.hideBasePopup()
                self.accountBanned(isBanned: true)
            } handler: {
                
            }
        }
    }

    func authSuccessfully() {
        UIConstants.isLoggedIn = true
        
        if !UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue) {
            dismiss(animated: true)
        }
        else {
            showHomeScreen()
        }
        
        loginCallback?()
    }

    func accountBanned(isBanned: Bool) {
        if isBanned {
            logOut()
            showHomeScreen()
        }
        else {
            if UserDefaults.standard.bool(forKey: Key.biometricAuth.rawValue) {
                biometry.authWithBiometry(isLogin: true)
            }

        }
    }
    
    func showHomeScreen() {
        // Check to create BaseTabBarViewController
        if !UIConstants.isInitHomeView {
            UIConstants.isInitHomeView = true
            let nav = UINavigationController(rootViewController: BaseTabBarViewController())
            nav.isNavigationBarHidden = true
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
            nav.view.backgroundColor = .clear
            kAppDelegate.window?.rootViewController = nav
            kAppDelegate.window?.makeKeyAndVisible()
        }
        else {
            if AppStateManager.shared.isOpeningNotificationDetail {
               popToViewController(NotificationDetailViewController())
            }
            else {
                dismiss(animated: true)
            }
        }
    }
}
