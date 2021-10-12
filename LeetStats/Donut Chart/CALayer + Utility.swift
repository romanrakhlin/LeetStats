//
//  CALayer + Utility.swift
//  SampleDonutChart
//
//  Created by Md. Saber Hossain on 21/4/20.
//  Copyright © 2020 Md. Saber Hossain. All rights reserved.
//

import UIKit

extension CALayer{
    func applyShadow(){
        shadowColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        shadowRadius = 1.0
        shadowOpacity = 1.0
        shadowOffset = CGSize(width: 0, height: 2.0)
    }
}
