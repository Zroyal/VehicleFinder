//
//  AppFactory.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

protocol AppFactory {
    func makeMapViewController() -> MapVC
}


class DefaultAppFactory: AppFactory {
    func makeMapViewController() -> MapVC {
        let repo = DefaultScooterRepository()
        let useCase = DefaultFetchScooterListUseCase(repo: repo)
        let viewModel = DefaultMapViewModel(useCase: useCase)
        let vc = MapVC(viewModel: viewModel)
        
        return vc
    }
}
