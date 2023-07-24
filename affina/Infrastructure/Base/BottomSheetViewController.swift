//
//  BottomSheetViewController.swift
//  affina
//
//  Created by Intelin MacHD on 13/08/2022.
//

import UIKit
import SnapKit

class BottomSheetViewController: UIViewController {

    private var currentHeight: CGFloat
    var topBarView = UIView()
    var topView = UIView()
    
    init(initialHeight: CGFloat) {
        currentHeight = initialHeight
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = .red
        // Do any additional setup after loading the view.
        updateContentHeight(newValue: currentHeight)
        initView()
    }
    
    private func initView() {
        self.view.backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            self.view.layer.cornerRadius = 20
            self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        self.view.layer.shadowColor = UIColor.black.cgColor
                self.view.layer.shadowOffset = .init(width: 0, height: -2)
                self.view.layer.shadowRadius = 20
                self.view.layer.shadowOpacity = 0.5
        topView.addSubview(topBarView)
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        topBarView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(100)
            make.height.equalTo(7)
        }
        topBarView.layer.cornerRadius = 5
        topBarView.backgroundColor = .black
    }
    
    func setContentForBottomSheet(_ view: UIView) {
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(topBarView.snp_bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func updateContentHeight(newValue: CGFloat) {
        guard newValue >= 200 && newValue < 5000 else { return }
        
        currentHeight = newValue
        UIView.animate(
            withDuration: 0.25,
            animations: { [self] in
                preferredContentSize = CGSize(
                    width: UIScreen.main.bounds.width,
                    height: newValue
                )
            }
        )
    }
}
