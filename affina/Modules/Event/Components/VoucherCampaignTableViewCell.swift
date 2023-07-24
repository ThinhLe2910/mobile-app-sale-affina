//
//  VoucherCampaignTableViewCell.swift
//  affina
//
//  Created by Intelin MacHD on 04/04/2023.
//

import UIKit

class VoucherCampaignTableViewCell: UITableViewCell {

    @IBOutlet weak var expiredLabel: UILabel!
    @IBOutlet weak var expiredDate: UILabel!
    @IBOutlet weak var voucherIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    static let nib = "VoucherCampaignTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutViews()
    }
    
    var data: EventVoucherModel? {
        didSet {
            if data != nil {
                titleLabel.text = data!.voucherName
                expiredDate.text = "EXPIRE_DATE".localize() + " " + Date(timeIntervalSince1970: Double(data!.toDate ?? 0) / 1000).convertToString(with: "dd.MM.YYYY")
                if (Int64(Date().startOfDay.timeIntervalSince1970) / 1000 > data!.toDate ?? 0) {
                    expiredLabel.isHidden = false
                } else {
                    expiredLabel.isHidden = true
                }
                loadImage()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadImage() {
        guard let data = data else { return }
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            if data.images != nil {
                if data.images!.count > 0 {
                    do {
                        guard let images = data.images else { return }
                        let json = try JSONDecoder().decode([String: String].self, from: images.data(using: .utf16) ?? Data())
                        let urlString = (json["image_1"] != nil) ? "\(API.STATIC_RESOURCE)\(json["image_1"] ?? "")" : ""
                        guard let url = URL(string: urlString) else { return }
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.voucherIcon.image = UIImage(data: data)
                        }
                    } catch(let e) {
                        Logger.Logs(message: e.localizedDescription)
                    }
                }
            }
        }
    }
    
    func layoutViews() {
        expiredDate.text = "EXPIRE_DATE".localize()
        expiredLabel.text = "EXPIRED".localize().uppercased()
//        roundCorners([.allCorners], radius: 16.height)
        containerView.layer.cornerRadius = 16.height
        containerView.layer.masksToBounds = true
        selectionStyle = .none
    }
}
