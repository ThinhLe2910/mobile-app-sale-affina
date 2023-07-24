//
//  SelectInsuredViewController.swift
//  affina
//
//  Created by Dylan on 21/09/2022.
//

import UIKit

struct InsuredNameModel: Codable {
    let name: String
}

class SelectInsuredViewController: BaseViewController {

    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var emptyLabel: BaseLabel!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    private var insuredPersons: [InsuredNameModel] = []
    
    private let claimService = ClaimService()
    
    var callback: ((InsuredNameModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerBaseView.hide()
        
        view.backgroundColor = .appColor(.blueUltraLighter)
        
        //        addBlurStatusBar()
        setupHeaderView()
        
        tableViewTopConstraint.constant = UIConstants.Layout.headerHeight + 10
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: SelectInsuredTableViewCell.nib, bundle: nil), forCellReuseIdentifier: SelectInsuredTableViewCell.cellId)
        
        getInsuredPersons()
    }
    
    private func getInsuredPersons() {
        lockScreen()
        claimService.getInsuredPersons { [weak self] result in
            self?.unlockScreen()
            switch result {
                case .success(let data):
                    switch data.code {
                        case ResponseCode.OK_200.rawValue:
                            guard let data = data.data else {
                                return
                            }
                            
                            Logger.Logs(message: data)
                            self?.insuredPersons = data
                            self?.tableView.reloadData()
                            break
                        case ErrorCode.EXPIRED.rawValue:
                            self?.logOut()
                            self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                self?.hideBasePopup()
                                //                    self.navigationController?.popToRootViewController(animated: true)
                                self?.dismiss(animated: true, completion: nil)
                            } handler: {
                                
                            }
                        default: break
                    }
                    break
                case .failure(let error):
                    Logger.Logs(message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self?.logOut()
                            self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                                self?.hideBasePopup()
                                //                    self.navigationController?.popToRootViewController(animated: true)
                                self?.dismiss(animated: true, completion: nil)
                            } handler: {
                                
                            }
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                    
                    case .requestTimeout(let error):
                        self?.queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                            self?.hideBasePopup()
                        } handler: {
                            
                        }
                default:
                    break
                }
                break
            }
        }
    }

    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "SELECT_INSURED_PEOPLE".localize().capitalized
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
    }

}

extension SelectInsuredViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectInsuredTableViewCell.cellId, for: indexPath) as? SelectInsuredTableViewCell else {
            return UITableViewCell()
        }
        
        cell.nameLabel.text = insuredPersons[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return insuredPersons.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        callback?(insuredPersons[indexPath.row])
        popViewController()
//        dismiss(animated: true) {
            
//        }
    }
}
