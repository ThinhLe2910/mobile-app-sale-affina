//
//  ProfileViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 23/05/2022.
//

import Foundation
import UIKit

protocol ProfileViewDelegate {
    func lockUI()
    func unLockUI()

    func updateUI(profile: ProfileModel)

    func updateRelatives(relatives: [RelativeModel])

    func showAlert()
    func showError(error: ApiError)

    func updateSuccess()
    func uploadImageSuccess(link: String)
    
}

class ProfileViewPresenter {

    private var delegate: ProfileViewDelegate?

    private let imageService = ImageService()
    private let profileService = ProfileService()
    
    func setViewDelegate(delegate: ProfileViewDelegate?) {
        self.delegate = delegate
    }
    
    func getProfile() {
        self.delegate?.lockUI()
        let homePresenter = HomeViewPresenter()
        homePresenter.getProfile { [weak self] result in
            self?.delegate?.unLockUI()
            switch result {
            case .success(let model):
                AppStateManager.shared.profile = model
                self?.delegate?.updateUI(profile: model)
            case .failure(let error):
                self?.delegate?.showError(error: error)
//                switch error {
//                case .expired:
//                    self?.delegate?.showError(error: .expired)
//                default:
//                    break
//                }
            }
        }
    }
    
    func updateProfile(dict: [String: Any]) {
        self.delegate?.lockUI()
        profileService.updateProfile(dict: dict) { [weak self] result in
            self?.delegate?.unLockUI()
            
            guard let self = self else { return }
            
            Logger.Logs(message: result)
            
            switch result {
            case .success(let data):
                switch data.code {
                case ProfileCode.OK_200.rawValue:
                    self.delegate?.updateSuccess()
                    break
                case ProfileCode.AUTH_4001.rawValue:
                    break
                case CheckPhoneCode.LOGIN_4002.rawValue:
                    self.delegate?.showError(error: ApiError.expired)
                    break
                case ErrorCode.EXPIRED.rawValue:
                    self.delegate?.showError(error: ApiError.expired)
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.Logs(message: error)
                switch error {
                case ApiError.invalidData(let error, let data):
                    Logger.Logs(message: error)
                    guard let data = data else { return }
                    do {
                        let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                        if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                            self.delegate?.showError(error: ApiError.expired)
                        }
                    }
                    catch let err{
                        Logger.DumpLogs(event: .error, message: err)
                    }
                    
                default:
                        self.delegate?.showError(error: error)
                    break
                }
                break
            }
        }
    }
    
    func uploadImage(image: UIImage) {
        self.delegate?.lockUI()
        let request = BaseApiRequest(path: API.Other.PUBLIC_UPLOAD, method: .post, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil) // headers: ["Content-type": "multipart/form-data"]
        imageService.upload(image: image.jpegData(compressionQuality: 1.0)!, to: request.request(), params: [:]) { result in
            self.delegate?.unLockUI()
            switch result {
            case .success(let data):
                if let link = data.data?.link {
                    self.delegate?.uploadImageSuccess(link: link)
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                break
            }
        }
    }
    
}
