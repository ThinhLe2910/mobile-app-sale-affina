//
//  FlexiCategoriesViewController.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import SnapKit

enum FlexiCategoryViewType {
    case company
    case voucher
}

class FlexiCategoriesViewController: BaseViewController {

    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var benefitView: BaseView!
    @IBOutlet weak var benefitHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moneyLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var usedMoneyLabel: BaseLabel!
    
    @IBOutlet weak var moneyProgressView: UIProgressView!
    
    @IBOutlet weak var categoryView: BaseView!
    @IBOutlet weak var voucherView: BaseView!
    
    private lazy var categoryCollectionView: FlexiCategoriesView = {
        let view = FlexiCategoriesView()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 78, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        view.showsHorizontalScrollIndicator = false
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: PointCategoryCollectionViewCell.nib)
        return view
    }()
    
    private lazy var voucherCollectionView: PointVoucherView = {
        let view = PointVoucherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollDirection = .vertical
        view.sectionInset = .init(top: 0, left: 24, bottom: 0, right: 24)
        view.buyCallBack = { model in
            print(model)
            let vc = VoucherDetailViewController()
            vc.voucherId = model.voucherId ?? ""
            vc.providerId = model.providerId ?? ""
            vc.viewType = self.viewType
            if self.viewType == .company {
                vc.voucherDetailType = .company
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.isScrollEnabled = false
        return view
    }()
    
    private var heightConstraint: Constraint?
    
    private let presenter = FlexiCategoriesViewPresenter()
    private var lowestPrice: Int = 0
    private var maxPrice: Int = 0
    
    private var list: [VoucherModel] = []
    
    var viewType: FlexiCategoryViewType = .voucher
    var categoryId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeaderView()
        containerBaseView.hide()
        
        scrollViewTopConstraint.constant = UIConstants.Layout.headerHeight
        
        //
        moneyProgressView.trackTintColor = .appColor(.pinkUltraLighter)
        moneyProgressView.progressTintColor = .appColor(.blue)
        moneyProgressView.layer.cornerRadius = 2
        moneyProgressView.layer.masksToBounds = true
        
        setupCatogoriesCollectionView()
        
        voucherView.addSubview(voucherCollectionView)
        voucherCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()// .inset(-UIPadding.size24)
            heightConstraint = make.height.equalTo(100).constraint
            
        }
        voucherCollectionView.delegate = self
        voucherCollectionView.setData(items: [], title: "DEALS_FOR_YOU".localize(), viewType: viewType)
        
        presenter.delegate = self
        presenter.getListCategory()
        
        if viewType == .company {
            addBlurEffect(benefitView)
            benefitView.backgroundColor = .appColor(.blueUltraLighter)?.withAlphaComponent(0.65)
            benefitView.show()
            benefitHeightConstraint.constant = 92
            
            updateUI()
        }
        else {
            benefitView.hide()
            benefitHeightConstraint.constant = 0
            presenter.getListVoucherByCategory(categoryId: categoryId, from: 0, limit: 10)
        }
        
    }
    
    private func updateUI() {
        guard let model = AppStateManager.shared.flexiSummary else { return }
        
        let dateText = "\((model.expiredAt ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
        let attrs = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 10)
        ] as [NSAttributedString.Key : Any]
        let attributedString = NSMutableAttributedString(string: dateText, attributes: attrs)
        let normalString = NSMutableAttributedString(string: "\("EXPIRY".localize()): ")
        attributedString.insert(normalString, at: 0)
        dateLabel.attributedText = attributedString
        
        let usedPointText = "\((model.usedPoint ?? 0).addComma()) \("POINT".localize())"
        let attrs2 = [
            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 10)
        ] as [NSAttributedString.Key : Any]
        let attributedString2 = NSMutableAttributedString(string: usedPointText, attributes: attrs2)
        let normalString2 = NSMutableAttributedString(string: "\("USED".localize()): ")
        attributedString2.insert(normalString2, at: 0)
        usedMoneyLabel.attributedText = attributedString2
        
