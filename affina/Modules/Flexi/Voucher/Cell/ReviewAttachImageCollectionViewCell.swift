//
//  ReviewAttachImageCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 20/10/2022.
//

import UIKit

class ReviewAttachImageCollectionViewCell: UICollectionViewCell {

    static let nib = "ReviewAttachImageCollectionViewCell"
    static let cellId = "ReviewAttachImageCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIImageView!
    
    var deleteCallBack: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        deleteButton.addTapGestureRecognizer {
            self.deleteCallBack?()
        }
    }

}
