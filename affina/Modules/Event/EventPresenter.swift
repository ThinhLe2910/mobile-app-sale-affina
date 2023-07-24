//
//  EventPresenter.swift
//  affina
//
//  Created by Intelin MacHD on 04/04/2023.
//

import Foundation

protocol EventBannerDetailProtocol {
    func updateInfo(data: EventBannerModel)
    func showError(error: ApiError)
}

protocol EventDetailProtocol {
    func updateInfo(data: EventModel)
    func showError(error: ApiError)
    func handleGetVoucherSummarySuccess(summary: VoucherSummaryModel)
}

class EventPresenter {
    
    private let eventService = EventService()
    private let voucherService = VoucherService()
    
    var bannerDetailDelegate: EventBannerDetailProtocol?
    var eventDetailDelegate: EventDetailProtocol?
    
    func setDelegate(input: EventBannerDetailProtocol) {
        bannerDetailDelegate = input
    }
    
    func setDelegate(input: EventDetailProtocol) {
        eventDetailDelegate = input
    }
    
    func requestGetBannerDetail(id: String) {
        eventService.getBannerDetail(id: id) { [weak self] result in
            switch result {
            case .success(let data):
                Logger.Logs(message: data)
                guard let data = data.data else {
                    self?.bannerDetailDelegate?.showError(error: .otherError)
                    return
                }
                self?.bannerDetailDelegate?.updateInfo(data: data)
            case .failure(let error):
                self?.bannerDetailDelegate?.showError(error: error)
            }
        }
    }
    
    func requestGetEventDetail(id: String) {
        eventService.getEventDetail(id: id) { [weak self] result in
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    guard let data = data.data else {
                        self?.eventDetailDelegate?.showError(error: .otherError)
                        return
                    }
                    self?.eventDetailDelegate?.updateInfo(data: data)
                case .failure(let error):
                    self?.eventDetailDelegate?.showError(error: error)
            }
        }
    }
    
    func getVoucherSummary() {
        voucherService.getVoucherSummary { [weak self] result in
            switch result {
                case .success(let data):
                    guard let data = data.data else {
                        self?.eventDetailDelegate?.showError(error: .otherError)
                        return
                    }
                    self?.eventDetailDelegate?.handleGetVoucherSummarySuccess(summary: data)
                    
                case .failure(let error):
                    self?.eventDetailDelegate?.showError(error: error)
                    Logger.Logs(event: .error, message: error)
            }
        }
    }
}
