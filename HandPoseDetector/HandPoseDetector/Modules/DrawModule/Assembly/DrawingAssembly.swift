//
//  DrawingAssembly.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 02.05.2022.
//

import UIKit

final class DrawingAssembly {
    static func assemble(closeAction: @escaping VoidBlock) -> UIViewController {
        let view = DrawingViewController()
        view.modalPresentationStyle = .fullScreen
        let presenter = DrawingPresenter(
            closeAction: closeAction,
            cameraPermissionsHandler: CameraPermissionsHandler(),
            view: view
        )
        view.presenter = presenter
        return view
    }
}
