//
//  AppCoordinator.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

final class AppCoordinator: BaseCoordinator, Coordinatable {
    private let router: Routable
    
    var finishFlow: VoidBlock?
    
    init(router: Routable) {
        self.router = router
    }

    func start() {
        startMenuFlow()
    }
    
    private func startMenuFlow() {
        let coordinator = CoordinatorFactory.makeMenuCoordinator(router: router)
        addDependency(coordinator)
        coordinator.start()
    }
}
