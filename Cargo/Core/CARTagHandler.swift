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
class CARTagHandler : NSObject {

/* *********************************** Variables Declaration ************************************ */

    /** A unique key associated to the handler */
    var key: String;
    /** The name of the handler */
    var name: String;
    /** Defines whether the handler has been initialized */
    var valid: Bool = false;
    /** Defines whether the sdk has been initialized */
    var initialized: Bool = false ;

    /** Instance of the logger */
    var logger: CARLogger!;

/* *************************************** Initializer ****************************************** */

    /// Initialize the key & name variables for the handler.
    ///
    /// - Parameters:
    ///   - key: a unique key describing the handler
    ///   - name: the name of the handler
    init(key:String, name:String){
        self.key = key;
        self.name = name;
        super.init();
        Cargo.getInstance().registerHandler(self);
    }

/* *********************************** Methods declaration ************************************** */

    /// Called when a child "execute" method is called. Logs the method call and its parameters
    ///
    /// - Parameters:
    ///   - tagName: the tag name of the callback method
    ///   - parameters: the parameters sent to the method through a dictionary
    func execute(_ tagName:String, parameters:[AnyHashable: Any]){
        logger.logReceivedFunction(tagName, parameters: parameters as! [String : Any]);
    }

    /// Called in registerHandlers to validate a handler and check for its initialization.
    func validate(){
        valid = true;
    }

}
