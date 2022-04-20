//
//  APIEndpoints.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

import Foundation

struct APIEndpoints {
    func getScooterPath() -> String {

        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.path = APIConstants.path
        
        return components.url?.absoluteString ?? ""
    }
}
