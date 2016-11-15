//
//  CARTagHandler.swift
//  SwiftSampleApp
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


/// A class all the handlers inherit from. 
/// Defines the mandatory methods which need to be implemented in any handler.
class CARTagHandler : NSObject, TAGFunctionCallTagHandler {

/* *********************************** Variables Declaration ************************************ */

    /** A unique key associated to the handler */
    var key: String;
    /** The name of the handler */
    var name: String;
    /** Defines whether the handler has been initialized */
    var valid: Bool = false;
    /** Defines whether the sdk has been initialized */
    var initialized: Bool = false ;

    /** The instance of Cargo, to access the logger among other attributes */
    let cargo = Cargo.sharedHelper;

/* *************************************** Initializer ****************************************** */

    /// Initialize the key & name variables for the handler.
    ///
    /// - Parameters:
    ///   - key: a unique key describing the handler
    ///   - name: the name of the handler
    init(key:String, name:String){
        self.key = key;
        self.name = name;
    }

/* *********************************** Methods declaration ************************************** */

    /// Called when a child "execute" method is called. Logs the method call and its parameters
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the callback method
    ///   - parameters: the parameters sent to the method through a dictionary
    func execute(_ tagName:String, parameters:[AnyHashable: Any]){
        cargo.logger.carLog(kTAGLoggerLogLevelDebug,
                            handler: self,
                            message: "Function \(tagName) has been received with parameters \(parameters)");
    }
    
    /// Logs when a tag doesn't match a method
    ///
    /// - Parameters:
    ///   - handler: The handler it happens in
    ///   - tagName: The tag name which doesn't match
    func noTagMatch(_ handler: CARTagHandler, tagName: String) {
        let infoMessage = "\(tagName) does not match any known tag";
        cargo.logger.carLog(kTAGLoggerLogLevelInfo, handler: handler, message: infoMessage);
    }

    
    /// Called in registerHandlers to validate a handler and check for its initialization.
    func validate(){
        valid = true;
    }

}
