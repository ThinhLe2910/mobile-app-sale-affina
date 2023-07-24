//
//  RangeSlider.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 09/08/2022.
//

import UIKit
import QuartzCore
@IBDesignable
class RangeSlider: UIControl {
    
    @IBInspectable var minimumValue = 0.0
    @IBInspectable var maximumValue = 1.0
    @IBInspectable var lowerValue = 0.0
    @IBInspectable var upperValue = 1.0
    
    let trackLayer = RangeSliderTrackLayer()//= CALayer() defined in RangeSliderTrackLayer.swift
    let lowerThumbLayer = RangeSliderThumbLayer()//CALayer()
    let upperThumbLayer = RangeSliderThumbLayer()//CALayer()
    var previousLocation = CGPoint()
    
    var trackTintColor = UIColor.appColor(.blueSlider)!
    var trackHighlightTintColor = UIColor.appColor(.blueMain)!
    var thumbTintColor = UIColor.white
    
    var curvaceousness : CGFloat = 1.0
    
    var thumbWidth: CGFloat {
        return bounds.height
    }
    
    func commonInit() {
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func updateLayerFrames() {
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(value: lowerValue))
        lowerThumbLayer.frame = CGRect(
            x: lowerThumbCenter - thumbWidth / 2.0 == 0 ? -2 : (lowerThumbCenter - thumbWidth / 2.0 == (bounds.width - thumbWidth) ? (bounds.width - thumbWidth + 2) : (lowerThumbCenter - thumbWidth / 2.0)),
            y: 0.0, width: thumbWidth, height: thumbWidth
        )
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(value: upperValue))
        upperThumbLayer.frame = CGRect(
            x: upperThumbCenter - thumbWidth / 2.0 == (bounds.width - thumbWidth) ? (bounds.width - thumbWidth + 2) : (upperThumbCenter - thumbWidth / 2.0 == 0 ? -2 : (upperThumbCenter - thumbWidth / 2.0)),
            y: 0.0, width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) / (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if lowerThumbLayer.frame.contains(previousLocation) && upperThumbLayer.frame.contains(previousLocation) {
            if previousLocation.x <= thumbWidth {
                upperThumbLayer.highlighted = true
            }
            else if previousLocation.x >= (bounds.width - thumbWidth) {
                lowerThumbLayer.highlighted = true
            }
            else { // default if they overlaps each other
                upperThumbLayer.highlighted = true
            }
        }
        // Hit test the thumb layers
        else if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        previousLocation = location
        
        // 2. Update the values
        if lowerThumbLayer.highlighted {
            lowerValue += deltaValue
            lowerValue = boundValue(value: lowerValue, toLowerValue: minimumValue, upperValue: upperValue)
        } else if upperThumbLayer.highlighted {
            upperValue += deltaValue
            upperValue = boundValue(value: upperValue, toLowerValue: lowerValue, upperValue: maximumValue)
        }
        
        // 3. Update the UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
