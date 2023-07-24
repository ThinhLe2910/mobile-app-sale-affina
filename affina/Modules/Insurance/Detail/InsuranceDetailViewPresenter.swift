//
//  InsuranceDetailViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 10/08/2022.
//

import Foundation

protocol InsuranceDetailViewDelegate {
    func lockUI()
    func unlockUI()
    func showError()
    func updateUI(model: ProductDetailModel)
    func updateTerms(terms: InsuranceTermsModel)
}

class InsuranceDetailViewPresenter {
    init() { }
    
    var delegate: InsuranceDetailViewDelegate?
    
    private let insuranceService = InsuranceService()
    
    func setViewDelegate(delegate: InsuranceDetailViewDelegate) {
        self.delegate = delegate
    }
    
    func getProductDetail(id: String, gender: Int, dob: Double) {
        self.delegate?.lockUI()
        insuranceService.getProductDetail(id: id, gender: gender, dob: dob) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                guard let model = data.data else { return }
                Logger.Logs(message: model)
                self?.delegate?.updateUI(model: model)
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self?.delegate?.showError()
                break
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
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError()
                    break
            }
        }
    }
}
