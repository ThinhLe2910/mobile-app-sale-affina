//
//  PointVoucherBigCollectionViewCell.swift
//  affina
//
//  Created by Dylan on 18/10/2022.
//

import UIKit
import SnapKit

class PointVoucherBigCollectionViewCell: BaseCollectionViewCell<VoucherModel> {
    
    static let nib = "PointVoucherBigCollectionViewCell"
    
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
    
    @IBOutlet weak var typeView: BaseView!
    @IBOutlet weak var typeLabel: BaseLabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var starImages: [UIImageView] = []
    var buyCallBack: ((VoucherModel) -> Void)?
    var cellType: FlexiCategoryViewType = .voucher
    
    override var item: VoucherModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            if let discountApplyType = item.discountApplyType {
                typeView.isHidden = false
                typeLabel.text = discountApplyType == 0 ? "Voucher" : "DISCOUNT".localize()
                typeView.backgroundColor = .appColor(discountApplyType == 0 ? .orange : .pinkLighter)
                typeLabel.textColor = .appColor(discountApplyType == 0 ? .black : .whiteMain)
            }
            else {
                typeView.isHidden = true
            }
            
            nameLabel.text = item.voucherName
            buyButton.setTitle("\((item.price ?? 0).addComma()) \(cellType == .voucher ? "COIN".localize().capitalized : "POINT".localize().capitalized)", for: .normal)
            //            oldPriceLabel.text = "\((item.fee + 100000).addComma()) điểm"
            //            oldPriceLabel.strikeThrough = true
            buyButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            buyButton.contentVerticalAlignment = .center
    
            oldPriceLabel.hide()
            
            let ratings: CGFloat = CGFloat((item.totalRatingPoint ?? 0)/(item.totalRating ?? 1))
            ratingLabel.text = "\(ratings)"
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
            CacheManager.shared.imageFor(url: URL(string: API.STATIC_RESOURCE + (images["imageLong_1"] ?? ""))!) { [weak self] image, error in
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
        imageHeightConstraint.constant = 148.height
        
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
        
        typeView.backgroundColor = UIColor(hex: "FFDD65") // FF75E2
        if #available(iOS 11.0, *) {
            typeView.layer.masksToBounds = true
            typeView.layer.cornerRadius = 8
            typeView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        } else {
            // Fallback on earlier versions
            typeView.roundCorners([.topRight, .bottomRight], radius: 8)
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
        
        typeView.isHidden = true
    }
    
    
}
