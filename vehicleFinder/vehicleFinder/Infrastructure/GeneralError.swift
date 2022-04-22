//
//  APIError.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

import Foundation

enum GeneralError: Error {
    case parsing(description: String)
    case network(description: String)
    case locationAccess(description: String)
}
