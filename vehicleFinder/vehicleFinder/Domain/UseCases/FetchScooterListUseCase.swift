//
//  FetchScooterListUseCase.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import Combine

typealias VehicleFetchResult = (Result<[VehicleModel], GeneralError>) -> Void

protocol FetchScooterListUseCase {
    func fetchScooters(completion: @escaping VehicleFetchResult)
}

class DefaultFetchScooterListUseCase: FetchScooterListUseCase {
    private var repo: ScooterRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(repo: ScooterRepository) {
        self.repo = repo
    }
    
    func fetchScooters(completion: @escaping VehicleFetchResult) {
            
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
