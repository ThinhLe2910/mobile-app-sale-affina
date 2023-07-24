//
//  ContractCompensationHistoryHeaderView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/08/2022.
//

import UIKit

class ContractCompensationHistoryHeaderView: UITableViewHeaderFooterView {

    static let nib = "ContractCompensationHistoryHeaderView"
    static let headerId = "ContractCompensationHistoryHeaderView"
    
    class func instanceFromNib() -> ContractCompensationHistoryHeaderView {
        return UINib(nibName: ContractCompensationHistoryHeaderView.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ContractCompensationHistoryHeaderView
    }
    
    @IBOutlet weak var yearLabel: BaseLabel!
    @IBOutlet weak var calendarButton: BaseButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }

}
