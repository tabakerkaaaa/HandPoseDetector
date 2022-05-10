//
//  DrawingPresenter.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 02.05.2022.
//

import UIKit
import CoreGraphics

final class DrawingPresenter {
    private let cameraPermissionsHandler: ICameraPermissionsHandler
    private let closeAction: VoidBlock
    
    private weak var view: DrawingViewControllerInput?
    
    private typealias OverlayModel = DrawingModel.DrawingOverlayModel
    
    init(
        closeAction: @escaping VoidBlock,
        cameraPermissionsHandler: ICameraPermissionsHandler,
        view: DrawingViewControllerInput
    ) {
        self.closeAction = closeAction
        self.cameraPermissionsHandler = cameraPermissionsHandler
        self.view = view
        
        setModuleUI()
    }
    
    private func setModuleUI() {
        let model = DrawingModel(
            backgroundColor: .white,
            closeIcon: .closeIcon,
            closeIconColor: .black,
            drawingOverlayModel: OverlayModel(
                lineWidth: 5,
                backgroundColor: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.5).cgColor,
                strokeColor: #colorLiteral(red: 0.6, green: 0.1, blue: 0.3, alpha: 1).cgColor,
                fillColor: #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0).cgColor,
                lineCap: .round
            )
        )
        view?.setModel(model: model)
    }
}

//MARK: - DrawingViewControllerOutput

extension DrawingPresenter: DrawingViewControllerOutput {
    func performCloseAction() {
        closeAction()
    }
    
    func checkCameraPermissions(
        completion: @escaping ValueBlock<Result<Bool, AppError>>
    ) {
        cameraPermissionsHandler.checkCameraPermissions(completion: completion)
    }
    
    func displayError(error: Error) {
        let completion: VoidBlock = { [weak self] in
            self?.performCloseAction()
        }
        
        AppError.display(
            error,
            inViewController: view,
            completion: completion
        )
    }
}

