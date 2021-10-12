//
//  DonutChartSegmentLayer.swift
//  SampleDonutChart
//
//  Created by Md. Saber Hossain on 22/4/20.
//  Copyright © 2020 Md. Saber Hossain. All rights reserved.
//

import UIKit

let startAngle : CGFloat = 270.0
let maxAngle : CGFloat = 360.0
let strokeWidth : CGFloat = 25.0

class DonutChartSegmentLayer: CAShapeLayer{
    
    init(color: UIColor, strokeStart: CGFloat, strokeEnd: CGFloat) {
        super.init()
        self.strokeColor = color.cgColor
        self.lineWidth = strokeWidth
        self.fillColor = nil
        self.lineCap = .round
        self.strokeStart = strokeStart
        self.strokeEnd = strokeEnd
    }
    
    override var bounds: CGRect {
        didSet {
            buildLayer()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    func buildLayer() {
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.midX - lineWidth
        let path = UIBezierPath(arcCenter: center,
                                radius: radius, startAngle: startAngle.radianValue,
                                endAngle: (startAngle + maxAngle).radianValue,
                                clockwise: true)
        self.path = path.cgPath
        self.position = center
    }
}
