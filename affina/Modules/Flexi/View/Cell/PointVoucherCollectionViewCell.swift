//
//  PointVoucherCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import SnapKit
import SkeletonView

@IBDesignable
class PointVoucherCollectionViewCell: BaseCollectionViewCell<VoucherModel> {
    
    static let nib = "PointVoucherCollectionViewCell"
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var oldPriceLabel: BaseLabel!
    @IBOutlet weak var buyButton: BaseButton!
    @IBOutlet weak var cartButton: BaseButton!
    @IBOutlet weak var starImage1: UIImageView!
    @IBOutlet weak var starImage2: UIImageView!
    @IBOutlet weak var starImage3: UIImageView!
    @IBOutlet weak var starImage4: UIImageView!
    @IBOutlet weak var starImage5: UIImageView!
    
    var starImages: [UIImageView] = []
    var buyCallBack: ((VoucherModel) -> Void)?
    
    var cellType: FlexiCategoryViewType = .voucher
    
    override var item: VoucherModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            nameLabel.text = item.voucherName
            buyButton.setTitle("\((item.price ?? 0).addComma()) \(cellType == .voucher ? "COIN".localize().capitalized : "POINT".localize().capitalized)", for: .normal)
//            oldPriceLabel.text = "\((item.fee + 100000).addComma()) điểm"
//            oldPriceLabel.strikeThrough = true
            buyButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            buyButton.contentVerticalAlignment = .center
            
            oldPriceLabel.hide()
            
            let ratings: CGFloat = CGFloat(CGFloat(item.totalRatingPoint ?? 0)/CGFloat(item.totalRating ?? 1))
            ratingLabel.text = "\(ratings)"
            ratingLabel.font = UIConstants.Fonts.appFont(.Semibold, 12.height)
            for star in starImages {
                star.image = UIImage(named: "ic_star")
            }
            for i in 0..<Int(ratings) {
                starImages[i].image = UIImage(named: "ic_star_fill")
            }

            if ratings - floor(ratings) > 0.5 {
                starImages[Int(ratings)].image = UIImage(named: "ic_star_fill")
            }
            else if(ratings - floor(ratings) <= 0.5) && (ratings - floor(ratings) > 0) {
                starImages[Int(ratings)].image = UIImage(named: "ic_star_half")
            }
            
            if let _ = item.providerId {
                productImageView.isSkeletonable = true
                DispatchQueue.main.async {
                    self.productImageView.showSkeleton()
                }
                if let image = item.image, let url = URL(string: image) {
                    CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                        DispatchQueue.main.async {
                            self?.productImageView.hideSkeleton()
                        }
                        if error != nil {
                            DispatchQueue.main.async {
                                self?.productImageView.image = UIImage(named: "placeholder")
                            }
                            Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                            return
                        }
                        DispatchQueue.main.async {
                            self?.productImageView.image = image
                        }
                    }
                }
                return
            }
            
            if item.images == nil || item.images!.isEmpty {
                return
            }
            
            productImageView.isSkeletonable = true
            DispatchQueue.main.async {
                self.productImageView.showSkeleton()
            }
            var images: [String: String] = [:]
            if let data = item.images?.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String]
                    images = json ?? [:]
                } catch {
                    Logger.Logs(message: "Something went wrong")
                }
            }
            CacheManager.shared.imageFor(url: URL(string: API.STATIC_RESOURCE + (images["image_1"] ?? ""))!) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.productImageView.hideSkeleton()
                }
                if error != nil {
                    DispatchQueue.main.async {
                        self?.productImageView.image = UIImage(named: "placeholder")
                    }
                    Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                    return
                }
                DispatchQueue.main.async {
                    self?.productImageView.image = image
                }
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            contentView.layer.cornerRadius = cornerRadius
            contentView.layer.masksToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        starImages = [starImage1, starImage2, starImage3, starImage4, starImage5]
        
        contentView.backgroundColor = UIColor.appColor(.whiteMain)
        if #available(iOS 11.0, *) {
            buyButton.layer.masksToBounds = true
            buyButton.layer.cornerRadius = 8
            buyButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
            buyButton.roundCorners([.topLeft, .bottomLeft], radius: 8)
        }
        
        if #available(iOS 11.0, *) {
            productImageView.layer.masksToBounds = true
            productImageView.layer.cornerRadius = 16
            productImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
            productImageView.roundCorners([.topRight, .topLeft], radius: 16)
        }
        
        cartButton.roundCorners([.topRight, .bottomRight], radius: 8)
        cartButton.tintColor = UIColor.appColor(.black)
        buyButton.contentVerticalAlignment = .bottom
        
        oldPriceLabel.attributedText = oldPriceLabel.text?.strikeThrough()
        
        buyButton.addTapGestureRecognizer {
            guard let item = self.item else { return }
            self.buyCallBack?(item)
        }
        cartButton.addTapGestureRecognizer {
            guard let item = self.item else { return }
            self.buyCallBack?(item)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    
}
