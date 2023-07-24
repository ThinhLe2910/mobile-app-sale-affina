//
//  ContractViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import UIKit
import SnapKit

class ContractViewController: BaseViewController {
    
    static let nib = "ContractViewController"
    
    @IBOutlet weak var emptyLabel: BaseLabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var notLogInView: BaseView!
    @IBOutlet weak var loginButton: BaseButton!
    
    private let presenter = ContractViewPresenter()
    
    private var listCoverImageProgram = LayoutBuilder.shared.getListSetupCoverImageProgram()
    private var items: [ContractModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appColor(.backgroundLightGray)
        //        hideHeaderBase()
        containerBaseView.hide()
        setupHeaderView()
        tableViewTopConstraint.constant = UIConstants.Layout.headerHeight + 20
        presenter.setViewDelegate(delegate: self)
        
        presenter.getListContracts()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ContractTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ContractTableViewCell.cellId)
        
        loginButton.addTapGestureRecognizer {
            let vc = WelcomeViewController()
            self.presentInFullScreen(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
        
        if UIConstants.isLoggedIn {
            notLogInView.hide()
            rightBaseImage.show()
        }
        else {
            notLogInView.show()
            rightBaseImage.hide()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if items.isEmpty {
            presenter.getListContracts()
        }
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "INSURANCE_CONTRACT".localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_add")?.withRenderingMode(.alwaysTemplate)
        rightBaseImage.tintColor = .appColor(.black)
        rightBaseImage.addTapGestureRecognizer {
            let vc = InsuranceApproachViewController()
            self.presentInFullScreen(UINavigationController(rootViewController: vc), animated: true)
        }
    }
    
}

extension ContractViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContractTableViewCell.cellId, for: indexPath) as? ContractTableViewCell else { return UITableViewCell() }
        cell.item = items[indexPath.row]
        cell.cardImageView.image = UIImage(named: "Card_4")
        //        cell.inset = .init(top: 0, left: 24, bottom: 8, right: 24)
        
        for item in listCoverImageProgram {
            if item.programID == items[indexPath.row].listContractObject[0].programId {
                if let url = URL(string: API.STATIC_RESOURCE + (item.imageFilter ?? "")) {
                    CacheManager.shared.imageFor(url: url) { image, error in
                        if error != nil {
                            DispatchQueue.main.async {
                                cell.cardImageView.image = UIImage(named: "Card_4")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            cell.cardImageView.image = image
                        }
                    }
                    break
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ContractDetailViewController(nibName: ContractDetailViewController.nib, bundle: nil)
        vc.setContractId(contractId: items[indexPath.row].contractID)
        vc.setContractObjectId(contractObjectId: items[indexPath.row].listContractObject[0].contractObjectId)
        vc.cardImage = UIImage(named: "Card_4")
        if let customerType = items[indexPath.row].listContractObject[0].customerType{
            vc.setCustomertype(customerType: customerType)
        }
        

//        vc.model = items[indexPath.row]
//        vc.setContract(contract: items[indexPath.row])
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ContractViewController: ContractViewDelegate {
    func lockUI() { 
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func updateUI(contracts: [ContractModel]) {
        items = contracts
        tableView.reloadData()
        
        if items.isEmpty {
            emptyLabel.show()
            tableView.hide()
        }
        else {
            emptyLabel.hide()
            tableView.show()
        }
    }
    
    func showAlert() {
        
    }
    
    func showError(error: ApiError) {
        switch error {
        case .refresh:
            break
        case .expired:
            logOut()
            queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                self.hideBasePopup()
                self.navigationController?.popToRootViewController(animated: true)
            } handler: {
                
            }
//            navigationController?.popToRootViewController(animated: true)
            break
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
        default:
            break
        }
    }
    
}
