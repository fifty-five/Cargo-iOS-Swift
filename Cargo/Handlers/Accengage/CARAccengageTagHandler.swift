//
//  CARAccengageHandler.swift
//  Cargo
//
//  Created by Julien Gil on 05/10/16.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation

class CARAccengageHandler: CARTagHandler {
    
/* ********************************* Variables Declaration ********************************* */
    
    let ACC_init = "ACC_init";
    
/* ************************************* Initializer *************************************** */
    
    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "ACC", name: "Accengage");
        self.registerNotification();
        
        cargo.registerTagHandler(self, key: ACC_init);
    }
    
    /**
     *  Register the right to
     */
    func registerNotification(){

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
        case ACC_init:
            self.initialize(parameters);
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
    func initialize(_ parameters: [AnyHashable: Any]) {

    }
    
/* ********************************** Specific methods ************************************* */

    
}
