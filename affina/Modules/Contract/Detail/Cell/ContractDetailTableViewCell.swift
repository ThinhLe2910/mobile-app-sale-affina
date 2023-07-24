//
//  ContractTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import UIKit
import SnapKit
class ContractDetailTableViewCell: PaddingTableViewCell {
    
    static let cellId = "ContractDetailTableViewCell"
    static let nib = "ContractDetailTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var totalLabel: BaseLabel!
    @IBOutlet weak var remainingLabel: BaseLabel!
    @IBOutlet weak var remainingTitleLabel: BaseLabel!
    @IBOutlet weak var nameLabel: BaseLabel!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var usedViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stateButton: BaseButton!
    
    var item: ContractListProductMainBenefit? {
        didSet {
            guard let item = item else {
                return
            }
            iconImageView.image = UIImage(named: "ic_legacy")
            nameLabel.text = item.name
            remainingLabel.snp.makeConstraints{ make in
                make.trailing.equalToSuperview()
              }
            remainingLabel.textAlignment = .right
            //            if item.type == 0 {
            remainingLabel.text = "\(item.listMaximumAmountMainBenefit[0].maximumAmount.addComma()) vnd"
//            usedViewWidthConstraint.constant = 0
            stackView.spacing = 0
            
            totalLabel.hide()
            //            remainingLabel.hide()
            //            }
            //            else {
            //                totalLabel.text = "\(item.insuranceMoney.addComma()) vnd"
            //                remainingLabel.text = "\(item.remaining.addComma()) vnd"
            //                usedViewWidthConstraint.constant = frame.width * CGFloat(CGFloat(item.usedMoney)/CGFloat(item.remaining))
            //                stackView.spacing = 1
            //                totalLabel.show()
            //                remainingTitleLabel.show()
            //            }
        }
    }
    var sideItem: ContractListProductSideBenefit? {
        didSet {
            guard let item = sideItem else {
                return
            }
            iconImageView.image = UIImage(named: "ic_legacy")
            nameLabel.text = item.name
            
            //            if item.type == 0 {
            remainingLabel.text =  "\(item.listFeeAndMaximumAmountSideBenefit?[0].maximumAmount.addComma() ?? "0") vnd"
//            usedViewWidthConstraint.constant = 0
            stackView.spacing = 0
            
            totalLabel.hide()
            //            remainingLabel.hide()
            //            }
            //            else {
            //                totalLabel.text = "\(item.insuranceMoney.addComma()) vnd"
            //                remainingLabel.text = "\(item.remaining.addComma()) vnd"
            //                usedViewWidthConstraint.constant = frame.width * CGFloat(CGFloat(item.usedMoney)/CGFloat(item.remaining))
            //                stackView.spacing = 1
            //                totalLabel.show()
            //                remainingTitleLabel.show()
            //            }
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
        
        iconImageView.image = nil
        totalLabel.text = nil
        remainingLabel.text = nil
        nameLabel.text = nil
//        usedViewWidthConstraint.constant = 0
    }
}
