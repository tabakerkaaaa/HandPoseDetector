//
//  HandPoseDetectingCoordinator.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 07.05.2022.
//

import Foundation

final class HandPoseDetectingCoordinator: BaseCoordinator, Coordinatable {
    private let router: Routable
    
    var finishFlow: VoidBlock?
    
    init(router: Routable) {
        self.router = router
    }

    func start() {
        let closeAction: VoidBlock = { [weak self] in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.router.dismissModule()
            }
            self.finishFlow?()
        }
        
        let module = HandPoseDetectingAssembly.assemble(closeAction: closeAction)
        router.present(module)
    }
}
