//
//  ModuleBuilder.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/10/23.
//

import UIKit

protocol ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController
    static func createDetailModule(_ data: ResultForDisplay) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController {
        let viewController = MainViewControllerMVP()
        viewController.presenter = MainViewPresenter()
        return viewController
    }
    
    static func createDetailModule(_ data: ResultForDisplay) -> UIViewController {
        let viewController = DetailViewController()
        let detailVCPresenter = DetailViewPresenter(about: data)
        viewController.presenter = detailVCPresenter
        return viewController
    }
}
