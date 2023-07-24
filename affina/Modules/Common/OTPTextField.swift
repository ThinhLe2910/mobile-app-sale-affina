//
//  OTPTextField.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit
import SnapKit

protocol OTPSubmitViewDelegate {
    func textDidChange(text: String)
    func textDidEndEditing()
    func textDidBeginEditing()
    func didEnterLastDigit(string: String)
}

class OneTimeCodeTextField: UITextField {

    var defaultCharacter = ""

    private var isConfigured = false

    private var digitLabels = [UILabel]()
    private var digitLabelViews = [UIView]()
//    private var cursors = [UIView]()
    private var overlayView = UIView()

    private var isStarting: Bool = false

    var otpDelegate: OTPSubmitViewDelegate?

    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()

    func configure(with slotCount: Int = 6) {
        guard isConfigured == false else { return }
        isConfigured.toggle()

        addSubview(overlayView)
        overlayView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }

        configureTextField()

        let labelsStackView = createLabelsStackView(with: slotCount)
        addSubview(labelsStackView)

        addGestureRecognizer(tapRecognizer)

        labelsStackView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            digitLabels.forEach { label in
                label.backgroundColor = backgroundColor
            }
        }
    }

    func clear() {
        text = ""

        for i in 0..<digitLabelViews.count {
            digitLabelViews[i].show()
            digitLabelViews[i].backgroundColor = .appColor(.blueLighter)
        }

        digitLabels.forEach {
            $0.text = ""
            $0.backgroundColor = .clear
        }
        for i in 0..<digitLabels.count {
            if i == 0 {
                digitLabels[i].layer.borderColor = UIColor(r: 89, g: 158, b: 252).cgColor
            }
            else {
                digitLabels[i].layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor
            }
        }
    }

    private func configureTextField() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        } else {
            // Fallback on earlier versions
        }

