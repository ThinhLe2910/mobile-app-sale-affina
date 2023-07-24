//
//  CardCompensationHistoryView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/07/2022.
//

import UIKit

class CardCompensationHistoryView: BaseView {
    
    static let nib = "CardCompensationHistoryView"

    class func instanceFromNib() -> CardCompensationHistoryView {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CardCompensationHistoryView
    }
    
    @IBOutlet weak var containerView: BaseView!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    var navigationCallBack: ((BaseViewController) -> Void)?
    var didFilterState: ((Int) -> Void)?
    
    var items: [ClaimHistoryModel] = [] {
        didSet {
            yearSections = []
            itemsInSections = []
            
            for item in items {
                let year: String = "\(item.createdAt/1000)".timestampToFormatedDate(format: "yyyy")
                if !yearSections.contains(year) {
                    yearSections.append(year)
                    itemsInSections.append([])
                }
                itemsInSections[itemsInSections.count-1].append(item)
            }
            if yearSections.isEmpty {
                yearSections.append("\(Date().timeIntervalSince1970)".timestampToFormatedDate(format: "yyyy"))
                itemsInSections.append([])
            }

            tableView.reloadData()
        }
    }
    
    var statusFilter: Int = -1
    
    var yearSections: [String] = []
    var itemsInSections: [[ClaimHistoryModel]] = []
    
    var isLoadingMore: Bool = false
    var endReached: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(CardCompensationHistoryView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .clear
        
        tableView.register(UINib(nibName: CardCompensationHistoryHeaderView.nib, bundle: nil), forHeaderFooterViewReuseIdentifier: CardCompensationHistoryHeaderView.headerId)
        tableView.register(UINib(nibName: CardCompensationHistoryTableViewCell.nib, bundle: nil), forCellReuseIdentifier: CardCompensationHistoryTableViewCell.cellId)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    func resetStatusFilter() {
        statusFilter = -1
    }
}

extension CardCompensationHistoryView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return yearSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsInSections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CardCompensationHistoryTableViewCell.cellId, for: indexPath) as? CardCompensationHistoryTableViewCell else { return UITableViewCell() }
        cell.item = itemsInSections[indexPath.section][indexPath.row]
        cell.tapCallBack = { [weak self] in
            guard let self = self else { return }
            if self.itemsInSections[indexPath.section][indexPath.row].claimType == ClaimType.DEAD.rawValue {
                return
            }
            
            let vc = ClaimBenefitDetailViewController()
            vc.claimId = self.itemsInSections[indexPath.section][indexPath.row].id
            self.navigationCallBack?(vc)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CardCompensationHistoryHeaderView.headerId) as! CardCompensationHistoryHeaderView
        headerCell.yearLabel.text = (UIConstants.isVietnamese ? "\("YEAR".localize()) " : "") + "\(yearSections[section])"
        
        headerCell.yearLabel.isHidden = items.isEmpty
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = .clear //UIColor(white: 1, alpha: 1)
        headerCell.backgroundView = backgroundView
        
        headerCell.pickerView(headerCell.statePickerView, didSelectRow: statusFilter+1, inComponent: 0)
        headerCell.statePickerView.selectRow(statusFilter+1, inComponent: 0, animated: true)

        headerCell.textFieldResponderCallback = {
            headerCell.categoryTextField.becomeFirstResponder()
        }
        
        headerCell.didFilterState = { [weak self] state in
            headerCell.categoryTextField.resignFirstResponder()
            self?.didFilterState?(state)
            self?.statusFilter = state
        }
        
        if section != 0 {
            headerCell.hideFilterButton()
        }
        else {
            headerCell.showFilterButton()
        }
        
        return headerCell
    }
    
    
    
}
