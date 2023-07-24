//
//  InsuranceDetailMainTypeCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/08/2022.
//

import UIKit

class InsuranceDetailMainTypeCollectionViewCell: UICollectionViewCell {
    
    static let nib = "InsuranceDetailMainTypeCollectionViewCell"
    static let cellId = "InsuranceDetailMainTypeCollectionViewCell"
    
    @IBOutlet weak var label: BaseLabel!
    @IBOutlet weak var containerView: BaseView!
    
    var blurView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addBlurEffect(containerView)
        setUnSelectedColor()
    }
    
    func setSelectedColor() {
        containerView.backgroundColor = .appColor(.blueMain)
        label.textColor = .appColor(.whiteMain)
        blurView.isHidden = true
    }
    
    func setUnSelectedColor() {
        containerView.backgroundColor = .clear //.appColor(.blueMain)
        label.textColor = .appColor(.subText)
        blurView.isHidden = false
    }
    
    func addBlurEffect(_ view: UIView) {
        view.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.65)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        blurView = blurEffectView
    }
}
