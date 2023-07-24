//
//  NewService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 01/03/2023.
//

import Foundation

class NewService {
    
    func fetchCategoryList(completion: @escaping ((Result<APIResponse<NewsCategoryData>, ApiError>) -> Void)) {
        let body: [String: Any] = ["order": "id",
                                   "by": "desc",
                                   "from": 0,
                                   "limit": 20]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = NewsRequest(path: API.News.GET_CATEGORY, method: .delete, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NewsCategoryData>, ApiError>) in
            completion(result)
        }
    }
    
    func fetchOutstandingNews(of categoryId: String, completion: @escaping ((Result<APIResponse<OutstandingNewsData>, ApiError>) -> Void)) {
        let body: [String: Any] = ["order": "newsId",
                                   "by": "desc",
                                   "from": 0,
                                   "limit": 10,
                                   "filter": "news.newsTopic",
                                   "filterValue": categoryId,
                                   "filter1": "news.newsType",
                                   "filterValue1": "1"]
        let data: Data? = try? JSONSerialization.data(withJSONObject: body, options: [])
        let request = NewsRequest(path: API.News.GET_OUTSTANDING_NEWS, method: .delete, parameters: [:], isJsonRequest: true, headers: UIConstants.isLoggedIn ? APIManager.shared.getTokenHeader() : [:] as [String: String], httpBody: data)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<OutstandingNewsData>, ApiError>) in
            completion(result)
        }
    }
    
    func fetchNews(of categoryId: String, newsId: String?, createdAt: Int64?, completion: @escaping ((Result<APIResponse<[NewsModel]>, ApiError>) -> Void)) {
        var param = ["limit": 10,
                     "newsTopic": categoryId,
                     "newsObject": 1] as [String: Any]
        if let newsId = newsId {
            param.updateValue(newsId, forKey: "newsTopic")
        }
        if let createdAt = createdAt {
            param.updateValue(createdAt, forKey: "createdAt")
        }
        let body: Data? = try? JSONSerialization.data(withJSONObject: param, options: [])
        let request = NewsRequest(path: API.News.GET_OUTSTANDING_NEWS, method: .post, parameters: [:], isJsonRequest: true, headers: UIConstants.isLoggedIn ? APIManager.shared.getTokenHeader() : [:], httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[NewsModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func fetchNewsDetail(of id: String, completion: @escaping ((Result<APIResponse<NewsDetailModel>, ApiError>) -> Void)) {
        let request = NewsRequest(path: API.News.GET_OUTSTANDING_NEWS, method: .get, parameters: ["newsId":id], isJsonRequest: false, headers: UIConstants.isLoggedIn ? APIManager.shared.getTokenHeader() : [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NewsDetailModel>, ApiError>) in
            completion(result)
        }
    }
    
    func likeNews(newsId: String, isLiked: Bool = false, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        let param: [String: Any] = ["newsId": newsId]
        let body: Data? = try? JSONSerialization.data(withJSONObject: param, options: [])
        let request = BaseApiRequest(path: API.News.LIKE_NEWS, method: isLiked ? .put : .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
    func createComment(newsId: String, comment: String, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        let param: [String: Any] = ["newsId": newsId, "content": comment]
        let body: Data? = try? JSONSerialization.data(withJSONObject: param, options: [])
        
        let request = BaseApiRequest(path: API.News.COMMENT_NEWS, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: body)

        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
}
