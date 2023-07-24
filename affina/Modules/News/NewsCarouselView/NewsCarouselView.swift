//
//  NewsCarouselView.swift
//  affina
//
//  Created by Intelin MacHD on 27/07/2022.
//

import UIKit

protocol NewsCarouselViewDelegate: AnyObject {
    func currentPageDidChange(to page: Int)
    func handleOnPressCarouselItem(id: String)
    
    func likeCarouselNewsItem(id: String, isLiked: Bool)
    func commentCarouselNewsItem(id: String)
    
}

class NewsCarouselView: UIView {
    struct NewsCarouselData {
        let id: String?
        let image: String?
        let time: String?
        let title: String?
        var numberLikes: Int
        var numberComments: Int
        var isLiked: Int
    }

    // MARK: - Subviews
    private lazy var carouselCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(NewsCarouselCell.self, forCellWithReuseIdentifier: NewsCarouselCell.cellId)
        collection.backgroundColor = .clear
        return collection
    }()

    var pageControl: UICollectionView
    let layout = UICollectionViewFlowLayout()

    // MARK: - Properties
    private var index = 0
    private var preIndex = 0
    private let controlHeight: CGFloat = 4
    private let selectedControlWidth: CGFloat = 36
    private let controlSpacing: CGFloat = 4
    private let carouselHeight: CGFloat = 239 + 12 + 56// + 16 + 20

    private var pages: Int
    private weak var delegate: NewsCarouselViewDelegate?
    private var carouselData = [NewsCarouselData]()
    private var currentPage = 0 {
        didSet {
            index = currentPage
            pageControl.reloadData()
            delegate?.currentPageDidChange(to: currentPage)
        }
    }

    var timer: Timer?
    
    // MARK: - Initializers

    init(pages: Int, delegate: NewsCarouselViewDelegate?) {
        self.pages = pages
        self.delegate = delegate

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
    }

    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let cellPadding: CGFloat = 0 // (frame.width - 300) / 2
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        carouselLayout.itemSize = .init(width: frame.width == 0 ? 4 : frame.width, height: carouselHeight)
        carouselLayout.sectionInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        carouselLayout.minimumLineSpacing = cellPadding * 2
        carouselLayout.minimumInteritemSpacing = cellPadding
        return carouselLayout
    }

    private func setupCollectionView() {
        carouselCollectionView.collectionViewLayout = createFlowLayout()

        addSubview(carouselCollectionView)
        carouselCollectionView.translatesAutoresizingMaskIntoConstraints = false
        carouselCollectionView.snp.makeConstraints { make in
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
            make.top.equalTo(carouselCollectionView.snp_bottom).offset(UIPadding.size8)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(120)
            make.height.greaterThanOrEqualTo(controlHeight)
            //            make.bottom.equalTo(snp_bottom).inset(32)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewsCarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

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
            if index == self.index {
                cell.backgroundColor = UIColor.appColor(.blueDark)
            } else {
                cell.backgroundColor = UIColor.appColor(.blueLighter)
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsCarouselCell.cellId, for: indexPath) as? NewsCarouselCell else { return UICollectionViewCell() }
            cell.configure(model: carouselData[indexPath.row])
            cell.likeCallBack = { newsId in
                self.delegate?.likeCarouselNewsItem(id: newsId, isLiked: self.carouselData[indexPath.row].isLiked == IsLiked.YES.rawValue)
            }
            cell.commentCallBack = { newsId in
                self.delegate?.commentCarouselNewsItem(id: newsId)
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
        return createFlowLayout().itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == carouselCollectionView {
            delegate?.handleOnPressCarouselItem(id: carouselData[indexPath.row].id ?? "")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        if collectionView == pageControl {
            let totalCellWidth = controlHeight * CGFloat(carouselData.count) + selectedControlWidth
            let totalSpacingWidth = controlSpacing * CGFloat(carouselData.count - 1)

            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset

            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
        return createFlowLayout().sectionInset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == pageControl {
            return controlSpacing
        }
        return createFlowLayout().minimumInteritemSpacing
    }
}

// MARK: - UICollectionView Delegate
extension NewsCarouselView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()

//        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(slide), userInfo: nil, repeats: true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()
    }
}

// MARK: - Public
extension NewsCarouselView {
    public func configureView(with data: [NewsCarouselData]) {
        carouselCollectionView.collectionViewLayout = createFlowLayout()

        carouselData = data
        carouselCollectionView.reloadData()
        pageControl.reloadData()

        // TODO:
//        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(slide), userInfo: nil, repeats: true)

    }

    @objc func slide() {
        let width = UIScreen.main.bounds.width
        var newOffsetX = carouselCollectionView.contentOffset.x + width
        index += 1
        if newOffsetX >= width * 3 {
            newOffsetX = 0
            index = 0
        }
        pageControl.reloadData()
        carouselCollectionView.contentOffset = CGPoint(x: newOffsetX, y: 0)
    }
}

// MARKK: - Helpers
private extension NewsCarouselView {
    func getCurrentPage() -> Int {

        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }

        return currentPage
    }
}


