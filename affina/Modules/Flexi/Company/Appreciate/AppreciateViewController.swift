//
//  AppreciateViewController.swift
//  affina
//
//  Created by Dylan on 21/10/2022.
//

import UIKit

class AppreciateViewController: BaseViewController {
    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var benefitView: BaseView!
    @IBOutlet weak var benefitHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moneyLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var usedMoneyLabel: BaseLabel!
    
    @IBOutlet weak var moneyProgressView: UIProgressView!
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var searchTextField: TextFieldAnimBase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        //
        moneyProgressView.trackTintColor = .appColor(.pinkUltraLighter)
        moneyProgressView.progressTintColor = .appColor(.blue)
        moneyProgressView.layer.cornerRadius = 2
        moneyProgressView.layer.masksToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: EmployeeTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: EmployeeTableViewCell.identifier)
        
        let dateText = "32/09/2023"
        let attrs = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.ExtraBold, 10)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: dateText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: "\("EXPIRY".localize()): ")
        attributedString.insert(normalString, at: 0)
        dateLabel.attributedText = attributedString
        
        let usedPointText = "20.000 đ"
        let attrs2 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.ExtraBold, 10)
        ] as [NSAttributedString.Key : Any]
        let attributedString2 = NSMutableAttributedString(string: usedPointText, attributes: attrs2)
        let normalString2 = NSMutableAttributedString(string: "\("USED".localize()): ")
        attributedString2.insert(normalString2, at: 0)
        usedMoneyLabel.attributedText = attributedString2
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        headerBaseView.backgroundColor = .appColor(.blueUltraLighter)?.withAlphaComponent(0.65)
        
        labelBaseTitle.text = "Tặng tim".capitalized.localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_clock")
        rightBaseImage.addTapGestureRecognizer {
            let vc = AppreciateHistoryViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension AppreciateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmployeeTableViewCell.identifier, for: indexPath) as? EmployeeTableViewCell else { return UITableViewCell() }
        cell.nameLabel.text = "Wade Warren"
        cell.titleLabel.text = "Ullamco est sit aliqua dolor do amet"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let view = EmployeeGivingHeartView()
        view.cancelCallBack = {
            self.hideBottomSheet(animated: true)
        }
        view.submitCallBack = {
            self.hideBottomSheet(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.queueBasePopup(icon: UIImage(named: "ic_question_mark_circle"), title: "Bạn muốn dùng 200 tim?", desc: "TO_GIVE_TO_ROBERT_FOX".localize(), okTitle: "CONFIRM".localize(), cancelTitle: "CANCEL".localize()) {
                    self.hideBasePopup()
                    self.queueBasePopup(icon: UIImage(named: "ic_check_circle"), title: "SUCCESSFULLY_GIFT_GIVING".localize(), desc: "200 tim sẽ được chuyển đổi thành 200 điểm Affina ở tài khoản của Robert Fox", okTitle: "GOT_IT".localize(), cancelTitle: "") {
                        self.hideBasePopup()
//                        self.view.addSubview(self.grayScreen)
//                        self.view.bringSubviewToFront(self.bottomSheet.view)
                    } handler: {
                        
                    }
                } handler: {
//                    self.view.addSubview(self.grayScreen)
//                    self.view.bringSubviewToFront(self.bottomSheet.view)
                }
            }

        }
        bottomSheet.topBarView.backgroundColor = .appColor(.blueUltraLighter)
        bottomSheet.view.backgroundColor = .appColor(.blueUltraLighter)
        bottomSheet.setContentForBottomSheet(view)
        setNewBottomSheetHeight(568.height)
        showBottomSheet(animated: true)
    }
}
