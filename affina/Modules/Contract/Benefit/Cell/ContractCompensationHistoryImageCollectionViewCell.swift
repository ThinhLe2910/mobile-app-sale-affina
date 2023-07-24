//
//  ContractCompensationHistoryImageCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

class ContractCompensationHistoryImageCollectionViewCell: UICollectionViewCell {

    static let nib = "ContractCompensationHistoryImageCollectionViewCell"
    static let cellId = "ContractCompensationHistoryImageCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var moreView: BaseView!
    @IBOutlet weak var moreLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//    }
}
