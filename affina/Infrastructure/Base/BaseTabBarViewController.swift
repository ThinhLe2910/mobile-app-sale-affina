//
//  BaseTabBarViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 02/06/2022.
//

import UIKit

enum TabItem: String, CaseIterable {
    case home = "HOME"
    case news = "NEWS"
//    case chat = "CHAT"
    //    case cart = "CART"
    case account = "ACCOUNT"
    
    var viewController: UIViewController {
        switch self {
        case .home:
            return HomeViewController()
        case .news:
            return NewsViewController(nibName: NewsViewController.nib, bundle: nil)
//        case .chat:
//            return ChatBotViewController()
        case .account:
            return ProfileViewController(nibName: ProfileViewController.nib, bundle: nil)
        }
    }
    var icon: UIImage {
        switch self {
        case .home:
            return UIImage(named: "ic_home")!
        case .news:
            return UIImage(named: "ic_news")!
//        case .chat:
//            return UIImage(named: "ic_chat")!
        case .account:
            return UIImage(named: "ic_account")!
        }
    }
    var iconSelected: UIImage {
        switch self {
        case .home:
            return UIImage(named: "ic_home_selected")!
        case .news:
            return UIImage(named: "ic_news_selected")!
//        case .chat:
//            return UIImage(named: "ic_chat_selected")!
        case .account:
            return UIImage(named: "ic_account_selected")!
        }
    }
    
    var displayTitle: String {
        return self.rawValue.localize()
    }
}

class BaseTabBarViewController: UITabBarController {
    var customTabBar: CustomTabBar!
    static let TABBAR_HEIGHT: CGFloat = 70.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTitle), name: NSNotification.Name(Key.changeLocalize.rawValue), object: nil)
    }
    
    func loadTabBar() {
        // Create and load custom tab bar
        let tabbarItems: [TabItem] = [.home, .news/*, .chat*/, /*.cart,*/ .account]
        
        setupCustomTabMenu(tabbarItems, completion: { viewControllers in
            self.viewControllers = viewControllers
        })
        
        selectedIndex = 0 // Set default selected index to first item
        
    }
    
    func setupCustomTabMenu(_ menuItems: [TabItem], completion: @escaping ([UIViewController]) -> Void) {
        let frame = tabBar.frame
        var controllers = [UINavigationController]()
        
        // Hide default tab bar
        tabBar.isHidden = true
        
        // Init custom tab bar
        customTabBar = CustomTabBar(menuItems: menuItems, frame: .init(x: 0, y: UIConstants.Layout.screenHeight - BaseTabBarViewController.TABBAR_HEIGHT + frame.height, width: frame.width, height: BaseTabBarViewController.TABBAR_HEIGHT))
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.clipsToBounds = true
        customTabBar.itemTapped = changeTab(tab:)
        view.addSubview(customTabBar)
        
        // Auto layout for custom tab bar
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(tabBar.frame.width)
            make.height.equalTo(BaseTabBarViewController.TABBAR_HEIGHT)
        }
        
        // Add view controllers
        menuItems.forEach({
            controllers.append(UINavigationController(rootViewController: $0.viewController))
        })
        
        view.layoutIfNeeded()
        completion(controllers)
    }
    
    func changeTab(tab: Int) {
        self.selectedIndex = tab
    }
    
    @objc func reloadTitle() {
        let tabbarItems: [TabItem] = [.home, .news/*, .chat*/, /*.cart,*/ .account]
        for i in 0..<tabbarItems.count {
            customTabBar.updateTitle(i, tabbarItems[i].displayTitle)
        }
    }
    
    
    func showTabBar() {
//        customTabBar.show()
        customTabBar.isHidden = false
    }
    
    func hideTabBar() {
        customTabBar.isHidden = true
//        customTabBar.hide()
    }
}

