//
//  RangeSlider.swift
//  CustomSliderExample
//
//  Created by William Archimede on 04/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderTrackLayer: CALayer {
    unowned let slider:RangeSlider
    
    init(slider:RangeSlider) {
        self.slider = slider
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        
        let padding = slider.thumbWidth/2 + slider.sublayerPadding
        let width = bounds.size.width - slider.thumbWidth - slider.sublayerPadding*2
        
        // Clip
        let path = UIBezierPath(roundedRect: CGRectMake(padding, 0, width, bounds.height), cornerRadius: bounds.width)
        CGContextAddPath(ctx, path.CGPath)
        
        // Fill the track
        CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
        CGContextAddPath(ctx, path.CGPath)
        CGContextFillPath(ctx)
        
        // Fill the highlighted range
        CGContextSetFillColorWithColor(ctx, slider.trackHighlightTintColor.CGColor)
        let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
        let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
        let rect = CGRect(x: lowerValuePosition, y: 0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
        let highlightPath = UIBezierPath(roundedRect: rect, cornerRadius: bounds.width)
        CGContextAddPath(ctx, highlightPath.CGPath)
        CGContextFillPath(ctx)
        
        // Add Ellipse
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor);
        let count = 10
        let spacing:CGFloat = width/CGFloat(count)
        let ellipseWidth = bounds.height
        for i in 0...count {
            CGContextFillEllipseInRect(ctx, CGRect(origin: CGPoint(x: spacing*CGFloat(i) + padding - ellipseWidth/2, y: 0), size: CGSize(width: ellipseWidth, height: ellipseWidth)))
        }
    }
}

class RangeSliderThumbLayer: CALayer {
    var highlighted: Bool = false
    
    unowned let slider:RangeSlider
    
    init(slider:RangeSlider) {
        self.slider = slider
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        self.contentsScale = UIScreen.mainScreen().scale
        self.contentsGravity = kCAGravityResizeAspect
        
        if highlighted { // add some effect if need
            
        }
    }
}

@IBDesignable
class RangeSlider: UIControl {
    
    static let defaultHeight:CGFloat = 70
    
