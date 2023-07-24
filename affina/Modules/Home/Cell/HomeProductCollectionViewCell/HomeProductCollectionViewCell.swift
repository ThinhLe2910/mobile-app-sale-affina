//
//  HomeProductTableViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 14/06/2022.
//

import UIKit
import SnapKit
import SkeletonView

@IBDesignable
class HomeProductCollectionViewCell: BaseCollectionViewCell<HomeFeaturedProduct> {
    
    static let nib = "HomeProductCollectionViewCell"
    
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
    @IBOutlet weak var hotIcon: UIView!
    
    var starImages: [UIImageView] = []
    var buyCallBack: ((HomeFeaturedProduct) -> Void)?
    
    override var item: HomeFeaturedProduct? {
        didSet {
            guard let item = item else {
                return
            }
            let rate = item.rate ?? 0
            ratingLabel.text = "\(rate)"
            nameLabel.text = item.name ?? ""
            buyButton.setTitle("\((item.fee ?? 0).addComma()) đ", for: .normal)
            oldPriceLabel.text = nil // "\((item.fee + 100000).addComma()) đ"
            oldPriceLabel.strikeThrough = true
                
            for star in starImages {
                star.image = UIImage(named: "ic_star")
            }
            for i in 0..<Int(rate) {
                starImages[i].image = UIImage(named: "ic_star_fill")
            }
            
            if rate - floor(rate) > 0.5 {
                starImages[Int(rate)].image = UIImage(named: "ic_star_fill")
            }
            else if(rate - floor(rate) <= 0.5) && (rate - floor(rate) > 0) {
                starImages[Int(rate)].image = UIImage(named: "ic_star_half")
            }
            
            if item.label == 1 {
                hotIcon.isHidden = false
            } else {
                hotIcon.isHidden = true
            }
            
            if item.image == nil || item.image!.isEmpty {
                return
            }
            
            productImageView.isSkeletonable = true
            DispatchQueue.main.async {
                self.productImageView.showSkeleton()
            }
            CacheManager.shared.imageFor(url: URL(string: API.STATIC_RESOURCE + (item.image ?? ""))!) { [weak self] image, error in
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
        
        //        contentView.layer.borderWidth = 1
        //        contentView.layer.borderColor = UIColor.appColor(.black)?.cgColor
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
//        buyButton.contentVerticalAlignment = .bottom
        
        oldPriceLabel.attributedText = oldPriceLabel.text?.strikeThrough()
        
        buyButton.addTapGestureRecognizer {
            guard let item = self.item else { return }
            self.buyCallBack?(item)
        }
        cartButton.addTapGestureRecognizer {
            guard let item = self.item else { return }
            self.buyCallBack?(item)
        }
        
        hotIcon.layer.masksToBounds = true
        hotIcon.layer.cornerRadius = 16
        hotIcon.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        oldPriceLabel.text = nil
        productImageView.image = UIImage(named: "placeholder")
    }
    
    
}
