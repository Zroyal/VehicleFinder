//
//  Networker.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation

import Combine

protocol Networkable: AnyObject {
    func get<T>(
        type: T.Type,
        path: String) -> AnyPublisher<T, APIError> where T: Decodable
}

class Networker: Networkable {
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get<T>(
        type: T.Type,
        path: String) -> AnyPublisher<T, APIError> where T: Decodable {
            
            return fetch(with: path)
        }
    
    
    private func fetch<T>(with path: String) -> AnyPublisher<T, APIError> where T: Decodable {
        
        guard let url = URL(string: path) else {
            let error = APIError.network(
                description: StringConstatns.createUrlError)
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let cancellable = session.dataTaskPublisher(for: URLRequest(url: url))
        
        cancellable
            .sink { completion in
                switch completion {
                    
                case .failure(let error):
                    print("error from api \(error)")
                    
                case .finished: break
                }
            } receiveValue: { response in
                print("fetching data: \(response.data)")

                do {
                    if let jsonDict = try JSONSerialization.jsonObject(with: response.data) as? NSDictionary {
                        print("response: \(jsonDict)")
                    }

                } catch(let error) {
                    print("error from api \(error)")
                }

            }
            .store(in: &cancellables)
        
        
        let pub: AnyPublisher<T, APIError> = cancellable
            .mapError { error in
                return APIError.network(description: error.localizedDescription)
            }
        
            .flatMap(maxPublishers: .max(1)) { dataResponse -> AnyPublisher<T, APIError> in
                return decode(dataResponse.data)
            }
        
            .eraseToAnyPublisher()
        
        return pub
    }
}
