//
//  Cargo.swift
//  SwiftSampleApp
//
//  Created by François K on 09/08/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation


class Cargo: NSObject {
    
    // Déclaration des variables
    static let sharedHelper = Cargo();
    var launchOptions: Dictionary<String, AnyObject>?;
    var registeredTagHandlers = [CARTagHandler]();
    var tagManager:TAGManager;
    var container:TAGContainer;
    
    // var CARMacroHandlers (à voir si on doit définir la classe)
 
    
    private override init() {
        super.init();
        print("Cargo initialization done");
    }

    func registerHandler(){
        for handler in registeredTagHandlers {
            handler.validate();
            
            if (handler.valid){
                self.container.registerFunctionCallTagHandler(handler, forTag: handler.tag);
            }
            
            print("Handler \(handler.key) has been registered");
        }
    }
    
    
    func initTagHandlerWithManager(tagManager:TAGManager, tagHandler:TAGContainer) {
        self.tagManager = tagManager;
        self.container = tagHandler;
    }
    
}
