//
//  VenueVC.swift
//  TIY Lunch
//
//  Created by Mollie on 2/6/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

var venueTitle:String = ""
var venueCoord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
var venueInfo:AnyObject = ""
// FIXME: This will be part of venueInfo, later
var venueID:String = ""

class VenueVC: UIViewController, RMMapViewDelegate, CLLocationManagerDelegate {
    
    
    var manager = CLLocationManager()
    var mapboxView = RMMapView()
    var foundVenue: [String:AnyObject] = [:]
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Aesthetics
        urlButton.contentHorizontalAlignment = .Left
        
        // MARK: Foursquare
        let venueID = "644RJR"
        
        // FIXME: location should come from
        foundVenue = FourSquareRequest.requestVenueWithID("4adba2adf964a5209c2921e3")
        
        // MARK: Geolocation setup
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // MARK: Mapbox
        RMConfiguration().accessToken = "pk.eyJ1IjoibW9sbGllIiwiYSI6IjdoX1Z4d0EifQ.hXHw5tonOOCDlvh3oKQNXA"
        
        var mapboxFrame = CGRectMake(0, 0, view.bounds.width, 200)
        var mapboxTiles = RMMapboxSource(mapID: "mollie.l2ibmbpc")
        mapboxView = RMMapView(frame: mapboxFrame, andTilesource: mapboxTiles)
        mapboxView.delegate = self
        
        mapboxView.tileSource.cacheable = true
        // FIXME: possibly base zoom on geolocation?
        mapboxView.zoom = 17
        mapboxView.centerCoordinate = venueCoord
        mapboxView.adjustTilesForRetinaDisplay = true
        mapboxView.userInteractionEnabled = true
        
        var annotation = RMAnnotation(mapView: mapboxView, coordinate: venueCoord, andTitle: venueTitle)
        
        mapboxView.addAnnotation(annotation)
        
        view.addSubview(mapboxView)
        
        
        // MARK: Labels
        nameLabel.text = venueTitle
        
        if foundVenue.count > 0 {
            
            if let location: AnyObject = foundVenue["location"] {
                addressLabel.text = location["address"] as? String
            }
            
            if let categories: AnyObject = foundVenue["categories"] {
                categoryLabel.text = categories[0]["name"] as? String
            }
            
            if let url: AnyObject = foundVenue["url"] {
                // TODO: change text color to blue
                
//                UIApplication.sharedApplication().openURL(NSURL(string:"https://docs.google.com/forms/d/1S7XVU0ePdFFihdAL4NjoJeThoGho0DS84lix__K99JA/viewform")!)
                urlButton.setTitleColor(blueUIColor, forState: .Normal)
                urlButton.setTitle(url as? String, forState: .Normal)
            }
            
            if let hours: AnyObject = foundVenue["hours"] {
                if hours["isOpen"] as? Int == 1 {
                    hoursLabel.textColor = greenUIColor
                } else {
                    hoursLabel.textColor = redUIColor
                }
                hoursLabel.text = hours["status"] as? String
            }
            
            // TODO: menu
            
        } else {
            addressLabel.text = venueInfo.objectForKey("Address") as? String
        }
        // price tier?
        
        
    }
    
    @IBAction func urlButtonPressed(sender: AnyObject) {
//        UIApplication.sharedApplication().openURL(NSURL(string:"https://docs.google.com/forms/d/1S7XVU0ePdFFihdAL4NjoJeThoGho0DS84lix__K99JA/viewform")!)
        
        if foundVenue.count > 0 {
            
            if let url: String = foundVenue["url"] as? String {
                
                UIApplication.sharedApplication().openURL(NSURL(string:url)!)
                
            }
            
        }
        
    }
    
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
        
        if annotation.title? == "You Are Here" {
            
            return nil
            
        } else {
            
            var lunchMarker = RMMarker(mapboxMarkerImage: "restaurant", tintColorHex: "#D2B42A", sizeString: "medium")
            lunchMarker.canShowCallout = true
            
            return lunchMarker
            
        }
        
    }
    
    // MARK: Geolocation
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var userLocation = locations.last as CLLocation
        
        mapboxView.showsUserLocation = true
        mapboxView.userLocationVisible
        mapboxView.userLocation.title = "You Are Here"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
