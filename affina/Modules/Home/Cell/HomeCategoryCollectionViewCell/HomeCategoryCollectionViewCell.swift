//
//  HomeCategoryCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 04/07/2022.
//

import UIKit

class HomeCategoryCollectionViewCell: BaseCollectionViewCell<HomeCategoryModel> {
    
    static let nib = "HomeCategoryCollectionViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: BaseView!
    
    override var item: HomeCategoryModel? {
        didSet {
            guard let item = item else {
                return
            }
            nameLabel.text = item.name
            iconImageView.image = UIImage(named: item.imageURL ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.textColor = UIColor.appColor(.blueBold)
        iconView.dropShadow(color: UIColor(hex: "010953"), opacity: 0.12, offset: .init(width: 0, height: 4), radius: 8, scale: true)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        iconImageView.image = nil
    }
}
