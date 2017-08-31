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
                logger.logUnknownFunctionTag(tagName);
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

}
