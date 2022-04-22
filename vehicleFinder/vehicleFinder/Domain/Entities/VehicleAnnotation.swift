//
//  VehicleAnnotation.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import MapKit
import Contacts


class VehicleAnnotation: NSObject, MKAnnotation {
    let model: VehicleModel?
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    var mapItem: MKMapItem? {
        guard let vehicle = model?.attributes?.vehicleType else {
        return nil
      }

      let addressDict = [CNPostalAddressStreetKey: vehicle]
      let placemark = MKPlacemark(
        coordinate: coordinate,
        addressDictionary: addressDict)
      let mapItem = MKMapItem(placemark: placemark)
      mapItem.name = vehicle
      return mapItem
    }

    init(model: VehicleModel) {
        self.model = model
        self.coordinate = CLLocationCoordinate2D(
            latitude: model.attributes?.latitude ?? 0,
            longitude: model.attributes?.longitude ?? 0)
        
        self.title = model.attributes?.vehicleType
        self.subtitle = model.attributes?.vehicleType
        super.init()
    }
}