//        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addTarget(self, action: #selector(valueDidChange), for: .editingChanged)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
        addTarget(self, action: #selector(valueDidChange), for: .editingDidBegin)

        delegate = self
    }

    private func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        for _ in 1...count {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIConstants.Fonts.appFont(.Medium, 36)
            label.text = defaultCharacter

            label.layer.masksToBounds = true
            label.isUserInteractionEnabled = false

//            label.layer.cornerRadius = 8
//            label.layer.borderWidth = 1
//            label.layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor

            label.textColor = .blue
            label.backgroundColor = .clear
            stackView.addArrangedSubview(label)
            digitLabels.append(label)

//            let cursor = UIView()
//            cursor.layer.cornerRadius = 2
//            cursor.backgroundColor = UIColor.appColor(.textDescGray)
//            label.addSubview(cursor)
//            cursor.snp.makeConstraints { make in
////                make.leading.trailing.equalToSuperview().inset(10)
////                make.height.equalTo(3)
////                make.bottom.equalToSuperview().inset(5)
//                make.top.bottom.equalToSuperview().inset(12)
//                make.centerX.equalToSuperview()
//                make.width.equalTo(1)
//            }
//            cursors.append(cursor)
//            cursor.isHidden = true
//            cursor.layer.opacity = 0

            // placeholder view
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            label.addSubview(view)
            view.layer.cornerRadius = 4
            view.backgroundColor = UIColor.appColor(.blueLighter)
            view.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalTo(16)
                make.height.equalTo(12)
            }
            digitLabelViews.append(view)
        }
        return stackView
    }

    @objc func valueDidChange() {
        digitLabels.forEach {
            $0.layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor
        }
        isStarting = false
        let text = self.text ?? ""
        switch text.count {
        case 1, 2, 3, 4, 5:
            for i in 0..<digitLabels.count {
                if i <= text.count - 1 {
                    if !isSecureTextEntry {
                        digitLabelViews[i].isHidden = true
                    }
                    else {
                        digitLabelViews[i].backgroundColor = UIColor.appColor(.blue)
                    }
//                    cursors[i].hide()
                    digitLabels[i].text = isSecureTextEntry ? "" : "\(Array(text)[i])"
//                    digitLabels[i].backgroundColor = UIColor.appColor(.greenMain)
                    digitLabels[i].layer.borderColor = UIColor(r: 89, g: 158, b: 252).cgColor
                }
                else if i == text.count {
                    digitLabels[i].text = ""
                    digitLabels[i].layer.borderColor = UIColor(r: 89, g: 158, b: 252).cgColor
//                    digitLabels[i].backgroundColor = .white
//                    animateCursor(i)
//                    digitLabelViews[i].show()
                    digitLabelViews[i].isHidden = false
                    digitLabelViews[i].backgroundColor = UIColor.appColor(.blueLighter)
                }
                else {
                    digitLabelViews[i].backgroundColor = UIColor.appColor(.blueLighter)
//                    digitLabelViews[i].show()
                    digitLabelViews[i].isHidden = false
                    // cursors[i].hide()
                    digitLabels[i].text = ""
                    digitLabels[i].layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor
//                    digitLabels[i].backgroundColor = .white
                }
            }
        case 6:
            for i in 0..<digitLabels.count {
                if !isSecureTextEntry {
                    DispatchQueue.main.async {
                        self.digitLabelViews[i].isHidden = true
                    }
                }
                else {
                    digitLabelViews[i].backgroundColor = UIColor.appColor(.blue)
                }
//                cursors[i].hide()
                digitLabels[i].text = isSecureTextEntry ? "" : "\(Array(text)[i])"
//                digitLabels[i].backgroundColor = UIColor.appColor(.greenMain)
            }
        case 7:
            self.text = String(text.dropLast())
//            cursors.forEach {
//                $0.hide()
//            }
            error()
            break
        default:
//            if !isStarting {
//                animateCursor()
//                for i in 1..<digitLabels.count {
//                    cursors[i].hide()
//                }
//            }
            clear()
        }

        digitLabels.forEach {
            $0.textColor = .appColor(.blue)
        }

        otpDelegate?.textDidChange(text: text)

//        for i in 0..<digitLabels.count {
//            let curLabel = digitLabels[i]
//            if i < text.count {
//                let index = text.index(text.startIndex, offsetBy: i)
//                curLabel.text = String(text[index])
//            } else {
//                curLabel.text = defaultCharacter
//            }
//        }

        if text.count == digitLabels.count {
            otpDelegate?.didEnterLastDigit(string: text)
        }
    }

    @objc func didEndEditing() {
//        cursors.forEach {
//            $0.hide()
//        }
        let text = self.text ?? ""
        switch text.count {
        case 1, 2, 3, 4, 5:
            for i in 0..<digitLabels.count {
                if i >= text.count {
//                    digitLabels[i].layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor
                }
            }
        case 6:
            break
        case 7:
            self.text = String(text.dropLast())
            break
        default:
            for _ in 0..<digitLabels.count {
//                digitLabels[i].layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor
            }
        }
    }

    func error() {
        for i in 0..<digitLabels.count {
            digitLabels[i].backgroundColor = UIColor.appColor(.redErrorBg)
            digitLabels[i].textColor = UIColor.appColor(.redError)
            digitLabels[i].layer.borderColor = UIColor.appColor(.redError)?.cgColor
        }
    }

//    func animateCursor(_ index: Int = 0) {
//        cursors[index].show()
//        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.repeat, .autoreverse], animations: {
//            self.cursors[index].alpha = 0.0
//        }, completion: nil)
//    }

}

extension OneTimeCodeTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isStarting = true
//        animateCursor()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let characterCount = textField.text?.count else { return false }

        return characterCount < digitLabels.count || string == ""

    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        otpDelegate?.textDidBeginEditing()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        otpDelegate?.textDidEndEditing()
    }
}
