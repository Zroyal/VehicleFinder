//
//  Vehicle.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

class VehicleModel: Codable {
    var type: String?
    var vehicleId: String?
    var vehicleType: String?
    var lat: Double?
    var long: Double?
    var maxSpeed: Int?
    var batteryLevel: Int?
    var hasHelmetBox: Bool?

    enum VehicleModelKeys: String, CodingKey {
        case type
        case vehicleId = "id"
        case vehicleType
        case lat
        case long
        case maxSpeed
        case batteryLevel
        case hasHelmetBox
        case attributes
    }
    
    init (dict: [String: Any]) {
        self.type = dict[VehicleModelKeys.type.rawValue] as? String
        self.vehicleId = dict[VehicleModelKeys.vehicleId.rawValue] as? String
        
        if let attributes = dict[VehicleModelKeys.attributes.rawValue] as? [String: Any] {
            self.vehicleType = attributes[VehicleModelKeys.vehicleType.rawValue] as? String
            self.lat = attributes[VehicleModelKeys.lat.rawValue] as? Double
            self.long = attributes[VehicleModelKeys.long.rawValue] as? Double
            self.maxSpeed = attributes[VehicleModelKeys.maxSpeed.rawValue] as? Int
            self.batteryLevel = attributes[VehicleModelKeys.batteryLevel.rawValue] as? Int
            self.hasHelmetBox = attributes[VehicleModelKeys.hasHelmetBox.rawValue] as? Bool
        }
    }

    required init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: VehicleModelKeys.self)
        
        self.type = try? container.decode(String.self, forKey: .type)
        self.vehicleId = try? container.decode(String.self, forKey: .vehicleId)
        self.vehicleType = try? container.decode(String.self, forKey: .vehicleType)
        self.lat = try? container.decode(Double.self, forKey: .lat)
        self.long = try? container.decode(Double.self, forKey: .long)
        self.maxSpeed = try? container.decode(Int.self, forKey: .maxSpeed)
        self.batteryLevel = try? container.decode(Int.self, forKey: .batteryLevel)
        self.hasHelmetBox = try? container.decode(Bool.self, forKey: .hasHelmetBox)
    }

}

