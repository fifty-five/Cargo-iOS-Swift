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
        super.init(key: "AT", name: "AT Internet");
        self.tracker = ATInternet.sharedInstance.defaultTracker;

        cargo.registerTagHandler(self, key: AT_init);
        cargo.registerTagHandler(self, key: AT_setConfig);
        cargo.registerTagHandler(self, key: AT_tagScreen);
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

        switch (tagName) {
        case AT_init:
            self.initialize(parameters);
            break ;
        case AT_setConfig:
            self.setConfig(parameters: parameters);
            break ;
        case AT_tagScreen:
            self.tagScreen(parameters: parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
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
            self.initialized = true;
        }
        else {
            cargo.logger.logMissingParam(TRACKER_NAME, methodName: AT_init, handler: self);
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

        if (initialized) {
            if let screenName = parameters[SCREEN_NAME] {
                var screen = tracker.screens.add(screenName as! String);
                cargo.logger.logParamSetWithSuccess(SCREEN_NAME, value: screen.name);

                screen = self.addChapters(parameters: parameters as [NSObject : AnyObject], screen: screen);
                screen = self.setAdditionalProperties(parameters: parameters as [NSObject : AnyObject], screen: screen);

                screen.sendView();
            }
            else {
                cargo.logger.logMissingParam(SCREEN_NAME, methodName: "tagScreen", handler: self);
            }
        }
        else {
            cargo.logger.logUninitializedFramework(self);
        }
    }

/* *********************************** Utility methods ************************************* */

    private func addChapters(parameters: [AnyHashable: Any], screen: Screen) -> Screen {
        let screen = screen;

        if let chapter1 = parameters[CHAPTER1] {
            screen.chapter1 = chapter1 as? String;
            cargo.logger.logParamSetWithSuccess(CHAPTER1, value: screen.chapter1!);

            if let chapter2 = parameters[CHAPTER2] {
                screen.chapter2 = chapter2 as? String;
                cargo.logger.logParamSetWithSuccess(CHAPTER2, value: screen.chapter2!);

                if let chapter3 = parameters[CHAPTER3] {
                    screen.chapter2 = chapter3 as? String;
                    cargo.logger.logParamSetWithSuccess(CHAPTER3, value: screen.chapter3!);
                }
            }
        }
        return screen;
    }

    private func setAdditionalProperties(parameters: [AnyHashable: Any], screen: Screen) -> Screen {
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

        return screen;
    }

}

