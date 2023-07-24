//
//  ClaimBenefitDetailPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 15/12/2022.
//

import UIKit

struct AdditionalDocument: Codable {
    let id: String
    let listDocument: [AttachmentModel]
}

struct AttachmentModel: Codable {
    let type: String
    let attachments: String
}

protocol ClaimBenefitDetailViewDelegate {
    func unlockUI()
    func lockUI()
    
    func uploadFilesSuccess(files: String)
    
    func updateSuccess()
    func updateUI(model: ClaimDetailModel)
    
    func showError(error: ApiError)
}

class ClaimBenefitDetailPresenter {
    var delegate: ClaimBenefitDetailViewDelegate?
    private let imageService = ImageService()
    private let claimService = ClaimService()
    
    func updateProofImages(document: AdditionalDocument) {
        delegate?.lockUI()
        var jsonStr : String = ""
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(document)
            jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)!
        } catch { }
        
        var request = URLRequest(url: URL(string: API.Claim.CREATE_CLAIM)!)
        request.httpMethod = "PUT"
        request.headers = APIManager.shared.getTokenHeader()
        request.httpBody = (jsonStr).data(using: .utf8)
            
        let request3 = BaseApiRequest(path: API.Claim.CREATE_CLAIM, method: .put, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: (jsonStr).data(using: .utf8))
        APIManager.shared.send2(request: request3) { [weak self] (result: Result<APIResponse<NilData>, ApiError>) in
//        APIManager.shared.send3(apiRequest: request2) { [weak self] (result: Result<APIResponse<NilData>, ApiError>) in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                Logger.Logs(message: data)
                self?.delegate?.updateSuccess()
                break
            case .failure(let error):
                self?.delegate?.showError(error: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self?.delegate?.showError(error: ApiError.expired)
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                default:
                        self?.delegate?.showError(error: error)
                    break
                }
                break
            }
        }
    }
    
    func getClaimDetail(id: String) {
        delegate?.lockUI()
        claimService.getClaimDetail(id: id) { [weak self] result in
            self?.delegate?.unlockUI()
            
            switch result {
            case .success(let data):
                guard let self = self, let data = data.data else { return }
                self.delegate?.updateUI(model: data)
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self?.delegate?.showError(error: ApiError.expired)
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                    
                default:
                        self?.delegate?.showError(error: error)
                    break
                }
                break
            }
        }
    }
    
    func uploadImages(images: [UIImage]) {
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
                        self?.delegate?.uploadFilesSuccess(files: String(data: json, encoding: String.Encoding.utf8) ?? "")
                    } catch (let err) {
                        Logger.Logs(event: .error, message: err)
                        self?.delegate?.showError(error: .notResponse)
                    }
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self?.delegate?.showError(error: error)
                break
            }
        }
    }
    
}

