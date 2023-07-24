//
//  InsuranceFilterViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 10/08/2022.
//

import Foundation

protocol InsuranceFilterViewDelegate {
    func lockUI()
    func unlockUI()
    
    func updateListCompanyProvider(list: [CompanyProvider])
    func updateListProgramType(list: [ProgramType])
    
    func showError()
}

class InsuranceFilterViewPresenter {
    
    var delegate: InsuranceFilterViewDelegate?
    
    init() {}
    
    func setViewDelegate(delegate: InsuranceFilterViewDelegate) {
        self.delegate = delegate
    }
    
    func getListInsuranceType() {
        self.delegate?.lockUI()
        let request = BaseApiRequest(path: API.Sale.GET_ALL_PROGRAM_TYPE, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<[ProgramType]>, ApiError>) in
            self?.delegate?.unlockUI()
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                Logger.Logs(message: data.data)
                guard let list = data.data else { return }
                self.delegate?.updateListProgramType(list: list)
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self.delegate?.showError()
                break
            }
        }
    }
    
    func getListCompanyProvider(search: String, id: String = "", programTypeId: String = "", createdAt: Double = -1) {
        self.delegate?.lockUI()
        var body: [String: Any] = [
            "limit": 999,
        ]
        if !search.isEmpty {
            body["searchValue"] = search
        }
        if !id.isEmpty {
            body["id"] = id
        }
        if !programTypeId.isEmpty {
            body["programTypeId"] = programTypeId
        }
        if createdAt != -1 {
            body["createdAt"] = createdAt
        }
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = BaseApiRequest(path: API.User.GET_LIST_COMPANY_PROVIDER, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<[CompanyProvider]>, ApiError>) in
            self?.delegate?.unlockUI()
            guard let self = self else { return }
            switch result {
            case .success(let data):
            Logger.Logs(message: data.data)
            guard let list = data.data else {
                return
            }
            self.delegate?.updateListCompanyProvider(list: list)
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self.delegate?.showError()
                break
            }
        }
    }
}
