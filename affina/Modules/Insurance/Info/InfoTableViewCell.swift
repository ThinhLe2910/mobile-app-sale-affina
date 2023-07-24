//
//  InfoTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/08/2022.
//

import UIKit

class InfoTableViewCell: UITableViewCell {

    static let cellId = "InfoTableViewCell"
    static let nib = "InfoTableViewCell"
    
    @IBOutlet weak var infoLabel: BaseLabel!
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var separator: BaseView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
}
