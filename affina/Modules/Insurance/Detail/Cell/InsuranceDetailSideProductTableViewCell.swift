//
//  InsuranceDetailSideProductTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/08/2022.
//

import UIKit

class InsuranceDetailSideProductTableViewCell: UITableViewCell {
    
    static let nib = "InsuranceDetailSideProductTableViewCell"
    static let cellId = "InsuranceDetailSideProductTableViewCell"
    
    @IBOutlet weak var coverView: BaseView!
    
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var priceLabel: BaseLabel!
    @IBOutlet weak var listView: BaseView! // parent table view
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var additionPriceLabel: BaseLabel!
    @IBOutlet weak var addButton: BaseButton!
    @IBOutlet weak var addView: BaseView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    var selectedTimeIndex: Int = 0
    
    var item: [ListProductSubSideBenefit] = [] {
        didSet {
            tableView.reloadData()
            tableHeightConstraint.constant = tableView.contentSize.height + (item.isEmpty ? 16 : 56)
            self.layoutIfNeeded()
        }
    }
    
    var isAdded: Bool = false
    
    var addCallBack: (() -> Void)?
    var removeCallBack: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        coverView.layer.borderColor = UIColor.appColor(.blueMain)?.cgColor
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: SideProductItemTableViewCell.nib, bundle: nil), forCellReuseIdentifier: SideProductItemTableViewCell.cellId)
        
        addView.addTapGestureRecognizer {
            self.didTapBuyView()
        }
        
        addButton.addTapGestureRecognizer {
            self.didTapBuyView()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isAdded = false
        tableView.reloadData()
        tableHeightConstraint.constant = self.tableView.contentSize.height + (item.isEmpty ? 16 : 40)
        listView.isHidden = self.isAdded
        addButton.setImage(UIImage(named: self.isAdded ? "ic_close" : "ic_cart"), for: .normal)
        self.addButton.sizeToFit()
        self.addView.backgroundColor = .appColor(self.isAdded ? .backgroundGray : .pinkUltraLighter)
        coverView.layer.borderWidth = 0
    }
    
    private func didTapBuyView() {
        self.isAdded = !self.isAdded
        listView.isHidden = self.isAdded
        if self.isAdded {
            coverView.layer.borderWidth = 2
            
            DispatchQueue.main.async {
                var indexPaths: [IndexPath] = []
                for i in 0..<self.item.count {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                self.tableView.deleteRows(at: indexPaths, with: .fade)
                self.tableHeightConstraint.constant = 12
                self.layoutIfNeeded()
                self.addCallBack?()
            }
        }
        else {
            coverView.layer.borderWidth = 0
            DispatchQueue.main.async {
                var indexPaths: [IndexPath] = []
                for i in 0..<self.item.count {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                self.tableView.insertRows(at: indexPaths, with: .fade)
                self.tableHeightConstraint.constant = self.tableView.contentSize.height + (self.item.isEmpty ? 16 : 40)
                self.layoutIfNeeded()
                self.removeCallBack?()
            }
        }
        self.addButton.setImage(UIImage(named: self.isAdded ? "ic_close" : "ic_cart"), for: .normal)
        self.addButton.sizeToFit()
        self.addView.backgroundColor = .appColor(self.isAdded ? .backgroundGray : .pinkUltraLighter)
    }
}

extension InsuranceDetailSideProductTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAdded {
            return 0
        }
        return item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideProductItemTableViewCell.cellId, for: indexPath) as? SideProductItemTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = item[indexPath.row].name
        cell.separator.isHidden = indexPath.row == item.count - 1
        
        let normalText = " vnd"
        let boldText = "\((item[indexPath.row].listMaximumAmountSubSideBenefit?[selectedTimeIndex].maximumAmount ?? 0).addComma())"
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 12)] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.append(normalString)
        cell.priceLabel.attributedText = attributedString
        
        return cell
    }
}
