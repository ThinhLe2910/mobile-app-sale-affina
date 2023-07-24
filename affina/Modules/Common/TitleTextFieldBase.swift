//
//  TitleTextFieldBase.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/07/2022.
//

import UIKit

@IBDesignable
class TitleTextFieldBase: UIView {
    static let nib = "TitleTextFieldBase"

    class func instanceFromNib() -> TitleTextFieldBase {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TitleTextFieldBase
    }

    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var errorLabel: BaseLabel!
    @IBOutlet weak var textField: TextFieldAnimBase!
    @IBOutlet weak var containerView: BaseView!
    @IBOutlet weak var contentView: BaseView!
    @IBOutlet weak var leftView: BaseView!
    @IBOutlet weak var rightView: BaseView!
    @IBOutlet weak var leftIconView: UIImageView!
    @IBOutlet weak var rightIconView: UIImageView!
    @IBOutlet weak var leftViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorTopConstraint: NSLayoutConstraint!
    
    @IBInspectable var leftIcon: UIImage = UIImage() {
        didSet {
            leftIconView.image = leftIcon
        }
    }
    
    var isError: Bool = false
    
    @IBInspectable var leftBackground: String = "" {
        didSet {
            if leftBackground == "nil" || leftBackground == "clear" {
                self.leftView.backgroundColor = UIColor.clear
                return
            }
            self.leftView.backgroundColor = UIColor.appColor(AssetsColor(rawValue: leftBackground) ?? .blackMain)
        }
    }
    
    @IBInspectable var hideLeftView: Bool = false {
        didSet {
            if hideLeftView {
                leftView.hide()
            }
            else {
                leftView.show()
            }
        }
    }
    @IBInspectable var rightIcon: UIImage = UIImage() {
        didSet {
            rightIconView.image = rightIcon
        }
    }
    
    @IBInspectable var rightBackground: String = "" {
        didSet {
            if rightBackground == "nil" || rightBackground == "clear" {
                self.rightView.backgroundColor = UIColor.clear
                return
            }
            self.rightView.backgroundColor = UIColor.appColor(AssetsColor(rawValue: rightBackground) ?? .blackMain)
        }
    }
    
    @IBInspectable var hideRightView: Bool = false {
        didSet {
            if hideRightView {
                rightView.hide()
            }
            else {
                rightView.show()
            }
        }
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            textField.placeholder = placeholder.localize()
        }
    }
    
    @IBInspectable var placeholderColor: String = "" {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.appColor(AssetsColor(rawValue: placeholderColor) ?? .blackMain) ?? .black])
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var text: String {
        set(value) {
            titleLabel.text = value.localize()
        }
        get {
            return ""
        }
    }
    
    @IBInspectable var isUppercaseTitle: Bool = false {
        didSet {
            if isUppercaseTitle {
                titleLabel.text = titleLabel.text?.uppercased()
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(TitleTextFieldBase.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .clear
        
        textField.rightView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 0))
        textField.rightViewMode = .always
        
        if isUppercaseTitle {
            titleLabel.text = titleLabel.text?.uppercased()
        }
        
        errorLabel.textColor = .appColor(.redError)
        hideError()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "" , attributes: [NSAttributedString.Key.foregroundColor: UIColor.appColor(AssetsColor(rawValue: placeholderColor) ?? .blackMain) ?? UIColor.black])
        
        if isUppercaseTitle {
            titleLabel.text = titleLabel.text?.uppercased()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
//        awakeFromNib()
        
    }
    
    
    func hideError() {
        isError = false
        errorLabel.isHidden = !isError
        errorLabel.layer.opacity = 0
        errorHeightConstraint.constant = 0
        errorTopConstraint.constant = 0
        layoutIfNeeded()
        
    }
    
    func showError(_ message: String = "") {
        if !message.isEmpty {
            errorLabel.text = message
        }
        isError = true
        errorLabel.isHidden = !isError
        errorLabel.layer.opacity = 1
        errorHeightConstraint.constant = 18
        errorTopConstraint.constant = 8
        layoutIfNeeded()
    }

}
