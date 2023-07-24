//
//  DoubleColumnTableViewCell.swift
//  affina
//
//  Created by Dylan on 28/09/2022.
//

import UIKit

class DoubleColumnTableViewCell: UITableViewCell {

    static let cellId = "DoubleColumnTableViewCell"
    static let nib = "DoubleColumnTableViewCell"
    
    @IBOutlet weak var contentStackView: UIStackView!
    
    @IBOutlet weak var contentSeparator: BaseView!
    @IBOutlet weak var leftSeparator: BaseView!
    @IBOutlet weak var rightSeparator: BaseView!
    
    @IBOutlet weak var leftTitleLabel: BaseLabel!
    @IBOutlet weak var leftTextLabel: BaseLabel!
    
    @IBOutlet weak var rightTitleLabel: BaseLabel!
    @IBOutlet weak var rightTextLabel: BaseLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setTitle(title: String) {
        let strs = title.split(separator: "@").map({ String($0) })
        leftTitleLabel.text = strs[0]
        rightTitleLabel.text = strs[1]
    }
    
    func showContentSeparator(_ show: Bool) {
        if show {
            leftSeparator.hide(isImmediate: true)
            rightSeparator.hide(isImmediate: true)
            contentSeparator.show()
        }
        else {
            leftSeparator.show()
            rightSeparator.show()
            contentSeparator.hide(isImmediate: true)
        }
    }
    
    func setText(text: String) {
        let strs = text.split(separator: "@").map({ String($0) })
        leftTextLabel.text = strs[0]
        rightTextLabel.text = strs[1]
    }
}
