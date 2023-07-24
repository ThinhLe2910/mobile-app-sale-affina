//
//  ContractBenefitViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 05/08/2022.
//

import UIKit

struct ContractTermModel {
    let title: String
    let desc: String
    let subDescs: [String]
}

class ContractBenefitViewController: BaseViewController {
    
    @IBOutlet weak var benefitLabel: BaseLabel!
    @IBOutlet weak var maxAmountLabel: BaseLabel!
    
    @IBOutlet weak var remainAmountLabel: BaseLabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var termsButton: BaseButton!
    @IBOutlet weak var historyButton: BaseButton!
    
    @IBOutlet weak var privacyView: BaseView!
    @IBOutlet weak var historyView: BaseView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var usedViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
     var benefitId : String?
    private var isHistoryView = false
    
    private let termsHeaders: [String] = [
        "BENEFIT".localize(),
//        "APPLICALE".localize(),
//        "PAYMENT_METHOD".localize(),
//        "INSURANCE_EXCLUSION".localize(),
//        "PARTICIPATION_TERMS".localize()
    ]
    
    private var historyHeaders: [String] = [
        "\("YEAR".localize()) 2022"
    ]
    
    var terms: [[ContractTermModel]] = [[
        ContractTermModel(title: "Sed cursus nulla eu mi lacinia:", desc: "Phasellus eleifend mauris at pellentesque placerat. Sed ac viverra eros.", subDescs: []),
        ContractTermModel(title: "Mauris mattis nulla enim:", desc: "Donec consequat felis vel leo iaculis tincidunt. Donec eget nisi eros.", subDescs: []),
        ContractTermModel(title: "Integer imperdiet turpis in dui vehicula:", desc: "Vestibulum faucibus luctus est eget volutpat. Proin eget feugiat leo. Etiam sit amet tincidunt risus, eu lobortis dui.", subDescs: ["Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.", "Proin varius mollis augue, eu suscipit odio commodo sit amet.", "Sed quis volutpat mi."]),
    ], [], [], [], []]
    
    private let historys: [ContractCompensationHistoryModel] = [
        ContractCompensationHistoryModel(hospitalName: "Bệnh viện Vestibulum", diagnostic: "Curabitur varius, diam eu malesuada dignissim, lorem justo placerat nulla, sed feugiat est velit vel ante.", price: 20000000, date: "22.06.2022", type: "OUTPATIENT_TREATMENT".localize(), status: 0),
        ContractCompensationHistoryModel(hospitalName: "Bệnh viện Praesent Porttitor Tempor Elit", diagnostic: "Curabitur varius, diam eu malesuada dignissim, lorem justo placerat nulla, sed feugiat est velit vel ante.", price: 200000, date: "10.04.2022", type: "Điều trị nội trú", status: 1),
        ContractCompensationHistoryModel(hospitalName: "Bệnh viện Praesent Porttitor Tempor Elit", diagnostic: "Curabitur varius, diam eu malesuada dignissim, lorem justo placerat nulla, sed feugiat est velit vel ante.", price: 200000, date: "10.04.2022", type: "Điều trị nội trú", status: 2)
    ]
    
    private var hiddenSections = Set<Int>()
    
    var maximumAmount: Int = 0
    var benefitName: String = ""
    var contractId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerBaseView.hide(isImmediate: true)
        //        view.backgroundColor = .appColor(.backgroundLightGray)
        view.backgroundColor = .appColor(.blueUltraLighter)
        setIcon()
        setupHeaderView()
        
