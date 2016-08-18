//
//  ViewController.swift
//  SwiftSampleApp
//
//  Created by François K on 09/08/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func pressedEvent(sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;
        dataLayer.push(["event": "testGA"]);
    }
    
    @IBAction func pressedScreen(sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;
        dataLayer.push(["event": "openScreen", SCREEN_NAME: "home_screen"])
    }

}

