//
//  CardInsuranceCarouselView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/07/2022.
//

import UIKit
import SnapKit
import CollectionViewPagingLayout

protocol CardInsuranceCarouselDelegate: AnyObject {
    func didTapEditButton(index: Int)
    func didTapRequestButton(index: Int)
    func loadMoreCards(contractId: String, contractObjectId: String, createdAt: Double)
    func didSwipeCard(index: Int)
}

extension CardInsuranceCarouselDelegate {
    func didSwipeCard(index: Int) {
        
    }
}

class CardInsuranceCarouselView: BaseView {
    
    struct CarouselData {
        let image: UIImage?
    }
    
    // MARK: - Subviews
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewPagingLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(CardInsuranceCollectionViewCell.self, forCellWithReuseIdentifier: CardInsuranceCollectionViewCell.cellId)
        collection.register(CardInsuranceClaimCollectionViewCell.self, forCellWithReuseIdentifier: CardInsuranceClaimCollectionViewCell.cellId)
        collection.backgroundColor = .clear
        return collection
    }()
    
    private var pageControl: UICollectionView
    private let layout = UICollectionViewFlowLayout()
    
    // MARK: - Properties
    private let controlHeight: CGFloat = 4
    private let selectedControlWidth: CGFloat = 36
    private let controlSpacing: CGFloat = 4
    private var carouselHeight: CGFloat = CardInsuranceCollectionViewCell.size.height + 16
    
    var type: Int {
        didSet {
            if type == 0 {
                carouselHeight = CardInsuranceCollectionViewCell.size.height + 16
            }
            else {
                carouselHeight = CardInsuranceCollectionViewCell.size.height
            }
            collectionView.reloadData()
            pageControl.reloadData()
        }
    }
    //    private let cardColors: [UIColor?] = [.appColor(.blue), .appColor(.orange), .appColor(.pinkLighter)]
    var pages: Int = 0
    
    weak var delegate: CardInsuranceCarouselDelegate?
    
    private var carouselData = [CardModel]() // [CarouselData]()
    private var currentPage = 0 {
        didSet {
            pageControl.reloadData()
            //            delegate?.currentPageDidChange(to: currentPage)
        }
    }
    
    private var cardLayouts: [ListSetupCard] = []
    
    var isLoadingMore: Bool = false
    var endReached: Bool = false
    
    // MARK: - Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //            self.pages = pages
        //            self.delegate = delegate
        self.layout.scrollDirection = .horizontal
        self.layout.itemSize = CGSize(width: selectedControlWidth, height: controlHeight)
        self.layout.minimumLineSpacing = 0
        self.layout.minimumInteritemSpacing = 0
        self.pageControl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        setupUI()
    }
    
    override init(frame: CGRect) {
        self.layout.scrollDirection = .horizontal
        self.layout.itemSize = CGSize(width: selectedControlWidth, height: controlHeight)
        self.layout.minimumLineSpacing = 0
        self.layout.minimumInteritemSpacing = 0
        self.pageControl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.type = 1
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        self.layout.scrollDirection = .horizontal
        self.layout.itemSize = CGSize(width: selectedControlWidth, height: controlHeight)
        self.layout.minimumLineSpacing = 0
        self.layout.minimumInteritemSpacing = 0
        self.pageControl = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.type = 1
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        setupCollectionView()
        setupPageControl()
        
    }
    
    private func createFlowLayout() -> CollectionViewPagingLayout {
        let carouselLayout = CollectionViewPagingLayout()
        return carouselLayout
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = createFlowLayout()
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(carouselHeight)
        }
    }
    
    private func setupPageControl() {
        // Setup view indicator
        pageControl.delegate = self
        pageControl.dataSource = self
        pageControl.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        pageControl.backgroundColor = .clear
        pageControl.isScrollEnabled = false
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp_bottom).offset(UIPadding.size8)
//            make.centerX.equalToSuperview()
//            make.width.greaterThanOrEqualTo(120)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(controlHeight)
            //            make.bottom.equalTo(snp_bottom).inset(32)
        }
    }
    
    @objc private func didTapAddButton() {
        
    }
    
    func updateCardLayouts(_ list: [ListSetupCard]) {
        cardLayouts = list
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension CardInsuranceCarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pageControl {
            return carouselData.count - 2
        }
        return carouselData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pageControl {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.removeFromSuperview()
            cell.layer.cornerRadius = controlHeight / 2
            let index = indexPath.row
            if carouselData.count == 1 {
                cell.backgroundColor = .appColor(.blueSlider)
            }
            else if (index + 1) == currentPage {
                cell.backgroundColor = UIColor.appColor(.blueDark)
            }
            else if (index == (carouselData.count - 2 - 1) && currentPage >= (carouselData.count - 2)) || (index == 0 && currentPage <= 1) {
                cell.backgroundColor = UIColor.appColor(.blueDark)
            }
            else {
                cell.backgroundColor = UIColor.appColor(.blueLighter)
            }
            return cell
        }
        else {
            if type == 1 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardInsuranceCollectionViewCell.cellId, for: indexPath) as? CardInsuranceCollectionViewCell else { return UICollectionViewCell() }
                //            let image = carouselData[indexPath.row].image
                //            cell.configure(image: image)
                cell.item = carouselData[indexPath.row]
                cell.backgroundAsset = .appColor(.pinkLighter) // cardColors[indexPath.row]
                cell.requestCallBack = {
                    self.delegate?.didTapRequestButton(index: indexPath.row - 1)
                }
                cell.editCallBack = {
                    self.delegate?.didTapEditButton(index: indexPath.row - 1)
                }
            
                for cardLayout in cardLayouts {
                    
                    if LayoutBuilder.shared.isAbleToApplyCardLayout(card: carouselData[indexPath.row], layout: cardLayout)
                    {
                        cell.updateCardLayout(cardLayout.listCardOrder ?? [])
                    }
                }
                
                return cell
            }
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardInsuranceClaimCollectionViewCell.cellId, for: indexPath) as? CardInsuranceClaimCollectionViewCell else { return UICollectionViewCell() }
            //            let image = carouselData[indexPath.row].image
            //            cell.configure(image: image)
            cell.item = carouselData[indexPath.row]
            cell.backgroundAsset = .appColor(.pinkLighter) // cardColors[indexPath.row]
            
            for cardLayout in cardLayouts {
                if LayoutBuilder.shared.isAbleToApplyCardLayout(card: carouselData[indexPath.row], layout: cardLayout)
                {
                    cell.updateCardLayout(cardLayout.listCardOrder ?? [])
                }
            }
            
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == pageControl {
            let index = indexPath.row
            if index + 1 == currentPage {
                return CGSize(width: selectedControlWidth, height: controlHeight)
            }
            else if (index == (carouselData.count - 2 - 1) && currentPage >= (carouselData.count - 2)) || (index == 0 && currentPage <= 1) {
                return CGSize(width: selectedControlWidth, height: controlHeight)
            }
            else {
                return CGSize(width: controlHeight, height: controlHeight)
            }
        }
        return CardInsuranceCollectionViewCell.size
        //        return UICollectionViewFlowLayout.automaticSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == pageControl {
            let totalCellWidth = controlHeight * CGFloat(carouselData.count) + selectedControlWidth
            let totalSpacingWidth = controlSpacing * CGFloat(carouselData.count - 1)
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
        return .init(top: 0, left: UIPadding.size24, bottom: 0, right: UIPadding.size24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == pageControl {
            return controlSpacing
        }
        return UIPadding.size8
    }
    
    
}

