//
//  SecuritySettingsViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 20/07/2022.
//

import UIKit
import LocalAuthentication

class SecuritySettingsViewController: BaseViewController {

    static let nib = "SecuritySettingsViewController"
    
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    private var items: [SettingCellModel] = [
        SettingCellModel(title: "CHANGE_PIN_CODE".localize(), type: 3, subText: [], value: 0),
        SettingCellModel(title: "ACCOUNT_RECOVERY_METHODS".localize(), type: 1, subText: ["EMAIL".localize()], value: 0),
        SettingCellModel(title: "\("USE".localize()) Face ID", type: 2, subText: [], value: UserDefaults.standard.bool(forKey: Key.biometricAuth.rawValue) ? 1 : 0)
    ]
    
    private let biometric: BiometryAuth = BiometryAuth()
    private var biometricType: LAContext.BiometricType = .none {
        didSet {
            guard biometricType != .none else {
                return
            }
            items[2].title = "\("USE".localize()) \(biometricType == .touchID ? "Touch ID" : "Face ID")"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideHeaderBase()
        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        let context = LAContext()
        biometricType = context.biometricType
        biometric.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: SettingsTableViewCell.nib, bundle: nil), forCellReuseIdentifier: SettingsTableViewCell.cellId)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension SecuritySettingsViewController: UITableViewDelegate, UITableViewDataSource {
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
        cell.switchCallBack = { isOn in
            if isOn {
                self.biometric.authWithBiometry()
            }
            else {
                UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if items[indexPath.row].type == 1 { return 65 }
        if items[indexPath.row].type == 2 { return 55 }
        return 49
    }
}

extension SecuritySettingsViewController {
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
                self.successView = SecuritySettingView(frame: .init(x: 4, y: UIConstants.Layout.screenHeight + UIConstants.heightConstraint(236), width: dialogWidth, height: UIConstants.heightConstraint(236)))
                guard let successView = self.successView else {
                    return
                }
                (successView as? SecuritySettingView)?.setData(model: self.items[index])
                (successView as? SecuritySettingView)?.closeCallBack = {
                    self.hideCustomBottomNotiSettingPopup()
                }

                (successView as? SecuritySettingView)?.emailCallBack = { isOn in
                    if isOn {
                        self.items[index].subText.insert("EMAIL".localize(), at: 0)
                    }
                    else {
                        self.items[index].subText.removeFirst()
                    }
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }

                (successView as? SecuritySettingView)?.pushCallBack = { isOn in
                    if isOn {
                        self.items[index].subText.append("SMS_VIA_PHONE_NUMBER".localize())
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

// MARK: BiometryAuthDelegate
extension SecuritySettingsViewController: BiometryAuthDelegate {
    func authFail(error: Error?) {
        Logger.Logs(message: "AUTH FAIL")
        UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        guard let error = error else {
            return
        }
        Logger.Logs(event: .error, message: error.localizedDescription)
        switch error._code {
        case LAError.authenticationFailed.rawValue:
            break
        case LAError.userCancel.rawValue:
            break
        default:
            AlertService.showAlert(style: .alert, title: "BIOMETRIC_HAS_BEEN_BLOCKED".localize(), message: nil)
            break
        }
    }
    
    func authSuccessful() {
        Logger.Logs(message: "AUTH SUCCESSFUL")
        UserDefaults.standard.set(true, forKey: Key.biometricAuth.rawValue)
    }
    
    func deviceNotSupport() {
    }
    
}
