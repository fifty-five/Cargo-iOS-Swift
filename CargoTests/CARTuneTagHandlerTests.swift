//
//  CARTuneTagHandlerTests.swift
//  Cargo
//
//  Created by Julien Gil on 30/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo
import Tune

class CARTuneTagHandlerTests: XCTestCase {

    let HANDLER_METHOD = "handlerMethod";

    let TUN_INIT = "TUN_init";
    let TUN_SESSION = "TUN_measureSession";
    let TUN_IDENTIFY = "TUN_identify";
    let TUN_TAG_EVENT = "TUN_tagEvent";

    let ADVERTISER_ID = "advertiserId";
    let CONVERSION_KEY = "conversionKey";

    let advertiser = "randomAdvertiser";
    let conversionKey = "randomConversionKey";
    let userId = "JeanDupont123";
    let facebookId = "012345678910";
    let googleId = "df2451dsf231s2c1";
    let twitterId = "5fa1f3f51r6z1eft";
    let userName = "Jean Dupont";
    let userAge = "42";
    let userMail = "j.dupont@blabla.com";
    let userGender = "male";

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Cargo.instance = nil;
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testConstructor_defaultBehaviour() {
        _ = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        XCTAssertEqual(tuneHandler.initialized, false);
        XCTAssertEqual(tuneHandler.constructorDebugLastArg, false);
        XCTAssertEqual(tuneHandler.constructorCount, 1);
    }

    func testConstructor_debugOn() {
        _ = Cargo.init(logLevel: .verbose);
        let tuneHandler = CARTuneMock();

        XCTAssertEqual(tuneHandler.initialized, false);
        XCTAssertEqual(tuneHandler.constructorDebugLastArg, true);
        XCTAssertEqual(tuneHandler.constructorCount, 1);
    }

    func testExecute_ifDeclarationMakesHandlerValid_butNotInitialized() {
        _ = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        XCTAssertEqual(tuneHandler.valid, true);
        XCTAssertEqual(tuneHandler.initialized, false);
    }

    func testExecute_ifCorrectInitTriggersInitializedBool() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute([HANDLER_METHOD:TUN_INIT,
                       ADVERTISER_ID:advertiser,
                       CONVERSION_KEY:conversionKey]);

        XCTAssertEqual(tuneHandler.initialized, true);
        XCTAssertEqual(tuneHandler.lastAdvertiserId, advertiser);
        XCTAssertEqual(tuneHandler.lastConversionKey, conversionKey);
        XCTAssertEqual(tuneHandler.initializeCount, 1);
        XCTAssertEqual(tuneHandler.initializeValidCount, 1);
    }

    func testExecute_incorrectInitShouldFail() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute([HANDLER_METHOD:TUN_INIT,
                       ADVERTISER_ID:advertiser]);

        XCTAssertEqual(tuneHandler.initialized, false);
        XCTAssertEqual(tuneHandler.lastAdvertiserId, nil);
        XCTAssertEqual(tuneHandler.lastConversionKey, nil);
        XCTAssertEqual(tuneHandler.initializeCount, 1);
        XCTAssertEqual(tuneHandler.initializeValidCount, 0);
    }

    func testExecute_noInitBefore_soMeasureSessionFails() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute([HANDLER_METHOD:TUN_SESSION]);

        XCTAssertEqual(tuneHandler.measureSessionCount, 0);
    }

    func testExecute_measureSessionSuccess() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_SESSION]);

        XCTAssertEqual(tuneHandler.measureSessionCount, 1);
    }

    func testIdentify_allParameters() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_ID:userId,
                       USER_FACEBOOK_ID:facebookId,
                       USER_GOOGLE_ID:googleId,
                       USER_TWITTER_ID:twitterId,
                       USER_NAME:userName,
                       USER_AGE:userAge,
                       USER_EMAIL:userMail,
                       USER_GENDER:userGender]);

        XCTAssertEqual(tuneHandler.identifyCount, 1);
        XCTAssertEqual(tuneHandler.lastUserId, userId);
        XCTAssertEqual(tuneHandler.lastFacebookId, facebookId);
        XCTAssertEqual(tuneHandler.lastGoogleId, googleId);
        XCTAssertEqual(tuneHandler.lastTwitterId, twitterId);
        XCTAssertEqual(tuneHandler.lastUserName, userName);
        XCTAssertEqual(tuneHandler.lastUserAge, userAge);
        XCTAssertEqual(tuneHandler.lastUserMail, userMail);
        XCTAssertEqual(tuneHandler.lastUserGender, userGender);
    }

    func testIdentify_severalParameters() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_ID:userId,
                       USER_EMAIL:userMail,
                       USER_GENDER:userGender]);

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_FACEBOOK_ID:facebookId,
                       USER_GOOGLE_ID:googleId,
                       USER_NAME:userName]);

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_FACEBOOK_ID:"",
                       USER_GENDER:"grxmlblbl"]);

        XCTAssertEqual(tuneHandler.identifyCount, 3);
        XCTAssertEqual(tuneHandler.lastUserId, userId);
        XCTAssertEqual(tuneHandler.lastFacebookId, "");
        XCTAssertEqual(tuneHandler.lastGoogleId, googleId);
        XCTAssertEqual(tuneHandler.lastTwitterId, nil);
        XCTAssertEqual(tuneHandler.lastUserAge, nil);
        XCTAssertEqual(tuneHandler.lastUserMail, userMail);
        XCTAssertEqual(tuneHandler.lastUserGender, "grxmlblbl");
    }

    func testSetGenderSuccess() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_GENDER:"MALE"]);
        XCTAssertEqual(tuneHandler.setGengerCount, 1);
        XCTAssertEqual(tuneHandler.lastTuneGender, TuneGender.male);

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_GENDER:"lkfhsdf"]);
        XCTAssertEqual(tuneHandler.setGengerCount, 2);
        XCTAssertEqual(tuneHandler.lastTuneGender, TuneGender.unknown);

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_GENDER:"Female"]);
        XCTAssertEqual(tuneHandler.setGengerCount, 3);
        XCTAssertEqual(tuneHandler.lastTuneGender, TuneGender.female);
    }

}
