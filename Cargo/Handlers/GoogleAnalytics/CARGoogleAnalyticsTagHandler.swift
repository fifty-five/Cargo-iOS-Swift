//
//  CARGoogleAnalyticsTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


/// The class which handles interactions with the Google Analytics SDK.
class CARGoogleAnalyticsTagHandler: CARTagHandler {

/* ************************************ Variables declaration *********************************** */
    
    /** Google analytics instance */
    var instance: GAI!;
    /** The tracker of the Google Analytics SDK which send the events */
    var tracker: GAITracker!;

    /** Constants used to define callbacks in the register and in the execute method */
    let GA_init = "GA_init";
    let GA_set = "GA_set";
    let GA_setUserId = "GA_setUserId";
    let GA_tagScreen = "GA_tagScreen";
    let GA_tagEvent = "GA_tagEvent";


/* ************************************ Handler core methods ************************************ */

    /// Called to instantiate the handler with its key and name properties.
    /// Also set up the GA instance and tracker attributes.
    /// Register the callbacks to the container. After a dataLayer.push(),
    /// these will trigger the execute method of this handler.
    init() {
        super.init(key: "GA", name: "Google Analytics");
        self.GA_configuration();
        self.instance = GAI.sharedInstance();
        self.tracker = self.instance.defaultTracker;

        cargo.registerTagHandler(self, key: GA_init);
        cargo.registerTagHandler(self, key: GA_set);
        cargo.registerTagHandler(self, key: GA_setUserId);
        cargo.registerTagHandler(self, key: GA_tagScreen);
        cargo.registerTagHandler(self, key: GA_tagEvent);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);
        
        if (tagName == GA_init) {
            self.initialize(parameters);
            return ;
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case GA_set:
                    self.set(parameters);
                    break ;
                case GA_setUserId:
                    self.setUserId(parameters);
                    break ;
                case GA_tagEvent:
                    self.tagEvent(parameters);
                    break ;
                case GA_tagScreen:
                    self.tagScreen(parameters);
                    break ;
                default:
                    noTagMatch(self, tagName: tagName);
            }
        }
        else {
            cargo.logger.logUninitializedFramework(self);
        }
    }

    /// Mandatory to use GA, configures the tracker from the plist file
    func GA_configuration(){
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?;
        GGLContext.sharedInstance().configureWithError(&configureError);
        assert(configureError == nil, "Error configuring Google services: \(configureError)");
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance();
        gai?.trackUncaughtExceptions = true;  // report uncaught exceptions
        // the log level of GA is decided from the log level of the Cargo logger
        switch (cargo.logger.level) {
        case kTAGLoggerLogLevelNone:
            gai?.logger.logLevel = GAILogLevel.none;
            break ;
        case kTAGLoggerLogLevelInfo:
            gai?.logger.logLevel = GAILogLevel.info;
            break ;
        case kTAGLoggerLogLevelWarning:
            gai?.logger.logLevel = GAILogLevel.warning;
            break ;
        case kTAGLoggerLogLevelDebug:
            gai?.logger.logLevel = GAILogLevel.warning;
            break ;
        case kTAGLoggerLogLevelVerbose:
            gai?.logger.logLevel = GAILogLevel.verbose;
            break ;
        default:
            gai?.logger.logLevel = GAILogLevel.error;
        }
    }

