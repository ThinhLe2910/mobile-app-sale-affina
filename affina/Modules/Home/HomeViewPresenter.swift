//
//  HomeViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 23/05/2022.
//

import Foundation

protocol HomeViewDelegate {
    func lockUI()
    func unLockUI()
    
    func updateUI()
    func updateDisplayName()
    
    func showAlert()
    func showError(error: ApiError)
    
    func updateListCard(list: [ListSetupCard])
    func updateListProgramType(list: [ProgramType])
    func updateListBanners(list: [ListSetupBanner])
    func updateListFeaturedProducts(list: [HomeFeaturedProduct])
    
    func updateNotificationStatus(status: Int)
    func updateBannersList(list: [HomeBannerModel])
    func showPopupFromList(list: [HomeEventModel])
}

class HomeViewPresenter {
    
    private var delegate: HomeViewDelegate?
    
    private let homeService = HomeService()
    private let commonService = CommonService()
    private let notiService = NotificationService()
//    private let cardService = CardService()
    
    func setViewDelegate(delegate: HomeViewDelegate?) {
        self.delegate = delegate
    }
    
    func getListProgramType() {
//        self.delegate?.lockUI()
        homeService.getListProgramType { [weak self] result in
//            self?.delegate?.unLockUI()
            guard let self = self else { return }
            switch result {
                case .success(let data):
                    guard let list = data.data else { return }
                    Logger.Logs(message: list)
                    self.delegate?.updateListProgramType(list: list)
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self.delegate?.showError(error: error)
                    break
            }
        }
    }
    
    func getProfile(completion: @escaping (Result<ProfileModel, ApiError>) -> Void) {
//        self.delegate?.lockUI()
        homeService.getProfile { [weak self] result in
//            self?.delegate?.unLockUI()
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    switch data.code {
                        case ProfileCode.OK_200.rawValue:
                            if let model = data.data {
                                AppStateManager.shared.profile = model
                                let cacheData = CacheData(json: Json.filterJson(model))
                                CacheManager.shared.insertCacheWithKey(Key.profile.rawValue, cacheData)
                                //                        UserDefaults.standard.set(model.displayID, forKey: Key.customerName.rawValue)
                                completion(.success(model))
                            }
                            break
                        case ProfileCode.AUTH_4001.rawValue:
                            break
                        case CheckPhoneCode.LOGIN_4002.rawValue, ErrorCode.EXPIRED.rawValue:
                            self?.delegate?.showError(error: ApiError.expired)
                            completion(.failure(.expired))
                        default:
                            break
                    }
                    break
                case .failure(let error):
                    switch error {
                        case ApiError.invalidData(let error, let data):
                            Logger.Logs(message: error)
                            guard let data = data else { return }
                            do {
                                let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                                if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                    self?.delegate?.showError(error: ApiError.expired)
                                    completion(.failure(.expired))
                                }
                            }
                            catch let err{
                                Logger.Logs(event: .error, message: err)
                            }
                            
                        default:
                            Logger.Logs(message: error)
                            break
                    }
                    
                    break
            }
        }
    }
    
    func getListFeaturedProducts() {
        homeService.getListFeaturedProducts { [weak self] result in
            switch result {
                case .success(let data):
                    guard let list = data.data else { return }
                    Logger.Logs(message: list)
                    self?.delegate?.updateListFeaturedProducts(list: list)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
    
    func getAllSetup() {
        commonService.getAllSetup { [weak self] result in
            switch result {
                case .success(let data):
                    guard let list = data.data else { return }
                    self?.delegate?.updateListBanners(list: list.listBanner ?? [])
                    self?.delegate?.updateListCard(list: list.listCard ?? [])
                    //                self?.delegate?.updateListFeaturedProducts(list: list.listCoverImageProgram ?? [])
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
    
    func getNotificationStatus() {
        notiService.getNotificationStatus { [weak self] result in
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    AppStateManager.shared.hasUnReadNoti = (data.data?.status ?? 1) == 0
                    self?.delegate?.updateNotificationStatus(status: data.data?.status ?? 1)
                case .failure(let error):
                    Logger.Logs(message: error)
                    self?.delegate?.showError(error: error)
            }
        }
    }
    
    func getBannerList() {
        homeService.getCampaignBannersList { [weak self] result in
            switch result {
                case .success(let data):
                    Logger.Logs(message: data)
                    self?.delegate?.updateBannersList(list: data.data ?? [])
                case .failure(let error):
                Logger.Logs(message: error.localizedDescription)
                    self?.delegate?.showError(error: error)
            }
        }
    }
    
    func getPopupList() {
        homeService.getPopupList { [weak self] result in
            switch result {
            case .success(let data):
                Logger.Logs(message: data)
                guard let data = data.data else {
                    self?.delegate?.showError(error: .otherError)
                    return
                }
                let readPopup = EventPopupManager.shared.getShownPopup()
                let filtered = data.filter({!readPopup.contains($0.campaignId ?? "")})
                self?.delegate?.showPopupFromList(list: filtered)
            case .failure(let error):
                Logger.Logs(message: error.localizedDescription)
                self?.delegate?.showError(error: error)
            }
        }
    }
}
