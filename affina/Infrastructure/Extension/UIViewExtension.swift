//
//  UIViewExtension.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit
import SnapKit

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical

    var startPoint: CGPoint {
        return points.startPoint
    }

    var endPoint: CGPoint {
        return points.endPoint
    }

    var points: GradientPoints {
        switch self {
        case .topRightBottomLeft:
            return (CGPoint(x: 0.0, y: 1.0), CGPoint(x: 1.0, y: 0.0))
        case .topLeftBottomRight:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 1, y: 1))
        case .horizontal:
            return (CGPoint(x: 0.0, y: 0.5), CGPoint(x: 1.0, y: 0.5))
        case .vertical:
            return (CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 1.0))
        }
    }
}

extension UIViewController {

    func presentInFullScreen(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: animated, completion: completion)
    }
}

extension UIView {
    // MARK: Show/hide
    func hide(isImmediate: Bool = false) {
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.25, delay: 0, options: .transitionCrossDissolve, animations: {
//                self.isHidden = isImmediate
//                self.layer.opacity = 0
//            }, completion: { finished in
//                self.isHidden = true
//            })
//        }
        self.isHidden = true
    }

    func show() {
//        DispatchQueue.main.async {
//            UIView.animate(withDuration: 0.25, delay: 0, options: .showHideTransitionViews, animations: {
//                self.isHidden = false
//                self.layer.opacity = 1
//            })
//        }
        self.isHidden = false
    }
    // MARK: Tap Gesture Recognizer
    fileprivate struct AssociatedObjectKey {
        static var tapGestureRecognizer = "Affina_AssociatedObjectKey_Affina"
    }

    fileprivate typealias Action = (() -> Void)?

    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedObjectKey.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKey.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }

    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handlerTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc fileprivate func handlerTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        }
        else {
            Logger.Logs(message: "No action!!")
        }
    }

    // MARK: Safe Area
    var safeArea: ConstraintBasicAttributesDSL {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        }
        return self.snp
    }

    // MARK: Shadow
    func dropShadow(color: UIColor, opacity: Float = 0.5, offset: CGSize, radius: CGFloat = 2, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        //        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    // gradient
    func applyGradientLayer(colors: [UIColor], locations: [NSNumber]?) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0.08))

//        layer.addSublayer(gradientLayer)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    func applyGradientLayer(colors: [UIColor], orientation: GradientOrientation) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = orientation.startPoint
        gradientLayer.endPoint = orientation.endPoint

        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0.08))

//        layer.addSublayer(gradientLayer)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    class func initFromNib<T: UIView>() -> T {
        return UINib(nibName: String(describing: self), bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! T
//        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?[0] as! T
    }
}
