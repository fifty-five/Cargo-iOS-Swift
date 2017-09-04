//
//  CARTuneMock.swift
//  Cargo
//
//  Created by Julien Gil on 30/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import Foundation
import Tune

class CARTuneMock: CARTuneTagHandler {

    static let GenderMock = TuneGender.self;

    var constructorCount = 0;
    var constructorDebugLastArg: Bool?;

    override init() {
        super.init();
        if (self.logger.level.rawValue <= CARLogger.LogLevelType.debug.rawValue) {
            constructorCount += 1;
            constructorDebugLastArg = true;
        }
        else {
            constructorCount += 1;
            constructorDebugLastArg = false;
        }
    }

/* ********************************************************************************************** */

    var initializeCount = 0;
    var initializeValidCount = 0;
    var lastAdvertiserId:String?;
    var lastConversionKey:String?;

    override func initialize(_ parameters: [AnyHashable: Any]) {
        super.initialize(parameters);
        initializeCount += 1;
        if let advertiserId = parameters[ADVERTISER_ID],
            let conversionKey = parameters[CONVERSION_KEY] {
            initializeValidCount += 1;
            lastAdvertiserId = advertiserId as? String;
            lastConversionKey = conversionKey as? String;
        }
    }


/* ********************************************************************************************** */

    var executeCount = 0;
    var executeInitCount = 0;
    var executeSwitchCount = 0;
    var executeUnknownFunctionCount = 0;
    var executeUninitializedCount = 0;

    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);
        executeCount += 1;

        if (tagName == TUN_INIT) {
            executeInitCount += 1;
        }
        else if (self.initialized) {
            executeSwitchCount += 1;
            switch (tagName) {
            case TUN_SESSION:
                break ;
            case TUN_IDENTIFY:
                break ;
            case TUN_TAG_EVENT:
                break ;
            default:
                executeUnknownFunctionCount += 1;
            }
        }
        else {
            executeUninitializedCount += 1;
        }
    }


/* ********************************************************************************************** */

    var measureSessionCount = 0;

    override func measureSession() {
        super.measureSession();
        measureSessionCount += 1;
    }


/* ********************************************************************************************** */

    var tagEventCount = 0;
    var tagEventFailureCount = 0;
    var lastTagEventName: String?;
    var lastParamCount = 0;
    var eventHasBeenSent = false;

    override func tagEvent(_ parameters: [AnyHashable: Any]) {
        var params = parameters;
        var tuneEvent: TuneEvent!;
        super.tagEvent(parameters);
        tagEventCount += 1;

        if let eventName = params[EVENT_NAME] {
            tuneEvent = TuneEvent.init(name: eventName as! String);
            params.removeValue(forKey: EVENT_NAME);
            lastTagEventName = eventName as? String;
        }
        else {
            tagEventFailureCount += 1;
            return ;
        }
        if (params.count > 0 && (tuneEvent) != nil) {
            lastParamCount = params.count;
        }
        if (tuneEvent != nil) {
            eventHasBeenSent = true;
        }
        else {
            tagEventFailureCount += 1;
        }
    }


/* ********************************************************************************************** */

    var buildEventCount = 0;
    var buildEventStringPropertiesCount = 0;
    var unknownKeysCount = 0;

    override func buildEvent(_ event: TuneEvent, parameters: [AnyHashable: Any]) -> TuneEvent {
        var params = parameters;

        _ = super.buildEvent(event, parameters: parameters);
        for key: String in EVENT_MIXED_PROPERTIES {
            params.removeValue(forKey: key);
        }
        for property: String in EVENT_STRING_PROPERTIES {
            if params[property] != nil {
                buildEventStringPropertiesCount += 1;
                params.removeValue(forKey: property);
            }
        }
        for (_, _) in params {
            unknownKeysCount += 1;
        }
        return event;
    }


