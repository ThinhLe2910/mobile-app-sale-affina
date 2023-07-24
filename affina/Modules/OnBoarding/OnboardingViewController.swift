//
//  OnboardingViewController.swift
//  affina
//
//  Created by Intelin MacHD on 29/09/2022.
//

import UIKit
import SnapKit

class OnboardingViewController: UIPageViewController {
    
    var index = 0 {
        didSet {
            if index == controllers.count - 1 {
                skipButton.setTitle("LATER".localize(), for: .normal)
            } else {
                skipButton.setTitle("SKIP".localize(), for: .normal)
            }
        }
    }
    var preIndex = 0
    var controllers = [OnboardingChildViewController()]
    var pageControl: UICollectionView
    let layout = UICollectionViewFlowLayout()
    
    let skipButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("SKIP".localize().capitalizingFirstLetter(), for: .normal)
        btn.titleLabel?.font = UIConstants.Fonts.appFont(.Semibold, 16)
        btn.backgroundAsset = "clear"
        btn.colorAsset = "blueDark"
        return btn
    }()
    
    let nextButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle("CONTINUE".localize().capitalizingFirstLetter(), for: .normal)
        btn.titleLabel?.font = UIConstants.Fonts.appFont(.Bold, 16)
        btn.backgroundAsset = "clear"
        btn.colorAsset = "blueDark"
        return btn
    }()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 16, height: 4)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        pageControl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }
    
    required init?(coder: NSCoder) {
        layout.scrollDirection = .horizontal
        
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        pageControl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        initView()
        setupPageViewController()
        setupViewIndicator()
        setupButton()
    }
    
    func initView() {
        view.backgroundColor = UIColor(hex: "#E6EFFF")
    }
    
    func setupPageViewController() {
        //Setup intro pages
        let page1 = OnboardingChildViewController(nibName: "OnboardingChildViewController", bundle: nil)
        page1.topLabelText = "100_ONLINE".localize()
        page1.bottomLabelText = "ONECLICK_ONLINE_REGISTER_IN".localize()
        page1.imageVar = UIImage(named: "onboarding-1") ?? UIImage()
        
        let page2 = OnboardingChildViewController(nibName: "OnboardingChildViewController", bundle: nil)
        page2.topLabelText = "SIMPLE_PROCESS".localize()
        page2.bottomLabelText = "NO_MEDICAL_DECLARATION_IS".localize()
        page2.imageVar = UIImage(named: "onboarding-2") ?? UIImage()
        
        let page3 = OnboardingChildViewController(nibName: "OnboardingChildViewController", bundle: nil)
        page3.topLabelText = "INDEPENDENT_PARTICIPATION".localize()
        page3.bottomLabelText = "CHILDREN_FROM_30DAY_OLD".localize()
        page3.imageVar = UIImage(named: "onboarding-3") ?? UIImage()
        
        let page4 = OnboardingChildViewController(nibName: "OnboardingChildViewController", bundle: nil)
        page4.topLabelText = "COMMIT".localize()
        page4.bottomLabelText = "ALWAYS_BE_WITH_YOU".localize()
        page4.imageVar = UIImage(named: "onboarding-4") ?? UIImage()
        
        let page5 = OnboardingChildViewController(nibName: "OnboardingChildViewController", bundle: nil)
        page5.topLabelText = "LOG_IN_NOW".localize()
        page5.bottomLabelText = "DO_NOT_MISS_ATTRACTIVE".localize()
        page5.imageVar = UIImage(named: "onboarding-5") ?? UIImage()
        
        controllers = [page1,page2,page3,page4,page5]
        
        // Setup PageViewController
        if let firstViewController = controllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func setupViewIndicator() {
        //Setup view indicator
        pageControl.delegate = self
        pageControl.dataSource = self
        pageControl.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        pageControl.backgroundColor = .clear
        pageControl.isScrollEnabled = false
        
        self.view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).inset(80.height)
//            make.leading.trailing.equalToSuperview().inset(161)
            make.width.equalTo(36 + 4*4 + 4*4)
            make.centerX.equalTo(self.view.snp_centerX)
            make.height.greaterThanOrEqualTo(4)
        }
    }
    
    func setupButton() {
        // Setup button
        self.view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).inset(55)
            make.right.equalTo(self.view.snp_right).inset(32)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        nextButton.addTarget(self, action: #selector(toNext), for: .touchUpInside)
        
        self.view.addSubview(skipButton)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).inset(55)
            make.left.equalTo(self.view.snp_left).inset(32)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        skipButton.addTarget(self, action: #selector(toSkip), for: .touchUpInside)
    }
    
    @objc func toNext() {
        if index < controllers.count - 1 {
            self.preIndex = self.index
            index += 1
            self.goToNextPage()
            self.pageControl.reloadData()
            
        } else {
            //toSkip()
            UserDefaults.standard.set(true, forKey: Key.firstInstalled.rawValue)
            UIConstants.isInitHomeView = true
            UIConstants.requireLogin = true
            let baseVC = BaseTabBarViewController()
            let nav = UINavigationController(rootViewController: baseVC)
            nav.isNavigationBarHidden = true
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
            nav.view.backgroundColor = .clear
            kAppDelegate.window?.rootViewController = nav
            kAppDelegate.window?.makeKeyAndVisible()
        }
    }
    
    @objc func toSkip() {
        if index != controllers.count - 1 {
            self.preIndex = controllers.count - 2
            index = controllers.count - 1
            setViewControllers([controllers[index]], direction: .forward, animated: true)
            self.pageControl.reloadData()
            
            return
        }
        
        UserDefaults.standard.set(true, forKey: Key.firstInstalled.rawValue)
        UIConstants.isInitHomeView = true
        let nav = UINavigationController(rootViewController: BaseTabBarViewController())
        nav.isNavigationBarHidden = true
        nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nav.navigationBar.shadowImage = UIImage()
        nav.navigationBar.isTranslucent = true
        nav.view.backgroundColor = .clear
        kAppDelegate.window?.rootViewController = nav
        kAppDelegate.window?.makeKeyAndVisible()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.controllers.firstIndex(of: viewController as! OnboardingChildViewController) {
            if viewControllerIndex < self.controllers.count - 1 {
                // go to next page in array
                return self.controllers[viewControllerIndex + 1]
            } else {
                
                return nil
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewControllerIndex = self.controllers.firstIndex(of: viewController as! OnboardingChildViewController) {
            if viewControllerIndex == 0 {
                // wrap to last page in array
                return nil
            } else {
                // go to previous page in array
                return self.controllers[viewControllerIndex - 1]
            }
        }
        return nil
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let viewControllers = pageViewController.viewControllers {
            if let viewControllerIndex = self.controllers.firstIndex(of: viewControllers[0] as! OnboardingChildViewController) {
                self.preIndex = self.index
                self.index = viewControllerIndex
                self.pageControl.reloadData()
//                if viewControllerIndex == controllers.count - 1 {
//                    roundButton.removeFromSuperview()
//                    self.view.addSubview(button)
//                    button.snp.makeConstraints { (make) in
//                        make.bottom.equalTo(self.view.snp_bottom).inset(34)
//                        make.right.equalTo(self.view.snp_right).inset(16)
//                        make.width.equalTo(116)
//                        make.height.equalTo(48)
//                    }
//                }
//                if index == 1 && preIndex == 2 {
//                    button.removeFromSuperview()
//                    self.view.addSubview(roundButton)
//                    roundButton.snp.makeConstraints { (make) in
//                        make.bottom.equalTo(self.view.snp_bottom).inset(34)
//                        make.right.equalTo(self.view.snp_right).inset(16)
//                        make.width.equalTo(116)
//                        make.height.equalTo(48)
//                    }
//                }
            }
        }
    }
}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        controllers.count
    }
    func numberOfSections(inOnboardingViewController collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.contentView.removeFromSuperview()
        cell.layer.cornerRadius = 2
        let index = indexPath.row
        if index == self.index {
            cell.backgroundColor = UIColor(hex: "#074BC9")
        } else {
            cell.backgroundColor = UIColor(hex: "#9DBFFE")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = indexPath.row
        if index == self.index {
            return CGSize(width: 36, height: 4)
        } else {
            return CGSize(width: 4, height: 4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}

