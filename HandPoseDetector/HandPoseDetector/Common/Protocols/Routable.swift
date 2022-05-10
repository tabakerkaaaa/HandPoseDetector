//
//  Routable.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

protocol Routable: AnyObject {
    func present(_ module: UIViewController?)
    func present(_ module: UIViewController?, animated: Bool)
    func present(_ module: UIViewController?, animated: Bool, completion: VoidBlock?)
    
    func push(_ module: UIViewController?)
    func push(_ module: UIViewController?, animated: Bool)
    
    func popModule()
    func popModule(animated: Bool)
    
    func dismissModule()
    func dismissModule(animated: Bool)
    func dismissModule(animated: Bool, completion: VoidBlock?)
    
    func setRootModule(_ module: UIViewController?)
    func setRootModule(_ module: UIViewController?, animated: Bool)
    func setRootModule(_ module: UIViewController?, hideBar: Bool)
    func setRootModule(_ module: UIViewController?, animated: Bool, hideBar: Bool)
    
    func popToRootModule()
    func popToRootModule(animated: Bool)
    
    func popToModule(module: UIViewController?)
    func popToModule(module: UIViewController?, animated: Bool)
}
