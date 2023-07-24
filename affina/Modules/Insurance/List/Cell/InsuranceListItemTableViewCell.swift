//
//  InsuranceListItemTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

class InsuranceListItemTableViewCell: UITableViewCell {

    static let nib = "InsuranceListItemTableViewCell"
    static let cellId = "InsuranceListItemTableViewCell"
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var detailLabel: BaseLabel! 
    @IBOutlet weak var moreButton: BaseButton!
    @IBOutlet weak var feeLabel: BaseLabel!
    @IBOutlet weak var discountLabel: BaseLabel!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var item: FilterProductModel? {
        didSet {
            guard let item = item else { return }
            nameLabel.text = "\(item.programName) - \(item.packageName)"
            priceLabel.text = "\((item.maximumAmount ?? 0).addComma()) vnd"
            feeLabel.text = "\(item.fee.addComma()) vnd"
            discountLabel.text = "\((item.fee + 400000).addComma()) vnd"
            detailLabel.text = (item.highlight ?? "").htmlToString
            detailLabel.sizeToFit()
            layoutIfNeeded()
        }
    }
    
    var tapMoreCallBack: ((FilterProductModel) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }

    @objc private func didTapMoreButton() {
        guard let item = item else { return }
        tapMoreCallBack?(item)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.tableHeightConstraint?.constant = self.detailTableView.contentSize.height
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        detailLabel.text = nil
        detailLabel.sizeToFit()
        bgImageView.image = UIImage(named: "Card_4")
        logoImageView.image = UIImage(named: "pti_logo")
    }
}
//
//extension InsuranceListItemTableViewCell: UITableViewDataSource, UITableViewDelegate {

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let item = item else { return 44 }
//        let itemHeight = (item.highlight?.htmlToString.heightWithConstrainedWidth(width: self.detailTableView.contentSize.width - 20, font: UIConstants.Fonts.appFont(.Medium, 16)) ?? 44) + 16
//        DispatchQueue.main.async {
//            self.tableHeightConstraint?.constant = CGFloat(itemHeight) //* CGFloat((item.highlight?.components(separatedBy: "<p>").filter({ !$0.isEmpty }).count ?? 1))
//        }
//        Logger.Logs(message: itemHeight)
//        layoutIfNeeded()
//        return itemHeight
//    }
//}
