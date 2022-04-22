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

    private var locationManager: CLLocationManager?
    private var useCase: FetchScooterListUseCase?
    private var usersCurrentLocation: CLLocation?
    
    init(useCase: FetchScooterListUseCase) {
        self.useCase = useCase
        
        super.init()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    func fetchScooters() {
        status = .fetching
        
        useCase?.fetchScooters(completion: { result in
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
        locationManager?.requestWhenInUseAuthorization()
        calculateDistance()
    }
    
    func calculateClosestDisance() -> Double? {
        guard let userLocation = usersCurrentLocation else { return nil }
        guard let closest = closestVehicle?.model else { return nil }
        guard let lat = closest.attributes?.latitude else { return nil }
        guard let lng = closest.attributes?.longitude else { return nil }

        let itemLocation = CLLocation(latitude: lat, longitude: lng)
        let itemDistance = userLocation.distance(from: itemLocation)
        
        return itemDistance
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


extension DefaultMapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    manager.startUpdatingLocation()
                }
            }
        } else if status == .denied {
            self.closestVehicleFindingError = .locationAccess(description: "Access to your current location is denied. If you would like to see the closest vehicle, please access the app through the device settings.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.usersCurrentLocation = locations[0] as CLLocation
        calculateDistance()
    }
    
    func calculateDistance() {
        guard let userLocation = usersCurrentLocation else { return }
        
        
        DispatchQueue.global(qos: .background).async {
            var distance: Double?
            var closestAnnotation: VehicleAnnotation?

            for item in self.annotations {
                guard let lat = item.model?.attributes?.latitude else { continue }
                guard let lng = item.model?.attributes?.longitude else { continue }
                
                let itemLocation = CLLocation(latitude: lat, longitude: lng)
                let itemDistance = userLocation.distance(from: itemLocation)
                if distance == nil {
                    distance = itemDistance
                    closestAnnotation = item
                    
                } else if itemDistance < distance ?? 0 {
                    distance = itemDistance
                    closestAnnotation = item
                }
            }
            
            DispatchQueue.main.async {
                self.closestVehicle = closestAnnotation
            }
        }

    }
}
