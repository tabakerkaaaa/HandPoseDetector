//
//  HandPoseDetectorUITests.swift
//  HandPoseDetectorUITests
//
//  Created by n.s.babenko on 01.05.2022.
//

import XCTest

class HandPoseDetectorUITests: XCTestCase {
    func testButtonsExistOnMenuScreen() {
        // Given
        let app = XCUIApplication()
        
        // When
        app.launch()
        
        // Then
        XCTAssert(app.buttons["Открыть рисование жестом"].exists)
        XCTAssert(app.buttons["Открыть распознавание жестов"].exists)
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
