//
//  NotiSettingsViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/07/2022.
//

import UIKit

class NotiSettingsViewController: BaseViewController {

    static let nib = "NotiSettingsViewController"

    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var saveButton: BaseButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    private var items: [SettingCellModel] = [
        SettingCellModel(title: "PROMTION_NEWS_OFFERS".localize(), type: 1, subText: ["Email"], value: 0),
        SettingCellModel(title: "NOTIFICATION_FROM_AFFINA".localize(), type: 1, subText: ["Email", "PUSH_NOTIFICATION".localize()], value: 0),
        SettingCellModel(title: "NEW_MESSAGE".localize(), type: 1, subText: ["Email", "PUSH_NOTIFICATION".localize()], value: 0),
        SettingCellModel(title: "NOTIFICATION_FROM_COMPANY".localize(), type: 1, subText: ["Email", "PUSH_NOTIFICATION".localize()], value: 0)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        hideHeaderBase()
        containerBaseView.hide()

        view.backgroundColor = .appColor(.blueUltraLighter)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: SettingsTableViewCell.nib, bundle: nil), forCellReuseIdentifier: SettingsTableViewCell.cellId)

        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }

    @objc private func didTapSaveButton() {

    }

    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension NotiSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.cellId, for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
        cell.item = items[indexPath.row]
        cell.selectionStyle = .none
        cell.showPopupFunc = {
            self.showCustomBottomPopup(index: indexPath.row)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NotiSettingsViewController {
    @objc func hideCustomBottomNotiSettingPopup() {
        if successView != nil {
            self.clearScreen.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                var frame = self.successView!.frame
                frame.origin.y = self.view.frame.height // Move to bottom
                self.successView!.frame = frame
            }) { (_) in
                if self.successView != nil {
                    self.successView!.removeFromSuperview()
                    self.successView = nil
                }
            }
        }
    }

    func showCustomBottomPopup(index: Int) {
//        self.successCompletion = closure
        let dialogWidth = UIConstants.Layout.screenWidth - 8
        if successView == nil {
            DispatchQueue.main.async {
                self.view.addSubview(self.clearScreen)
                self.successView = NotificationSettingView(frame: .init(x: 4, y: UIConstants.Layout.screenHeight + UIConstants.heightConstraint(236), width: dialogWidth, height: UIConstants.heightConstraint(236)))
                guard let successView = self.successView else {
                    return
                }
                (successView as? NotificationSettingView)?.setData(model: self.items[index])
                (successView as? NotificationSettingView)?.closeCallBack = {
                    self.hideCustomBottomNotiSettingPopup()
                }

                (successView as? NotificationSettingView)?.emailCallBack = { isOn in
                    if isOn {
                        self.items[index].subText.insert("EMAIL".localize(), at: 0)
                    }
                    else {
                        self.items[index].subText.removeFirst()
                    }
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }

                (successView as? NotificationSettingView)?.pushCallBack = { isOn in
                    if isOn {
                        self.items[index].subText.append("PUSH_NOTIFICATION".localize())
                    }
                    else {
                        self.items[index].subText.removeLast()
                    }
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }

                self.view.addSubview(successView)

                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    var frame = self.successView!.frame
                    frame.origin.y = self.view.frame.height - UIConstants.heightConstraint(236)
                    self.successView!.frame = frame
                })
            }
        }
    }

}
