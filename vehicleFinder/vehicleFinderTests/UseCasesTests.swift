//
//  UseCasesTests.swift
//  vehicleFinderTests
//
//  Created by Zeinab Khosravinia on 4/23/22.
//

import XCTest
@testable import vehicleFinder

class UseCasesTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
    }

    func testScooterFetcherUseCase() throws {
        let networker = MockNetworker()
        let repo = DefaultScooterRepository(networker: networker)
        
        let sut = DefaultFetchScooterListUseCase(repo: repo)
        
        var error: GeneralError?
        var response: [VehicleModel]?

        let expectation = self.expectation(description: "testScooterFetcherUseCase")

        sut.fetchScooters { result in
            expectation.fulfill()
            
            switch result {
            case .success(let list):
                response = list
                
            case .failure(let err):
                error = err
            }

        }

        waitForExpectations(timeout: 2)

        XCTAssertNil(error)
        XCTAssertTrue(response?.count == 2)
        
        if let model1 = response?[0] {
            let test1 = TestMockData.vehicleModel1
            XCTAssertTrue(model1 == test1)

        } else {
            XCTAssert(true)
        }
        
        if let model2 = response?[1] {
            let test2 = TestMockData.vehicleModel2
            XCTAssertTrue(model2 == test2)

        } else {
            XCTAssert(true)
        }
    }
    
    
    func testScooterFetcherUseCaseFail() throws {
        let networker = MockNetworker(needSuccess: false)
        let repo = DefaultScooterRepository(networker: networker)
        
        let sut = DefaultFetchScooterListUseCase(repo: repo)
        
        var error: GeneralError?
        var response: [VehicleModel]?

        let expectation = self.expectation(description: "testScooterFetcherUseCase")

        sut.fetchScooters { result in
            expectation.fulfill()
            
            switch result {
            case .success(let list):
                response = list
                
            case .failure(let err):
                error = err
            }

        }

        waitForExpectations(timeout: 2)

        XCTAssertNil(response)
        XCTAssertNotNil(error)
    }

    
    func testLocationUseCase() throws {
        let annotations = TestMockData.annotations
        let locationManager = MockLocationManager()
        
        let sut = DefaultLocationManagerUseCase(manager: locationManager)
        
        var error: GeneralError?
        var closest: VehicleAnnotation?
        
        let expectation = self.expectation(description: "testLocationUseCase")

        sut.getClosestLocation(annotations: annotations) { result in
            expectation.fulfill()
            
            switch result {
            case .success(let annotation):
                closest = annotation
                
            case .failure(let err):
                error = err
            }
        }
        
        
        waitForExpectations(timeout: 2)

        XCTAssertNil(error)
        XCTAssertEqual(closest?.model, TestMockData.vehicleAnnotation2.model)

    }
    
    func testLocationUseCaseGetDistanse() throws {
        let annotations = TestMockData.annotations
        let locationManager = MockLocationManager()
        
        let sut = DefaultLocationManagerUseCase(manager: locationManager)
        
        var error: GeneralError?
        var distance: Double?
        
        let expectation = self.expectation(description: "testLocationUseCase")

        sut.getClosestLocation(annotations: annotations) { result in
            expectation.fulfill()
            
            switch result {
            case .success(_):
                distance = sut.calculateClosestDisance()
                
            case .failure(let err):
                error = err
            }
        }
        
        waitForExpectations(timeout: 2)

        XCTAssertNil(error)
        XCTAssertEqual(distance, 0)
    }


    func testLocationUseCaseFail() throws {
        let annotations = TestMockData.annotations
        let locationManager = MockLocationManager(needSuccess: false)
        
        let sut = DefaultLocationManagerUseCase(manager: locationManager)
        
        var error: GeneralError?
        var closest: VehicleAnnotation?
        
        let expectation = self.expectation(description: "testLocationUseCase")

        sut.getClosestLocation(annotations: annotations) { result in
            expectation.fulfill()
            
            switch result {
            case .success(let annotation):
                closest = annotation
                
            case .failure(let err):
                error = err
            }
        }
        
        waitForExpectations(timeout: 2)

        XCTAssertNil(closest)
        XCTAssertNotNil(error)
    }

}
