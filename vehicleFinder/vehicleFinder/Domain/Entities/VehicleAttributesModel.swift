//
//  VehicleAttributesModel.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

class VehicleAttributesModel: Codable {
    var vehicleType: String?
    var latitude: Double?
    var longitude: Double?
    var maxSpeed: Int?
    var batteryLevel: Int?
    var hasHelmetBox: Bool?

    enum CodingKeys: String, CodingKey {
        case vehicleType
        case latitude = "lat"
        case longitude = "lng"
        case maxSpeed
        case batteryLevel
        case hasHelmetBox
    }
}

