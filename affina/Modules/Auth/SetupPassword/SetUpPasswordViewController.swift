//
//  SetUpPasswordViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/05/2022.
//

import UIKit
import LocalAuthentication

class SetUpPasswordViewController: BaseViewController {
    
    @IBOutlet weak var errorLabel: BaseLabel!
    
    @IBOutlet weak var pinTextField: OneTimeCodeTextField!
    
    @IBOutlet weak var descLabel: BaseLabel!
    
    @IBOutlet weak var backButton: BaseButton!
    
    // MARK:
    private lazy var presenter: SetUpPasswordViewPresenter = SetUpPasswordViewPresenter()
    
    private var model: ProfileRegisterModel?
    private var pinCode: String = ""
    
    var isRegistering: Bool = false
    
    var tokenRegister: String = ""
    
    // MARK: Biometric
    private let biometry = BiometryAuth()
    private var biometricType: LAContext.BiometricType = .none
    
    private var iconBiometric: UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.appColor(.blueUltraLighter)
        
        containerBaseView.hide()
        hideHeaderBase()
        
        pinTextField.isSecureTextEntry = true
        pinTextField.configure()
        pinTextField.otpDelegate = self
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        presenter.setViewDelegate(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pinTextField.becomeFirstResponder()
    }
    
    func setModel(model: ProfileRegisterModel) {
        self.model = model
    }
    
    @objc private func didTapSubmitButton() {
        pinTextField.resignFirstResponder()
        guard let password = pinTextField.text, !password.isEmpty else {
            pinTextField.error()
            //            showErrorPassword(type: .empty)
            return
        }
        
        if password.count != 6 {
            //            showErrorOtp(type: .invalid)
            return
        }
        
        // Encrypt md5 -> rsa
        let md5Hashed = HashString.encryptWithMD5(message: password).map { String(format: "%02hhx", $0) }.joined()
        guard let rsaHashed = HashString.encryptWithRsa(message: md5Hashed) else {
            Logger.Logs(event: .error, message: "Hashed Error")
            return
        }
        if !tokenRegister.isEmpty {
            let body: [String: String] = [
                "token": tokenRegister,
                "password": rsaHashed
            ]
            presenter.setupPasswordAfterCreateContract(body: body)
            return
        }
        if isRegistering {
            model?.password = rsaHashed
            guard let model = model else {
                return
            }
            presenter.setupPassword(model: model)
        }
        else {
            presenter.submitNewPassword(password: rsaHashed, token: UserDefaults.standard.string(forKey: Key.token.rawValue) ?? "")
        }
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    //    override func textFieldDidEndEditing(_ textField: UITextField) {
    //        if let text = pinTextField.text, text.count >= 6 {
    //        }
    //        else {
    //        }
    //    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

extension SetUpPasswordViewController: SetupPasswordViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func showErrorPassword(type: PasswordError) {
        //        pinTextField.errorStatus()
        switch type {
        case .expired:
            errorLabel.show()
            errorLabel.text = "ERROR_OTP_EXPIRED".localize()
            break
        case .invalid:
            errorLabel.show()
            errorLabel.text = "ERROR_VALID".localize()
            break
        case .empty:
            break
        case .error:
            errorLabel.show()
            errorLabel.text = "ERROR_COMMON".localize()
            break
        case .incorrect:
            break
        case .accountBlocked:
            errorLabel.show()
            errorLabel.text = "ERROR_ACCOUNT_BLOCK".localize()
            break
        }
    }
    
    func showAlert() {
        
    }
    
    func updateUI() {
    }
    
    func updateSuccessful() {
        UIConstants.isLoggedIn = true
        let nav = UINavigationController(rootViewController: BaseTabBarViewController())
        nav.isNavigationBarHidden = true
        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.isTranslucent = true
        nav.view.backgroundColor = .clear
        kAppDelegate.window?.rootViewController = nav
        kAppDelegate.window?.makeKeyAndVisible()
    }
    
    func setupSuccessful() {
        let context = LAContext()
        biometricType = context.biometricType
        
        guard biometricType != .none else {
            UIConstants.isLoggedIn = true
            UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
            dismiss(animated: true, completion: nil)
            return
        }
        biometry.delegate = self
        
        let typeStr = biometricType == .faceID ? "Face ID" : "Touch ID"
        queueBasePopup(icon: UIImage(named: biometricType.rawValue.lowercased()), title: "\("USE".localize()) \(typeStr)", desc: "ALLOW_APP_TO_USE".localize().replace(string: "@", replacement: typeStr), okTitle: "AGREE".localize(), cancelTitle: "NONE".localize(), okHandler: {
            self.biometry.authWithBiometry()
        }, handler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIConstants.isLoggedIn = true
                UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func setupSuccessfulAfterCreateContract() {
        let context = LAContext()
        biometricType = context.biometricType
        
        guard biometricType != .none else {
            UIConstants.isLoggedIn = true
            UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
            dismiss(animated: true, completion: nil)
            return
        }
        biometry.delegate = self
        
        let typeStr = biometricType == .faceID ? "Face ID" : "Touch ID"
        queueBasePopup(icon: UIImage(named:  biometricType.rawValue.lowercased()), title: "\("USE".localize()) \(typeStr)", desc: "ALLOW_APP_TO_USE".localize().replace(string: "@", replacement: typeStr), okTitle: "AGREE".localize(), cancelTitle: "NONE".localize(), okHandler: {
            self.biometry.authWithBiometry()
        }, handler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIConstants.isLoggedIn = true
                UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}

extension SetUpPasswordViewController: OTPSubmitViewDelegate {
    func textDidEndEditing() {
        disableViews()
    }
    
    func textDidBeginEditing() {
    }
    
    func textDidChange(text: String) {
        if !pinCode.isEmpty && (pinTextField.text ?? "").count >= 6 && pinCode != pinTextField.text {
            errorLabel.show()
            errorLabel.text = "ERROR_PIN_NOT_MATCH".localize()
        }
        else {
            errorLabel.hide(isImmediate: true)
        }
        
        if text.count < 6 {
        }
    }
    
    func didEnterLastDigit(string: String) {
        //        enableViews()
        if !pinCode.isEmpty && pinCode == pinTextField.text {
            didTapSubmitButton()
            return
        }
        if pinCode.isEmpty {
            pinCode = pinTextField.text ?? ""
            descLabel.text = "CONFIRM_PIN_CODE".localize()
            pinTextField.clear()
        }
    }
}

// MARK: BiometryAuthDelegate
extension SetUpPasswordViewController: BiometryAuthDelegate {
    func authFail(error: Error?) {
        Logger.Logs(message: "AUTH FAIL")
        guard let error = error else {
            return
        }
        Logger.Logs(event: .error, message: error.localizedDescription)
        switch error._code {
        case LAError.authenticationFailed.rawValue:
            break
        case LAError.userCancel.rawValue:
            break
        default:
            break
        }
    }
    
    func authSuccessful() {
        Logger.Logs(message: "AUTH SUCCESSFUL")
        UserDefaults.standard.set(true, forKey: Key.biometricAuth.rawValue)
        
        UIConstants.isLoggedIn = true
        dismiss(animated: true, completion: nil)
    }
    
    func deviceNotSupport() {
    }
    
}
