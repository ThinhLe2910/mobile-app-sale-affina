//
//  RewardHistoryTableViewCell.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit

class RewardHistoryTableViewCell: UITableViewCell {

    static let nib = "RewardHistoryTableViewCell"
    static let cellId = "RewardHistoryTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var pointLabel: BaseLabel!
    
    var cellType = FlexiCategoryViewType.voucher
    var item: VoucherHistoryModel? {
        didSet {
            guard let item = item else { return }
//            iconImageView.image = UIImage(named: item.)
            dateLabel.text = "\((item.createdAt ?? 0)/1000)".timestampToFormatedDate(format: "HH:mm - dd/MM/yyyy")
            nameLabel.text = item.voucherName
            
            let pointText = "-\((cellType == .voucher ? (item.totalCoin ?? 0) : (item.totalPoint ?? 0)).addComma()) "
            let attrs = [
                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
            ] as [NSAttributedString.Key : Any]
            let attributedString = NSMutableAttributedString(string: pointText, attributes: attrs)
            let normalString = NSMutableAttributedString(string: "\(cellType == .voucher ? "xu" : "điểm")")
            attributedString.append(normalString)
            pointLabel.attributedText = attributedString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
    }
    
}
