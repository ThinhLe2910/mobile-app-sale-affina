//
//  ProfileSettingTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 19/07/2022.
//

import UIKit

struct ProfileSettingModel {
    let icon: String
    let label: String
}

class ProfileSettingTableViewCell: UITableViewCell {

    static let nib = "ProfileSettingTableViewCell"
    static let cellId = "ProfileSettingTableViewCell"

    @IBOutlet weak var settingLabel: BaseLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var notiImageView: UIImageView!

    var item: ProfileSettingModel? {
        didSet {
            guard let item = item else {
                return
            }
            settingLabel.text = item.label
            iconImageView.image = UIImage(named: item.icon)?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor.appColor(.black)
            
//            if item.icon == "ic_insurance_shield" {
//                notiImageView.show()
//            }
//            else {
                notiImageView.hide(isImmediate: true)
//            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
