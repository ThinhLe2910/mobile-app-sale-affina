//
//  NotificationTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/01/2023.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    static let identifier = "NotificationTableViewCell"
    
    @IBOutlet weak var bgView: BaseView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var contentLabel: BaseLabel!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    var item: NotificationModel? {
        didSet {
            guard let item = item else { return }
            
            contentLabel.attributedText = item.contentShort?.htmlToAttributedString
            dateLabel.text = "\(item.createdAt/1000)".timestampToFormatedDate(format: "dd.MM.yyyy")
            
            if item.eventId != nil {
                bgView.backgroundColor = .appColor(.whiteMain)
            }
            else if item.status == 0 && item.notificationId != nil {
                bgView.backgroundColor = .appColor(.whiteMain)
            }
            else {
                bgView.backgroundColor = .appColor(.blueExtremeLight)
            }
            
            guard let url = URL(string: API.STATIC_RESOURCE + (item.icon ?? "")) else { return }
            CacheManager.shared.imageFor(url: url) { image, error in
                if error != nil {
                    DispatchQueue.main.async {
                        self.iconImageView.image = UIImage(named: "ic_bed")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.iconImageView.image = image
                }
                
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        contentLabel.text = nil
        iconImageView.image = UIImage(named: "ic_bed")
        bgView.backgroundColor = .appColor(.whiteMain)
    }
    
    func showBottomPadding() {
        viewBottomConstraint.constant = 0
    }
    
    func hideBottomPadding() {
        viewBottomConstraint.constant = 12
    }
}
