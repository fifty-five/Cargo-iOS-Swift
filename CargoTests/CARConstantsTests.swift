//
//  CARConstantsTests.swift
//  Cargo
//
//  Created by Julien Gil on 03/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import XCTest
@testable import Cargo

class CARConstantsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTracker() {
        XCTAssertEqual(APPLICATION_ID, "applicationId");
        XCTAssertEqual(ENABLE_DEBUG, "enableDebug");
        XCTAssertEqual(ENABLE_OPTOUT, "enableOptOut");
        XCTAssertEqual(DISABLE_TRACKING, "disableTracking");
        XCTAssertEqual(DISPATCH_INTERVAL, "dispatchInterval");
        XCTAssertEqual(LEVEL2, "level2");
        XCTAssertEqual(CUSTOM_DIM1, "customDim1");
        XCTAssertEqual(CUSTOM_DIM2, "customDim2");
    }
    
    func testScreen() {
        XCTAssertEqual(SCREEN_NAME, "screenName");
    }
    
    func testEvent() {
        XCTAssertEqual(EVENT_NAME, "eventName");
        XCTAssertEqual(EVENT_ID, "eventId");
        XCTAssertEqual(EVENT_VALUE, "eventValue");
        XCTAssertEqual(EVENT_TYPE, "eventType");
    }
    
    func testUser() {
        XCTAssertEqual(USER_ID, "userId");
        XCTAssertEqual(USER_AGE, "userAge");
        XCTAssertEqual(USER_EMAIL, "userEmail");
        XCTAssertEqual(USER_NAME, "userName");
        XCTAssertEqual(USER_GENDER, "userGender");
        XCTAssertEqual(USER_GOOGLE_ID, "userGoogleId");
        XCTAssertEqual(USER_TWITTER_ID, "userTwitterId");
        XCTAssertEqual(USER_FACEBOOK_ID, "userFacebookId");
    }
    
    func testTransaction() {
        XCTAssertEqual(TRANSACTION_ID, "transactionId");
        XCTAssertEqual(TRANSACTION_TOTAL, "transactionTotal");
        XCTAssertEqual(TRANSACTION_CURRENCY_CODE, "transactionCurrencyCode");
        XCTAssertEqual(TRANSACTION_PRODUCTS, "transactionProducts");
        XCTAssertEqual(TRANSACTION_PRODUCT_NAME, "name");
        XCTAssertEqual(TRANSACTION_PRODUCT_SKU, "sku");
        XCTAssertEqual(TRANSACTION_PRODUCT_PRICE, "price");
        XCTAssertEqual(TRANSACTION_PRODUCT_CATEGORY, "category");
        XCTAssertEqual(TRANSACTION_PRODUCT_QUANTITY, "quantity");
    }
    
}