//        let pointText = "\((model.point ?? 0).addComma()) \("POINT".localize())"
//        let attrs3 = [
//            NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16)
//        ] as [NSAttributedString.Key : Any]
//        let attributedString3 = NSMutableAttributedString(string: pointText, attributes: attrs3)
//        let normalString3 = NSMutableAttributedString(string: "POINT".localize())
//        attributedString3.append(normalString3)
//        moneyLabel.attributedText = attributedString3
        moneyLabel.text = "\((model.point ?? 0).addComma()) \("POINT".localize())"  
        
        let used = CGFloat(model.usedPoint ?? 0)
        let avail = CGFloat(model.point ?? 0)
        moneyProgressView.setProgress(Float(used == avail && used == 0 ? 0.0 : (avail/(used + avail))), animated: true)
        
    }
    
    
    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        headerBaseView.backgroundColor = .appColor(.blueUltraLighter)?.withAlphaComponent(0.65)
        if viewType == .company {
            labelBaseTitle.text = "REDEEM_BENEFITS".capitalized.localize()
            labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
            labelBaseTitle.textColor = .appColor(.black)
            rightBaseImage.image = UIImage(named: "ic_clock")
            rightBaseImage.addTapGestureRecognizer {
                let vc = BenefitCompanyHistoryViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            labelBaseTitle.text = "USE_COINS".localize().capitalized
            labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
            labelBaseTitle.textColor = .appColor(.black)
            rightBaseImage.image = UIImage(named: "ic_filter")
            rightBaseImage.addTapGestureRecognizer { [weak self] in
                guard let self = self else { return }
                self.lowestPrice = 0
                self.maxPrice = 20000000
                self.grayScreen.removeFromSuperview()
                self.view.addSubview(self.grayScreen)
                self.grayScreen.frame = self.view.bounds
                let view = FlexiCategoriesFilterView(frame: .init(x: UIConstants.Layout.screenWidth, y: 0, width: 352.width, height: UIConstants.Layout.screenHeight))
                view.closeCallBack = { [weak self] items in
                    self?.grayScreen.removeFromSuperview()
                    self?.handleFilter(items)
                }
                view.changeRangeCallback = { [weak self] lowPrice, maxPrice in
                    self?.lowestPrice = lowPrice
                    self?.maxPrice = maxPrice
                }
                self.view.addSubview(view)
                
                UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseInOut) {
                    view.frame.origin.x = UIConstants.Layout.screenWidth - 352.width
                } completion: { _ in
                    view.rangeSlider.updateLayerFrames()
                    view.rangeSlider.show()
                }
                
                self.grayScreen.addTapGestureRecognizer {
                    UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseInOut, animations: {
                        view.frame.origin.x = UIConstants.Layout.screenWidth
                    }) { _ in
                        view.removeFromSuperview()
                        self.grayScreen.removeFromSuperview()
                    }
                }
                
            }
        }
        
    }
    
    private func setupCatogoriesCollectionView() {
        categoryView.addSubview(categoryCollectionView)
        categoryCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size24)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(-UIPadding.size8)
        }
        
        categoryCollectionView.items = []
        
        categoryCollectionView.setDidSelectItemHandler { [weak self] item in
            guard let self = self else { return }
            if self.viewType == .company {
                self.presenter.getListSMEVoucherByCategory(categoryId: item.categoryID ?? "", from: 0, limit: 10)
                return
            }
            self.presenter.getListVoucherByCategory(categoryId: item.categoryID ?? "", from: 0, limit: 10)
        }
        categoryCollectionView.reloadData()
        
    }
    
    private func handleFilter(_ items: [Bool]) {
//        let isLatestVoucher = items[0]
//        let isPopularVoucher = items[1]
        let ascPrice = items[0]
        let descPrice = items[1]
        
        var filteredList = list
        
        if ascPrice {
            filteredList = list.sorted(by: { v1, v2 in
                v1.price ?? 0 <= v2.price ?? 0
            })
        }
        else if descPrice {
            filteredList = list.sorted(by: { v1, v2 in
                v1.price ?? 0 >= v2.price ?? 0
            })
        }
        
        filteredList = filteredList.filter({ voucher in
            (voucher.price ?? 0) >= lowestPrice && (voucher.price ?? 0) <= maxPrice
        })

        DispatchQueue.main.async {
            self.heightConstraint?.update(offset: CGFloat(filteredList.count/2 + (filteredList.count%2 != 0 ? 1 : 0)) * 288 + 24)
            self.voucherCollectionView.setData(items: filteredList, title: "", viewType: self.viewType)
        }
    }
}

// MARK: PointVoucherViewDelegate
extension FlexiCategoriesViewController: PointVoucherViewDelegate {
    func didTapBuyButton(item: VoucherModel) {
        let vc = VoucherDetailViewController()
        vc.voucherId = item.voucherId ?? ""
        vc.providerId = item.providerId ?? ""
        vc.viewType = viewType
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

// MARK: FlexiCategoriesViewDelegate
extension FlexiCategoriesViewController: FlexiCategoriesViewDelegate {
    func updateListVouchers(list: [VoucherModel]) {
//        var arr: [VoucherModel] = list
//        arr.append(contentsOf: list)
        self.list = list
        DispatchQueue.main.async {
            self.heightConstraint?.update(offset: CGFloat(list.count/2 + (list.count%2 != 0 ? 1 : 0)) * 288 + 24)
            self.voucherCollectionView.setData(items: list, title: "", viewType: self.viewType)
        }
    }
    
    func updateListCategories(list: [VoucherCategoryModel]) {
        var list = list
        list.insert(.init(categoryID: "", categoryName: "ALL".localize(), createdAt: -1, categoryIcon: "ic_crown"), at: 0)
        categoryCollectionView.items = list
        var i = 0
        for (idx, cate) in list.enumerated() {
            if cate.categoryID == self.categoryId {
                i = idx
                break
            }
        }
        
        if viewType == .company {
            presenter.getListSMEVoucherByCategory(categoryId: list[i].categoryID ?? "", from: 0, limit: 10)
        }
        
        DispatchQueue.main.async {
            self.categoryCollectionView.selectedCategory = i
            self.categoryCollectionView.reloadData()
            self.categoryCollectionView.scrollToItem(at: .init(item: i, section: 0), at: .right, animated: true)
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
    
    
}
