//
//  FlexiViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 17/03/2023.
//

import Foundation

protocol FlexiViewDelegate: AnyObject {
    func updateSummary()
    
    func exchangeDayOffsSuccess(model: FlexiExchangeDaysModel)
    func handleExchangeError(code: String, message: String)
    
    func updateListBenefit(list: [FlexiBenefitModel])
    func updateListCardSME(list: [CardModel])
    func lockUI()
    func unlockUI()
    
}

class FlexiViewPresenter {
    weak var delegate: FlexiViewDelegate?
    private let flexiService = FlexiService()
    
    func getSummary() {
        delegate?.lockUI()
        
        flexiService.getSummaryFlexiPoint { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let response):
                    AppStateManager.shared.flexiSummary = response.data
                    self?.delegate?.updateSummary()
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
        
    }
    
    func getListFlexi() {
        delegate?.lockUI()
        flexiService.getListFlexi { [weak self] result in
            self?.delegate?.unlockUI()
            
            switch result {
                case .success(let response):
                    self?.delegate?.updateListBenefit(list: response.data ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func getListSmeCards(contractId: String = "", createdAt: Double = -1, limit: Int) {
        delegate?.lockUI()
        flexiService.getListCardSME(contractId: contractId, createdAt: createdAt, limit: limit) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let response):
                    self?.delegate?.updateListCardSME(list: response.data ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
    
    func exchangeDayOffs(benefitId: String, exchangeDays: Int) {
        delegate?.lockUI()
        flexiService.exchangeDayOff(benefitId: benefitId, exchangeDays: exchangeDays) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let response):
                    if response.code == "FLEXI_4001" {
                        self?.delegate?.handleExchangeError(code: response.code, message: response.messages ?? "-")
                        return
                    }
                    guard let data = response.data else { return }
                    self?.delegate?.exchangeDayOffsSuccess(model: data)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
}
