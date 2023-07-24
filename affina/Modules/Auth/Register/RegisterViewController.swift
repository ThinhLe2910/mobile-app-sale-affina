//
//  RegisterViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/06/2022.
//

import UIKit

class RegisterViewController: BaseViewController {

    static let nib = "RegisterViewController"

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: BaseView!

    @IBOutlet weak var checkBoxButton: BaseButton!
    @IBOutlet weak var fullNameTextField: TitleTextFieldBase!
    @IBOutlet weak var dobTextField: TitleTextFieldBase!
    var datePickerView: UIDatePicker = UIDatePicker()
    @IBOutlet weak var emailTextField: TitleTextFieldBase!

    @IBOutlet weak var termRegisterLabel: BaseLabel!
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var maleButton: BaseButton!
    @IBOutlet weak var femaleButton: BaseButton!
    @IBOutlet weak var submitButton: BaseButton!
    @IBOutlet weak var agreeButton: BaseButton!
    @IBOutlet weak var termPrivacyLabel: BaseLabel!
//    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!

    private var textField: TextFieldAnimBase?
    private var textFieldIndex: CGFloat = 0
    private var isAgree: Bool = false
    private var isAgree1: Bool = false
    private var isMale: Bool = true
    private var token: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        hideHeaderBase()
        containerBaseView.hide()

        view.backgroundColor = UIColor.appColor(.blueUltraLighter)
        scrollView.backgroundColor = UIColor.appColor(.blueUltraLighter)

        contentView.addTapGestureRecognizer {
            self.fullNameTextField.textField.resignFirstResponder()
            self.dobTextField.textField.resignFirstResponder()
            self.emailTextField.textField.resignFirstResponder()
        }

        termPrivacyLabel.attributedText = getAttributedString(
            arrayTexts: ["I_AGREE".localize(), "TERMS".localize(), "AND".localize(), "PRIVACY".localize(), "OUR".localize()],
            arrayColors: [UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!, UIColor.appColor(.black)!],
            arrayFonts: [termPrivacyLabel.font, UIConstants.Fonts.appFont(.Bold, 14), termPrivacyLabel.font, UIConstants.Fonts.appFont(.Bold, 14), termPrivacyLabel.font],
            arrayUnderlines: [false, true, false, true, false]
        )
        termRegisterLabel.attributedText =
        getAttributedString(arrayTexts: ["I_AGREE_WITH_THE_TERMS_OF".localize(),"AFFINA'S_INFORMATION_EXPLOITATION.".localize()],
                            arrayColors: [UIColor.appColor(.black)!, UIColor.appColor(.black)!],
                            arrayFonts: [termRegisterLabel.font,UIConstants.Fonts.appFont(.Bold, 14)],
                            arrayUnderlines: [false, true])
        
