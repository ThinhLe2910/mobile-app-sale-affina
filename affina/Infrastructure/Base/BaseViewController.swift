//
//  BaseViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 11/05/2022.
//

import UIKit
import SnapKit
import FirebaseMessaging

class BaseViewController: UIViewController {
    
    // header
    lazy var headerBaseView = UIView()
    lazy var leftBaseButton = UIButton()
    lazy var leftBaseImage = UIImageView()
    lazy var labelBaseTitle = UILabel()
    lazy var rightBaseButton = UIButton()
    lazy var rightBaseImage = UIImageView()
    
    //base viewcontroller
    let containerBaseView = UIView()
    let viewBaseContent = UIView()
    
    //MARK: bottomSheet
    let bottomSheet = BottomSheetViewController(initialHeight: 500)
    // Configuration
    public struct BottomSheetConfiguration {
        let height: CGFloat
        let initialOffset: CGFloat
    }
    private var configuration = BottomSheetConfiguration(height: 500.height, initialOffset: 0)
    
    // State
    public enum BottomSheetState {
        case initial
        case full
    }
    var state: BottomSheetState = .initial
    
    //pan gesture
    lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer()
        pan.delegate = self
        pan.addTarget(self, action: #selector(handlePan))
        return pan
    }()
    
    private var topConstraint = NSLayoutConstraint()
    private var bottomSheetHeightConstraint = NSLayoutConstraint()
    
    // lock screen
    lazy var viewLock = UIView()
    lazy var viewIndicator = UIActivityIndicatorView()
    
    //errorView
    var errorView: UIView?
    
    //successView
    var successView: UIView?
    var successCompletion: (() -> ())?
    
