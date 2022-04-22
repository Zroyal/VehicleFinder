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
    var attributes: VehicleAttributesModel?

    enum CodingKeys: String, CodingKey {
        case type
        case vehicleId = "id"
        case attributes
    }
    
}

