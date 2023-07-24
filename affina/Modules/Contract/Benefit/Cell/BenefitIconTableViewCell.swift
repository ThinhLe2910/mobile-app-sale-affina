//
//  BenefitIconTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/08/2022.
//

import UIKit

class BenefitIconTableViewCell: UITableViewCell {
    static let nib = "BenefitIconTableViewCell"
    static let cellId = "BenefitIconTableViewCell"
    
    @IBOutlet weak var label: BaseLabel!
    @IBOutlet weak var iconCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        iconCheck.image = UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate)
        iconCheck.tintColor = .appColor(.blueMain)
    }
}
