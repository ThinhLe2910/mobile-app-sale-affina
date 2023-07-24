//
//  CardHospitalTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/07/2022.
//

import UIKit

class CardHospitalTableViewCell: UITableViewCell {

    static let nib = "CardHospitalTableViewCell"
    static let cellId = "CardHospitalTableViewCell"
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var addressLabel: BaseLabel!
    @IBOutlet weak var calendarButton: BaseButton!
    
    var isPinned: Bool = false
    
    var tapCallBack: (() -> Void)?
    
    var item: HospitalModel? {
        didSet {
            guard let item = item else { return }
            nameLabel.text = item.name
            addressLabel.text = item.address
//            logoImageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        selectionStyle = .none
        
        pinImageView.isHidden = true
        
        pinImageView.addTapGestureRecognizer {
            self.isPinned.toggle()
            self.pinImageView.image = UIImage(named: self.isPinned ? "ic_pin.fill" : "ic_pin")
        }
        
        contentView.addTapGestureRecognizer { [weak self] in
            self?.tapCallBack?()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.pinImageView.image = UIImage(named: "ic_pin")
    }
    
}
