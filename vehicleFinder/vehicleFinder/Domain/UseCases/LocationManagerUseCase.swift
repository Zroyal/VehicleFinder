//
//  LocationManagerUseCase.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/22/22.
//

import Foundation
import MapKit
import Combine

typealias LocationResult = (Result<VehicleAnnotation, GeneralError>) -> Void

protocol LocationManagerUseCase {
    func getClosestLocation(annotations: [VehicleAnnotation], completion: @escaping LocationResult)
    func calculateClosestDisance() -> Double?
}

class DefaultLocationManagerUseCase: NSObject, LocationManagerUseCase {
    private var locationManager: CLLocationManager

    private var completion: LocationResult?
    private var annotations: [VehicleAnnotation]?
    private var usersCurrentLocation: CLLocation?
    private var closestVehicle: VehicleAnnotation?

    init(manager: CLLocationManager) {
        self.locationManager = manager
        
        super.init()

        self.locationManager.delegate = self
    }

    func getClosestLocation(annotations: [VehicleAnnotation], completion: @escaping LocationResult) {
                
        if let closest = self.closestVehicle {
            completion(.success(closest))
            
        } else {
            self.annotations = annotations
            self.completion = completion
            
            if self.usersCurrentLocation != nil {
                calculateDistance()
            }
        }
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
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

}


extension DefaultLocationManagerUseCase: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    manager.startUpdatingLocation()
                }
            }
        } else if status == .denied {
            let error: GeneralError = .locationAccess(description: StringConstatns.accessLocationError)
            if let completion = completion {
                completion(.failure(error))
            }
            
            self.completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.usersCurrentLocation = locations[0] as CLLocation
        calculateDistance()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let error: GeneralError = .locationAccess(description: error.localizedDescription)
        if let completion = completion {
            completion(.failure(error))
        }
        
        self.completion = nil
    }
    
    private func calculateDistance() {
        guard let userLocation = usersCurrentLocation else { return }
        guard let annotations = annotations else { return }

        
        DispatchQueue.global(qos: .userInitiated).async {
            var distance: Double?
            var closestAnnotation: VehicleAnnotation?

            for item in annotations {
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
                if let closest = closestAnnotation {
                    self.closestVehicle = closest
                    if let completion = self.completion {
                        completion(.success(closest))
                    }
                    
                    self.completion = nil
                }
            }
        }

    }
}
