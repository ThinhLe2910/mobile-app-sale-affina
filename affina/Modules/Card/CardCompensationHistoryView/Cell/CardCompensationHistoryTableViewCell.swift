//
//  CardCompensationHistoryTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/07/2022.
//

import UIKit

class CardCompensationHistoryTableViewCell: UITableViewCell {
    static let nib = "CardCompensationHistoryTableViewCell"
    static let cellId = "CardCompensationHistoryTableViewCell"
    
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var hospitalLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var statusLabel: BaseButton!
    @IBOutlet weak var treatmentLabel: BaseLabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var notiImageView: UIImageView!
    
    @IBOutlet weak var statusLabelWidthConstraint: NSLayoutConstraint!
    
    var tapCallBack: (() -> Void)?
    
    var item: ClaimHistoryModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            dateLabel.text = "\(item.createdAt/1000)".timestampToFormatedDate(format: "dd.MM.yyyy")
            hospitalLabel.text = item.placeOfTreatment
            
            if item.amountClaim != nil {
                let priceText = "\(Int(item.amountClaim!).addComma()) "
                let currencyText = "VND"
                let attrs2 = [
                    NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)
                ] as [NSAttributedString.Key : Any]
                let attributedString2 = NSMutableAttributedString(string: priceText, attributes: attrs2)
                let normalString2 = NSMutableAttributedString(string: currencyText)
                attributedString2.append(normalString2)
                priceLabel.attributedText = attributedString2
            }
            notiImageView.isHidden = true // item.status != ClaimProcessType.PROCESSING.rawValue
            
            switch item.status {
            case ClaimProcessType.APPROVED.rawValue:
                self.statusLabel.setTitle(ClaimProcessType.APPROVED.string, for: .normal)
                statusLabel.setImage(UIImage(named: "ic_approved_state"), for: .normal)
                priceLabel.textColor = .black
                break
            case ClaimProcessType.PROCESSING.rawValue:
                self.statusLabel.setTitle(ClaimProcessType.PROCESSING.string, for: .normal)
                statusLabel.setImage(UIImage(named: "ic_processing_state"), for: .normal)
                priceLabel.textColor = .appColor(.blueLighter)
                break
            case ClaimProcessType.REJECT.rawValue:
                self.statusLabel.setTitle(ClaimProcessType.REJECT.string, for: .normal)
                statusLabel.setImage(UIImage(named: "ic_reject_state"), for: .normal)
                priceLabel.textColor = .appColor(.blueLighter)
                break
            case ClaimProcessType.REQUIRE_UPDATE.rawValue:
                self.statusLabel.setTitle(ClaimProcessType.REQUIRE_UPDATE.string, for: .normal)
                statusLabel.setImage(UIImage(named: "ic_update_state"), for: .normal)
                priceLabel.textColor = .appColor(.blueLighter)
                break
            case ClaimProcessType.SENT_INFO.rawValue:
                self.statusLabel.setTitle(ClaimProcessType.SENT_INFO.string, for: .normal)
                statusLabel.setImage(UIImage(named: "ic_new_state"), for: .normal)
                priceLabel.textColor = .appColor(.blueLighter)
                break
            default: break
            }
            
            let claimType = ClaimType(rawValue: item.claimType) ?? ClaimType.LABOR_ACCIDENT
            switch claimType {
            case .LABOR_ACCIDENT:
                iconImageView.image = UIImage(named: "ic_accident")
                priceLabel.isHidden = false
            case .TRAFFIC_ACCIDENT:
                iconImageView.image = UIImage(named: "ic_accident")
                priceLabel.isHidden = false
            case .OUTPATIENT:
                iconImageView.image = UIImage(named: "ic_drug_medicine")
                priceLabel.isHidden = false
            case .INPATIENT:
                iconImageView.image = UIImage(named: "ic_bed")
                priceLabel.isHidden = false
            case .DENTISTRY:
                iconImageView.image = UIImage(named: "ic_tooth")
                priceLabel.isHidden = false
            case .HOSPITALIZATION_ALLOWANCE:
                iconImageView.image = UIImage(named: "ic_money")
                priceLabel.isHidden = false
            case .INCOME_SUPPORT:
                iconImageView.image = UIImage(named: "ic_money")
                priceLabel.isHidden = false
            case .MATERNITY:
                iconImageView.image = UIImage(named: "ic_pregnant")
                priceLabel.isHidden = false
            case .DEAD:
                iconImageView.image = UIImage(named: "ic_rip")
                priceLabel.isHidden = true
                //                    statusLabel.setTitle(ClaimProcessType.SENT_INFO.string, for: .normal)
            case .ILLNESS:
                iconImageView.image = UIImage(named: "ic_bed")
                priceLabel.isHidden = false
            case .SUBSIDY_FOR_HOSPITAL_FEE_INCOME:
                iconImageView.image = UIImage(named: "ic_money")
                priceLabel.isHidden = false
            case .DEATH_BY_ACCIDENT_ILLNESS:
                iconImageView.image = UIImage(named: "ic_rip")
                priceLabel.isHidden = false
            }
            
            treatmentLabel.text = claimType.string
            
            statusLabel.sizeToFit()
            statusLabelWidthConstraint.constant = (statusLabel.title(for: .normal)?.widthWithConstrainedHeight(height: statusLabel.frame.height, font: UIConstants.Fonts.appFont(.ExtraBold, 10)) ?? 0) + 16 + 42
            
            contentView.addTapGestureRecognizer { [weak self] in
                self?.tapCallBack?()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addTapGestureRecognizer { [weak self] in
            self?.tapCallBack?()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
