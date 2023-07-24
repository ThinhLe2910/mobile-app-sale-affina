//
//  ChangeEnvViewController.swift
//  affina
//
//  Created by ho lam on 10/08/2022.
//

import UIKit

class ChangeEnvViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableEnv: UITableView!
    
    let arrEnv = ["dev", "staging", "uat", "live"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideHeaderBase()
        containerBaseView.hide()
        
        tableEnv.delegate = self
        tableEnv.dataSource = self
        tableEnv.bounces = false
        tableEnv.separatorStyle = .none
//        tableEnv.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.description())
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEnv.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: UITableViewCell.description())
        cell.textLabel?.text = arrEnv[indexPath.row]
        cell.selectionStyle = .none
        
        if API.networkEnvironment == .dev && indexPath.row == 0 {
            cell.accessoryType = .checkmark
        } else if API.networkEnvironment == .staging && indexPath.row == 1 {
            cell.accessoryType = .checkmark
        } else if API.networkEnvironment == .uat && indexPath.row == 2 {
            cell.accessoryType = .checkmark
        } else if API.networkEnvironment == .live && indexPath.row == 3 {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            switch indexPath.row {
            case 0:
                API.networkEnvironment = .dev
                cell.accessoryType = .checkmark
            case 1:
                API.networkEnvironment = .staging
                cell.accessoryType = .checkmark
            case 2:
                API.networkEnvironment = .uat
                cell.accessoryType = .checkmark
            case 3:
                API.networkEnvironment = .live
                cell.accessoryType = .checkmark
            default:
                return
            }
        }
        
        tableEnv.reloadData()
        Logger.Logs(event: .info, message: "Change environment to: \(arrEnv[indexPath.row])")
        self.logOut()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
        }
    }

}
