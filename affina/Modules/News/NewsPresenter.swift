//
//  NewsPresenter.swift
//  affina
//
//  Created by Intelin MacHD on 28/07/2022.
//

import Foundation
import UIKit

protocol NewsPresenterDelegate: BaseProtocol {
    func handleFetchCategoryListSuccess(_ list: [NewsCategoryViewModel])
    func handleFetchOutstandingNewsSuccess(_ list: [NewsCarouselView.NewsCarouselData])
    func handleFetchNewsSuccess(_ list: [NewsItemTableViewModel])
    
    func likeNewsSuccess(newsId: String)
}

protocol NewsPresenterDetailDelegate: BaseProtocol {
    func handleGetDetailSuccess(_ detail: NewsDetailModel)
    
    func likeNewsSuccess(newsId: String)
    func sendCommentSuccess()
}

class NewsRequest: BaseApiRequest {
}

class NewsPresenter {
    weak fileprivate var delegate: NewsPresenterDelegate?
    weak fileprivate var detailDelegate: NewsPresenterDetailDelegate?
    
    private let newService = NewService()
    
    func setDelegate(_ viewControlller: NewsPresenterDelegate) {
        delegate = viewControlller
    }
    
    func setDetailDelegate(_ viewController: NewsPresenterDetailDelegate) {
        detailDelegate = viewController
    }
    
    func fetchCategoryList() {
        delegate?.lockUI()
        newService.fetchCategoryList { [weak self] (result: Result<APIResponse<NewsCategoryData>, ApiError>) in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    //Logger.DumpLogs(event: .debug, message: data)
                    if data.code == ResponseCode.OK_200.rawValue {
                        //Logger.DumpLogs(event: .info, message: data.data?.list)
                        guard let list = data.data?.list else { return }
                        let resultList = list.map { item in
                            return NewsCategoryViewModel(name: item.getName(), id: item.getId())
                        }
                        self?.delegate?.handleFetchCategoryListSuccess(resultList)
                    } else {
                        self?.delegate?.showError(error: .otherError)
                    }
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
                    break
            }
        }
    }
    
    func fetchOutstandingNews(of categoryId: String) {
        delegate?.lockUI()
        newService.fetchOutstandingNews(of: categoryId) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    //Logger.DumpLogs(event: .debug, message: data)
                    if data.code == ResponseCode.OK_200.rawValue {
                        //Logger.DumpLogs(event: .info, message: data.data?.list)
                        guard let list = data.data?.list else { return }
                        var resultList = [NewsCarouselView.NewsCarouselData]()
                        for item in list {
                            if URL(string: API.STATIC_RESOURCE + item.getNewsImage2()) != nil {
                                resultList.append(NewsCarouselView.NewsCarouselData(id: item.getNewsId(), image: item.getNewsImage2(), time: Date(timeIntervalSince1970: Double(item.getCreatedAt()) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY"), title: item.getNewsName(), numberLikes: item.getNumberLikes(), numberComments: item.getNumberComments(), isLiked: item.getIsLiked()))
                                
                            } else {
                                resultList.append(NewsCarouselView.NewsCarouselData(id: item.getNewsId(), image: nil, time: Date(timeIntervalSince1970: Double(item.getCreatedAt()) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY"), title: item.getNewsName(), numberLikes: item.getNumberLikes(), numberComments: item.getNumberComments(), isLiked: item.getIsLiked()))
                            }
                        }
                        self?.delegate?.handleFetchOutstandingNewsSuccess(resultList)
                    } else {
                        self?.delegate?.showError(error: .otherError)
                    }
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
                    break
            }
        }
    }
    
    func fetchNews(of categoryId: String, newsId: String?, createdAt: Int64?) {
        delegate?.lockUI()
        newService.fetchNews(of: categoryId, newsId: newsId, createdAt: createdAt) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    //Logger.DumpLogs(event: .debug, message: data)
                    if data.code == ResponseCode.OK_200.rawValue {
                        guard let list = data.data else { return }
                        var resultList = [NewsItemTableViewModel]()
                        if list.count == 0 {
                            self?.delegate?.handleFetchNewsSuccess([NewsItemTableViewModel]())
                            return
                        }
                        for item in list {
                            if URL(string: API.STATIC_RESOURCE + item.getNewsImage1()) != nil {
                                resultList.append(NewsItemTableViewModel(id: item.getNewsId(), title: item.getNewsName(), content: item.getNewsContent(), date: Date(timeIntervalSince1970: Double(item.getCreatedAt()) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY"), image: item.getNewsImage1(), createdAt: item.getCreatedAt(), numberLikes: item.getNumberLikes(), numberComments: item.getNumberComments(), isLiked: item.getIsLiked()))
                            } else {
                                resultList.append(NewsItemTableViewModel(id: item.getNewsId(), title: item.getNewsName(), content: item.getNewsContent(), date: Date(timeIntervalSince1970: Double(item.getCreatedAt()) / 1000).convertToString(with: "HH:mm - dd/MM/YYYY"), image: nil, createdAt: item.getCreatedAt(), numberLikes: item.getNumberLikes(), numberComments: item.getNumberComments(), isLiked: item.getIsLiked()))
                            }
                        }
                        self?.delegate?.handleFetchNewsSuccess(resultList)
                    } else {
                        self?.delegate?.showError(error: .otherError)
                    }
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
                    break
            }
        }
    }
    
    func fetchNewsDetail(of id: String) {
        self.detailDelegate?.lockUI()
        newService.fetchNewsDetail(of: id) { [weak self] result in
            self?.detailDelegate?.unlockUI()
            switch result {
                case .success(let data):
                    //Logger.DumpLogs(event: .debug, message: data)
                    if data.code == ResponseCode.OK_200.rawValue {
                        //Logger.DumpLogs(event: .info, message: data.data?.list)
                        guard let data = data.data else { return }
                        self?.detailDelegate?.handleGetDetailSuccess(data)
                    } else {
                        self?.delegate?.showError(error: .otherError)
                    }
                case .failure(let error):
                    Logger.DumpLogs(event: .error, message: error.localizedDescription)
                    self?.delegate?.showError(error: .otherError)
                    break
            }
        }
    }
    
    func likeNews(newsId: String, isLiked: Bool = false) {
        newService.likeNews(newsId: newsId, isLiked: isLiked) { [weak self] result in
            switch result {
                case .success(let data):
                    switch data.code {
                        case ResponseCode.OK_200.rawValue:
                            self?.delegate?.likeNewsSuccess(newsId: newsId)
                            self?.detailDelegate?.likeNewsSuccess(newsId: newsId)
                        case ResponseCode.SERVER_500.rawValue:
                            self?.delegate?.showError(error: .otherError)
                        default: break
                    }
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
            }
        }
    }
    
    func unlikeNews(newsId: String) {
        likeNews(newsId: newsId, isLiked: true)
    }
    
    func createComment(newsId: String, comment: String) {
        detailDelegate?.lockUI()
        
        newService.createComment(newsId: newsId, comment: comment) { [weak self] result in
            self?.detailDelegate?.unlockUI()
            switch result {
                case .success(let data):
                    switch data.code {
                        case ResponseCode.OK_200.rawValue:
                            self?.detailDelegate?.sendCommentSuccess()
                        default:
                            break
                    }
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    self?.delegate?.showError(error: .otherError)
                    break
            }
        }
    }
    
}
