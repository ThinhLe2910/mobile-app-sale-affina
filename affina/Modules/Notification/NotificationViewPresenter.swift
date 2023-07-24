//
//  NotificationViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/01/2023.
//

import Foundation

protocol NotificationViewDelegate {
    func lockUI()
    func unlockUI()
    
    func updateListTopics(topics: [NotificationTopicModel])
    func updateListNotifications(list: [NotificationModel])
    
    func handleError(error: ApiError)
}

class NotificationViewPresenter {
    var delegate: NotificationViewDelegate?
    
    private let notiService = NotificationService()
    
    init() { }
    
    func getListTopics() {
        delegate?.lockUI()
        notiService.getListTopics { [weak self] result in
            self?.delegate?.unlockUI()

            switch result {
            case .success(let data):
                guard let data = data.data else { return }
                self?.delegate?.updateListTopics(topics: data)
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self?.delegate?.handleError(error: ApiError.expired)
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                    
                default:
                    self?.delegate?.handleError(error: error)
                    break
                }
            }
        }
    }
    
    func getListNotifications(topicId: String, limit: Int = 10, createdAt: Double = -1, id: String = "") {
        delegate?.lockUI()
        
        notiService.getListNotifications(topicId: topicId, limit: limit, createdAt: createdAt, id: id) { [weak self] result in
            self?.delegate?.unlockUI()

            switch result {
            case .success(let data):
                self?.delegate?.updateListNotifications(list: data.data ?? [])
            case .failure(let error):
                Logger.Logs(message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self?.delegate?.handleError(error: ApiError.expired)
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                default:
                    self?.delegate?.handleError(error: error)
                    break
                }
            }
        }
    }
    
    func getListEvents(limit: Int = 10, createdAt: Double = -1, id: String = "") {
        delegate?.lockUI()
        notiService.getListEvents(limit: limit, createdAt: createdAt, id: id) { [weak self] result in
            self?.delegate?.unlockUI()
            
            switch result {
                case .success(let data):
                    self?.delegate?.updateListNotifications(list: data.data ?? [])
                case .failure(let error):
                    Logger.Logs(message: error)
                    switch error {
                        case ApiError.invalidData(let error, let data):
                            Logger.Logs(message: error)
                            guard let data = data else { return }
                            do {
                                let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                                if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                    self?.delegate?.handleError(error: ApiError.expired)
                                }
                            }
                            catch let err{
                                Logger.DumpLogs(event: .error, message: err)
                            }
                            
                        default:
                            self?.delegate?.handleError(error: error)
                            break
                    }
            }
        }
    }
}
