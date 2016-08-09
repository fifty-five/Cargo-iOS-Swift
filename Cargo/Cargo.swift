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
    var registeredTagHandlers:Dictionary<String, CARTagHandler>? ;
    
    // var CARMacroHandlers (à voir si on doit définir la classe)
 
    
    private override init() {
        super.init();
        print("Cargo initialization done");
    }

    
    
}
