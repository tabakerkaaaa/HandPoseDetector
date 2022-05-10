//
//  UIImage.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 02.05.2022.
//

import UIKit

extension UIImage {
    // Иконка закрытия
    class var closeIcon: UIImage? {
        UIImage(named: closeIconName)
    }
}

private let closeIconName = "CloseIcon"
