//
//  PointVoucherView.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import SnapKit
import SkeletonView

protocol PointVoucherViewDelegate {
    func didTapBuyButton(item: VoucherModel)
}

class PointVoucherView: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ưu đãi"
        label.font = UIConstants.Fonts.appFont(.Bold, 24)
        return label
    }()
    
    private lazy var moreButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_next_circle"), for: .normal)
//        button.hide() // TODO:
        return button
    }()
    
    private lazy var collectionView: PointVoucherCollectionView = {
        let view = PointVoucherCollectionView()
        let layout = createFlowLayout()
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: PointVoucherCollectionViewCell.nib)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.didScrollHandler = { [weak self] scrollView in
            
        }
        return view
    }()
    
    var sectionInset: UIEdgeInsets = .zero {
        didSet {
            let layout = createFlowLayout()
            collectionView.collectionViewFlowLayout = layout
            
            titleLabel.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(UIPadding.size8)
                make.leading.equalToSuperview().offset(sectionInset.left)
                make.trailing.equalTo(moreButton.snp_leading).inset(UIPadding.size16)
            }
        }
    }
    
    var viewType: FlexiCategoryViewType = .voucher
    
    var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            let layout = createFlowLayout()
            collectionView.collectionViewFlowLayout = layout
            
            if scrollDirection == .horizontal {
                
                moreButton.snp.updateConstraints { make in
                    make.top.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-UIPadding.size8)
                    make.width.height.equalTo(64.height)
                }
                
                collectionView.snp.updateConstraints { make in
                    make.top.equalTo(titleLabel.snp_bottom).inset(-UIPadding.size24 + UIPadding.size8/2)
                    make.leading.equalToSuperview()//.inset(UIPadding.size16)
                    make.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().inset(UIPadding.size8)
                }
            }
            else {
                moreButton.hide(isImmediate: true)
                moreButton.snp.updateConstraints { make in
                    make.top.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-UIPadding.size8)
                    make.width.height.equalTo(64.height)
                }
                
                collectionView.snp.updateConstraints { make in
                    make.top.equalTo(titleLabel.snp_bottom).inset(-UIPadding.size24 + UIPadding.size8/2)
                    make.leading.trailing.equalToSuperview()//.inset(UIPadding.size8)
                    make.bottom.equalToSuperview().inset(UIPadding.size8)
                }
            }
            
        }
    }
    
    var isScrollEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    var delegate: PointVoucherViewDelegate?
    var buyCallBack: ((VoucherModel) -> Void)?
    var viewMoreCallback: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(items: [VoucherModel], title: String, viewType: FlexiCategoryViewType) {
        collectionView.items = items
        titleLabel.text = title
        
        collectionView.viewType = viewType
        
        if title.isEmpty {
            moreButton.hide(isImmediate: true)
        }
        collectionView.reloadData()
    }
    
    @objc func onTapViewMore() {
        print("View more tapped")
        viewMoreCallback?()
    }
    
    private func initViews() {
        backgroundColor = .clear
        
        addSubview(titleLabel)
        addSubview(moreButton)
        addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size8)
            make.leading.equalToSuperview()//.inset(UIPadding.size8)
            make.trailing.equalTo(moreButton.snp_leading).inset(UIPadding.size16)
        }
        
        moreButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(64.height)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).inset(-UIPadding.size24 + UIPadding.size8/2)
            make.leading.trailing.equalToSuperview()//.inset(UIPadding.size8)
            make.bottom.equalToSuperview().inset(UIPadding.size8)
        }
        
        collectionView.buyCallBack = { [weak self] item in
            guard let self = self else { return }
            self.delegate?.didTapBuyButton(item: item)
        }
        
        collectionView.setDidSelectItemHandler { [weak self] model in
            self?.buyCallBack?(model)
        }
        
        moreButton.addTarget(self, action: #selector(onTapViewMore), for: .touchUpInside)
    }
    
    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIConstants.Layout.screenWidth / 2 - 28, height: 268)
        layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = scrollDirection
        return layout
    }
    
}

class PointVoucherCollectionView: BaseCollectionView<PointVoucherCollectionViewCell, VoucherModel> {
    var buyCallBack: ((VoucherModel) -> Void)?
    var viewType = FlexiCategoryViewType.voucher
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PointVoucherCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.cellType = viewType
        cell.item = items[indexPath.row]
        cell.buyCallBack = buyCallBack
        return cell
    }
    
}

extension PointVoucherCollectionView: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "Cell"
    }
    
}
