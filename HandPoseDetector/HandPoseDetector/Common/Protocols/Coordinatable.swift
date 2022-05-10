//
//  Coordinatable.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

protocol Coordinatable: AnyObject {
    func start()
    var finishFlow: VoidBlock? { get set }
}
