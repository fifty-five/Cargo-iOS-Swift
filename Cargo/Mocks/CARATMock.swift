//
//  CARATMock.swift
//  Cargo
//
//  Created by Julien Gil on 31/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import Foundation
import Tracker

class CARATMock: CARATInternetTagHandler {

    var lastDebugValue = false;

    override init() {
        super.init();
        if (self.logger.level.rawValue <= CARLogger.LogLevelType.debug.rawValue) {
            lastDebugValue = true;
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

        if (tagName == AT_INIT) {
            executeInitCount += 1;
        }
        else if (initialized == true) {
            executeSwitchCount += 1;
            switch (tagName) {
            case AT_SET_CONFIG:
                break ;
            case AT_TAG_SCREEN:
                break ;
            case AT_TAG_EVENT:
                break ;
            case AT_IDENTIFY:
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

    var initializeCount = 0;
    var lastLog: String?;
    var lastLogSSL: String?;
    var lastSiteId:Int?;

    override func initialize(_ parameters: [AnyHashable: Any]) {
        super.initialize(parameters);
        initializeCount += 1;
        if let site = parameters[SITE], let log = parameters[LOG], let logSSL = parameters[LOG_SSL]{
            lastLog = log as? String;
            lastLogSSL = logSSL as? String;
            lastSiteId = Int((site as? String)!);
            self.initialized = true;
        }
    }


/* ********************************************************************************************** */

    var setConfigCount = 0;
    var lastCountOfParams = 0;
    var lastOverrideValue = false;

    override func setConfig(parameters: [AnyHashable: Any]) {
        super.setConfig(parameters: parameters);
        var params = parameters;
        setConfigCount += 1;

        if let tempOverride = params[OVERRIDE] {
            lastOverrideValue = tempOverride as! Bool;
            params.removeValue(forKey: OVERRIDE);
            lastCountOfParams = params.count;
        }
    }


/* ********************************************************************************************** */

    var tagScreenCount = 0;
    var tagScreenFailedCount = 0;
    var lastScreenName:String?

    override func tagScreen(parameters: [AnyHashable: Any]) {
        super.tagScreen(parameters: [:]);
        tagScreenCount += 1;
        if let screenName = parameters[SCREEN_NAME] {
            lastScreenName = screenName as? String;
        }
        else {
            tagScreenFailedCount += 1;
        }
    }


/* ********************************************************************************************** */

    var tagEventCount = 0;
    var tagEventFailedCount = 0;
    var lastEventType:String?;

    override func tagEvent(parameters: [AnyHashable: Any]) {
        super.tagEvent(parameters: [:]);
        tagEventCount += 1;
        if let _ = parameters[EVENT_NAME], let eventType = parameters[EVENT_TYPE] {
            switch eventType as! String {
            case "sendTouch", "sendNavigation", "sendDownload", "sendExit", "sendSearch":
                lastEventType = eventType as? String;
                break;
            default:
                tagEventFailedCount += 1;
            }
        }
        else {
            tagEventFailedCount += 1;
        }
    }


/* ********************************************************************************************** */

    var identifyCount = 0;
    var identifyErroredCount = 0;
    var lastUserId:String?;

    override func identify(parameters: [AnyHashable: Any]) {
        super.identify(parameters: parameters);
        identifyCount += 1;
        if let userId = parameters[USER_ID] {
            lastUserId = userId as? String;
        }
        else {
            identifyErroredCount += 1;
        }
    }

}
