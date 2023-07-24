//
//  EventService.swift
//  affina
//
//  Created by Intelin MacHD on 04/04/2023.
//

import Foundation

class EventService {
    
    func getBannerDetail(id: String, completion: @escaping((Result<APIResponse<EventBannerModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Campaign.GET_DETAIL_BANNER, method: .get, parameters: ["campaignId":id], isJsonRequest: false, headers: APIManager.shared.getSimpleHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<EventBannerModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getEventDetail(id: String, completion: @escaping((Result<APIResponse<EventModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Campaign.GET_DETAIL_POPUP, method: .get, parameters: ["campaignId":id], isJsonRequest: false, headers: APIManager.shared.getSimpleHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<EventModel>, ApiError>) in
            completion(result)
        }
    }
}
