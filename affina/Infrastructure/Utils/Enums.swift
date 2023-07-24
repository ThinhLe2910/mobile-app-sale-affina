//
//  Enums.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit

enum ResponseCode: String {
    case OK_200 = "200"
    case AUTH_4001
    case SERVER_500 = "500"
}

enum ErrorCustom: Error {
    case dataNil
}

enum ErrorCode: String {
    case EXPIRED = "4002"
}

enum ApiError: Error {
    case forbidden
    case notFound
    case conflict
    case internalServerError
    case invalidUrl
    case invalidData(Error, Data? = nil)
    case noInternetConnection
    case notResponse
    case requestTimeout(Error)
    case otherError
    case expired
    case refresh
    case unauthorized
    case unknown
    case unexpectedStatusCode
    case custom(Error)
}

enum EnumOnOffStatus: Int {
    case on = 1
    case off = 0
}

enum EnumAlertType {
    case info, warning, error
}

enum EnumGender: Int {
    case female = 0
    case male = 1
    case unknown = -1
    case both = 2
    var title: String {
        switch self {
        case .female:
            return "Nữ".localize()
        case .male:
            return "Nam".localize()
            case .both:
                return "ALL".localize()
            case .unknown:
                return "Chưa rõ".localize()
        }
    }
}

// MARK: Colors
enum AssetsColor: String {
    case whiteMain = "whiteMain"
    case blackMain = "blackMain"
    case backgroundGray = "backgroundGray"
    case backgroundGray2 = "backgroundGray2"
    case textBlack = "textBlack"
    case textGray = "textGray"
    case textGraySecond = "textGraySecond"
    case textDescGray = "textDescGray"
    case textBlue = "textBlue"
    case greenMain = "greenMain"
    case greenSecond
    case graySeparator
    case grayLight
    case red
    case lineSpace
    case cellGray
    case azul

    case redError
    case redErrorBg
    case whiteTextMain

    case pinkMain
    case pink
    case pinkLighter
    case pinkLighter2
    case pinkUltraLighter
    case pinkLong
    
    case orangeMain
    case orange
    
    case blueMain
    case blue
    case blueSlider
    case blue2
    case blueBold
    case blueDark
    case blueLighter
    case blueUltraLighter
    case blueExtremeLight
    case blueLight
    
    case subText
    case grayBorder
    case mediumViolet
    case secondaryViolet
    
    //page control
    case pageTint
    case pageBorder
    case buttonDisable
    case darkGray
    case greenLight
    case greenCheckpoint
    case yellow
    case greenBorder
    case defaultBorder
    case activeBorder
    
    case gray
    case mediumGray
    
    case headerColor
    case backgroundLightGray
    case shadow
    case black
    case black333
    
    func toUIColor() -> UIColor {
        return UIColor(hex: assetsColorDict[self.rawValue] ?? "000000")
    }

    var value: String {
        get {
            return assetsColorDict[self.rawValue] ?? "000000"
        }
    }
}

let assetsColorDict: [String: String] = [
    "whiteMain": "FFFFFF",
    "blackMain": "222222",
    "backgroundGray": "F5F5F5",
    "backgroundGray2": "C4C4C4",
    "textBlack": "1E1E1C",
    "textGray": "6B778C",
    "textGraySecond": "A0A6B0",
    "textDescGray": "303C52",
    "textBlue": "0544BB",
    "greenMain": "0751DA",
    
    "orangeMain": "FF7F00",
    "orange": "FFDD65",
    "greenSecond": "D1FFDA",
    "graySeparator": "F4F4F4",
    "grayLight": "CFCFCF",
    
    "red": "F20000",
    "lineSpace": "E6E6E6",
    "cellGray": "F0F0F0",
    "azul": "386fd6",
    "redError": "D92A2A",
    "redErrorBg": "FFEEFC",
    "whiteTextMain": "F8F9FF",
    
    "pinkMain": "FF76E2",
    "pink": "FFEEFB",
    "pinkLighter": "FF75E2",
    "pinkLighter2": "FFBAF1",
    "pinkUltraLighter": "FFDCF8",
    "pinkLong": "FF52DB",
    "blueMain": "3A7EFC",
    "blue": "095EFB",
    "blue2": "e8f6ff",
    "blueBold": "444DA8",
    "blueSlider": "CEDFFE",
    "blueDark": "074BC9",
    "blueLighter": "9DBFFE",
    "blueUltraLighter": "E6EFFF",
    "blueExtremeLight": "F1F6FF",
    "blueLight": "6B9EFD",
    
    "black333": "333333",
    "gray": "D9D9D9",
    "grayBorder": "E9E9E9",
    "mediumGray": "AEAEAE",
    "mediumViolet": "ADB2D5",
    "secondaryViolet": "444DA0",
    
    "pageTint": "CBCBCB",
    "pageBorder": "ADADAD",
    "buttonDisable": "D8D8D8",
    "darkGray": "EBEBEB",
    "greenLight": "009BEE",
    "greenCheckpoint": "CEF4FF",
    "yellow": "FFB300",
    "greenBorder": "00B1FF",
    "defaultBorder": "CEDFFD",
    "activeBorder": "3C7DF8",
    "headerColor": "3D78EA",
    "backgroundLightGray": "F5F5F5",
    "shadow": "010953",
    "black": "000000",
    "subText": "606060",
]

// MARK: Font Style
enum FontStyle: String {
    case Black
    case BlackItalic
    case Bold
    case BoldItalic
    case ExtraBold
    case Heavy
    case HeavyItalic
    case Light
    case LightItalic
    case Medium
    case MediumItalic
    case Regular
    case RegularItalic
    case SemiBold
    case Semibold
    case SemiboldItalic
    case Thin
    case ThinItalic
    case Ultralight
    case UltralightItalic
}

// MARK: Key
enum Key: String {
    case languageApp = "languageApp"
    case biometricAuth = "biometricAuth"
    case hasRequestedBiometricAuth = "hasRequestedBiometricAuth"
    case firstInstalled = "firstInstalled"
    case notFirstTimeLogin = "notFirstTimeLogin"
    case companyId = "AF_companyId_AF"
    case customerName = "AF_cusName_AF"
    case phoneNumber = "AF_phoneNumber_AF"
    case password = "AF_password_AF"
    case token = "AF_token_AF"
    case pushKey = "AF_pushKey_AF"
    case expireAt = "AF_expireAt_AF"
    case refreshAt = "AF_refreshAt_AF"
    case profile = "AF_profile_AF"
    case claimBenefitNote = "claimBenefitNote"
    
    case treatmentPlaces = "AF_treatmentPlaces_AF"
    
    case hasShownFirstCard = "AF_hasShownFirstCard_AF"
    case lastOtpTime = "AF_lastOtpTime_AF"
    
    case changeLocalize = "changeLocalize"
    case provinces = "AF_provinces_AF"
    case insuranceCards = "AF_insuranceCards_AF"
    
    case crashedNotificationKey = "IntelinCrashChecker"
    
    case isUserSelectedLang = "isUserSelectedLang"
    case readPopup = "readPopup"
    case shownCongratsHome = "showCongratsHome"
    case shownInstructDownload = "showInstructDownload"
}

enum EnumLanguage: String {
    case en = "en"
    case vi = "vi"
}

// MARK: Network Env
enum NetworkEnvironment {
    case dev
    case staging
    case uat
    case live
}

// HTTP_KEY
enum HTTP_KEY: String {
    case DATA = "data"
    case Code = "code"
    case link = "link"
}

enum CaretPosition {
    case center, left, right
}

enum IdentityType: Int {
    case cccd = 1, cmnd = 0, passport = 2
}
