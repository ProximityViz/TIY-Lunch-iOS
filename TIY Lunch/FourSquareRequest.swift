//
//  FourSquareRequest.swift
//  Maps
//
//  Created by Mollie on 2/2/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import CoreLocation

let API_URL = "https://api.foursquare.com/v2/"
let CLIENT_ID = "UTSGJ2ZPLOL2LHDOHW5XZFYHVASA4B0JIYMOXH3ZW1TLQ1X1"
let CLIENT_SECRET = "IOGOZ0YYX2CDS1CLO1ASXZU5EQ3MYSYUKXIP2SPD5MZ4CKKH"

class FourSquareRequest: NSObject {
    
    class func requestVenueWithID(id: String) -> [String:AnyObject] {
        
//        var requestString = API_URL + "venues/search"
//            + "?" + "client_id=" + CLIENT_ID
//            + "&" + "client_secret=" + CLIENT_SECRET
//            + "&" + "v=20130815"
//        requestString = requestString
//            + "&" + "ll=33.7518732,-84.3914068"
//            + "&" + "radius=1600"
//        requestString = requestString
//            + "&" + "query=taco"
        
        let requestString = API_URL + "venues/" + id
            + "?" + "client_id=" + CLIENT_ID
            + "&" + "client_secret=" + CLIENT_SECRET
            + "&" + "v=20130815"
        
        if let url = NSURL(string: requestString) {
        
            let request = NSURLRequest(URL: url)
            
            // dictionary with array of venues
            if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil) {
                
                if let returnInfo = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? [String:AnyObject] {
                    
                    let responseInfo = returnInfo["response"] as [String:AnyObject]
                    let venue = responseInfo["venue"] as [String:AnyObject]
                    
                    return venue
                    
                }
                
            }
            
        }
        
        return [:]
    }
   
}
