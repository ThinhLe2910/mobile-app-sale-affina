//
//  UIDeviceExtension.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 19/05/2022.
//

import UIKit

public enum Model: String {
    case simulator = "simulator/sandbox",
        iPod1 = "iPod 1",
        iPod2 = "iPod 2",
        iPod3 = "iPod 3",
        iPod4 = "iPod 4",
        iPod5 = "iPod 5",
        iPad2 = "iPad 2",
        iPad3 = "iPad 3",
        iPad4 = "iPad 4",
        iPhone4 = "iPhone 4",
        iPhone4S = "iPhone 4S",
        iPhone5 = "iPhone 5",
        iPhone5S = "iPhone 5S",
        iPhone5C = "iPhone 5C",
        iPadMini1 = "iPad Mini 1",
        iPadMini2 = "iPad Mini 2",
        iPadMini3 = "iPad Mini 3",
        iPadAir1 = "iPad Air 1",
        iPadAir2 = "iPad Air 2",
        iPadPro9_7 = "iPad Pro 9.7\"",
        iPadPro9_7_cell = "iPad Pro 9.7\" cellular",
        iPadPro10_5 = "iPad Pro 10.5\"",
        iPadPro10_5_cell = "iPad Pro 10.5\" cellular",
        iPadPro12_9 = "iPad Pro 12.9\"",
        iPadPro12_9_cell = "iPad Pro 12.9\" cellular",
        iPhone6 = "iPhone 6",
        iPhone6plus = "iPhone 6 Plus",
        iPhone6S = "iPhone 6S",
        iPhone6Splus = "iPhone 6S Plus",
        iPhoneSE = "iPhone SE",
        iPhone7 = "iPhone 7",
        iPhone7plus = "iPhone 7 Plus",
        iPhone8 = "iPhone 8",
        iPhone8plus = "iPhone 8 Plus",
        iPhoneX = "iPhone X",
        iPhoneXS = "iPhone XS",
        iPhoneXSmax = "iPhone XS Max",
        iPhoneXR = "iPhone XR",
        iPhone11 = "iPhone 11",
        iPhone11Pro = "iPhone 11 Pro",
        iPhone11ProMax = "iPhone 11 Pro Max",
        iPhone12 = "iPhone 12",
        iPhone12Pro = "iPhone 12 Pro",
        iPhone12ProMax = "iPhone 12 Pro Max",
        unrecognized = "?unrecognized?"
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad6,11", "iPad6,12": return "iPad 5"
        case "iPad7,5", "iPad7,6": return "iPad 6"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad6,3", "iPad6,4": return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8": return "iPad Pro 12.9 Inch"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
        case "AppleTV5,3": return "Apple TV"
        case "AppleTV6,2": return "Apple TV 4K"
        case "AudioAccessory1,1": return "HomePod"
        default: return identifier
        }
    }
}

// MARK: Detect by screen size
struct Device {
    static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA = UIScreen.main.scale >= 2.0

    static let SCREEN_WIDTH = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH = Int(max(SCREEN_WIDTH, SCREEN_HEIGHT))
    static let SCREEN_MIN_LENGTH = Int(min(SCREEN_WIDTH, SCREEN_HEIGHT))

    static let IS_IPHONE_4 = IS_IPHONE && SCREEN_MAX_LENGTH <= 400 // 2, 3, 3GS, 4, 4S
    static let IS_IPHONE_5 = IS_IPHONE && SCREEN_MAX_LENGTH == 568 // 5, 5S, 5C, 5E
    static let IS_IPHONE_6 = IS_IPHONE && SCREEN_MAX_LENGTH == 667 // 6, 6S, 7, 8
    static let IS_IPHONE_6P = IS_IPHONE && SCREEN_MAX_LENGTH == 736 // 6+, 6S+, 7+, 8+
    static let IS_IPHONE_XS = IS_IPHONE && SCREEN_MAX_LENGTH == 812 // X, XS, 11 Pro
    static let IS_IPHONE_XS_MAX = IS_IPHONE && SCREEN_MAX_LENGTH == 896 // XR, XS Max, 11, 11 Pro Max
    static let IS_IPAD_PRO_11 = IS_IPAD && SCREEN_MAX_LENGTH == 1024 // iPad Pro 11"
    static let IS_IPAD_PRO_13 = IS_IPAD && SCREEN_MAX_LENGTH == 1366 // iPad Pro 12.9"
}
