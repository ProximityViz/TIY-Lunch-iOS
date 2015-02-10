//
//  VenueVC.swift
//  TIY Lunch
//
//  Created by Mollie on 2/6/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import MapKit

var venueTitle:String = ""
var venueCoord:CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
var venueInfo:AnyObject = ""

class VenueVC: UIViewController, RMMapViewDelegate,  CLLocationManagerDelegate {
    
    
    var manager = CLLocationManager()
    var mapboxView: RMMapView!
    var foundVenue: [String:AnyObject] = [:]
    var venueID:String = ""
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Aesthetics
        urlButton.contentHorizontalAlignment = .Left
        addressButton.contentHorizontalAlignment = .Left
        
        // MARK: Foursquare
        var foursquareID = venueInfo.objectForKey("Foursquare") as? String
        if foursquareID != "" {
            if var venueID:String = foursquareID {
                venueID = venueInfo.objectForKey?("Foursquare") as String
                foundVenue = FourSquareRequest.requestVenueWithID(venueID)
            } else {
                venueID = ""
            }
        }
        
        // MARK: Geolocation setup
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // MARK: Mapbox
        RMConfiguration().accessToken = "pk.eyJ1IjoibW9sbGllIiwiYSI6IjdoX1Z4d0EifQ.hXHw5tonOOCDlvh3oKQNXA"
        
        var mapboxFrame = CGRectMake(0, 0, view.bounds.width, 200)
        var mapboxTiles = RMMapboxSource(mapID: "mollie.l5ldhf1o")
        mapboxView = RMMapView(frame: mapboxFrame, andTilesource: mapboxTiles)
        mapboxView.delegate = self
        
        mapboxView.tileSource.cacheable = true
        // FIXME: possibly base zoom on geolocation?
        mapboxView.zoom = 16
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
                addressButton.setTitleColor(blueUIColor, forState: .Normal)
                addressButton.setTitle(location["address"] as? String, forState: .Normal)
            }
            
            if let categories: AnyObject = foundVenue["categories"] {
                categoryLabel.text = categories[0]["name"] as? String
            }
            
            if let url: AnyObject = foundVenue["url"] {
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
            
            if let price: AnyObject = foundVenue["price"] {

                if let tier = price["tier"] as? Int {
             
                    switch tier {
                        
                    case 1:
                        priceLabel.text = "$"
                    case 2:
                        priceLabel.text = "$"
                    case 3:
                        priceLabel.text = "$"
                    case 4:
                        priceLabel.text = "$"
                    default:
                        priceLabel.text = ""
                    
                    
                    }
                    
                }
                
            }
            
            let venueLocation = CLLocation(latitude: venueCoord.latitude, longitude: venueCoord.longitude)
            let tiyLocation = CLLocation(latitude: 33.7518732, longitude: -84.3914068)
            let meters:CLLocationDistance = venueLocation.distanceFromLocation(tiyLocation)
            let df = MKDistanceFormatter()
            df.unitStyle = .Full
            distanceLabel.text = df.stringFromDistance(meters)
            
        } else if venueInfo.objectForKey("Address") as? String != "" {
            addressButton.setTitleColor(blueUIColor, forState: .Normal)
            addressButton.setTitle(venueInfo.objectForKey("Address") as? String, forState: .Normal)
        }
        
        
    }
    
    @IBAction func urlButtonPressed(sender: AnyObject) {
//        UIApplication.sharedApplication().openURL(NSURL(string:"https://docs.google.com/forms/d/1S7XVU0ePdFFihdAL4NjoJeThoGho0DS84lix__K99JA/viewform")!)
        
        if foundVenue.count > 0 {
            
            if let url: String = foundVenue["url"] as? String {
                
                UIApplication.sharedApplication().openURL(NSURL(string:url)!)
                
            }
            
        }
        
    }
    
    @IBAction func addressButtonPressed(sender: AnyObject) {
        
        // TODO: Refactor??
        if foundVenue.count > 0 {
            
            if let location: AnyObject = foundVenue["location"] {
                
                if let address: [String] = location["formattedAddress"] as? [String] {
                    
                    var url: String = ""
                    
                    if address[0] != "" {
                        
                        if address[1] != "" {
                            url = "http://maps.apple.com/?q=" + address[0] + ", " + address[1]
                        } else {
                            url = "http://maps.apple.com/?q=" + address[0] + ", Atlanta GA"
                        }
                        
                    } else if venueInfo.objectForKey("Address") as? String != "" {
                        
                        let address = venueInfo.objectForKey("Address") as String
                        url = "http://maps.apple.com/?q=" + address + ", Atlanta GA"
                        
                    }
                    
                    if url != "" {
                        url = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                        UIApplication.sharedApplication().openURL(NSURL(string:url)!)
                    }
                    
                }
                
            }
            
        }
        
        // TODO: Maybe make this work even if the venue isn't found, with the data from the spreadsheet
        // but make sure it doesn't link if there's no info at all
        
        
    }
    
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
        
        if annotation.title? == "You Are Here" {
            
            return nil
            
        } else {
            // type
            var markerImage = "restaurant"
            var markerSize = "small"
            var markerColor = greenColor
            
            switch venueInfo.objectForKey("Type") as String {
                
            case "Eating":
                markerImage = "restaurant"
                markerColor = yellowColor
            case "Drinking":
                markerImage = "beer"
                markerColor = orangeColor
            default:
                markerImage = "embassy"
                markerColor = redColor
            }
            
            var venueMarker = RMMarker(mapboxMarkerImage: markerImage, tintColorHex: markerColor, sizeString: "medium")
            return venueMarker
            
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
