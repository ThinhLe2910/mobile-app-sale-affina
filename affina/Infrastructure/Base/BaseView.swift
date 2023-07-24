//
//  BaseView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 04/07/2022.
//

import UIKit

@IBDesignable
class BaseView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable var rotation: CGFloat = 180 {
        didSet {
            let angle = .pi * rotation / 180
            transform = CGAffineTransform.identity.rotated(by: angle)
        }
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
    
    @IBInspectable var backgroundAsset: String = "" {
        didSet {
            self.backgroundColor =  UIColor.appColor(AssetsColor(rawValue: backgroundAsset) ?? .blackMain)
        }
    }
    @IBOutlet weak var hotIcon: UIView!
    
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
    }
    
}
