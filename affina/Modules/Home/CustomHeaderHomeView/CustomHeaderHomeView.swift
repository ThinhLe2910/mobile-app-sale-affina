//
//  CustomHeaderHomeView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 10/06/2022.
//

import UIKit

protocol CustomHeaderHomeViewDelegate: AnyObject {
    func didTapLoginButton()
    func didTapSearchButton()
    func didTapNoticeButton()
}

class CustomHeaderHomeView: UIView {
    static let nib = "CustomHeaderHomeView"

    class func instanceFromNib() -> CustomHeaderHomeView {
        return UINib(nibName: CustomHeaderHomeView.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomHeaderHomeView
    }

    @IBOutlet weak var searchButton: BaseButton!
    @IBOutlet weak var accountButton: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarView: BaseView!
    @IBOutlet weak var noticeButton: BaseButton!
    @IBOutlet weak var avatarBg: BaseView!
    @IBOutlet weak var userLabel: BaseLabel!
//    @IBOutlet weak var logginButton: BaseLabel!
    @IBOutlet weak var pointLabel: BaseLabel!
    @IBOutlet weak var notiBadgeIcon: UIImageView!
    @IBOutlet weak var underlineWidth: NSLayoutConstraint!
    
    var delegate: CustomHeaderHomeViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

//        pointLabel.addUnderline()

        accountButton.image = accountButton.image?.withRenderingMode(.alwaysTemplate)
        accountButton.tintColor = .appColor(.pinkLighter2)

        avatarBg.applyGradientLayer(colors: [UIColor(red: 1, green: 1, blue: 1, alpha: 0.65),
                                             UIColor(red: 1, green: 1, blue: 1, alpha: 0.45)], locations: [0, 1])

        let searchImg = UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate)
        searchButton.setBackgroundImage(searchImg, for: .normal)
        searchButton.tintColor = UIColor.appColor(.black)
        let bellImg = UIImage(named: "ic_bell")?.withRenderingMode(.alwaysTemplate)
        noticeButton.setBackgroundImage(bellImg, for: .normal)
        noticeButton.tintColor = UIColor.appColor(.black)

        pointLabel.addTapGestureRecognizer {
            if !UIConstants.isLoggedIn {
                self.delegate?.didTapLoginButton()
            }
        }

        searchButton.addTapGestureRecognizer {
            self.delegate?.didTapSearchButton()
        }

        noticeButton.addTapGestureRecognizer {
            self.delegate?.didTapNoticeButton()
        }

        accountButton.addTapGestureRecognizer {
            
        }

    }

    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }

    func updateUI() {
        DispatchQueue.main.async {
            self.userLabel.text = "\(UserDefaults.standard.string(forKey: Key.customerName.rawValue) ?? "")"
//            self.userLabel.text = "User #\(UserDefaults.standard.string(forKey: Key.customerName.rawValue) ?? "")"
            self.userLabel.font = UIConstants.Fonts.appFont(.Bold, 14)
            self.pointLabel.font = UIConstants.Fonts.appFont(.Regular, 12)
            
//            self.pointLabel.hide() // TODO:
            
            self.pointLabel.removeUnderline()
            let normalText = "MEMBER_POINT".localize() + ": "
            let boldText = "\(Int(AppStateManager.shared.userCoin).addComma()) \("COIN".localize())"
//            let attrs = [
//                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 12),
//                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue
//            ] as [NSAttributedString.Key: Any]
            let attrs = [
                NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 12)
            ] as [NSAttributedString.Key: Any]
            let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
            self.underlineWidth.constant = attributedString.size().width
            let normalString = NSMutableAttributedString(string: normalText)
            attributedString.insert(normalString, at: 0)
            //            self.logginButton.attributedText = self.attributedText(withString: String(format: "MEMBER_POINT".localize() + ": %@", "0 điểm"), boldString: "0 điểm", font: self.logginButton.font) // attributedString
            self.pointLabel.attributedText = attributedString
        }
        if CacheManager.shared.isExistCacheWithKey(Key.profile.rawValue) {
            ParseCache.parseCacheToItem(key: Key.profile.rawValue, modelType: ProfileModel.self) { result in
                switch result {
                case .success(let profile):
                    self.updateAvatar(profile: profile)
                case .failure(let error):
                    Logger.Logs(event: .error, message: error.localizedDescription)
                }
            }
        }
    }

    func showGuestState() {
        self.userLabel.text = "WELLCOME_TO_AFFINA".localize()
        self.userLabel.font = UIConstants.Fonts.appFont(.Regular, 15)
//        self.pointLabel.addUnderline()
        self.pointLabel.font = UIConstants.Fonts.appFont(.Semibold, 13)
        self.pointLabel.text = "PLEASE_LOGIN_HERE".localize()
        
        self.pointLabel.show() // TODO:
        
        self.accountButton.show()
        self.avatarView.hide()
        self.avatarImageView.image = nil
        self.underlineWidth.constant = "PLEASE_LOGIN_HERE".localize().widthOfString(usingFont: UIConstants.Fonts.appFont(.Semibold, 13))
    }
    
    private func updateAvatar(profile: ProfileModel) {
        guard let avatar = profile.avatar, let url = URL(string: API.STATIC_RESOURCE + avatar) else {
            self.avatarImageView.image = nil
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
                self.accountButton.hide()
                self.avatarImageView.image = UIConstants.isLoggedIn ? image : nil
                self.avatarView.show()
//                self.avatarImageView.transform = CGAffineTransform(scaleX: 3, y: 3)
            }
        }
    }
    
    func showBadgeNoti() {
        notiBadgeIcon.isHidden = false
    }
    
    func hideBadgeNoti() {
        notiBadgeIcon.isHidden = true
    }
    
//    private func initViews() {
//
////        addTapGestureRecognizer {
////            self.searchBar.resignFirstResponder()
////        }
//
////        searchBar.delegate = self
//
////        searchBar.addTapGestureRecognizer {
////            print("ASdASD")
////        }
//    }
}

//extension CustomHeaderHomeView: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        return true
//    }
//}
