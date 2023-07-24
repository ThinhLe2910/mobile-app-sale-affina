//
//  CommentTableViewCell.swift
//  affina
//
//  Created by Dylan on 10/10/2022.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    static let cellId = "CommentTableViewCell"
    static let nib = "CommentTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var usernameLabel: BaseLabel!
    @IBOutlet weak var commentLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    
}
