//
//  CoordinatorTests.swift
//  HandPoseDetectorTests
//
//  Created by n.s.babenko on 26.05.2022.
//

import XCTest
@testable import HandPoseDetector

class CoordinatorTests: XCTestCase {
    
    var router: RouterMock!
    var menuCoordinator: Coordinatable!
    var drawingCoordinator: Coordinatable!
    var handPoseDetectingCoordinator: Coordinatable!
    
    override func setUp() {
        router = RouterMock()
        menuCoordinator = CoordinatorFactory.makeMenuCoordinator(
            router: router
        )
        drawingCoordinator = CoordinatorFactory.makeDrawingCoordinator(
            router: router
        )
        handPoseDetectingCoordinator = CoordinatorFactory.makeHandPoseDetectingCoordinator(
            router: router
        )
    }

    override func tearDown() {
        router = nil
        menuCoordinator = nil
        drawingCoordinator = nil
        handPoseDetectingCoordinator = nil
    }

    func testSetMenuModuleAsRootModule() {
        // Given
        menuCoordinator.start()
        
        // Then
        XCTAssert(router.didCallSetRootModule)
        XCTAssert(router.stubbedSetRootModuleHideBar)
        XCTAssert(router.stubbedSetRootModuleAnimated)
    }
    
    func testPresentDrawingModule() {
        // Given
        drawingCoordinator.start()
        
        // Then
        XCTAssert(router.didCallPresent)
        XCTAssert(router.stubbedPresentAnimated)
    }
    
    func testPresentHandPoseDetectingModule() {
        // Given
        handPoseDetectingCoordinator.start()
        
        // Then
        XCTAssert(router.didCallPresent)
        XCTAssert(router.stubbedPresentAnimated)
    }
}
