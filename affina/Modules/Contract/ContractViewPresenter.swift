//
//  ContractViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import Foundation

protocol ContractViewDelegate {
    func lockUI()
    func unlockUI()
    func updateUI(contracts: [ContractModel])
    func showAlert()
    func showError(error: ApiError)
}

class ContractViewPresenter {

    private var delegate: ContractViewDelegate?

    private let contractService = ContractService()

    init() {

    }

    func setViewDelegate(delegate: ContractViewDelegate) {
        self.delegate = delegate
    }

    func getListContracts() {
        self.delegate?.lockUI()
        contractService.getListContracts { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let success):
                    Logger.Logs(message: success)
                    switch success.code {
                        case ContractCode.OK_200.rawValue:
                            self?.delegate?.updateUI(contracts: success.data!)
                            
                            break
                        case CheckPhoneCode.LOGIN_4002.rawValue:
                            self?.delegate?.showError(error: ApiError.expired)
                            break
                        case ErrorCode.EXPIRED.rawValue:
                            self?.delegate?.showError(error: ApiError.expired)
                            break
                        default:
                            break
                    }
                case .failure(let failure):
                    Logger.Logs(event: .error, message: failure)
                    switch failure {
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
}
