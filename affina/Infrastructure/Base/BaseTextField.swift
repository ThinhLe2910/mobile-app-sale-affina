//
//  BaseTextField.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit
import SnapKit

@IBDesignable
class TextFieldAnimBase: UITextField {
    let iconLeftView = UIView()
    let iconLeftImage = UIImageView()
    let iconRightView = UIView()
    let iconRightImage = UIImageView()
    let indicatorView = UIActivityIndicatorView()

    var defaultRightImage = UIImage()
    var activeRightImage = UIImage()
    var isPasswordField = false

    @IBInspectable var cornerRadius: CGFloat = 4 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var localizePlaceholder: String {
        set(value) {
            self.placeholder = value.localize()
        }
        get {
            return ""
        }
    }
    
    enum TextFieldAnimBaseStatus {
        case inactive, error, active
    }

    var textFieldStatus: TextFieldAnimBaseStatus = .inactive {
        didSet {
            switch textFieldStatus {
            case .inactive:
                iconRightImage.layer.opacity = isPasswordField && !isSecureTextEntry ? 1 : 0.3
                iconRightImage.changeToColor(AssetsColor.activeBorder.toUIColor())
            case .error:
                iconRightImage.layer.opacity = 1
                iconRightImage.changeToColor(AssetsColor.redError.toUIColor())
            case .active:
                iconRightImage.layer.opacity = 1
                iconRightImage.changeToColor(AssetsColor.activeBorder.toUIColor())
            }
        }
    }
    
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.configCommon(color: UIColor.appColor(.blackMain), fontWeight: .Regular, fontSize: 16)
        return label
    }()
    
    private lazy var errorLabel: BaseLabel = {
        let label = BaseLabel()
        label.text = "PLEASE_FILL_IN_THE_INFORMATION_IN_THIS_BOX".localize()
//        label.backgroundColor = .clear
        label.configCommon(color: UIColor.appColor(.redError), fontWeight: .Regular, fontSize: 14)
        return label
    }()

    private var leftSpace: CGFloat = UIConstants.widthConstraint(15)

    var title = "" {
        didSet {
            labelTitle.text = title.localize()
            if title.contains("*") {
                labelTitle.redDot()
            }
        }
    }
    var titleFont: UIFont = UIConstants.Fonts.appFont(.Regular, 16) {
        didSet {
            labelTitle.font = titleFont
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
    }

    override func awakeFromNib() {
        addSubview(labelTitle)
        addSubview(errorLabel)
        setupProperties()
        configureViews()
        addLeftSpaceView()
        addTarget()
    }

    private func setupProperties() {
        self.backgroundColor = UIColor.appColor(.whiteMain)
        self.textColor = UIColor.appColor(.blackMain)
        self.font = UIConstants.Fonts.appFont(.Regular, 16)
        self.layer.cornerRadius = UIConstants.widthConstraint(cornerRadius)
        self.layer.borderWidth = borderStyle == .none ? 0 : 1
        self.layer.borderColor = UIColor.appColor(.graySeparator)?.cgColor
        clipsToBounds = false
        hideError()
        
    }

    private func configureViews() {
        labelTitle.snp.makeConstraints { (make) in
//            make.centerY.equalTo(self.snp.centerY).offset(-36)
            make.bottom.equalTo(self.snp.top).offset(-5)
            make.leading.equalTo(self.snp.leading) //.offset(UIConstants.widthConstraint(10))
        }
        
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(5)
            make.leading.equalTo(self.snp.leading) //.offset(UIConstants.widthConstraint(10))
            make.height.equalTo(16)
        }
    }

    private func addTarget() {
        self.addTarget(self, action: #selector(textFieldBeginEdit), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldEndEdit), for: .editingDidEnd)
    }

    private func defaultView() {
        self.layer.borderWidth = borderStyle == .none ? 0 : 1
        self.layer.borderColor = UIColor.appColor(.defaultBorder)?.cgColor
        self.textColor = UIColor.appColor(.blackMain)
        self.backgroundColor = UIColor.appColor(.whiteMain)
        textFieldStatus = .inactive
    }

    private func errorView() {
        self.layer.borderWidth = borderStyle == .none ? 0 : 1
        self.layer.borderColor = UIColor.appColor(.redError)?.cgColor
        self.textColor = UIColor.appColor(.redError)
        self.backgroundColor = UIColor.appColor(.redErrorBg)//?.withAlphaComponent(0.3)
        textFieldStatus = .error
    }

    private func activeView() {
        self.layer.borderWidth = borderStyle == .none ? 0 : 1
        self.layer.borderColor = UIColor.appColor(.activeBorder)?.cgColor
        self.textColor = UIColor.appColor(.blackMain)
        self.backgroundColor = UIColor.appColor(.whiteMain)
        textFieldStatus = .active
    }

    func addLeftSpaceView() {
        iconLeftView.frame = CGRect(x: 0, y: 0, width: leftSpace, height: frame.height)
        iconLeftView.backgroundColor = .clear
        leftView = iconLeftView
        leftViewMode = .always
    }

    func addRightButton(_ iconName: String, _ activeIconName: String = "", action: (() -> Void)?) {
        iconRightView.frame = CGRect(x: 0, y: -10, width: 50.width, height: 50.height)
        iconRightView.isUserInteractionEnabled = true
        iconRightView.backgroundColor = .clear

        iconRightImage.frame = CGRect(x: 0, y: 50.height / 2 - 9.height, width: UIConstants.widthConstraint(18), height: UIConstants.widthConstraint(18))
        iconRightImage.center.x = iconRightView.center.x
//        iconRightImage.center.y = iconRightView.center.y
        if !iconName.isEmpty {
            iconRightImage.image = UIImage(named: iconName)
        } else {
            iconRightImage.image = UIImage()
        }
        defaultRightImage = iconRightImage.image ?? UIImage()

        if !activeIconName.isEmpty {
            activeRightImage = UIImage(named: activeIconName) ?? UIImage()
        } else {
            activeRightImage = UIImage()
        }

        iconRightImage.contentMode = .scaleAspectFit

        iconRightView.addSubview(iconRightImage)
//        iconRightImage.center.x = iconRightView.center.x
//        iconRightImage.center.y = iconRightView.center.y
        rightView = iconRightView
        rightViewMode = .always
        iconRightView.addTapGestureRecognizer(action: action)
    }

    func addSmallRightButton(_ iconName: String, color: UIColor? = UIColor.appColor(.blackMain)) {
        iconRightView.frame = CGRect(x: 0, y: 0, width: UIConstants.widthConstraint(25), height: frame.height)
        iconRightView.isUserInteractionEnabled = true
        iconRightView.backgroundColor = .clear

        iconRightImage.frame = CGRect(x: 0, y: 0, width: UIConstants.widthConstraint(12), height: UIConstants.widthConstraint(12))
        iconRightImage.center.x = iconRightView.center.x
        iconRightImage.center.y = iconRightView.center.y
        if !iconName.isEmpty {
            iconRightImage.image = UIImage(named: iconName)
        } else {
            iconRightImage.image = UIImage()
        }
        iconRightImage.changeToColor(.gray)
        iconRightImage.contentMode = .scaleAspectFit
        iconRightImage.changeToColor(color!)

        iconRightView.addSubview(iconRightImage)
        rightView = iconRightView
        rightViewMode = .always
    }

    func addRightLoading() {
        iconRightView.snp.makeConstraints { (make) in
            make.width.height.equalTo(UIConstants.heightConstraint(40))
        }
        iconRightView.isUserInteractionEnabled = true
        iconRightView.backgroundColor = .clear

        iconRightView.addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        indicatorView.color = UIColor.appColor(.greenMain)
        indicatorView.hidesWhenStopped = true
        indicatorView.isHidden = true

        rightView = iconRightView
        rightViewMode = .always
    }

    func showRightLoading() {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }

    func hideRightLoading() {
        indicatorView.stopAnimating()
    }

    func removeRightButton() {
        rightView = nil
    }

    func changeRightIcon(_ iconName: String) {
        if !iconName.isEmpty {
            iconRightImage.image = UIImage(named: iconName)
            iconRightImage.contentMode = .scaleAspectFit
        } else {
            iconRightImage.image = UIImage()
            iconRightImage.contentMode = .scaleAspectFit
        }
    }

    @objc private func textFieldBeginEdit() {
        self.activeView()
    }

    @objc private func textFieldEndEdit() {
//        if let text = self.text, text.isEmpty {
//        }
        self.defaultView()
    }

    fileprivate func performAnimation(transform: CGAffineTransform, isActive: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.labelTitle.transform = transform
            self.layoutIfNeeded()
            if isActive {
                self.labelTitle.textColor = UIColor.appColor(.greenMain)
                self.labelTitle.alpha = 1
            } else {
                self.labelTitle.textColor = UIColor.appColor(.blackMain)
                self.labelTitle.alpha = 0.5
            }
        }, completion: nil)
    }

    func activeStatus() {
        self.activeView()
//        labelTitle.snp.updateConstraints { (make) in
//            make.centerY.equalTo(self.snp.centerY).offset(-UIConstants.heightConstraint(32))
//            make.leading.equalTo(self.snp.leading)
//        }
//
//        performAnimation(transform: CGAffineTransform(scaleX: 0.8, y: 0.8), isActive: true)
    }

    func defaultStatus() {
        self.defaultView()
//        labelTitle.snp.updateConstraints { (make) in
//            make.centerY.equalTo(self.snp.centerY)
//            make.leading.equalTo(self.snp.leading).offset(leftSpace)
//        }
//        performAnimation(transform: CGAffineTransform(scaleX: 1, y: 1))
    }

    func errorStatus() {
        if let text = self.text, text.isEmpty {
            defaultStatus()
        } else {
            activeStatus()
        }

        self.errorView()
    }

    func reload() {
        if let text = self.text, text.isEmpty {
            defaultStatus()
        } else {
            activeStatus()
        }
    }

    override var text: String? {
        didSet {
            guard let text = self.text else {
                return
            }
            if text.isEmpty {
                self.defaultStatus()
            } else {
                self.activeStatus()
            }
        }
    }

    func disable() {
        textColor = UIColor.appColor(.grayLight)
        isEnabled = false
        backgroundColor = UIColor.appColor(.blueExtremeLight)// UIColor(hex: AssetsColor.backgroundGray.value)
    }

    func enable() {
        textColor = UIColor.appColor(.blackMain)
        isEnabled = true
        backgroundColor = .white
    }
    
    func hideError() {
        errorLabel.isHidden = true
        errorLabel.layer.opacity = 0
        layoutIfNeeded()
        
    }
    
    func showError(_ message: String = "") {
        if !message.isEmpty {
            errorLabel.text = message
        }
        errorLabel.isHidden = false
        errorLabel.layer.opacity = 1
        layoutIfNeeded()
    }

    
}

