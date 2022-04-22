//
//  AppFactory.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import CoreLocation

protocol AppFactory {
    func makeMapViewController() -> MapVC
}


class DefaultAppFactory: AppFactory {
    func makeMapViewController() -> MapVC {
        let repo = DefaultScooterRepository()
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = CLLocationManager()
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        let viewModel = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        let vc = MapVC(viewModel: viewModel)
        
        return vc
    }
}