    //gray screen
    lazy var grayScreen: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        return view
    }()
    //clear screen
    lazy var clearScreen: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        return view
    }()
    
    //base alert
    private lazy var viewBackgroundBaseAlert = UIView()
    private lazy var buttonBackgroundCloseAlert = UIButton()
    private lazy var viewBaseAlert = UIView()
    private lazy var buttonCloseBaseAlert = UIButton()
    private lazy var imageBaseAlert = UIImageView()
    private lazy var labelTitleBaseAlert = UILabel()
    lazy var labelMessageBaseAlert = UILabel()
    var buttonBaseAlertConfirm = BaseButton()
    var buttonSingleAlertBaseCancel = BaseButton()
    
    //base option alert
    private let viewBackgroundBaseOptionAlert = UIView()
    private let buttonBackgroundCloseOptionAlert = UIButton()
    private let viewBaseOptionAlert = UIView()
    private let imageBaseOptionAlert = UIImageView()
    private let labelTitleBaseOptionAlert = UILabel()
    private let labelMessageBaseOptionAlert = UILabel()
    var buttonBaseAlertOptionConfirm = BaseButton()
    var buttonBaseAlertOptionCancel = BaseButton()
    var centerYAlertConstraint: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        grayScreen.frame = self.view.frame
        clearScreen.frame = self.view.frame
        
        setUpNavigationBar()
        setupSwipeNavigation()
        initBaseView()
        initViews()
        setupConstraints()
        setupBottomSheet()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
    }
    func initViews() { }
    
    func setupConstraints() { }
    
    //    public func isIphoneX() -> Bool {
    //        var isIphoneX = false
    //        if UIDevice.current.modelName == Model.iPhoneX.rawValue || UIDevice.current.modelName == Model.iPhoneXR.rawValue || UIDevice.current.modelName == Model.iPhoneXS.rawValue || UIDevice.current.modelName == Model.iPhoneXSmax.rawValue {
    //            isIphoneX = true
    //        } else {
    //            isIphoneX = false
    //        }
    //        return isIphoneX
    //    }
    
    func setUpNavigationBar() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
    }
    
    func setupSwipeNavigation() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func initBaseView() {
        // MARK: HEADER VIEW
        // base header view
        headerBaseView.frame = CGRect(x: 0, y: 0, width: UIConstants.Layout.screenWidth, height: UIConstants.Layout.headerHeight)
        self.view.addSubview(headerBaseView)
        headerBaseView.backgroundColor = UIColor(r: 28, g: 82, b: 145)
        // left base button
        leftBaseImage.frame = CGRect(x: UIConstants.widthConstraint(15), y: 0, width: UIConstants.widthConstraint(24), height: UIConstants.heightConstraint(24))
        leftBaseImage.contentMode = .scaleAspectFit
        leftBaseImage.image = UIImage(named: "ic_back")
        //        leftBaseImage.changeToColor(.white)
        headerBaseView.addSubview(leftBaseImage)
        
        leftBaseButton.frame = CGRect(x: 0, y: 0, width: UIConstants.widthConstraint(Constants.Layout.headerHeight), height: UIConstants.heightConstraint(UIConstants.Layout.headerHeight))
        headerBaseView.addSubview(leftBaseButton)
        leftBaseButton.isUserInteractionEnabled = true
        leftBaseButton.addTarget(self, action: #selector(didClickLeftBaseButton), for: .touchUpInside)
        leftBaseImage.center.y = leftBaseButton.center.y + 15
        
        // label base title
        labelBaseTitle.frame = CGRect(x: UIConstants.widthConstraint(30), y: 0, width: UIConstants.Layout.screenWidth - 60, height: UIConstants.heightConstraint(21))
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textAlignment = .center
        labelBaseTitle.textColor = UIColor.appColor(.whiteMain)
        labelBaseTitle.center.x = headerBaseView.center.x
        labelBaseTitle.center.y = leftBaseImage.center.y
        headerBaseView.addSubview(labelBaseTitle)
        
        // right base image
        rightBaseImage.frame = CGRect(x: UIConstants.Layout.screenWidth - UIConstants.widthConstraint(24) - 15, y: 0, width: UIConstants.widthConstraint(24), height: UIConstants.heightConstraint(24))
        rightBaseImage.contentMode = .scaleAspectFit
        rightBaseImage.changeToColor(.white)
        headerBaseView.addSubview(rightBaseImage)
        rightBaseImage.center.y = leftBaseImage.center.y
        
        //MARK: CONTENT VIEW
        //add base content view
        //        containerBaseView.frame = CGRect(x: 0, y: UIConstants.Layout.headerHeight, width: UIConstants.Layout.screenWidth, height: UIConstants.Layout.screenHeight - UIConstants.Layout.Padding.top)
        view.addSubview(containerBaseView)
        containerBaseView.snp.makeConstraints { make in
            make.top.equalTo(UIConstants.Layout.headerHeight)
            make.width.equalToSuperview()
            make.height.equalTo(UIConstants.Layout.screenHeight - UIPadding.top)
        }
        
        viewBaseContent.frame = CGRect(x: 0, y: 0, width: UIConstants.Layout.screenWidth, height: UIConstants.Layout.screenHeight - headerBaseView.frame.height)
        viewBaseContent.backgroundColor = UIColor.appColor(.backgroundGray)
        containerBaseView.addSubview(viewBaseContent)
    }
    
    @objc func didClickLeftBaseButton() {
        popViewController()
    }
    
    func addRightBaseButton() {
        rightBaseButton.frame = CGRect(x: UIConstants.widthConstraint(275), y: 0, width: UIConstants.widthConstraint(UIConstants.widthConstraint(100)), height: UIConstants.heightConstraint(UIConstants.Layout.headerHeight))
        rightBaseButton.backgroundColor = .clear
        headerBaseView.addSubview(rightBaseButton)
    }
    
    func hideHeaderBase() {
        headerBaseView.removeFromSuperview()
    }
    
    func hideLeftBaseButton() {
        leftBaseImage.image = nil
        leftBaseButton.isUserInteractionEnabled = false
    }
    
    // MARK: Lock/Unlock Screen
    func lockScreen() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.viewIndicator.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.viewIndicator.backgroundColor = .black.withAlphaComponent(0.5)
            self.viewIndicator.layer.zPosition = 99
            UIApplication.topViewController()?.view.addSubview(self.viewIndicator)
            self.viewIndicator.style = .white
            self.viewIndicator.color = UIColor.appColor(.greenMain)
            self.viewIndicator.startAnimating()
        }
    }
    
    func unlockScreen() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.viewIndicator.removeFromSuperview()
        }
    }
    
    @objc func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    // MARK: Error View
    func showErrorViewWithText(_ text: String) {
        if errorView == nil {
            DispatchQueue.main.async {
                let errorView = UIView(frame: CGRect(x: 0, y: -(UIConstants.heightConstraint(UIConstants.Layout.headerHeight) + UIConstants.Layout.Padding.top), width: UIConstants.Layout.screenWidth, height: UIConstants.heightConstraint(UIConstants.Layout.headerHeight) + UIConstants.Layout.Padding.top))
                errorView.backgroundColor = UIColor(hex: AssetsColor.redError.value)
                self.view.addSubview(errorView)
                
                let labelError = UILabel(frame: CGRect(x: UIConstants.heightConstraint(31), y: UIConstants.Layout.Padding.top, width: UIConstants.widthConstraint(313), height: UIConstants.heightConstraint(UIConstants.Layout.headerHeight)))
                labelError.textColor = UIColor(hex: AssetsColor.whiteTextMain.value)
                labelError.text = text.localize()
                labelError.font = UIConstants.Fonts.appFont(.Regular, 14)
                labelError.numberOfLines = 0
                labelError.lineBreakMode = .byWordWrapping
                labelError.sizeToFit()
                labelError.center.y = UIConstants.Layout.Padding.top + UIConstants.heightConstraint(UIConstants.Layout.headerHeight) / 2
                errorView.addSubview(labelError)
                self.errorView = errorView
                
                UIView.animate(withDuration: 0.1, animations: {
                    var frame = self.errorView?.frame ?? .zero
                    frame.origin.y = 0
                    self.errorView?.frame = frame
                }, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.hideErrorView()
            }
        }
    }
    
    func hideErrorView() {
        if let errorView = errorView {
            UIView.animate(withDuration: 0.2, animations: {
                var frame = errorView.frame
                frame.origin.y = -(UIConstants.heightConstraint(UIConstants.Layout.headerHeight) + UIConstants.Layout.Padding.top)
                errorView.frame = frame
            }) { _ in
                errorView.removeFromSuperview()
                self.errorView = nil
            }
        }
    }
    
    // MARK: Custom Alert
    func showCustomOKAlert(title: String?, titleColor: UIColor = AssetsColor.textBlack.toUIColor(), iconString: String = "dialog_success", iconSize: CGFloat = 60, iconPadding: CGFloat = 20, message: String?, buttonString: String?, padding: CGFloat = 16, handler closure: @escaping () -> Void) {
        self.successCompletion = closure
        let dialogWidth = UIConstants.Layout.screenWidth - padding.width * 2
        if successView == nil {
            DispatchQueue.main.async {
                self.view.addSubview(self.grayScreen)
                // Set default y for moving from bottom to center
                self.successView = UIView(frame: CGRect(x: UIConstants.widthConstraint(padding), y: UIConstants.Layout.screenHeight + UIConstants.heightConstraint(269), width: dialogWidth, height: UIConstants.heightConstraint(269)))
                guard let successView = self.successView else {
                    return
                }
                successView.translatesAutoresizingMaskIntoConstraints = false
                //                self.successView!.center.y = UIConstants.Layout.screenHeight / 2
                successView.layer.cornerRadius = 10
                successView.backgroundColor = .white
                self.view.addSubview(successView)
                successView.snp.makeConstraints { make in
                    //                    make.width.equalTo(dialogWidth)
                    //                    make.height.equalTo(UIConstants.heightConstraint(300))
                    make.leading.trailing.equalToSuperview().inset(padding)
                    self.centerYAlertConstraint = make.centerY.equalTo(self.view.snp_centerY).constraint
                }
                
                let icon = UIImageView()
                icon.image = UIImage(named: iconString)
                icon.contentMode = .scaleAspectFit
                self.successView!.addSubview(icon)
                icon.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().inset(UIConstants.heightConstraint(iconPadding))
                    make.width.height.equalTo(UIConstants.heightConstraint(iconSize))
                }
                
                let topLabel = UILabel(frame: CGRect(x: 0, y: UIConstants.heightConstraint(iconSize + 30), width: dialogWidth, height: UIConstants.heightConstraint(21)))
                topLabel.numberOfLines = 0
                topLabel.text = title
                topLabel.font = .boldSystemFont(ofSize: 18)
                topLabel.textAlignment = .center
                topLabel.textColor = titleColor
                self.successView!.addSubview(topLabel)
                topLabel.snp.makeConstraints { (make) in
                    make.top.equalTo(icon.snp_bottom).inset(-16.height)
                    make.left.right.equalToSuperview().inset(20.width)
                }
                
                let bottomLabel = UILabel()
                bottomLabel.text = message
                bottomLabel.font = .systemFont(ofSize: 14)
                bottomLabel.numberOfLines = 0
                bottomLabel.textAlignment = .center
                self.successView!.addSubview(bottomLabel)
                bottomLabel.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(UIConstants.widthConstraint(25))
                    //                    make.top.equalToSuperview().inset(UIConstants.heightConstraint(119))
                    make.top.equalTo(topLabel.snp_bottom).inset(-UIPadding.size24)
                }
                
                let seperator = UIView()
                seperator.backgroundColor = UIColor(r: 217, g: 217, b: 217)
                self.successView!.addSubview(seperator)
                seperator.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(UIConstants.widthConstraint(15))
                    make.height.equalTo(1)
                    //                    make.bottom.equalToSuperview().inset(100.height)
                    make.top.equalTo(bottomLabel.snp_bottom).inset(-UIPadding.size24)
                }
                
                let button = UIView()
                self.successView!.addSubview(button)
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(seperator.snp_bottom)
                    make.left.right.bottom.equalToSuperview()
                    make.height.equalTo(50.height)
                }
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.successButtonTapped))
                button.isUserInteractionEnabled = true
                button.addGestureRecognizer(tap)
                
                let confirmLabel = UILabel()
                confirmLabel.font = .boldSystemFont(ofSize: 16)
                confirmLabel.textColor = UIColor(r: 56, g: 111, b: 214)
                confirmLabel.text = buttonString ?? "CONFIRM".localize()
                button.addSubview(confirmLabel)
                confirmLabel.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    var frame = self.successView!.frame
                    frame.origin.y = self.view.frame.height / 2
                    self.successView!.frame = frame
                })
            }
        }
    }
    
    func showCustomOptionAlert(title: String?, titleColor: UIColor = AssetsColor.textBlack.toUIColor(), iconString: String = "dialog_success", iconSize: CGFloat = 60, iconPadding: CGFloat = 20, message: String?, buttonString: String?, buttonColor: UIColor = UIColor(r: 56, g: 111, b: 214), cancelString: String?, cancelColor: UIColor = UIColor(r: 122, g: 122, b: 122), padding: CGFloat = 16, handler closure: @escaping () -> Void) {
        self.successCompletion = closure
        let dialogWidth = UIConstants.Layout.screenWidth - padding.width * 2
        if successView == nil {
            DispatchQueue.main.async {
                self.view.addSubview(self.grayScreen)
                // Set default y for moving from bottom to center
                self.successView = UIView(frame: CGRect(x: UIConstants.widthConstraint(padding), y: UIConstants.Layout.screenHeight + UIConstants.heightConstraint(300), width: dialogWidth, height: UIConstants.heightConstraint(300)))
                guard let successView = self.successView else {
                    return
                }
                successView.translatesAutoresizingMaskIntoConstraints = false
                
                //                self.successView!.center.y = UIConstants.Layout.screenHeight / 2
                successView.layer.cornerRadius = 10
                successView.backgroundColor = .white
                self.view.addSubview(successView)
                successView.snp.makeConstraints { make in
                    //                    make.width.equalTo(dialogWidth)
                    //                    make.height.equalTo(UIConstants.heightConstraint(300))
                    make.leading.trailing.equalToSuperview().inset(padding)
                    self.centerYAlertConstraint = make.centerY.equalTo(self.view.snp_centerY).constraint
                }
                
                let icon = UIImageView()
                icon.image = UIImage(named: iconString)
                icon.contentMode = .scaleAspectFit
                self.successView!.addSubview(icon)
                icon.snp.makeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().inset(UIConstants.heightConstraint(iconPadding))
                    make.width.height.equalTo(UIConstants.heightConstraint(iconSize))
                }
                
                let topLabel = UILabel(frame: CGRect(x: 0, y: UIConstants.heightConstraint(iconSize + 30), width: dialogWidth, height: UIConstants.heightConstraint(21)))
                topLabel.numberOfLines = 0
                topLabel.text = title
                topLabel.font = .boldSystemFont(ofSize: 18)
                topLabel.textAlignment = .center
                topLabel.textColor = titleColor
                self.successView!.addSubview(topLabel)
                topLabel.snp.makeConstraints { (make) in
                    //                    make.top.equalToSuperview().inset((iconSize + 30).height)
                    make.top.equalTo(icon.snp_bottom).inset(-16.height)
                    make.left.right.equalToSuperview().inset(20.width)
                }
                
                let bottomLabel = UILabel()
                bottomLabel.text = message
                bottomLabel.font = .systemFont(ofSize: 14)
                bottomLabel.numberOfLines = 0
                bottomLabel.textAlignment = .center
                self.successView!.addSubview(bottomLabel)
                bottomLabel.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(UIConstants.widthConstraint(25))
                    //                    make.top.equalToSuperview().inset(UIConstants.heightConstraint(119))
                    make.top.equalTo(topLabel.snp_bottom).inset(-UIPadding.size16)
                }
                
                let seperator = UIView()
                seperator.backgroundColor = UIColor(r: 217, g: 217, b: 217)
                self.successView!.addSubview(seperator)
                seperator.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(UIConstants.widthConstraint(15))
                    make.height.equalTo(1)
                    //                    make.bottom.equalToSuperview().inset(100.height)
                    make.top.equalTo(bottomLabel.snp_bottom).inset(-UIPadding.size24)
                }
                
                let buttonConfirm = UIView()
                self.successView!.addSubview(buttonConfirm)
                buttonConfirm.snp.makeConstraints { (make) in
                    make.top.equalTo(seperator.snp_bottom)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50.height)
                    //                    make.bottom.equalToSuperview().inset(50.height)
                }
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.successButtonTapped))
                buttonConfirm.isUserInteractionEnabled = true
                buttonConfirm.addGestureRecognizer(tap)
                
                let confirmLabel = UILabel()
                confirmLabel.font = .boldSystemFont(ofSize: 16)
                confirmLabel.textColor = buttonColor
                confirmLabel.text = buttonString ?? "CONFIRM".localize()
                buttonConfirm.addSubview(confirmLabel)
                confirmLabel.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                let secondSeperator = UIView()
                secondSeperator.backgroundColor = UIColor(r: 217, g: 217, b: 217)
                self.successView!.addSubview(secondSeperator)
                secondSeperator.snp.makeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(UIConstants.widthConstraint(15))
                    make.height.equalTo(1)
                    make.top.equalTo(buttonConfirm.snp_bottom)
                }
                
                let buttonCancel = UIView()
                self.successView!.addSubview(buttonCancel)
                buttonCancel.snp.makeConstraints { (make) in
                    make.height.equalTo(50.height)
                    make.top.equalTo(secondSeperator.snp_bottom)
                    make.left.right.bottom.equalToSuperview()
                }
                let tapCancel = UITapGestureRecognizer(target: self, action: #selector(self.hideCustomOkAlert))
                buttonCancel.isUserInteractionEnabled = true
                buttonCancel.addGestureRecognizer(tapCancel)
                
                let cancelLabel = UILabel()
                cancelLabel.font = .boldSystemFont(ofSize: 16)
                cancelLabel.textColor = cancelColor
                cancelLabel.text = cancelString ?? "Cancel"
                buttonCancel.addSubview(cancelLabel)
                cancelLabel.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                    var frame = self.successView!.frame
                    frame.origin.y = self.view.frame.height / 2
                    self.successView!.frame = frame
                })
            }
        }
    }
    
    @objc func hideCustomOkAlert() {
        if successView != nil {
            self.grayScreen.removeFromSuperview()
            //            centerYAlertConstraint?.deactivate()
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                var frame = self.successView!.frame
                self.centerYAlertConstraint?.update(offset: (self.view.frame.height + frame.height) / 2)
                frame.origin.y = self.view.frame.height // Move to bottom
                self.successView!.frame = frame
            }) { (_) in
                if self.successView != nil {
                    self.successView!.removeFromSuperview()
                    self.successView = nil
                    self.centerYAlertConstraint = nil
                }
            }
        }
    }
    
    @objc func successButtonTapped() {
        hideCustomOkAlert()
        successCompletion?()
    }
    
    // MARK: Observer
    func removeAllObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getAttributedString(arrayTexts: [String], arrayColors: [UIColor], arrayFonts: [UIFont], arrayUnderlines: [Bool] = []) -> NSMutableAttributedString {
        let finalString = NSMutableAttributedString()
        
        for i in 0..<arrayTexts.count {
            var attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: arrayColors[i],
                NSAttributedString.Key.font: arrayFonts[i]
            ]
            if !arrayUnderlines.isEmpty && arrayUnderlines.count > i && arrayUnderlines[i] {
                attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.thick.rawValue
            }
            let str = (NSAttributedString.init(string: arrayTexts[i], attributes: attributes))
            
            if i != 0 {
                finalString.append(NSAttributedString.init(string: " "))
            }
            finalString.append(str)
        }
        
        return finalString
    }
    
    // MARK: Enable/disable views
    func enableViews() { }
    
    func disableViews() { }
    
    func hideErrorLabel() { }
    
    func logOut() {
        if !UIConstants.isLoggedIn { return }
        UIConstants.isLoggedIn = false
        UIConstants.isRequestedProvinces = false
        AppStateManager.shared.userCoin = 0
        Messaging.messaging().unsubscribe(fromTopic: "logged")
        
        UserDefaults.standard.set(false, forKey: Key.notFirstTimeLogin.rawValue)
        UserDefaults.standard.set(false, forKey: Key.hasRequestedBiometricAuth.rawValue)
        UserDefaults.standard.set(false, forKey: Key.hasShownFirstCard.rawValue)
        UserDefaults.standard.set(false, forKey: Key.biometricAuth.rawValue)
        UserDefaults.standard.set(false, forKey: Key.claimBenefitNote.rawValue)
        UserDefaults.standard.set("", forKey: Key.expireAt.rawValue)
        UserDefaults.standard.set("", forKey: Key.refreshAt.rawValue)
        UserDefaults.standard.set(nil, forKey: Key.token.rawValue)
        UserDefaults.standard.set("", forKey: Key.password.rawValue)
        UserDefaults.standard.set("", forKey: Key.customerName.rawValue)
        UserDefaults.standard.set(nil, forKey: Key.phoneNumber.rawValue)
//        UserDefaults.standard.set([String](), forKey: Key.readPopup.rawValue)
        //        CacheManager.shared.deleteCacheData(Key.profile.rawValue)
        CacheManager.shared.clearAllCaches()
        
    }
    
    func popToViewController<T: BaseViewController>(_ viewController: T) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: T.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func canPopToViewController<T: BaseViewController>(_ viewController: T) -> Bool {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: T.self) {
                return true
            }
        }
        return false
    }
    
    func handleAPIError(error: ApiError) {
        switch error {
            case .refresh:
                break
            case .expired:
                logOut()
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    PopupManager.shared.removePopup(of: "ERROR".localize() + "ERROR_TOKEN_EXPIRED".localize())
                    self.dismiss(animated: true, completion: nil)
                } handler: {
                    
                }
                break
            default:
                queueBasePopup(icon: UIImage(named: "ic_warning"), title: "ERROR".localize(), desc: "ERROR_HAPPENED".localize(), okTitle: "TRY_AGAIN".localize(), cancelTitle: "", okHandler: {
                    self.hideBasePopup()
                }, handler: {})
                break
        }
        
    }
    
    func addBlurStatusBar() {
        let statusBarView = UIView(frame: CGRect(x:0, y:0, width:view.frame.size.width, height: UIApplication.shared.statusBarFrame.height))
        statusBarView.backgroundColor = UIColor.white
        statusBarView.alpha = 0.8 // set any value between 0 to 1
        view.addSubview(statusBarView)
        addBlurEffect(statusBarView)
    }
    
    func addBlurEffect(_ view: UIView, color: UIColor = UIColor(r: 255, g: 255, b: 255, a: 0.45), opacity: CGFloat = 0.45) {
        view.backgroundColor = color.withAlphaComponent(0.45)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
    }
}

