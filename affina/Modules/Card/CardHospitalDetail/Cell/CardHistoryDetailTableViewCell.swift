//
//  CardHospitalDetailTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 29/07/2022.
//

import UIKit

class CardHospitalDetailTableViewCell: UITableViewCell {
    static let nib = "CardHospitalDetailTableViewCell"
    static let cellId = "CardHospitalDetailTableViewCell"
    
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var detailLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        detailLabel.text = nil
    }
}
