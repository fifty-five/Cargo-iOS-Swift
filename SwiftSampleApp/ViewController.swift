//
//  ViewController.swift
//  SwiftSampleApp
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
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


    @IBAction func pressedEvent(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;

        dataLayer?.push(["event": "tagEvent"]);
    }

    @IBAction func pressedUser(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;

        dataLayer?.push(["event": "identify"]);
    }

    @IBAction func pressedScreen(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;

        dataLayer?.push(["event": "tagScreen"]);
    }

    @IBAction func pressedPurchase(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;
        
        dataLayer?.push(["event": "tagPurchase"]);
    }

}
