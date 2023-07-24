//
//  VoucherListViewPresenter.swift
//  affina
//
//  Created by Dylan on 19/10/2022.
//

import Foundation

protocol VoucherListViewDelegate: BaseProtocol {
    
    func updateListVoucher(list: [MyVoucherModel])
//    func updateListVoucher(list: [HomeFeaturedProduct])
    
    func checkVoucherSuccess(model: ContractVoucherModel)
    func handleCheckVoucherError(code: String, message: String)
}

class VoucherListViewPresenter {
    
    var delegate: VoucherListViewDelegate?
    
    private let voucherService = VoucherService()
    init() { }
    
    func getListActiveVouchers(filter: String = "usingVoucher.isUse", filterValue: Int = 0, fromDate: Int64 = Int64(Date().timeIntervalSince1970), order: String = "", fieldDate: String = "usingVoucher.expiredAt", by: String = "desc") {
        voucherService.getMyListVoucher(filter: filter, filterValue: filterValue, fromDate: fromDate, order: order, fieldDate: fieldDate, by: by) { [weak self] result in
            switch result {
                case .success(let response):
                    self?.delegate?.updateListVoucher(list: response.data?.list ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getListUsedVouchers() {
        voucherService.getMyListUsedVoucher(filter: "", filterValue: -1, fromDate: -1, order: "", fieldDate: "", by: "") { [weak self] result in
            switch result {
                case .success(let response):
                    self?.delegate?.updateListVoucher(list: response.data ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func checkContractVoucher(contractId: String, voucherCode: String) {
        voucherService.checkContractVoucher(contractId: contractId, voucherCode: voucherCode) { [weak self] result in
            switch result {
                case .success(let response):
                    if response.code != "200" {
                        self?.delegate?.handleCheckVoucherError(code: response.code, message: response.messages ?? "")
                        return
                    }
                    guard let model = response.data else { return }
                    self?.delegate?.checkVoucherSuccess(model: model)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
}
