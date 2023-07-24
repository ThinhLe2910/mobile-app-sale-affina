//
//  SelectInsuredTableViewCell.swift
//  affina
//
//  Created by Dylan on 21/09/2022.
//

import UIKit

class SelectInsuredTableViewCell: UITableViewCell {

    static let nib = "SelectInsuredTableViewCell"
    static let cellId = "SelectInsuredTableViewCell"
    
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        defaultImageView.tintColor = .appColor(.pinkLighter2)
    }

}
