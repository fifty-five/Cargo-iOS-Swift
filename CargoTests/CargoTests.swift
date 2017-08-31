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

    let HANDLER_METHOD = "handlerMethod";

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Cargo.instance = nil;
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }


    // Tests about the log level

    func testInit_withDefaultValueCompliance() {
        let cargo = Cargo.init(logLevel: .none);

        XCTAssertEqual(cargo, Cargo.getInstance());
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.none);
        XCTAssertEqual(cargo.logger.context, "Cargo");
    }

    func testInit_withDifferentLogLevel() {
        let cargo = Cargo.init(logLevel: .verbose);

        XCTAssertEqual(cargo, Cargo.getInstance());
        XCTAssertEqual(cargo.logger.level, CARLogger.LogLevelType.verbose);
        XCTAssertEqual(cargo.logger.context, "Cargo");
    }

    func testGetInstance_withDefaultLogLevel() {
        XCTAssertTrue(Cargo.getInstance().logger.level == CARLogger.LogLevelType.none);
    }

    func testSetLogLevel_withAllLogLevel() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneTagHandler();

        XCTAssertEqual(cargo.registeredTagHandlers["TUN"], tuneHandler);

        for level in CARLogger.LogLevelType.allValues {
            cargo.setLogLevel(level: level);
            XCTAssertEqual(cargo.logger.level, level);
            XCTAssertEqual(cargo.logger.level, tuneHandler.logger.level)
        }
    }


    // Test for the automatic registration of handlers

    func testAddHandler_keyIsMissingAtFirst_thenIsAddedToRegistered() {
        let cargo = Cargo.getInstance();
        XCTAssertEqual(cargo.registeredTagHandlers.index(forKey: "TUN"), nil);

        let tuneHandler = CARTuneTagHandler();
        XCTAssertNotEqual(cargo.registeredTagHandlers.index(forKey: "TUN"), nil);
        XCTAssertEqual(cargo.registeredTagHandlers["TUN"], tuneHandler);
    }


    // Tests for the Execute method

    func testExecute_success() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute([HANDLER_METHOD:"TUN_init",
                       "advertiserId": "123456",
                       "conversionKey": "078910"]);

        XCTAssertEqual(tuneHandler.executeCount, 1);
    }

    func testExecute_failMissingHandlerMethod() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute(["advertiserId": "123456",
                       "conversionKey": "078910"]);

        XCTAssertEqual(tuneHandler.executeCount, 0);
    }

    func testExecute_failMissingHandler() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        cargo.registeredTagHandlers = Dictionary<String, CARTagHandler>();

        cargo.execute([HANDLER_METHOD:"TUN_init",
                       "advertiserId": "123456",
                       "conversionKey": "078910"]);

        XCTAssertEqual(tuneHandler.executeCount, 0);
    }

    func testExecute_failWrongFormatHandlerMethod() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute([HANDLER_METHOD:"TUNinit",
                       "advertiserId": "123456",
                       "conversionKey": "078910"]);

        XCTAssertEqual(tuneHandler.executeCount, 0);
    }
}
