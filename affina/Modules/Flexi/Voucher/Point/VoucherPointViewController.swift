//
//  VoucherPointViewController.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import SnapKit

class VoucherPointViewController: BaseViewController {
    
    @IBOutlet weak var myVoucherLabel: BaseLabel!
    @IBOutlet weak var loginLabel: BaseLabel!
    @IBOutlet weak var pointLevel: BaseLabel!
    
    @IBOutlet weak var categoryView: BaseView!
    
    @IBOutlet weak var myVouchersLabel: BaseLabel!
    @IBOutlet weak var membershipLevelsLabel: BaseLabel!
    private lazy var categoryCollectionView: BaseCollectionView<PointCategoryCollectionViewCell, VoucherCategoryModel> = {
        let view = BaseCollectionView<PointCategoryCollectionViewCell, VoucherCategoryModel>()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 78, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 24, bottom: 5, right: 24)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        view.showsHorizontalScrollIndicator = false
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: PointCategoryCollectionViewCell.nib)
        return view
    }()
    
    @IBOutlet weak var stateView: BaseView!
    
    @IBOutlet weak var levelView: UIStackView!
    @IBOutlet weak var vouchersView: UIStackView!
    @IBOutlet weak var separator: BaseView!
    @IBOutlet weak var loginView: UIStackView!
    
    
    @IBOutlet weak var specialVoucherView: BaseView!
    @IBOutlet weak var forYouVoucherView: BaseView!
    @IBOutlet weak var popularVoucherView: BaseView!
    
    private lazy var specialVoucherCollectionView: PointVoucherBigView = {
        let view = PointVoucherBigView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollDirection = .horizontal
        view.sectionInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        view.buyCallBack = { model in
            let vc = VoucherDetailViewController()
            vc.voucherDetailType = .notMine
            vc.voucherId = model.voucherId ?? ""
            vc.providerId = model.providerId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.viewMoreCallback = {
            let vc = VoucherItemListViewController(nibName: VoucherItemListViewController.nib, bundle: nil)
            vc.type = .USE_POINT_SPECIAL_VOUCHER
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return view
    }()
    
    private lazy var promotionProductView: PointVoucherView = {
        let view = PointVoucherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollDirection = .horizontal
        view.sectionInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        view.buyCallBack = { model in
            let vc = VoucherDetailViewController()
            vc.voucherDetailType = .notMine
            vc.voucherId = model.voucherId ?? ""
            vc.providerId = model.providerId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.viewMoreCallback = {
            let vc = VoucherItemListViewController(nibName: VoucherItemListViewController.nib, bundle: nil)
            vc.type = .USE_POINT_VOUCHER_FOR_U
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return view
    }()
    
    private lazy var bestSellerProductView: PointVoucherView = {
        let view = PointVoucherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollDirection = .vertical
        view.buyCallBack = { model in
            let vc = VoucherDetailViewController()
            vc.voucherDetailType = .notMine
            vc.voucherId = model.voucherId ?? ""
            vc.providerId = model.providerId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.isScrollEnabled = false
        return view
    }()
    
    private var bestSellerHeightConstraint: Constraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    private let presenter = VoucherPointViewDelegate()
    
    private var summaryModel: VoucherSummaryModel?
    
    var viewType: FlexiCategoryViewType = .voucher
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabel()
        containerBaseView.hide()
        setupHeaderView()
        
        view.backgroundColor = UIColor.appColor(.backgroundLightGray)
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        setupCategoriesCollectionView()
        
        
        let pointText = "20.000 "
        let attrs = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: pointText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: "xu")
        attributedString.append(normalString)
        pointLevel.attributedText = attributedString
        
        let voucherText = "20.000 "
        let attrs2 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 20)
        ] as [NSAttributedString.Key : Any]
        let attributedString2 = NSMutableAttributedString(string: voucherText, attributes: attrs2)
        let normalString2 = NSMutableAttributedString(string: "VOUCHER_TO_EXPIRE".localize().capitalized)
        attributedString2.append(normalString2)
        
        pointLevel.attributedText = attributedString
        myVoucherLabel.attributedText = attributedString2
        
        specialVoucherView.addSubview(specialVoucherCollectionView)
        specialVoucherCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(-UIPadding.size24)
        }
        specialVoucherCollectionView.delegate = self
        specialVoucherCollectionView.setData(items: [], title: "SPECIAL_OFFER".localize().capitalized)
        
        forYouVoucherView.addSubview(promotionProductView)
        promotionProductView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(-UIPadding.size24)
        }
        promotionProductView.delegate = self
        promotionProductView.setData(items: [], title: "DEALS_FOR_YOU".localize(), viewType: viewType)
        
        popularVoucherView.addSubview(bestSellerProductView)
        bestSellerProductView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            bestSellerHeightConstraint = make.height.equalTo(200).constraint
        }
        bestSellerProductView.delegate = self
        bestSellerProductView.setData(items: [], title: "POPULAR_PRODUCT".localize(), viewType: viewType)
        
        presenter.delegate = self
        
        levelView.addTapGestureRecognizer { [weak self] in
            let vc = RewardHistoryViewController()
            vc.point = self?.summaryModel?.coin ?? 0
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        vouchersView.addTapGestureRecognizer {
            let vc = VoucherListViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        loginLabel.addTapGestureRecognizer {
            let vc = UINavigationController(rootViewController: WelcomeViewController(nibName: WelcomeViewController.nib, bundle: nil))
            self.presentInFullScreen(vc, animated: true, completion: nil)
        }
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    private func fetchData() {
        presenter.getVoucherSummary()
        
        presenter.getListCategory()
        
        presenter.getListVoucherAt(from: 0, limit: 10, showAt: .USE_POINT_SPECIAL_VOUCHER)
        presenter.getListVoucherAt(from: 0, limit: 10, showAt: .USE_POINT_VOUCHER_FOR_U)
        presenter.getListVoucherAt(from: 0, limit: 10, showAt: .USE_POINT_POPULAR_PRODUCT)
        
    }
    private func setupLabel(){
        membershipLevelsLabel.text = "MEMBERSHIP_LEVELS".localize().capitalized
        myVouchersLabel.text = "MY_VOUCHERS".localize().capitalized
    }
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.text = "USE_COINS".localize().capitalized
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        rightBaseImage.image = UIImage(named: "ic_search_black") // ?.withRenderingMode(.alwaysTemplate)
                                                                 //        rightBaseImage.tintColor = .appColor(.textBlack)
        rightBaseImage.addTapGestureRecognizer {
            
        }
        rightBaseImage.isHidden = true
    }
    
    private func setupCategoriesCollectionView() {
        categoryView.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(-UIPadding.size24)
        }
        
        categoryCollectionView.items = []
        
        categoryCollectionView.setDidSelectItemHandler { item in
            Logger.Logs(message: item)
            let vc = FlexiCategoriesViewController()
            vc.categoryId = item.categoryID ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        categoryCollectionView.reloadData()
        
    }
    
    private func updateUI() {
        if !UIConstants.isLoggedIn {
            loginLabel.addUnderline()
            loginView.show()
            vouchersView.hide(isImmediate: true)
            levelView.hide(isImmediate: true)
            separator.hide(isImmediate: true)
            stateView.cornerRadius = 32
        }
        else {
            loginView.hide(isImmediate: true)
            vouchersView.show()
            levelView.show()
            separator.show()
            stateView.cornerRadius = 20
        }
        
        guard let summaryModel = summaryModel else { return }
        pointLevel.attributedText = getAttributedString(arrayTexts: [
            "\(Int(AppStateManager.shared.userCoin).addComma())",
            "COIN".localize().capitalized
        ], arrayColors: [.appColor(.black333) ?? .black, .appColor(.black333) ?? .black], arrayFonts: [UIConstants.Fonts.appFont(.Bold, 20), UIConstants.Fonts.appFont(.Semibold, 14)])
        myVoucherLabel.attributedText = getAttributedString(arrayTexts: [
            "\(Int(summaryModel.voucherExp ?? 0).addComma())",
            "VOUCHER_TO_EXPIRE".localize().capitalized
        ], arrayColors: [.appColor(.black333) ?? .black, .appColor(.black333) ?? .black], arrayFonts: [UIConstants.Fonts.appFont(.Bold, 20), UIConstants.Fonts.appFont(.Semibold, 14)])
    }
}

