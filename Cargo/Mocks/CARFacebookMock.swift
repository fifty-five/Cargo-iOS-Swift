//
//  CARFacebookMock.swift
//  Cargo
//
//  Created by Julien Gil on 31/08/2017.
//  Copyright © 2017 François K. All rights reserved.
//

import Foundation
import FacebookCore

class CARFacebookMock: CARFacebookTagHandler {

    override init() {
        super.init();
    }


/* ********************************************************************************************** */

    var executeCount = 0;
    var executeInitCount = 0;
    var executeSwitchCount = 0;
    var executeUnknownFunctionCount = 0;
    var executeUninitializedCount = 0;

    override func execute(_ tagName: String, parameters: [AnyHashable: Any]){
        super.execute(tagName, parameters: parameters);
        executeCount += 1;

        if (tagName == FB_INIT) {
            executeInitCount += 1;
        }
        else if (self.initialized) {
            executeSwitchCount += 1;
            switch (tagName) {
            case FB_ACTIVATE_APP:
                break ;
            case FB_TAG_EVENT:
                break ;
            case FB_TAG_PURCHASE:
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
    var initializeValidCount = 0;
    var lastApplicationId:String?;
    var lastDebugValue:Bool?;

    override func initialize(parameters: [AnyHashable: Any]){
        super.initialize(parameters: parameters);
        initializeCount += 1;

        if let applicationId = parameters[APPLICATION_ID]{
            initializeValidCount += 1;
            lastApplicationId = applicationId as? String;
            lastDebugValue = false;

            if (debug) {
                lastDebugValue = debug;
            }
        }
    }

    var activateAppCount = 0;

    override func activateApp() {
        super.activateApp();
        activateAppCount += 1;
    }


/* ********************************************************************************************** */

    var tagEventCount = 0;
    var tagEventErrored = false;
    var lastTagEventName: String?;
    var lastValueToSum: Double?;
    var lastCountOfParams = 0;

    override func tagEvent(parameters: [AnyHashable: Any]){
        super.tagEvent(parameters: parameters);
        var params = parameters;
        let VALUE_TO_SUM = "valueToSum";
        tagEventCount += 1;

        if let eventName = params[EVENT_NAME] {
            lastTagEventName = eventName as? String;
            params.removeValue(forKey: EVENT_NAME);

            if let valueToSum = params[VALUE_TO_SUM]{
                lastValueToSum = valueToSum as? Double;
                params.removeValue(forKey: VALUE_TO_SUM);
                if(params.count > 0){
                    lastCountOfParams = params.count;
                }
            }
            else{
                if(params.count > 0){
                    lastCountOfParams = params.count;
                }
            }
        }
        else {
            tagEventErrored = true;
        }
    }


/* ********************************************************************************************** */

    var purchaseCount = 0;
    var lastAmount: Double?;
    var lastCurrencyCode: String?;
    var purchaseErrored = false;

    override func purchase(parameters: [AnyHashable: Any]){
        super.purchase(parameters: parameters);
        purchaseCount += 1;
        if let purchaseAmount = parameters[TRANSACTION_TOTAL] as? Double {
            if let currencyCode = parameters[TRANSACTION_CURRENCY_CODE] as? String {
                lastCurrencyCode = currencyCode;
                lastAmount = purchaseAmount;
            }
            else {
                purchaseErrored = true;
            }
        }
        else {
            purchaseErrored = true;
        }
    }

}
