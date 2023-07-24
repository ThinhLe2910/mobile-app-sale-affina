//
//  Constants.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit

typealias UIConstants = Constants
typealias UIPadding = Constants.Layout.Padding

let kAppDelegate = UIApplication.shared.delegate as! AppDelegate

class Constants {
    static var isUsingBiometry: Bool = false
    static var environment: Int = 0
    static var isLoggedIn: Bool = false
    static var isInitHomeView: Bool = false
    static var isRequestedProvinces: Bool = false
    
    static var isBanned: Bool = false
    static var isFromBackground: Bool = false
    static var requireLogin: Bool = false
    
    // MARK: URL Proof Image
    static let Proofs: [String: [String: String]] = [
        "INCOME_SUPPORT".localize(): [
            "ACCIDENT_REPORT".localize(): "https://static.affina.com.vn/affinastatic/CTBT/HoTroThuNhap/tuong_trinh_tai_nan.png",
            "TIMESHEET".localize(): "https://static.affina.com.vn/affinastatic/CTBT/HoTroThuNhap/chung_tu_luong.png",
            "SALARY_DOCUMENT".localize(): "https://static.affina.com.vn/affinastatic/CTBT/HoTroThuNhap/hop_dong_lao_dong.png",
//            "Hồ sơ khác": "Bạn có thể tải mẫu @TAI_DAY",
        ],
        
        "OUTPATIENT".localize(): [
            "RECEIPT".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NgoaiTru/Bien_lai_thu_tien_kham.png",
            "INDICATION_AND_TRACKING_PAPER".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NgoaiTru/Chi_dinh_va_phieu_theo_doi_tap_vat_ly_tri_lieu.png"
        ],
        
        "HOSPITALIZATION_ALLOWANCE".localize(): [
            "DISCHARGE_PAPER".localize(): "https://static.affina.com.vn/affinastatic/CTBT/TroCapNamVien/giay_ra_vien.jpg",
            "SURGERY_CERTIFICATION".localize(): "https://static.affina.com.vn/affinastatic/CTBT/TroCapNamVien/giay_chung_nhan_phau_thuat.png",
        ],
        
        "DENTAL".localize(): [
            "XRAY_FILM".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NhaKhoa/phim_x_quang_rang.png",
            "Quá trình điều trị".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NhaKhoa/phieu_theo_doi_dieu_tri.png"
        ],
        
        "INPATIENT".localize(): [
            "DISCHARGE_PAPER".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NoiTru/Giay_ra_vien.jpg",
            "SURGERY_CERTIFICATION".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NoiTru/giay_chung_nhan_phau_thuat.png",
            "PRE-HOSPITALIZATION_DOCUMENTS".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NoiTru/chung_tu_y_te_truoc_nhap_vien.png",
            "INDICATION_FOR_FOLLOWUP_EXAMINATION".localize(): "https://static.affina.com.vn/affinastatic/CTBT/NoiTru/giay_tai_kham.png",
        ],
        
        "TRAFFIC_ACCIDENT".localize(): [
            "ACCIDENT_REPORT".localize(): "https://static.affina.com.vn/affinastatic/CTBT/TaiNanGiaoThong/tuong_trinh_tai_nan.png",
            "DISCHARGE_PAPER".localize(): "EXAMPLE_OF_DISCHARGE_PAPER".localize(),
//            https://static.affina.com.vn/affinastatic/CTBT/TaiNanGiaoThong/mau_giay_chung_nhan_phau_thuat.jpg
        ],
        
        "MARTENITY".localize(): [
            "SURGERY_CERTIFICATION".localize(): "https://static.affina.com.vn/affinastatic/CTBT/ThaiSan/mau_giay_chung_nhan_phau_thuat.jpg",
            "DISCHARGE_PAPER".localize(): "https://static.affina.com.vn/affinastatic/CTBT/ThaiSan/giay_ra_vien.jpg"
        ],
        
        "ACCIDENT".localize(): [
            "ACCIDENT_REPORT".localize(): "https://static.affina.com.vn/affinastatic/CTBT/TaiNan/tuong_trinh_tai_nan.png",
            "SURGERY_CERTIFICATION".localize(): "https://static.affina.com.vn/affinastatic/CTBT/TaiNan/mau_giay_chung_nhan_phau_thuat.jpg",
            "DISCHARGE_PAPER".localize(): "https://static.affina.com.vn/affinastatic/CTBT/TaiNan/giay_ra_vien.jpg"
        ],
    ]
    // MARK: CONFIG PAYOO
    // DEV
    static let devMerchantID: String = "11674"
    static let devSecretKey: String = "NzFmZWFkOGY2ZTY4NGVjYWFiNzcyZTY5NGE1Y2M4MzM="
    // LIVE
    static let liveMerchantID: String = "5199"
    static let liveSecretKey: String = "5ZdF+VdAEyCABycegGLaQdWW7mltysJlLwqbO3mQ0GT65bGMGIesHZ54/yJsUSgoky1BCxLRKUNA2HnheLWbog=="
    
