//
//  VoucherPointViewDelegate.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import Foundation

protocol PointViewDelegate: BaseProtocol {
    func updateVoucherSummary(summary: VoucherSummaryModel)
    
    func updateListVoucher(list: [VoucherModel], showAt: VoucherTypeEnum)
    
    func updateListCategory(list: [VoucherCategoryModel])
    
}

class VoucherPointViewDelegate {
    init() { }
    
    private let voucherService = VoucherService()
    
    var delegate: PointViewDelegate?
    
    func getVoucherSummary() {
        voucherService.getVoucherSummary { [weak self] result in
            switch result {
                case .success(let data):
                    guard let data = data.data else { return }
                    self?.delegate?.updateVoucherSummary(summary: data)
                    
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getListCategory() {
        self.delegate?.lockUI()
        voucherService.getListVoucherCategory { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let response):
                    guard let data = response.data else { return }
                    self?.delegate?.updateListCategory(list: data)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getListVoucherAt(from: Int, limit: Int, showAt: VoucherTypeEnum) {
        self.delegate?.lockUI()
        voucherService.getVoucherAt(from: from, limit: limit, showAt: showAt.rawValue) { [weak self] result in
            switch result {
                case .success(let response):
                    self?.delegate?.unlockUI()
                    self?.delegate?.updateListVoucher(list: response.data?.list ?? [], showAt: showAt)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
}
