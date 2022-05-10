//
//  HandPoseDetectingAssembly.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 07.05.2022.
//

import UIKit

final class HandPoseDetectingAssembly {
    static func assemble(closeAction: @escaping VoidBlock) -> UIViewController {
        let view = HandPoseDetectingViewController()
        view.modalPresentationStyle = .fullScreen
        let presenter = HandPoseDetectingPresenter(
            closeAction: closeAction,
            cameraPermissionsHandler: CameraPermissionsHandler(),
            predictor: Predictor(),
            view: view
        )
        view.presenter = presenter
        return view
    }
}
