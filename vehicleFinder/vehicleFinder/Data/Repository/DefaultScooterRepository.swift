//
//  ScooterRepository.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import Combine

class DefaultScooterRepository: ScooterRepository {
    
    private let networker: Networkable
    private var cancellables = Set<AnyCancellable>()

    init(networker: Networkable = Networker()) {
        self.networker = networker
    }

    func getVehicles() -> AnyPublisher<ResponseModel, GeneralError> {
        let path = APIEndpoints().getScooterPath()
        let publisher: AnyPublisher<ResponseModel, GeneralError> = networker.get(type: ResponseModel.self, path: path)
        
        publisher.sink { completion in
            
        } receiveValue: { value in
            
        }.store(in: &cancellables)

        return publisher
    }
}