    @IBInspectable var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            updateTextLayers()
            updateLayerFrames()
        }
    }
    
    @IBInspectable var maximumValue: Double = 1.0 {
        willSet(newValue) {
            assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            upperValue = maximumValue
            updateTextLayers()
            updateLayerFrames()
        }
    }
    
    @IBInspectable var lowerValue: Double = 0.0 {
        didSet {
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            updateTextLayers()
            updateLayerFrames()
        }
    }
    
    @IBInspectable var upperValue: Double = 1.0 {
        didSet {
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            updateTextLayers()
            updateLayerFrames()
        }
    }
    
    @IBInspectable var trackTintColor:UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable var trackHighlightTintColor:UIColor = UIColor(red: 244.0 / 255.0, green: 83.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var gapBetweenThumbs: Double {
        return Double(thumbWidth)*(maximumValue - minimumValue) / Double(bounds.width)
    }
    
    private var previouslocation = CGPoint()
    
    private lazy var trackLayer:RangeSliderTrackLayer = {
        return RangeSliderTrackLayer(slider: self)
    }()
    private lazy var lowerThumbLayer:RangeSliderThumbLayer = {
        return RangeSliderThumbLayer(slider: self)
    }()
    private lazy var upperThumbLayer:RangeSliderThumbLayer = {
        return RangeSliderThumbLayer(slider: self)
    }()
    
    private let sublayerPadding:CGFloat = 10
    
    private var thumbWidth:CGFloat {
        return (self.thumbImage != nil) ? self.thumbImage!.size.width:25
    }
    private var thumbHeight:CGFloat {
        return (self.thumbImage != nil) ? self.thumbImage!.size.height:30
    }
    
    let lowerTextLayer = CATextLayer()
    let upperTextLayer = CATextLayer()
    @IBInspectable var textColor:UIColor = UIColor.whiteColor() {
        didSet{
            lowerTextLayer.foregroundColor = textColor.CGColor
            upperTextLayer.foregroundColor = textColor.CGColor
        }
    }
    @IBInspectable var textFont:UIFont = UIFont.systemFontOfSize(16.0) {
        didSet{
            lowerTextLayer.font = CTFontCreateWithName(textFont.fontName, 0.0, nil)
            lowerTextLayer.fontSize = textFont.pointSize
            upperTextLayer.font = CTFontCreateWithName(textFont.fontName, 0.0, nil)
            upperTextLayer.fontSize = textFont.pointSize
        }
    }
    
    var prefixString:String = "" {
        didSet {
            updateTextLayers()
            updateLayerFrames()
        }
    }
    var suffixString:String = "" {
        didSet {
            updateTextLayers()
            updateLayerFrames()
        }
    }
    
    var thumbImage:UIImage? {
        didSet{
            self.lowerThumbLayer.contents = self.thumbImage?.CGImage
            self.upperThumbLayer.contents = self.thumbImage?.CGImage
            updateLayerFrames()
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    // MARK:
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers("sliderThumbIcon")
    }
    
    init(imageName:String?){
        super.init(frame: CGRectZero)
        initializeLayers(imageName)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayers("sliderThumbIcon")
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        updateLayerFrames()
    }
    
    private func initializeLayers(imageName:String?) {
        
        if let imageName = imageName {
            #if !TARGET_INTERFACE_BUILDER
                self.thumbImage = UIImage(named: imageName)
            #else
                self.thumbImage = UIImage(named: imageName, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: self.traitCollection)!
            #endif
        }
        
        if(self.thumbImage == nil){
            debugPrint("RangeSlider can not find image !")
        }
        
        self.backgroundColor = UIColor.clearColor()
        
        self.trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(self.trackLayer)
        
        self.lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        self.upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        self.lowerThumbLayer.contents = self.thumbImage?.CGImage
        self.upperThumbLayer.contents = self.thumbImage?.CGImage
        layer.addSublayer(self.lowerThumbLayer)
        layer.addSublayer(self.upperThumbLayer)
        
        self.lowerTextLayer.alignmentMode = kCAAlignmentLeft
        self.upperTextLayer.alignmentMode = kCAAlignmentRight
        
        self.setupTextLayer(lowerTextLayer)
        self.setupTextLayer(upperTextLayer)
        
        layer.addSublayer(self.lowerTextLayer)
        layer.addSublayer(self.upperTextLayer)
        
        self.updateTextLayers()
    }
    
    private func setupTextLayer(layer:CATextLayer){
        layer.contentsScale = UIScreen.mainScreen().scale
        layer.font = CTFontCreateWithName(textFont.fontName, 0.0, nil)
        layer.fontSize = textFont.pointSize
        layer.foregroundColor = textColor.CGColor
        layer.wrapped = true
    }
    
    func updateTextLayers(){
        let lower:UInt = UInt(round(lowerValue))
        let upper:UInt = UInt(round(upperValue))
        self.lowerTextLayer.string = "\(prefixString)\(lower)\(suffixString)"
        self.upperTextLayer.string = "\(prefixString)\(upper)\(suffixString)"
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let tracklayerHeight:CGFloat = 5
        let trackYPos = bounds.height - 10
        trackLayer.frame = CGRectMake(0, trackYPos, bounds.width, tracklayerHeight)
        trackLayer.setNeedsDisplay()
        
        let thumbYPos = CGRectGetMinY(trackLayer.frame) - 7 - thumbHeight
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0, y: thumbYPos, width: thumbWidth, height: thumbHeight)
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth/2.0, y: thumbYPos, width: thumbWidth, height: thumbHeight)
        
        let textHeight:CGFloat = 21
        let textWidth = bounds.width/2
        let padding:CGFloat = 5
        lowerTextLayer.frame = CGRect(x: bounds.minX + sublayerPadding + thumbWidth/2, y: lowerThumbLayer.frame.minY - textHeight - padding, width: textWidth, height: textHeight)
        upperTextLayer.frame = CGRect(x: bounds.maxX - sublayerPadding - thumbWidth/2 - textWidth, y: upperThumbLayer.frame.minY - textHeight - padding, width: textWidth, height: textHeight)
        
        upperTextLayer.setNeedsDisplay()
        lowerTextLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth - sublayerPadding*2) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth/2.0) + Double(sublayerPadding)
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    // MARK: - Touches
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previouslocation = touch.locationInView(self)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previouslocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previouslocation) {
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        // Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
