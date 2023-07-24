//
//  PaddingTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/06/2022.
//

import UIKit

class PaddingTableViewCell: UITableViewCell {
    
    var inset: UIEdgeInsets = .zero
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: inset)
    }
}
