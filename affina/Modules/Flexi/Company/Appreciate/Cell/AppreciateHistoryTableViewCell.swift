//
//  AppreciateHistoryTableViewCell.swift
//  affina
//
//  Created by Dylan on 24/10/2022.
//

import UIKit

class AppreciateHistoryTableViewCell: UITableViewCell {
    static let identifier = "AppreciateHistoryTableViewCell"
    
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var heartLabel: BaseLabel!
    @IBOutlet weak var detailLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        avatarImageView.image = nil
    }
}
