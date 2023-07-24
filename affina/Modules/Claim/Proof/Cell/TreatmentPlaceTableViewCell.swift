//
//  TreatmentPlaceTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 07/12/2022.
//

import UIKit

class TreatmentPlaceTableViewCell: UITableViewCell {

    static let identifier = "TreatmentPlaceTableViewCell"
    
    @IBOutlet weak var placeLabel: BaseLabel!
    @IBOutlet weak var separator: BaseView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    
}
