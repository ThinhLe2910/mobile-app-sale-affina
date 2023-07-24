//
//  FeedbackViewController.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 22/06/2022.
//

import UIKit

class FeedbackViewController: BaseViewController {
    
    static let nib = "FeedbackViewController"
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var submitButton: BaseButton!
    
    let placeholder = "Nhap y kien"
    let start = NSRange(location: 0, length: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
//        hideHeaderBase()
        
        title = "Phản hồi ý kiến"
        
        containerBaseView.hide()
        
        textView.delegate = self
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 4
        textView.text = placeholder
        textView.textColor = UIColor.lightGray
        
        submitButton.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
    }
    
    @objc private func didTapSubmitButton() {
        
    }
    
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}
