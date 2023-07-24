//
//  BaseLabel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit

@IBDesignable
class BaseLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        awakeFromNib()
    }
    
    override class func prepareForInterfaceBuilder() {
        awakeFromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if font == UIFont.systemFont(ofSize: 17) {
            font = UIConstants.Fonts.appFont(.Regular, 16)
        }
    }
    
    @IBInspectable var customFont: String { // eg: Inter-SemiBold-24
        set(value) {
            let values = value.split(separator: "-")
            if values.isEmpty { return }
            let font = String(values[0])
            let style = FontStyle(rawValue: String(values[1])) ?? .Regular
            let size = (values[2] as NSString).doubleValue
            self.font = UIConstants.Fonts.appFont(style, size, fontName: font)
        }
        get {
            return ""
        }
    }
    
    @IBInspectable var colorAsset: String = "" {
        didSet {
            self.textColor =  UIColor.appColor(AssetsColor(rawValue: colorAsset) ?? .blackMain)
        }
    }
    
    @IBInspectable var localizeText: String {
        set(value) {
            self.text = value.localize()
        }
        get {
            return ""
        }
    }
    
    @IBInspectable var strikeThrough: Bool = false {
        didSet {
            if strikeThrough {
                self.attributedText = self.text?.strikeThrough()
            }
        }
    }
    
    @IBInspectable var isUppercase: Bool = false {
        didSet {
            if isUppercase {
                self.text = self.text?.uppercased()
            }
        }
    }
    @IBInspectable var isCapitalizedFirstLetter: Bool = false {
        didSet {
            if isCapitalizedFirstLetter {
                self.text = self.text?.capitalizingFirstLetter()
            }
        }
    }
    @IBInspectable var isCapitalized: Bool = false {
        didSet {
            if isCapitalized {
                self.text = self.text?.capitalized
            }
        }
    }
}

@IBDesignable
class BaseLabelDetail: BaseLabel {
    
    override func awakeFromNib() {
        self.textColor = UIColor(hex: AssetsColor.blackMain.value)
    }
    
    override func prepareForInterfaceBuilder() {
        self.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@IBDesignable
class BaseLabelTitle: BaseLabel {
    
    override func awakeFromNib() {
        self.textColor = UIColor(hex: AssetsColor.blackMain.value).withAlphaComponent(0.8)
    }
    
    override func prepareForInterfaceBuilder() {
        self.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
