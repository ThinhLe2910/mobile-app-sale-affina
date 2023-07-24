//
//  InsuranceListViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 10/08/2022.
//

import Foundation

protocol InsuranceListViewDelegate {
    func lockUI()
    func unlockUI()
    func updateListProduct(list: [FilterProductModel])
    func showError()
}

class InsuranceListViewPresenter {
    
    var delegate: InsuranceListViewDelegate?
    
    init() {}
    
    func setViewDelegate(delegate: InsuranceListViewDelegate) {
        self.delegate = delegate
    }
    
    
    func filterProduct(filter: FilterInsuranceModel) {
        delegate?.lockUI()
        let body: Data? = try? JSONSerialization.data(withJSONObject: filter.dictionary, options: [])
        let request = BaseApiRequest(path: API.Sale.POST_FILTER_PRODUCT, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: body)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<[FilterProductModel]>, ApiError>) in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                guard let list = data.data else { return }
                Logger.Logs(message: list)
                self?.delegate?.updateListProduct(list: list)
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self?.delegate?.showError()
                break
            }
        }
    }
}
