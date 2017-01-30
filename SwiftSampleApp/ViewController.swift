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
        FIRAnalytics.logEvent(withName: "applicationStart", parameters: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func pressedEvent(_ sender : AnyObject) {

        FIRAnalytics.logEvent(withName: "tagEvent", parameters: nil);
    }


    @IBAction func pressedUser(_ sender : AnyObject) {
        FIRAnalytics.logEvent(withName: "identify", parameters: nil);
    }

    @IBAction func pressedScreen(_ sender : AnyObject) {
        FIRAnalytics.logEvent(withName: "tagScreen", parameters: nil);
    }

    @IBAction func pressedPurchase(_ sender : AnyObject) {
        FIRAnalytics.logEvent(withName: "tagPurchase", parameters: nil);
    }

    @IBAction func setOptions(_ sender : AnyObject) {
        FIRAnalytics.logEvent(withName: "setOptions", parameters: nil);
    }
}
