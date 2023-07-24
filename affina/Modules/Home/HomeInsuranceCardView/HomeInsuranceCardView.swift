//
//  HomeInsuranceCardView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 05/07/2022.
//

import UIKit
import SnapKit
import CollectionViewPagingLayout

protocol HomeInsuranceCardViewDelegate: AnyObject {
    func didTapAddButton()
    func didTapInfoButton(index: Int)
    func didTapRequestButton(index: Int)
}

class HomeInsuranceCardView: UIView {

    struct HomeCarouselData {
        let image: UIImage?
    }

    // MARK: - Subviews
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewPagingLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(HomeInsuranceCardCell.self, forCellWithReuseIdentifier: HomeInsuranceCardCell.cellId)
        collection.backgroundColor = .clear
        return collection
    }()

    private var pageControl: UICollectionView
    private let layout = UICollectionViewFlowLayout()

    private var cardLayouts: [ListSetupCard] = []
    
    lazy var addCardButton: BaseButton = {
        let button = BaseButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "ic_insurance")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.appColor(.blue)
        button.backgroundColor = UIColor.appColor(.whiteMain)
        return button
    }()

    // MARK: - Properties
    private var index = 0
    private var preIndex = 0
    private let controlHeight: CGFloat = 4
    private let selectedControlWidth: CGFloat = 36
    private let controlSpacing: CGFloat = 4
    private let carouselHeight: CGFloat = HomeInsuranceCardCell.size.height + 16

//    private let cardColors: [UIColor?] = [.appColor(.blue), .appColor(.orange), .appColor(.pinkLighter)]
    var pages: Int = 0

    weak var delegate: HomeInsuranceCardViewDelegate?

    private var carouselData = [CardModel]() // [HomeCarouselData]()
    private var currentPage = 0 {
        didSet {
            index = currentPage
            pageControl.reloadData()
//            delegate?.currentPageDidChange(to: currentPage)
        }
    }

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
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        setupCollectionView()
        setupPageControl()

        addSubview(addCardButton)
        addCardButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(52)
        }
        addCardButton.cornerRadius = 52 / 2
        addCardButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
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
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(120)
            make.height.greaterThanOrEqualTo(controlHeight)
            //            make.bottom.equalTo(snp_bottom).inset(32)
        }
    }

    @objc private func didTapAddButton() {
        delegate?.didTapAddButton()
    }
    
    func updateCardLayouts(_ layouts: [ListSetupCard]) {
        if layouts.isEmpty { return }
        cardLayouts = layouts

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.collectionViewLayout = self.createFlowLayout()
            self.collectionView.reloadData()
            self.pageControl.reloadData()
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension HomeInsuranceCardView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
            else if index == self.index {
                cell.backgroundColor = UIColor.appColor(.blueDark)
            } else {
                cell.backgroundColor = UIColor.appColor(.blueLighter)
            }
            
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeInsuranceCardCell.cellId, for: indexPath) as? HomeInsuranceCardCell else { return UICollectionViewCell() }
//            let image = carouselData[indexPath.row].image
//            cell.configure(image: image)
            cell.item = carouselData[indexPath.row]
//            if indexPath.row == 0 { cell.setCardBackground() }
            cell.setCardBackground()
//            cell.backgroundAsset = cardColors[indexPath.row]
            cell.requestCallBack = {
                self.delegate?.didTapRequestButton(index: indexPath.row)
            }
            cell.infoCallBack = {
                self.delegate?.didTapInfoButton(index: indexPath.row)
            }
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
            if index == self.index {
                return CGSize(width: selectedControlWidth, height: controlHeight)
            } else {
                return CGSize(width: controlHeight, height: controlHeight)
            }
        }
        return HomeInsuranceCardCell.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if collectionView == pageControl {
            let totalCellWidth = controlHeight * CGFloat(carouselData.count) + selectedControlWidth
            let totalSpacingWidth = controlSpacing * CGFloat(carouselData.count - 1)

            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset

            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == pageControl {
            return controlSpacing
        }
        return .zero
    }

}

// MARK: - UICollectionView Delegate
extension HomeInsuranceCardView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
}

// MARK: - Public
extension HomeInsuranceCardView {
    public func configureView(with data: [CardModel]) {
        collectionView.collectionViewLayout = createFlowLayout()
        
        carouselData = data
        collectionView.reloadData()
        pageControl.reloadData()
        
    }
}

// MARK : - Helpers
private extension HomeInsuranceCardView {
    func getCurrentPage() -> Int {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: HomeInsuranceCardCell.size) // collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return Int(visiblePoint.x / (HomeInsuranceCardCell.size.width+32))
    }
}
 
