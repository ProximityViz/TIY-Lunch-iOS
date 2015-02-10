//
//  MainMapVC.swift
//  TIY Lunch
//
//  Created by Mollie on 1/26/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// marker colors
let yellowColor = "#D5B810"
let orangeColor = "#DB820C"
let redColor = "#C94E43"
let redUIColor = UIColor(red:0.79, green:0.31, blue:0.26, alpha:1)

// accessory colors
let blueColor = "#00A5B1"
let blueUIColor = UIColor(red:0, green:0.65, blue:0.69, alpha:1)
let greenColor = "#0DC67D"
let greenUIColor = UIColor(red:0.05, green:0.78, blue:0.49, alpha:1)

class MainMapVC: UIViewController, MKMapViewDelegate, RMMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var drawerRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var drinksButton: UIButton!
    @IBOutlet weak var miscButton: UIButton!
    
    var manager = CLLocationManager()
    var mapboxView: RMMapView!
    
    var foodShown = true
    var drinksShown = true
    var miscShown = true
    
    // change to specific type
    var foodAnnotations = [RMAnnotation]()
    var drinksAnnotations = [RMAnnotation]()
    var miscAnnotations = [RMAnnotation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawerRightConstraint.constant = -151
        
        // MARK: Geolocation setup
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // MARK: Mapbox
        RMConfiguration().accessToken = "pk.eyJ1IjoibW9sbGllIiwiYSI6IjdoX1Z4d0EifQ.hXHw5tonOOCDlvh3oKQNXA"
        
        var mapboxFrame = CGRectMake(0, 20, view.bounds.width, (view.bounds.height - 20))
        var mapboxTiles = RMMapboxSource(mapID: "mollie.l2ibmbpc")
        mapboxView = RMMapView(frame: mapboxFrame, andTilesource: mapboxTiles)
        var mapboxSource = RMMapboxSource(mapID: "mollie.l2ibmbpc", enablingDataOnMapView: mapboxView)
        mapboxView.delegate = self
        
        mapboxView.tileSource.cacheable = true
        mapboxView.zoom = 15
        mapboxView.centerCoordinate = CLLocationCoordinate2DMake(33.755, -84.39)
        mapboxView.adjustTilesForRetinaDisplay = true
        mapboxView.userInteractionEnabled = true
        
        var tiyLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(33.7518732, -84.3914068)
        var tiyAnnotation = RMAnnotation(mapView: mapboxView, coordinate: tiyLocation, andTitle: "The Iron Yard")
        tiyAnnotation.subtitle = "Life's Too Short for the Wrong Career"
        
        mapboxView.addAnnotation(tiyAnnotation)
        
        var halfAnnotation = RMAnnotation(mapView: mapboxView, coordinate: tiyLocation, andTitle: "Half-mile radius")
        var quarterAnnotation = RMAnnotation(mapView: mapboxView, coordinate: tiyLocation, andTitle: "Quarter-mile radius")
        
        var annotations: [RMAnnotation] = [halfAnnotation, quarterAnnotation]
        mapboxView.addAnnotations(annotations)
        
        // get drawer to show above map
        view.insertSubview(mapboxView, belowSubview: drawerView)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
    
        if annotation.title? == "The Iron Yard" {
            
            var tiyMarker: RMMarker = RMMarker(UIImage: UIImage(named: "Iron-Yard"))
            tiyMarker.canShowCallout = true
            
            return tiyMarker
            
        } else if annotation.title? == "Half-mile radius" {
            
            var halfMile = RMCircle(view: mapView, radiusInMeters: 805)
            
            halfMile.fillColor = UIColor.clearColor()
            halfMile.lineColor = greenUIColor
            halfMile.lineWidthInPixels = 2.0
            
            return halfMile
            
        } else if annotation.title? == "Quarter-mile radius" {
            
            var quarterMile = RMCircle(view: mapView, radiusInMeters: 402)
            
            quarterMile.fillColor = UIColor.clearColor()
            quarterMile.lineColor = greenUIColor
            quarterMile.lineWidthInPixels = 2.0
            
            return quarterMile
            
        } else if annotation.title? == "You Are Here" {
            // TODO: I'd rather have a blue dot
            
            return nil
            
        } else { // markers from mapbox data
            
            // TODO: move this to be its own function in a separate file if it ends up being used twice
            // type
            var markerImage = "restaurant"
            var markerSize = "small"
            var markerColor = greenColor
            
            switch annotation.userInfo.objectForKey("Type") as String {
                
            case "Eating":
                markerImage = "restaurant"
                markerColor = yellowColor
                foodAnnotations.append(annotation)
            case "Drinking":
                markerImage = "beer"
                markerColor = orangeColor
                drinksAnnotations.append(annotation)
            default:
                markerImage = "embassy"
                markerColor = redColor
                miscAnnotations.append(annotation)
            }
            
            switch annotation.userInfo.objectForKey("Count") as String {
                
            case "2":
                markerSize = "medium"
            case "3":
                markerSize = "large"
            default:
                markerSize = "small"
                
            }
            
            // marker and callout
            var lunchMarker = RMMarker(mapboxMarkerImage: markerImage, tintColorHex: markerColor, sizeString: markerSize)
            lunchMarker.canShowCallout = true
            
            var rightArrowButton = ArrowButton(frame: CGRectMake(0, 0, 22, 22))
            rightArrowButton.strokeColor = greenUIColor
            
            lunchMarker.rightCalloutAccessoryView = rightArrowButton

            return lunchMarker
            
        }
        
    }
    
    func tapOnCalloutAccessoryControl(control: UIControl!, forAnnotation annotation: RMAnnotation!, onMap map: RMMapView!) {
        
        var venueVC = storyboard?.instantiateViewControllerWithIdentifier("venueVC") as UIViewController
        
        // pass data through here. with a singleton, you can:
        //        let index = (view.annotation as MyPointAnnotation).index
        //        FeedData.mainData().selectedSeat = FeedData.mainData().feedItems[index]
        venueTitle = annotation.title
        venueCoord = annotation.coordinate
        venueInfo = annotation.userInfo
        
        navigationController?.pushViewController(venueVC, animated: true)
        
    }

    @IBAction func contributeWasPressed(sender: UIButton) {
        
        UIApplication.sharedApplication().openURL(NSURL(string:"https://docs.google.com/forms/d/1S7XVU0ePdFFihdAL4NjoJeThoGho0DS84lix__K99JA/viewform")!)
        
    }
    
    // MARK: Geolocation
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        var userLocation = locations.last as CLLocation
        
        mapboxView.showsUserLocation = true
        mapboxView.userLocationVisible
        mapboxView.userLocation.title = "You Are Here"
        
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [MKAnnotationView]!) {
        
        // FIXME: Is this even working?
        for view in views {
            
            if view.annotation.title == "You Are Here" {
                
                view.superview?.bringSubviewToFront(view)
                
            } else {
                
                view.superview?.sendSubviewToBack(view)
                
            }
            
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println(error)
        
    }
    
    // MARK: Drawer
    @IBAction func showHideDrawer(sender: AnyObject) {
        
        drawerRightConstraint.constant = (drawerRightConstraint.constant == -151) ? 0 : -151
        
    }
    
    @IBAction func tappedFood(sender: AnyObject) {

        if foodShown == true {
            
            foodButton.setImage(UIImage(named: "food grey"), forState: .Normal)
            foodShown = false
            mapboxView.removeAnnotations(foodAnnotations)
            
        } else {
            
            foodButton.setImage(UIImage(named: "food yellow"), forState: .Normal)
            foodShown = true
            mapboxView.addAnnotations(foodAnnotations)
            
        }
        
    }
    
    @IBAction func tappedDrink(sender: AnyObject) {
        
        if drinksShown == true {
            
            drinksButton.setImage(UIImage(named: "drink grey"), forState: .Normal)
            drinksShown = false
            mapboxView.removeAnnotations(drinksAnnotations)
            
        } else {
            
            drinksButton.setImage(UIImage(named: "drink orange"), forState: .Normal)
            drinksShown = true
            mapboxView.addAnnotations(drinksAnnotations)
            
        }
        
    }
    
    @IBAction func tappedMisc(sender: AnyObject) {
        
        if miscShown == true {
            
            miscButton.setImage(UIImage(named: "misc grey"), forState: .Normal)
            miscShown = false
            mapboxView.removeAnnotations(miscAnnotations)
            
        } else {
            
            miscButton.setImage(UIImage(named: "misc red"), forState: .Normal)
            miscShown = true
            mapboxView.addAnnotations(miscAnnotations)
            
        }
        
    }
    
    // MARK: End
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
