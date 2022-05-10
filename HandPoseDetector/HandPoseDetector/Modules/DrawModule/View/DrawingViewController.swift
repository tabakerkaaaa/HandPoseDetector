//
//  DrawingViewController.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 02.05.2022.
//

import UIKit
import AVFoundation
import Vision
import CoreGraphics

struct DrawingModel {
    let backgroundColor: UIColor
    let closeIcon: UIImage?
    let closeIconColor: UIColor
    let drawingOverlayModel: DrawingOverlayModel
    
    struct DrawingOverlayModel {
        let lineWidth: CGFloat
        let backgroundColor: CGColor
        let strokeColor: CGColor
        let fillColor: CGColor
        let lineCap: CAShapeLayerLineCap
    }
}

protocol DrawingViewControllerOutput: AnyObject {
    func performCloseAction()
    func checkCameraPermissions(
        completion: @escaping ValueBlock<Result<Bool, AppError>>
    )
    func displayError(error: Error)
}

protocol DrawingViewControllerInput: UIViewController {
    func setModel(model: DrawingModel)
}

final class DrawingViewController: UIViewController {
    private var cameraFeedSession: AVCaptureSession?
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    
    private var evidenceBuffer = [HandGestureProcessor.PointsPair]()
    private var lastDrawPoint: CGPoint?
    private var isFirstSegment = true
    private var lastObservationTimestamp = Date()
    
    private let drawOverlay = CAShapeLayer()
    private let drawPath = UIBezierPath()
    private var overlayLayer = CAShapeLayer()
    private var pointsPath = UIBezierPath()
    
    private var gestureProcessor = HandGestureProcessor()
    
    private lazy var closeButton = UIButton()
    
    private var model: DrawingModel? {
        didSet {
            setUI()
        }
    }
    
    var presenter: DrawingViewControllerOutput?
    
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
        overlayLayer.frame = view.bounds
        drawOverlay.frame = view.bounds
        
