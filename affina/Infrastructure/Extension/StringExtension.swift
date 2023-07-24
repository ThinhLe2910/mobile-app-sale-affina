//
//  StringExtension.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 27/05/2022.
//

import Foundation
import UIKit

extension String {
    func replaceFoldingTextWithDD() -> String {
        var newText = self.folding(options: .diacriticInsensitive, locale: .current).lowercased()
        if self.contains("đ") {
            newText = newText.replace(string: "đ", replacement: "d")
        }
        return newText
    }
    
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    func localize() -> String {
        let isUserSelectedLang = UserDefaults.standard.bool(forKey: Key.isUserSelectedLang.rawValue)
        if !isUserSelectedLang {
            let langStr = NSLocale.current.languageCode
            if let langStr = langStr, langStr.uppercased() == EnumLanguage.en.rawValue.uppercased() {
                guard let path = Bundle.main.path(forResource: EnumLanguage.en.rawValue, ofType: "lproj"),
                      let bundle = Bundle(path: path) else {
                    return self
                }
                return bundle.localizedString(forKey: self, value: nil, table: nil)
            } else {
                guard let path = Bundle.main.path(forResource: EnumLanguage.vi.rawValue, ofType: "lproj"),
                      let bundle = Bundle(path: path) else {
                    return self
                }
                //                UserDefaults.standard.set(EnumLanguage.vi.rawValue.uppercased(), forKey: Key.languageApp.rawValue)
                return bundle.localizedString(forKey: self, value: nil, table: nil)
            }
        }
        
        let language = UserDefaults.standard.string(forKey: Key.languageApp.rawValue)
        switch language {
        case EnumLanguage.en.rawValue.uppercased():
            guard let path = Bundle.main.path(forResource: EnumLanguage.en.rawValue, ofType: "lproj"),
                  let bundle = Bundle(path: path) else {
                return self
            }
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        case EnumLanguage.vi.rawValue.uppercased():
            guard let path = Bundle.main.path(forResource: EnumLanguage.vi.rawValue, ofType: "lproj"),
                  let bundle = Bundle(path: path) else {
                return self
            }
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        default:
            guard let path = Bundle.main.path(forResource: EnumLanguage.vi.rawValue, ofType: "lproj"),
                  let bundle = Bundle(path: path) else {
                return self
            }
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
    }
    
    //replace #string by #replacement
    func replace(string: String, replacement: String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: .literal, range: nil)
    }
    
    //remove Dot
    func removeDot() -> String! {
        return self.replace(string: ".", replacement: "")
    }
    
    //remove space
    func removeSpace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    //remove comma
    func removeComma() -> String! {
        return replace(string: ",", replacement: "")
    }
    
    func convertToEngLowercase() -> String {
        var str = self.lowercased()
        let aVariant = ["à", "á", "ạ", "ả", "ã", "â", "ầ", "ấ", "ậ", "ẩ", "ẫ", "ă", "ằ", "ắ", "ặ", "ẳ", "ẵ"]
        for item in aVariant {
            str = str.replace(string: item, replacement: "a")
        }
        let eVariant = ["e", "é", "è", "ẻ", "ẽ", "ẹ", "ế", "ề", "ể", "ễ", "ệ", "ê"]
        for item in eVariant {
            str = str.replace(string: item, replacement: "e")
        }
        let iVariant = ["í", "ì", "ỉ", "ĩ", "ị"]
        for item in iVariant {
            str = str.replace(string: item, replacement: "i")
        }
        let oVariant = ["ó", "ò", "ỏ", "õ", "ọ", "ô", "ố", "ồ", "ổ", "ỗ", "ộ", "ơ", "ớ", "ờ", "ở", "ỡ", "ợ"]
        for item in oVariant {
            str = str.replace(string: item, replacement: "o")
        }
        let uVariant = ["u", "ú", "ù", "ủ", "ụ", "ũ", "ư", "ứ", "ừ", "ử", "ữ", "ự"]
        for item in uVariant {
            str = str.replace(string: item, replacement: "u")
        }
        let yVariant = ["ý", "ỳ", "ỷ", "ỹ", "ỵ"]
        for item in yVariant {
            str = str.replace(string: item, replacement: "y")
        }
        let dVariant = ["đ"]
        for item in dVariant {
            str = str.replace(string: item, replacement: "d")
        }
        
        return str
    }
    
    func checkIfVietnameseSymbol() -> Bool {
        let str = self.lowercased()
        let aVariant = ["à", "á", "ạ", "ả", "ã", "â", "ầ", "ấ", "ậ", "ẩ", "ẫ", "ă", "ằ", "ắ", "ặ", "ẳ", "ẵ"]
        for item in aVariant {
            if str.contains(item) { return true }
        }
        let eVariant = ["é", "è", "ẻ", "ẽ", "ẹ", "ế", "ề", "ể", "ễ", "ệ", "ê"]
        for item in eVariant {
            if str.contains(item) { return true }
        }
        let iVariant = ["í", "ì", "ỉ", "ĩ", "ị"]
        for item in iVariant {
            if str.contains(item) { return true }
        }
        let oVariant = ["ó", "ò", "ỏ", "õ", "ọ", "ô", "ố", "ồ", "ổ", "ỗ", "ộ", "ơ", "ớ", "ờ", "ở", "ỡ", "ợ"]
        for item in oVariant {
            if str.contains(item) { return true }
        }
        let uVariant = ["ú", "ù", "ủ", "ụ", "ũ", "ư", "ứ", "ừ", "ử", "ữ", "ự"]
        for item in uVariant {
            if str.contains(item) { return true }
        }
        let yVariant = ["ý", "ỳ", "ỷ", "ỹ", "ỵ"]
        for item in yVariant {
            if str.contains(item) { return true }
        }
        let dVariant = ["đ"]
        for item in dVariant {
            if str.contains(item) { return true }
        }
        
        return false
    }
    
    public func timestampToFormatedDate(format: String) -> String {
        let timestamp: Double = (self as NSString).doubleValue
        let eventDate = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: eventDate)
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    func heightNeededForLabel(_ label: UILabel) -> CGFloat {
        let width = label.frame.size.width
        guard let font = label.font else { return 0 }
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start..<end]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex...end]
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex..<end]
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension NSAttributedString {
    func attributedStringWithResizedImages(with maxWidth: CGFloat) -> NSAttributedString {
        let text = NSMutableAttributedString(attributedString: self)
        text.enumerateAttribute(NSAttributedString.Key.attachment, in: NSMakeRange(0, text.length), options: .init(rawValue: 0), using: { (value, range, stop) in
            if let attachement = value as? NSTextAttachment {
                let image = attachement.image(forBounds: attachement.bounds, textContainer: NSTextContainer(), characterIndex: range.location)!
                if image.size.width > maxWidth {
                    let newImage = image.resizeImage(scale: maxWidth/image.size.width)
                    let newAttribut = NSTextAttachment()
                    newAttribut.image = newImage
                    text.addAttribute(NSAttributedString.Key.attachment, value: newAttribut, range: range)
                }
            }
        })
        return text
    }
}
