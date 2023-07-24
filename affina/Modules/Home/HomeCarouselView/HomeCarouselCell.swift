//
//  HomeCarouselCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 05/07/2022.
//

import UIKit
import SkeletonView

class HomeCarouselCell: UICollectionViewCell {
    
    // MARK: - SubViews
    private lazy var imageView = UIImageView()
    
    // MARK: - Properties
    static let cellId = "HomeCarouselCell"
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .clear
        
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIPadding.size8)
            make.height.equalTo(148)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.isSkeletonable = true
        DispatchQueue.main.async {
            self.imageView.showSkeleton()
        }
    }
    
    public func configure(imgUrl: String) {
        guard let url = URL(string: imgUrl) else {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(named: "placeholder")
            }
            return
        }
        CacheManager.shared.imageFor(url: url) { [weak self] image, error in
            DispatchQueue.main.async {
                self?.imageView.hideSkeleton()
            }
            if error != nil {
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(named: "placeholder")
                }
                return
            }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
}

