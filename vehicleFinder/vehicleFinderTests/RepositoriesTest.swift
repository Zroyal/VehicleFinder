//
//  RepositoriesTest.swift
//  vehicleFinderTests
//
//  Created by Zeinab Khosravinia on 4/23/22.
//

import XCTest
import Combine
@testable import vehicleFinder

class RepositoriesTest: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
    }

    override func tearDownWithError() throws {
    }

    func testScooterRepository() throws {
        let networker = MockNetworker()
        let sut = DefaultScooterRepository(networker: networker)

        var error: GeneralError?
        var response: ResponseModel?

        let expectation = self.expectation(description: "testScooterRepository")
        
        sut.getVehicles()
            .receive(on: DispatchQueue.main)
            .sink { completionBlock in
                expectation.fulfill()
                
                switch completionBlock {
                    
                case .failure(let err):
                    error = err
                    
                case .finished: break
                }
                
            } receiveValue: { value in
                response = value

            }
            .store(in: &cancellables)


        waitForExpectations(timeout: 2)

        XCTAssertNil(error)
        XCTAssertTrue(response?.data?.count == 2)
        
        if let model1 = response?.data?[0] {
            let test1 = TestMockData.vehicleModel1
            XCTAssertTrue(model1 == test1)

        } else {
            XCTAssert(true)
        }
        
        if let model2 = response?.data?[1] {
            let test2 = TestMockData.vehicleModel2
            XCTAssertTrue(model2 == test2)

        } else {
            XCTAssert(true)
        }

    }
    
    func testScooterRepositoryFailResponse() throws {
        let networker = MockNetworker(needSuccess: false)
        let sut = DefaultScooterRepository(networker: networker)

        var error: GeneralError?
        var response: ResponseModel?

        let expectation = self.expectation(description: "testScooterRepositoryFailResponse")
        
        sut.getVehicles()
            .receive(on: DispatchQueue.main)
            .sink { completionBlock in
                expectation.fulfill()
                
                switch completionBlock {
                    
                case .failure(let err):
                    error = err
                    
                case .finished: break
                }
                
            } receiveValue: { value in
                response = value

            }
            .store(in: &cancellables)


        waitForExpectations(timeout: 2)

        XCTAssertNil(response)
        XCTAssertNotNil(error)
    }
}
