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

        let eventItem1 = TuneCustomItem(name: "test1", unitPrice: 5.5, quantity: 10);
        let eventItem2 = TuneCustomItem(name: "test2", unitPrice: 4.2, quantity: 10, revenue: 42);
        eventItem2.attribute1 = "attr1";
        eventItem2.attribute3 = "attr2";
        let eventItems = [eventItem1, eventItem2];

        dataLayer?.push(["event": "tagEvent",
                         "eventItems": TuneCustomItem.toGTM(itemArray: eventItems),
                         "eventDate1": Date().timeIntervalSince1970]);
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

    @IBAction func setOptions(_ sender : AnyObject) {
        let dataLayer = Cargo.sharedHelper.tagManager.dataLayer;

        dataLayer?.push(["event": "setOptions"]);
    }
}
