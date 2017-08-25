//
//  CargoTests.swift
//  CargoTests
//
//  Created by Julien Gil on 03/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo

class CargoTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Cargo.instance = nil;
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let cargo = Cargo.init(logLevel: .none);
        XCTAssertEqual(cargo, Cargo.getInstance());
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.none);
        XCTAssertEqual(cargo.logger.context, "Cargo");
    }

    func testGetInstance() {
        XCTAssertTrue(Cargo.getInstance().logger.level == CARLogger.LogLevelType.none);
    }

    func testLogLevel() {
        let cargo = Cargo.getInstance();
        cargo.setLogLevel(level: CARLogger.LogLevelType.none);
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.none);
        cargo.setLogLevel(level: CARLogger.LogLevelType.verbose);
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.verbose);
        cargo.setLogLevel(level: CARLogger.LogLevelType.debug);
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.debug);
        cargo.setLogLevel(level: CARLogger.LogLevelType.info);
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.info);
        cargo.setLogLevel(level: CARLogger.LogLevelType.warning);
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.warning);
        cargo.setLogLevel(level: CARLogger.LogLevelType.error);
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.error);
    }

}
