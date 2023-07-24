//
//  ContractTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import UIKit

class ContractTableViewCell: PaddingTableViewCell {
    
    static let cellId = "ContractTableViewCell"
    static let nib = "ContractTableViewCell"
    
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var numberLabel: BaseLabel!
    @IBOutlet weak var ownerLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    
    @IBOutlet weak var stateButton: BaseButton!
    @IBOutlet weak var stateButtonWidthConstraint: NSLayoutConstraint!
    
    var item: ContractModel? {
        didSet {
            guard let item = item else {
                return
            }
            numberLabel.text = item.listContractObject[0].contractObjectIdProvider
            ownerLabel.text = item.listContractObject[0].peopleName
            dateLabel.text = "\((item.contractEndDate)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            let currentTime = Date().timeIntervalSince1970
            if currentTime > Double(item.listContractObject[0].contractObjectEndDate ?? 0)/1000 {
                stateButton.setTitle("USED_EXPIRED".localize(), for: .normal)
                stateButton.setImage(UIImage(named: "ic_reject_state"), for: .normal)
            }
            else if currentTime < Double(item.listContractObject[0].contractObjectStartDate ?? 0)/1000 {
                stateButton.setTitle("NEWLY_CREATED".localize(), for: .normal)
                stateButton.setImage(UIImage(named: "ic_new_state"), for: .normal)
            }
            else {
                stateButton.setTitle("VALID".localize(), for: .normal)
                stateButton.setImage(UIImage(named: "ic_processing_state"), for: .normal)
            }
            
            stateButtonWidthConstraint.constant = (stateButton.title(for: .normal)?.widthWithConstrainedHeight(height: stateButton.frame.height, font: UIConstants.Fonts.appFont(.ExtraBold, 10)) ?? 0) + 32
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        numberLabel.text = nil
        ownerLabel.text = nil
        dateLabel.text = nil
    }
}
