//
//  CardInsuranceClaimCollectionViewCell.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/01/2023.
//

import UIKit
import CollectionViewPagingLayout
import SnapKit

// MARK: CardInsuranceClaimCollectionViewCell
class CardInsuranceClaimCollectionViewCell: UICollectionViewCell, ScaleTransformView {
    
//    static let size = CGSize(width: UIConstants.Layout.screenWidth - 32 * 2, height: 212.height)
    static let size = CGSize(width: 370.width, height: 212.height)
    
    static let cellId = "CardInsuranceClaimCollectionViewCell"

    var scaleOptions = ScaleTransformViewOptions(
        minScale: 0.6,
        maxScale: 1.00,
        scaleRatio: 0.3,
        translationRatio: .init(x: 0.75, y: 0.20),
        minTranslationRatio: .init(x: -5.00, y: -5.00),
        maxTranslationRatio: .init(x: 2.00, y: 0.00),
        keepVerticalSpacingEqual: true,
        keepHorizontalSpacingEqual: true,
        scaleCurve: .linear,
        translationCurve: .linear,
        shadowEnabled: true,
        shadowColor: .black,
        shadowOpacity: 0.60,
        shadowRadiusMin: 2.00,
        shadowRadiusMax: 13.00,
        shadowOffsetMin: .init(width: 0.00, height: 2.00),
        shadowOffsetMax: .init(width: 0.00, height: 6.00),
        shadowOpacityMin: 0.10,
        shadowOpacityMax: 0.10,
        blurEffectEnabled: false,
        blurEffectRadiusRatio: 0.40,
        blurEffectStyle: .light,
        rotation3d: nil,
        translation3d: nil
    )
    
    private lazy var card: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 28
        return view
    }()
    
    lazy var bgCardView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        
        return imageView
    }()
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logoText")?.withRenderingMode(.alwaysTemplate)
        return imageView
    }()
    
    private lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.tintColor = .black
        imageView.image = generateQRCode(from: "AFFINA")
        return imageView
    }()
    
    private lazy var titleLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bảo hiểm tai nạn".uppercased()
        label.font = UIConstants.Fonts.appFont(.Bold, 16)
        label.textColor = UIColor.appColor(.black)
        return label
    }()
    
    private lazy var customerLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Vũ đình khánh phương".uppercased()
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        return label
    }()
    
    private lazy var dateLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\("DURATION".localize()):\n30/07/23"
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var numberLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "9087654321"
        label.font = UIConstants.Fonts.appFont(.Bold, 22, fontName: "DarkerGrotesque")
        label.textColor = UIColor.appColor(.black)
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        //        label.textAlignment = .center
        return label
    }()
    
    private lazy var label: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "REMAINING_LIMIT".localize()
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        
        return label
    }()
    
    private lazy var moneyLabel: BaseLabel = {
        let label = BaseLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "400.000.000 VND"
        label.font = UIConstants.Fonts.appFont(.Bold, 12)
        label.textColor = UIColor.appColor(.black)
        return label
    }()
    
    var backgroundAsset: UIColor? = UIColor.appColor(.blue) {
        didSet {
            card.backgroundColor = UIColor(hex: "#F7E5FF") // backgroundAsset
        }
    }
    
    var tintColorAsset: UIColor? = UIColor.appColor(.black) {
        didSet {
            logoImageView.tintColor = tintColorAsset
            customerLabel.textColor = tintColorAsset
            label.textColor = tintColorAsset
            numberLabel.textColor = tintColorAsset
            moneyLabel.textColor = tintColorAsset
            dateLabel.textColor = tintColorAsset
            titleLabel.textColor = tintColorAsset
        }
    }
    
    private var customViews: [UIView] = []
    
    var editCallBack: (() -> Void)?
    
    var item: CardModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            titleLabel.text = item.programName
            dateLabel.text = "\("DURATION".localize()):\n" + "\(item.contractEndDate/1000)".timestampToFormatedDate(format: "dd/MM/yy")
            moneyLabel.text = "\(item.maximumAmount.addComma()) VND"
            customerLabel.text = item.peopleName.uppercased()
            numberLabel.text = item.cardNumber // contractObjectIdProvider
            
            numberLabel.sizeToFit()
            
            DispatchQueue.main.async {
                var textHeight = (item.cardNumber ?? "").uppercased().heightWithConstrainedWidth(width: self.numberLabel.frame.width, font: self.numberLabel.font)
                textHeight = textHeight >= 72 ? 72 : textHeight
                self.customerLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(88 + textHeight - 36)
                }
                self.dateLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(108 + textHeight - 36)
                }
                self.label.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(108 + textHeight - 36)
                }
                self.moneyLabel.snp.updateConstraints { make in
                    make.top.equalToSuperview().inset(124 + textHeight - 36)
                }
                
                self.qrImageView.image = self.generateQRCode(from: item.cardNumber ?? "AFFINA")
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    
    func initViews() {
        contentView.backgroundColor = .clear
        contentView.addSubview(card)
        
        card.addSubview(bgCardView)
        
        card.addSubview(logoImageView)
        card.addSubview(qrImageView)
        
        card.addSubview(titleLabel)
        card.addSubview(dateLabel)
        card.addSubview(numberLabel)
        card.addSubview(customerLabel)
        card.addSubview(label)
        card.addSubview(moneyLabel)
        
        card.backgroundColor = .appColor(.blue)
        tintColorAsset = .appColor(.black)
        
    }
    
    func setupConstraints() {
        card.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            //            make.width.equalToSuperview().offset(-40)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        bgCardView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size24)
            make.trailing.equalToSuperview().inset(UIPadding.size8)
            make.height.equalTo(12)
        }
        
        qrImageView.snp.makeConstraints { make in
//            make.top.equalTo(logoImageView.snp_bottom).offset(UIPadding.size16)
            make.top.equalToSuperview().inset(12 + 24 + UIPadding.size16)
            make.trailing.equalToSuperview().inset(UIPadding.size8)
            make.width.height.equalTo(96.height)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size24)
