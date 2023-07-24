//
//  AttachedImageCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 22/09/2022.
//

import UIKit

class AttachedImageCollectionViewCell: UICollectionViewCell {

    static let nib = "AttachedImageCollectionViewCell"
    static let cellId = "AttachedImageCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var addImageView: UIImageView!
    
    @IBOutlet weak var moreBg: BaseView!
    @IBOutlet weak var moreLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        moreBg.layer.opacity = 0.6
        moreBg.isHidden = true
        addImageView.isHidden = true
    }
    
    func setImage(_ image: UIImage?) {
        if image == nil {
////            addImageView.show()
//            imageView.hide(isImmediate: true)
            
            addImageView.isHidden = false
            imageView.isHidden = true
        }
        else {
//            imageView.show()
////            addImageView.hide(isImmediate: true)
///
            addImageView.isHidden = true
            imageView.isHidden = false
        }
        imageView.image = image
        
    }
    
    func showMoreText(moreNumber: Int) {
        moreBg.isHidden = false
        moreLabel.text = "+ \(moreNumber)"
        addImageView.isHidden = true
    }
    
    func hideMoreText() {
        moreBg.isHidden = true
        addImageView.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.isHidden = true
        imageView.image = nil
        moreLabel.text = nil
        moreBg.isHidden = true
        addImageView.isHidden = true
    }
}
