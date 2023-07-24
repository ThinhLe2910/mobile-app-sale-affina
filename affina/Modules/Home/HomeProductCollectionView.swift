//
//  HomeProductTableView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/06/2022.
//

import UIKit
import SnapKit
import SkeletonView

protocol HomeProductCollectionViewDelegate {
    func didTapBuyButton(item: HomeFeaturedProduct)
}

class HomeProductCollectionView: UIView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ưu đãi"
        label.font = UIConstants.Fonts.appFont(.Medium, 24)
        return label
    }()

    lazy var moreButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_next_circle"), for: .normal)
        button.hide() // TODO: 
        return button
    }()
    
    private lazy var collectionView: HomeProductCollection = {
        let view = HomeProductCollection()
        let layout = createFlowLayout()
        view.collectionViewFlowLayout = layout
        view.backgroundColor = .clear
        view.registerCell(nibName: HomeProductCollectionViewCell.nib)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
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
    
    var scrollDirection: UICollectionView.ScrollDirection = .vertical {
        didSet {
            let layout = createFlowLayout()
            collectionView.collectionViewFlowLayout = layout

            if scrollDirection == .horizontal {
                
                moreButton.snp.updateConstraints { make in
                    make.top.equalToSuperview()
                    make.trailing.equalToSuperview().offset(-UIPadding.size16)
                    make.width.height.equalTo(64.height)
                }
                
                collectionView.snp.updateConstraints { make in
                    make.top.equalTo(titleLabel.snp_bottom).inset(-UIPadding.size8)
                    make.leading.equalToSuperview()//.inset(UIPadding.size16)
                    make.trailing.equalToSuperview()
                    make.bottom.equalToSuperview().inset(UIPadding.size8)
                }
            }
            else {

                moreButton.snp.updateConstraints { make in
                    make.top.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.width.height.equalTo(64.height)
                }
                
                collectionView.snp.updateConstraints { make in
                    make.top.equalTo(titleLabel.snp_bottom).inset(-UIPadding.size8)
                    make.leading.trailing.equalToSuperview()//.inset(UIPadding.size8)
                    make.bottom.equalToSuperview().inset(UIPadding.size8)
                }
            }

        }
    }

    var delegate: HomeProductCollectionViewDelegate?
    var buyCallBack: ((HomeFeaturedProduct) -> Void)?
    var moreCallback: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setData(items: [HomeFeaturedProduct], title: String) {
        collectionView.items = items
        
        setTitle(title: title)
        
        collectionView.reloadData()
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }

    private func initViews() {
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
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).inset(-UIPadding.size8)
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

    @objc func moreButtonTapped() {
        moreCallback?()
    }
}

class HomeProductCollection: BaseCollectionView<HomeProductCollectionViewCell, HomeFeaturedProduct> {
    var buyCallBack: ((HomeFeaturedProduct) -> Void)?
    var shouldShowHotIcon = true
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? HomeProductCollectionViewCell else {
            return UICollectionViewCell()
        }
        if !shouldShowHotIcon {
            items[indexPath.row].label = LabelEnum.NO_TAG.rawValue
        }
        cell.item = items[indexPath.row]
        cell.buyCallBack = buyCallBack
        return cell
    }
}

extension HomeProductCollection: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "Cell"
    }
    
}
