//
//  VoucherListViewController.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit

enum ListVoucherType {
    case myVoucher
    case myBenefit
}

class VoucherListViewController: BaseViewController {

    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var unUsedButton: BaseButton!
    @IBOutlet weak var expiredButton: BaseButton!
    
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    private var presenter: VoucherListViewPresenter = VoucherListViewPresenter()
    
    private var vouchers: [MyVoucherModel] = []
    
    private var isUsedList: Bool = false
    
    var listVoucherType: ListVoucherType = .myVoucher
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton()
        setupHeaderView()
        containerBaseView.hide()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: VoucherTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: VoucherTableViewCell.identifier)
        
        presenter.delegate = self
        if listVoucherType == .myVoucher {
            presenter.getListActiveVouchers()
        }
        else {

        }
        
        unUsedButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        expiredButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
    }
    private func setButton(){
        unUsedButton.setTitle("NOT_USED_YET".localize().capitalized, for: .normal)
        expiredButton.setTitle("USED_EXPIRED".localize().capitalized, for: .normal)
    }
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "MY_VOUCHERS".localize().capitalized
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
    }
    
    @objc private func didTapButton(_ button: BaseButton) {
        switch button {
            case unUsedButton:
                unUsedButton.colorAsset = "whiteMain"
                unUsedButton.backgroundAsset = "blueMain"
                
                expiredButton.colorAsset = "blueMain"
                expiredButton.backgroundAsset = "whiteMain"
                isUsedList = false
                
                vouchers = []
                if listVoucherType == .myVoucher {
                    presenter.getListActiveVouchers()
                }
                else {
                    
                }
                tableView.reloadData()
                
                break
            case expiredButton:
                expiredButton.colorAsset = "whiteMain"
                expiredButton.backgroundAsset = "blueMain"
                
                unUsedButton.colorAsset = "blueMain"
                unUsedButton.backgroundAsset = "whiteMain"
                isUsedList = true
                
                vouchers = []
                if listVoucherType == .myVoucher {
                    presenter.getListUsedVouchers()// (filter: "", filterValue: -1, fromDate: -1, order: "", fieldDate: "")
                }
                else {
                    
                }
                tableView.reloadData()
                
                break
            default: break
        }
    }
}

// MARK: VoucherListViewDelegate
extension VoucherListViewController: VoucherListViewDelegate {
    func checkVoucherSuccess(model: ContractVoucherModel) {
        
    }
    
    func handleCheckVoucherError(code: String, message: String) {
        
    }
    
    func lockUI() {
        
    }
    
    func unlockUI() {
        
    }
    
    func showError(error: ApiError) {
        
    }
    
    func showAlert() {
        
    }
    
    func updateListVoucher(list: [MyVoucherModel]) {
        vouchers = list
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension VoucherListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoucherTableViewCell.identifier, for: indexPath) as? VoucherTableViewCell else { return UITableViewCell() }
        cell.item = vouchers[indexPath.row]
        cell.isUsed = isUsedList
        cell.isSelectingMode = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76 + 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = VoucherDetailViewController()
        vc.voucherDetailType = .mine
        vc.code = vouchers[indexPath.row].code ?? ""
        vc.voucherId = vouchers[indexPath.row].voucherID ?? ""
        vc.providerId = vouchers[indexPath.row].providerID ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
