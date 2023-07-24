//
//  HomeService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class HomeService {
    
    func getListProgramType(completion: @escaping ((Result<APIResponse<[ProgramType]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Sale.GET_ALL_PROGRAM_TYPE, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[ProgramType]>, ApiError>) in
            completion(result)
        }
        
    }
    
    func getProfile(completion: @escaping (Result<APIResponse<ProfileModel>, ApiError>) -> Void) {
        let request = BaseApiRequest(path: API.User.GET_PROFILE, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)

        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ProfileModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getListFeaturedProducts(completion: @escaping ((Result<APIResponse<[HomeFeaturedProduct]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: UIConstants.isLoggedIn ? API.Home.GET_LOGGED_IN_FEATURED_PRODUCTS : API.Home.GET_FEATURED_PRODUCTS, method: .get, parameters: [:], isJsonRequest: false, headers: UIConstants.isLoggedIn ? APIManager.shared.getTokenHeader() : [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[HomeFeaturedProduct]>, ApiError>) in
            completion(result)
        }
    }
    
    func getCampaignBannersList(completion: @escaping((Result<APIResponse<[HomeBannerModel]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Campaign.GET_BANNER, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getSimpleHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[HomeBannerModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getPopupList(completion: @escaping((Result<APIResponse<[HomeEventModel]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Campaign.GET_POPUP, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getSimpleHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[HomeEventModel]>, ApiError>) in
            completion(result)
        }
    }
}
