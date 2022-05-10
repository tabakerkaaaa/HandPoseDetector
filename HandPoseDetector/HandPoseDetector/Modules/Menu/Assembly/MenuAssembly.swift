//
//  MenuAssembly.swift
//  HandPoseDetector
//
//  Created by n.s.babenko on 01.05.2022.
//

import UIKit

final class MenuAssembly {
    static func assemble(
        didTapOpenDrawModule: @escaping VoidBlock,
        didTapOpenHandPoseDetectModule: @escaping VoidBlock
    ) -> UIViewController {
        let view = MenuViewController()
        let presenter = MenuPresenter(
            didTapOpenDrawModule: didTapOpenDrawModule,
            didTapOpenHandPoseDetectModule: didTapOpenHandPoseDetectModule,
            view: view
        )
        view.presenter = presenter
        return view
    }
}
