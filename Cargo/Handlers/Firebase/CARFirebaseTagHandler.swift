//
//  CARFirebaseTagHandler.swift
//  Cargo
//
//  Created by François Khoury on 31/08/2016.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation
import Firebase

/// The class which handles interactions with the Firebase SDK.
class CARFirebaseTagHandler: CARTagHandler {

/* *********************************** Variables Declaration ************************************ */

    /** The tracker of the Firebase SDK which send the events */
    var FirebaseAnalyticsClass: FIRAnalytics!;
    /** The instance of Firebase which is used to setup the configuration */
    var FirebaseAnalyticsConf: FIRAnalyticsConfiguration!;

    /** Constants used to define callbacks in the register and in the execute method */
    let FIR_INIT = "FIR_init";
    let FIR_IDENTIFY = "FIR_identify";
    let FIR_TAG_EVENT = "FIR_tagEvent";

    let ENABLE_COLLECTION = "enableCollection";


/* ********************************** Handler core methods ************************************** */

    /// Called to instantiate the handler with its key and name properties.
    /// Also set up the Firebase instance and tracker attributes.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
        super.init(key: "FIR", name: "Firebase");

        self.FirebaseAnalyticsClass = FIRAnalytics();
        self.FirebaseAnalyticsConf = FIRAnalyticsConfiguration();
        FIRApp.configure();

        cargo.registerTagHandler(self, key: FIR_INIT);
        cargo.registerTagHandler(self, key: FIR_IDENTIFY);
        cargo.registerTagHandler(self, key: FIR_TAG_EVENT);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        switch (tagName) {
            case FIR_INIT:
                self.initialize(parameters);
                break ;
            case FIR_IDENTIFY:
                self.identify(parameters);
                break ;
            case FIR_TAG_EVENT:
                self.tagEvent(parameters);
                break ;
            default:
                logger.logUnknownFunctionTag(tagName);
        }
    }


/* ************************************ SDK initialization ************************************** */

    /// The method you may call first if you want to disable the Firebase analytics collection
    /// This setting is persisted across app sessions. By default it is enabled.
    ///
    /// - Parameters:
    ///   - enableCollection: a boolean true/false for collection enabled/disabled
    func initialize(_ parameters: [AnyHashable: Any]) {
        if let enabled = parameters[ENABLE_COLLECTION] {
            FirebaseAnalyticsConf.setAnalyticsCollectionEnabled(enabled as! Bool);
            logger.logParamSetWithSuccess(ENABLE_COLLECTION, value: enabled as! Bool);
            if (enabled as! Bool == false) {
                logger.carLog(kTAGLoggerLogLevelWarning,
                              message: "The analytics collection has been disabled, " +
                    "you won't be able to send anything to the Firebase console. " +
                    "Call on the \(FIR_INIT) method with the \(ENABLE_COLLECTION) " +
                    "parameter set to true to enable the collection again.");
            }
        }
        else{
            logger.logMissingParam(ENABLE_COLLECTION, methodName: FIR_INIT);
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Used to identify a unique user with an unique ID, defines the segments the user belongs to
    ///
    /// - Parameters:
    ///   - userId: unique ID used to identify an unique user
    ///   - parameters: additional properties you may set to your user
    func identify(_ parameters: [AnyHashable: Any]){
        var params = parameters;

        if let userID = params[USER_ID] {
            FIRAnalytics.setUserID(userID as? String);
            logger.logParamSetWithSuccess(USER_ID, value: userID as! String);
            params.removeValue(forKey: USER_ID);
        }
        if (params.count > 0) {
            for (key, value) in params {
                FIRAnalytics.setUserPropertyString(value as? String, forName:key as! String);
                logger.logParamSetWithSuccess(key as! String, value: value as! String);
            }
        }
        else {
            logger.logMissingParam(USER_ID, methodName: FIR_IDENTIFY);
        }
    }

    /// Method used to create and fire an event to the Firebase Console
    /// The mandatory parameters is EVENT_NAME which is a necessity to build the event
    /// Without this parameter, the event won't be built.
    /// After the creation of the event object, some attributes can be added,
    /// using the dictionary obtained from the gtm container.
    ///
    /// For the format to apply to the name and the parameters, check http://tinyurl.com/j7ppm6b
    ///
    /// - Parameters:
    ///   - eventName: the only parameter requested here
    ///   - parameters: additional parameters set to this event
    func tagEvent(_ parameters: [AnyHashable: Any]){
        var params = parameters;

        if let eventName = params[EVENT_NAME] {
            params.removeValue(forKey: EVENT_NAME);
            if (params.count > 0) {
                FIRAnalytics.logEvent(withName: eventName as! String,
                                      parameters: params as? [String : NSObject]);
                logger.logParamSetWithSuccess(EVENT_NAME, value: eventName as! String);
                logger.logParamSetWithSuccess("params", value: params);
            }
            else {
                FIRAnalytics.logEvent(withName: eventName as! String, parameters: nil);
                logger.logParamSetWithSuccess(EVENT_NAME, value: eventName as! String);
                logger.logParamSetWithSuccess("params", value: "nil");
            }
        }
        else{
            logger.logMissingParam(EVENT_NAME, methodName: FIR_TAG_EVENT);
        }
    }

}
