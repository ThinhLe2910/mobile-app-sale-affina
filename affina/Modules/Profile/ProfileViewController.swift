//
//  ProfileViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 16/05/2022.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    static let nib = "ProfileViewController"
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var avatarButton: BaseView!
    @IBOutlet weak var defaultImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarView: BaseView!
    @IBOutlet weak var logOutButton: BaseLabel!
    @IBOutlet weak var languageButton: BaseButton!
    @IBOutlet weak var usernameLabel: BaseLabel!
    @IBOutlet weak var pointLabel: BaseLabel!
    @IBOutlet weak var languageButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineWidth: NSLayoutConstraint!
    @IBOutlet weak var versionLabel: UILabel!
    
    private var sections = [
        "ACCOUNT_SETTINGS".localize(),
        "SERVICE".localize(),
        "SYSTEM".localize()
    ]
    
    private var items = [
        [
            ProfileSettingModel(icon: "ic_account", label: "PERSONAL_INFORMATION".localize()),
//            ProfileSettingModel(icon: "ic_bell", label: "NOTIFICATION".localize()),
//            ProfileSettingModel(icon: "ic_lock_profile", label: "SECURITY_SETTINGS".localize())
        ],
        [
            ProfileSettingModel(icon: "ic_insurance_shield", label: "INSURANCE_CARD".localize()),
            ProfileSettingModel(icon: "ic_contract", label: "INSURANCE_CONTRACT".localize())
            //            ProfileSettingModel(icon: "ic_medicine", label: "MEDICAL_HISTORY".localize()),
            //            ProfileSettingModel(icon: "ic_box", label: "ORDER".localize()),
            //            ProfileSettingModel(icon: "ic_coin", label: "SALARY_ADVANCEMENT_HISTORY".localize())
        ],
        [
            ProfileSettingModel(icon: "ic_terms", label: "TERMS_OF_SERVICE".localize()),
            ProfileSettingModel(icon: "ic_privacy", label: "PRIVACY_POLICIES".localize())
            //            ProfileSettingModel(icon: "ic_affiliate", label: "REFER_FRIENDS".localize())
        ]
    ]
    
    private let imagePicker = UIImagePickerController()
    
    private let imageSubmit = UIImageView()
    
    private var userProfile: ProfileModel?
    
    private let presenter = ProfileViewPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        presenter.setViewDelegate(delegate: self)
        
        setupActions()
    }
    
    private func setupViews() {
        
        hideHeaderBase()
        containerBaseView.hide()
        
        logOutButton.addUnderline()
        languageButton.borderColor = "grayBorder"
        setTitleLanguageButton()
        
        reloadTitle()
        
        view.backgroundColor = .appColor(.backgroundLightGray)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ProfileSettingTableViewCell.nib, bundle: nil), forCellReuseIdentifier: ProfileSettingTableViewCell.cellId)
        
        
        imagePicker.delegate = self
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionLabel.text = "Version " + (appVersion ?? "")
        versionLabel.font = UIConstants.Fonts.appFont(.Semibold, 14)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.showTabBar()
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
        
        if UIConstants.isLoggedIn, !CacheManager.shared.isExistCacheWithKey(Key.profile.rawValue), let token = UserDefaults.standard.string(forKey: Key.token.rawValue), !token.isEmpty {
            presenter.getProfile()
        }
        
        if UIConstants.isBanned {
            UIConstants.isBanned = false
            let tabBar = tabBarController as? BaseTabBarViewController
            tabBar?.customTabBar.switchTab(from: tabBar?.customTabBar.activeItem ?? 0, to: 0)
            tabBar?.changeTab(tab: 0)
        }
    }
    
    private func setupActions() {
        pointLabel.addTapGestureRecognizer {
            if !UIConstants.isLoggedIn {
                let notFirstTimeLogin = UserDefaults.standard.bool(forKey: Key.notFirstTimeLogin.rawValue)
                if !notFirstTimeLogin {
                    let vc = UINavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
                    self.presentInFullScreen(vc, animated: true, completion: nil)
                }
                else {
                    let vc = UINavigationController(rootViewController: InputPinCodeViewController(nibName: InputPinCodeViewController.nib, bundle: nil))
                    self.presentInFullScreen(vc, animated: true, completion: nil)
                }
            }
        }
        
        logOutButton.addTapGestureRecognizer {
            self.logOut()
            
            let tabBar = self.tabBarController as? BaseTabBarViewController
            tabBar?.customTabBar.switchTab(from: tabBar?.customTabBar.activeItem ?? 0, to: 0)
            tabBar?.changeTab(tab: 0)
            
            self.defaultImageView.show()
            self.avatarView.hide()
            self.avatarImageView.image = nil
            
            self.updateUI()
            
            self.usernameLabel.text = "CUSTOMER".localize()
            self.pointLabel.font = UIConstants.Fonts.appFont(.Semibold, 14)
//            self.pointLabel.addUnderline()
            self.pointLabel.text = "PLEASE_LOGIN_HERE".localize()
            self.underlineWidth.constant = "PLEASE_LOGIN_HERE".localize().widthOfString(usingFont: UIConstants.Fonts.appFont(.Semibold, 14))
        }
        
        avatarButton.addTapGestureRecognizer {
            self.showPhotoOptions()
        }
        
        languageButton.addTarget(self, action: #selector(didTapLanguageButton), for: .touchUpInside)
    }
    
    private func showPhotoOptions() {
        if UIConstants.isLoggedIn {
            AlertService.showAlert(style: .actionSheet, title: nil, message: nil, actions: [
                UIAlertAction(title: "TAKE_PHOTO".localize(), style: .default, handler: { _ in
                    self.imagePicker.sourceType = .camera
                    self.present(self.imagePicker, animated: true, completion: nil)
                }),
                UIAlertAction(title: "CHOOSE_PHOTOS_FROM_DEVICE".localize(), style: .default, handler: { _ in
                    self.imagePicker.sourceType = .photoLibrary
                    self.present(self.imagePicker, animated: true, completion: nil)
                }),
                UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { _ in
                    
                })], completion: {
                    
                })
        }
    }
    
    private func updateUI() {
        logOutButton.isHidden = !UIConstants.isLoggedIn
        if !UIConstants.isLoggedIn {
            languageButtonTrailingConstraint.constant = UIConstants.Layout.screenWidth / 2 - 112 / 2
            
            self.pointLabel.show() // TODO:
//            pointLabel.addUnderline()
            self.underlineWidth.constant = "PLEASE_LOGIN_HERE".localize().widthOfString(usingFont: UIConstants.Fonts.appFont(.Semibold, 14))
            
            avatarImageView.image = nil
            defaultImageView.show()
            avatarView.hide()
            reloadTitle()
        }
        else {
            languageButtonTrailingConstraint.constant = 16
            var height: CGFloat = 0
            for i in 0..<sections.count {
                height += CGFloat(50 * (items[i].count + 1))
            }
            //            usernameLabel.text = "User #\(UserDefaults.standard.string(forKey: Key.customerName.rawValue) ?? "")"
            usernameLabel.text = "\(UserDefaults.standard.string(forKey: Key.customerName.rawValue) ?? "")"
            
            updatePointLabel()
            
            ParseCache.parseCacheToItem(key: Key.profile.rawValue, modelType: ProfileModel.self) { result in
                switch result {
                    case .success(let profile):
                        self.userProfile = profile
                        self.updateAvatar(profile: profile)
                    case .failure(let error):
                        Logger.Logs(event: .error, message: error)
                }
            }
        }
        view.setNeedsLayout()
        tableView.reloadData()
    }
    
    private func updateAvatar(profile: ProfileModel) {
        guard let avatar = profile.avatar, let url = URL(string: API.STATIC_RESOURCE + avatar) else {
            self.avatarImageView.image = nil
            self.defaultImageView.show()
            self.avatarView.hide()
            return
        }
        CacheManager.shared.imageFor(url: url) { [weak self] image, error in
            guard let self = self, let image = image, error == nil else {
                DispatchQueue.main.async {
                    self?.avatarImageView.image = UIImage(named: "placeholder")
                }
                Logger.Logs(event: .error, message: error.debugDescription)
                return
            }
            
            DispatchQueue.main.async {
                self.defaultImageView.hide()
                self.avatarImageView.image = image
                self.avatarView.show()
                //                self.avatarImageView.transform = CGAffineTransform(scaleX: 3, y: 3)
            }
        }
    }
    
    private func updatePointLabel() {
        
//        self.pointLabel.hide() // TODO:
        
        self.pointLabel.font = UIConstants.Fonts.appFont(.Regular, 14)
        self.pointLabel.removeUnderline()
        let normalText = "MEMBER_POINT".localize() + ": "
        let boldText = "\(Int(AppStateManager.shared.userCoin).addComma()) Xu"
        let attrs = [NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Semibold, 14)] as [NSAttributedString.Key: Any]
        let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
        self.underlineWidth.constant = attributedString.size().width
        let normalString = NSMutableAttributedString(string: normalText)
        attributedString.insert(normalString, at: 0)
        self.pointLabel.attributedText = attributedString
    }
    
    @objc private func didTapLanguageButton() {
        UIConstants.isVietnamese.toggle()
        setTitleLanguageButton()
        NotificationCenter.default.post(name: NSNotification.Name(Key.changeLocalize.rawValue), object: nil)
        reloadTitle()
    }
    
    private func setTitleLanguageButton() {
        if UIConstants.isVietnamese {
            languageButton.setImage(UIImage(named: "ic_eng"), for: .normal)
            languageButton.localizeTitle = "English"
        }
        else {
            languageButton.setImage(UIImage(named: "ic_flag"), for: .normal)
            languageButton.localizeTitle = "VIETNAMESE".localize()
        }
        languageButton.sizeToFit()
    }
    
    private func reloadTitle() {
        if !UIConstants.isLoggedIn {
            usernameLabel.text = "CUSTOMER".localize()
            pointLabel.text = "PLEASE_LOGIN_HERE".localize()
            self.underlineWidth.constant = "PLEASE_LOGIN_HERE".localize().widthOfString(usingFont: UIConstants.Fonts.appFont(.Semibold, 14))
            
        }
        sections = [
            "ACCOUNT_SETTINGS".localize(),
            "SERVICE".localize(),
            "SYSTEM".localize()
        ]
        
        items = [
            [
                ProfileSettingModel(icon: "ic_account", label: "PERSONAL_INFORMATION".localize())
            ],
            [
                ProfileSettingModel(icon: "ic_insurance_shield", label: "INSURANCE_CARD".localize()),
                ProfileSettingModel(icon: "ic_contract", label: "INSURANCE_CONTRACT".localize())
            ],
            [
                ProfileSettingModel(icon: "ic_terms", label: "TERMS_OF_SERVICE".localize()),
                ProfileSettingModel(icon: "ic_privacy", label: "PRIVACY_POLICIES".localize())
            ]
        ]
        
        setTitleLanguageButton()
        
        tableView.reloadData()
        
        logOutButton.localizeText = "LOG_OUT".localize()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !UIConstants.isLoggedIn {
            return 1
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = BaseLabel(frame: .init(x: 16, y: 0, width: 200, height: 50))
        label.text = !UIConstants.isLoggedIn ? sections[2] : sections[section]
        label.font = UIConstants.Fonts.appFont(.Bold, 20)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !UIConstants.isLoggedIn {
            return items[2].count
        }
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSettingTableViewCell.cellId, for: indexPath) as? ProfileSettingTableViewCell else {
            return UITableViewCell()
        }
        if !UIConstants.isLoggedIn {
            cell.item = items[2][indexPath.row]
        }
        else {
            cell.item = items[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if UIConstants.isLoggedIn {
            switch indexPath.section {
                case 0:
                    switch indexPath.row {
                        case 0:
                            let vc = ChangePersonalInforViewController(nibName: ChangePersonalInforViewController.nib, bundle: nil)
                            navigationController?.pushViewController(vc, animated: true)
                        case 1:
                            let vc = NotiSettingsViewController(nibName: NotiSettingsViewController.nib, bundle: nil)
                            navigationController?.pushViewController(vc, animated: true)
                        case 2:
                            let vc = SecuritySettingsViewController(nibName: SecuritySettingsViewController.nib, bundle: nil)
                            navigationController?.pushViewController(vc, animated: true)
                        default:
                            break
                    }
                case 1:
                    switch indexPath.row {
                        case 0:
                            let vc = CardViewController()
                            navigationController?.pushViewController(vc, animated: true)
                            break
                        case 1:
                            let vc = ContractViewController(nibName: ContractViewController.nib, bundle: nil)
                            navigationController?.pushViewController(vc, animated: true)
                            break
                        default:
                            //                    let vc = UIViewController()
                            //                    navigationController?.pushViewController(vc, animated: true)
                            break
                    }
                case 2:
                    switch indexPath.row {
                        case 0:
                            let vc = WebViewController()
                            vc.setUrl(url: "https://affina.com.vn/dieu-khoan-kieu-kien")
                            navigationController?.pushViewController(vc, animated: true)
                        case 1:
                            let vc = WebViewController()
                            vc.setUrl(url: "https://affina.com.vn/chinh-sach-bao-mat")
                            navigationController?.pushViewController(vc, animated: true)
                            //                case 2:
                            //                    let vc = UIViewController()
                            //                    navigationController?.pushViewController(vc, animated: true)
                        default:
                            break
                    }
                default:
                    break
            }
        }
        else {
            switch indexPath.row {
                case 0:
                    let vc = WebViewController()
                    vc.setUrl(url: "https://affina.com.vn/dieu-khoan-kieu-kien")
                    navigationController?.pushViewController(vc, animated: true)
                case 1:
                    let vc = WebViewController()
                    vc.setUrl(url: "https://affina.com.vn/chinh-sach-bao-mat")
                    navigationController?.pushViewController(vc, animated: true)
                    //                case 2:
                    //                    let vc = UIViewController()
                    //                    navigationController?.pushViewController(vc, animated: true)
                default:
                    break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0, 1, 2:
                if indexPath.row == items[indexPath.section].count - 1 {
                    return 55
                }
                return 45
            default:
                return 45
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
    
    func convertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        imageSubmit.image = image
        self.imagePicker.allowsEditing = false
        if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        {
            image = img
            
        }
        else if let img = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage
        {
            image = img
        }
        presenter.uploadImage(image: image)
        picker.dismiss(animated: true, completion: {
            self.lockUI()
        })
    }
    
    //Cancel pick image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: UINavigationControllerDelegate {
    
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (key.rawValue, value) })
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

extension ProfileViewController: ProfileViewDelegate {
    func lockUI() {
        lockScreen()
    }
    
    func unLockUI() {
        unlockScreen()
    }
    
    func updateUI(profile: ProfileModel) {
        userProfile = profile
        updateAvatar(profile: profile)
        updateUI()
    }
    
    func updateRelatives(relatives: [RelativeModel]) {
        
    }
    
    func showAlert() {
        
    }
    
    func showError(error: ApiError) {
        switch error {
            case .expired:
                logOut()
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "ERROR".localize(), desc: "ACCOUNT_HAVE_BEEN_BLOCKED".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                    let tabBar = self.tabBarController as? BaseTabBarViewController
                    tabBar?.customTabBar.switchTab(from: tabBar?.customTabBar.activeItem ?? 0, to: 0)
                    tabBar?.changeTab(tab: 0)
                } handler: {
                    
                }
            case .requestTimeout(let error):
                queueBasePopup(icon: UIImage(named: "ic_close_circle"), title: "Timeout".localize(), desc: "".localize(), okTitle: "GOT_IT".localize(), cancelTitle: "", textColors: [UIColor.appColor(.redError)!, UIColor.appColor(.black)!]) {
                    self.hideBasePopup()
                } handler: {
                    
                }
            default:
                break
        }
    }
    
    func updateSuccess() {
        queueBasePopup(icon: UIImage(named: "ic_check_circle"), title: "NOTIFICATION".localize(), desc: "UPDATE_PROFILE_SUCCESS".localize(), okTitle: "CLOSE".localize(), cancelTitle: "") {
            self.hideBasePopup()
        } handler: {
            
        }
        presenter.getProfile()
    }
    
    func uploadImageSuccess(link: String) {
        var dict: [String: Any] = [:]
        dict["avatar"] = link
        presenter.updateProfile(dict: dict)
    }
    
    
}
