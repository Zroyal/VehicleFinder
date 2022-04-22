//
//  Vehicle.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

struct VehicleModel: Codable, Equatable {
    var type: String?
    var vehicleId: String?
    var attributes: VehicleAttributesModel?

    enum CodingKeys: String, CodingKey {
        case type
        case vehicleId = "id"
        case attributes
    }
    
    static func == (lhs: VehicleModel, rhs: VehicleModel) -> Bool {
        (lhs.type == rhs.type &&
        lhs.vehicleId == rhs.vehicleId &&
        lhs.attributes == rhs.attributes)
    }
}

