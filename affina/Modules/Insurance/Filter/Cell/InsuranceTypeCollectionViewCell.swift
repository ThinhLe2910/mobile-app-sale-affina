//
//  InsuranceTypeCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

class InsuranceTypeCollectionViewCell: UICollectionViewCell {

    static let nib = "InsuranceTypeCollectionViewCell"
    static let cellId = "InsuranceTypeCollectionViewCell"
    @IBOutlet weak var containerView: BaseView!
    @IBOutlet weak var nameLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setSelected() {
        let blueColor = UIColor.appColor(.blue)
        let whiteColor = UIColor.appColor(.whiteMain)
        containerView.backgroundColor = blueColor
        nameLabel.textColor = whiteColor
    }
    
    func setUnSelected() {
        let blueColor = UIColor.appColor(.blueMain)
        let whiteColor = UIColor.appColor(.whiteMain)
        containerView.backgroundColor = whiteColor
        nameLabel.textColor = blueColor
        
    }
}
