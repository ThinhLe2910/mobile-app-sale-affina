//
//  InsuranceChooseCompanyTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit

protocol InsuranceChooseCompanyDelegate {
    func didTapCell(item: CompanyProvider, selected: Bool)
    
}

class InsuranceChooseCompanyTableViewCell: UITableViewCell {

    static let nib = "InsuranceChooseCompanyTableViewCell"
    static let cellId = "InsuranceChooseCompanyTableViewCell"
    
    @IBOutlet weak var checkBox: BaseButton!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var separator: BaseView!
    
    var isChecked = false
    var item: CompanyProvider? {
        didSet {
            guard let item = item else { return }
            let normalText = " (\(item.numberPackage) \("PRODUCT".localize().lowercased()))"
            let boldText = "\(item.name)"
            let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)] as [NSAttributedString.Key : Any]
            let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
            let normalString = NSMutableAttributedString(string: normalText)
            attributedString.append(normalString)
            nameLabel.attributedText = attributedString
//            nameLabel.text = item.name
        }
    }
    
    var delegate: InsuranceChooseCompanyDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        checkBox.borderWidth = 1
        checkBox.borderColor = "grayBorder"
        
        checkBox.addTarget(self, action: #selector(didTapCheckBoxButton), for: .touchUpInside)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isChecked = false
        checkBox.borderWidth = 1
        checkBox.setImage(nil, for: .normal)
        checkBox.backgroundColor = .appColor(.whiteMain)
    }

    @objc private func didTapCheckBoxButton() {
        guard let item = item else {
            return
        }
        
        isChecked.toggle()
        
        checkBox.borderWidth = isChecked ? 0 : 1
        checkBox.setImage(isChecked ? UIImage(named: "ic_check")?.withRenderingMode(.alwaysTemplate) : nil, for: .normal)
        checkBox.backgroundColor = .appColor(isChecked ? .blueMain : .whiteMain)
        
        delegate?.didTapCell(item: item, selected: isChecked)
    }
    
}
