//
//  Cargo.swift
//  SwiftSampleApp
//
//  Created by François K on 09/08/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation


class Cargo: NSObject {
    
/* ********************************* Variables Declaration ********************************* */

    static let sharedHelper = Cargo();
    var launchOptions: [NSObject: AnyObject]?;
    var registeredTagHandlers = Dictionary<String, CARTagHandler>();
    var tagManager:TAGManager!;
    var container:TAGContainer!;
    var logger: CARLogger!;


/* ************************************* Initializer *************************************** */

    /**
     * Initialization of Cargo and of the logger
     *
     */
    private override init() {
        logger = CARLogger(aContext: "Cargo");
        super.init();
    }


/* ********************************* Methods declaration *********************************** */

    /**
     * Setup the tagManager and the GTM container as properties of Cargo
     * Setup the log level of Cargo Logger from the level of the tagManager logger
     *
     * @param tagManager    The tag manager
     * @param tagContainer  The GTM container
     */
    func initTagHandlerWithManager(tagManager:TAGManager, tagContainer:TAGContainer) {
        //GTM
        self.tagManager = tagManager;
        self.container = tagContainer;

        //Logger
        self.logger.level = self.tagManager.logger.logLevel();
        logger.carLog(kTAGLoggerLogLevelInfo, message: "Cargo initialization is done");
    }


    /**
     * Called by each handler to register itself
     * in the registeredTagHandlers variable.
     *
     * @param tagHandler    The tag handler
     * @param key           The key the handler is register with
     */
    func registerTagHandler(tagHandler: CARTagHandler, key:String) {
        registeredTagHandlers[key] = tagHandler;
    }


    /**
     * For each handler stored in the registeredTagHandlers variable,
     * validate the handler in order to register its GTM callback methods
     *
     */
    func registerHandlers(){
        for (key, handler) in registeredTagHandlers {
            handler.validate();

            if (handler.valid){
                self.container.registerFunctionCallTagHandler(handler, forTag: key);
            }

            logger.carLog(kTAGLoggerLogLevelInfo, message: "Function with key \(key) has been registered for \(handler.name)");
        }
    }

}
