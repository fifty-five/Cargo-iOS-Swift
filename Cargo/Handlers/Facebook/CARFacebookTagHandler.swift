//
//  CARFacebookTagHandler.swift
//  Cargo
//
//  Created by François K on 06/09/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

import Foundation
import FacebookCore

/// The class which handles interactions with the Accengage SDK.
class CARFacebookTagHandler: CARTagHandler {

/* *********************************** Variables Declaration ************************************ */

    /** Constants used to define callbacks in the register and in the execute method */
    let FB_initialize = "FB_initialize";
    let FB_activateApp = "FB_activateApp";
    let FB_tagEvent = "FB_tagEvent";
    let FB_purchase = "FB_purchase";


/* ********************************** Handler core methods ************************************** */

    /// Called to instantiate the handler with its key and name properties.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
        super.init(key: "FB", name: "Facebook");
        
        cargo.registerTagHandler(self, key: FB_initialize);
        cargo.registerTagHandler(self, key: FB_activateApp);
        cargo.registerTagHandler(self, key: FB_tagEvent);
        cargo.registerTagHandler(self, key: FB_purchase);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]){
        super.execute(tagName, parameters: parameters);

        if (tagName == FB_initialize) {
            self.initialize(parameters: parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case FB_activateApp:
                    self.activateApp();
                    break ;
                case FB_tagEvent:
                    self.tagEvent(parameters: parameters);
                    break ;
                case FB_purchase:
                    self.purchase(parameters: parameters);
                    break ;
                default:
                    noTagMatch(self, tagName: tagName);
            }
        }
        else {
            cargo.logger.logUninitializedFramework(self);
        }
    }


/* ************************************ SDK initialization ************************************** */

    /// The method you need to call first. Allow you to initialize Facebook SDK
    /// Register the application ID to the Facebook SDK.
    ///
    /// - Parameters:
    ///   - applicationId: the ID facebook gives when you register your app
    func initialize(parameters: [AnyHashable: Any]){
        if let applicationId = parameters["applicationId"]{
            AppEventsLogger.loggingAppId = applicationId as? String;
            self.activateApp();
            self.initialized = true;
            cargo.logger.logParamSetWithSuccess("applicationId", value: applicationId, handler: self);
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Needs to be called on each screen in order to measure sessions
    func activateApp(){
        AppEventsLogger.activate(UIApplication.shared);
        cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: self, message: "Facebook activateApp sent.");
    }

    /// Send an event to facebook SDK. Calls differents methods depending on which parameters have been given
    ///  Each events can be logged with a valueToSum and a set of parameters (up to 25 parameters).
    ///  When reported, all of the valueToSum properties will be summed together. It is an arbitrary number
    ///  that can represent any value (e.g., a price or a quantity).
    ///
    /// - Parameters:
    ///   - eventName: the name of the event, which is mandatory
    ///   - valueToSum: the value to sum
    ///   - parameters: other parameters you would like to link to the event
    func tagEvent(parameters: [AnyHashable: Any]){
        var params = parameters;

        if let eventName = params[EVENT_NAME] {
            params.removeValue(forKey: EVENT_NAME as NSObject);

            if let valueToSum = params["valueToSum"]{
                params.removeValue(forKey: "valueToSum" as NSObject);

                // in case there is an eventName, valueToSum and additional parameters
                if(params.count>0){
                    AppEventsLogger.log(eventName as!String,
                                        parameters: params as! AppEvent.ParametersDictionary,
                                        valueToSum: valueToSum as? Double);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("valueToSum", value: valueToSum, handler: self);
                    cargo.logger.logParamSetWithSuccess("params", value: params, handler: self);
                }
                // in case there is an eventName and a valueToSum
                else{
                    AppEventsLogger.log(eventName as! String, valueToSum: valueToSum as? Double);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("valueToSum", value: valueToSum, handler: self);
                }
            }
            else{
                // in case there is an eventName and additional parameters
                if(params.count>0){
                    AppEventsLogger.log(eventName as! String,
                                        parameters: params as! AppEvent.ParametersDictionary);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                    cargo.logger.logParamSetWithSuccess("params", value: params, handler: self);
                }
                // in case there is just an eventName
                else{
                    AppEventsLogger.log(eventName as! String);
                    cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: eventName, handler: self);
                }
            }
        }
    }

    /// Logs a purchase in your app. with purchaseAmount the money spent, and currencyCode the currency code.
    /// The currency specification is expected to be an ISO 4217 currency code.
    ///
    /// - Parameters:
    ///   - purchaseAmount: the amount of the purchase, which is mandatory
    ///   - currencyCode: the currency of the purchase, which is mandatory
    func purchase(parameters: [AnyHashable: Any]){
        if let purchaseAmount = parameters["purchaseAmount"] as? Double, let currencyCode = parameters["currencyCode"] as? String {
            AppEventsLogger.log(.purchased(amount: purchaseAmount, currency: currencyCode));
            cargo.logger.logParamSetWithSuccess("purchaseAmount", value: purchaseAmount, handler: self);
            cargo.logger.logParamSetWithSuccess("currencyCode", value: currencyCode, handler: self);
        }
        else {
            cargo.logger.logMissingParam("purchaseAmount AND/OR currencyCode", methodName: "purchase", handler: self);
        }
    }
}
