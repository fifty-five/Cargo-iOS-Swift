//
//  ViewController.swift
//  SwiftSampleApp
//
//  Created by Julien Gil on 24/08/16.
//  Copyright © 2016 fifty-five All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!;
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var userEmailText: UITextField!
    @IBOutlet weak var xboxText: UITextField!
    @IBOutlet weak var playstationText: UITextField!
    @IBOutlet weak var nintendoText: UITextField!
    
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
        var parameters = [String: AnyHashable]();
        var revenue: CGFloat = 0;
        parameters["currencyCode"] = "EUR";

        if let qty = self.xboxText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let xbox = CargoItem.init(name: "xBox One", unitPrice: 149.99, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: xbox);
                revenue += xbox.revenue;
            }
        }
        if let qty = self.playstationText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let playstation = CargoItem.init(name: "Playstation 4", unitPrice: 240.75, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: playstation);
                revenue += playstation.revenue;
            }
        }
        if let qty = self.nintendoText.text {
            if (UInt(qty) != nil && UInt(qty)! > 0) {
                let nintendo = CargoItem.init(name: "Nintendo Switch", unitPrice: 350, quantity: UInt(qty)!);
                CargoItem.attachItemToEvent(item: nintendo);
                revenue += nintendo.revenue;
            }
        }
        parameters["totalRevenue"] = revenue;
        if (CargoItem.getItemsArray().count != 0) {
            parameters["eventItems"] = true;
        }
        FIRAnalytics.logEvent(withName: "tagPurchase", parameters: parameters as [String : NSObject]?);
    }

    @IBAction func clickOnView(_ sender: UITapGestureRecognizer) {
        dismissKeyboard();
    }
    
    func dismissKeyboard() {
        userNameText.resignFirstResponder();
        userEmailText.resignFirstResponder();
        xboxText.resignFirstResponder();
        playstationText.resignFirstResponder();
        nintendoText.resignFirstResponder();
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollPoint = CGPoint(x:0, y:textField.frame.origin.y/2);
        scrollView.setContentOffset(scrollPoint, animated: true);
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint.zero, animated: true);
    }
    
}
