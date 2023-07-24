//
//  CategoryCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/06/2022.
//

import UIKit

@IBDesignable
class CategoryInsuranceCollectionViewCell: BaseCollectionViewCell<String> {
    
    static let nib = "CategoryInsuranceCollectionViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var isPicked: Bool = false {
        didSet {
            if isPicked {
                contentView.layer.borderWidth = 2
                nameLabel.textColor = .appColor(.blue)
                nameLabel.font = UIConstants.Fonts.appFont(.Bold, 12)
            }
            else {
                contentView.layer.borderWidth = 0
                nameLabel.textColor = .appColor(.black)
                nameLabel.font = UIConstants.Fonts.appFont(.Medium, 12)
            }
        }
    }
    
    override var item: String? {
        didSet {
            guard let item = item else {
                return
            }
//            if item == "ALL".localize() {
//                nameLabel.font = UIConstants.Fonts.appFont(.Bold, 12)
//            }
//            else {
                nameLabel.font = UIConstants.Fonts.appFont(.Medium, 12)
//            }
            nameLabel.text = item
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    private func initViews() {
        contentView.backgroundColor = UIColor.appColor(.whiteMain)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.appColor(.blue)?.cgColor
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isPicked = false
    }
    
    func showHideBorder() {
        isPicked.toggle()
    }
}
