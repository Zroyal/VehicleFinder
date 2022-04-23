//
//  ViewModelTests.swift
//  vehicleFinderTests
//
//  Created by Zeinab Khosravinia on 4/23/22.
//

import XCTest
import Combine
@testable import vehicleFinder

class ViewModelTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
    }

    override func tearDownWithError() throws {
    }

    func testMapViewModelFetchScootersSuccess() throws {
        let networker = MockNetworker()
        let repo = DefaultScooterRepository(networker: networker)
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = MockLocationManager()
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        
        let sut = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        
        let statusExpectation = self.expectation(description: "statusSuccess")

        sut.$status.sink(receiveValue: { value in
            if value == .success {
                statusExpectation.fulfill()
            }
        }).store(in: &cancellables)

        sut.fetchScooters()
        
        waitForExpectations(timeout: 2)

        XCTAssertTrue(sut.error == nil)
        XCTAssertTrue(sut.annotations.count == 2)
        XCTAssertTrue(sut.status == .success)
    }

    func testMapViewModelFetchScootersFail() throws {
        let networker = MockNetworker(needSuccess: false)
        let repo = DefaultScooterRepository(networker: networker)
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = MockLocationManager()
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        
        let sut = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        
        let statusExpectation = self.expectation(description: "statusFail")

        sut.$status.sink(receiveValue: { value in
            if value == .fail {
                statusExpectation.fulfill()
            }
        }).store(in: &cancellables)

        sut.fetchScooters()
        
        waitForExpectations(timeout: 2)

        XCTAssertNotNil(sut.error)
        XCTAssertTrue(sut.annotations.count == 0)
        XCTAssertTrue(sut.status == .fail)
    }

    
    func testMapViewModelCalculateClosestDisance() throws {
        let networker = MockNetworker()
        let repo = DefaultScooterRepository(networker: networker)
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = MockLocationManager()
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        
        let sut = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        
        let expectation = self.expectation(description: "testMapViewModelCalculateClosestDisance")

        var distance: Double?
        
        sut.$status.sink(receiveValue: { value in
            if value == .success {
                sut.showClosestVehicle()
            }
        }).store(in: &cancellables)

        sut.$closestVehicle.sink(receiveValue: { _ in
            distance = sut.calculateClosestDisance()
            if distance != nil {
                expectation.fulfill()
            }
        }).store(in: &cancellables)


        sut.fetchScooters()
        
        waitForExpectations(timeout: 2)

        XCTAssertTrue(distance == 0)
    }

    
    func testMapViewModelCalculateClosestDisanceFail() throws {
        let networker = MockNetworker()
        let repo = DefaultScooterRepository(networker: networker)
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = MockLocationManager(needSuccess: false)
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        
        let sut = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        
        let expectation = self.expectation(description: "testMapViewModelCalculateClosestDisance")

        var distance: Double?
        var error: GeneralError?

        sut.$status.sink(receiveValue: { value in
            if value == .success {
                sut.showClosestVehicle()
            }
        }).store(in: &cancellables)

        sut.$closestVehicle.sink(receiveValue: { _ in
            distance = sut.calculateClosestDisance()
            
        }).store(in: &cancellables)

        sut.$closestVehicleFindingError.sink(receiveValue: { err in
            if err != nil {
                error = err
                expectation.fulfill()
            }

        }).store(in: &cancellables)


        sut.fetchScooters()
        
        waitForExpectations(timeout: 2)

        XCTAssertNil(distance)
        XCTAssertNotNil(error)
    }

    
    func testMapViewModelGetClosestAnnotation() throws {
        let networker = MockNetworker()
        let repo = DefaultScooterRepository(networker: networker)
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = MockLocationManager()
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        
        let sut = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        
        let expectation = self.expectation(description: "testMapViewModelGetClosestAnnotation")

        var annotation: VehicleAnnotation?
        
        sut.$status.sink(receiveValue: { value in
            if value == .success {
                sut.showClosestVehicle()
            }
        }).store(in: &cancellables)

        sut.$closestVehicle.sink(receiveValue: { annot in
            if annot != nil {
                annotation = annot
                expectation.fulfill()
            }
            
        }).store(in: &cancellables)

        sut.fetchScooters()
        
        waitForExpectations(timeout: 2)

        XCTAssertEqual(annotation?.model, TestMockData.vehicleAnnotation2.model)
        XCTAssertEqual(annotation?.coordinate.latitude, TestMockData.vehicleAnnotation2.model?.attributes?.latitude)
        XCTAssertEqual(annotation?.coordinate.longitude, TestMockData.vehicleAnnotation2.model?.attributes?.longitude)
    }


    func testAnnotationInfo() throws {
        let networker = MockNetworker()
        let repo = DefaultScooterRepository(networker: networker)
        let fetchUseCase = DefaultFetchScooterListUseCase(repo: repo)
        let locationManager = MockLocationManager()
        let locationUseCase = DefaultLocationManagerUseCase(manager: locationManager)
        
        let sut = DefaultMapViewModel(fetchUseCase: fetchUseCase, locationUseCase: locationUseCase)
        

        let message = sut.getAlertInfo(annotation: TestMockData.vehicleAnnotation1, distance: 10)

        XCTAssertEqual(message.0, "Selected Vehicle Information")
        XCTAssertEqual(message.1, "\nType: escooter\nHas Helment Box: false\nBattery Level: 51\nMax Speed: 20\nDistance: 10.0\n")

    }
}
