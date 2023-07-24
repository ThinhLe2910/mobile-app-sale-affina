//
//  CompanyBenefitTableViewCell.swift
//  affina
//
//  Created by Dylan on 21/10/2022.
//

import UIKit

class CompanyBenefitTableViewCell: UITableViewCell {

    static let cellId = "CompanyBenefitTableViewCell"
    static let nib = "CompanyBenefitTableViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconView: BaseView!
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var statusButton: BaseButton!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var valueLabel: BaseLabel!
    @IBOutlet weak var actionButton: BaseButton!
    
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    
    var actionCallBack: (() -> Void)?
    var iconString: String = "" {
        didSet {
            guard let url = URL(string: API.STATIC_RESOURCE + iconString) else {
                self.iconImageView.image = UIImage(named: "ic_benefit_default")
                return
            }
            
            CacheManager.shared.imageFor(url: url) { image, error in
                DispatchQueue.main.async {
                    self.iconImageView.image = image
                }
            }
        }
    }
    var item: FlexiBenefitModel? {
        didSet {
            guard let item = item else { return }
            
            nameLabel.text = item.benefitName
            
            let valueText2 = "\((item.startDate ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            let attrs2 = [
                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Semibold, 12)
            ] as [NSAttributedString.Key : Any]
            let attributedString2 = NSMutableAttributedString(string: valueText2, attributes: attrs2)
            let normalString2 = NSMutableAttributedString(string: "Ngày hiệu lực: ")
            attributedString2.insert(normalString2, at: 0)
            dateLabel.attributedText = attributedString2
            
            let valueText = "\(item.point ?? 0) "
            let attrs = [
                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
            ] as [NSAttributedString.Key : Any]
            let attributedString = NSMutableAttributedString(string: valueText, attributes: attrs)
            let normalString = NSMutableAttributedString(string: "POINT".localize())
            attributedString.append(normalString)
            valueLabel.attributedText = attributedString
            
            if #available(iOS 11.0, *) {
                statusButton.contentHorizontalAlignment = .trailing
            } else {
                statusButton.contentHorizontalAlignment = .right
            }
            
            switch item.status {
                case .FINISHED:
//                    dateLabel.text = "Đã kết thúc"
                statusButton.setTitle("FINISHED".localize(), for: .normal)
                    statusButton.setImage(UIImage(named: "ic_reject_state"), for: .normal)
                    
                    actionButton.backgroundColor = .appColor(.blueMain)?.withAlphaComponent(0.5)
                    actionButton.disable()
                case .UPCOMING:
                statusButton.setTitle("Not available".localize(), for: .normal)
                    statusButton.setImage(UIImage(named: "ic_update_state"), for: .normal)
                    actionButton.disable()
                actionButton.backgroundColor = .appColor(.blueMain)?.withAlphaComponent(0.5)
                case .HAPPENING:
                statusButton.setTitle("VALID".localize(), for: .normal)
                    statusButton.setImage(UIImage(named: "ic_processing_state"), for: .normal)
                    actionButton.enable()
                    actionButton.backgroundColor = .appColor(.blueMain)?.withAlphaComponent(1)
                default: break
            }
            
            switch item.type {
                case .OTHER:
                    dateLabel.show()
                    if #available(iOS 11.0, *) {
                        statusButton.contentHorizontalAlignment = .trailing
                    } else {
                        statusButton.contentHorizontalAlignment = .right
                    }
                    valueLabel.show()
                    actionButton.hide()
                case .BIRTHDAY:
                    dateLabel.show()
                    if #available(iOS 11.0, *) {
                        statusButton.contentHorizontalAlignment = .trailing
                    } else {
                        statusButton.contentHorizontalAlignment = .right
                    }
                    valueLabel.show()
                    actionButton.hide()
                case .EXCHANGE_DAY_OFF:
                    dateLabel.hide()
                    if #available(iOS 11.0, *) {
                        statusButton.contentHorizontalAlignment = .leading
                    } else {
                        statusButton.contentHorizontalAlignment = .left
                    }
                    valueLabel.hide()
                    actionButton.show()
                default: break
            }
            
            if item.type == .EXCHANGE_DAY_OFF {
                if item.isUse ?? 0 >= item.maxDay ?? 0 {
                    actionButton.backgroundColor = .appColor(.blueMain)?.withAlphaComponent(0.5)
                    actionButton.disable()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
//        updateUI()
    }
    
    func updateUI() {
//        if type == 3 || type == 4 {
//            iconView.backgroundAsset = "blueSlider"
//            iconImageView.image = UIImage(named: type == 3 ? "ic_honey_moon" : "ic_wedding")
//        }
//        else {
//            iconView.backgroundAsset = "pinkMain"
//            switch type {
//                case 0:
//                    iconImageView.image = UIImage(named: "ic_medicine")
//                    dateLabel.hide()
//                    buttonWidthConstraint.constant = actionButton.frame.width + 40
//
//                case 1:
//                    iconImageView.image = UIImage(named: "ic_leave")
//
//                    buttonWidthConstraint.constant = actionButton.frame.width + 40
//
//                case 2:
//                    iconImageView.image = UIImage(named: "ic_gift")
//                case 5:
//                    iconImageView.image = UIImage(named: "ic_anniversary")
//                case 6:
//                    iconImageView.image = UIImage(named: "ic_three_dots")
//                default: break
//            }
//        }
    }
    
    @objc private func didTapActionButton() {
        if item?.type == .EXCHANGE_DAY_OFF && ((item?.maxDay ?? 0) - (item?.isUse ?? 0) > 0){
            actionCallBack?()
        }
    }
}
