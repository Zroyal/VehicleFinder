//
//  ScooterRepository.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import Combine

protocol ScooterRepository {
    func getVehicles() -> AnyPublisher<ResponseModel, APIError>
}
