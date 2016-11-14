//
//  CARATInternetTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 06/09/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation
import Tracker

class CARATInternetTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */

    let AT_init = "AT_init";
    let AT_setConfig = "AT_setConfig";
    let AT_tagScreen = "AT_tagScreen";
    let AT_tagEvent = "AT_tagEvent";

    let TRACKER_NAME = "trackerName";
    let OVERRIDE = "override";
    let CHAPTER1 = "chapter1";
    let CHAPTER2 = "chapter2";
    let CHAPTER3 = "chapter3";
    let BASKET = "isBasketView";
    let ACTION = "action";

    var tracker: Tracker;

/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the handler
     */
    init() {
        self.tracker = ATInternet.sharedInstance.defaultTracker;
        super.init(key: "AT", name: "AT Internet");

        cargo.registerTagHandler(self, key: AT_init);
        cargo.registerTagHandler(self, key: AT_setConfig);
        cargo.registerTagHandler(self, key: AT_tagScreen);
        cargo.registerTagHandler(self, key: AT_tagEvent);
    }

/* ******************************** Core handler methods *********************************** */

    /**
     *  Call back from GTM container to execute a specific action
     *  after tag and parameters are received
     *
     *  @param tagName  The tag name
     *  @param parameters   Dictionary of parameters
     */
    override func execute(_ tagName: String, parameters: [AnyHashable: Any]) {
        super.execute(tagName, parameters: parameters);

        if (tagName == AT_init) {
            self.initialize(parameters);
        }
        else if (initialized == true) {
            switch (tagName) {
            case AT_setConfig:
                self.setConfig(parameters: parameters);
                break ;
            case AT_tagScreen:
                self.tagScreen(parameters: parameters);
                break ;
            case AT_tagEvent:
                self.tagEvent(parameters: parameters);
                break ;
            default:
                noTagMatch(self, tagName: tagName);
            }
        }
        else {
            cargo.logger.logUninitializedFramework(self);
        }
    }

    /**
     * The method you have to call first, because it initializes
     * the AT Internet tracker with the parameters you give.
     *
     *  @param parameters   Dictionary of parameters
     */
    func initialize(_ parameters: [AnyHashable: Any]) {
        var params = parameters;

        // we check if the required name is set, and then initialize the tracker with required values
        if let trackerName = params[TRACKER_NAME] {
            params.removeValue(forKey: TRACKER_NAME);
            tracker = ATInternet.sharedInstance.tracker(trackerName as! String,
                                                        configuration:params as! [String : String]);
            cargo.logger.logParamSetWithSuccess(TRACKER_NAME, value: parameters);
        }
        else if let siteId = params["siteId"] {
            tracker.setConfig(TrackerConfigurationKeys.Site, value: siteId as! String,
                              completionHandler: { (isSet) -> Void in
                                self.cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: self,
                                                         message: "AT Internet siteId set to \(siteId)");
            });
            self.initialized = true;
        }
        else {
            cargo.logger.logMissingParam("siteId or \(TRACKER_NAME)", methodName: "initialize", handler: self);
        }
    }

    /**
     * The method you may call if you want to reconfigure your tracker
     *
     *  @param parameters   Dictionary of parameters
     */
    func setConfig(parameters: [AnyHashable: Any]) {
        var params = parameters;

        if let override = params[OVERRIDE] {
            params.removeValue(forKey: OVERRIDE);

            tracker.setConfig(params as! [String : String], override: override as! Bool) { (isSet) -> Void in
                self.cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: self,
                                    message: "tracker reconfigured with \(params) and override set to \(override)");
            }
        }
    }

