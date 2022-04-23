//
//  ResponseModel.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

struct ResponseModel: Codable, Equatable {
    var data: [VehicleModel]?
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}
