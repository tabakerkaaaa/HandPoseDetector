//
//  UIColor.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

extension UIColor {
    // Фирменный цвет СПбГЭТУ «ЛЭТИ»
    class var etuBlue: UIColor {
        UIColor(red: 20/255, green: 50/255, blue: 106/255, alpha: 1)
    }
    
    // Цвет лейбла предсказания жеста
    class var predictionBlack: UIColor {
        .black.withAlphaComponent(0.8)
    }
}
