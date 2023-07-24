//
//  PointCategoryCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit

class PointCategoryCollectionViewCell: BaseCollectionViewCell<VoucherCategoryModel> {
    
    static let nib = "PointCategoryCollectionViewCell"
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: BaseView!
    
    override var item: VoucherCategoryModel? {
        didSet {
            guard let item = item else {
                return
            }
            nameLabel.text = item.categoryName
            if item.categoryIcon == "ic_crown" {
                iconImageView.image = UIImage(named: "ic_crown")?.withRenderingMode(.alwaysTemplate)
            }
            else {
                guard let url = URL(string: API.STATIC_RESOURCE + (item.categoryIcon ?? "")) else { return }
                CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self?.iconImageView.image = UIImage(named: "ic_crown")?.withRenderingMode(.alwaysTemplate)
                        }
                        Logger.Logs(event: .error, message: error)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.iconImageView.image = image
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setColors(bgColor: "whiteMain", iconColor: "secondaryViolet", textColor: "black")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        iconImageView.image = UIImage(named: "ic_crown")?.withRenderingMode(.alwaysTemplate)
        setColors(bgColor: "whiteMain", iconColor: "secondaryViolet", textColor: "black")
    }
    
    func setColors(bgColor: String, iconColor: String, textColor: String) {
        nameLabel.colorAsset = textColor
        iconView.backgroundAsset = bgColor
        iconImageView.tintColor = UIColor.appColor(AssetsColor(rawValue: iconColor) ?? .blackMain)
        iconView.dropShadow(color: UIColor(hex: "010953"), opacity: 0.12, offset: .init(width: 0, height: 4), radius: 8, scale: true)
    }
}
