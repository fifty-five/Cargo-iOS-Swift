//
//  CargoItemTests.swift
//  Cargo
//
//  Created by Julien Gil on 24/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo

class CargoItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CargoItem.notifyTagFired();
        super.tearDown()
    }

    func testCountElements() {
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem", unitPrice: 42.55, quantity: 2));
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem2", unitPrice: 55.42, quantity: 3, revenue: 160.99));
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem3", unitPrice: 100, quantity: 8));
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem4", unitPrice: 33, quantity: 10));

        XCTAssertEqual(CargoItem.getItemsArray()?.count, 4);
    }

    func testVerifItemConstructor1() {
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem", unitPrice: 42.55, quantity: 2));
        let item = CargoItem.getItemsArray()![0];

        XCTAssertEqual(item.name, "testItem");
        XCTAssertEqual(item.unitPrice, 42.55);
        XCTAssertEqual(item.quantity, 2);
        XCTAssertEqual(item.revenue, 85.10);
    }

    func testVerifItemConstructor2() {
        let cargoItem = CargoItem.init(name: "testItem", unitPrice: 42.55, quantity: 2, revenue: 99.99);
        cargoItem.attribute1 = "attribute 1";
        cargoItem.attribute2 = "attribute 2";
        cargoItem.attribute3 = "attribute 3";
        cargoItem.attribute4 = "attribute 4";
        cargoItem.attribute5 = "attribute 5";
        CargoItem.attachItemToEvent(item: cargoItem);
        let item = CargoItem.getItemsArray()![0];

        XCTAssertEqual(item.name, "testItem");
        XCTAssertEqual(item.unitPrice, 42.55);
        XCTAssertEqual(item.quantity, 2);
        XCTAssertEqual(item.revenue, 99.99);
        XCTAssertEqual(item.attribute1, "attribute 1");
        XCTAssertEqual(item.attribute2, "attribute 2");
        XCTAssertEqual(item.attribute3, "attribute 3");
        XCTAssertEqual(item.attribute4, "attribute 4");
        XCTAssertEqual(item.attribute5, "attribute 5");
    }

    func testFlushItems() {
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem", unitPrice: 42.55, quantity: 2));

        XCTAssertEqual(CargoItem.getItemsArray()?[0].name, "testItem");
        CargoItem.notifyTagFired();

        CargoItem.attachItemToEvent(item: CargoItem.init(name: "otherTestItem", unitPrice: 42.55, quantity: 2));
        XCTAssertEqual(CargoItem.getItemsArray()?[0].name, "otherTestItem");
    }

    func testSetNewArray() {
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem", unitPrice: 42.55, quantity: 2));
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem2", unitPrice: 55.42, quantity: 3, revenue: 160.99));
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem3", unitPrice: 100, quantity: 8));
        CargoItem.attachItemToEvent(item: CargoItem.init(name: "testItem4", unitPrice: 33, quantity: 10));

        XCTAssertEqual(CargoItem.getItemsArray()?.count, 4);

        CargoItem.setNewItemsArray(newItemsArray: [CargoItem.init(name: "anotherItem", unitPrice: 42.55, quantity: 2), CargoItem.init(name: "Last Item", unitPrice: 42.55, quantity: 2)]);

        XCTAssertEqual(CargoItem.getItemsArray()?.count, 2);
    }


    func testToString() {
        let myItem = CargoItem.init(name: "testItem", unitPrice: 42.55, quantity: 2);
        XCTAssertEqual(String(describing: myItem), "{\n\"name\": \"testItem\",\n \"unitPrice\": \"42.55\",\n" +
        "\"quantity\": \"2\",\n\"revenue\": \"85.1\"\n}");
    }
}
