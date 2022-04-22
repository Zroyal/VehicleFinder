//
//  TestMockData.swift
//  vehicleFinderTests
//
//  Created by Zeinab Khosravinia on 4/23/22.
//

import Foundation
import Combine
@testable import vehicleFinder

struct TestMockData {
    static let vehiclesRawResponse =
"""
{
    "data": [
        {
            "type": "vehicle",
            "id": "a6eec990",
            "attributes": {
                "batteryLevel": 51,
                "lat": 52.562272,
                "lng": 13.335213,
                "maxSpeed": 20,
                "vehicleType": "escooter",
                "hasHelmetBox": false
            }
        },
        {
            "type": "vehicle",
            "id": "efa4de0b",
            "attributes": {
                "batteryLevel": 83,
                "lat": 52.556577,
                "lng": 13.393951,
                "maxSpeed": 20,
                "vehicleType": "escooter",
                "hasHelmetBox": true
            }
        }
    ]
}
"""

    static let vehicleModel1 = VehicleModel(
        type: "vehicle",
        vehicleId: "a6eec990",
        attributes: VehicleAttributesModel(
            vehicleType: "escooter",
            latitude: 52.562272,
            longitude: 13.335213,
            maxSpeed: 20,
            batteryLevel: 51,
            hasHelmetBox: false))

    static let vehicleModel2 = VehicleModel(
        type: "vehicle",
        vehicleId: "efa4de0b",
        attributes: VehicleAttributesModel(
            vehicleType: "escooter",
            latitude: 52.556577,
            longitude: 13.393951,
            maxSpeed: 20,
            batteryLevel: 83,
            hasHelmetBox: true))
    
    
    static let vehicles = [TestMockData.vehicleModel1, TestMockData.vehicleModel2]

}


class MockNetworker: Networkable {
    convenience init(needSuccess: Bool = true) {
        self.init()
        self.needSuccess = needSuccess
    }
    var needSuccess: Bool = true

    
    func get<T>(type: T.Type, path: String) -> AnyPublisher<T, GeneralError> where T : Decodable {
        guard let url = URL(string: path) else {
            let error = GeneralError.network(
                description: StringConstatns.createUrlError)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil)!
        
        guard needSuccess else {
            
            let response: AnyPublisher<T, GeneralError> =
            Result<T, GeneralError>.Publisher(.failure(.network(description: "This is a mock failed response")))
                .eraseToAnyPublisher()
            return response
        }
        
        let data = TestMockData.vehiclesRawResponse.data(using: .utf8)!
        
        let pub: AnyPublisher<T, GeneralError> = Just((data: data, response: response))
            .flatMap { dataResponse in
                return decode(dataResponse.data)
            }
        
            .eraseToAnyPublisher()
        
        return pub

    }
}
