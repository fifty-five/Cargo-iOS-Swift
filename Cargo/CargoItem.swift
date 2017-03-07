//
//  CargoItem.swift
//  Cargo
//
//  Created by Julien Gil on 21/12/2016.
//  Copyright © 2016 François K. All rights reserved.
//

import Foundation


/// Create an Item object with this class in order to send item objects through Cargo
@objc class CargoItem : NSObject {
    
    /// name of the item
    var name: String!;
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

    static var itemsArray : [CargoItem]?;
    static var tagFiredSinceLastChange = false;


    class func attachItemToEvent(item: CargoItem) {
        self.emptyListIfTagHasBeenFired();
        if ((self.itemsArray?.append(item)) == nil) {
            self.itemsArray = [item];
        }
    }

    class func emptyListIfTagHasBeenFired() {
        if (self.tagFiredSinceLastChange) {
            self.tagFiredSinceLastChange = false;
            self.itemsArray = nil;
        }
    }

    /// A getter for the NSMutableArray of items which will be sent to the next "item relative" event.
    /// May be used to modify some objects before setting a new Array with the 'setItemsArray' method.
    ///
    /// @return an NSMutableArray of CargoItem objects.
    class func getItemsArray() -> ([CargoItem]) {
        return self.itemsArray!;
    }
    

    /// Sets the array of items which will be sent to the next "item relative" event with a new value.
    ///
    /// @param newItemsArray A new array of CargoItem objects, which value can be null.
    class func setNewItemsArray(newItemsArray: [CargoItem]) {
        self.emptyListIfTagHasBeenFired();
        self.itemsArray = newItemsArray;
    }

    /// A method called whenever a tag is received in the Tags class.
    @objc class func notifyTagFired() {
        self.tagFiredSinceLastChange = true;
    }

    /// Creates a CargoItem, which will be changed into an Item object for a specific SDK
    /// The revenue will be automatically calculated with (quantity * unit price) within Tune SDK
    ///
    /// - Parameters:
    ///   - name: name of the item
    ///   - unitPrice: unit price of the item
    ///   - quantity: amount of all these items
    public init(name: String!, unitPrice: CGFloat, quantity: UInt) {
        self.name = name;
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
        self.name = name;
        self.unitPrice = unitPrice;
        self.quantity = quantity;
        self.revenue = revenue;
    }


    /// A String representation for the current object.
    override var description: String {
        var json: String = "{\n\"name\": \"\(self.name!)\",\n \"unitPrice\": \"\(self.unitPrice)\",\n" +
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

}
