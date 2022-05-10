//
//  Predictor.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 09.05.2022.
//

import CoreML
import Vision

protocol IPredictor {
    func makePrediction(
        observation: VNHumanHandPoseObservation
    ) -> Result<HandPoseClassifierOutput, AppError>
}

final class Predictor: IPredictor {
    private lazy var handPoseClassifier = try? HandPoseClassifier(
        configuration: MLModelConfiguration()
    )
    
    func makePrediction(
        observation: VNHumanHandPoseObservation
    ) -> Result<HandPoseClassifierOutput, AppError> {
        guard let keypointsMultiArray = try? observation.keypointsMultiArray() else { let error = AppError.classification(reason: "Could not parse current observation")
            return .failure(error)
        }
        
        do {
            guard let prediction = try handPoseClassifier?.prediction(
                poses: keypointsMultiArray
            ) else {
                let error = AppError.classification(
                    reason: "Could not make a prediction"
                )
                return .failure(error)
            }
            
            return .success(prediction)
        } catch {
            return .failure(AppError.otherError(error: error))
        }
    }
}
