//
//  PaymentMethodTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/08/2022.
//

import UIKit

class PaymentMethodTableViewCell: UITableViewCell {

    static let nib = "PaymentMethodTableViewCell"
    static let cellId = "PaymentMethodTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconNextImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func disableView() {
//        backgroundColor =
        nameLabel.layer.opacity = 0.35
        iconImageView.layer.opacity = 0.35
        iconNextImageView.layer.opacity = 0.35
    }
    
    func enableView() {
        nameLabel.layer.opacity = 1
        iconImageView.layer.opacity = 1
        iconNextImageView.layer.opacity = 1
        
    }
}