// MARK: TextField
extension BaseViewController: UITextFieldDelegate {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hideErrorLabel()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.disableViews()
    }
    
}

// MARK: CustomPopup
extension BaseViewController {
    func queueBasePopup(icon: UIImage?, title: String, desc: String, okTitle: String, cancelTitle: String, textColors: [UIColor]? = [], buttonStyles: [BaseButtonStyle]? = [], okHandler okClosure: @escaping () -> Void, handler closure: @escaping () -> Void, priority: PopupPriority = .normal) {
        self.successCompletion = closure
        let dialogWidth: CGFloat = 344.width
        let descHeight = title.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Bold, 24)) + desc.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Medium, 16)) + 4 + 24
        let dialogHeight: CGFloat = 286.height + descHeight + 20
        
        self.view.addSubview(self.grayScreen)
        
        let popupView = BasePopup.instanceFromNib()
        popupView.setPopupData(icon: icon, title: title, desc: desc, okTitle: okTitle, cancelTitle: cancelTitle)
        
        if textColors != nil && !textColors!.isEmpty { // textColor for title & desc
            popupView.titleLabel.textColor = textColors![0]
            popupView.descLabel.textColor = textColors![1]
        }
        
        if buttonStyles != nil && !buttonStyles!.isEmpty { // buttonStyles for ok/cancel button
            popupView.setBackButtonStyle(style: buttonStyles![0])
            popupView.setOkButtonStyle(style: buttonStyles![1])
        }
        
        popupView.cancelCallBack = {
            self.hideBasePopup()
            closure()
        }
        
        popupView.okCallBack = {
            okClosure()
        }
        
        //popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.frame = .init(origin: .init(x: (UIConstants.Layout.screenWidth - dialogWidth) / 2, y: (UIConstants.Layout.screenHeight - dialogHeight) / 2 - 50), size: .init(width: dialogWidth, height: dialogHeight))
        let popupNode = PriorityNode(name: title + desc, priority: priority, popup: popupView)
        print(popupView.frame)
        PopupManager.shared.queuePopup(popupNode)
        //        PopupManager.shared.showPopup()
    }

    func queueBasePopup2(icon: UIImage?, title: String, desc: String, okTitle: String, cancelTitle: String, textColors: [UIColor]? = [], buttonStyles: [BaseButtonStyle]? = [], okHandler okClosure: @escaping () -> Void, handler closure: @escaping () -> Void, priority: PopupPriority = .normal) {
        self.successCompletion = closure
        let dialogWidth: CGFloat = 344.width
        let descHeight = title.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Bold, 24)) + desc.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Medium, 16)) + 4
        let dialogHeight: CGFloat = 358.height + descHeight + okTitle.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Medium, 16)) + cancelTitle.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Medium, 16))
        
        self.view.addSubview(self.grayScreen)
        
        let popupView = BasePopup2.instanceFromNib()
        popupView.setPopupData(icon: icon, title: title, desc: desc, okTitle: okTitle, cancelTitle: cancelTitle)
        
        if textColors != nil && !textColors!.isEmpty { // textColor for title & desc
            popupView.titleLabel.textColor = textColors![0]
            popupView.descLabel.textColor = textColors![1]
        }
        
        if buttonStyles != nil && !buttonStyles!.isEmpty { // buttonStyles for ok/cancel button
            popupView.setBackButtonStyle(style: buttonStyles![0])
            popupView.setOkButtonStyle(style: buttonStyles![1])
        }
        
        popupView.cancelCallBack = {
            self.hideBasePopup()
            closure()
        }
        
        popupView.okCallBack = {
            okClosure()
        }
        
        //popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.frame = .init(origin: .init(x: (UIConstants.Layout.screenWidth - dialogWidth) / 2, y: (UIConstants.Layout.screenHeight - dialogHeight) / 2 - 50), size: .init(width: dialogWidth, height: dialogHeight))
        let popupNode = PriorityNode(name: okTitle, priority: priority, popup: popupView)
        PopupManager.shared.queuePopup(popupNode)
    }
    
    func queueBasePopup(icon: UIImage?, title: String, desc: NSMutableAttributedString, okTitle: String, cancelTitle: String, textColors: [UIColor]? = [], buttonStyles: [BaseButtonStyle]? = [], descText: String, okHandler okClosure: @escaping () -> Void, handler closure: @escaping () -> Void, priority: PopupPriority = .normal) {
        self.successCompletion = closure
        let dialogWidth: CGFloat = 344.width
        let descHeight = title.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Bold, 24)) + descText.heightWithConstrainedWidth(width: dialogWidth, font: UIConstants.Fonts.appFont(.Medium, 16)) + 4 + 24
        let dialogHeight: CGFloat = 286 + descHeight
        //        print("Dialog width: ")
        //        Logger.Logs(message: dialogWidth)
        //        Logger.Logs(message: descHeight)
        //        Logger.Logs(message: dialogHeight)
        
        self.view.addSubview(self.grayScreen)
        
        let popupView = BasePopup.instanceFromNib()
        popupView.setPopupData(icon: icon, title: title, desc: desc, okTitle: okTitle, cancelTitle: cancelTitle)
        
        if textColors != nil && !textColors!.isEmpty { // textColor for title & desc
            popupView.titleLabel.textColor = textColors![0]
            popupView.descLabel.textColor = textColors![1]
        }
        
        if buttonStyles != nil && !buttonStyles!.isEmpty { // buttonStyles for ok/cancel button
            popupView.setBackButtonStyle(style: buttonStyles![0])
            popupView.setOkButtonStyle(style: buttonStyles![1])
        }
        
        popupView.cancelCallBack = {
            self.hideBasePopup()
            closure()
        }
        
        popupView.okCallBack = {
            okClosure()
        }
        
        //popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.frame = .init(origin: .init(x: (UIConstants.Layout.screenWidth - dialogWidth) / 2, y: (UIConstants.Layout.screenHeight - dialogHeight) / 2 - 50), size: .init(width: dialogWidth, height: dialogHeight))
        let popupNode = PriorityNode(name: okTitle, priority: priority, popup: popupView)
        print(popupView.frame)
        PopupManager.shared.queuePopup(popupNode)
        //        PopupManager.shared.showPopup()
    }

    
    func showCustomPopup(zPosition: CGFloat = 99, messages: [String], positions: [CGPoint], posTypes: [CaretPosition] = [CaretPosition.center, CaretPosition.right], dialogWidth: CGFloat = 252, handler closure: @escaping () -> Void, priority: PopupPriority = .normal) {
        self.successCompletion = closure
        let customPopup = CustomPopup.instanceFromNib()
        customPopup.positions = positions
        customPopup.posTypes = posTypes
        customPopup.messages = messages
        customPopup.callBack = {
            self.hideCustomPopup()
            customPopup.removeFromSuperview()
            closure()
        }
        customPopup.layer.zPosition = zPosition
        customPopup.updatePopupInfo()
        
        
        customPopup.frame = .init(origin: positions[0], size: .init(width: dialogWidth, height: 130))
        
//        let popupNode = PriorityNode(name: "Custom popup", priority: priority, popup: customPopup)
//        PopupManager.shared.queuePopup(popupNode)
//        PopupManager.shared.showPopup()
        self.view.addSubview(customPopup)
    }
    
    func showCustomPopup2(messages: [String], positions: [CGPoint], caretPos: [CGPoint] = [.init(x: 0, y: 0)], dialogWidth: CGFloat = 252, handler closure: @escaping () -> Void, priority: PopupPriority = .normal) {
        self.successCompletion = closure
        let customPopup = CustomPopup.instanceFromNib()
        customPopup.positions = positions
        customPopup.caretPos = caretPos
        customPopup.messages = messages
        customPopup.callBack = {
            self.hideCustomPopup()
            closure()
        }
        UIApplication.topViewController()?.view.addSubview(self.clearScreen)
        
        customPopup.updatePopupInfo()
        
        customPopup.frame = .init(origin: positions[0], size: .init(width: dialogWidth, height: 130))
        
        let popupNode = PriorityNode(name: "Custom popup", priority: priority, popup: customPopup)
        PopupManager.shared.queuePopup(popupNode)
        PopupManager.shared.showPopup()
    }
    
    func showPopup() {
        PopupManager.shared.showPopup()
    }
    
    @objc func hideBasePopup() {
        clearScreen.removeFromSuperview()
        grayScreen.removeFromSuperview()
        PopupManager.shared.removePopup()
        PopupManager.isShowingPopup = false
    }
    
    @objc func hideCustomPopup() {
        clearScreen.removeFromSuperview()
        grayScreen.removeFromSuperview()
        PopupManager.shared.removePopup()
        PopupManager.isShowingPopup = false
    }
}

