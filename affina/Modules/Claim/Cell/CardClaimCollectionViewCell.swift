//
//  CardClaimCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 04/08/2022.
//

import UIKit

class CardClaimCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var viewDisable: UIView!
    static let nib = "CardClaimCollectionViewCell"
    static let cellId = "CardClaimCollectionViewCell"
    static let size = CGSize.init(width: (UIConstants.Layout.screenWidth - 24*2 - 16 * 2)/3, height: UIConstants.heightConstraint(128))
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    var item: HomeCategoryModel? {
        didSet {
            guard  let item = item else {
                return
            }
            viewDisable.isHidden = true
            iconImageView.image = UIImage(named: item.imageURL ?? "")
            nameLabel.text = item.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
