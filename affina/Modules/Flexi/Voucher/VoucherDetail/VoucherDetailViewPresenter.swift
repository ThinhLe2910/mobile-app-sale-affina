//
//  VoucherDetailViewPresenter.swift
//  affina
//
//  Created by Dylan on 20/10/2022.
//

import Foundation

protocol VoucherDetailViewDelegate: BaseProtocol {
    func updateListReviews(list: [CommentModel])
    func updateVoucherDetail(detail: VoucherDetailModel)
    func updateMyVoucherDetail(detail: MyVoucherModel)
    func buyVoucherSuccess(coin: Double)
    func handleBuyVoucherError(message: String)
    
    func markUsedSuccess()
    func handleMarkUsedError(error: ApiError)
}

class VoucherDetailViewPresenter {
    var delegate: VoucherDetailViewDelegate?
    
    private let voucherService = VoucherService()
    private let flexiService = FlexiService()
    
    init() { }
    
    func getSMESummary() {
        delegate?.lockUI()
        flexiService.getSummaryFlexiPoint { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    guard let data = data.data else { return }
                    AppStateManager.shared.flexiSummary = data
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getVoucherSummary() {
        delegate?.lockUI()
        voucherService.getVoucherSummary { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    guard let data = data.data else { return }
                    AppStateManager.shared.userCoin = data.coin ?? 0
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getDetail(voucherId: String, providerId: String) {
        delegate?.lockUI()
        voucherService.getVoucherDetail(voucherId: voucherId, providerId: providerId) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    guard let data = data.data else { return }
                    self?.delegate?.updateVoucherDetail(detail: data)
                case .failure(let failure):
                    Logger.Logs(message: failure)
                    break
            }
        }
    }
    
    func getMyVoucherDetail(voucherId: String, code: String, providerId: String) {
        delegate?.lockUI()
        voucherService.getMyVoucherDetail(voucherId: voucherId, code: code, providerId: providerId) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    guard let data = data.data else { return }
                    self?.delegate?.updateMyVoucherDetail(detail: data)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getSMEMyVoucherDetail(voucherId: String, code: String, providerId: String) {
        delegate?.lockUI()
        flexiService.getSMEMyVoucherDetail(voucherId: voucherId, code: code, providerId: providerId) {  result in
            self.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    guard let data = data.data else { return }
                    self.delegate?.updateVoucherDetail(detail: data)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getReviews() {
        
    }
    
    func buyVoucher(voucherId: String, quantity: Int, providerId: String) {
        delegate?.lockUI()
        voucherService.buyVoucher(voucherId: voucherId, quantity: quantity, providerId: providerId) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    switch data.code {
                        case "VOUCHER_4001":
                        self?.delegate?.handleBuyVoucherError(message: "Bạn không đủ điểm để đổi voucher!")
                        return
                        case "VOUCHER_4002", "VOUCHER_4003":
                        self?.delegate?.handleBuyVoucherError(message: "Bạn không đủ điều kiện để đổi voucher!")
                        return
                        case "5000":
                            self?.delegate?.handleBuyVoucherError(message: data.messages ?? "Unknown")
                            return
                        default: break
                    }
                    self?.delegate?.buyVoucherSuccess(coin: data.data?.coin ?? 0)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.handleMarkUsedError(error: error)
            }
        }
    }
    
    func buySMEVoucher(voucherId: String, quantity: Int, providerId: String) {
        delegate?.lockUI()
        flexiService.buyVoucher(voucherId: voucherId, quantity: quantity, providerId: providerId) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    switch data.code {
                        case "VOUCHER_4001":
                            self?.delegate?.handleBuyVoucherError(message: "Bạn không đủ điểm để đổi voucher!")
                            return
                        case "VOUCHER_4002", "VOUCHER_4003":
                            self?.delegate?.handleBuyVoucherError(message: "Bạn không đủ điều kiện để đổi voucher!")
                            return
                        case "5000":
                            self?.delegate?.handleBuyVoucherError(message: data.messages ?? "Unknown")
                            return
                        default: break
                    }
                    self?.delegate?.buyVoucherSuccess(coin: data.data?.point ?? 0)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.handleMarkUsedError(error: error)
            }
        }
    }
    
    
    func markUsed(voucherId: String, code: String) {
        delegate?.lockUI()
        voucherService.markUsedVoucher(voucherId: voucherId, code: code) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    self?.delegate?.markUsedSuccess()
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.handleMarkUsedError(error: error)
            }
        }
    }
}
