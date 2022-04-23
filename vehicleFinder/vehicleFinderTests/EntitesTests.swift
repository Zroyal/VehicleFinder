//
//  EntitesTests.swift
//  vehicleFinderTests
//
//  Created by Zeinab Khosravinia on 4/23/22.
//

import XCTest
@testable import vehicleFinder

class EntitesTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testInitVehicleModel() throws {
        let modelRawData = TestMockData.vehicleModelRaw
        let model = TestMockData.vehicleModel1
        let decoder = JSONDecoder()
        let data = Data(modelRawData.utf8)
        let sut = try decoder.decode(VehicleModel.self, from: data)
        
        XCTAssertEqual(sut, model)
    }
    
    func testInitVehicleModelEquality() throws {
        let model1 = TestMockData.vehicleModel1
        
        let modelRawData = TestMockData.vehicleModelRaw
        let decoder = JSONDecoder()
        let data = Data(modelRawData.utf8)
        let model2 = try decoder.decode(VehicleModel.self, from: data)

        let model3 = TestMockData.vehicleModel2
        
        XCTAssertEqual(model1, model2)
        XCTAssertNotEqual(model1, model3)
    }

    
    func testInitVehicleAttributesModel() throws {
        let modelRawData = TestMockData.vehicleAttributeRaw
        let model = TestMockData.vehicleModel1.attributes
        let decoder = JSONDecoder()
        let data = Data(modelRawData.utf8)
        let sut = try decoder.decode(VehicleAttributesModel.self, from: data)
        
        XCTAssertEqual(sut, model)
    }

    func testInitResponseModel() throws {
        let rawData = TestMockData.vehiclesRawResponse
        let model = ResponseModel(data: [TestMockData.vehicleModel1, TestMockData.vehicleModel2])
        let decoder = JSONDecoder()
        let data = Data(rawData.utf8)
        let sut = try decoder.decode(ResponseModel.self, from: data)
        
        XCTAssertEqual(sut, model)
    }

    func testInitVehicleAnnotation() throws {
        let model = TestMockData.vehicleModel2
        let sut = VehicleAnnotation(model: model)
        
        XCTAssertEqual(sut.model, model)
        XCTAssertEqual(sut.coordinate.longitude, model.attributes?.longitude)
        XCTAssertEqual(sut.coordinate.latitude, model.attributes?.latitude)
        XCTAssertEqual(sut.title, model.attributes?.vehicleType)
        XCTAssertEqual(sut.subtitle, model.attributes?.vehicleType)
    }

    
    
}
