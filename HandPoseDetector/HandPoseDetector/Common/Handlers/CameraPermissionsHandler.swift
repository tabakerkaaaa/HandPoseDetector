//
//  CameraPermissionsHandler.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 07.05.2022.
//

import AVFoundation

protocol ICameraPermissionsHandler {
    func checkCameraPermissions(
        completion: @escaping ValueBlock<Result<Bool, AppError>>
    )
}

final class CameraPermissionsHandler: ICameraPermissionsHandler {
    func checkCameraPermissions(
        completion: @escaping ValueBlock<Result<Bool, AppError>>
    ) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                completion(.success(granted))
            }
        case .restricted:
            completion(
                .failure(
                    AppError.cameraPermission(
                        reason: "The user is not allowed to access media capture devices."
                    )
                )
            )
        case .denied:
            completion(.success(false))
        case .authorized:
            completion(.success(true))
        @unknown default:
            completion(
                .failure(
                    AppError.cameraPermission(
                        reason: "Unknown camera permission error."
                    )
                )
            )
        }
    }
}
