//
//  FlexiCategoriesViewPresenter.swift
//  affina
//
//  Created by Dylan on 19/10/2022.
//

import Foundation

protocol FlexiCategoriesViewDelegate: BaseProtocol {
    func updateListVouchers(list: [VoucherModel])
    func updateListCategories(list: [VoucherCategoryModel])
}

class FlexiCategoriesViewPresenter {
    var delegate: FlexiCategoriesViewDelegate?
    
    private let voucherService = VoucherService()
    private let flexiService = FlexiService()
    
    init() { }
    
    func getListCategory() {
        voucherService.getListVoucherCategory { [weak self] result in
            switch result {
                case .success(let response):
                    Logger.Logs(message: response)
                    self?.delegate?.updateListCategories(list: response.data ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
    
    func getListVoucherByCategory(categoryId: String, from: Int, limit: Int) {
        delegate?.lockUI()
        voucherService.getListVoucherByCategory(categoryId: categoryId, from: from, limit: limit) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let response):
                    Logger.Logs(message: response)
                    self?.delegate?.updateListVouchers(list: response.data ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
    
    func getListSMEVoucherByCategory(categoryId: String, from: Int, limit: Int) {
        delegate?.lockUI()
        flexiService.getListVoucherByCategory(categoryId: categoryId, from: from, limit: limit) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let response):
                    Logger.Logs(message: response)
                    self?.delegate?.updateListVouchers(list: response.data ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
}
