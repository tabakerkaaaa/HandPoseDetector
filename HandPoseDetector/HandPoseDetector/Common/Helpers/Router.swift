//
//  Router.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

final class Router: Routable {
    private let rootController: UINavigationController
    
    init(rootController: UINavigationController) {
        self.rootController = rootController
    }
    
    func present(_ module: UIViewController?) {
        guard let module = module else {
            return
        }

        rootController.present(module, animated: true, completion: nil)
    }
    
    func present(_ module: UIViewController?, animated: Bool) {
        guard let module = module else {
            return
        }
        
        rootController.present(module, animated: animated, completion: nil)
    }
    
    func present(_ module: UIViewController?, animated: Bool, completion: VoidBlock?) {
        guard let module = module else {
            return
        }
        
        rootController.present(module, animated: animated, completion: completion)
    }
    
    func push(_ module: UIViewController?) {
        guard let module = module else {
            return
        }
        
        rootController.pushViewController(module, animated: true)
    }
    
    func push(_ module: UIViewController?, animated: Bool) {
        guard let module = module else {
            return
        }
        
        rootController.pushViewController(module, animated: animated)
    }
    
    func popModule() {
        rootController.popViewController(animated: true)
    }
    
    func popModule(animated: Bool) {
        rootController.popViewController(animated: animated)
    }
    
    func dismissModule() {
        rootController.dismiss(animated: true, completion: nil)
    }
    
    func dismissModule(animated: Bool) {
        rootController.dismiss(animated: animated, completion: nil)
    }
    
    func dismissModule(animated: Bool, completion: VoidBlock?) {
        rootController.dismiss(animated: animated, completion: nil)
    }
    
    func setRootModule(_ module: UIViewController?) {
        setRootModule(module, animated: true)
    }
    
    func setRootModule(_ module: UIViewController?, animated: Bool) {
        setRootModule(module, animated: animated, hideBar: false)
    }
    
    func setRootModule(_ module: UIViewController?, hideBar: Bool) {
        setRootModule(module, animated: true, hideBar: hideBar)
    }
    
    func setRootModule(_ module: UIViewController?, animated: Bool, hideBar: Bool) {
        guard let module = module else {
            return
        }
        
        rootController.setViewControllers([module], animated: animated)
        rootController.isNavigationBarHidden = hideBar
    }
    
    func popToRootModule() {
        popToRootModule(animated: true)
    }
    
    func popToRootModule(animated: Bool) {
        rootController.popToRootViewController(animated: animated)
    }
    
    func popToModule(module: UIViewController?) {
        popToModule(module: module, animated: true)
    }
    
    func popToModule(module: UIViewController?, animated: Bool) {
        guard let module = module else {
            return
        }
        
        rootController.popToViewController(module, animated: animated)
    }
}
