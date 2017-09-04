//
//  CARFacebookTagHandlerTests.swift
//  Cargo
//
//  Created by Julien Gil on 31/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo

class CARFacebookTagHandlerTests: XCTestCase {

    let HANDLER_METHOD = "handlerMethod";

    let FB_INIT = "FB_init";
    let FB_ACTIVATE_APP = "FB_activateApp";
    let FB_TAG_EVENT = "FB_tagEvent";
    let FB_TAG_PURCHASE = "FB_tagPurchase";

    let APPLICATION_ID = "applicationId";
    let EVENT_NAME = "eventName";
    let VALUE_TO_SUM = "valueToSum";

    let applicationId = "123456789369852174";
    let eventName = "a_random_event_name";
    let valueToSum = 15.3;
    
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
        let facebookHandler = CARFacebookMock();

        XCTAssertFalse(facebookHandler.initialized);
        XCTAssertEqual(facebookHandler.key, "FB");
        XCTAssertEqual(facebookHandler.name, "Facebook");
        XCTAssertTrue(facebookHandler.debug);
    }

    func testConstructor_withoutDebug() {
        _ = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();

        XCTAssertFalse(facebookHandler.initialized);
        XCTAssertEqual(facebookHandler.key, "FB");
        XCTAssertEqual(facebookHandler.name, "Facebook");
        XCTAssertFalse(facebookHandler.debug);
    }

    func testExecute_ifDeclarationMakesHandlerValid_butNotInitialized() {
        _ = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();

        XCTAssertTrue(facebookHandler.valid);
        XCTAssertFalse(facebookHandler.initialized);
    }

    func testExecute_ifCorrectInitTriggersInitializedBool() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();

        cargo.execute([HANDLER_METHOD:FB_INIT,
                       APPLICATION_ID:applicationId]);

        XCTAssertTrue(facebookHandler.initialized);
        XCTAssertEqual(facebookHandler.lastApplicationId, applicationId);
        XCTAssertEqual(facebookHandler.initializeCount, 1);
        XCTAssertEqual(facebookHandler.initializeValidCount, 1);
        XCTAssertEqual(facebookHandler.activateAppCount, 1);
    }

    func testExecute_incorrectInitShouldFail() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();

        cargo.execute([HANDLER_METHOD:FB_INIT]);

        XCTAssertFalse(facebookHandler.initialized);
        XCTAssertEqual(facebookHandler.lastApplicationId, nil);
        XCTAssertEqual(facebookHandler.initializeCount, 1);
        XCTAssertEqual(facebookHandler.initializeValidCount, 0);
        XCTAssertEqual(facebookHandler.activateAppCount, 0);
    }

    func testExecute_noInitBefore_soCallFails() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();

        cargo.execute([HANDLER_METHOD:FB_ACTIVATE_APP]);

        XCTAssertEqual(facebookHandler.activateAppCount, 0);
    }

    func testExecute_activateApp() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_ACTIVATE_APP]);

        XCTAssertEqual(facebookHandler.activateAppCount, 1);
        XCTAssertEqual(facebookHandler.executeCount, 1);
        XCTAssertEqual(facebookHandler.executeInitCount, 0);
        XCTAssertEqual(facebookHandler.executeSwitchCount, 1);
        XCTAssertEqual(facebookHandler.executeUnknownFunctionCount, 0);
        XCTAssertEqual(facebookHandler.executeUninitializedCount, 0);
    }

    func testExecute_withUnknownMethod() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:"FB_unknown"]);

        XCTAssertEqual(facebookHandler.executeCount, 1);
        XCTAssertEqual(facebookHandler.executeInitCount, 0);
        XCTAssertEqual(facebookHandler.executeSwitchCount, 1);
        XCTAssertEqual(facebookHandler.executeUnknownFunctionCount, 1);
        XCTAssertEqual(facebookHandler.executeUninitializedCount, 0);
    }

    func testTagEvent_withEventName() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_EVENT,
                       EVENT_NAME:eventName]);

        XCTAssertEqual(facebookHandler.tagEventCount, 1);
        XCTAssertEqual(facebookHandler.lastTagEventName, eventName);
        XCTAssertEqual(facebookHandler.lastValueToSum, nil);
        XCTAssertEqual(facebookHandler.lastCountOfParams, 0);
        XCTAssertFalse(facebookHandler.tagEventErrored);
    }

    func testTagEvent_withEventNameAndValue() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_EVENT,
                       EVENT_NAME:eventName,
                       VALUE_TO_SUM:valueToSum]);

        XCTAssertEqual(facebookHandler.tagEventCount, 1);
        XCTAssertEqual(facebookHandler.lastTagEventName, eventName);
        XCTAssertEqual(facebookHandler.lastValueToSum, valueToSum);
        XCTAssertEqual(facebookHandler.lastCountOfParams, 0);
        XCTAssertFalse(facebookHandler.tagEventErrored);
    }

    func testTagEvent_withEventNameAndValue_plusAdditionalParameters() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_EVENT,
                       EVENT_NAME:eventName,
                       VALUE_TO_SUM:valueToSum,
                       "param1":"blabla",
                       "param2":"blublu",
                       "param3":"blibli"]);

        XCTAssertEqual(facebookHandler.tagEventCount, 1);
        XCTAssertEqual(facebookHandler.lastTagEventName, eventName);
        XCTAssertEqual(facebookHandler.lastValueToSum, valueToSum);
        XCTAssertEqual(facebookHandler.lastCountOfParams, 3);
        XCTAssertFalse(facebookHandler.tagEventErrored);
    }

    func testTagEvent_withEventName_plusAdditionalParameters() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_EVENT,
                       EVENT_NAME:eventName,
                       "param1":"blabla",
                       "param2":"blublu",
                       "param3":"blibli"]);

        XCTAssertEqual(facebookHandler.tagEventCount, 1);
        XCTAssertEqual(facebookHandler.lastTagEventName, eventName);
        XCTAssertEqual(facebookHandler.lastValueToSum, nil);
        XCTAssertEqual(facebookHandler.lastCountOfParams, 3);
        XCTAssertFalse(facebookHandler.tagEventErrored);
    }

    func testTagEvent_errorWithoutEventName() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_EVENT,
                       VALUE_TO_SUM:valueToSum,
                       "param1":"blabla",
                       "param2":"blublu",
                       "param3":"blibli"]);

        XCTAssertEqual(facebookHandler.tagEventCount, 1);
        XCTAssertEqual(facebookHandler.lastTagEventName, nil);
        XCTAssertEqual(facebookHandler.lastValueToSum, nil);
        XCTAssertEqual(facebookHandler.lastCountOfParams, 0);
        XCTAssertTrue(facebookHandler.tagEventErrored);
    }

    func testPurchase_success() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_PURCHASE,
                       "transactionTotal":55.42,
                       "transactionCurrencyCode":"USD"]);

        XCTAssertEqual(facebookHandler.purchaseCount, 1);
        XCTAssertEqual(facebookHandler.lastAmount, 55.42);
        XCTAssertEqual(facebookHandler.lastCurrencyCode, "USD");
        XCTAssertFalse(facebookHandler.purchaseErrored);
    }

    func testPurchase_errored_withoutCurrencyCode() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_PURCHASE,
                       "transactionTotal":55.42]);

        XCTAssertEqual(facebookHandler.purchaseCount, 1);
        XCTAssertEqual(facebookHandler.lastAmount, nil);
        XCTAssertEqual(facebookHandler.lastCurrencyCode, nil);
        XCTAssertTrue(facebookHandler.purchaseErrored);
    }

    func testPurchase_errored_withoutAmount() {
        let cargo = Cargo.getInstance();
        let facebookHandler = CARFacebookMock();
        facebookHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:FB_TAG_PURCHASE,
                       "transactionCurrencyCode":"USD"]);

        XCTAssertEqual(facebookHandler.purchaseCount, 1);
        XCTAssertEqual(facebookHandler.lastAmount, nil);
        XCTAssertEqual(facebookHandler.lastCurrencyCode, nil);
        XCTAssertTrue(facebookHandler.purchaseErrored);
    }
}