        benefitLabel.text = benefitName
        maxAmountLabel.text = "" // "\(maximumAmount.addComma()) vnd"
        remainAmountLabel.text = "\(maximumAmount.addComma()) vnd"
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        usedViewWidthConstraint.constant = 0
        stackView.spacing = 0
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ContractBenefitTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ContractBenefitTableViewCell.cellId)
        tableView.register(UINib(nibName: ContractCompensationHistoryTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ContractCompensationHistoryTableViewCell.cellId)
        tableView.register(UINib(nibName: ContractBenefitHeaderView.nib, bundle: nil), forHeaderFooterViewReuseIdentifier: ContractBenefitHeaderView.headerId)
        tableView.register(UINib(nibName: ContractCompensationHistoryHeaderView.nib, bundle: nil), forHeaderFooterViewReuseIdentifier: ContractCompensationHistoryHeaderView.headerId)
        
        didTapTermsButton()
        
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(didTapHistoryButton), for: .touchUpInside)
    }
    
    override func initViews() {
        setupHeaderView()
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "Hợp Đồng".localize() + " #\(contractId)" // " #\(contractId.prefix(6))"
        labelBaseTitle.frame = CGRect(x: UIConstants.widthConstraint(30), y: 0, width: 272.width, height: UIConstants.heightConstraint(24))
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        labelBaseTitle.center.x = headerBaseView.center.x
        labelBaseTitle.center.y = leftBaseImage.center.y
    }
    private func setIcon(){
        guard let benefitId = benefitId else{
            return
        }
        if let url = URL(string: benefitId) {
            CacheManager.shared.imageFor(url: url) { image, error in
                DispatchQueue.main.async {
                    if error != nil {
                        return
                    }
                    self.iconImageView.image = image
                }
            }
        }
    }
    @objc private func didTapTermsButton() {
        termsButton.backgroundAsset = "blueMain"
        termsButton.colorAsset = "whiteMain"
        historyButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        historyButton.colorAsset = "subText"
        //        historyView.hide(isImmediate: true)
        //        privacyView.show()
        
        isHistoryView = false
        tableView.reloadData()
    }
    
    @objc private func didTapHistoryButton() {
        historyButton.backgroundAsset = "blueMain"
        historyButton.colorAsset = "whiteMain"
        termsButton.backgroundColor = UIColor(r: 255, g: 255, b: 255, a: 0.45)
        termsButton.colorAsset = "subText"
        //        privacyView.hide(isImmediate: true)
        //        historyView.show()
        
        isHistoryView = true
        tableView.reloadData()
    }
    
    @objc private func hideSection(section: Int) {
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.terms[section].count {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            
            
            return indexPaths
        }
        if terms[section].isEmpty { return }
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(), with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(), with: .fade)
        }
    }
}

extension ContractBenefitViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if isHistoryView {
            return historyHeaders.count
        }
        
        return termsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isHistoryView {
            return historys.count // historyHeaders[section].count
        }
        if self.hiddenSections.contains(section) {
            return 0
        }
        
        return terms[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isHistoryView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContractCompensationHistoryTableViewCell.cellId, for: indexPath) as? ContractCompensationHistoryTableViewCell else { return UITableViewCell() }
            cell.item = historys[indexPath.row]
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ContractBenefitTableViewCell.cellId, for: indexPath) as? ContractBenefitTableViewCell else { return UITableViewCell() }
            cell.item = terms[indexPath.section][indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isHistoryView {
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ContractCompensationHistoryHeaderView.headerId) as! ContractCompensationHistoryHeaderView
            headerCell.yearLabel.text = historyHeaders[section]
            let backgroundView = UIView(frame: CGRect.zero)
            backgroundView.backgroundColor = .clear //UIColor(white: 1, alpha: 1)
            headerCell.backgroundView = backgroundView
            return headerCell
            
        }
        else {
            let headerCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ContractBenefitHeaderView.headerId) as! ContractBenefitHeaderView
            headerCell.titleLabel.text = termsHeaders[section]
            let backgroundView = UIView(frame: CGRect.zero)
            backgroundView.backgroundColor = .clear //UIColor(white: 1, alpha: 1)
            headerCell.backgroundView = backgroundView
            headerCell.addTapGestureRecognizer {
                self.hideSection(section: section)
                headerCell.rotateDropdown()
            }
            return headerCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isHistoryView {
            return 36
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isHistoryView {
            return UITableView.automaticDimension
        }
//        var height: CGFloat = 0.0
//        if indexPath.row == 2 {
//            let item = terms[indexPath.row]
//            if !item.subDescs.isEmpty {
//                for text in item.subDescs {
//                    height += CGFloat(Int(text.heightWithConstrainedWidth(width: tableView.bounds.width - 20, font: UIConstants.Fonts.appFont(.Medium, 16))) + 8)
//                }
//            }
//            return height
//        }
        return UITableView.automaticDimension
    }
}