        termRegisterLabel.isUserInteractionEnabled = true
        termPrivacyLabel.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNoteLabel))
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTapNoteLabel))
        termPrivacyLabel.addGestureRecognizer(tap)
        termRegisterLabel.addGestureRecognizer(tap1)
        fullNameTextField.textField.delegate = self
        dobTextField.textField.delegate = self
        emailTextField.textField.delegate = self
        emailTextField.textField.keyboardType = .emailAddress
        setupDatePicker()

        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        agreeButton.addTarget(self, action: #selector(didTapAgreeButton(_:)), for: .touchUpInside)
        checkBoxButton.addTarget(self, action: #selector(didTapAgreeButton(_:)), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(didTapGenderButton(_:)), for: .touchUpInside)

        disableSubmitButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    override func keyboardWillHide(notification: NSNotification) {
        scrollViewBottomConstraint.constant = 0
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollViewBottomConstraint.constant = keyboardSize.height
            let yOffset = (textField?.convert(textField?.frame.origin ?? .zero, to: contentView).y ?? 0)
            scrollView.setContentOffset(.init(x: 0, y: yOffset - keyboardSize.height + (textFieldIndex == 2 ? 0 : 74)), animated: true)
        }
    }

    @objc private func didTapNoteLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = termPrivacyLabel.text, let text1 = termRegisterLabel.text else { return }
        let termsRange = (text as NSString).range(of: "TERMS".localize())
        let privacyRange = (text as NSString).range(of: "PRIVACY".localize())
        let registerRange = (text1 as NSString).range(of: "AFFINA'S_INFORMATION_EXPLOITATION.".localize())
        if gesture.didTapAttributedTextInLabel(label: termPrivacyLabel, targetRange: termsRange) {
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/dieu-khoan-kieu-kien")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if gesture.didTapAttributedTextInLabel(label: termPrivacyLabel, targetRange: privacyRange) {
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/chinh-sach-bao-mat")
            self.navigationController?.pushViewController(vc, animated: true)
        }else if gesture.didTapAttributedTextInLabel(label: termRegisterLabel, targetRange: registerRange){
            print(123)
            let vc = WebViewController()
            vc.setUrl(url: "https://affina.com.vn/dieu-khoan-khai-thac-thong-tin")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc private func didTapSubmitButton() {
        fullNameTextField.textField.resignFirstResponder()
        dobTextField.textField.resignFirstResponder()
        emailTextField.textField.resignFirstResponder()

        guard let token = UserDefaults.standard.string(forKey: Key.token.rawValue),
            let fullName = fullNameTextField.textField.text,
            let email = emailTextField.textField.text else { return }

        if !checkInfoIsFilled() || (!email.isEmpty && !Validation.isValidEmail(email: email)) {
            return
        }

        let model = ProfileRegisterModel(token: token, gender: isMale ? 1 : 0, name: fullName, dob: datePickerView.date.timeIntervalSince1970 * 1000, email: email)
        let vc = SetUpPasswordViewController()
        vc.isRegistering = true
        vc.setModel(model: model)
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func didTapAgreeButton(_ sender : BaseButton) {
        switch sender {
        case agreeButton:
            isAgree.toggle()
            
            agreeButton.setImage(isAgree ? UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate) : nil, for: .normal)
            agreeButton.backgroundColor = .appColor(isAgree ? .blueMain : .whiteMain)
            
            if checkInfoIsFilled() {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
            break;
        case checkBoxButton :
            isAgree1.toggle()
            
            checkBoxButton.setImage(isAgree1 ? UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate) : nil, for: .normal)
            checkBoxButton.backgroundColor = .appColor(isAgree1 ? .blueMain : .whiteMain)
            
            if checkInfoIsFilled() {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
            break;
        default:
            break;
        }
        
        
    }

    @objc private func didTapBackButton() {
        navigationController?.popToRootViewController(animated: true)
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
        case emailTextField.textField:
            textFieldIndex = 2
            self.textField = emailTextField.textField
            break
        default:
            break
        }

        return true
    }

    @objc private func didTapGenderButton(_ sender: UIButton) {
        if sender == maleButton {
            isMale = true
        }
        else {
            isMale = false
        }

        let blueColor = UIColor.appColor(.blueMain)
        let blueTextColor = UIColor.appColor(.blue)
        let whiteColor = UIColor.appColor(.whiteMain)
        maleButton.backgroundColor = isMale ? blueColor : whiteColor
        femaleButton.backgroundColor = !isMale ? blueColor : whiteColor
        maleButton.setTitleColor(isMale ? whiteColor : blueTextColor, for: .normal)
        femaleButton.setTitleColor(isMale ? blueTextColor : whiteColor, for: .normal)
    }

    private func setupDatePicker() {
        dobTextField.rightIconView.tintColor = .appColor(.whiteMain)
        datePickerView = UIDatePicker()
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
        
        dobTextField.rightView.addTapGestureRecognizer {
            self.dobTextField.textField.becomeFirstResponder()
        }
        
        dobTextField.textField.inputView = datePickerView
        let doneToolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(datePickerValueDone))
        let items: [UIBarButtonItem] = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        dobTextField.textField.inputAccessoryView = doneToolbar
    }

    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")

        dobTextField.textField.text = dateFormatter.string(from: datePickerView.date)
    }

    @objc private func datePickerValueDone() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "vi_VN")

        dobTextField.textField.text = dateFormatter.string(from: datePickerView.date)

        dobTextField.textField.resignFirstResponder()
        emailTextField.textField.becomeFirstResponder()
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        guard let nameText = fullNameTextField.textField.text, !nameText.isEmpty,
            let dobText = dobTextField.textField.text, !dobText.isEmpty,
            checkInfoIsFilled() else {
            disableSubmitButton()
            return
        }
        enableSubmitButton()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let nameCount = fullNameTextField.textField.text?.count,
            let dobCount = dobTextField.textField.text?.count,
            var email = emailTextField.textField.text else { return false }
        let emailCount = email.count
        var count = string == "" ? -1 : 1
        if textField == fullNameTextField.textField {
            count += nameCount
            if count > 0 && dobCount > 0 && isAgree {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
        }
        else if textField == emailTextField.textField {
            count += emailCount
            if string == "" { email.removeLast() }
            if nameCount > 0 && dobCount > 0 && isAgree && (count == 0 || (Validation.isValidEmail(email: email + string))) {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
        }
        else {
            if checkInfoIsFilled() {
                enableSubmitButton()
            }
            else {
                disableSubmitButton()
            }
        }

        return true
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

    private func checkInfoIsFilled() -> Bool {
        guard let nameCount = fullNameTextField.textField.text?.count,
            let dobCount = dobTextField.textField.text?.count
        else { return false }
        return nameCount > 0 && dobCount > 0 && isAgree && isAgree1
    }
}
