//
//  RouterMock.swift
//  HandPoseDetectorTests
//
//  Created by n.s.babenko on 26.05.2022.
//

import UIKit
@testable import HandPoseDetector

final class RouterMock: Routable {
    var callPresentCount = 0
    var didCallPresent: Bool {
        callPresentCount > 0
    }
    
    var stubbedPresentModule: UIViewController? = nil
    
    func present(_ module: UIViewController?) {
        stubbedPresentModule = module
        callPresentCount += 1
    }
    
    var stubbedPresentAnimated: Bool = true
    
    func present(_ module: UIViewController?, animated: Bool) {
        stubbedPresentAnimated = animated
        stubbedPresentModule = module
        callPresentCount += 1
    }
    
    var stubbedPresentCompletion: VoidBlock? = nil
    
    func present(_ module: UIViewController?, animated: Bool, completion: VoidBlock?) {
        stubbedPresentCompletion = completion
        stubbedPresentAnimated = animated
        stubbedPresentModule = module
        callPresentCount += 1
    }
    
    var callPushCount = 0
    var didCallPush: Bool {
        callPushCount > 0
    }
    
    var stubbedPushModule: UIViewController? = nil
    
    func push(_ module: UIViewController?) {
        stubbedPushModule = module
        callPushCount += 1
    }
    
    var stubbedPushAnimated: Bool = true
    
    func push(_ module: UIViewController?, animated: Bool) {
        stubbedPushAnimated = animated
        stubbedPushModule = module
        callPushCount += 1
    }
    
    var callPopModuleCount = 0
    var didCallPopModule: Bool {
        callPopModuleCount > 0
    }
    
    func popModule() {
        callPopModuleCount += 1
    }
    
    var stubbedPopModuleAnimated: Bool = true
    
    func popModule(animated: Bool) {
        stubbedPopModuleAnimated = animated
        callPopModuleCount += 1
    }
    
    var callDismissModuleCount = 0
    var didCallDismissModule: Bool {
        callDismissModuleCount > 0
    }
    
    func dismissModule() {
        callDismissModuleCount += 1
    }
    
    var stubbedDismissModuleAnimated: Bool = true
    
    func dismissModule(animated: Bool) {
        stubbedDismissModuleAnimated = animated
        callDismissModuleCount += 1
    }
    
    var stubbedDismissModuleCompletion: VoidBlock? = nil
    
    func dismissModule(animated: Bool, completion: VoidBlock?) {
        stubbedDismissModuleCompletion = completion
        stubbedDismissModuleAnimated = animated
        callDismissModuleCount += 1
    }
    
    var callSetRootModuleCount = 0
    var didCallSetRootModule: Bool {
        callSetRootModuleCount > 0
    }
    
    var stubbedSetRootModule: UIViewController? = nil
    
    func setRootModule(_ module: UIViewController?) {
        stubbedSetRootModule = module
        callSetRootModuleCount += 1
    }
    
    var stubbedSetRootModuleAnimated: Bool = true
    
    func setRootModule(_ module: UIViewController?, animated: Bool) {
        stubbedSetRootModuleAnimated = animated
        stubbedSetRootModule = module
        callSetRootModuleCount += 1
    }
    
    var stubbedSetRootModuleHideBar: Bool = false
    
    func setRootModule(_ module: UIViewController?, hideBar: Bool) {
        stubbedSetRootModuleHideBar = hideBar
        stubbedSetRootModule = module
        callSetRootModuleCount += 1
    }
    
    func setRootModule(_ module: UIViewController?, animated: Bool, hideBar: Bool) {
        stubbedSetRootModuleHideBar = hideBar
        stubbedSetRootModuleAnimated = animated
        stubbedSetRootModule = module
        callSetRootModuleCount += 1
    }
    
    var callPopToRootModuleCount = 0
    var didCallPopToRootModule: Bool {
        callPopToRootModuleCount > 0
    }
    
    func popToRootModule() {
        callPopToRootModuleCount += 1
    }
    
    var stubbedPopToRootModuleAnimated: Bool = true
    
    func popToRootModule(animated: Bool) {
        stubbedPopToRootModuleAnimated = animated
        callPopToRootModuleCount += 1
    }
    
    var callPopToModuleCount = 0
    var didCallPopToModule: Bool {
        callPopToModuleCount > 0
    }
    
    var stubbedPopToModule: UIViewController? = nil
    
    func popToModule(module: UIViewController?) {
        stubbedPopToModule = module
        callPopToModuleCount += 1
    }
    
    var stubbedPopToModuleAnimated: Bool = true
    
    func popToModule(module: UIViewController?, animated: Bool) {
        stubbedPopToModuleAnimated = animated
        stubbedPopToModule = module
        callPopToModuleCount += 1
    }
}
