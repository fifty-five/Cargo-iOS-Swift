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
    let GA_INIT = "GA_init";
    let GA_SET = "GA_set";
    let GA_IDENTIFY = "GA_identify";
    let GA_TAG_SREEN = "GA_tagScreen";
    let GA_TAG_EVENT = "GA_tagEvent";

    let TRACKING_ID = "trackingId";
    let TRACK_UNCAUGHT_EXCEPTIONS = "trackUncaughtExceptions";
    let ALLOW_IDFA_COLLECTION = "allowIdfaCollection";
    let DISPATCH_INTERVAL = "dispatchInterval";
    let EVENT_ACTION = "eventAction";
    let EVENT_CATEGORY = "eventCategory";
    let EVENT_LABEL = "eventLabel";
    let EVENT_VALUE = "eventValue";


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

        cargo.registerTagHandler(self, key: GA_INIT);
        cargo.registerTagHandler(self, key: GA_SET);
        cargo.registerTagHandler(self, key: GA_IDENTIFY);
        cargo.registerTagHandler(self, key: GA_TAG_SREEN);
        cargo.registerTagHandler(self, key: GA_TAG_EVENT);
    }

    /// Callback from GTM container designed to execute a specific method
    /// from its tag and the parameters received.
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the aimed method
    ///   - parameters: Dictionary of parameters
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);
        
        if (tagName == GA_INIT) {
            self.initialize(parameters);
        }
        // check whether the SDK has been initialized before calling any method
        else if (self.initialized) {
            switch (tagName) {
                case GA_SET:
                    self.set(parameters);
                    break ;
                case GA_IDENTIFY:
                    self.identify(parameters);
                    break ;
                case GA_TAG_EVENT:
                    self.tagEvent(parameters);
                    break ;
                case GA_TAG_SREEN:
                    self.tagScreen(parameters);
                    break ;
                default:
                    logger.logUnknownFunctionTag(tagName);
            }
        }
        else {
            logger.logUninitializedFramework();
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
        switch (logger.level) {
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
        if let trackingId = parameters[TRACKING_ID] {
            self.tracker = self.instance.tracker(withTrackingId: trackingId as! String);
            // the SDK is now initialized
            self.initialized = true;
            logger.logParamSetWithSuccess(TRACKING_ID, value: trackingId);
        }
        else {
            logger.logMissingParam(TRACKING_ID, methodName: GA_INIT);
        }
    }


/* ****************************************** Tracking ****************************************** */

    /// Called to set optional parameters
    ///
    /// - Parameters:
    ///   - enableOptOut: boolean disabling the tracking in the entire app when set to true
    ///   - disableTracking: When this is set to true, no tracking information will be sent.
    ///   - trackUncaughtExceptions: boolean set to true by default
    ///   - allowIdfaCollection: boolean set to true by default
    ///   - dispatchInterval: Double set to 30 by default. Time interval before sending pending hits
    func set(_ parameters: [AnyHashable: Any]) {
        var optOut = false;
        var dryRun = false;
        var trackException = true;
        var idfaCollection = true;
        var dispInterval: Double = 30;

        // overriding the value for parameter "trackUnCaughtException" and log its new value
        if let tempOptOut = parameters[ENABLE_OPTOUT] as? Bool {
            optOut = tempOptOut;
        }
        self.instance.optOut = optOut;
        logger.logParamSetWithSuccess(ENABLE_OPTOUT, value: optOut);

        // overriding the value for parameter "trackUnCaughtException" and log its new value
        if let tempDryRun = parameters[DISABLE_TRACKING] as? Bool {
            dryRun = tempDryRun;
        }
        self.instance.dryRun = dryRun;
        logger.logParamSetWithSuccess(DISABLE_TRACKING, value: dryRun);

        // overriding the value for parameter "trackUnCaughtException" and log its new value
        if let trackUnCaughtException = parameters[TRACK_UNCAUGHT_EXCEPTIONS] as? Bool {
            trackException = trackUnCaughtException;
        }
        self.instance.trackUncaughtExceptions = trackException;
        logger.logParamSetWithSuccess(TRACK_UNCAUGHT_EXCEPTIONS, value: trackException);

        // overriding the value for parameter "allowIdfaCollection" and log its new value
        if let allowIdfaCollection = parameters[ALLOW_IDFA_COLLECTION] as? Bool {
            idfaCollection = allowIdfaCollection;
        }
        self.tracker.allowIDFACollection = idfaCollection;
        logger.logParamSetWithSuccess(ALLOW_IDFA_COLLECTION, value: idfaCollection);

        // overriding the value for parameter "dispatchInterval" and log its new value
        if let dispatchInterval = parameters[DISPATCH_INTERVAL] as? TimeInterval {
            dispInterval = dispatchInterval;
        }
        self.instance.dispatchInterval = dispInterval;
        logger.logParamSetWithSuccess(DISPATCH_INTERVAL, value: dispInterval);
    }

    /// Used to setup the userId when the user logs in
    ///
    /// - Parameters:
    ///   - userId: the google user id
    func identify(_ parameters: [AnyHashable: Any]){

        if let userID = parameters[USER_ID] {
            self.tracker.set(kGAIUserId, value: userID as! String);
            logger.logParamSetWithSuccess(USER_ID, value: userID)
        }
        else {
            logger.logMissingParam(USER_ID, methodName: GA_IDENTIFY);
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
            logger.logParamSetWithSuccess(SCREEN_NAME, value: screenName);
        }
        else {
            logger.logMissingParam(SCREEN_NAME, methodName: GA_TAG_SREEN);
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
        if let category = parameters[EVENT_CATEGORY], let action = parameters[EVENT_ACTION] {
            let label = parameters[EVENT_LABEL];
            let value = parameters[EVENT_VALUE];

            let builder: NSObject = GAIDictionaryBuilder.createEvent(withCategory: category as! String,
                                                                     action: action as! String,
                                                                     label: label as? String,
                                                                     value: value as? NSNumber).build();
            self.tracker.send(builder as! [NSObject : AnyObject]);
            logger.logParamSetWithSuccess(EVENT_CATEGORY, value: category);
            logger.logParamSetWithSuccess(EVENT_ACTION, value: action);
            if (label != nil) {
                logger.logParamSetWithSuccess(EVENT_LABEL, value: label!);
            }
            if (value != nil) {
                logger.logParamSetWithSuccess(EVENT_VALUE, value: value!);
            }
        }
        else {
            logger.logMissingParam("\([EVENT_ACTION, EVENT_CATEGORY])", methodName: GA_TAG_EVENT);
        }
    }

}
