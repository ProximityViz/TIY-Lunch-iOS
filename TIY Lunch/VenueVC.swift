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

class VenueVC: UIViewController, RMMapViewDelegate, CLLocationManagerDelegate {
    
    
    var manager = CLLocationManager()
    var mapboxView = RMMapView()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
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
//        annotation.subtitle = "Address"
        //        annotation.userInfo = "custom icon"
        
        mapboxView.addAnnotation(annotation)
        
        view.addSubview(mapboxView)
        
        
        // MARK: Labels
        nameLabel.text = venueTitle

        // Do any additional setup after loading the view.
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
