//
//  VoucherService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/03/2023.
//

import Foundation

enum VoucherTypeEnum: Int {
    case HOME = 1
    case USE_POINT_VOUCHER_FOR_U = 2
    case USE_POINT_SPECIAL_VOUCHER = 4
    case USE_POINT_POPULAR_PRODUCT = 8
}

class VoucherService {
    
    func getVoucherAt(from: Int, limit: Int, showAt: Int, completion: @escaping ((Result<APIResponse<ListVoucherModel>, ApiError>) -> Void)) {
        let params: [String: String] = [
            "from": "\(from)",
            "limit": "\(limit)",
            "showAt": "\(showAt)",
            "order": "createdAt",
            "by": "desc"
        ]
        let body: Data? = try? JSONEncoder().encode(params)
        let request = BaseApiRequest(path: API.Voucher.GET_VOUCHER_AT, method: .delete, parameters: [:], isJsonRequest: false, headers: [:], httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ListVoucherModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getListVoucherCategory(completion: @escaping ((Result<APIResponse<[VoucherCategoryModel]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Voucher.GET_LIST_CATEGORY, method: .get, parameters: [:], isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[VoucherCategoryModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getListVoucherByCategory(categoryId: String, from: Int, limit: Int, completion: @escaping ((Result<APIResponse<[VoucherModel]>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "from": "\(from)",
            "limit": "\(limit)",
//            "categoryId": categoryId
        ]
        if categoryId != "" {
            params["categoryId"] = categoryId
        }
        let request = BaseApiRequest(path: API.Voucher.GET_LIST_VOUCHER_BY_CATEGORY, method: .get, parameters: params, isJsonRequest: false, headers: [:], httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[VoucherModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getVoucherDetail(voucherId: String, providerId: String, completion: @escaping ((Result<APIResponse<VoucherDetailModel>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "voucherId": voucherId
        ]
        if !providerId.isEmpty {
            params["providerId"] = providerId
        }
        
        let request = BaseApiRequest(path: API.Voucher.GET_VOUCHER_DETAIL, method: .get, parameters: params, isJsonRequest: false, headers: [:], httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<VoucherDetailModel>, ApiError>) in
            completion(result)
        }
    }
    
    func buyVoucher(voucherId: String, quantity: Int, providerId: String, completion: @escaping ((Result<APIResponse<BuyVoucherResponse>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "voucherId": voucherId,
            "quantity": "\(quantity)",
        ]
        if !providerId.isEmpty {
            params["providerId"] = providerId
        }
        
        let body: Data? = try? JSONEncoder().encode(params)
        let request = BaseApiRequest(path: API.Voucher.BUY_VOUCHER, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<BuyVoucherResponse>, ApiError>) in
            completion(result)
        }
    }
    
    // Not use/ active
    func getMyListVoucher(filter: String = "usingVoucher.isUse", filterValue: Int = -1, fromDate: Int64 = Int64(Date().timeIntervalSince1970), order: String = "expiredAt", fieldDate: String = "usingVoucher.expiredAt", by: String = "asc", completion: @escaping ((Result<APIResponse<ListMyVoucherModel>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "by": by,
        ]
        if !filter.isEmpty {
            params["filter"] = "\(filter)"
        }
        if !fieldDate.isEmpty {
            params["fieldDate"] = "\(fieldDate)"
        }
        if !order.isEmpty {
            params["order"] = "\(order)"
        }
        if filterValue != -1 {
            params["filterValue"] = "\(filterValue)"
        }
        if fromDate != -1 {
            params["fromDate"] = "\(fromDate * 1000)"
        }
        
        let request = BaseApiRequest(path: API.Voucher.GET_MY_LIST_VOUCHER, method: .get, parameters: params, isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ListMyVoucherModel>, ApiError>) in
            completion(result)
        }
    }
    
    // Out of date/ used
    func getMyListUsedVoucher(filter: String = "usingVoucher.isUse", filterValue: Int = 0, fromDate: Double, order: String = "expiredAt", fieldDate: String = "usingVoucher.expiredAt", by: String = "asc", completion: @escaping ((Result<APIResponse<[MyVoucherModel]>, ApiError>) -> Void)) {
        var params: [String: String] = [:]
        if !filter.isEmpty {
            params["filter"] = "\(filter)"
        }
        if !fieldDate.isEmpty {
            params["fieldDate"] = "\(fieldDate)"
        }
        if !by.isEmpty {
            params["by"] = "\(by)"
        }
        if !order.isEmpty {
            params["order"] = "\(order)"
        }
        if filterValue != -1 {
            params["filterValue"] = "\(filterValue)"
        }
        if fromDate != -1 {
            params["fromDate"] = "\(fromDate)"
        }
        let request = BaseApiRequest(path: API.Voucher.GET_MY_LIST_VOUCHER, method: .delete, parameters: params, isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[MyVoucherModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getVoucherSummary(completion: @escaping ((Result<APIResponse<VoucherSummaryModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Voucher.BUY_VOUCHER, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<VoucherSummaryModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getMyVoucherDetail(voucherId: String, code: String, providerId: String, completion: @escaping ((Result<APIResponse<MyVoucherModel>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "voucherId": voucherId,
            "code": code
        ]
        if !providerId.isEmpty {
            params["providerId"] = providerId
        }
        let request = BaseApiRequest(path: API.Voucher.GET_MY_VOUCHER_DETAIL, method: .get, parameters: params, isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<MyVoucherModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getVoucherHistory(fieldDate: String, fromDate: Double, toDate: Double, order: String, by: String, completion: @escaping ((Result<APIResponse<ListModel<VoucherHistoryModel>>, ApiError>) -> Void)) {
        var params: [String: Any] = [:]
        if !fieldDate.isEmpty {
            params["fieldDate"] = fieldDate
        }
        if fromDate != -1 {
            params["fromDate"] = fromDate
        }
        if toDate != -1 {
            params["toDate"] = toDate
        }
        if !order.isEmpty {
            params["order"] = order
        }
        if !by.isEmpty {
            params["by"] = by
        }
        let body: Data? = try? JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
        let request = BaseApiRequest(path: API.Voucher.BUY_VOUCHER, method: .delete, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ListModel<VoucherHistoryModel>>, ApiError>) in
            completion(result)
        }
    }
    
    func ratingVoucher(voucherId: String, providerId: String, code: String, point: Int, comment: String, images: String, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        
        let params: [String: Any] = [
            "voucherId": voucherId,
            "providerId": providerId.count > 0 ? providerId : nil,
            "point": point,
            "comment": comment,
            "image": images,
            "code": code
        ]
        let body: Data? = try? JSONSerialization.data(withJSONObject: params)
        let request = BaseApiRequest(path: API.Voucher.RATING_VOUCHER, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
    }
    
    func markUsedVoucher(voucherId: String, code: String, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        let params: [String: String] = [
            "voucherId": voucherId,
            "code": code
        ]
        let body: Data? = try? JSONEncoder().encode(params)
        let request = BaseApiRequest(path: API.Voucher.MARK_USED_VOUCHER, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<NilData>, ApiError>) in
            completion(result)
        }
        
    }
    
    func checkContractVoucher(contractId: String, voucherCode: String, completion: @escaping ((Result<APIResponse<ContractVoucherModel>, ApiError>) -> Void)) {
        let params: [String: Any] = [
            "contractId": contractId,
            "voucherCode": voucherCode
        ]
        let body: Data? = try? JSONSerialization.data(withJSONObject: params)
        let url = UIConstants.isLoggedIn ? API.Voucher.CHECK_CONTRACT_VOUCHER_USER : API.Voucher.CHECK_CONTRACT_VOUCHER
        let request = BaseApiRequest(path: url, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ContractVoucherModel>, ApiError>) in
            completion(result)
        }
    }
    
}