// MARK: Internet Connection Status
extension BaseViewController: InternetConnectionStatusDelegate {
    func tokenNotFound() {
        DispatchQueue.main.async {
            self.unlockScreen()
            self.queueBasePopup(icon: UIImage(named: "ic_banned"), title: "Token not found", desc: "Token not found", okTitle: "", cancelTitle: "OK") {
                
            } handler: {
                
            }
        }
    }
    
    func badRequest() {
        DispatchQueue.main.async {
            self.unlockScreen()
            self.queueBasePopup(icon: UIImage(named: "ic_banned"), title: "Token not found", desc: "Bad request", okTitle: "", cancelTitle: "OK") {
                
            } handler: {
                
            }
        }
    }
    
    func tokenExpired() {
        DispatchQueue.main.async {
            self.unlockScreen()
            self.queueBasePopup(icon: UIImage(named: "ic_banned"), title: "Token not found", desc: "Token expired", okTitle: "", cancelTitle: "OK") {
                
            } handler: {
                
            }
        }
    }
    
    func showViewDisconnected() {
        DispatchQueue.main.async {
            // TODO:
            if !(UIApplication.topViewController()?.isKind(of: InternetConnectionViewController.self))! {
                self.presentInFullScreen(InternetConnectionViewController(), animated: true, completion: nil)
            }
        }
    }
    