// MARK: - UICollectionView Delegate
extension CardInsuranceCarouselView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
        
        let pageFloat = (scrollView.contentOffset.x / scrollView.frame.size.width)
        let pageInt = Int(round(pageFloat))
        let pageCeil = Int(ceil(pageFloat))
        
        switch pageInt {
            case 0: setCurrentIndex(scrollToPage: pageCeil)
            default: setCurrentIndex(scrollToPage: pageInt)
        }
        
        if !isLoadingMore && currentPage == carouselData.count - 2 {
            loadMoreProducts()
        }
        delegate?.didSwipeCard(index: currentPage - 1)
    }
    
    func loadMoreProducts() {
        isLoadingMore = true
        guard !endReached, !carouselData.isEmpty else {
            isLoadingMore = false
            return
        }
        delegate?.loadMoreCards(contractId: carouselData[carouselData.count - 2].contractId, contractObjectId: carouselData[carouselData.count - 2].contractObjectId, createdAt: carouselData[carouselData.count - 2].createdAt)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        currentPage = getCurrentPage()
    }
}

// MARK: - Public
extension CardInsuranceCarouselView {
    public func configureView(with data: [CardModel]) {
        // collectionView.collectionViewLayout = createFlowLayout()
        if data != carouselData {
            carouselData = data
            carouselData.insert(data[data.count - 1], at: 0)
            carouselData.append(data[0])
            
            collectionView.reloadData()
//            if isLoadingMore {
//                isLoadingMore = false
//                self.collectionView.layoutIfNeeded()
//                self.collectionView.reloadItems(at: [IndexPath(item: self.currentPage, section: 0)])
//            }
//            else {
//                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
//            }
        }
    }
    
    public func scrollTo(index: Int) {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: CGFloat(Int(UIScreen.main.bounds.width) * (index)), y: 0), animated: false)
        let setIndxe = Int(collectionView.contentOffset.x / UIScreen.main.bounds.width)
        
        currentPage = setIndxe >= (carouselData.count) ? carouselData.count - 1: setIndxe // : 0
        
        self.collectionView.reloadItems(at: [IndexPath(item: currentPage, section: 0)])
    }
}

// MARK: - Helpers
private extension CardInsuranceCarouselView {
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: CardInsuranceCollectionViewCell.size) // collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }
        return Int(visiblePoint.x / CardInsuranceCollectionViewCell.size.width)
    }
    
    // MARK: active
    //    @objc private func update() {
    //        collectionView.setContentOffset(CGPoint(x: CGFloat(Int(UIScreen.main.bounds.width) * (currentIndex + 1)), y: 0), animated: true)
    //    }
    
    @objc private func setCurrentIndex(scrollToPage: Int) {
        switch scrollToPage {
            case 0:
                collectionView.setContentOffset(CGPoint(x: CGFloat(Int(UIScreen.main.bounds.width) * (carouselData.count - 2)), y: 0), animated: false)
            case carouselData.count - 1:
                collectionView.setContentOffset(CGPoint(x: UIScreen.main.bounds.width, y: 0), animated: false)
            default:
                break
        }
        let idx = Int(collectionView.contentOffset.x / UIScreen.main.bounds.width)
        currentPage = idx
    }
}