        let layout = Layout(safeAreaInsets: view.safeAreaInsets)
        closeButton.frame = layout.closeButtonFrame
    }
    
    private func setUI() {
        guard let model = model else {
            return
        }
        
        view.backgroundColor = model.backgroundColor
        closeButton.setBackgroundImage(model.closeIcon, for: .normal)
        closeButton.tintColor = model.closeIconColor
        drawOverlay.lineWidth = model.drawingOverlayModel.lineWidth
        drawOverlay.backgroundColor = model.drawingOverlayModel.backgroundColor
        drawOverlay.strokeColor = model.drawingOverlayModel.strokeColor
        drawOverlay.fillColor = model.drawingOverlayModel.fillColor
        drawOverlay.lineCap = model.drawingOverlayModel.lineCap
    }
    
    private func addSubviews() {
        view.layer.addSublayer(previewLayer)
        previewLayer.addSublayer(overlayLayer)
        view.layer.addSublayer(drawOverlay)
        view.addSubview(closeButton)
    }
    
    private func bindActions() {
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapGesture)
        )
        tapRecognizer.numberOfTapsRequired = 2
        view.addGestureRecognizer(tapRecognizer)
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGesture)
        )
        swipeDownRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownRecognizer)
        
        closeButton.addTarget(
            self,
            action: #selector(tapCloseButton),
            for: .touchUpInside
        )
        
        handPoseRequest.maximumHandCount = 1

        gestureProcessor.didChangeStateClosure = { [weak self] state in
            self?.handleGestureStateChange(state: state)
        }
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
    }
    
    private func processPoints(thumbTip: CGPoint?, indexTip: CGPoint?) {
        guard let thumbPoint = thumbTip, let indexPoint = indexTip else {
            if Date().timeIntervalSince(lastObservationTimestamp) > 2 {
                gestureProcessor.reset()
            }
            showPoints([], color: .clear)
            return
        }
        
        let thumbPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: thumbPoint)
        let indexPointConverted = previewLayer.layerPointConverted(fromCaptureDevicePoint: indexPoint)
        
        gestureProcessor.processPointsPair((thumbPointConverted, indexPointConverted))
    }
    
    private func showPoints(_ points: [CGPoint], color: UIColor) {
        pointsPath.removeAllPoints()
        for point in points {
            pointsPath.move(to: point)
            pointsPath.addArc(
                withCenter: point,
                radius: 5,
                startAngle: 0,
                endAngle: 2 * .pi,
                clockwise: true
            )
        }
        overlayLayer.fillColor = color.cgColor
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        overlayLayer.path = pointsPath.cgPath
        CATransaction.commit()
    }
    
    private func handleGestureStateChange(state: HandGestureProcessor.State) {
        let pointsPair = gestureProcessor.lastProcessedPointsPair
        var tipsColor: UIColor
        switch state {
        case .possiblePinch, .possibleApart:
            evidenceBuffer.append(pointsPair)
            tipsColor = .orange
        case .pinched:
            for bufferedPoints in evidenceBuffer {
                updatePath(with: bufferedPoints, isLastPointsPair: false)
            }
            evidenceBuffer.removeAll()
            updatePath(with: pointsPair, isLastPointsPair: false)
            tipsColor = .green
        case .apart, .unknown:
            evidenceBuffer.removeAll()
            updatePath(with: pointsPair, isLastPointsPair: true)
            tipsColor = .red
        }
        showPoints([pointsPair.thumbTip, pointsPair.indexTip], color: tipsColor)
    }
    
    private func updatePath(
        with points: HandGestureProcessor.PointsPair,
        isLastPointsPair: Bool
    ) {
        let (thumbTip, indexTip) = points
        let drawPoint = CGPoint.midPoint(p1: thumbTip, p2: indexTip)

        if isLastPointsPair {
            if let lastPoint = lastDrawPoint {
                drawPath.addLine(to: lastPoint)
            }
            lastDrawPoint = nil
        } else {
            if lastDrawPoint == nil {
                drawPath.move(to: drawPoint)
                isFirstSegment = true
            } else {
                let lastPoint = lastDrawPoint!
                let midPoint = CGPoint.midPoint(p1: lastPoint, p2: drawPoint)
                if isFirstSegment {
                    drawPath.addLine(to: midPoint)
                    isFirstSegment = false
                } else {
                    drawPath.addQuadCurve(to: midPoint, controlPoint: lastPoint)
                }
            }
            lastDrawPoint = drawPoint
        }
        drawOverlay.path = drawPath.cgPath
    }
    
    @objc private func tapCloseButton() {
        presenter?.performCloseAction()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        evidenceBuffer.removeAll()
        drawPath.removeAllPoints()
        drawOverlay.path = drawPath.cgPath
    }
    
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            presenter?.performCloseAction()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension DrawingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        var thumbTip: CGPoint?
        var indexTip: CGPoint?
        
        defer {
            DispatchQueue.main.sync {
                self.processPoints(thumbTip: thumbTip, indexTip: indexTip)
            }
        }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                return
            }
            let thumbPoints = try observation.recognizedPoints(.thumb)
            let indexFingerPoints = try observation.recognizedPoints(.indexFinger)
            guard let thumbTipPoint = thumbPoints[.thumbTip], let indexTipPoint = indexFingerPoints[.indexTip] else {
                return
            }
            guard thumbTipPoint.confidence > 0.3 && indexTipPoint.confidence > 0.3 else {
                return
            }
            thumbTip = CGPoint(x: thumbTipPoint.location.x, y: 1 - thumbTipPoint.location.y)
            indexTip = CGPoint(x: indexTipPoint.location.x, y: 1 - indexTipPoint.location.y)
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            presenter?.displayError(error: error)
        }
    }
}

// MARK: - DrawingViewControllerInput

extension DrawingViewController: DrawingViewControllerInput {
    func setModel(model: DrawingModel) {
        self.model = model
    }
}

// MARK: - Layout

private struct Layout {
    private let buttonSideOffset: CGFloat = 20
    private let buttonSide: CGFloat = 20
    
    let closeButtonFrame: CGRect
    
    init(safeAreaInsets: UIEdgeInsets) {
        let buttonX = buttonSideOffset + safeAreaInsets.left
        let buttonY = buttonSideOffset + safeAreaInsets.top
        closeButtonFrame = CGRect(
            x: buttonX,
            y: buttonY,
            width: buttonSide,
            height: buttonSide
        )
    }
}
