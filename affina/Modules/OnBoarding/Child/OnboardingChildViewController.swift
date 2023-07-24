//
//  OnboardingChildViewController.swift
//  affina
//
//  Created by Intelin MacHD on 29/09/2022.
//

import UIKit

class OnboardingChildViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageVar = UIImage()
    @IBOutlet weak var topLabel: UILabel!
    var topLabelText = ""
    @IBOutlet weak var bottomLabel: UILabel!
    var bottomLabelText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageVar
        topLabel.text = topLabelText
        bottomLabel.text = bottomLabelText
        imageView.layer.cornerRadius = imageView.frame.height / 2
    }
}
