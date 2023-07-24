//
//  InsuranceOtpModel.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 30/08/2022.
//

//class OtpRequest: BaseApiRequest {
//}
//
//struct OtpModel: Encodable {
//    let otpKey: String
//    let code: String
//}
//
//// MARK: Submit OTP
//struct OtpSubmitData: Codable {
//    let token: String?
//}
//
//// MARK: Receive OTP
//struct OtpResponseData: Codable {
//    let otpKey: String
//    let length: Int
//    let timeCodeExpire: Double
//    let timeKeyExpire: Double
//    let contact: String
//    let via: Int // 1 email, 2 sms
//}
//
//struct OtpResendResponseData: Codable {
//    let otpKey: String
//    let length: Int
//    let timeCodeExpire: Double
//    let timeKeyExpire: Double
//    let contact: String
//}
//
//// MARK: OTP Error
//enum OtpError: Int {
//    case empty, invalid, expired, unmatch, failed, wrongManyTime, error, requestLimited, blocked
//}
//
//// MARK: OTP CODE
//enum OtpCode: String {
//    case OK_200 = "200"
//    case OTP_4004 // Request otp limited
//    case AUTH_4001
//    case AUTH_4002 // Token expire by timeout when authenticate
//    case OTP_4000 // Not match
//    case OTP_4001 // Expired
//    case OTP_4002 // OTP transaction failed
//    case OTP_4003 // OTP wrong many time
//}
