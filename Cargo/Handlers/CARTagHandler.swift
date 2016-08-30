//
//  CARTagHandler.swift
//  SwiftSampleApp
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation

class CARTagHandler : NSObject, TAGFunctionCallTagHandler {

/* ********************************* Variables Declaration ********************************* */

    var key: String;
    var name: String;
    var initialized: Bool = false ;
    var valid: Bool = false;

    let cargo = Cargo.sharedHelper;

/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the variables for the handler
     *
     *  @param key  The key for the handler
     *  @param name The name of the handler
     */
    init(key:String, name:String){
        self.key = key;
        self.name = name;
    }

/* ********************************* Methods declaration *********************************** */

    /**
     *  Called when an execute child method is called. Logs the call
     *
     *  @param tagName  The tag name
     *  @param parameters   Dictionary of parameters
     */
    func execute(tagName:String, parameters:[NSObject : AnyObject]){
        cargo.logger.carLog(kTAGLoggerLogLevelDebug, handler: self, message: "Function \(tagName) has been received with parameters \(parameters)");
    }

    /**
     *  Logs when a tag doesn't match a method
     *
     *  @param handler  The handler it happens in
     *  @param tagName  The tag name which doesn't match
     */
    func noTagMatch(handler: CARTagHandler, tagName: String) {
        let infoMessage = "\(tagName) does not match any known tag";
        cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: handler, message: infoMessage);
    }

    /**
     *  Called when the handler is valid
     */
    func validate(){
        valid = true;
    }

}
