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

class VenueVC: UIViewController, RMMapViewDelegate, CLLocationManagerDelegate {
    
    
    var manager = CLLocationManager()
    var mapboxView: RMMapView!
    var foundVenue: [String:AnyObject] = [:]
    var venueID:String = ""
    
    var venueLocation: CLLocation!
    let tiyLocation = CLLocation(latitude: 33.7518732, longitude: -84.3914068)
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var foursquareButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        venueLocation = CLLocation(latitude: venueCoord.latitude as CLLocationDegrees, longitude: venueCoord.longitude as CLLocationDegrees)
        
        // MARK: Aesthetics
        urlButton.contentHorizontalAlignment = .Left
        addressButton.contentHorizontalAlignment = .Left
        
        // MARK: Foursquare
        // FIXME: Something looks wrong here:
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
        
        var mapboxFrame = CGRectMake(0, 0, view.bounds.width, view.bounds.height - 295)
        var mapboxTiles = RMMapboxSource(mapID: "mollie.l5ldhf1o")
        mapboxView = RMMapView(frame: mapboxFrame, andTilesource: mapboxTiles)
        mapboxView.delegate = self
        
        mapboxView.tileSource.cacheable = true
        mapboxView.zoom = 16 // temporary until userLocation loads
        mapboxView.centerCoordinate = venueCoord
        
        // zoom to annotations
        mapboxView.adjustTilesForRetinaDisplay = true
        mapboxView.userInteractionEnabled = true
        
        var annotation = RMAnnotation(mapView: mapboxView, coordinate: venueCoord, andTitle: venueTitle)
        
        mapboxView.addAnnotation(annotation)
        
        view.addSubview(mapboxView)
        
        
        // MARK: Labels
        nameLabel.text = venueTitle
        
        if foundVenue.count > 0 {
            
            if let categories: AnyObject = foundVenue["categories"] {
                categoryLabel.textColor = UIColor.whiteColor()
                categoryLabel.text = categories[0]["name"] as? String
            }
            
            if let location: AnyObject = foundVenue["location"] {
                addressButton.setTitleColor(blueUIColor, forState: .Normal)
                addressButton.setTitle(location["address"] as? String, forState: .Normal)
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
                    
                    priceLabel.textColor = UIColor.whiteColor()
             
                    switch tier {
                        
                    case 1:
                        priceLabel.text = "$"
                    case 2:
                        priceLabel.text = "$$"
                    case 3:
                        priceLabel.text = "$$$"
                    case 4:
                        priceLabel.text = "$$$$"
                    default:
                        priceLabel.text = ""
                    
                    
                    }
                    
                }
                
            }
            
            foursquareButton.setBackgroundImage(UIImage(named: "foursquare-wordmark"), forState: .Normal)
            
        } else if venueInfo.objectForKey("Address") as? String != "" {
            addressButton.setTitleColor(blueUIColor, forState: .Normal)
            addressButton.setTitle(venueInfo.objectForKey("Address") as? String, forState: .Normal)
        }
        
        let meters:CLLocationDistance = tiyLocation.distanceFromLocation(venueLocation)
        let df = MKDistanceFormatter()
        df.unitStyle = .Full
        distanceLabel.textColor = UIColor.whiteColor()
        distanceLabel.text = df.stringFromDistance(meters)
        
    }
    
    func mapView(mapView: RMMapView!, didUpdateUserLocation userLocation: RMUserLocation!) {
        
        // use the annotations to zoom and center
        // but only if userLocation is near venueLocation
        if venueLocation.distanceFromLocation(userLocation.location) < 1609 {
            zoomToFitAnnotations(mapboxView.annotations as [RMAnnotation])
        }
        
    }
    
    func zoomToFitAnnotations(annotations: [RMAnnotation]) {
        
        if annotations.count > 0 {
            
            if var firstCoordinate = annotations.first?.coordinate {
            
                var neLat = CGFloat(firstCoordinate.latitude)
                var neLon = CGFloat(firstCoordinate.longitude)
                var swLat = CGFloat(firstCoordinate.latitude)
                var swLon = CGFloat(firstCoordinate.longitude)
                
                for annotation in annotations {
                    
                    var coordinate = annotation.coordinate
                    
                    neLat = max(neLat, CGFloat(coordinate.latitude))
                    neLon = max(neLon, CGFloat(coordinate.longitude))
                    swLat = min(swLat, CGFloat(coordinate.latitude))
                    swLon = min(swLat, CGFloat(coordinate.longitude))
                    
                }
                
                var verticalMarginPixels = 80 as CGFloat
                var horizontalMarginPixels = 40 as CGFloat
                
                var verticalMarginPercent = verticalMarginPixels / mapboxView.bounds.height
                var horizontalMarginPercent = horizontalMarginPixels / mapboxView.bounds.width
                
                var verticalMargin = (neLat - swLat) * verticalMarginPercent
                var horizontalMargin = (neLon - swLon) * horizontalMarginPercent
                
                swLat -= verticalMargin
                swLon -= horizontalMargin
                neLat += verticalMargin
                neLon += horizontalMargin
                
                mapboxView.zoomWithLatitudeLongitudeBoundsSouthWest(CLLocationCoordinate2DMake(CLLocationDegrees(swLat), CLLocationDegrees(swLon)), northEast: CLLocationCoordinate2DMake(CLLocationDegrees(neLat), CLLocationDegrees(neLon)), animated: true)
                
            }
            
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
        
        
    }
    
    
    @IBAction func foursquarePressed(sender: AnyObject) {
        
        let venueID = venueInfo.objectForKey("Foursquare") as String
        
        let foursquareURL = "foursquare://venues/" + venueID
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: foursquareURL)!) {
        
            UIApplication.sharedApplication().openURL(NSURL(string: foursquareURL)!)
            
        } else {
            
            let url = "https://foursquare.com/v/" + venueID + "?ref=" + CLIENT_ID
            UIApplication.sharedApplication().openURL(NSURL(string:url)!)
            
        }
        
    }
    
    
    // MARK: Markers
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
            case "Coffee":
                markerImage = "cafe"
                markerColor = tealColor
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
