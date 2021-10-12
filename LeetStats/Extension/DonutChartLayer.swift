//
//  DonutChartLayer.swift
//  SampleDonutChart
//
//  Created by Md. Saber Hossain on 17/4/20.
//  Copyright © 2020 Md. Saber Hossain. All rights reserved.
//

import UIKit


class DonutChartLayer: CAShapeLayer {
   
    override init() {
        super.init()
        lineWidth = 22.0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var bounds: CGRect{
        didSet{
            sublayers?.forEach{ $0.bounds = bounds }
        }
    }
    
    func configure(entries:[DonutChartEntry]){
        sublayers?.forEach{ $0.removeFromSuperlayer() }
        var initialValue : CGFloat = 0
      
        //split the first line
        var components = entries
        let first = components.first!
        components = Array(components.dropFirst())
        
        // split first semgment into two parts to achieve ring behavior
        //splitting first part
        var strokeStart = initialValue
        var strokeEnd = initialValue + (first.value / 2.0)
        let layerStart = DonutChartSegmentLayer(color: first.color,
                                                strokeStart: strokeStart,
                                                strokeEnd: strokeEnd)
        initialValue = strokeEnd
    
        //splitting 2nd part
        strokeStart = initialValue
        strokeEnd = initialValue + (first.value / 2.0)
        let layerEnd =  DonutChartSegmentLayer(color: first.color,
                                                       strokeStart: strokeStart,
                                                       strokeEnd: strokeEnd)
        initialValue = strokeEnd
        //insert others segments
        components.forEach{ component in
            strokeStart = initialValue
            strokeEnd = initialValue + component.value
            let layer = DonutChartSegmentLayer(color: component.color,
                                               strokeStart: strokeStart,
                                               strokeEnd: strokeEnd)
            initialValue = strokeEnd
            insertSublayer(layer, at: 0)
        }
        //insert first splitted part in first index and append 2nd part.
        insertSublayer(layerStart, at: 0)
        addSublayer(layerEnd)
        // add shadow
        strokeStart = 0
        strokeEnd = 1
        let shadowLayer = DonutChartSegmentLayer(color: UIColor.white,
                                                 strokeStart: strokeStart,
                                                 strokeEnd: strokeEnd)
        shadowLayer.applyShadow()
        insertSublayer(shadowLayer, at: 0)
        //draw them
        sublayers?.forEach{ $0.bounds = bounds }
    }
    
    func animateSubLayers(){
        sublayers?.forEach({ layer in
            guard let layer = layer as? CAShapeLayer else { return }
          
            let startAnimation = CABasicAnimation(keyPath: "strokeStart")
            startAnimation.fromValue = 0.0
            startAnimation.toValue = layer.strokeStart
            startAnimation.fillMode = .forwards
            
            let endAnimation = CABasicAnimation(keyPath: "strokeEnd")
            endAnimation.fromValue = 0.0
            endAnimation.toValue = layer.strokeEnd
            endAnimation.fillMode = .forwards
            
            let group = CAAnimationGroup()
            group.animations = [startAnimation, endAnimation]
            group.timingFunction = CAMediaTimingFunction(name: .easeOut)
            group.duration = 0.5
            layer.add(group, forKey: nil)
        })
    }
}


