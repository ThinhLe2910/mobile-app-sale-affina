//
//  SettingsTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/07/2022.
//

import UIKit

struct SettingCellModel {
    var title: String
    let type: Int
    var subText: [String]
    let value: Int
}

class SettingsTableViewCell: UITableViewCell {

    static let cellId = "SettingsTableViewCell"
    static let nib = "SettingsTableViewCell"
    
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var subText: BaseLabel!
    @IBOutlet weak var editButton: BaseButton!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var nextImage: UIImageView!
    
    var showPopupFunc: (() -> Void)?
    var switchCallBack: ((Bool) -> Void)?
    
    var item: SettingCellModel? {
        didSet {
            guard let item = item else {
                return
            }
            titleLabel.text = item.title
            subText.text = "TURN_ON".localize() + ": \(item.subText.isEmpty ? "NONE".localize() : item.subText.joined(separator: " \("AND".localize()) "))"
            if item.type == 1 {
                nextImage.hide(isImmediate: true)
                switchButton.hide(isImmediate: true)
                editButton.show()
                subText.show()
            }
            else if item.type == 2 {
                nextImage.hide(isImmediate: true)
                editButton.hide(isImmediate: true)
                subText.hide(isImmediate: true)
                switchButton.show()
                switchButton.isOn = item.value == 1
            }
            else {
                editButton.hide(isImmediate: true)
                switchButton.hide(isImmediate: true)
                subText.hide(isImmediate: true)
                nextImage.show()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        switchButton.onTintColor = .appColor(.blueMain)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        switchButton.addTarget(self, action: #selector(valueSwitchChanged), for: .valueChanged)
    }
    
    @objc private func didTapEditButton() {
        showPopupFunc?()
    }

    @objc private func valueSwitchChanged() {
        switchCallBack?(switchButton.isOn)
    }
    
}
