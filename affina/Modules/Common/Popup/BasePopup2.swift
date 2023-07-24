//
//  BasePopup.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 26/07/2022.
//

import UIKit

@IBDesignable
class BasePopup2: UIView {
    
    static let nib = "BasePopup2"
    
    class func instanceFromNib() -> BasePopup2 {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BasePopup2
    }
    
    @IBOutlet weak var nextButton: BaseButton!
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var descLabel: BaseLabel!
    
    private var defaultPos: CGFloat = 0.0
    
    var okCallBack: (() -> Void)? = nil
    var cancelCallBack: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    func setPopupData(icon: UIImage?, title: String, desc: String, okTitle: String, cancelTitle: String) {
        imageView.image = icon
        titleLabel.text = title
        descLabel.text = desc
        if cancelTitle.isEmpty {
            backButton.hide(isImmediate: true)
        }
        else {
            backButton.setTitle(cancelTitle, for: .normal)
        }
        
        if okTitle.isEmpty {
            nextButton.hide(isImmediate: true)
        }
        else {
            nextButton.setTitle(okTitle, for: .normal)
        }
    }
    
    @objc func didTapNextButton() {
        okCallBack?()
    }

    @objc func didTapBackButton() {
        cancelCallBack?()
    }
    
    func setBackButtonStyle(style: BaseButtonStyle) {
        if let backgroundColor = style.backgroundColor {
            backButton.backgroundColor = backgroundColor
        }
        if let textColor = style.textColor {
            backButton.setTitleColor(textColor, for: .normal)
            backButton.setTitleColor(textColor, for: .disabled)
            backButton.setTitleColor(textColor, for: .highlighted)
        }
        if let borderColor = style.borderColor {
            backButton.layer.borderColor = borderColor.cgColor
        }
        if let borderWidth = style.borderWidth {
            backButton.layer.borderWidth = borderWidth
        }
    }
    
    func setOkButtonStyle(style: BaseButtonStyle) {
        if let backgroundColor = style.backgroundColor {
            nextButton.backgroundColor = backgroundColor
        }
        if let textColor = style.textColor {
            nextButton.setTitleColor(textColor, for: .normal)
            nextButton.setTitleColor(textColor, for: .disabled)
            nextButton.setTitleColor(textColor, for: .highlighted)
        }
        if let borderColor = style.borderColor {
            nextButton.layer.borderColor = borderColor.cgColor
        }
        if let borderWidth = style.borderWidth {
            nextButton.layer.borderWidth = borderWidth
        }
    }
    
}
