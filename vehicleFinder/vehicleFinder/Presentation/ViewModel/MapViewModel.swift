//
//  MapViewModel.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import CoreLocation

protocol MapViewModel {
    func showClosestVehicle()
    func fetchScooters()
    func getAlertInfo(annotation: VehicleAnnotation?, distance: Double?) -> (String, String)
    func calculateClosestDisance() -> Double?
}

enum LoadingDataStatus {
    case fetching
    case success
    case fail
    case none
}

class DefaultMapViewModel: NSObject, MapViewModel {
    @Published var status: LoadingDataStatus = .none
    
    @Published var annotations: [VehicleAnnotation] = []
    @Published var error: GeneralError?
    
    @Published var closestVehicle: VehicleAnnotation?
    @Published var closestVehicleFindingError: GeneralError?

    private var fetchUseCase: FetchScooterListUseCase?
    private var locationUseCase: LocationManagerUseCase?

    private var usersCurrentLocation: CLLocation?
    
    init(fetchUseCase: FetchScooterListUseCase, locationUseCase: LocationManagerUseCase) {
        self.fetchUseCase = fetchUseCase
        self.locationUseCase = locationUseCase
    }
    
    func fetchScooters() {
        status = .fetching
        
        fetchUseCase?.fetchScooters(completion: { result in
            switch result {
            case .success(let list):
                self.loadData(models: list)
                self.status = .success
                
            case .failure(let error):
                self.error = error
                self.status = .fail
            }
        })
    }
    
    func showClosestVehicle() {
        if self.annotations.count == 0 {
            return
        }
        
        locationUseCase?.getClosestLocation(
            annotations: annotations,
            completion: { result in
                switch result {
                case .success(let annotation):
                    self.closestVehicle = annotation
                    
                case .failure(let error):
                    self.closestVehicleFindingError = error
                }
            })
    }
    
    func calculateClosestDisance() -> Double? {
        locationUseCase?.calculateClosestDisance()
    }
    
    func getAlertInfo(annotation: VehicleAnnotation?, distance: Double?) -> (String, String) {
        guard let annotation = annotation else {
            return ("", "")
        }
        
        let title = distance == nil ? StringConstatns.selectedVehicleInformation : StringConstatns.closestVehicleInformation
        
        var message = ""
        message.append("\n")

        message.append(StringConstatns.typeString)
        message.append(": ")
        message.append(annotation.model?.attributes?.vehicleType ?? "")
        message.append("\n")

        message.append(StringConstatns.hasHelmentBox)
        message.append(": ")
        message.append("\(annotation.model?.attributes?.hasHelmetBox ?? false)")
        message.append("\n")

        message.append(StringConstatns.batteryLevel)
        message.append(": ")
        message.append("\(annotation.model?.attributes?.batteryLevel ?? 0)")
        message.append("\n")

        message.append(StringConstatns.maxSpeed)
        message.append(": ")
        message.append("\(annotation.model?.attributes?.maxSpeed ?? 0)")
        message.append("\n")

        if distance != nil {
            message.append(StringConstatns.distance)
            message.append(": ")
            message.append("\((distance ?? 0)/1000) Km")
            message.append("\n")
        }
        
        return (title, message)
    }
    
    private func loadData(models: [VehicleModel]) {
        var annotations: [VehicleAnnotation] = []
        for item in models {
            let annotation = VehicleAnnotation(model: item)
            annotations.append(annotation)
        }
        
        self.annotations = annotations
    }
    
}
