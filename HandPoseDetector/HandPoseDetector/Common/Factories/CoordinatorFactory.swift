//
//  CoordinatorFactory.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

final class CoordinatorFactory {
    static func makeAppCoordinator(router: Routable) -> Coordinatable {
        AppCoordinator(router: router)
    }
    
    static func makeMenuCoordinator(router: Routable) -> Coordinatable {
        MenuCoordinator(router: router)
    }
    
    static func makeDrawingCoordinator(router: Routable) -> Coordinatable {
        DrawingCoordinator(router: router)
    }
    
    static func makeHandPoseDetectingCoordinator(router: Routable) -> Coordinatable {
        HandPoseDetectingCoordinator(router: router)
    }
}
