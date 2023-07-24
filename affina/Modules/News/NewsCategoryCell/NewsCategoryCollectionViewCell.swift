//
//  NewsCategoryCollectionViewCell.swift
//  affina
//
//  Created by Intelin MacHD on 27/07/2022.
//

import UIKit

//------------------------------------//

struct NewsCategoryViewModel {
     let name: String?
     let id: String?
}

@IBDesignable
class NewsCategoryCollectionViewCell: BaseCollectionViewCell<NewsCategoryViewModel> {
    static let nib = "NewsCategoryCollectionViewCell"

    @IBOutlet weak var containerView: BaseView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var isPicked: Bool = false {
        didSet {
            if isPicked {
                nameLabel.textColor = .appColor(.whiteMain)
                containerView.backgroundColor = UIColor(hex: "#3A7EFC")
            }
            else {
                nameLabel.textColor = .appColor(.black)
                containerView.backgroundColor = UIColor(hex: "#FFFFFF", alpha: 0.5)
            }
        }
    }
    
    override var item: NewsCategoryViewModel? {
        didSet {
            guard let item = item else {
                return
            }
            nameLabel.text = item.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    private func initViews() {
        containerView.backgroundColor = UIColor.appColor(.whiteMain)
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        initViews()
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isPicked = false
    }

}
