//
//  HandPoseDetectingViewController.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 07.05.2022.
//

import AVFoundation
import Vision
import UIKit

struct HandPoseDetectingModel {
    let backgroundColor: UIColor
    let closeIcon: UIImage?
    let closeIconColor: UIColor
}

protocol HandPoseDetectingViewControllerOutput: AnyObject {
    func performCloseAction()
    func checkCameraPermissions(
        completion: @escaping ValueBlock<Result<Bool, AppError>>
    )
    func displayError(error: Error)
    func makePrediction(
        observation: VNHumanHandPoseObservation
    ) -> Result<HandPoseClassifierOutput, AppError>
}

protocol HandPoseDetectingViewControllerInput: UIViewController {
    func setModel(model: HandPoseDetectingModel)
}

final class HandPoseDetectingViewController: UIViewController {
    private lazy var closeButton = UIButton()
    private lazy var predictionLabel = makePredictionLabel()
    
    private var cameraFeedSession: AVCaptureSession?
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedDataOutput",
        qos: .userInteractive
    )
    
    private var model: HandPoseDetectingModel? {
        didSet {
            setUI()
        }
    }
    
    var presenter: HandPoseDetectingViewControllerOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = view.bounds
        
        let layout = Layout(
            parentFrame: view.bounds,
            safeAreaInsets: view.safeAreaInsets
        )
        closeButton.frame = layout.closeButtonFrame
        predictionLabel.frame = layout.predictionLabelFrame
    }
    
    private func setUI() {
        guard let model = model else {
            return
        }
        
        view.backgroundColor = model.backgroundColor
        closeButton.setBackgroundImage(model.closeIcon, for: .normal)
        closeButton.tintColor = model.closeIconColor
        predictionLabel.isHidden = true
    }
    
    private func addSubviews() {
        view.layer.addSublayer(previewLayer)
        view.addSubview(closeButton)
        view.addSubview(predictionLabel)
    }
    
    private func bindActions() {
        closeButton.addTarget(
            self,
            action: #selector(tapCloseButton),
            for: .touchUpInside
        )
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGesture)
        )
        swipeDownRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownRecognizer)
    }
    
    private func setUpCamera() {
        if cameraFeedSession == nil {
            previewLayer.videoGravity = .resizeAspectFill
            presenter?.checkCameraPermissions { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success:
                    do {
                        try self.setupAVSession()
                    }
                    catch {
                        self.presenter?.displayError(error: error)
                    }
                case .failure(let error):
                    self.presenter?.displayError(error: error)
                }
            }
            
            previewLayer.session = cameraFeedSession
        }
        cameraFeedSession?.startRunning()
    }
    
    private func setupAVSession() throws {
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)

            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
        predictionLabel.isHidden = false
    }
    
    private func makePredictionLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .predictionBlack
        label.textColor = .white
        return label
    }
    
    private func makePrediction(observation: VNHumanHandPoseObservation) {
        guard let prediction = presenter?.makePrediction(observation: observation) else {
            let error = AppError.classification(reason: "Could not make a prediction")
            presenter?.displayError(error: error)
            return
        }
        
        switch prediction {
        case let .success(output):
            DispatchQueue.main.async {
                self.handlePrediction(output)
            }
        case let .failure(error):
            presenter?.displayError(error: error)
        }
    }
    
    private func handlePrediction(_ prediction: HandPoseClassifierOutput) {
        let label = prediction.label
        if let confidence = prediction.labelProbabilities[label] {
            predictionLabel.text =
            "Hand Pose: \(label)\nConfidence: \(confidence)"
        }
    }
    
    @objc private func tapCloseButton() {
        presenter?.performCloseAction()
    }
    
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            presenter?.performCloseAction()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension HandPoseDetectingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            
            makePrediction(observation: observation)
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            presenter?.displayError(error: error)
        }
    }
}

// MARK: - HandPoseDetectingViewControllerInput

extension HandPoseDetectingViewController: HandPoseDetectingViewControllerInput {
    func setModel(model: HandPoseDetectingModel) {
        self.model = model
    }
}

// MARK: - Layout

private struct Layout {
    private let buttonSideOffset: CGFloat = 20
    private let buttonSide: CGFloat = 20
    private let predictionLabelDownOffset: CGFloat = 100
    private let predictionLabelHeight: CGFloat = 100
    
    let closeButtonFrame: CGRect
    let predictionLabelFrame: CGRect
    
    init(
        parentFrame: CGRect,
        safeAreaInsets: UIEdgeInsets
    ) {
        let buttonX = buttonSideOffset + safeAreaInsets.left
        let buttonY = buttonSideOffset + safeAreaInsets.top
        closeButtonFrame = CGRect(
            x: buttonX,
            y: buttonY,
            width: buttonSide,
            height: buttonSide
        )
        
        let predictionLabelY = parentFrame.height - safeAreaInsets.bottom - predictionLabelDownOffset - predictionLabelHeight
        
        predictionLabelFrame = CGRect(
            x: safeAreaInsets.left,
            y: predictionLabelY,
            width: parentFrame.width - safeAreaInsets.left - safeAreaInsets.right,
            height: predictionLabelHeight
        )
    }
}


