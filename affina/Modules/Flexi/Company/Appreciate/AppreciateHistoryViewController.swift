//
//  AppreciateHistoryViewController.swift
//  affina
//
//  Created by Dylan on 24/10/2022.
//

import UIKit

class AppreciateHistoryViewController: BaseViewController {

    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeaderView()
        containerBaseView.hide()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: AppreciateHistoryTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: AppreciateHistoryTableViewCell.identifier)
        
    }

    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        headerBaseView.backgroundColor = .appColor(.blueUltraLighter)?.withAlphaComponent(0.65)
        
        labelBaseTitle.text = "Lịch sử tặng tim".capitalized.localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
    }
}

// MARK: UITableViewDelegate + Datasource
extension AppreciateHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AppreciateHistoryTableViewCell.identifier, for: indexPath) as? AppreciateHistoryTableViewCell else { return UITableViewCell() }
        
        cell.nameLabel.text = "Wade Warren"
        cell.detailLabel.text = "ENTHUSIASTICALLY_SUPPORTED".localize()
        
        let dateText = "-10 "
        let attrs = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: dateText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: "tim")
        attributedString.append(normalString)
        cell.heartLabel.attributedText = attributedString
        
        return cell
    }
}
