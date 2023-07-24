//
//  FlexiFilterTableViewCell.swift
//  affina
//
//  Created by Dylan on 19/10/2022.
//

import UIKit

class FlexiFilterTableViewCell: UITableViewCell {

    static let nib = "FlexiFilterTableViewCell"
    static let cellId = "FlexiFilterTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var checkBox: BaseButton!
    @IBOutlet weak var separator: BaseView!
    
    var callBack: ((Bool) -> Void)?
    
    var item: FilterModel? {
        didSet {
            guard let item = item else { return }
            
            nameLabel.text = item.name
            iconImageView.image = UIImage(named: item.iconName)
            
            if item.isSelected {
                checkBox.setImage(UIImage(named: "ic_check"), for: .normal)
            }
            else {
                checkBox.setImage(nil, for: .normal)
            }
            
            checkBox.addTapGestureRecognizer {
                if !item.isSelected {
                    self.checkBox.setImage(UIImage(named: "ic_check"), for: .normal)
                }
                else {
                    self.checkBox.setImage(nil, for: .normal)
                }
                self.callBack?(!item.isSelected)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

}
