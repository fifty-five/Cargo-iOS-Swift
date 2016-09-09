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

        dataLayer.push(["event": "testGA"]);
        dataLayer.push(["event": "testFirebase"]);
        dataLayer.push(["event": "testTune", "eventName": "a cool event", "eventCurrencyCode": "USD"]);
        dataLayer.push(["event": "testFacebook", "eventName": "a super cool event", "valueToSum": 123]);
    }

    @IBAction func pressedUser(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;

        dataLayer.push(["event": "setUser"]);
        dataLayer.push(["event": "initialize"]);
    }

    @IBAction func pressedScreen(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;

        dataLayer.push(["event": "openScreen", SCREEN_NAME: "home_screen"]);
        dataLayer.push(["event": "purchase", "purchaseAmount": 60, "currencyCode": "USD"]); //pour tester l'event purchase du handler Facebook
    }

}
