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

class MainMapVC: UIViewController, MKMapViewDelegate, RMMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var drawerRightConstraint: NSLayoutConstraint!

    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var drinksButton: UIButton!
    @IBOutlet weak var miscButton: UIButton!
    
    var manager = CLLocationManager()
    var mapboxView = RMMapView()
    
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
        // FIXME: should next two lines be hardcoded?
        mapboxView.zoom = 15
        mapboxView.centerCoordinate = CLLocationCoordinate2DMake(33.755, -84.39)
        mapboxView.adjustTilesForRetinaDisplay = true
        mapboxView.userInteractionEnabled = true
        
        var tiyLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(33.7518732, -84.3914068)
        var tiyAnnotation = RMAnnotation(mapView: mapboxView, coordinate: tiyLocation, andTitle: "The Iron Yard")
        tiyAnnotation.subtitle = "Life's Too Short for the Wrong Career"
//        tiyAnnotation.userInfo = "custom icon"
        
        mapboxView.addAnnotation(tiyAnnotation)
        
        var halfAnnotation = RMAnnotation(mapView: mapboxView, coordinate: tiyLocation, andTitle: "Half-mile radius")
        var quarterAnnotation = RMAnnotation(mapView: mapboxView, coordinate: tiyLocation, andTitle: "Quarter-mile radius")
        
//        var annotations: [RMAnnotation] = [halfAnnotation, quarterAnnotation]
//        mapboxView.addAnnotations([annotations])
        mapboxView.addAnnotation(halfAnnotation)
        mapboxView.addAnnotation(quarterAnnotation)
        
//        view.addSubview(mapboxView)
        view.insertSubview(mapboxView, belowSubview: drawerView)
        
            
//            - (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
        
        // marker colors
        let yellowColor = "#D5B810"
        let orangeColor = "#DB820C"
        let redColor = "#C94E43"
        
        // accessory colors
        let blueColor = "#00A5B1"
        let greenColor = "#0DC67D"
        let greenUIColor = UIColor(red:0.05, green:0.78, blue:0.49, alpha:1)
    
        if annotation.title? == "The Iron Yard" {
            
            var tiyMarker: RMMarker = RMMarker(UIImage: UIImage(named: "Iron-Yard"))
            tiyMarker.canShowCallout = true
            
            return tiyMarker
            
        } else if annotation.title? == "Half-mile radius" {
            
            // FIXME: change location of halfMile and quarterMile callouts
            var halfMile = RMCircle(view: mapView, radiusInMeters: 805)
            halfMile.canShowCallout = true
            
            halfMile.fillColor = UIColor.clearColor()
            halfMile.lineColor = greenUIColor
            halfMile.lineWidthInPixels = 2.0
            
            return halfMile
            
        } else if annotation.title? == "Quarter-mile radius" {
            
            var quarterMile = RMCircle(view: mapView, radiusInMeters: 402)
            quarterMile.canShowCallout = true
            
            quarterMile.fillColor = UIColor.clearColor()
            quarterMile.lineColor = greenUIColor
            quarterMile.lineWidthInPixels = 2.0
            
            return quarterMile
            
        } else if annotation.title? == "You Are Here" {
            // TODO: I'd rather have a blue dot
            
//            var geolocationMarker = RMMarker(mapboxMarkerImage: "embassy", tintColorHex: "#ffffff", sizeString: "large")
//            geolocationMarker.canShowCallout = true
            
            return nil
            
        } else { // markers from mapbox data
            
            // type
            var markerImage = "restaurant"
            var markerSize = "small"
            var markerColor = greenColor
            
            // TODO: Refactoring: probably should give annotation.userInfo.objectForKey("Type") a variable name above somewhere. Same with other keys.
            switch annotation.userInfo.objectForKey("Type") as String {
                
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
            
            switch annotation.userInfo.objectForKey("Count") as String {
                
            case "2":
                markerSize = "medium"
            case "3":
                markerSize = "large"
            default:
                markerSize = "small"
                
            }
            
//            println(annotation.description)
//            println(annotation.userInfo)
            
//                {
//                    Address = "Peachtree and Edgewood";
//                    Coordinates = "33.7558504,-84.3888957";
//                    Count = 2;
//                    Place = "Tin Drum";
//                    Type = Eating;
//                    description = "Peachtree and Edgewood";
//                    id = "marker-i5h0ggxfu";
//                    "marker-color" = "#d2b42a";
//                    "marker-size" = "";
//                    "marker-symbol" = restaurant;
//                    title = "Tin Drum";
//            }
            
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
        
        // TODO: add filtering code, which might change if statement to an "if foodIsOn"
        
        if foodButton.imageView?.image == UIImage(named: "food yellow") {
            foodButton.setImage(UIImage(named: "food grey"), forState: .Normal)
        } else {
            foodButton.setImage(UIImage(named: "food yellow"), forState: .Normal)
        }
        
    }
    
    @IBAction func tappedDrink(sender: AnyObject) {
        
        if drinksButton.imageView?.image == UIImage(named: "drink orange") {
            drinksButton.setImage(UIImage(named: "drink grey"), forState: .Normal)
        } else {
            drinksButton.setImage(UIImage(named: "drink orange"), forState: .Normal)
        }
        
    }
    
    @IBAction func tappedMisc(sender: AnyObject) {
        
        if miscButton.imageView?.image == UIImage(named: "misc red") {
            miscButton.setImage(UIImage(named: "misc grey"), forState: .Normal)
        } else {
            miscButton.setImage(UIImage(named: "misc red"), forState: .Normal)
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