    static let merchantID: String = API.networkEnvironment == .live ? liveMerchantID : devMerchantID
    static let secretKey: String = API.networkEnvironment == .live ? liveSecretKey : devSecretKey

    static let deeplink: String = API.networkEnvironment == .live ? "affina://affina.vn/id=12fqasd21ffas" : "affina://affina.vn/id=9"
    
    // MARK: Fonts
    struct Fonts {
        static func appFont(_ style: FontStyle, _ size: CGFloat, fontName: String = "Raleway") -> UIFont {
            if let font = UIFont(name: "\(fontName)-\(style.rawValue)", size: size) {
                return font
            }
            switch style {
            case .Bold, .ExtraBold:
                return UIFont.systemFont(ofSize: size, weight: .bold)
            case .Light:
                return UIFont.systemFont(ofSize: size, weight: .light)
            case .Medium:
                return UIFont.systemFont(ofSize: size, weight: .medium)
            case .Semibold, .SemiBold:
                return UIFont.systemFont(ofSize: size, weight: .semibold)
            case .Thin:
                return UIFont.systemFont(ofSize: size, weight: .thin)
            case .RegularItalic:
                return UIFont.italicSystemFont(ofSize: size)
            default:
                return UIFont.systemFont(ofSize: size, weight: .regular)
            }
        }
    }

    // MARK: Layout
    struct Layout {
        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height

        static var safeAreaWidth: CGFloat = 0.0
        static var safeAreaHeight: CGFloat = 0.0

        static let screenDesignHeight: CGFloat = 844 //+ 83 //729 + 83
        static let screenDesignWidth: CGFloat = 390 //375

        static var heightKeyboard: CGFloat = 0.0
        static let headerHeight: CGFloat = Constants.heightConstraint(100)

        // MARK: Padding
        struct Padding {
            static var top: CGFloat = 0.0
            static var left: CGFloat = 0.0
            static var right: CGFloat = 0.0
            static var bottom: CGFloat = 0.0

            static var size8: CGFloat = 8
            static var size16: CGFloat = 16
            static var size24: CGFloat = 24
            static var size32: CGFloat = 32
            static var size48: CGFloat = 48
            static var size56: CGFloat = 56
            static var size64: CGFloat = 64
            static var size72: CGFloat = 72
            static var size80: CGFloat = 80
        }

        static func setDefaultLayout(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
            self.Padding.top = top
            self.Padding.left = left
            self.Padding.bottom = bottom
            self.Padding.right = right

            self.safeAreaWidth = self.screenWidth - left - right
            self.safeAreaHeight = self.screenHeight - top - bottom
        }
    }

    static func heightConstraint(_ height: CGFloat) -> CGFloat {
        let constant = Constants.Layout.screenDesignHeight / height
        return Constants.Layout.screenHeight / constant
    }

    static func widthConstraint(_ width: CGFloat) -> CGFloat {
        let constant = Constants.Layout.screenDesignWidth / width
        return Constants.Layout.safeAreaWidth / constant
    }

    static var isVietnamese: Bool {
        get {
            let isUserSelectedLang = UserDefaults.standard.bool(forKey: Key.isUserSelectedLang.rawValue)
            if !isUserSelectedLang {
                let langStr = NSLocale.current.languageCode
                if let langStr = langStr, langStr.uppercased() == EnumLanguage.en.rawValue.uppercased() {
                    return false
                }
                else {
                    return true
                }
            }
            return UserDefaults.standard.string(forKey: Key.languageApp.rawValue) != EnumLanguage.en.rawValue.uppercased()
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue ? EnumLanguage.vi.rawValue.uppercased() : EnumLanguage.en.rawValue.uppercased(), forKey: Key.languageApp.rawValue)
            UserDefaults.standard.set(true, forKey: Key.isUserSelectedLang.rawValue)
        }
    }
}
