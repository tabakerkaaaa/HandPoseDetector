//
//  MenuPresenter.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

final class MenuPresenter {
    private let didTapOpenDrawModule: VoidBlock
    private let didTapOpenHandPoseDetectModule: VoidBlock
    
    private weak var view: MenuViewControllerInput?
    
    init(
        didTapOpenDrawModule: @escaping VoidBlock,
        didTapOpenHandPoseDetectModule: @escaping VoidBlock,
        view: MenuViewControllerInput
    ) {
        self.didTapOpenDrawModule = didTapOpenDrawModule
        self.didTapOpenHandPoseDetectModule = didTapOpenHandPoseDetectModule
        self.view = view
        
        setModuleUI()
    }
    
    private func setModuleUI() {
        let model = MenuModel(
            drawButtonTitle: "Открыть рисование жестом",
            handPoseDetectButtonTitle: "Открыть распознавание жестов",
            buttonTitleColor: .white,
            buttonColor: .etuBlue,
            backgroundColor: .white,
            gradientColors: [
                UIColor.etuBlue.cgColor,
                UIColor.white.cgColor
            ],
            gradientDuration: 5
        )
        view?.setModel(model: model)
    }
}

//MARK: - MenuViewControllerOutput

extension MenuPresenter: MenuViewControllerOutput {
    func tapOpenDrawModule() {
        didTapOpenDrawModule()
    }
    
    func tapOpenHandPoseDetectModule() {
        didTapOpenHandPoseDetectModule()
    }
}
