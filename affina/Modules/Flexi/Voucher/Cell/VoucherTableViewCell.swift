//
//  VoucherTableViewCell.swift
//  affina
//
//  Created by Dylan on 20/10/2022.
//

import UIKit

//class VoucherTableViewCell: UITableViewCell {
class VoucherTableViewCell: PaddingTableViewCell {
    
    static let identifier = "VoucherTableViewCell"
    
    @IBOutlet weak var view: BaseView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: BaseLabel!
    @IBOutlet weak var dateLabel: BaseLabel!
    @IBOutlet weak var usedLabel: BaseLabel!
    
    @IBOutlet weak var addButton: BaseButton!
    @IBOutlet weak var addedView: BaseView!
    
    @IBOutlet weak var nameLabelTrailingConstraint: NSLayoutConstraint!
    
    var isSelectingMode: Bool = false {
        didSet {
            addButton.isHidden = !isSelectingMode
            addedView.isHidden = !isSelectingMode
            nameLabelTrailingConstraint.constant = isSelectingMode ? 44 : 12
        }
    }
    
    var isAdded: Bool = false {
        didSet {
            addButton.isHidden = isAdded
            addedView.isHidden = !isAdded
        }
    }
    
    var isUsed: Bool = false {
        didSet {
            setUsedStatus()
        }
    }
    
    var item: MyVoucherModel? {
        didSet {
            guard let item = item else { return }
            
            nameLabel.text = item.voucherName
            dateLabel.text = "\("EXPIRE_DATE".localize()): " + "\((item.expiredAt ?? 0)/1000)".timestampToFormatedDate(format: "dd.MM.yyyy")
            dateLabel.isHidden = item.expiredAt == nil
            if let _ = item.providerID, let image = item.voucherImage, !image.isEmpty,
                let url = URL(string: image) {
                CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                    if let error = error {
                        Logger.Logs(event: .error, message: error)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.iconImageView.image = self?.isUsed ?? false ? image?.grayScaled : image
                    }
                }
                return
            }
            else {
                var images: [String: String] = [:]
                if let image = item.voucherImage, !image.isEmpty, let data = image.data(using: .utf8) {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: String]
                        images = json ?? [:]
                    } catch {
                        Logger.Logs(message: "Something went wrong")
                    }
                }
                guard let url = URL(string: API.STATIC_RESOURCE + (images["image_1"] ?? "")) else {
                    DispatchQueue.main.async {
                        self.iconImageView.hideSkeleton()
                    }
                    return
                }
                CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                    DispatchQueue.main.async {
                        self?.iconImageView.hideSkeleton()
                    }
                    if error != nil {
                        DispatchQueue.main.async {
                            self?.iconImageView.image = UIImage(named: "placeholder")
                        }
                        Logger.Logs(event: .error, message: error?.localizedDescription ?? "Cache Image Error")
                        return
                    }
                    DispatchQueue.main.async {
                        self?.iconImageView.image = image == nil ? UIImage(named: "voucher_gift") : image
                    }
                }
            }
            
        }
    }
    
    var addCallback: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        view.backgroundColor = .appColor(.whiteMain)
        view.layer.cornerRadius = 16
        
        inset = .init(top: 0, left: 0, bottom: 12, right: 0)
        
        addButton.addTapGestureRecognizer {
            if !self.isSelectingMode { return }
            self.isAdded = true
            self.addCallback?(true)
        }
        
        addedView.addTapGestureRecognizer {
            if !self.isSelectingMode { return }
            self.isAdded = false
            self.addCallback?(false)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = UIImage(named: "placeholder")
        isAdded = false
        isSelectingMode = false
        dateLabel.isHidden = false
        nameLabelTrailingConstraint.constant = 12
    }
    
    private func setUsedStatus() {
        if isUsed {
            dateLabel.textColor = .appColor(.subText)
            usedLabel.isHidden = false
        }
        else {
            dateLabel.textColor = .appColor(.black)
            usedLabel.isHidden = true
            
        }
        
        if item?.isUse == 0 {
            usedLabel.text = "EXPIRED".localize().uppercased()
        } else {
            usedLabel.text = "USED".localize().uppercased()
        }
        var urlString = ""
        if item?.voucherImage?.contains("http") != false {
            urlString = item?.voucherImage ?? ""
        } else {
            if let jsonArray = try? JSONDecoder().decode([String: String].self, from: (item?.voucherImage ?? "").data(using: .utf16) ?? Data()) {
                urlString = API.STATIC_RESOURCE + (jsonArray["image_1"] ?? "")
            }
        }
        
        guard let url = URL(string: (urlString)) else { return }
        CacheManager.shared.imageFor(url: url) { [weak self] image, error in
            if let error = error {
                Logger.Logs(event: .error, message: error)
                return
            }
            DispatchQueue.main.async {
                self?.iconImageView.image = self?.isUsed ?? false ? image?.noir : image
            }
        }
    }
    
    func grayscale(image: UIImage) -> UIImage? {
        guard let currentCGImage = image.cgImage else { return nil }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        
        // set a gray value for the tint color
        filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
        
        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext()
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            print(processedImage.size)
            return processedImage
        }
        return nil
    }
}
