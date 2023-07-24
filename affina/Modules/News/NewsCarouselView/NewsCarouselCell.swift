//
//  NewsCarouselCell.swift
//  affina
//
//  Created by Intelin MacHD on 27/07/2022.
//

import UIKit

class NewsCarouselCell: UICollectionViewCell {

    // MARK: - SubViews
    private lazy var containerView = UIView()
    private lazy var imageView = UIImageView()
    private lazy var timeLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Constants.Fonts.appFont(.Semibold, 12)
        return label
    }()

    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Constants.Fonts.appFont(.Bold, 16)
        return label
    }()
    
    private lazy var separator: BaseView = {
        let view = BaseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundAsset = "backgroundLightGray"
        return view
    }()
    
    private lazy var likeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_heart")
        return imageView
    }()
    
    private lazy var likeCountLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.subText)
        label.font = Constants.Fonts.appFont(.Semibold, 12)
        return label
    }()
    
    private lazy var commentCountLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.subText)
        label.font = Constants.Fonts.appFont(.Semibold, 12)
        return label
    }()

    private lazy var separator2: BaseView = {
        let view = BaseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundAsset = "backgroundLightGray"
        return view
    }()
    
    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var likeView: BaseView = {
        let view = BaseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_heart_gray")
        return imageView
    }()
    
    private lazy var likeLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.subText)
        label.font = Constants.Fonts.appFont(.Bold, 16)
        label.text = "LIKE".localize()
        return label
    }()
    
    private lazy var commentView: BaseView = {
        let view = BaseView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var commentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "ic_comment")
        return imageView
    }()
    
    private lazy var commentLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.appColor(.subText)
        label.font = Constants.Fonts.appFont(.Bold, 16)
        label.text = "Comment"
        return label
    }()
    
    var likeCallBack: ((String) -> Void)?
    var commentCallBack: ((String) -> Void)?

    private var item: NewsCarouselView.NewsCarouselData?
    
    // MARK: - Properties
    static let cellId = "NewsCarouselCell"

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
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(UIPadding.size24)
            make.bottom.equalToSuperview()
        }
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        
        containerView.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(148)
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp_bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp_bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        containerView.addSubview(likeIconImageView)
        likeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(20)
//            make.bottom.equalToSuperview().inset(20)
            make.width.height.equalTo(16)
        }
        
        containerView.addSubview(likeCountLabel)
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.leading.equalTo(likeIconImageView.snp.trailing).offset(4)
        }
        
        containerView.addSubview(commentCountLabel)
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
        }
        
        containerView.addSubview(separator2)
        separator2.snp.makeConstraints { make in
            make.top.equalTo(likeIconImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        containerView.addSubview(actionStackView)
        actionStackView.addArrangedSubview(likeView)
        actionStackView.addArrangedSubview(commentView)
        
        actionStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(separator2.snp.bottom)
        }
        
        likeView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        likeView.addSubview(likeImageView)
        likeView.addSubview(likeLabel)
        
        commentView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        commentView.addSubview(commentImageView)
        commentView.addSubview(commentLabel)
        
        likeImageView.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(20)
        }
        
        likeLabel.snp.makeConstraints { make in
            make.leading.equalTo(likeImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(likeImageView.snp.centerY)
        }
        
        commentImageView.snp.makeConstraints { make in
            make.width.equalTo(24)
            make.top.bottom.equalToSuperview().inset(16)
//            make.leading.equalTo(20)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.leading.equalTo(commentImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(commentImageView.snp.centerY)
        }
        
        
        likeView.addTapGestureRecognizer {
            self.likeCallBack?(self.item?.id ?? "")
        }
        
        commentView.addTapGestureRecognizer {
            self.commentCallBack?(self.item?.id ?? "")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }

    public func configure(model: NewsCarouselView.NewsCarouselData) {
        item = model
        
        if let url = URL(string: API.STATIC_RESOURCE + (model.image ?? "")) {
            CacheManager.shared.imageFor(url: url) { image, error in
                if let image = image {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
        
        timeLabel.text = model.time
        titleLabel.text = model.title
        
        commentCountLabel.text = "\(model.numberComments ) \("COMMENT".localize())"
        likeCountLabel.text = "\(model.numberLikes ) \("NUMBER_LIKES".localize() + (model.numberLikes > 1 ? "s" : ""))"
        
        if model.isLiked == IsLiked.YES.rawValue {
            likeImageView.image = UIImage(named: "ic_heart_big")
            likeLabel.textColor = .appColor(.pinkMain)
        }
        else {
            likeImageView.image = UIImage(named: "ic_heart_gray")
            likeLabel.textColor = .appColor(.subText)
        }
        
    }
}

