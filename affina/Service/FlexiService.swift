//
//  FlexiService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/03/2023.
//

import Foundation

class FlexiService {
    
    private let voucherService = VoucherService()
    
    func getSummaryFlexiPoint(completion: @escaping ((Result<APIResponse<FlexiSummaryModel>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Flexi.GET_SUMMARY_FLEXI_POINT, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<FlexiSummaryModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getListFlexi(completion: @escaping ((Result<APIResponse<[FlexiBenefitModel]>, ApiError>) -> Void)) {
        let request = BaseApiRequest(path: API.Flexi.GET_LIST_FLEXI, method: .get, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[FlexiBenefitModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func exchangeDayOff(benefitId: String, exchangeDays: Int, completion: @escaping ((Result<APIResponse<FlexiExchangeDaysModel>, ApiError>) -> Void)) {
        let params: [String: Any] = [
            "exchangeDays": exchangeDays,
            "benefitId": benefitId
        ]
        
        let body: Data? = try? JSONSerialization.data(withJSONObject: params)
        
        let request = BaseApiRequest(path: API.Flexi.EXCHANGE_DAY_OFF_BENEFIT, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<FlexiExchangeDaysModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getListCardSME(contractId: String = "", createdAt: Double = -1, limit: Int, completion: @escaping ((Result<APIResponse<[CardModel]>, ApiError>) -> Void)) {
        var params: [String: Any] = [
            "limit": limit
        ]
        
        if !contractId.isEmpty {
            params["contractId"] = contractId
        }
        
        if createdAt != -1 {
            params["createdAt"] = createdAt
        }
        
        let body: Data? = try? JSONSerialization.data(withJSONObject: params)
        
        let request = BaseApiRequest(path: API.Flexi.GET_LIST_CARD_SME, method: .put, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[CardModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getVoucherAt(from: Int, limit: Int, showAt: Int, completion: @escaping ((Result<APIResponse<ListVoucherModel>, ApiError>) -> Void)) {
        voucherService.getVoucherAt(from: from, limit: limit, showAt: showAt, completion: completion)
    }
    
    func getListVoucherCategory(completion: @escaping ((Result<APIResponse<[VoucherCategoryModel]>, ApiError>) -> Void)) {
        voucherService.getListVoucherCategory(completion: completion)
    }
    
    func getListVoucherByCategory(categoryId: String, from: Int, limit: Int, completion: @escaping ((Result<APIResponse<[VoucherModel]>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "from": "\(from)",
            "limit": "\(limit)",
            // "categoryId": categoryId
        ]
        if categoryId != "" {
            params["categoryId"] = categoryId
        }
        let request = BaseApiRequest(path: API.Voucher.GET_LIST_SME_VOUCHER_BY_CATEGORY, method: .get, parameters: params, isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<[VoucherModel]>, ApiError>) in
            completion(result)
        }
    }
    
    func getVoucherDetail(voucherId: String, providerId: String, completion: @escaping ((Result<APIResponse<VoucherDetailModel>, ApiError>) -> Void)) {
        voucherService.getVoucherDetail(voucherId: voucherId, providerId: providerId, completion: completion)
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
        let request = BaseApiRequest(path: API.Voucher.BUY_SME_VOUCHER, method: .post, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<BuyVoucherResponse>, ApiError>) in
            completion(result)
        }
    }
    
    // Not use/ active
    func getMyListVoucher(filter: String = "usingVoucher.isUse", filterValue: Int = -1, fromDate: Int64 
= Int64(Date().timeIntervalSince1970), order: String = "expiredAt", fieldDate: String = "usingVoucher.expiredAt", by: String = "asc", completion: @escaping ((Result<APIResponse<ListMyVoucherModel>, ApiError>) -> Void)) {
        voucherService.getMyListVoucher(filter: filter, filterValue: filterValue, fromDate: fromDate, order: order, fieldDate: fieldDate, by: by, completion: completion)
    }
    
    // Out of date/ used
    func getMyListUsedVoucher(filter: String = "usingVoucher.isUse", filterValue: Int = 0, fromDate: Double, order: String = "expiredAt", fieldDate: String = "usingVoucher.expiredAt", by: String = "asc", completion: @escaping ((Result<APIResponse<[MyVoucherModel]>, ApiError>) -> Void)) {
        voucherService.getMyListUsedVoucher(filter: filter, filterValue: filterValue, fromDate: fromDate, order: order, fieldDate: fieldDate, by: by, completion: completion)
    }
    
    func getMyVoucherDetail(voucherId: String, code: String, providerId: String, completion: @escaping ((Result<APIResponse<MyVoucherModel>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "voucherId": voucherId,
            "code": code
        ]
        if !providerId.isEmpty {
            params["providerId"] = providerId
        }
        let request = BaseApiRequest(path: API.Voucher.GET_MY_SME_VOUCHER_DETAIL, method: .get, parameters: params, isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<MyVoucherModel>, ApiError>) in
            completion(result)
        }
    }
    
    func getSMEMyVoucherDetail(voucherId: String, code: String, providerId: String, completion: @escaping ((Result<APIResponse<VoucherDetailModel>, ApiError>) -> Void)) {
        var params: [String: String] = [
            "voucherId": voucherId,
            "code": code
        ]
        if !providerId.isEmpty {
            params["providerId"] = providerId
        }
        let request = BaseApiRequest(path: API.Voucher.GET_MY_SME_VOUCHER_DETAIL, method: .get, parameters: params, isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: nil)
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<VoucherDetailModel>, ApiError>) in
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
        let request = BaseApiRequest(path: API.Voucher.BUY_SME_VOUCHER, method: .delete, parameters: [:], isJsonRequest: false, headers: APIManager.shared.getTokenHeader(), httpBody: body)
        
        APIManager.shared.send2(request: request) { (result: Result<APIResponse<ListModel<VoucherHistoryModel>>, ApiError>) in
            completion(result)
        }
    }
    
    func ratingVoucher(voucherId: String, providerId: String, code: String, point: Int, comment: String, images: String, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        voucherService.ratingVoucher(voucherId: voucherId, providerId: providerId, code: code, point: point, comment: comment, images: images, completion: completion)
    }
    
    func markUsedVoucher(voucherId: String, code: String, completion: @escaping ((Result<APIResponse<NilData>, ApiError>) -> Void)) {
        voucherService.markUsedVoucher(voucherId: voucherId, code: code, completion: completion)
    }
    
    func checkContractVoucher(contractId: String, voucherCode: String, completion: @escaping ((Result<APIResponse<ContractVoucherModel>, ApiError>) -> Void)) {
        voucherService.checkContractVoucher(contractId: contractId, voucherCode: voucherCode, completion: completion)
    }
    
}
