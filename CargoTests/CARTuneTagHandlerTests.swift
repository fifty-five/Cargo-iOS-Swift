//
//  CARTuneTagHandlerTests.swift
//  Cargo
//
//  Created by Julien Gil on 30/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo

class CARTuneTagHandlerTests: XCTestCase {

    let HANDLER_METHOD = "handlerMethod";

    let TUN_INIT = "TUN_init";
    let TUN_SESSION = "TUN_measureSession";
    let TUN_IDENTIFY = "TUN_identify";
    let TUN_TAG_EVENT = "TUN_tagEvent";

    let ADVERTISER_ID = "advertiserId";
    let CONVERSION_KEY = "conversionKey";
    let EVENT_NAME = "eventName";
    let EVENT_RATING = "eventRating";
    let EVENT_DATE1 = "eventDate1";
    let EVENT_DATE2 = "eventDate2";
    let EVENT_REVENUE = "eventRevenue";
    let EVENT_ITEMS = "eventItems";
    let EVENT_LEVEL = "eventLevel";
    let EVENT_RECEIPT = "eventReceipt";
    let EVENT_QUANTITY = "eventQuantity";
    let EVENT_TRANSACTION_STATE = "eventTransactionState";

    let EVENT_CURRENCY_CODE = "eventCurrencyCode";
    let EVENT_REF_ID = "eventRefId";
    let EVENT_CONTENT_ID = "eventContentId";
    let EVENT_CONTENT_TYPE = "eventContentType";
    let EVENT_SEARCH_STRING = "eventSearchString";
    let EVENT_ATT1 = "eventAttribute1";
    let EVENT_ATT2 = "eventAttribute2";
    let EVENT_ATT3 = "eventAttribute3";
    let EVENT_ATT4 = "eventAttribute4";
    let EVENT_ATT5 = "eventAttribute5";

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
        CargoItem.notifyTagFired();
        super.tearDown()
    }

    func testConstructor_defaultBehaviour() {
        _ = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        XCTAssertFalse(tuneHandler.initialized);
        XCTAssertFalse(tuneHandler.constructorDebugLastArg!);
        XCTAssertEqual(tuneHandler.constructorCount, 1);
    }

    func testConstructor_debugOn() {
        _ = Cargo.init(logLevel: .verbose);
        let tuneHandler = CARTuneMock();

        XCTAssertFalse(tuneHandler.initialized);
        XCTAssertTrue(tuneHandler.constructorDebugLastArg!);
        XCTAssertEqual(tuneHandler.constructorCount, 1);
    }

    func testExecute_ifDeclarationMakesHandlerValid_butNotInitialized() {
        _ = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        XCTAssertTrue(tuneHandler.valid);
        XCTAssertFalse(tuneHandler.initialized);
    }

    func testExecute_ifCorrectInitTriggersInitializedBool() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();

        cargo.execute([HANDLER_METHOD:TUN_INIT,
                       ADVERTISER_ID:advertiser,
                       CONVERSION_KEY:conversionKey]);

        XCTAssertTrue(tuneHandler.initialized);
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

        XCTAssertFalse(tuneHandler.initialized);
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

    func testTagEvent_simple() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT,
                       EVENT_NAME:userName]);

        XCTAssertEqual(tuneHandler.tagEventCount, 1);
        XCTAssertEqual(tuneHandler.tagEventFailureCount, 0);
        XCTAssertEqual(tuneHandler.lastTagEventName, userName);
        XCTAssertEqual(tuneHandler.lastParamCount, 0);
        XCTAssertTrue(tuneHandler.eventHasBeenSent);
    }

    func testTagEvent_failOnMissingParam() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT]);

        XCTAssertEqual(tuneHandler.tagEventCount, 1);
        XCTAssertEqual(tuneHandler.tagEventFailureCount, 1);
        XCTAssertEqual(tuneHandler.lastTagEventName, nil);
        XCTAssertEqual(tuneHandler.lastParamCount, 0);
        XCTAssertFalse(tuneHandler.eventHasBeenSent);
    }

    func testTagEvent_withWrongParams() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT,
                       EVENT_NAME:userName,
                       "anotherParam":"param1",
                       "anotherAgain":"paramN",
                       "lastParameter":"lastOne"]);

        XCTAssertEqual(tuneHandler.tagEventCount, 1);
        XCTAssertEqual(tuneHandler.tagEventFailureCount, 0);
        XCTAssertEqual(tuneHandler.lastTagEventName, userName);
        XCTAssertEqual(tuneHandler.lastParamCount, 3);
        XCTAssertEqual(tuneHandler.unknownKeysCount, 3);
        XCTAssertTrue(tuneHandler.eventHasBeenSent);
    }

    func testTagEvent_withExpectedStringParams() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT,
                       EVENT_NAME:userName,
                       EVENT_CURRENCY_CODE:"USD",
                       EVENT_REF_ID:"1234567890",
                       EVENT_CONTENT_ID:"9876543210",
                       EVENT_CONTENT_TYPE:"pas content",
                       EVENT_SEARCH_STRING:"random search from google",
                       EVENT_ATT1:"lkjhdz",
                       EVENT_ATT2:"fdlmkgjfdmgl",
                       EVENT_ATT3:"dfmlkhje foez",
                       EVENT_ATT4:"erlkfjezpofjezf",
                       EVENT_ATT5:"é!çudp oé"]);

        XCTAssertEqual(tuneHandler.tagEventCount, 1);
        XCTAssertEqual(tuneHandler.tagEventFailureCount, 0);
        XCTAssertEqual(tuneHandler.lastTagEventName, userName);
        XCTAssertEqual(tuneHandler.lastParamCount, 10);
        XCTAssertEqual(tuneHandler.unknownKeysCount, 0);
        XCTAssertEqual(tuneHandler.buildEventStringPropertiesCount, 10);
        XCTAssertEqual(tuneHandler.buildEventMixedPropertiesCount, 1);
        XCTAssertEqual(tuneHandler.lastRating, nil);
        XCTAssertEqual(tuneHandler.lastDate1, nil);
        XCTAssertEqual(tuneHandler.lastDate2, nil);
        XCTAssertEqual(tuneHandler.lastRevenue, nil);
        XCTAssertEqual(tuneHandler.lastItems, nil);
        XCTAssertEqual(tuneHandler.lastLevel, nil);
        XCTAssertEqual(tuneHandler.lastTransactionState, nil);
        XCTAssertEqual(tuneHandler.lastReceipt, nil);
        XCTAssertEqual(tuneHandler.lastQuantity, nil);
        XCTAssertTrue(tuneHandler.eventHasBeenSent);
    }

    func testTagEvent_withExpectedMixedParams() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT,
                       EVENT_NAME:userName,
                       EVENT_RATING:"3.5",
                       EVENT_REVENUE:"55.42",
                       EVENT_ITEMS:false,
                       EVENT_LEVEL:"38",
                       EVENT_TRANSACTION_STATE:"2",
                       EVENT_QUANTITY:"10"]);

        XCTAssertEqual(tuneHandler.tagEventCount, 1);
        XCTAssertEqual(tuneHandler.tagEventFailureCount, 0);
        XCTAssertEqual(tuneHandler.lastTagEventName, userName);
        XCTAssertEqual(tuneHandler.lastParamCount, 6);
        XCTAssertEqual(tuneHandler.unknownKeysCount, 0);
        XCTAssertEqual(tuneHandler.buildEventStringPropertiesCount, 0);
        XCTAssertEqual(tuneHandler.buildEventMixedPropertiesCount, 1);
        XCTAssertEqual(tuneHandler.lastRating, 3.5);
        XCTAssertEqual(tuneHandler.lastRevenue, 55.42);
        XCTAssertEqual(tuneHandler.lastItems, false);
        XCTAssertEqual(tuneHandler.lastLevel, 38);
        XCTAssertEqual(tuneHandler.lastTransactionState, 2);
        XCTAssertEqual(tuneHandler.lastQuantity, 10);
        XCTAssertTrue(tuneHandler.eventHasBeenSent);
    }

    func testTagEvent_withItems() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        let xbox = CargoItem.init(name: "xBox One", unitPrice: 149.99, quantity: 1);
        let playstation = CargoItem.init(name: "Playstation 4", unitPrice: 240.75, quantity: 2);
        playstation.attribute1 = "Collector";
        playstation.attribute2 = "Multiplayer";
        playstation.attribute3 = "Free game";
        playstation.attribute4 = "Extra controller";
        playstation.attribute5 = "";
        CargoItem.attachItemToEvent(item: xbox);
        CargoItem.attachItemToEvent(item: playstation);
        tuneHandler.initialized = true;

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT,
                       EVENT_NAME:userName,
                       EVENT_ITEMS:true]);

        XCTAssertEqual(tuneHandler.lastTuneItemArray?.count, 2);
        XCTAssertEqual(tuneHandler.getItemsSuccessCount, 1);

        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].item, "xBox One");
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].unitPrice, 149.99);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].quantity, 1);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].revenue, 149.99);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].attribute1, nil);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].attribute2, nil);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].attribute3, nil);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].attribute4, nil);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[0].attribute5, nil);

        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].item, "Playstation 4");
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].unitPrice, 240.75);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].quantity, 2);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].revenue, 481.50);
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].attribute1, "Collector");
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].attribute2, "Multiplayer");
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].attribute3, "Free game");
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].attribute4, "Extra controller");
        XCTAssertEqual(tuneHandler.lastTuneItemArray?[1].attribute5, "");
    }

    func testTagEvent_failWithoutItems() {
        let cargo = Cargo.getInstance();
        let tuneHandler = CARTuneMock();
        tuneHandler.initialized = true;
        CargoItem.notifyTagFired();

        cargo.execute([HANDLER_METHOD:TUN_TAG_EVENT,
                       EVENT_NAME:userName,
                       EVENT_ITEMS:true]);

        XCTAssertEqual(tuneHandler.lastTuneItemArray?.count, nil);
        XCTAssertEqual(tuneHandler.getItemsErroredCount, 1);
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
        XCTAssertEqual(tuneHandler.lastTuneGender, CARTuneMock.GenderMock.male);

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_GENDER:"lkfhsdf"]);
        XCTAssertEqual(tuneHandler.setGengerCount, 2);
        XCTAssertEqual(tuneHandler.lastTuneGender, CARTuneMock.GenderMock.unknown);

        cargo.execute([HANDLER_METHOD:TUN_IDENTIFY,
                       USER_GENDER:"Female"]);
        XCTAssertEqual(tuneHandler.setGengerCount, 3);
        XCTAssertEqual(tuneHandler.lastTuneGender, CARTuneMock.GenderMock.female);
    }

}
