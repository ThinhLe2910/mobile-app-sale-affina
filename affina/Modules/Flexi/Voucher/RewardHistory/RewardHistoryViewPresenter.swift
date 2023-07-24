//
//  RewardHistoryViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 08/03/2023.
//

import Foundation

protocol RewardHistoryViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()
 
    func updateListHistory(list: [VoucherHistoryModel])
    
}

class RewardHistoryViewPresenter {
    weak var delegate: RewardHistoryViewDelegate?
    
    private let voucherService = VoucherService()
    private let flexiService = FlexiService()
    
    func getVoucherHistory(fieldDate: String = "voucherTransaction.createdAt", fromDate: Double, toDate: Double, order: String = "createdAt", by: String = "desc") {
        delegate?.lockUI()
        voucherService.getVoucherHistory(fieldDate: fieldDate, fromDate: fromDate, toDate: toDate, order: order, by: by) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    self?.delegate?.updateListHistory(list: data.data?.list ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getSMEVoucherHistory(fieldDate: String = "voucherTransaction.createdAt", fromDate: Double, toDate: Double, order: String = "createdAt", by: String = "desc") {
        delegate?.lockUI()
        flexiService.getVoucherHistory(fieldDate: fieldDate, fromDate: fromDate, toDate: toDate, order: order, by: by) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    self?.delegate?.updateListHistory(list: data.data?.list ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
}
