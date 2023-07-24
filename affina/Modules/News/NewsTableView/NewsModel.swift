//
//  NewsModel.swift
//  affina
//
//  Created by Intelin MacHD on 28/07/2022.
//

import Foundation

enum IsLiked: Int {
    case YES = 1, NO = 0
}

// MARK: - Comment
struct CommentModel: Codable {
    let id, userID, newsID, content: String
    let createdAt: Int
    let createdBy: String
    let modifiedAt: Int
    let modifiedBy: String
    let name: String
    let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case newsID = "newsId"
        case content, createdAt, createdBy, modifiedAt, modifiedBy
        case name, avatar
    }
}


struct NewsCategoryData: Decodable, Encodable {
    let list: [NewsCategoryModel]
}

struct OutstandingNewsData: Decodable, Encodable {
    let list: [OutstandingNewsModel]
}

struct NewsData: Decodable, Encodable {
    let data: [NewsModel]
}

struct NewsDetailData: Decodable, Encodable {
    let data: NewsDetailModel
}

class NewsModel: Codable {
    private var newsId: String?
    private var newsName: String?
    private var newsTopic: String?
    private var topicName: String?
    private var newsType : Int?
    private var newsStatus: Int?
    private var newsContent: String?
    private var newsImage1: String?
    private var newsImage2: String?
    private var createdBy: String?
    private var createdAt: Int64?
    private var modifiedBy: String?
    private var modifiedAt: Int64?
    
    private var numberLike: Int?
    private var listComment: [CommentModel]?
    private var isLiked: Int?
    
    func getIsLiked() -> Int {
        return isLiked ?? 0
    }
    
    func getNumberLikes() -> Int {
        return numberLike ?? 0
    }
    
    func getNumberComments() -> Int {
        return listComment?.count ?? 0
    }
    
    func getNewsId()-> String {
        guard let newsId = newsId else {
            return ""
        }
        return newsId
    }
    
    func setNewsId(_ newsId: String)->Self {
        self.newsId = newsId
        return self
    }
    
    func getNewsName()-> String {
        guard let newsName = newsName else {
            return ""
        }
        return newsName
    }
    
    func setNewsName(_ newsName: String)->Self {
        self.newsName = newsName
        return self
    }
    
    
    func setNewsTopic(_ newsTopic: String)->Self {
        self.newsTopic = newsTopic
        return self
    }
    
    func getNewsTopic() -> String {
        guard let newsTopic = newsTopic else {
            return ""
        }
        return newsTopic
    }
    
    func setTopicName(_ topicName: String)->Self {
        self.topicName = topicName
        return self
    }
    
    func getTopicName()-> String {
        guard let topicName = topicName else {
            return ""
        }
        return topicName
    }
    
    func getNewsType()-> Int {
        guard let newsType = newsType else {
            return -1
        }
        return newsType
    }
    
    func setNewsType(_ newsType: Int)-> Self {
        self.newsType = newsType
        return self
    }
    
    func getNewsContent()-> String {
        guard let newsContent = newsContent else {
            return ""
        }
        return newsContent
    }
    
    func setNewsContent(_ newsContent: String)->Self {
        self.newsContent = newsContent
        return self
    }
    
    func setNewsImage1(_ newsImage1: String)->Self {
        self.newsImage1 = newsImage1
        return self
    }
    
    func getNewsImage1()-> String {
        guard let newsImage1 = newsImage1 else {
            return ""
        }
        return newsImage1
    }
    
    func setNewsImage2(_ newsImage2: String)->Self {
        self.newsImage2 = newsImage2
        return self
    }
    
    func getNewsImage2()-> String {
        guard let newsImage2 = newsImage2 else {
            return ""
        }
        return newsImage2
    }
    
    func getCreatedBy()-> String {
        guard let createdBy = createdBy else {
            return ""
        }
        return createdBy
    }
    
    func setCreatedBy(_ createdBy: String)->Self {
        self.createdBy = createdBy
        return self
    }
    
    func getCreatedAt()-> Int64 {
        guard let createdAt = createdAt else {
            return 0
        }
        return createdAt
    }
    
    func setCreatedAt(_ createdAt: Int64)->Self {
        self.createdAt = createdAt
        return self
    }
    
    func getModifiedBy()-> String {
        guard let modifiedBy = modifiedBy else {
            return ""
        }
        return modifiedBy
    }
    
    func setModifiedBy(_ modifiedBy: String)->Self {
        self.modifiedBy = modifiedBy
        return self
    }
    
    func getModifiedAt()-> Int64 {
        guard let modifiedAt = modifiedAt else {
            return 0
        }
        return modifiedAt
    }
    
    func setModifiedAt(_ modifiedAt: Int64)->Self {
        self.modifiedAt = modifiedAt
        return self
    }
}
