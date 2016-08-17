//
//  CARGoogleAnalyticsTagHandler.swift
//  Cargo
//
//  Created by Med on 17/08/16.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

class CARGoogleAnalyticsTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */

    var tracker: GAITracker!;
    var instance: GAI!;


    let GA_init = "GA_init";
    let GA_set = "GA_set";

/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "GA", name: "Google Analytics");
        self.instance = GAI.sharedInstance();
        self.tracker = self.instance.defaultTracker;

        cargo.registerTagHandler(self, key: GA_init);
        cargo.registerTagHandler(self, key: GA_set);
    }


/* ******************************** Core handler methods *********************************** */

    /**
     *  Call back from GTM container to execute a specific action
     *  after tag and parameters are received
     *
     *  @param tagName  The tag name
     *  @param parameters   Dictionary of parameters
     */
    override func execute(tagName: String, parameters: [NSObject : AnyObject]) {
        super.execute(tagName, parameters: parameters);

        switch (tagName) {
        case GA_init:
            self.initialize(parameters);
            break ;
        case GA_set:
            self.set(parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }

    /**
     *  Is called to set the tracking ID
     *
     *  @param parameters   Dictionary of parameters which should contain the tracking ID
     */
    func initialize(parameters: [NSObject : AnyObject]) {
        if let trackingId = parameters["trackingId"] {
            self.instance.trackerWithTrackingId(trackingId as! String);
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "tracking ID set as \(trackingId)");
        }
    }

    /**
     *  Called to set optional parameters
     *
     *  @param parameters   Dictionary of parameters
     */
    func set(parameters: [NSObject : AnyObject]) {

        if let trackUnCaughtException = parameters["trackUncaughtExceptions"] {
            self.instance.trackUncaughtExceptions = trackUnCaughtException as! Bool;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "trackUnCaughtException set as \(trackUnCaughtException)");
        }
        if let allowIdfaCollection = parameters["allowIdfaCollection"] {
            self.tracker.allowIDFACollection = allowIdfaCollection as! Bool;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "allowIdfaCollection set as \(allowIdfaCollection)");
        }
        if let dispatchInterval = parameters["dispatchInterval"] {
            self.instance.dispatchInterval = dispatchInterval as! NSTimeInterval;
            cargo.logger.carLog(kTAGLoggerLogLevelVerbose, handler: self, message: "dispatchInterval set as \(dispatchInterval)");
        }
    }

}
