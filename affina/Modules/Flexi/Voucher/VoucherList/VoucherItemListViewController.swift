//
//  VoucherItemListViewController.swift
//  affina
//
//  Created by Intelin MacHD on 10/04/2023.
//

import UIKit

class VoucherItemListViewController: BaseViewController {
    static let nib = "VoucherItemListViewController"
    
    private lazy var collectionView: PointVoucherCollectionView = {
        let view = PointVoucherCollectionView()
        let layout = createFlowLayout()
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: PointVoucherCollectionViewCell.nib)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.didScrollHandler = { [weak self] scrollView in
            let contentOffsetX = scrollView.contentOffset.x
                if contentOffsetX >= (scrollView.contentSize.width - scrollView.bounds.width) - 20 /* Needed offset */ {
                    self?.handleLoadMore()
                }
        }
        view.setDidSelectItemHandler { item in
            let vc = VoucherDetailViewController()
            vc.voucherDetailType = .notMine
            vc.voucherId = item.voucherId ?? ""
            vc.providerId = item.providerId ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return view
    }()
    
    var type: VoucherTypeEnum = .USE_POINT_VOUCHER_FOR_U
    private var canLoadMore = true

    private let presenter = VoucherPointViewDelegate()
    private var data: [VoucherModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerBaseView.hide()
        setupCollectionView()
        setupHeaderView()
        presenter.delegate = self
        presenter.getListVoucherAt(from: 0, limit: 10, showAt: type)
        
    }

    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        switch type {
            case .USE_POINT_VOUCHER_FOR_U:
                labelBaseTitle.text = "DEALS_FOR_YOU".localize()
            case .USE_POINT_SPECIAL_VOUCHER:
                labelBaseTitle.text = "SPECIAL_OFFER".localize()
            default:
                break
        }
    }
    
    func setTitle(_ title: String) {
        labelBaseTitle.text = title
    }
}

extension VoucherItemListViewController {
    
    private func setupCollectionView() {
        view.insertSubview(collectionView, belowSubview: headerBaseView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(23.width)
            make.right.equalToSuperview().offset(-23.width)
        }
        collectionView.setInset(UIEdgeInsets(top: 70.height, left: 0, bottom: 30.height, right: 0))
    }
    
    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIConstants.Layout.screenWidth / 2 - 28, height: 268)
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        return layout
    }
    
    func handleLoadMore() {
        if data.count > 0 && canLoadMore {
            presenter.getListVoucherAt(from: data.count, limit: 10, showAt: type)
        }
    }
}

extension VoucherItemListViewController: PointViewDelegate {
    
    func updateListVoucher(list: [VoucherModel], showAt: VoucherTypeEnum) {
        if list.count > 0 {
            collectionView.items = list
            data = list
            collectionView.reloadData()
        } else {
            canLoadMore = false
        }
    }
    
    func lockUI() {
        lockScreen()
    }
    
    func unlockUI() {
        unlockScreen()
    }
    
    func showError(error: ApiError) {
        self.showErrorPopup(error: error)
    }
    
    //Ignore these since they only here due to the delegate
    func showAlert() {
        
    }
    
    func updateVoucherSummary(summary: VoucherSummaryModel) {
        
    }
    
    
    func updateListCategory(list: [VoucherCategoryModel]) {
        
    }
}
