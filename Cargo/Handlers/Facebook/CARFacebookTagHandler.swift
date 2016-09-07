//
//  CARFacebookTagHandler.swift
//  Cargo
//
//  Created by François K on 06/09/2016.
//  Copyright © 2016 55 SAS. All rights reserved.
//

import Foundation

class CARFacebookTagHandler: CARTagHandler {
    
    /* ********************************* Variables Declaration ********************************* */
    
    var fbAppEvents : FBSDKAppEvents;
    var facebookLogger:  AppEventsLogger;
    
    let FB_initialize = "FB_initialize";
    let FB_activateApp = "FB_activateApp";
    let FB_tagEvent = "FB_tagEvent";
    let FB_purchase = "FB_purchase";
    
    /* ************************************* Initializer *************************************** */
    
    /**
     *  Initialize the handler
     */
    init() {
        super.init(key: "FB", name: "Facebook");
        self.fbAppEvents;
        self.facebookLogger;
        
        cargo.registerTagHandler(self, key: FB_initialize);
        cargo.registerTagHandler(self, key: FB_activateApp);
        cargo.registerTagHandler(self, key: FB_tagEvent);
        cargo.registerTagHandler(self, key: FB_purchase);
    }
    
    
    /* ******************************** Core handler methods *********************************** */
    
    /**
     * Initialize Facebook SDK with the Application id given by Facebook when Facebook app has benn created
     */
    func initialize(parameters: [NSObject : AnyObject]){
        if let applicationId = parameters["applicationId"]{
            self.fbAppEvents.setLoggingOverrideAppID(applicationId);
            //mettre un carlog
        }
        self.activateApp()
    }
    
    /**
     * Activate events logging
     */
    func activateApp(){
        self.fbAppEvents.activateApp();
    }
    
    
    /* ********************************** Specific methods ************************************* */
    
    
}