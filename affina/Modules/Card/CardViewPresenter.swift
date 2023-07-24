//
//  CardViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/08/2022.
//

import Foundation

protocol CardViewDelegate: AnyObject {
    func lockUI()
    func unlockUI()
    
    func updateUI(cards: [CardModel])
    func updateClaimHistory(history: [ClaimHistoryModel])
    func updateHospital(hospitals: [HospitalModel], isBlackList: Bool)
    func showError(error: ApiError)
}

class CardViewPresenter {
    weak var delegate: CardViewDelegate?
    private let cardService = CardService()
    
    init() { }
    
    func setViewDelegate(_ delegate: CardViewDelegate) {
        self.delegate = delegate
    }
    
    func getListCards(limit: Int = 10) {
        self.delegate?.lockUI()
        cardService.getListCards(limit: limit) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case.success(let res):
                switch res.code {
                case ResponseCode.OK_200.rawValue:
                    guard let cards = res.data else {
                        self?.delegate?.showError(error: ApiError.otherError)
                        return
                    }
                    Logger.Logs(message: cards)
                    self?.delegate?.updateUI(cards: cards)
                case ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription.description)
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
                        self?.delegate?.showError(error: error)
                    break
                }
            }
        }
    }
    
    func getMoreListCards(contractId: String, contractObjectId: String, createdAt: Double) {
        self.delegate?.lockUI()
        cardService.getMoreListCards(contractId: contractId, contractObjectId: contractObjectId, createdAt: createdAt) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case.success(let res):
                switch res.code {
                case ResponseCode.OK_200.rawValue:
                    guard let cards = res.data else {
                        self?.delegate?.showError(error: ApiError.otherError)
                        return
                    }
                    Logger.Logs(message: cards)
                    self?.delegate?.updateUI(cards: cards)
                case ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
            case .failure(let error):
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
                        Logger.Logs(event: .error, message: err)
                    }
                    
                default:
                    Logger.Logs(message: error)
                        self?.delegate?.showError(error: error)
                    break
                }
                //                    Logger.Logs(event: .error, message: error.localizedDescription.description)
            }
        }
    }
    
    func getListCardsByName(name: String) {
        self.delegate?.lockUI()
        cardService.getListCardsByName(name: name) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case.success(let res):
                switch res.code {
                case ResponseCode.OK_200.rawValue:
                    guard let cards = res.data else {
                        self?.delegate?.showError(error: ApiError.otherError)
                        return
                    }
                    Logger.Logs(message: cards)
                    self?.delegate?.updateUI(cards: cards)
                case ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription.description)
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
                        self?.delegate?.showError(error: error)
                    break
                }
            }
        }
    }
    
    func getMoreListCardsByName(name: String, contractId: String, contractObjectId: String, createdAt: Double) {
        self.delegate?.lockUI()
        cardService.getMoreListCardsByName(name: name, contractId: contractId, contractObjectId: contractObjectId, createdAt: createdAt) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case.success(let res):
                switch res.code {
                case ResponseCode.OK_200.rawValue:
                    guard let cards = res.data else {
                        self?.delegate?.showError(error: ApiError.otherError)
                        return
                    }
                    Logger.Logs(message: cards)
                    self?.delegate?.updateUI(cards: cards)
                case ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription.description)
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
                        self?.delegate?.showError(error: error)
                    break
                }
            }
        }
    }
    
    func getClaimList(contractObjectId: String, claimId: String = "", createdAt: Int = 0, status: Int? = nil, dateFrom: Int? = nil, dateTo: Int? = nil) {
        self.delegate?.lockUI()
        cardService.getClaimList(contractObjectId: contractObjectId, claimId: claimId, createdAt: createdAt, status: status, dateFrom: dateFrom, dateTo: dateTo) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case.success(let res):
                switch res.code {
                case ResponseCode.OK_200.rawValue:
                    guard let history = res.data else {
                        self?.delegate?.showError(error: ApiError.otherError)
                        return
                    }
                    Logger.Logs(message: history)
                    self?.delegate?.updateClaimHistory(history: history)
                case ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription.description)
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
                        self?.delegate?.showError(error: error)
                    break
                }
            }
        }
    }
    
    func getHospitalList(contractObjectId: String, hospitalId: String = "", createdAt: Int = 0, isBlackList: Bool = false, search: String = "") {
        self.delegate?.lockUI()
        cardService.getHospitalList(contractObjectId: contractObjectId, hospitalId: hospitalId, createdAt: createdAt, isBlackList: isBlackList, search: search) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case.success(let res):
                switch res.code {
                case ResponseCode.OK_200.rawValue:
                    guard let hospitals = res.data else {
                        self?.delegate?.showError(error: ApiError.otherError)
                        return
                    }
                    Logger.Logs(message: hospitals)
                    self?.delegate?.updateHospital(hospitals: hospitals, isBlackList: isBlackList)
                case ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription.description)
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
                        self?.delegate?.showError(error: error)
                    break
                }
            }
        }
    }
}
