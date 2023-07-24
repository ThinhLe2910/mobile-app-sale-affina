//
//  ContractDetailViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import Foundation

protocol ContractDetailViewDelegate {
    func lockUI()
    func unlockUI()
    func updateUI(contractDetail: ContractDetailModel)
    func showAlert()
    func showError(error: ApiError)
    func updateTerms(terms: InsuranceTermsModel)
}

class ContractDetailViewPresenter {
    
    private var delegate: ContractDetailViewDelegate?

    private let insuranceService = InsuranceService()
    private let contractService = ContractService()
    
    init() {

    }

    func setViewDelegate(delegate: ContractDetailViewDelegate) {
        self.delegate = delegate
    }
    
    func getContractDetail(contractId: String) {
        self.delegate?.lockUI()
        
        contractService.getContractDetail(contractId: contractId) { [weak self] result in
            self?.delegate?.unlockUI()
            
            switch result {
                case .success(let success):
                    switch success.code {
                        case ContractCode.OK_200.rawValue:
                            guard let data = success.data else { return }
                            Logger.Logs(message: data)
                            self?.delegate?.updateUI(contractDetail: data)
                        case ErrorCode.EXPIRED.rawValue:
                            self?.delegate?.showError(error: ApiError.expired)
                        default:
                            break
                    }
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    switch error {
                        case ApiError.invalidData(let error, let data):
                            Logger.Logs(message: error)
                            guard let data = data else { return }
                            do {
                                let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                                if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                    self?.delegate?.showError(error: ApiError.expired)
                                }
                            }
                            catch let err{
                                Logger.DumpLogs(event: .error, message: err)
                            }
                            
                        default:
                            break
                    }
            }
        }
    }
    
    func getTerms(programId: String) {
        insuranceService.getTerms(programId: programId) { [weak self] result in
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    guard let data = data.data else {
                        return
                    }
                    self?.delegate?.updateTerms(terms: data)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
}
