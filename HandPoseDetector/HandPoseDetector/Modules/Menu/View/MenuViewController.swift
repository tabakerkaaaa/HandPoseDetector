//
//  MenuViewController.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

struct MenuModel {
    let drawButtonTitle: String
    let handPoseDetectButtonTitle: String
    let buttonTitleColor: UIColor
    let buttonColor: UIColor
    let backgroundColor: UIColor
    let gradientColors: [CGColor]
    let gradientDuration: Double
}

protocol MenuViewControllerInput: AnyObject {
    func setModel(model: MenuModel)
}

protocol MenuViewControllerOutput: AnyObject {
    func tapOpenDrawModule()
    func tapOpenHandPoseDetectModule()
}

final class MenuViewController: UIViewController {
    private lazy var drawButton = makeButton()
    private lazy var handPoseDetectButton = makeButton()
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.etuBlue.cgColor,
        ]
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    var presenter: MenuViewControllerOutput?
    
    private var model: MenuModel? {
        didSet {
            setUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        bindActions()
    }
    
    override func viewDidLayoutSubviews() {
        let layout = Layout(
            parentFrame: view.bounds,
            safeAreaInsets: view.safeAreaInsets
        )
        drawButton.frame = layout.drawButtonFrame
        handPoseDetectButton.frame = layout.handPoseDetectButtonFrame
        gradient.frame = view.bounds
    }
    
    private func addSubviews() {
        view.layer.addSublayer(gradient)
        view.addSubview(drawButton)
        view.addSubview(handPoseDetectButton)
    }
    
    private func bindActions() {
        drawButton.addTarget(
            self,
            action: #selector(tapOpenDrawModule),
            for: .touchUpInside
        )
        handPoseDetectButton.addTarget(
            self,
            action: #selector(tapOpenHandPoseDetectModule),
            for: .touchUpInside
        )
    }
    
    private func makeButton() -> UIButton {
        let button = UIButton()
        button.layer.cornerRadius = 20
        return button
    }
    
    private func setUI() {
        guard let model = model else {
            return
        }
        
        view.backgroundColor = model.backgroundColor
        drawButton.backgroundColor = model.buttonColor
        handPoseDetectButton.backgroundColor = model.buttonColor
        drawButton.setTitle(model.drawButtonTitle, for: .normal)
        handPoseDetectButton.setTitle(model.handPoseDetectButtonTitle, for: .normal)
        drawButton.setTitleColor(model.buttonTitleColor, for: .normal)
        handPoseDetectButton.setTitleColor(model.buttonTitleColor, for: .normal)
        
        gradient.setColors(
            model.gradientColors,
            animated: true,
            withDuration: model.gradientDuration,
            timingFunctionName: .linear
        )
    }
    
    @objc private func tapOpenDrawModule() {
        presenter?.tapOpenDrawModule()
    }
    
    @objc private func tapOpenHandPoseDetectModule() {
        presenter?.tapOpenHandPoseDetectModule()
    }
}

// MARK: - MenuViewControllerInput

extension MenuViewController: MenuViewControllerInput {
    func setModel(model: MenuModel) {
        self.model = model
    }
}


// MARK: - Layout

private struct Layout {
    private let buttonSideOffset: CGFloat = 20
    private let buttonHeight: CGFloat = 70
    private let buttonGap: CGFloat = 50
    
    let drawButtonFrame: CGRect
    let handPoseDetectButtonFrame: CGRect
    
    init(
        parentFrame: CGRect,
        safeAreaInsets: UIEdgeInsets
    ) {
        let buttonX = buttonSideOffset + safeAreaInsets.left
        let buttonWidth = min(
            parentFrame.width - 2 * buttonSideOffset,
            parentFrame.width - safeAreaInsets.left - safeAreaInsets.right
        )
        let drawButtonY = parentFrame.height / 2 - buttonHeight - buttonGap / 2
        let handPoseDetectButtonY = drawButtonY + buttonHeight + buttonGap
        
        drawButtonFrame = CGRect(
            x: buttonX,
            y: drawButtonY,
            width: buttonWidth,
            height: buttonHeight
        )
        
        handPoseDetectButtonFrame = CGRect(
            x: buttonX,
            y: handPoseDetectButtonY,
            width: buttonWidth,
            height: buttonHeight
        )
    }
}

private extension CAGradientLayer {
    func setColors(_ newColors: [CGColor],
                   animated: Bool = true,
                   withDuration duration: TimeInterval = 0,
                   timingFunctionName name: CAMediaTimingFunctionName? = nil) {
        
        if !animated {
            self.colors = newColors
            return
        }
        
        let colorAnimation = CABasicAnimation(keyPath: "colors")
        colorAnimation.repeatCount = .infinity
        colorAnimation.fromValue = colors
        colorAnimation.toValue = newColors
        colorAnimation.duration = duration
        colorAnimation.autoreverses = true
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.fillMode = CAMediaTimingFillMode.forwards
        colorAnimation.timingFunction = CAMediaTimingFunction(name: name ?? .linear)

        add(colorAnimation, forKey: "colorsChangeAnimation")
    }
}
