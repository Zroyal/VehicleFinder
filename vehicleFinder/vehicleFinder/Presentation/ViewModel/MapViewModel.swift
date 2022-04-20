//
//  MapViewModel.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

protocol MapViewModel {
}

class DefaultMapViewModel: MapViewModel {
    @Published var showLoading = true
    @Published var vehicles: [VehicleModel] = []

    @Published var showingAlert = false
    @Published var error: APIError?
    
    private var useCase: FetchScooterListUseCase?

    init(useCase: FetchScooterListUseCase) {
        self.useCase = useCase
    }

}
