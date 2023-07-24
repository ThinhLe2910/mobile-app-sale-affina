//
//  AlertService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 12/05/2022.
//

import UIKit

class AlertService {
    
    static func showToast(message: String, controller: UIViewController? = UIApplication.topViewController(), font: UIFont? = nil) {
        guard let controller = controller else { return }
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 8;
        toastContainer.clipsToBounds  =  true

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = .systemFont(ofSize: 12, weight: .medium)
        if font != nil {
            toastLabel.font = font!
        }
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        toastLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.top.equalToSuperview().inset(15)
        }
        
        toastContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview().inset(65)//.equalToSuperview().inset(65)
            make.bottom.equalToSuperview().inset(75)
            
        }

        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
    
    static func showAlert(style: UIAlertController.Style, title: String?, message: String?, actions: [UIAlertAction] = [UIAlertAction(title: "AGREE".localize(), style: .cancel, handler: nil)], completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { action in
            alert.addAction(action)
        }
        if let topVC = UIApplication.topViewController() {
            alert.popoverPresentationController?.sourceView = topVC.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
            alert.popoverPresentationController?.permittedArrowDirections = []
            alert.pruneNegativeWidthConstrants()
            topVC.present(alert, animated: true, completion: completion)
        }
    }
}
