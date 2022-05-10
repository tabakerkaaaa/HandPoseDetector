//
//  HandPoseDetectingPresenter.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 07.05.2022.
//

import Vision

final class HandPoseDetectingPresenter {
    private let cameraPermissionsHandler: ICameraPermissionsHandler
    private let predictor: IPredictor
    private let closeAction: VoidBlock
    
    private weak var view: HandPoseDetectingViewControllerInput?
    
    init(
        closeAction: @escaping VoidBlock,
        cameraPermissionsHandler: ICameraPermissionsHandler,
        predictor: IPredictor,
        view: HandPoseDetectingViewControllerInput
    ) {
        self.closeAction = closeAction
        self.cameraPermissionsHandler = cameraPermissionsHandler
        self.predictor = predictor
        self.view = view
        
        setModuleUI()
    }
    
    private func setModuleUI() {
        let model = HandPoseDetectingModel(
            backgroundColor: .white,
            closeIcon: .closeIcon,
            closeIconColor: .black
        )
        view?.setModel(model: model)
    }
}

//MARK: - HandPoseDetectingViewControllerOutput

extension HandPoseDetectingPresenter: HandPoseDetectingViewControllerOutput {
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
    
    func makePrediction(
        observation: VNHumanHandPoseObservation
    ) -> Result<HandPoseClassifierOutput, AppError> {
        predictor.makePrediction(observation: observation)
    }
}
