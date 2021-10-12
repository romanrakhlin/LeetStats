//
//  DonutChartView.swift
//  SampleDonutChart
//
//  Created by Md. Saber Hossain on 17/4/20.
//  Copyright © 2020 Md. Saber Hossain. All rights reserved.
//

import UIKit

@IBDesignable class DonutChartView: UIView{
    
    override class var layerClass: AnyClass{
        return DonutChartLayer.self
    }
    
    var donutLayer: DonutChartLayer{
        return self.layer as! DonutChartLayer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        donutLayer.contentsScale = UIScreen.main.scale
        donutLayer.shouldRasterize = true
        donutLayer.rasterizationScale = UIScreen.main.scale * 2
        donutLayer.masksToBounds = false
        backgroundColor = UIColor.clear
    }
    
    func configureView(entries: [DonutChartEntry], centerLabelText: String, animate: Bool){
        donutLayer.configure(entries: entries)
        if animate{
            donutLayer.animateSubLayers()
        }
    }
}