class CustomTabBar: UIView {
    var itemTapped: ((_ tab: Int) -> Void)?
    var activeItem: Int = 0 {
        didSet {
            AppStateManager.shared.currentTabBar = activeItem
        }
    }
    var items: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(menuItems: [TabItem], frame: CGRect) {
        self.init(frame: frame)
        
        //        if #available(iOS 11.0, *) {
        //            layer.masksToBounds = true
        //            layer.cornerRadius = 32
        //            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        //        } else {
        //            // Fallback on earlier versions
        //            // roundCorners([.topLeft, .topRight], radius: 32)
        //        }
        //        layer.backgroundColor = UIColor.clear.cgColor//.white.cgColor
        
        roundCorners([.topLeft, .topRight], radius: 32)
        
        backgroundColor = .clear // UIColor.appColor(.backgroundGray2)
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.clipsToBounds = true
        stackView.isUserInteractionEnabled = true
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        for index in 0 ..< menuItems.count {
            //            let itemWidth = frame.width / CGFloat(menuItems.count)
            //            let offsetX = itemWidth * CGFloat(index)
            
            let itemView = createTabItem(item: menuItems[index])
            itemView.translatesAutoresizingMaskIntoConstraints = false
            itemView.clipsToBounds = true
            itemView.tag = index
            
            //            addSubview(itemView)
            //            itemView.snp.makeConstraints { make in
            //                make.top.equalToSuperview().offset(UIPadding.size8/2)
            //                make.leading.equalToSuperview().offset(offsetX)
            //                make.height.equalToSuperview()
            //            }
            stackView.addArrangedSubview(itemView)
            items.append(itemView)
        }
        
        
        setNeedsLayout()
        layoutIfNeeded()
        activateTab(tab: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createTabItem(item: TabItem) -> UIView {
        let tabBarItem = UIView()
        tabBarItem.translatesAutoresizingMaskIntoConstraints = false
        tabBarItem.clipsToBounds = true
        tabBarItem.backgroundColor = .clear
        
        let itemTitleLabel = UILabel()
        itemTitleLabel.text = item.displayTitle
        itemTitleLabel.textColor = .appColor(.subText)
        itemTitleLabel.textAlignment = .center
        itemTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        itemTitleLabel.tag = 11
        itemTitleLabel.clipsToBounds = true
        itemTitleLabel.font = UIConstants.Fonts.appFont(.ExtraBold, 10)
        
        let itemImageView = UIImageView()
        itemImageView.tag = 22
        itemImageView.contentMode = .scaleAspectFit
        itemImageView.image = item.icon.withRenderingMode(.alwaysTemplate)
        itemImageView.tintColor = UIColor.appColor(.subText)
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.clipsToBounds = true
        
        tabBarItem.addSubview(itemTitleLabel)
        tabBarItem.addSubview(itemImageView)
        
        // Auto layout cho item title và item icon
        itemImageView.snp.makeConstraints { make in
            make.height.equalTo(24)
            //            make.width.height.equalTo(24)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(UIPadding.size8)
            make.leading.equalToSuperview().offset(UIPadding.size32)
        }
        itemTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(itemImageView.snp_bottom).offset(UIPadding.size8 / 2)
            make.width.equalToSuperview()
            make.height.equalTo(14)
        }
        
        // Tap gesture recognizer for handling tap event
        tabBarItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        return tabBarItem
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        if PopupManager.isShowingPopup { return }
        switchTab(from: activeItem, to: sender.view!.tag)
    }
    
    func switchTab(from: Int, to: Int) {
        deactivateTab(tab: from)
        activateTab(tab: to)
    }
    
    func activateTab(tab: Int) {
        let tabToActivate = (subviews[1] as! UIStackView).arrangedSubviews[tab]
        //        let tabToActivate = subviews[tab + 1]
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            DispatchQueue.main.async {
                tabToActivate.setNeedsLayout()
                tabToActivate.layoutIfNeeded()
                (tabToActivate.viewWithTag(11) as? UILabel)?.textColor = UIColor.appColor(.blueMain)
                (tabToActivate.viewWithTag(22) as? UIImageView)?.tintColor = UIColor.appColor(.blueMain)
                if tab == 0 {
                    (tabToActivate.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_home_selected")
                }
                else if tab == 1 {
                    (tabToActivate.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_news_selected")
                }
//                else if tab == 2 {
//                    (tabToActivate.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_chat_selected")
//                }
                else if tab == 3 {
                    (tabToActivate.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_account_selected")
                }
                
            }
        }, completion: { _ in
            self.itemTapped?(tab)
            self.activeItem = tab
        })
    }
    
    func deactivateTab(tab: Int) {
        let inactiveTab = (subviews[1] as! UIStackView).arrangedSubviews[tab]
        //        let inactiveTab = subviews[tab + 1]
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            DispatchQueue.main.async {
                inactiveTab.setNeedsLayout()
                inactiveTab.layoutIfNeeded()
                (inactiveTab.viewWithTag(11) as? UILabel)?.textColor = UIColor.appColor(.subText)
                (inactiveTab.viewWithTag(22) as? UIImageView)?.tintColor = UIColor.appColor(.subText)
                if tab == 0 {
                    (inactiveTab.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_home")
                }
                else if tab == 1 {
                    (inactiveTab.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_news")
                }
//                else if tab == 2 {
//                    (inactiveTab.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_chat")
//                }
                else if tab == 3 {
                    (inactiveTab.viewWithTag(22) as? UIImageView)?.image = UIImage(named: "ic_account")
                }
            }
        }, completion: { _ in
            
        })
        
    }
    
    func updateTitle(_ index: Int, _ title: String) {
        (items[index].viewWithTag(11) as? UILabel)?.text = title
    }
}
