//
//  CardBlackListTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 27/07/2022.
//

import UIKit

class CardBlackListTableViewCell: UITableViewCell {

    static let nib = "CardBlackListTableViewCell"
    static let cellId = "CardBlackListTableViewCell"
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var addressLabel: BaseLabel!
    
    var item: HospitalModel? {
        didSet {
            guard let item = item else {
                return
            }
            nameLabel.text = item.name
            addressLabel.text = item.address
//            logoImageView.image = nil
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        selectionStyle = .none
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
}
