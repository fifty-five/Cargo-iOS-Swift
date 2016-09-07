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
        //Mettre un carlog
    }
    
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
        case FB_initialize:
            self.initialize(parameters);
            break ;
        case FB_activateApp:
            self.activateApp()(parameters);
            break ;
        case FB_tagEvent:
            self.tagEvent(parameters);
            break ;
        case FB_purchase:
            self.purchase(parameters);
            break ;
        default:
            noTagMatch(self, tagName: tagName);
        }
    }
    
    /* ********************************** Specific methods ************************************* */
    
    //TODO: tagEvent
    // Send an event to facebook SDK. Calls differents methods depending on which parameters have been given
    // Each events can be logged with a valueToSum and a set of parameters (up to 25 parameters).
    // When reported, all of the valueToSum properties will be summed together. It is an arbitrary number
    // that can represent any value (e.g., a price or a quantity).
    // Note that both the valueToSum and parameters arguments are optional.
    
    //TODO: purchase
    // Logs a purchase in your app. with purchaseAmount the money spent, and currencyCode the currency code.
    // The currency specification is expected to be an ISO 4217 currency code.
    
    
    

    
}