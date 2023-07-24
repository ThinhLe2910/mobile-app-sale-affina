//
//  SideProductItemTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/08/2022.
//

import UIKit

class SideProductItemTableViewCell: UITableViewCell {

    static let nib = "SideProductItemTableViewCell"
    static let cellId = "SideProductItemTableViewCell"
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var separator: BaseView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    
}
