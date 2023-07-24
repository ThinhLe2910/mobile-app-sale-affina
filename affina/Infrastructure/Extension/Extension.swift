//
//  Extension.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit
import LocalAuthentication

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            return tabController
            //            if let selected = tabController.selectedViewController {
            //                return topViewController(controller: selected)
            //            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIAlertController {
    func pruneNegativeWidthConstrants() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}

extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor? {
        if #available(iOS 11.0, *) {
            return UIColor(named: String(describing: name))
        } else {
            return UIColor(hex: name.value)
        }
    }

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        func convertIntToFloatColor(intColor: CGFloat) -> CGFloat {
            let divisor: CGFloat = 255
            return intColor / divisor
        }
        self.init(red: convertIntToFloatColor(intColor: r), green: convertIntToFloatColor(intColor: g), blue: convertIntToFloatColor(intColor: b), alpha: a)
    }

    convenience init(hex: String, alpha: CGFloat = 1) {
        var chars = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hex.hasPrefix("#") {
            chars.remove(at: chars.startIndex)
        }

        if (chars.count != 6) {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }

        let arrChar = Array(chars)
        self.init(red: .init(strtoul(String(arrChar[0...1]), nil, 16)) / 255,
                  green: .init(strtoul(String(arrChar[2...3]), nil, 16)) / 255,
                  blue: .init(strtoul(String(arrChar[4...5]), nil, 16)) / 255,
                  alpha: alpha)
    }

}

extension UIImageView {
    func changeToColor(_ color: UIColor) {
        if let image = self.image {
            self.tintColor = color
            self.image = image.withRenderingMode(.alwaysTemplate)
        }
    }
}

extension UILabel {
    func configSizeToFit() {
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        sizeToFit()
    }

    func redDot(colorTextPart: String = "*", color: UIColor? = UIColor.appColor(.red)) {
        guard let string = self.text, let color = color else {
            return
        }
        attributedText = nil
        let result = NSMutableAttributedString(string: string)
        result.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSString(string: string.lowercased()).range(of: colorTextPart.lowercased()))
        attributedText = result
    }

    func configCommon(color: UIColor? = UIColor.appColor(.blackMain), fontWeight: FontStyle = FontStyle.Regular, fontSize: CGFloat = 14) {
        self.textColor = color
        self.textAlignment = .left
        self.font = UIConstants.Fonts.appFont(fontWeight, fontSize)
    }
    
    func addUnderline() {
        DispatchQueue.main.async {
            self.removeUnderline()
            let attributedString = NSMutableAttributedString.init(string: self.text ?? "")
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange.init(location: 0, length: attributedString.length));
            self.attributedText = attributedString
        }
    }
    func removeUnderline() {
        let attributedString = NSMutableAttributedString.init(string: text ?? "")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 0, range: NSRange.init(location: 0, length: attributedString.length));
        attributedText = attributedString
    }
}

extension LAContext {
    enum BiometricType: String {
        case none, touchID, faceID, unknown
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                return .unknown
                #warning("Handle new Biometric type")
            }
        }

        return self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        let labelSize = label.bounds.size

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange) || NSLocationInRange(indexOfCharacter + 4, targetRange)
    }

    func didTapAttributedTextInLabel2(label: UILabel, targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: .zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        label.sizeToFit()
        let labelSize = label.bounds.size

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = .byWordWrapping
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return (indexOfCharacter > 0 && (indexOfCharacter > targetRange.location && indexOfCharacter < (targetRange.location+targetRange.length)) || (indexOfCharacter + 4) > targetRange.location && (indexOfCharacter + 4) < (targetRange.location+targetRange.length))
    }
}

extension Dictionary {
    func getCode() -> String {
        guard let dict = self as? [String: Any], let code = dict[HTTP_KEY.Code.rawValue] as? String else {
            return ""
        }
        return code
    }
}

extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}

extension UIPageViewController {
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        if let currentViewController = viewControllers?[0] {
            if let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentViewController) {
                setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
            }
        }
    }
}

public extension BinaryFloatingPoint {
    func isAlmostEqual(to other: Self) -> Bool {
        abs(self - other) < abs(self + other).ulp
    }

    func isAlmostEqual(to other: Self, accuracy: Self) -> Bool {
        abs(self - other) < (abs(self + other) * accuracy).ulp
    }

    func isAlmostEqual(to other: Self, error: Self) -> Bool {
        abs(self - other) <= error
    }
}

public extension CGRect {
    // MARK: - Properties

    var center: CGPoint {
        get {
            CGPoint(x: midX, y: midY)
        }
        set {
            origin = CGPoint(x: newValue.x - width * 0.5, y: newValue.y - height * 0.5)
        }
    }
    
    // MARK: - Equality
    
    func isAlmostEqual(to other: CGRect) -> Bool {
        size.isAlmostEqual(to: other.size) && origin.isAlmostEqual(to: other.origin)
    }
    
    func isAlmostEqual(to other: CGRect, error: CGFloat) -> Bool {
        size.isAlmostEqual(to: other.size, error: error) && origin.isAlmostEqual(to: other.origin, error: error)
    }
}

public extension CGPoint {
    // MARK: - Equality

    func isAlmostEqual(to other: CGPoint) -> Bool {
        x.isAlmostEqual(to: other.x) && y.isAlmostEqual(to: other.y)
    }

    func isAlmostEqual(to other: CGPoint, error: CGFloat) -> Bool {
        x.isAlmostEqual(to: other.x, error: error) && y.isAlmostEqual(to: other.y, error: error)
    }
}

extension CGSize {
    static func uniform(_ side: CGFloat) -> CGSize {
        CGSize(width: side, height: side)
    }
    
    // MARK: - Equality

    func isAlmostEqual(to other: CGSize) -> Bool {
        width.isAlmostEqual(to: other.width) && height.isAlmostEqual(to: other.height)
    }
    
    func isAlmostEqual(to other: CGSize, error: CGFloat) -> Bool {
        width.isAlmostEqual(to: other.width, error: error) && height.isAlmostEqual(to: other.height, error: error)
    }
}

extension URLRequest {
    static func allowsAnyHTTPSCertificateForHost(_ host:String) -> Bool{
        return true
    }
}

extension UITextField {
    // MARK: Validation
    func isValid(with word: String) -> Bool {
        guard let text = self.text, !text.isEmpty else { return false }
        guard text.contains(word) else {
            return false
        }
        return true
    }
    
    func isEmpty() -> Bool {
        guard let text = self.text, !text.isEmpty else { return true }
        return false
    }
    
    var count: Int {
        return text?.count ?? 0
    }
}

extension UIImage{
    var grayScaled: UIImage?{
        guard let currentCGImage = self.cgImage else { return nil }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        
        // set a gray value for the tint color
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        
        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return nil
    }
}
