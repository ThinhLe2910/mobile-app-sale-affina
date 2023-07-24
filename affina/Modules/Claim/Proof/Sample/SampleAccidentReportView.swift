//
//  SampleAccidentReportView.swift
//  affina
//
//  Created by Dylan on 22/09/2022.
//

import UIKit

class SampleAccidentReportView: BaseView {
    static let nib = "SampleAccidentReportView"
    class func instanceFromNib() -> SampleAccidentReportView {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SampleAccidentReportView
    }
    
    @IBOutlet weak var containerView: BaseView!
    @IBOutlet weak var uploadButton: BaseButton!
    @IBOutlet weak var captureButton: BaseButton!
    @IBOutlet weak var understandButton: BaseButton!
    @IBOutlet weak var nopeButton: BaseButton!
    
    @IBOutlet weak var sampleTitle: BaseLabel!
    @IBOutlet weak var sampleLabel: BaseLabel!
    @IBOutlet weak var sampleImage: UIImageView!
    
    var uploadCallback: (() -> Void)?
    var captureCallback: (() -> Void)?
    var nopeCallback: (() -> Void)?
    var understandCallback: (() -> Void)?
    var downloadCallback: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(SampleAccidentReportView.nib, owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.backgroundColor = .appColor(.whiteMain)
        
//        hideButtons()

        sampleLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapNoteLabel))
        sampleLabel.addGestureRecognizer(tap)
        
        uploadButton.addTapGestureRecognizer {
            self.uploadCallback?()
        }
        
        captureButton.addTapGestureRecognizer {
            self.captureCallback?()
        }
        
        nopeButton.addTapGestureRecognizer {
            self.nopeCallback?()
        }
        
        understandButton.addTapGestureRecognizer {
            self.understandCallback?()
        }
        
        uploadButton.setTitle(uploadButton.title(for: .normal)?.capitalized, for: .normal)
        captureButton.setTitle(captureButton.title(for: .normal)?.capitalized, for: .normal)
        understandButton.setTitle(understandButton.title(for: .normal)?.capitalized, for: .normal)
    }
    
    func setNopeButtonText(_ text: String) {
        nopeButton.setTitle(text, for: .normal)
    }
    
    func setTitleNoteSampleLabel(imageUrl: String, title: String, note: String) {
        if !title.isEmpty {
            sampleTitle.text = title
            if let url = URL(string: imageUrl) {
            CacheManager.shared.imageFor(url: url) { [weak self] image, error in
                DispatchQueue.main.async {
                    self?.sampleImage.backgroundColor = .clear
                    self?.sampleImage.image = image
                }
            }
            }
            else {
                self.sampleImage.backgroundColor = .appColor(.backgroundLightGray)
            }
        }
        
        if !note.isEmpty {
            sampleLabel.removeUnderline()
            sampleLabel.attributedText = nil
            let arrText = note.components(separatedBy: "@TAI_DAY")
            let hereText = "HERE".localize().uppercased()
            if arrText.count == 1 {
                let normalText = note + " "
                let boldText = hereText
                let attrs = [
                    NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16),
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue
                ] as [NSAttributedString.Key: Any]
                let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
                let normalString = NSMutableAttributedString(string: normalText)
                attributedString.insert(normalString, at: 0)
                sampleLabel.attributedText = attributedString
                
            }
            else {
                let normalText = arrText[0]
                let boldText = arrText.count > 1 ? hereText : ""
                let attrs = [
                    NSAttributedString.Key.font: UIConstants.Fonts.appFont(.Bold, 16),
                    NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue
                ] as [NSAttributedString.Key: Any]
                let attributedString = NSMutableAttributedString(string: boldText, attributes: attrs)
                let normalString = NSMutableAttributedString(string: normalText)
                attributedString.insert(normalString, at: 0)
                sampleLabel.attributedText = attributedString
                //            sampleLabel.text = note
            }
        }
        else {
            sampleLabel.text = ""
        }
    }
    
    @objc private func didTapNoteLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = sampleLabel.attributedText?.string else { return }
        let hereRange = (text as NSString).range(of: "HERE".localize().uppercased())
        if gesture.didTapAttributedTextInLabel2(label: sampleLabel, targetRange: hereRange) {
            downloadCallback?()
        }
        else if gesture.didTapAttributedTextInLabel(label: sampleLabel, targetRange: hereRange) {
            downloadCallback?()
        }
    }
    
    func hideButtons() {
        uploadButton.hide(isImmediate: true)
        captureButton.hide(isImmediate: true)
        nopeButton.hide(isImmediate: true)
        understandButton.hide(isImmediate: true)
    }
    
    func showUploadCaptureButtons() {
        uploadButton.show()
        captureButton.show()
    }
    
    func showNopeButton() {
        nopeButton.show()
    }
    
    func showUnderstandButton() {
        understandButton.show()
    }
}
