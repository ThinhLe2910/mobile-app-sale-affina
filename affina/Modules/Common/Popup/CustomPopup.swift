//
//  CustomPopup.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 06/07/2022.
//

import UIKit

@IBDesignable
class CustomPopup: UIView {

    static let nib = "CustomPopup"

    class func instanceFromNib() -> CustomPopup {
        return UINib(nibName: self.nib, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomPopup
    }

    @IBOutlet weak var nextButton: BaseButton!
    @IBOutlet weak var backButton: BaseButton!
    @IBOutlet weak var label: BaseLabel!
    @IBOutlet weak var caretView: BaseView!
    @IBOutlet weak var caretCenterXConstraint: NSLayoutConstraint!

    private var defaultPos: CGFloat = 0.0

    var callBack: (() -> Void)? = nil
    var positions: [CGPoint] = []
    var posTypes: [CaretPosition] = []
    var caretPos: [CGPoint] = []
    var messages: [String] = []
    var curIndex: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()

        dropShadow(color: .init(r: 1, g: 9, b: 83, a: 1), opacity: 0.12, offset: .init(width: 0, height: 8), radius: 16, scale: true)
        defaultPos = caretCenterXConstraint.constant

        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }

    func updateCaretPosition(_ posType: CaretPosition) {
        let delta = posType == .right ? (frame.width / 2 - 16 - 15) : (posType == .left ? 36 : 0)

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.caretCenterXConstraint.constant = self.defaultPos + delta
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    func updateCaretPosition(_ caretPos: CGPoint) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.caretCenterXConstraint.constant = 0 + caretPos.x
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }

    @objc func didTapNextButton() {
        if curIndex >= positions.count - 1 {
            callBack?()
            return
        }
        DispatchQueue.main.async {
            if self.curIndex == 0 {
                self.backButton.show()
            }

            self.curIndex += 1
            self.updatePopupInfo()
            self.frame.origin = self.positions[self.curIndex]

        }
    }
    
    func updatePopupInfo() {
        label.text = messages[curIndex]
        
        if posTypes.isEmpty {
            updateCaretPosition(caretPos[curIndex])
            return
        }
        
        updateCaretPosition(posTypes[curIndex])
    }

    @objc func didTapBackButton() {
        if curIndex == 0 {
            return
        }

        DispatchQueue.main.async {
            self.curIndex -= 1

            if self.curIndex == 0 {
                self.backButton.hide(isImmediate: true)
            }
            
            self.updatePopupInfo()
            self.frame.origin = self.positions[self.curIndex]
        }
    }

}
