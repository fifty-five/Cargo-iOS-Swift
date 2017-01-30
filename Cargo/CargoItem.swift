//
//  CargoItem.swift
//  Cargo
//
//  Created by Julien Gil on 21/12/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation


/// Create an Item object with this class in order to send item objects through Cargo
class CargoItem : NSObject {
    
    /// name of the item
    var item: String!;
    /// unit price of the item
    var unitPrice: CGFloat;
    /// number of items concerned
    var quantity: UInt;
    /// total cost of all these items
    var revenue: CGFloat;
    /// attribute of the item
    var attribute1: String!;
    /// attribute of the item
    var attribute2: String!;
    /// attribute of the item
    var attribute3: String!;
    /// attribute of the item
    var attribute4: String!;
    /// attribute of the item
    var attribute5: String!;

    
    /// Creates a CargoItem, which will be changed into an Item object for a specific SDK
    /// The revenue is automatically calculated with (quantity * unit price)
    ///
    /// - Parameters:
    ///   - name: name of the item
    ///   - unitPrice: unit price of the item
    ///   - quantity: amount of all these items
    public init(name: String!, unitPrice: CGFloat, quantity: UInt) {
        self.item = name;
        self.unitPrice = unitPrice;
        self.quantity = quantity;
        self.revenue = unitPrice * CGFloat(quantity);
    }

    
    /// Creates a CargoItem, which will be changed into an Item object for a specific SDK
    ///
    /// - Parameters:
    ///   - name: name of the item
    ///   - unitPrice: unit price of the item
    ///   - quantity: amount of all these items
    ///   - revenue: total cost of all these items
    public init(name: String!, unitPrice: CGFloat, quantity: UInt, revenue: CGFloat) {
        self.item = name;
        self.unitPrice = unitPrice;
        self.quantity = quantity;
        self.revenue = revenue;
    }

    
    /// A String representation for the current object.
    override var description: String {
        var json: String = "{\n\"id\": \"\(self.item!)\",\n \"unitPrice\": \"\(self.unitPrice)\",\n" +
        "\"quantity\": \"\(self.quantity)\",\n\"revenue\": \"\(self.revenue)\"";
        if ((attribute1) != nil) {
            json = json + ",\n\"attribute1\": \"\(self.attribute1!)\"";
        }
        if ((attribute2) != nil) {
            json = json + ",\n\"attribute2\": \"\(self.attribute2!)\"";
        }
        if ((attribute3) != nil) {
            json = json + ",\n\"attribute3\": \"\(self.attribute3!)\"";
        }
        if ((attribute4) != nil) {
            json = json + ",\n\"attribute4\": \"\(self.attribute4!)\"";
        }
        if ((attribute5) != nil) {
            json = json + ",\n\"attribute5\": \"\(self.attribute5!)\"";
        }
        json = json + "\n}";
        return json;
    }

    
    /// This class method has to be used before sending a CargoItem array to the DataLayer
    /// The array given as parameter is turned into a flat json String.
    ///
    /// - Parameter itemArray: the array of CargoItem attached to this event
    /// - Returns: a flat json, as a String, which will be turned back into an array by the handler.
    class func toGTM(itemArray: [CargoItem]) -> (String) {
        var tempDictArray: [Dictionary<String, AnyHashable>] = [];
        var string: String!;

        // turns the CargoItem objects as dictionaries
        for item in itemArray {
            var dic : Dictionary<String, AnyHashable> = [ "name" : item.item!, "unitPrice" : item.unitPrice,
                "quantity" : item.quantity, "revenue" : item.revenue];
            if ((item.attribute1) != nil) {
                dic["attribute1"] = item.attribute1!;
            }
            if ((item.attribute2) != nil) {
                dic["attribute2"] = item.attribute2!;
            }
            if ((item.attribute3) != nil) {
                dic["attribute3"] = item.attribute3!;
            }
            if ((item.attribute4) != nil) {
                dic["attribute4"] = item.attribute4!;
            }
            if ((item.attribute5) != nil) {
                dic["attribute5"] = item.attribute5!;
            }
            // add the dictionary in a array
            tempDictArray.append(dic);
        }
        do {
            // array encoded in JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: tempDictArray);
            // JSON data converted to String
            string = String(data: jsonData, encoding: String.Encoding.utf8);
        } catch {
            print(error.localizedDescription);
            Cargo.sharedHelper.logger.carLog(.error, message: "Unable to convert" +
                " [CargoItem] to Data type in class method CargoItem.toGTM()");
        }
        return string!;
    }
}
