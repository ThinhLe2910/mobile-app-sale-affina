//
//  HomeCarouselView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 05/07/2022.
//

import UIKit
import SkeletonView

protocol CarouselViewDelegate: AnyObject {
    func currentPageDidChange(to page: Int)
}

class HomeCarouselView: UIView {
    struct HomeCarouselData {
        //TODO: Replace id with link to hide the new campaign flow
        let id: String
//        let link: String
        let image: String
    }

    // MARK: - Subviews
    private lazy var carouselCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.register(HomeCarouselCell.self, forCellWithReuseIdentifier: HomeCarouselCell.cellId)
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
    private let carouselHeight: CGFloat = 150

    private var pages: Int
    private weak var delegate: CarouselViewDelegate?
    private var carouselData = [HomeCarouselData]()
    private var currentPage = 0 {
        didSet {
            index = currentPage
            pageControl.reloadData()
            delegate?.currentPageDidChange(to: currentPage)
        }
    }

    var timer: Timer?

    // MARK: - Initializers

    init(pages: Int, delegate: CarouselViewDelegate?) {
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
        carouselLayout.sectionInset = .init(top: 0, left: cellPadding, bottom: 0, right: cellPadding)
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

extension HomeCarouselView: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return HomeCarouselCell.cellId
    }
    
}

// MARK: - UICollectionViewDataSource
extension HomeCarouselView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCarouselCell.cellId, for: indexPath) as? HomeCarouselCell else { return UICollectionViewCell() }
            let image = carouselData[indexPath.row].image
            cell.configure(imgUrl: image)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if carouselData[indexPath.row].id == "-1"{
            return
        }
        Logger.Logs(message: carouselData[indexPath.row])
        
//        guard let url = URL(string: carouselData[indexPath.row].link) else { return }
        
        let vc = CampaignDetailWithActionViewController(nibName: CampaignDetailWithActionViewController.nib, bundle: nil)
        vc.id = carouselData[indexPath.row].id
        UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
      
        //TODO: Uncomment this to hide campaign
//        guard let url = URL(string: carouselData[indexPath.row].link) else { return }
//
//        UIApplication.shared.open(url)
    }
}

// MARK: - UICollectionView Delegate
extension HomeCarouselView: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage()

        timer?.invalidate()
        if carouselData.count <= 1 { return }
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(slide), userInfo: nil, repeats: true)
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
extension HomeCarouselView {
    public func configureView(with data: [HomeCarouselData]) {
        carouselCollectionView.collectionViewLayout = createFlowLayout()

        carouselData = data
        carouselCollectionView.reloadData()
        pageControl.reloadData()

        timer?.invalidate()
        // TODO:
        if carouselData.count <= 1 { return }
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(slide), userInfo: nil, repeats: true)

    }

    @objc func slide() {
        let width = UIScreen.main.bounds.width - UIPadding.size16 * 2
        var newOffsetX = carouselCollectionView.contentOffset.x + width
        index += 1
        if newOffsetX >= (width * CGFloat(carouselData.count)) {
            newOffsetX = 0
            index = 0
        }
        pageControl.reloadData()
        carouselCollectionView.contentOffset = CGPoint(x: newOffsetX, y: 0)
    }
}

// MARKK: - Helpers
private extension HomeCarouselView {
    func getCurrentPage() -> Int {

        let visibleRect = CGRect(origin: carouselCollectionView.contentOffset, size: carouselCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = carouselCollectionView.indexPathForItem(at: visiblePoint) {
            return visibleIndexPath.row
        }

        return currentPage
    }
}


