//
//  ProofViewPresenter.swift
//  affina
//
//  Created by Dylan on 27/09/2022.
//

import Foundation
import UIKit

protocol ProofViewDelegate {
    func lockUI()
    func unlockUI()
    
    func updateUI()
    func showError(error: ApiError)
    
    func uploadFilesSuccess(files: String)
    func createClaimSuccess()
    func updateListTreatmentPlacesBaoMinh(list: PagedListDataRespone)
    func updateListTreatmentPlaces(list: [CoSoYTeModel])
    func updateListBanks(banks: [Bank])
}

extension ProofViewDelegate {
    func updateListBanks(banks: [Bank]) {}
}

class ProofViewPresenter {
    
    var delegate: ProofViewDelegate?
    
    private let commonService = CommonService()
    private let imageService = ImageService()
    private let claimService = ClaimService()
    
    init() { }
    
    func createClaimRequest(model: ClaimRequestModel) {
        delegate?.lockUI()
        Logger.Logs(message: model.dict)
        claimService.createClaimRequest(model: model) { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                switch data.code {
                case ResponseCode.OK_200.rawValue:
                    self?.delegate?.createClaimSuccess()
                    break
                case ResponseCode.AUTH_4001.rawValue:
                    self?.delegate?.showError(error: .otherError)
                    
                default:
                    self?.delegate?.showError(error: .otherError)
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
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
                    break
                }
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
    
    func getListBanks() {
        self.delegate?.lockUI()
        
        claimService.getListBanks { [weak self] result in
            self?.delegate?.unlockUI()
            switch result {
            case .success(let data):
                if data.code == ResponseCode.OK_200.rawValue {
                    guard let data = data.data else { return }
                    self?.delegate?.updateListBanks(banks: data)
                }
                else if data.code == "5000" {
                    self?.delegate?.showError(error: .notResponse)
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                self?.delegate?.showError(error: .otherError)
                break
            }
        }
    }
    
    func searchCoSoYTe(keyword: String, pageIndex: Int = 1, pageSize: Int = 10) {
//        let encodeKeyword: String = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
       commonService.getListCSYT(keyword: keyword, pageIndex: pageIndex, pageSize: pageSize) {  [weak self] (result: Result<[CoSoYTeModel], ApiError>) in
            //                guard let _ = self else { return }
            switch result {
            case .success(let data):
                self?.delegate?.updateListTreatmentPlaces(list: data)
                break
            case .failure(let error):
                Logger.Logs(message: error.localizedDescription)
                break
            }
        }
    }
    func searchCoSoYTe1(keyword: String, pageIndex: Int = 1, pageSize: Int = 10) {
//        let encodeKeyword: String = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
       commonService.getListCSYTBaoMinh(keyword: keyword, pageIndex: pageIndex, pageSize: pageSize) {  [weak self] (result: Result<PagedListDataRespone, ApiError>) in
            //                guard let _ = self else { return }
            switch result {
            case .success(let data):
                self?.delegate?.updateListTreatmentPlacesBaoMinh(list: data)
                break
            case .failure(let error):
                Logger.Logs(message: error.localizedDescription)
                break
            }
        }
    }
}
