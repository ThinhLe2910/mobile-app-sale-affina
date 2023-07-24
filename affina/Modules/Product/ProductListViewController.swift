//
//  ProductListViewController.swift
//  affina
//
//  Created by Intelin MacHD on 24/04/2023.
//

import UIKit

class ProductListViewController: BaseViewController {
    static let nib = "ProductListViewController"
    
    private let presenter = ProductListPresenter()
    private var list = [HomeFeaturedProduct]()
    
    private lazy var collectionView: HomeProductCollection = {
        let view = HomeProductCollection()
        let layout = createFlowLayout()
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: HomeProductCollectionViewCell.nib)
        view.shouldShowHotIcon = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.setDidSelectItemHandler { item in
            let vc = UINavigationController(rootViewController: InsuranceApproachViewController())
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        return view
    }()
    
    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIConstants.Layout.screenWidth / 2 - 28, height: 268)
        layout.sectionInset = .zero
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerBaseView.hide()
        setupHeaderView()
        setupCollectionView()
        
        presenter.setViewDelegate(delegate: self)
        presenter.getListFeaturedProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? BaseTabBarViewController)?.hideTabBar()
    }

    private func setupHeaderView() {
        addBlurEffect(headerBaseView)
        labelBaseTitle.font = UIConstants.Fonts.appFont(.Bold, 16)
        labelBaseTitle.textColor = .appColor(.black)
        labelBaseTitle.text = "DEALS_FOR_YOU".localize()
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(23.width)
            make.right.equalToSuperview().offset(-23.width)
        }
        collectionView.setInset(UIEdgeInsets(top: 70.height, left: 0, bottom: 30.height, right: 0))
    }
}

extension ProductListViewController: ProductListViewDelegate {
    func lockUI() {
        self.lockScreen()
    }
    
    func unLockUI() {
        self.unlockScreen()
    }
    
    func showError(error: ApiError) {
        self.showErrorPopup(error: error)
    }
    
    func updateListFeaturedProducts(list: [HomeFeaturedProduct]) {
        self.list = list
        collectionView.items = list
        collectionView.reloadData()
    }
}
