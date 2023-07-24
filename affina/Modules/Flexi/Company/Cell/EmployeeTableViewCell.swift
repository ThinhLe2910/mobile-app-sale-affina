//
//  EmployeeTableViewCell.swift
//  affina
//
//  Created by Dylan on 21/10/2022.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    static let identifier = "EmployeeTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var defaultImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var titleLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

}
