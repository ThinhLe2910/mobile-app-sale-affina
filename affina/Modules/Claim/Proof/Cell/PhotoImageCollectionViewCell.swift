//
//  PhotoImageCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 04/10/2022.
//

import UIKit

class PhotoImageCollectionViewCell: UICollectionViewCell {

    static let nib = "PhotoImageCollectionViewCell"
    static let cellId = "PhotoImageCollectionViewCell"
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkImageView: BaseView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        checkImageView.isHidden = false
        cameraImageView.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.isHidden = true
        cameraImageView.isHidden = true
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setChecked() {
        checkImageView.isHidden = false
    }
    
    func setUnChecked() {
        checkImageView.isHidden = true
    }
}
