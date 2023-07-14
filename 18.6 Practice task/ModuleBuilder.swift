//
//  ModuleBuilder.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/10/23.
//

import UIKit

protocol ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController
//    static func createDetailModule(_ data: ResultForDisplay) -> UIViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    static func createMainModule() -> UIViewController {
        let viewController = MainViewController()

        let networkService = NetworkService()
        let viewModel = MainViewModel(networkService: networkService)
        viewController.viewModel = viewModel
        return viewController
    }

    static func createDetailModule(_ data: ResultForDisplay) -> UIViewController {
        let viewController = DetailViewController()
        let networkService = NetworkService()
        let viewModel = DetailViewModel(networkService: networkService, result: data)
        viewController.viewModel = viewModel
        return viewController
    }
}
