//
//  ContractBenefitHeaderView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/08/2022.
//

import UIKit

class ContractBenefitHeaderView: UITableViewHeaderFooterView {

    static let nib = "ContractBenefitHeaderView"
    static let headerId = "ContractBenefitHeaderView"
    
    class func instanceFromNib() -> ContractBenefitHeaderView {
        return UINib(nibName: ContractBenefitHeaderView.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ContractBenefitHeaderView
    }
    
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var dropdownImageView: UIImageView!
    @IBOutlet weak var separator: BaseView!
    
    private var isRotating = false
    override func awakeFromNib() {
        super.awakeFromNib()
        let rotation = isRotating ? 0 : .pi
        dropdownImageView.transform = CGAffineTransform.identity.rotated(by: rotation)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dropdownImageView.transform = CGAffineTransform.identity.rotated(by: isRotating ? 0 : .pi)

    }
    
    func rotateDropdown() {
        isRotating = !isRotating
        dropdownImageView.transform = CGAffineTransform.identity.rotated(by: isRotating ? 0 : .pi)
        if !isRotating {
            separator.hide()
        }
        else {
            separator.show()
        }
    }
}
