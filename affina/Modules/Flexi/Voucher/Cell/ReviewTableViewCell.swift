//
//  ReviewTableViewCell.swift
//  affina
//
//  Created by Dylan on 20/10/2022.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    static let identifier = "ReviewTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: BaseLabel!
    @IBOutlet weak var commentLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    
    @IBOutlet weak var ratedStarsView: RatedStarsView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    private var images: [String] = []
    
    var item: VoucherRatingModel? {
        didSet {
            guard let item = item else { return }
            
            usernameLabel.text = item.name
            commentLabel.text = item.comment
            
            ratedStarsView.ratedStar = CGFloat(item.ratingPoint ?? 0)
            
            let commentDate = "\(item.createdAt/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            
            let distance = Date().timeIntervalSince1970 * 1000 - item.createdAt
            let minutes = Int(distance/1000/60)
            let hours = Int(floor((minutes / 60) > 0 ? Double((minutes / 60)) : 0))
            let days = Int(floor((hours / 24) > 0 ? Double((hours / 24)) : 0))
            
            if distance <= 60000 {
                dateLabel.text = "Vừa xong"
            }
            else if distance > 60000 && distance < 86400 * 1000 {
                dateLabel.text = "\(hours > 0 ? "\(hours) " + "HOURS_AGO".localize() : "\(minutes) " + "MINUTES_AGO".localize())"
            }
            else if distance < 86400 * 1000 * 7 {
                dateLabel.text = "\(days > 0 ? ("\(days) " + "DAYS_AGO".localize()) : "")"
            }
            else {
                dateLabel.text = "\(item.createdAt/1000)".timestampToFormatedDate(format: "dd/MM/yyyy")
            }
            
            if let data = item.images?.data(using: .utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String]
                    images = json ?? []
                    imageCollectionView.reloadData()
                } catch {
                    Logger.Logs(message: "Something went wrong")
                }
            }
            
            if let url = URL(string: API.STATIC_RESOURCE + (item.avatar ?? "")) {
                CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                    if error != nil {
                        DispatchQueue.main.async {
                            self?.avatarImageView.image = nil
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self?.avatarImageView.image = image
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: AttachedImageCollectionViewCell.nib, bundle: nil), forCellWithReuseIdentifier: AttachedImageCollectionViewCell.cellId)
        
        ratedStarsView.ratedStar = 3.2
        ratedStarsView.starType = 1
    }
    
    
}

extension ReviewTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachedImageCollectionViewCell.cellId, for: indexPath) as? AttachedImageCollectionViewCell else { return UICollectionViewCell() }
        if let url = URL(string: API.STATIC_RESOURCE + images[indexPath.row]) {
            CacheManager.shared.imageFor(url: url) { image, error in
                if error != nil {
                    cell.setImage(nil)
                    return
                }
                DispatchQueue.main.async {
                    cell.setImage(image)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