/* ************************************ SDK initialization ************************************** */

    /// The method you need to call first. Allow you to initialize Google Analytics SDK
    /// Register the trackingId to the Google Analytics SDK.
    ///
    /// - Parameters:
    ///   - trackingId: your Universal Analytics ID
    func initialize(_ parameters: [AnyHashable: Any]) {
        if let trackingId = parameters["trackingId"] {
            self.tracker = self.instance.tracker(withTrackingId: trackingId as! String);
            // the SDK is now initialized
            self.initialized = true;
            cargo.logger.logParamSetWithSuccess("trackingId", value: trackingId, handler: self);
        }
        else {
            cargo.logger.logMissingParam("trackingId", methodName: "GA_init", handler: self);
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Called to set optional parameters
    ///
    /// - Parameters:
    ///   - trackUncaughtExceptions: boolean set to true by default
    ///   - allowIdfaCollection: boolean set to true by default
    ///   - dispatchInterval: Double set to 30 by default. Time interval before sending pending hits
    func set(_ parameters: [AnyHashable: Any]) {
        var trackException = true;
        var idfaCollection = true;
        var dispInterval: Double = 30;

        // overriding the value for parameter "trackUnCaughtException" and log its new value
        if let trackUnCaughtException = parameters["trackUncaughtExceptions"] as? Bool {
            self.instance.trackUncaughtExceptions = trackUnCaughtException;
            trackException = trackUnCaughtException;
        }
        else {
            self.instance.trackUncaughtExceptions = trackException;
        }
        cargo.logger.logParamSetWithSuccess("trackUncaughtExceptions",
                                            value: trackException, handler: self);

        // overriding the value for parameter "allowIdfaCollection" and log its new value
        if let allowIdfaCollection = parameters["allowIdfaCollection"] as? Bool {
            self.tracker.allowIDFACollection = allowIdfaCollection;
            idfaCollection = allowIdfaCollection;
        }
        else {
            self.tracker.allowIDFACollection = idfaCollection;
        }
        cargo.logger.logParamSetWithSuccess("allowIdfaCollection",
                                            value: idfaCollection, handler: self);

        // overriding the value for parameter "dispatchInterval" and log its new value
        if let dispatchInterval = parameters["dispatchInterval"] as? TimeInterval {
            self.instance.dispatchInterval = dispatchInterval;
            dispInterval = dispatchInterval;
        }
        else {
            self.instance.dispatchInterval = dispInterval;
        }
        cargo.logger.logParamSetWithSuccess("dispatchInterval",
                                            value: dispInterval, handler: self);
    }

    /// Used to setup the userId when the user logs in
    ///
    /// - Parameters:
    ///   - userId: the google user id
    func setUserId(_ parameters: [AnyHashable: Any]){

        if let userID = parameters[USER_ID] {
            self.tracker.set(kGAIUserId, value: userID as! String);
        }
        else {
            cargo.logger.logMissingParam(USER_ID, methodName: "GA_setUserId", handler: self);
        }
    }

    /// Used to build and send a screen event to Google Analytics.
    /// Requires a screenName parameter.
    ///
    /// - Parameters:
    ///   - screenName: the name of the screen you want to be reported
    func tagScreen(_ parameters: [AnyHashable: Any]) {

        if let screenName = parameters[SCREEN_NAME] {
            // setup the screen name
            self.tracker.set(kGAIScreenName, value: screenName as! String);
            // build the event
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build();
            // send the screen event
            self.tracker.send(builder as! [NSObject : AnyObject]);
        }
        else {
            cargo.logger.logMissingParam(SCREEN_NAME, methodName: "GA_tagScreen", handler: self);
        }
    }
    
    /// Method used to create and fire an event to the Google Analytics interface
    /// The mandatory parameters are eventCategory and eventAction.
    /// eventLabel and eventValue are optional.
    ///
    /// - Parameters:
    ///   - eventCategory: the category the event belongs to
    ///   - eventAction: the type of event
    ///   - eventLabel: a label for this event
    ///   - eventValue: a value as NSNumber for this event
    func tagEvent(_ parameters: [AnyHashable: Any]) {
        if let category = parameters["eventCategory"], let action = parameters["eventAction"] {
            let label = parameters["eventLabel"];
            let value = parameters["eventValue"];

            let builder: NSObject = GAIDictionaryBuilder.createEvent(withCategory: category as! String,
                                                                     action: action as! String,
                                                                     label: label as? String,
                                                                     value: value as? NSNumber).build();
            self.tracker.send(builder as! [NSObject : AnyObject]);
        }
        else if (parameters["eventCategory"] == nil) {
            cargo.logger.logMissingParam("eventCategory", methodName: "GA_tagEvent", handler: self);
        }
        else {
            cargo.logger.logMissingParam("eventAction", methodName: "GA_tagEvent", handler: self);
        }
    }

}
