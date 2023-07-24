//
//  InsuranceCustomerInfoViewPresenter.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/08/2022.
//

import UIKit

protocol InsuranceCustomerInfoViewDelegate {
    func lockUI()
    func unLockUI()
    
    func isValidInfo(code: String, isValid: Bool, message: String)
    func createSuccessful(contract: InsuranceContractModel)
    func goToOtp(otp: OtpResponseData)
    func uploadImageSuccess(link: String, isFront: Bool)
    func uploadBuyHelpImageSuccess(link: String, isFront: Bool)
    
    func showAlert()
    func showError(error: ApiError)
}

extension InsuranceCustomerInfoViewDelegate {
    func uploadBuyHelpImageSuccess(link: String, isFront: Bool) { }
}

class InsuranceCustomerInfoViewPresenter {
    var delegate: InsuranceCustomerInfoViewDelegate?
    
    private let imageService = ImageService()
    
    init() {}
    
    func setViewDelegate(delegate: InsuranceCustomerInfoViewDelegate) {
        self.delegate = delegate
    }
    
    func checkIsValidInfo(model: [String: Any]) {
        delegate?.lockUI()
        let data: Data? = try? JSONSerialization.data(withJSONObject: model, options: [])
        let request = BaseApiRequest(path: API.Sale.PUT_CHECK_PRODUCT, method: .put, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<NilData>, ApiError>) in
            self?.delegate?.unLockUI()
            switch result {
            case .success(let data):
                switch data.code {
                case "200":
                        self?.delegate?.isValidInfo(code: data.code, isValid: true, message: data.messages ?? "")
                    break
                case "PRODUCT_4000":
                    self?.delegate?.isValidInfo(code: data.code, isValid: false, message: data.messages ?? "")
                    break
                case "CONTRACT_4000":
                    self?.delegate?.isValidInfo(code: data.code, isValid: false, message: data.messages ?? "")
                    break
                case "AUTH_4001":
                        self?.delegate?.isValidInfo(code: data.code, isValid: false, message: data.messages ?? "")
                    break
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                    self?.delegate?.isValidInfo(code: "5000", isValid: false, message: "")
                break
            }
        }
    }
    
    func createContract(model: PaymentContractPeopleInfoRequestModel) {
        self.delegate?.lockUI()
        let data: Data? = try? JSONSerialization.data(withJSONObject: model.dictionary, options: [])
        let request = BaseApiRequest(path: API.Contract.CREATE_CONTRACT, method: .post, parameters: [:], isJsonRequest: true, headers: [:], httpBody: data)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<OtpResponseData>, ApiError>) in
            self?.delegate?.unLockUI()
            switch result {
            case .success(let data):
                switch data.code {
                case ResponseCode.OK_200.rawValue:
                    guard let model = data.data else {
                        return
                    }
                    Logger.Logs(message: model)
                    self?.delegate?.goToOtp(otp: model)
                    break
                case CheckPhoneCode.LOGIN_4002.rawValue, ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                case "COMMON_4001": // COMMON_DUPLICATE_ERROR
                    self?.delegate?.showError(error: .conflict)
                    break
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription)
                if error.localizedDescription.contains("The operation couldn’t be completed. (affina.ApiError error 1.)") {
                    self?.delegate?.showError(error: .noInternetConnection)
                }
                else {
                    switch error {
                    case ApiError.invalidData(let error, let data):
                        Logger.Logs(message: error)
                        guard let data = data else { return }
                        do {
                            let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                            if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                self?.delegate?.showError(error: ApiError.expired)
                            }
                            else if nilData.code == "COMMON_4001" { // COMMON_DUPLICATE_ERROR
                                self?.delegate?.showError(error: .conflict)
                            }
                        }
                        catch let err{
                            Logger.Logs(event: .error, message: err)
                            self?.delegate?.showError(error: .otherError)
                        }
                    default:
                        Logger.Logs(event: .error, message: error)
                        self?.delegate?.showError(error: error)
                        break
                    }
                }
            }
        }
    }
    
    func createContractWithToken(model: PaymentContractPeopleInfoRequestModel) {
        self.delegate?.lockUI()
        
        let data: Data? = try? JSONSerialization.data(withJSONObject: model.dictionary, options: [])
        let request = BaseApiRequest(path: API.Contract.CREATE_CONTRACT_WITH_TOKEN, method: .post, parameters: [:], isJsonRequest: true, headers: APIManager.shared.getTokenHeader(), httpBody: data)
        APIManager.shared.send2(request: request) { [weak self] (result: Result<APIResponse<InsuranceContractModel>, ApiError>) in
            self?.delegate?.unLockUI()
            switch result {
            case .success(let data):
                switch data.code {
                case ResponseCode.OK_200.rawValue:
                    guard let model = data.data else {
                        return
                    }
                    Logger.Logs(message: model)
                    self?.delegate?.createSuccessful(contract: model)
                    break
                case CheckPhoneCode.LOGIN_4002.rawValue, ErrorCode.EXPIRED.rawValue:
                    self?.delegate?.showError(error: ApiError.expired)
                case "COMMON_4001": // COMMON_DUPLICATE_ERROR
                    self?.delegate?.showError(error: .conflict)
                case "CONTRACT_4000":
                    self?.delegate?.showError(error: .conflict)
                default:
                    break
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error.localizedDescription)
                if error.localizedDescription.contains("The operation couldn’t be completed. (affina.ApiError error 1.)") {
                    self?.delegate?.showError(error: .noInternetConnection)
                }
                else {
                    switch error {
                    case ApiError.invalidData(let error, let data):
                        Logger.Logs(message: error)
                        guard let data = data else { return }
                        do {
                            let nilData = try JSONDecoder().decode(APIResponse<NilData>.self, from: data)
                            if nilData.code == CheckPhoneCode.LOGIN_4002.rawValue || nilData.code == ErrorCode.EXPIRED.rawValue {
                                self?.delegate?.showError(error: ApiError.expired)
                            }
                            else if nilData.code == "CONTRACT_4000" {
                                self?.delegate?.showError(error: .otherError)
                            }
                            else if nilData.code == "COMMON_4001" { // COMMON_DUPLICATE_ERROR
                                self?.delegate?.showError(error: .conflict)
                            }
                        }
                        catch let err{
                            Logger.Logs(event: .error, message: err)
                        }
                        
                    default:
                        Logger.Logs(event: .error, message: error)
                        break
                    }
                }
            }
        }
    }
    
    func uploadImage(image: UIImage, isFront: Bool, isBuyHelp: Bool) {
        self.delegate?.lockUI()
        let request = BaseApiRequest(path: API.Other.PUBLIC_UPLOAD, method: .post, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil) // headers: ["Content-type": "multipart/form-data"]
        imageService.upload(image: image.jpegData(compressionQuality: 1.0)!, to: request.request(), params: [:]) { result in
            switch result {
            case .success(let data):
                if let link = data.data?.link {
                    if isBuyHelp {
                        self.delegate?.uploadBuyHelpImageSuccess(link: link, isFront: isFront)
                    }
                    else {
                        self.delegate?.uploadImageSuccess(link: link, isFront: isFront)
                    }
                }
                break
            case .failure(let error):
                Logger.Logs(event: .error, message: error)
                break
            }
        }
    }
}
