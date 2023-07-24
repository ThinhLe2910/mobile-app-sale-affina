//
//  SelectVoucherViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/03/2023.
//

import UIKit

class SelectVoucherViewController: BaseViewController {

    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var submitButton: BaseButton!
    @IBOutlet weak var searchVoucherTextField: TitleTextFieldBase!
    
    private var presenter: VoucherListViewPresenter = VoucherListViewPresenter()
    
    private var vouchers: [MyVoucherModel] = []
    private var tempVouchers: [MyVoucherModel] = []
    
    var contractId: String = ""
    var selectedVouchers: [String: MyVoucherModel] = [:]
    
    var selectedVoucher: ContractVoucherModel?
    
    var applyCallback: ((ContractVoucherModel?, [String: MyVoucherModel]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView()
        containerBaseView.hide()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        searchVoucherTextField.textField.delegate = self
        searchVoucherTextField.textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: VoucherTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: VoucherTableViewCell.identifier)
        
        presenter.delegate = self
        
        presenter.getListActiveVouchers()
        
        submitButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        submitButton.hide()
        
        updateSubmitButtonUI()
    }
    
    func updateSubmitButtonUI() {
        
        if selectedVouchers.isEmpty {
            submitButton.hide()
            submitButton.setTitle("Áp dụng 0 ưu đãi".capitalized, for: .normal)
        }
        else {
            submitButton.show()
            submitButton.setTitle("Áp dụng \(selectedVouchers.count) ưu đãi".capitalized, for: .normal)
        }
    }
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        searchVoucherTextField.text = "ENTER_DISCOUNT_CODE".localize()
        labelBaseTitle.text = "MY_VOUCHERS".capitalized.localize()
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
    }
    
    @objc private func didTapButton(_ button: BaseButton) {
        switch button {
            case submitButton:
                applyCallback?(selectedVoucher, selectedVouchers)
                popViewController()
                break
            default: break
        }
    }
    override func didClickLeftBaseButton() {
        if selectedVouchers.isEmpty {
            applyCallback?(nil, [:])
        }
        super.didClickLeftBaseButton()
    }
    
    @objc func textFieldDidChange() {
        guard let code = searchVoucherTextField.textField.text, !code.isEmpty else {
            tempVouchers = vouchers
            tableView.reloadData()
            return
        }
        tempVouchers = vouchers.filter({ voucher in
            voucher.code?.contains(code) ?? false
        })
        
        tableView.reloadData()
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let code = searchVoucherTextField.textField.text, !code.isEmpty else {
            return true
        }
        if let voucher = vouchers.filter({ voucher in
            voucher.code?.contains(code) ?? false
        }).first {
            selectedVouchers[code] = voucher
        }
        else {
            let appendedVoucher = MyVoucherModel(voucherID: nil, campaignID: nil, userID: nil, code: code, serial: nil, imageCode: nil, isUse: nil, expiredAt: nil, providerID: nil, voucherName: code, voucherImage: nil, summary: nil, content: nil, totalRating: nil, totalRatingPoint: nil, ratingList: nil)
            selectedVouchers[code] = appendedVoucher
            tempVouchers.insert(appendedVoucher, at: 0)
            vouchers.insert(appendedVoucher, at: 0)
        }
        checkVoucherValid()
        updateSubmitButtonUI()
        tableView.reloadData()
        return true
    }
    
    func checkVoucherValid() {
        if contractId.isEmpty { return }
        
        if let voucher = selectedVouchers.first?.value {
            presenter.checkContractVoucher(contractId: contractId, voucherCode: voucher.code ?? "")
            
        }
        else if let code = selectedVouchers.first?.key {
            presenter.checkContractVoucher(contractId: contractId, voucherCode: code)
        }
    }
}

// MARK: VoucherListViewDelegate
extension SelectVoucherViewController: VoucherListViewDelegate {
    func checkVoucherSuccess(model: ContractVoucherModel) {
        selectedVoucher = model
    }
    
    func handleCheckVoucherError(code: String, message: String) {
        selectedVouchers.removeAll()
        if tempVouchers.count > 0 {
            if let temp = tempVouchers.first, temp.voucherID == nil {
                tempVouchers.removeFirst()
            }
        }
        if vouchers.count > 0 {
            if let temp = vouchers.first, temp.voucherID == nil {
                vouchers.removeFirst()
            }
        }
        tableView.reloadData()
        
        updateSubmitButtonUI()
        
        queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: message.isEmpty ? "Error" : message, okTitle: "GOT_IT".localize(), cancelTitle: "") {
            self.hideBasePopup()
            
        } handler: {
            
        }

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
        vouchers = list.filter({ voucher in
            voucher.providerID == nil || (voucher.providerID?.isEmpty ?? true)
        })
        if let code = selectedVouchers.first?.key {
            if let voucher = vouchers.first(where: { voucher in
                voucher.code == code
            }) {
                
            }
            else {
                let appendedVoucher = MyVoucherModel(voucherID: nil, campaignID: nil, userID: nil, code: code, serial: nil, imageCode: nil, isUse: nil, expiredAt: nil, providerID: nil, voucherName: code, voucherImage: nil, summary: nil, content: nil, totalRating: nil, totalRatingPoint: nil, ratingList: nil)
                vouchers.insert(appendedVoucher, at: 0)
            }
        }
        
        tempVouchers = vouchers
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension SelectVoucherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempVouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VoucherTableViewCell.identifier, for: indexPath) as? VoucherTableViewCell else { return UITableViewCell() }
        cell.item = tempVouchers[indexPath.row]
        cell.isUsed = false
        cell.isSelectingMode = true
        cell.isAdded = selectedVouchers[tempVouchers[indexPath.row].code ?? "-"] != nil
        cell.addCallback = { isAdded in
            if isAdded {
                self.selectedVouchers.removeAll()
                self.selectedVouchers[self.tempVouchers[indexPath.row].code ?? "-"] = self.tempVouchers[indexPath.row]
                
                self.checkVoucherValid()
            }
            else {
                self.selectedVouchers.removeValue(forKey: self.tempVouchers[indexPath.row].code ?? "-")
            }
            self.tableView.reloadData()
            self.updateSubmitButtonUI()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76 + 12 - 17 + (tempVouchers[indexPath.row].voucherName?.height(withConstrainedWidth: UIConstants.Layout.screenWidth - 24 * 2 - 44 * 2 - 76, font: UIConstants.Fonts.appFont(.Bold, 14)) ?? 17)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismissKeyboard()
    }
}