// MARK: PointVoucherViewDelegate
extension VoucherPointViewController: PointVoucherViewDelegate {
    func didTapBuyButton(item: VoucherModel) {
        let vc = VoucherDetailViewController()
        vc.voucherDetailType = .notMine
        vc.voucherId = item.voucherId ?? ""
        vc.providerId = item.providerId ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: PointViewDelegate
extension VoucherPointViewController: PointViewDelegate {
    func updateVoucherSummary(summary: VoucherSummaryModel) {
        summaryModel = summary
        AppStateManager.shared.userCoin = summary.coin ?? 0
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func showError(error: ApiError) {
        
    }
    
    func showAlert() {
        
    }
    
    func updateListVoucher(list: [VoucherModel], showAt: VoucherTypeEnum) {
        DispatchQueue.main.async {
            switch showAt {
                case .HOME:
                    break
                case .USE_POINT_VOUCHER_FOR_U:
                    self.bestSellerProductView.setData(items: list, title: "POPULAR_PRODUCT".localize(), viewType: self.viewType)
                case .USE_POINT_SPECIAL_VOUCHER:
                self.specialVoucherCollectionView.setData(items: list, title: "SPECIAL_OFFER".localize().capitalized)
                case .USE_POINT_POPULAR_PRODUCT:
                    self.promotionProductView.setData(items: list, title: "DEALS_FOR_YOU".localize(), viewType: self.viewType)
            }
            
            let rowCount: Int = list.count / 2 + list.count % 2
            self.bestSellerHeightConstraint.update(offset: CGFloat(288 * rowCount) + BaseTabBarViewController.TABBAR_HEIGHT)
        }
    }
    
    func updateListCategory(list: [VoucherCategoryModel]) {
        var list = list
        list.insert(.init(categoryID: "", categoryName: "ALL".localize(), createdAt: -1, categoryIcon: "ic_crown"), at: 0)
        
        categoryCollectionView.items = list

        DispatchQueue.main.async {
            self.categoryCollectionView.reloadData()
        }
    }
}
