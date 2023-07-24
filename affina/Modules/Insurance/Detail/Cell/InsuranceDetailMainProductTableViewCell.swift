//
//  InsuranceDetailMainProductTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/08/2022.
//

import UIKit

class InsuranceDetailMainProductTableViewCell: UITableViewCell {
    
    static let nib = "InsuranceDetailMainProductTableViewCell"
    static let cellId = "InsuranceDetailMainProductTableViewCell"
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

}
