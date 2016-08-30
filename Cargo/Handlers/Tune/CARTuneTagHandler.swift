//
//  CARTuneTagHandler.swift
//  Cargo
//
//  Created by Julien Gil on 30/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import Foundation


import Foundation

class CARTuneTagHandler: CARTagHandler {

/* ********************************* Variables Declaration ********************************* */

    let Tune_init = "Tune_init";

/* ************************************* Initializer *************************************** */

    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "TUN", name: "Tune");
        
        cargo.registerTagHandler(self, key: Tune_init);
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
        case Tune_init:
            self.initialize(parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }

    /**
     *  Is called to set the advertiser ID & conversion key
     *
     *  @param parameters   Dictionary of parameters which should contain the advertiser ID
     *                      and the conversion key for this account
     */
    func initialize(parameters: [NSObject : AnyObject]) {
        if let advertiserId = parameters["advertiserId"], conversionKey = parameters["conversionKey"] {
            Tune.initializeWithTuneAdvertiserId(advertiserId as! String, tuneConversionKey: conversionKey as! String);
            self.initialized = true;
        }
        else {
            cargo.logger.logMissingParam("advertiserId/conversionKey", methodName: "Tune_init", handler: self);
        }
    }
    
}


