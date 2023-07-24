//
//  InsuranceOtpViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 30/08/2022.
//

import UIKit
import SnapKit

class InsuranceOtpViewController: BaseViewController {
    static let nib = "InsuranceOtpViewController"

    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var otpTextField: OneTimeCodeTextField!

    @IBOutlet weak var noteLabel: BaseLabel!
    @IBOutlet weak var sendAgainLabel: BaseLabel!

    @IBOutlet weak var submitButton: BaseButton!
    @IBOutlet weak var backButton: BaseButton!

    @IBOutlet weak var buttonBottomKeyboardConstraint: NSLayoutConstraint!

    private lazy var presenter: InsuranceOtpViewPresenter = InsuranceOtpViewPresenter()

    // MARK: Timer
    private var defaultSec = 60
    private var countDownSec = 60
    private var timer: Timer?

    var isError: Bool = false
    var phoneNumber: String = ""
    private var otpKey = ""

    var productDetail: ProductDetailModel?
    var selectedSides: [Int] = []
    var paymentInfoModel: PaymentContractPeopleInfoRequestModel?
    var otpData: OtpResponseData?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.appColor(.blueUltraLighter)

        containerBaseView.hide()
        hideHeaderBase()

        disableSubmitButton()

        otpTextField.configure()
        otpTextField.otpDelegate = self

        // Init timer
        setCountDownText()
        UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: Key.lastOtpTime.rawValue)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownOTP), userInfo: nil, repeats: true)

        // Tap & action
        sendAgainLabel.addTapGestureRecognizer {
            if self.countDownSec >= 0 {
                return
            }
            
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: Key.lastOtpTime.rawValue)

            self.sendAgainLabel.removeUnderline()
            self.countDownSec = self.defaultSec
            self.setCountDownText()
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownOTP), userInfo: nil, repeats: true)
            self.presenter.resendOtp(otpKey: self.otpKey)
        }
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        presenter.setViewDelegate(delegate: self)
        
        noteLabel.text = "DESC_OTP_REGISTER".localize()

        guard let otpData = otpData else {
            return
        }
        updateOtpKey(otpKey: otpData.otpKey, type: otpData.via, contact: otpData.contact, time: otpData.timeCodeExpire / 1000)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isError {
            otpTextField.becomeFirstResponder()
        }
        
    }

    @objc override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                buttonBottomKeyboardConstraint.constant = keyboardSize.height + 8
//                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc override func keyboardWillHide(notification: NSNotification) {
        buttonBottomKeyboardConstraint.constant = 24
        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
        }
    }

    @objc private func countDownOTP() {
        if UIConstants.isFromBackground {
            UIConstants.isFromBackground = false
            let currentTime = Date().timeIntervalSince1970
            let startTime = UserDefaults.standard.double(forKey: Key.lastOtpTime.rawValue)
            countDownSec = defaultSec - Int(currentTime - startTime) + 1
            
        }
        if countDownSec <= 0 {
            countDownSec -= 1
            sendAgainLabel.text = "SEND_OTP_CODE_AGAIN".localize()
            sendAgainLabel.addUnderline()
            timer?.invalidate()
            return
        }
        countDownSec -= 1
        setCountDownText()
    }

    private func setCountDownText() {
        if countDownSec == 0 {
            sendAgainLabel.text = "SEND_OTP_CODE_AGAIN".localize()
            sendAgainLabel.addUnderline()
        }
        else {
            sendAgainLabel.text = secondsToMinutesSeconds(countDownSec) // "\(countDownSec)s"
        }
    }

    @objc private func didTapSubmitButton() {
        otpTextField.resignFirstResponder()
        guard let text = otpTextField.text, !text.isEmpty else {
            otpTextField.error()
            return
        }
        if text.count != 6 {
            showErrorOtp(type: .invalid)
            return
        }
        let otpModel = OtpModel(otpKey: otpKey, code: text)
        presenter.submitOtp(otp: otpModel)
    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }

    private func enableSubmitButton() {
        submitButton.isUserInteractionEnabled = true
        submitButton.backgroundColor = .appColor(.pinkMain)
        submitButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        submitButton.dropShadow(color: UIColor.appColor(.pinkLong) ?? UIColor(hex: "FF52DB"), opacity: 0.25, offset: .init(width: 0, height: 8), radius: 16, scale: true)
    }
    private func disableSubmitButton() {
        submitButton.isUserInteractionEnabled = false
        submitButton.backgroundColor = .appColor(.pinkUltraLighter)
        submitButton.setTitleColor(.appColor(.whiteMain), for: .normal)
        submitButton.clearShadow()
    }

    override func enableViews() {
        super.enableViews()
        enableSubmitButton()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != sendAgainLabel {
            view.endEditing(true)
        }
    }
    
    func secondsToMinutesSeconds(_ seconds: Int) -> String {
//        if seconds <= 60 {
//            return "\((seconds % 3600) % 60)s"
//        }
        let min = (seconds % 3600) / 60
        let sec = (seconds % 3600) % 60
        return "\(min < 10 ? "0\(min)" : "\(min)"):\(sec < 10 ? "0\(sec)" : "\(sec)")"
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
            dismiss(animated: true)
        }
    }
}

