//
//  MainMapVC.swift
//  TIY Lunch
//
//  Created by Mollie on 1/26/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit
import MapKit

class MainMapVC: UIViewController, MKMapViewDelegate, RMMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RMConfiguration().accessToken = "pk.eyJ1IjoibW9sbGllIiwiYSI6IjdoX1Z4d0EifQ.hXHw5tonOOCDlvh3oKQNXA"
        
        var mapboxFrame = CGRectMake(0, 20, view.bounds.width, (view.bounds.height - 80))
        var mapboxTiles = RMMapboxSource(mapID: "mollie.l2ibmbpc")
        var mapboxView = RMMapView(frame: mapboxFrame, andTilesource: mapboxTiles)
        var mapboxSource = RMMapboxSource(mapID: "mollie.l2ibmbpc", enablingDataOnMapView: mapboxView)
        mapboxView.delegate = self
        
        println("\(mapboxSource)")
        
        mapboxView.tileSource.cacheable = true
        mapboxView.zoom = 15
        mapboxView.adjustTilesForRetinaDisplay = true
        mapboxView.centerCoordinate = CLLocationCoordinate2DMake(33.755, -84.39)
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
        
        view.addSubview(mapboxView)
        
    }
    
    // FIXME: custom markers kill popups
    func mapView(mapView: RMMapView!, layerForAnnotation annotation: RMAnnotation!) -> RMMapLayer! {
        
        println(annotation)
        
        // marker colors
        var yellowColor = "#D5B810"
        var orangeColor = "#DB820C"
        var redColor = "#C94E43"
        
        // accessory colors
        var blueColor = "#00A5B1"
        var greenColor = "#0DC67D"
        var greenUIColor = UIColor(red:0.05, green:0.78, blue:0.49, alpha:1)
        
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
            
        } else {
            
            var foodSymbol = "restaurant"
            var beerSymbol = "beer"
            
            var lunchMarker = RMMarker(mapboxMarkerImage: foodSymbol, tintColorHex: "#D2B42A", sizeString: "medium")
            lunchMarker.canShowCallout = true
            return lunchMarker
            
        }
        
    }

    @IBAction func contributeWasPressed(sender: UIButton) {
        
        UIApplication.sharedApplication().openURL(NSURL(string:"https://docs.google.com/forms/d/1S7XVU0ePdFFihdAL4NjoJeThoGho0DS84lix__K99JA/viewform")!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
