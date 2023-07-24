//
//  RangeSliderTrackLayer.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit
import QuartzCore

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            let height: CGFloat = 4.0 // bounds.height
            let y: CGFloat = bounds.height/2 - 2.0 // 0.0
            // Clip
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: .init(x: 0, y: y, width: bounds.width, height: height), cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)
            
            // Fill the track
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            // Fill the highlighted range
            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            let lowerValuePosition =  CGFloat(slider.positionForValue(value: slider.lowerValue))
            let upperValuePosition = CGFloat(slider.positionForValue(value: slider.upperValue))
            let rect = CGRect(x: lowerValuePosition, y: y, width: upperValuePosition - lowerValuePosition, height: height)
            ctx.fill(rect)
        }
    }
}