extension InsuranceOtpViewController: InsuranceOtpViewDelegate {
    func lockUI() {
        lockScreen()
    }

    func unlockUI() {
        unlockScreen()
    }

    func showErrorOtp(type: OtpError) {
        otpTextField.error()
        isError = true
        switch type {
        case .empty:
            break
        case .invalid:
            errorLabel.show()
            errorLabel.text = "ERROR_VALID".localize()
            break
        case .expired:
            errorLabel.show()
            errorLabel.text = "ERROR_OTP_EXPIRED".localize()
            break
        case .unmatch:
            errorLabel.show()
            errorLabel.text = "ERROR_OTP_NOT_MATCH".localize()
            break
        case .failed:
            break
        case .wrongManyTime:
            break
        case .requestLimited:
            otpTextField.resignFirstResponder()
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_ACCOUNT_BLOCK".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                self.hideBasePopup()
                self.navigationController?.popToRootViewController(animated: true)
            } handler: {
                
            }

            break
        case .blocked:
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ACCOUNT_HAVE_BEEN_BLOCKED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                self.hideBasePopup()
                self.logOut()
                self.showHomeScreen()
            } handler: {
                
            }
        case .error:
            errorLabel.show()
            errorLabel.text = "ERROR_COMMON".localize()
            break
        }
    }

    func showAlert() {
    }

    // MARK: OTP is correct
    func authSuccessful(contract: InsuranceContractModel) {
        let vc = InsurancePaymentViewController()
        vc.contractModel = contract
        vc.paymentInfoModel = paymentInfoModel
        vc.productDetail = self.productDetail
        vc.selectedSides = self.selectedSides
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Add otp key
    func updateOtpKey(otpKey: String, type: Int, contact: String, time: Double) {
        guard !otpKey.isEmpty else {
            showErrorOtp(type: .error)
            return
        }
        self.otpKey = otpKey
        
        self.defaultSec = Int(time)
        self.countDownSec = Int(time)
        
        guard type != -1, !contact.isEmpty else { return }
        let arr = "WE_SEND_OTP_TO_UR_CONTACT".localize().split(separator: "@")
        for i in 0..<arr.count {
            if i == 1 {
                noteLabel.text! += (type == 1 ? " \("EMAIL_ADDRESS".localize().lowercased()) " : " \("PHONE".localize().lowercased()) ") + "\(contact) \(String(arr[i]))"
            }
            else {
                noteLabel.text! = String(arr[i])
            }
        }
    }
    
}

extension InsuranceOtpViewController: OTPSubmitViewDelegate {
    func textDidEndEditing() {
        disableViews()
    }

    func textDidBeginEditing() {
//        enableViews()
        hideErrorLabel()
        isError = false
    }

    func textDidChange(text: String) {
        if text.count < 6 {
//            submitButton.disable()
            disableSubmitButton()
        }
    }

    func didEnterLastDigit(string: String) {
        enableViews()
    }
}
