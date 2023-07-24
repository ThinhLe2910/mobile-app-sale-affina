//
//  VoucherReviewViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/03/2023.
//

import UIKit

protocol VoucherReviewViewDelegate: AnyObject {
    func ratingVoucherSuccess()
    func handleRatingError()
    
    func lockUI()
    func unlockUI()
}

class VoucherReviewViewPresenter {
    weak var delegate: VoucherReviewViewDelegate?
    private let voucherService = VoucherService()
    
    private let imageService = ImageService()
    
    func ratingVoucher(voucherId: String, providerId: String, code: String, point: Int, comment: String, images: [UIImage]) {
        delegate?.lockUI()
        if images.isEmpty {
            voucherService.ratingVoucher(voucherId: voucherId, providerId: providerId, code: code, point: point, comment: comment, images: "[]") { [weak self] result in
                self?.delegate?.unlockUI()
                switch result {
                    case .success(let data):
                        Logger.Logs(message: data)
                        self?.delegate?.ratingVoucherSuccess()
                    case .failure(let error):
                        Logger.Logs(event: .error, message: error)
                        self?.delegate?.handleRatingError()
                }
            }
            return
        }
        uploadImages(images: images) { [weak self] uploadResult in
            switch uploadResult {
                case .success(let imagesString):
                if let data = imagesString.data(using: .utf16) {
                    if let jsonArray = try? JSONDecoder().decode([[String:String]].self, from: data) {
                        var imageLinks = []
                        for item in jsonArray {
                            if let url = item["link"] {
                                imageLinks.append(url)
                            }
                        }
                        self?.voucherService.ratingVoucher(voucherId: voucherId, providerId: providerId, code: code, point: point, comment: comment, images: "\(imageLinks)") { result in
                            self?.delegate?.unlockUI()
                            switch result {
                                case .success(let data):
                                    Logger.Logs(message: data)
                                    self?.delegate?.ratingVoucherSuccess()
                                case .failure(let error):
                                    Logger.Logs(event: .error, message: error)
                                    self?.delegate?.handleRatingError()
                            }
                        }
                    }
                }
                
                case .failure(let err):
                    Logger.Logs(event: .error, message: err)
            }
        }
    }
    
    private func uploadImages(images: [UIImage], completion: @escaping ((Result<String, ApiError>) -> Void)) {
        self.delegate?.lockUI()
        let request = BaseApiRequest(path: API.Other.PUBLIC_UPLOAD, method: .put, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil) // headers: ["Content-type": "multipart/form-data"]
        imageService.uploadMultiImages(images: images.compactMap({ $0.jpegData(compressionQuality: 1.0) }), to: request.request(), params: [:]) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
                case .success(let data):
                    Logger.Logs(message: data.data?.files)
                    if let files = data.data?.files {
                        do{
                            let json = try JSONEncoder().encode(files)
                            //                            Logger.Logs(message: String(data: json, encoding: String.Encoding.utf8))
                            completion(.success(String(data: json, encoding: String.Encoding.utf8) ?? ""))
                        } catch (let err) {
                            Logger.Logs(event: .error, message: err)
                            completion(.failure(.invalidData(err)))
                        }
                    }
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
                    completion(.failure(.unknown))
                    break
            }
        }
    }
}
