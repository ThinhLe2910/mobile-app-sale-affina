//
//  RatedStarsView.swift
//  affina
//
//  Created by Dylan on 20/10/2022.
//

import UIKit
import SnapKit

class RatedStarsView: BaseView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var stars: [UIImageView] = []
    
    var starCount: Int = 5
    var ratedStar: CGFloat = 0.0 {
        didSet {
            for star in stars {
                star.image = UIImage(named: starType == 0 ? "ic_star" : "ic_star_2")
            }
            for i in 0..<Int(ratedStar) {
                stars[i].image = UIImage(named: "ic_star_fill")
            }
            if ratedStar - floor(ratedStar) > 0.5 {
                stars[Int(ratedStar)].image = UIImage(named: "ic_star_fill")
            }
            else if(ratedStar - floor(ratedStar) <= 0.5) && (ratedStar - floor(ratedStar) > 0) {
                stars[Int(ratedStar)].image = UIImage(named: starType == 0 ? "ic_star_half" : "ic_star_half_2")
            }
            
        }
    }
    
    var starType: Int = 0 { // 0: bg white, 1: bg blue
        didSet {
            for star in stars {
                star.image = UIImage(named: starType == 0 ? "ic_star" : "ic_star_2")
            }
            for i in 0..<Int(ratedStar) {
                stars[i].image = UIImage(named: "ic_star_fill")
            }
            if ratedStar - floor(ratedStar) > 0.5 {
                stars[Int(ratedStar)].image = UIImage(named: "ic_star_fill")
            }
            if(ratedStar - floor(ratedStar) <= 0.5) && (ratedStar - floor(ratedStar) > 0) {
                stars[Int(ratedStar)].image = UIImage(named: starType == 0 ? "ic_star_half" : "ic_star_half_2")
            }
        }
    }
    
    var allowsRating: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
//        fatalError("init(coder:) has not been implemented")
    }
    

    private func initViews() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        for i in 0..<starCount {
            let star = UIImageView()
            star.image = UIImage(named: "ic_star")
            star.translatesAutoresizingMaskIntoConstraints = false
            star.tag = i
            stars.append(star)
            stackView.addArrangedSubview(star)
            star.addTapGestureRecognizer {
                if !self.allowsRating { return }
                self.ratedStar = CGFloat(i + 1)
            }
        }
        
    }
}
