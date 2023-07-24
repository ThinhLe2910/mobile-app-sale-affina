//
//  BaseCollectionView.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/05/2022.
//

import UIKit

class BaseCollectionViewCell<U>: UICollectionViewCell {
    var item: U?

}

class BaseCollectionView<T: BaseCollectionViewCell<U>, U>: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    var items = [U]()

    private var didSelectItemHandler: ((_ item: U) -> Void)?
    var didScrollHandler: ((_ scrollView: UIScrollView) -> Void)?

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    var collectionViewFlowLayout: UICollectionViewFlowLayout? {
        didSet {
            guard let collectionViewFlowLayout = collectionViewFlowLayout else {
                return
            }
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }

    var showsHorizontalScrollIndicator: Bool? {
        didSet {
            collectionView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator ?? false
        }
    }

    var showsVerticalScrollIndicator: Bool? {
        didSet {
            collectionView.showsVerticalScrollIndicator = showsVerticalScrollIndicator ?? false
        }
    }
    
    var isScrollEnabled: Bool? {
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled ?? false
        }
    }

    var isEmpty: Bool {
        get {
            return items.isEmpty
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initViews() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func registerCell(nibName: String? = nil) {
        guard let nibName = nibName else {
            collectionView.register(T.self, forCellWithReuseIdentifier: "Cell")
            return
        }
        collectionView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: "Cell")
    }
    
    func setDidSelectItemHandler(handler: @escaping ((_ item: U) -> Void)) {
        didSelectItemHandler = handler
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        didSelectItemHandler?(items[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? T else {
            return UICollectionViewCell()
        }
        cell.item = items[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScrollHandler?(scrollView)
    }
    
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
    }
    
    func setInset(_ inset: UIEdgeInsets) {
        collectionView.contentInset = inset
    }
}
