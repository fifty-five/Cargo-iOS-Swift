//
//  CARATInternetTagHandlerTests.swift
//  Cargo
//
//  Created by Julien Gil on 31/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo

class CARATInternetTagHandlerTests: XCTestCase {

    let HANDLER_METHOD = "handlerMethod";

    let AT_INIT = "AT_init";
    let AT_SET_CONFIG = "AT_setConfig";
    let AT_TAG_SCREEN = "AT_tagScreen";
    let AT_TAG_EVENT = "AT_tagEvent";
    let AT_IDENTIFY = "AT_identify";

    let SITE = "site";
    let LOG = "log";
    let LOG_SSL = "logSSL";
    let SCREEN_NAME = "screenName";
    let OVERRIDE = "override";
    let EVENT_TYPE = "eventType";
    let EVENT_NAME = "eventName";
    let USER_ID = "userId";


    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Cargo.instance = nil;
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        CargoItem.notifyTagFired();
        super.tearDown()
    }

    func testConstructor_withDebug() {
        _ = Cargo(logLevel: .verbose);
        let atHandler = CARATMock();

        XCTAssertFalse(atHandler.initialized);
        XCTAssertEqual(atHandler.key, "AT");
        XCTAssertEqual(atHandler.name, "AT Internet");
        XCTAssertTrue(atHandler.lastDebugValue);
    }

    func testConstructor_withoutDebug() {
        _ = Cargo.getInstance();
        let atHandler = CARATMock();

        XCTAssertFalse(atHandler.initialized);
        XCTAssertEqual(atHandler.key, "AT");
        XCTAssertEqual(atHandler.name, "AT Internet");
        XCTAssertFalse(atHandler.lastDebugValue);
    }

    func testExecute_ifDeclarationMakesHandlerValid_butNotInitialized() {
        _ = Cargo.getInstance();
        let atHandler = CARATMock();

        XCTAssertTrue(atHandler.valid);
        XCTAssertFalse(atHandler.initialized);
    }

    func testExecute_ifCorrectInitTriggersInitializedBool() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();

        cargo.execute([HANDLER_METHOD:AT_INIT,
                       LOG_SSL:"random_log",
                       SITE:"12345",
                       LOG:"someLogs"]);

        XCTAssertTrue(atHandler.initialized);
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeInitCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 0);
        XCTAssertEqual(atHandler.lastLog, "someLogs");
        XCTAssertEqual(atHandler.lastLogSSL, "random_log");
        XCTAssertEqual(atHandler.lastSiteId, 12345);
        XCTAssertEqual(atHandler.executeUnknownFunctionCount, 0);
        XCTAssertEqual(atHandler.executeUninitializedCount, 0);
        XCTAssertEqual(atHandler.initializeCount, 1);
    }

    func testExecute_erroredInit() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();

        cargo.execute([HANDLER_METHOD:AT_INIT,
                       LOG_SSL:"random_log",
                       LOG:"someLogs"]);

        XCTAssertFalse(atHandler.initialized);
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeInitCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 0);
        XCTAssertEqual(atHandler.lastLog, nil);
        XCTAssertEqual(atHandler.lastLogSSL, nil);
        XCTAssertEqual(atHandler.lastSiteId, nil);
        XCTAssertEqual(atHandler.executeUnknownFunctionCount, 0);
        XCTAssertEqual(atHandler.executeUninitializedCount, 0);
        XCTAssertEqual(atHandler.initializeCount, 1);
    }

    func testExecute_withNoPreviousInit() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();

        cargo.execute([HANDLER_METHOD:AT_TAG_SCREEN,
                       SCREEN_NAME:"randomScreen Name"]);

        XCTAssertFalse(atHandler.initialized);
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeInitCount, 0);
        XCTAssertEqual(atHandler.executeSwitchCount, 0);
        XCTAssertEqual(atHandler.executeUnknownFunctionCount, 0);
        XCTAssertEqual(atHandler.executeUninitializedCount, 1);
        XCTAssertEqual(atHandler.tagScreenCount, 0);
    }

    func testExecute_withUnknownMethod() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:"AT_unknown"]);

        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeInitCount, 0);
        XCTAssertEqual(atHandler.executeSwitchCount, 1);
        XCTAssertEqual(atHandler.executeUnknownFunctionCount, 1);
        XCTAssertEqual(atHandler.executeUninitializedCount, 0);
    }

    func testSetConfig_withOverride() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_SET_CONFIG,
                       OVERRIDE:true,
                       "param1":"value1",
                       "param2":"value2",
                       "param3":"value3"]);

        XCTAssertEqual(atHandler.setConfigCount, 1);
        XCTAssertEqual(atHandler.lastCountOfParams, 3);
        XCTAssertTrue(atHandler.lastOverrideValue);
    }

    func testSetConfig_withoutOverride() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_SET_CONFIG,
                       OVERRIDE:false,
                       "param1":"value1",
                       "param2":"value2",
                       "param3":"value3"]);

        XCTAssertEqual(atHandler.setConfigCount, 1);
        XCTAssertEqual(atHandler.lastCountOfParams, 3);
        XCTAssertFalse(atHandler.lastOverrideValue);
    }

    func testSimpleTagEvent() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;
        let types = ["sendTouch", "sendNavigation", "sendDownload", "sendExit", "sendSearch"];

        var i = 1;
        for type in types {
            cargo.execute([HANDLER_METHOD:AT_TAG_EVENT,
                           EVENT_TYPE:type,
                           EVENT_NAME:"un event random"]);

            XCTAssertEqual(atHandler.tagEventCount, i);
            XCTAssertEqual(atHandler.tagEventFailedCount, 0);
            XCTAssertEqual(atHandler.lastEventType, type);
            XCTAssertEqual(atHandler.executeCount, i);
            XCTAssertEqual(atHandler.executeSwitchCount, i);
            i += 1;
        }

        cargo.execute([HANDLER_METHOD:AT_TAG_EVENT,
                       EVENT_TYPE:"grxmlbl",
                       EVENT_NAME:"un event random"]);

        XCTAssertEqual(atHandler.tagEventCount, i);
        XCTAssertEqual(atHandler.tagEventFailedCount, 1);
        XCTAssertNotEqual(atHandler.lastEventType, "grxmlbl");
        XCTAssertEqual(atHandler.executeCount, i);
        XCTAssertEqual(atHandler.executeSwitchCount, i);
    }

    func testSimpleTagEvent_withFailure() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_TAG_EVENT,
                       EVENT_NAME:"un event random"]);

        XCTAssertEqual(atHandler.tagEventCount, 1);
        XCTAssertEqual(atHandler.tagEventFailedCount, 1);
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 1);
    }

    func testSimpleTagScreen() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_TAG_SCREEN,
                       SCREEN_NAME:"homepage"]);

        XCTAssertEqual(atHandler.tagScreenCount, 1);
        XCTAssertEqual(atHandler.tagScreenFailedCount, 0);
        XCTAssertEqual(atHandler.lastScreenName, "homepage");
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 1);
    }

    func testSimpleTagScreen_withFailure() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_TAG_SCREEN]);

        XCTAssertEqual(atHandler.tagScreenCount, 1);
        XCTAssertEqual(atHandler.tagScreenFailedCount, 1);
        XCTAssertEqual(atHandler.lastScreenName, nil);
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 1);
    }

    func testIdentify_withSuccess() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_IDENTIFY,
                       USER_ID:"jean dupond"]);

        XCTAssertEqual(atHandler.identifyCount, 1);
        XCTAssertEqual(atHandler.identifyErroredCount, 0);
        XCTAssertEqual(atHandler.lastUserId, "jean dupond");
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 1);
    }

    func testIdentify_withMissingUserId() {
        let cargo = Cargo.getInstance();
        let atHandler = CARATMock();
        atHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:AT_IDENTIFY]);

        XCTAssertEqual(atHandler.identifyCount, 1);
        XCTAssertEqual(atHandler.identifyErroredCount, 1);
        XCTAssertEqual(atHandler.lastUserId, nil);
        XCTAssertEqual(atHandler.executeCount, 1);
        XCTAssertEqual(atHandler.executeSwitchCount, 1);
    }

}
