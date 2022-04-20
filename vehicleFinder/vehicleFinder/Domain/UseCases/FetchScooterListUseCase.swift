//
//  FetchScooterListUseCase.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import Combine

protocol FetchScooterListUseCase {
    func fetchScooters(completion: @escaping (Result<[VehicleModel], APIError>) -> Void)
}

class DefaultFetchScooterListUseCase: FetchScooterListUseCase {
    private var repo: ScooterRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repo: ScooterRepository) {
        self.repo = repo
    }
    
    func fetchScooters(completion: @escaping (Result<[VehicleModel], APIError>) -> Void) {
            
            repo.getVehicles()
                .receive(on: DispatchQueue.main)
                .sink { completionBlock in
                    switch completionBlock {
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                    case .finished: break
                    }
                    
                } receiveValue: { value in
                    completion(.success(value.data ?? []))
                }
                .store(in: &cancellables)
        }
    
}
