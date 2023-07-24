//
//  NewsItemTableViewCell.swift
//  affina
//
//  Created by Intelin MacHD on 27/07/2022.
//

import UIKit

struct NewsItemTableViewModel {
    let id: String?
    let title: String?
    let content: String?
    let date: String?
    let image: String?
    let createdAt: Int64
    var numberLikes: Int
    var numberComments: Int
    var isLiked: Int
}

class NewsItemTableViewCell: BaseTableViewCell<NewsItemTableViewModel> {

    static let nib = "NewsItemTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewImage: UIImageView!
    
    @IBOutlet weak var likeCountLabel: BaseLabel!
    @IBOutlet weak var commentLabel: BaseLabel!
    
    @IBOutlet weak var limeImageView: UIImageView!

    @IBOutlet weak var likeLabel: BaseLabel!
    @IBOutlet weak var likeView: BaseView!
    @IBOutlet weak var commentView: BaseView!
    
    var likeCallBack: (() -> Void)?
    var commentCallBack: (() -> Void)?
    
    override var item: NewsItemTableViewModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            titleLabel.text = item.title
            contentLabel.attributedText = item.content?.htmlToAttributedString

            dateLabel.text = item.date
            if let url = URL(string: API.STATIC_RESOURCE + (item.image ?? "")) {
                CacheManager.shared.imageFor(url: url) { image, error in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.viewImage.image = image
                        }
                        
                    }
                }
            }
            
            commentLabel.text = "\(item.numberComments) \("COMMENT".localize())"
            likeCountLabel.text = "\(item.numberLikes) \("NUMBER_LIKES".localize() + (item.numberLikes > 1 ? "s" : ""))"
            
            if item.isLiked == IsLiked.YES.rawValue {
                limeImageView.image = UIImage(named: "ic_heart_big")
                likeLabel.textColor = .appColor(.pinkMain)
            }
            else {
                limeImageView.image = UIImage(named: "ic_heart_gray")
                likeLabel.textColor = .appColor(.subText)
            }
            
            likeView.addTapGestureRecognizer {
//                guard let item = self.item else {
//                    return
//                }
                self.likeCallBack?()
            }
            
            commentView.addTapGestureRecognizer {
                self.commentCallBack?()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    
    private func initViews() {
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 20
        layer.masksToBounds = true
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        contentLabel.text = nil
        dateLabel.text = nil
        viewImage.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }
}
