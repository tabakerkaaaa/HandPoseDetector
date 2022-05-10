//
//  AppError.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 02.05.2022.
//

import UIKit

enum AppError: Error {
    case captureSessionSetup(reason: String)
    case cameraPermission(reason: String)
    case classification(reason: String)
    case visionError(error: Error)
    case otherError(error: Error)
    
    static func display(
        _ error: Error,
        inViewController viewController: UIViewController?,
        completion: VoidBlock? = nil
    ) {
        guard let viewController = viewController else {
            return
        }
        
        DispatchQueue.main.async {
            if let appError = error as? AppError {
                appError.displayInViewController(viewController, completion: completion)
            } else {
                AppError.otherError(error: error).displayInViewController(
                    viewController,
                    completion: completion
                )
            }
        }
    }
    
    func displayInViewController(
        _ viewController: UIViewController,
        completion: VoidBlock? = nil
    ) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .visionError(let error):
            title = "Vision Error"
            message = error.localizedDescription
        case .otherError(let error):
            title = "Error"
            message = error.localizedDescription
        case .cameraPermission(reason: let reason):
            title = "Camera Permission Error"
            message = reason
        case .classification(let reason):
            title = "Classification Error"
            message = reason
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alert.addAction(alertAction)

        viewController.present(alert, animated: true, completion: nil)
    }
}
