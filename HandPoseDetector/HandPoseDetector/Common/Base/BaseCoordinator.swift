//
//  BaseCoordinator.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

class BaseCoordinator {
    var childCoordinators: [Coordinatable] = []
    
    func addDependency(_ coordinator: Coordinatable) {
        guard childCoordinators.first(where: { $0 === coordinator }) == nil else {
            return
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinatable) {
        guard let index = childCoordinators.firstIndex(where: { $0 === coordinator }) else {
            return
        }
        childCoordinators.remove(at: index)
    }
}
