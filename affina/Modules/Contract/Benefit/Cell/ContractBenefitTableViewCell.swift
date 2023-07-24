//
//  ContractBenefitTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/08/2022.
//

import UIKit

class ContractBenefitTableViewCell: UITableViewCell {

    static let nib = "ContractBenefitTableViewCell"
    static let cellId = "ContractBenefitTableViewCell"
    
    @IBOutlet weak var titleLabel: BaseLabel!
    @IBOutlet weak var descLabel: BaseLabel!
    @IBOutlet weak var separator: BaseView!
    @IBOutlet weak var separatorTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    var item: ContractTermModel? {
        didSet {
            guard let item = item else { return }
            let doc1 = item.title.htmlToAttributedString // htmlToString
            let doc2 = item.desc.htmlToAttributedString // htmlToString
            titleLabel.attributedText = doc1
            descLabel.attributedText = doc2
            
            if !item.subDescs.isEmpty {
                tableView.reloadData()
                separator.isHidden = false
                separatorTopConstraint.constant = 19
            }
            else {
                separator.isHidden = true
                separatorTopConstraint.constant = 4
            }
            setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
//        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: BenefitIconTableViewCell.nib, bundle: nil), forCellReuseIdentifier: BenefitIconTableViewCell.cellId)
    }

}

extension ContractBenefitTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item?.subDescs.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = item, let cell = tableView.dequeueReusableCell(withIdentifier: BenefitIconTableViewCell.cellId, for: indexPath) as? BenefitIconTableViewCell else {
            return UITableViewCell()
        }
        cell.label.text = item.subDescs[indexPath.row].htmlToString
        return cell
    }
}