    func showErrorPopup(error: ApiError) {
        switch error {
            case .refresh:
                break
            case .expired:
                UIConstants.isBanned = true
                logOut()
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ERROR_TOKEN_EXPIRED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    PopupManager.shared.removePopup(of: "ERROR".localize())
                    self.navigationController?.popToRootViewController(animated: true)
                } handler: {
                    
                }
                break
            case .requestTimeout(_):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
            case .custom(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: error.localizedDescription, okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    PopupManager.shared.removePopup(of: "ERROR".localize())
                    self.navigationController?.popToRootViewController(animated: true)
                } handler: {
                    
                }
                break
            default:
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "SERVER_ERROR".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
                break
        }
    }
}

//MARK: Bottom sheet extension
extension BaseViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func showBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.height
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.addSubview(self.grayScreen)
                self.view.bringSubviewToFront(self.bottomSheet.view)
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .full
            })
        } else {
            self.view.layoutIfNeeded()
            self.state = .full
        }
    }
    
    public func hideBottomSheet(animated: Bool = true) {
        self.topConstraint.constant = -configuration.initialOffset
        
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: [.curveEaseOut],
                           animations: {
                self.grayScreen.removeFromSuperview()
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.state = .initial
                
            })
        } else {
            self.grayScreen.removeFromSuperview()
            self.view.layoutIfNeeded()
            self.state = .initial
        }
    }
    
    private func setupBottomSheet() {
        // 1
        self.addChild(bottomSheet)
        
        // 2
        self.view.addSubview(bottomSheet.view)
        
        // 3
        bottomSheet.topView.addGestureRecognizer(panGesture)
        
        // 4
        bottomSheet.view.translatesAutoresizingMaskIntoConstraints = false
        
        
        // 7
        topConstraint = bottomSheet.view.topAnchor
            .constraint(equalTo: self.view.bottomAnchor,
                        constant: -configuration.initialOffset)
        bottomSheetHeightConstraint = bottomSheet.view.heightAnchor
            .constraint(equalToConstant: configuration.height)
        
        // 8
        NSLayoutConstraint.activate([
            //            bottomSheet.view.heightAnchor
            //                .constraint(equalToConstant: configuration.height),
            bottomSheet.view.leftAnchor
                .constraint(equalTo: self.view.leftAnchor),
            bottomSheet.view.rightAnchor
                .constraint(equalTo: self.view.rightAnchor),
            topConstraint,
            bottomSheetHeightConstraint
        ])
        
        // 9
        bottomSheet.didMove(toParent: self)
        
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: bottomSheet.view)
        let velocity = sender.velocity(in: bottomSheet.view)
        
        let yTranslationMagnitude = translation.y.magnitude
        
        switch sender.state {
            case .began, .changed:
                if self.state == .full {
                    // 1
                    guard translation.y > 0 else { return }
                    
                    // 2
                    topConstraint.constant = -(configuration.height - yTranslationMagnitude)
                    
                    // 3
                    self.view.layoutIfNeeded()
                } else {
                    // 4
                    let newConstant = -(configuration.initialOffset + yTranslationMagnitude)
                    
                    // 5
                    guard translation.y < 0 else { return }
                    
                    // 6
                    guard newConstant.magnitude < configuration.height else {
                        self.showBottomSheet()
                        return
                    }
                    // 7
                    topConstraint.constant = newConstant
                    
                    // 8
                    self.view.layoutIfNeeded()
                }
            case .ended:
                if self.state == .full {
                    // 1
                    if velocity.y < 0 {
                        self.showBottomSheet()
                    } else if yTranslationMagnitude >= configuration.height / 2 || velocity.y > 1000 {
                        // 2
                        self.hideBottomSheet()
                    } else {
                        // 3
                        self.showBottomSheet()
                    }
                } else {
                    // 4
                    if yTranslationMagnitude >= configuration.height / 2 || velocity.y < -1000 {
                        // 5
                        self.showBottomSheet()
                    } else {
                        // 6
                        self.hideBottomSheet()
                    }
                }
            case .failed:
                if self.state == .full {
                    self.showBottomSheet()
                } else {
                    self.hideBottomSheet()
                }
            default: break
        }
    }
    
    func setNewBottomSheetHeight(_ height: CGFloat) {
        bottomSheetHeightConstraint.constant = height
        topConstraint.constant = -height
        configuration = BottomSheetConfiguration(height: height, initialOffset: 0)
    }
    
    func disableBottomSheetDrag() {
        panGesture.isEnabled = false
    }
    
    func enableBottomSheetDrag() {
        panGesture.isEnabled = true
    }
}
