//
//  ExtraInfoView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/08/2022.
//

import UIKit
struct listTerms{
    var isOpen : Bool
    var data :[ContractTermModel]
}
class ExtraInfoView: BaseView {
    
    static let nib = "ExtraInfoView"
    class func instanceFromNib() -> ExtraInfoView {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ExtraInfoView
    }
    
    @IBOutlet weak var containerView: BaseView!
    @IBOutlet weak var tableView: UITableView! // ContentSizedTableView!
    private var termsModel: InsuranceTermsModel?
    private let termsHeaders: [String] = [
        "BENEFIT".localize(),
        "APPLICALE".localize(),
        "PAYMENT_METHOD".localize(),
        "INSURANCE_EXCLUSION".localize(),
        "PARTICIPATION_TERMS".localize()
    ]
    private var list : [listTerms] = [listTerms(isOpen: false, data: [])]
    private var terms = [[
        ContractTermModel(title: "Sed cursus nulla eu mi lacinia:", desc: "Phasellus eleifend mauris at pellentesque placerat. Sed ac viverra eros.", subDescs: []),
        ContractTermModel(title: "Mauris mattis nulla enim:", desc: "Donec consequat felis vel leo iaculis tincidunt. Donec eget nisi eros.", subDescs: []),
        ContractTermModel(title: "Integer imperdiet turpis in dui vehicula:", desc: "Vestibulum faucibus luctus est eget volutpat. Proin eget feugiat leo. Etiam sit amet tincidunt risus, eu lobortis dui.", subDescs: ["Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", "Proin varius mollis augue, eu suscipit odio commodo sit amet.", "Sed quis volutpat mi."]),
    ], [], [], [], []]
  
    
    var hiddenSections = Set<Int>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        Bundle.main.loadNibNamed(ExtraInfoView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .appColor(.whiteMain)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ContractBenefitHeaderView.nib, bundle: nil), forHeaderFooterViewReuseIdentifier: ContractBenefitHeaderView.headerId)
        tableView.register(UINib(nibName: ContractBenefitTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ContractBenefitTableViewCell.cellId)
    }
    @objc private func openSection(section: Int) {
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.list[section].data.count {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            return indexPaths
        }
        if list[section].data.count == 0 { return }
        if list[section].isOpen {
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(), with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
        }
    }
    
    func setTerms(terms: InsuranceTermsModel) {
        termsModel = terms
        self.list[0] = (listTerms(isOpen: false, data: [ContractTermModel(title: "", desc: terms.benefit ?? "", subDescs: [])]))
        self.list.append(listTerms(isOpen: false, data:  [ContractTermModel(title: "", desc: terms.applicableObject ?? "", subDescs: [])]))
        self.list.append(listTerms(isOpen: false, data:   [ContractTermModel(title: "", desc: terms.feePaymentMethod ?? "", subDescs: [])]))
        self.list.append(listTerms(isOpen: false, data:  terms.listExclusionTerms.map({ ContractTermModel(title: $0.name, desc: $0.content ?? "", subDescs: []) })))
        self.list.append(listTerms(isOpen: false, data:  terms.listParticipationTerms.map({ ContractTermModel(title: $0.name, desc: $0.content ?? "", subDescs: []) })))
        tableView.reloadData()
    }
}

extension ExtraInfoView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return termsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !list[section].isOpen {
            return 0
        }
        
        return list[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContractBenefitTableViewCell.cellId, for: indexPath) as? ContractBenefitTableViewCell else { return UITableViewCell() }
        cell.item = list[indexPath.section].data[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ContractBenefitHeaderView.headerId) as! ContractBenefitHeaderView
        headerCell.titleLabel.text = termsHeaders[section]
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = .clear //UIColor(white: 1, alpha: 1)
        headerCell.backgroundView = backgroundView
        headerCell.addTapGestureRecognizer {
            self.list[section].isOpen = !self.list[section].isOpen
            self.openSection(section: section)
            headerCell.rotateDropdown()
        }
        return headerCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