/* ********************************************************************************************** */

    var buildEventMixedPropertiesCount = 0;
    var lastRating: CGFloat?;
    var lastDate1: Date?;
    var lastDate2: Date?;
    var lastRevenue: CGFloat?;
    var lastItems: Bool?;
    var lastLevel: Int?;
    var lastTransactionState: Int?;
    var lastReceipt: Data?;
    var lastQuantity: UInt?;

    override func setMixedPropertiesToEvent(tuneEvent: TuneEvent, params:[AnyHashable: Any]) -> (TuneEvent) {
        _ = super.setMixedPropertiesToEvent(tuneEvent: tuneEvent, params: params);
        buildEventMixedPropertiesCount += 1;
        if let eventRating = params[EVENT_RATING] {
            if let tempRating = eventRating as? String {
                let doubleRating: Double = Double(tempRating)!;
                lastRating = CGFloat(doubleRating);
            }
        }
        if let eventDate1 = params[EVENT_DATE1] {
            let date1 = NSDate(timeIntervalSince1970: Double(eventDate1 as! String)!);
            lastDate1 = date1 as Date;

            if let eventDate2 = params[EVENT_DATE2] {
                let date2 = NSDate(timeIntervalSince1970: Double(eventDate2 as! String)!);
                lastDate2 = date2 as Date;
            }
        }
        if let eventRevenue = params[EVENT_REVENUE] {
            if let tempRevenue = eventRevenue as? String {
                let doubleRevenue: Double = Double(tempRevenue)!;
                lastRevenue = CGFloat(doubleRevenue);
            }
        }
        if let eventItems = params[EVENT_ITEMS] {
            lastItems = eventItems as? Bool;
        }
        if let eventLevel = params[EVENT_LEVEL] {
            lastLevel = Int(eventLevel as! String)!;
        }
        if let eventTransaction = params[EVENT_TRANSACTION_STATE] {
            lastTransactionState = Int(eventTransaction as! String)!;
        }
        if let eventReceipt = params[EVENT_RECEIPT] {
            if let data = (eventReceipt as! String).data(using: .utf8) {
                lastReceipt = data;
            }
        }
        if let eventQuantity = params[EVENT_QUANTITY] {
            let qty = Int(eventQuantity as! String)!;
            if (qty >= 0) {
                lastQuantity = UInt(qty);
            }
        }
        return tuneEvent;
    }

/* ********************************************************************************************** */

    var identifyCount = 0;
    var lastUserId:String?;
    var lastFacebookId:String?;
    var lastGoogleId:String?;
    var lastTwitterId:String?;
    var lastUserName:String?;
    var lastUserAge:String?;
    var lastUserMail:String?;
    var lastUserGender:String?;

    override func identify(_ parameters: [AnyHashable: Any]) {
        super.identify(parameters);
        identifyCount += 1;

        if let userId = parameters[USER_ID] {
            lastUserId = userId as? String;
        }
        if let userFacebookId = parameters[USER_FACEBOOK_ID] {
            lastFacebookId = userFacebookId as? String;
        }
        if let userGoogleId = parameters[USER_GOOGLE_ID] {
            lastGoogleId = userGoogleId as? String;
        }
        if let userTwitterId = parameters[USER_TWITTER_ID] {
            lastTwitterId = userTwitterId as? String;
        }
        if let userName = parameters[USER_NAME] {
            lastUserName = userName as? String;
        }
        if let userAge = parameters[USER_AGE] {
            lastUserAge = userAge as? String;
        }
        if let userEmail = parameters[USER_EMAIL] {
            lastUserMail = userEmail as? String;
        }
        if let userGender = parameters[USER_GENDER] {
            lastUserGender = userGender as? String;
        }
    }


/* ********************************************************************************************** */

    var setGengerCount = 0;
    var lastTuneGender:TuneGender?;

    override func setGender(_ gender: String) {
        super.setGender(gender);
        setGengerCount += 1;

        let upperGender = gender.uppercased();
        if (upperGender == "MALE") {
            lastTuneGender = TuneGender.male;
        }
        else if (upperGender == "FEMALE") {
            lastTuneGender = TuneGender.female;
        }
        else {
            lastTuneGender = TuneGender.unknown;
        }
    }


/* ********************************************************************************************** */

    var lastTuneItemArray: [TuneEventItem]?;
    var getItemsSuccessCount = 0;
    var getItemsErroredCount = 0;

    override func getItems() -> ([TuneEventItem]!) {
        lastTuneItemArray = super.getItems();

        if (CargoItem.getItemsArray() != nil && CargoItem.getItemsArray()?.count != 0) {
                getItemsSuccessCount += 1;
        }
        else {
            getItemsErroredCount += 1;
        }
        return nil;
    }

}
