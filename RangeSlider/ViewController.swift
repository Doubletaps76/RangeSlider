//
//  ViewController.swift
//  RangeSlider
//
//  Created by William Archimede on 08/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var rangeSlider1:RangeSlider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rangeSlider1 = RangeSlider(imageName: "sliderThumbIcon")
        view.addSubview(rangeSlider1!)
        
        self.rangeSlider1?.addTarget(self, action: #selector(rangeSliderValueChanged), forControlEvents: .ValueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider1?.frame = CGRect(x: margin, y: margin + topLayoutGuide.length + 100,
            width: width, height: RangeSlider.defaultHeight)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
    }
}

