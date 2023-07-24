//
//  PersonInfoTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/08/2022.
//

import UIKit

class PersonInfoTableViewCell: UITableViewCell {

    static let cellId = "PersonInfoTableViewCell"
    static let nib = "PersonInfoTableViewCell"
    
    @IBOutlet weak var infoLabel: BaseLabel!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var separator: BaseView!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
}
