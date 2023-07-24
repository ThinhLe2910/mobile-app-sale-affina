//
//  NotificationService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class NotificationService {
    
    func getListTopics(completion: @escaping ((Result<APIResponse<[NotificationTopicModel]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Notification.GET_LIST_TOPICS, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[NotificationTopicModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getListNotifications(topicId: String, limit: Int = 10, createdAt: Double = -1, id: String = "", completion: @escaping ((Result<APIResponse<[NotificationModel]>, ApiError>) -> Void)) {
        var params: [String: Any] = [
            // "createdAt": 1658913266000,
            // "id": "33fa76301d9cb6d0d43e01823eef9cef",
            "limit": limit,
            "notificationTopicId": topicId
        ]
        if createdAt != -1 {
            params["createdAt"] = createdAt
        }
        
        if !id.isEmpty {
            params["id"] = id
        }
        
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            //            body = try JSONEncoder().encode(params)
        } catch { }
        
        let request = BaseApiRequest(path: API.Notification.GET_LIST_NOTIFICATION, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[NotificationModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getListEvents(limit: Int = 10, createdAt: Double = -1, id: String = "", completion: @escaping ((Result<APIResponse<[NotificationModel]>, ApiError>) -> Void)) {
        var params: [String: Any] = [
            // "createdAt": 1658913266000,
            // "id": "33fa76301d9cb6d0d43e01823eef9cef",
            "limit": limit,
        ]
        if createdAt != -1 {
            params["createdAt"] = createdAt
        }
        
        if !id.isEmpty {
            params["id"] = id
        }
        
        var body: Data?
        do {
            body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            //            body = try JSONEncoder().encode(params)
        } catch { }
        
        let request = BaseApiRequest(path: API.Notification.GET_LIST_EVENTS, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[NotificationModel]>, ApiError>) in
            completion(result)
        }
    }
    
    
    func getNotificationStatus(completion: @escaping ((Result<APIResponse<NotificationStatusModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Notification.GET_LIST_NOTIFICATION, method: .put, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NotificationStatusModel>, ApiError>) in
            completion(result)
        }
    }
}
