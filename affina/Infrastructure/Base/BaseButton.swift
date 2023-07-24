//
//  BaseButton.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit
import SnapKit

@IBDesignable
class BaseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
    }

    override func prepareForInterfaceBuilder() {
        self.awakeFromNib()
    }

    override func awakeFromNib() {

//        applyGradientLayer(colors: [
//            UIColor(red: 0.043, green: 0.365, blue: 0.965, alpha: 1),
//            UIColor(red: 0.941, green: 0.349, blue: 0.824, alpha: 1)
//        ], orientation: .horizontal)
//
//        setTitleColor(.white, for: .normal)
//        setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
//        clipsToBounds = true
//
//        if let titleLabel = titleLabel {
//            bringSubviewToFront(titleLabel) // Title will be hid by gradient layer so we need to bring it to front
//        }
        
        if titleLabel?.font == UIFont.systemFont(ofSize: 15) {
            titleLabel?.font = UIConstants.Fonts.appFont(.Semibold, 16)
        }

    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title?.localize(), for: state)
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: String = "" {
        didSet {
            self.layer.borderColor = UIColor.appColor(AssetsColor(rawValue: borderColor) ?? .black)?.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 8.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var backgroundAsset: String = "" {
        didSet {
            if backgroundAsset == "nil" || backgroundAsset == "clear" {
                self.backgroundColor = UIColor.clear
                return
            }
            self.backgroundColor =  UIColor.appColor(AssetsColor(rawValue: backgroundAsset) ?? .blackMain)
        }
    }
    
    @IBInspectable var tintAsset: String = "" {
        didSet {
            self.tintColor = UIColor.appColor(AssetsColor(rawValue: tintAsset) ?? .blackMain)
        }
    }
    
    @IBInspectable var colorAsset: String = "" {
        didSet {
            self.setTitleColor(UIColor.appColor(AssetsColor(rawValue: colorAsset) ?? .blackMain), for: .normal)
            self.setTitleColor(UIColor.appColor(AssetsColor(rawValue: colorAsset) ?? .blackMain)?.withAlphaComponent(0.7), for: .highlighted)
        }
    }

    @IBInspectable var localizeTitle: String {
        set(value) {
            self.setTitle(value.localize(), for: .normal)
        }
        get {
            return ""
        }
    }
    
    @IBInspectable var customFont: String { // eg: Inter-SemiBold-24
        set(value) {
            let values = value.split(separator: "-")
            if values.isEmpty { return }
            let font = String(values[0])
            let style = FontStyle(rawValue: String(values[1])) ?? .Regular
            let size = (values[2] as NSString).doubleValue
            self.titleLabel?.font = UIConstants.Fonts.appFont(style, size, fontName: font)
        }
        get {
            return ""
        }
    }
    
    func enable() {
        isEnabled = true
        layer.opacity = 1
    }

    func disable() {
        isEnabled = false
        layer.opacity = 0.35
    }

    func changeToColor(bgColor: UIColor?, titleColor: UIColor? = UIColor.appColor(.whiteMain)) {
        backgroundColor = bgColor
        setTitleColor(titleColor, for: .normal)
        setTitleColor(titleColor?.withAlphaComponent(0.7), for: .highlighted)
    }

    func clearShadow() {
        layer.shadowColor = UIColor.clear.cgColor
    }

    func cornerCircle() {
        layer.cornerRadius = self.bounds.height / 2
    }
}


