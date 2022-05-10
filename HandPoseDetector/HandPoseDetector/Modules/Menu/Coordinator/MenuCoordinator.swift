//
//  MenuCoordinator.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

final class MenuCoordinator: BaseCoordinator, Coordinatable {
    private let router: Routable
    
    var finishFlow: VoidBlock?
    
    init(router: Routable) {
        self.router = router
    }

    func start() {
        let didTapOpenDrawModule: VoidBlock = { [weak self] in
            self?.startDrawingFlow()
        }
        
        let didTapOpenHandPoseDetectModule: VoidBlock = { [weak self] in
            self?.startHandPoseDetectingFlow()
        }
        
        let menuModule = MenuAssembly.assemble(
            didTapOpenDrawModule: didTapOpenDrawModule,
            didTapOpenHandPoseDetectModule: didTapOpenHandPoseDetectModule
        )
        router.setRootModule(menuModule, hideBar: true)
    }
    
    private func startDrawingFlow() {
        let coordinator = CoordinatorFactory.makeDrawingCoordinator(
            router: router
        )
        
        coordinator.finishFlow = { [weak self] in
            self?.removeDependency(coordinator)
        }
    
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func startHandPoseDetectingFlow() {
        let coordinator = CoordinatorFactory.makeHandPoseDetectingCoordinator(
            router: router
        )
        
        coordinator.finishFlow = { [weak self] in
            self?.removeDependency(coordinator)
        }
    
        addDependency(coordinator)
        coordinator.start()
    }
}