//            make.centerY.equalTo(logoImageView.snp_centerY)
            make.leading.equalToSuperview().offset(UIPadding.size16)
            make.trailing.equalToSuperview().inset(96.height + 8 + 8)
//            make.trailing.equalTo(qrImageView.snp_leading).offset(UIPadding.size8)
        }
        
        numberLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIPadding.size48)
//            make.top.equalTo(titleLabel.snp_bottom).offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(UIPadding.size16)
            make.trailing.equalToSuperview().inset(96.height + 8 + 8)
//            make.trailing.equalTo(qrImageView.snp_leading).offset(-UIPadding.size8)
        }
        
        customerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(128)
//            make.top.equalTo(numberLabel.snp_bottom)///.offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(UIPadding.size16)
            make.trailing.equalToSuperview().inset(96.height + 8 + 16)
//            make.trailing.equalTo(qrImageView.snp_leading).offset(UIPadding.size8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(148.height)
//            make.top.equalTo(customerLabel.snp_bottom).offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(144)
//            make.leading.equalTo(moneyLabel.snp_trailing).offset(UIPadding.size8)
            make.trailing.equalTo(qrImageView.snp_leading).offset(-UIPadding.size8)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(148.height)
//            make.top.equalTo(customerLabel.snp_bottom).offset(UIPadding.size8)
            make.leading.equalToSuperview().inset(UIPadding.size16)
//            make.leading.equalTo(customerLabel.snp_leading)
        }
        
        moneyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(164)
//            make.top.equalTo(label.snp_bottom)
//            make.leading.equalTo(label.snp_leading)
            make.leading.equalToSuperview().inset(UIPadding.size16)
//            make.bottom.equalToSuperview().offset(-UIPadding.size16)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bgCardView.image = nil
        customerLabel.isHidden = false
        label.isHidden = false
        moneyLabel.isHidden = false
        titleLabel.isHidden = false
        numberLabel.isHidden = false
        dateLabel.isHidden = false
        logoImageView.isHidden = false
        qrImageView.isHidden = false
        customViews.forEach { view in
            view.removeFromSuperview()
        }
        customViews = []
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setDefaults()
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                let colorParameters = [
                    "inputColor0": CIColor(color: UIColor.black), // Foreground
                    "inputColor1": CIColor(color: UIColor.clear) // Background
                ]
                let colored = output.applyingFilter("CIFalseColor", parameters: colorParameters)
                
                return UIImage(ciImage: colored)
            }
        }
        
        return nil
    }
    
    // MARK: updateCardLayout
    func updateCardLayout(_ layouts: [ListSetupCardOrder]) {

        label.isHidden = true
        moneyLabel.isHidden = true
        titleLabel.isHidden = true
        numberLabel.isHidden = true
        customerLabel.isHidden = true
        qrImageView.isHidden = true
        dateLabel.isHidden = true
        logoImageView.isHidden = true
        
        customViews.forEach { view in
            view.removeFromSuperview()
        }
        customViews = []
        
//        for card in APIManager.shared.setupModel?.listCard ?? [] {
//            if card.majorID == item?.majorId && card.companyID == item?.companyProvider && card.programID ==  item?.programId && card.programTypeID == item?.programTypeId {
                
                if let url = URL(string: API.STATIC_RESOURCE + (layouts[0].background ?? "")) {
                    CacheManager.shared.imageFor(url: url) { image, error in
                        if error != nil {
                            self.bgCardView.image = nil
                            return
                        }
                        DispatchQueue.main.async {
                            self.bgCardView.image = image
                        }
                    }
                }
//                else {
//                    self.bgCardView.image = nil
//                }
//                break
//        }
//        }
        
        for layout in layouts {
            for field in layout.listCardOrderField ?? [] where layout.orderCard == 1 {
                if field.fieldType == CardFieldTypeEnum.Fixed.rawValue {
//                    let label = BaseLabel(frame: .init(x: 0, y: 0, width: CardInsuranceClaimCollectionViewCell.size.width, height: 20))
//                    //                        label.translatesAutoresizingMaskIntoConstraints = false
//                    card.addSubview(label)
//                    label.text = field.fieldFixedName
//                    updateViewPos(view: label, field: field)
                    let label = LayoutBuilder.shared.createLabel(view: card, labelSize: .init(width: CardInsuranceClaimCollectionViewCell.size.width, height: 30), text: field.fieldFixedName, field: field, designSize: CardInsuranceClaimCollectionViewCell.size)
                    customViews.append(label)
                }
                else {
                    if let fieldVariable = field.fieldVariable {
                        let label = LayoutBuilder.shared.getCreatedLabel(fieldVariable, view: card, labelSize: .init(width: CardInsuranceClaimCollectionViewCell.size.width, height: 30), item: item, field: field, designSize: CardInsuranceClaimCollectionViewCell.size)
                        customViews.append(label)
                    }
                }
            }
        }
    }
}