/* ********************************** Specific methods ************************************* */

    func tagScreen(parameters: [AnyHashable: Any]) {

        if let screenName = parameters[SCREEN_NAME] {
            var screen = tracker.screens.add(screenName as! String);
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: screen.name);

            screen = self.setAdditionalScreenProperties(parameters: parameters as [NSObject : AnyObject], screen: screen);

            screen.sendView();
        }
        else {
            cargo.logger.logMissingParam(SCREEN_NAME, methodName: "tagScreen", handler: self);
        }
    }

    func tagEvent(parameters: [AnyHashable: Any]) {
        
        if let eventName = parameters[EVENT_NAME], let eventType = parameters[EVENT_TYPE] {
            var event = tracker.gestures.add(eventName as! String);
            cargo.logger.logParamSetWithSuccess(EVENT_NAME, value: event.name);

            event = self.setAdditionalEventProperties(parameters: parameters as [NSObject : AnyObject], event: event);
            
            switch eventType as! String {
                case "touch":
                    event.sendTouch();
                case "navigation":
                    event.sendNavigation();
                case "download":
                    event.sendDownload();
                case "exit":
                    event.sendExit();
                case "search":
                    event.sendSearch();
                default:
                    cargo.logger.logNotFoundValue(eventType as! String, key: EVENT_TYPE,
                                                  possibleValues: ["touch",
                                                                   "navigation",
                                                                   "download",
                                                                   "exit",
                                                                   "search"]);
            }
        }
        else {
            cargo.logger.logMissingParam("\(EVENT_NAME) and/or \(EVENT_TYPE)", methodName: "tagEvent", handler: self);
        }
    }
    
/* *********************************** Utility methods ************************************* */

    private func setAdditionalScreenProperties(parameters: [AnyHashable: Any], screen: Screen) -> Screen {
        let screen = screen;

        if let level2 = parameters[LEVEL2] {
            screen.level2 = level2 as! Int;
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: screen.name);
        }
        if let basket = parameters[BASKET] {
            screen.isBasketScreen = basket as! Bool;
            cargo.logger.logParamSetWithSuccess(BASKET, value: screen.isBasketScreen);
        }
        if let action = parameters[ACTION] {
            screen.action = action as! AbstractScreen.ScreenAction;
            cargo.logger.logParamSetWithSuccess(ACTION, value: screen.action);
        }
        
        if let chapter1 = parameters[CHAPTER1] {
            screen.chapter1 = chapter1 as? String;
            cargo.logger.logParamSetWithSuccess(CHAPTER1, value: screen.chapter1!);
            
            if let chapter2 = parameters[CHAPTER2] {
                screen.chapter2 = chapter2 as? String;
                cargo.logger.logParamSetWithSuccess(CHAPTER2, value: screen.chapter2!);
                
                if let chapter3 = parameters[CHAPTER3] {
                    screen.chapter3 = chapter3 as? String;
                    cargo.logger.logParamSetWithSuccess(CHAPTER3, value: screen.chapter3!);
                }
            }
        }

        return screen;
    }

    
    private func setAdditionalEventProperties(parameters: [AnyHashable: Any], event: Gesture) -> Gesture {
        let event = event;
        
        if let level2 = parameters[LEVEL2] {
            event.level2 = level2 as! Int;
            cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: event.name);
        }
        if let action = parameters[ACTION] {
            event.action = action as! Gesture.GestureAction;
            cargo.logger.logParamSetWithSuccess(ACTION, value: event.action);
        }

        if let chapter1 = parameters[CHAPTER1] {
            event.chapter1 = chapter1 as? String;
            cargo.logger.logParamSetWithSuccess(CHAPTER1, value: event.chapter1!);

            if let chapter2 = parameters[CHAPTER2] {
                event.chapter2 = chapter2 as? String;
                cargo.logger.logParamSetWithSuccess(CHAPTER2, value: event.chapter2!);

                if let chapter3 = parameters[CHAPTER3] {
                    event.chapter3 = chapter3 as? String;
                    cargo.logger.logParamSetWithSuccess(CHAPTER3, value: event.chapter3!);
                }
            }
        }
        return event;
    }

}

