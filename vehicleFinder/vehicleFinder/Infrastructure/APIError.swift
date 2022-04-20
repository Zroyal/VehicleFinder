//
//  APIError.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

import Foundation

enum APIError: Error {
  case parsing(description: String)
  case network(description: String)
}
