//
//  RouteBuilder.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 19.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class RouteBuilder {
    
    // MARK: enum
    enum Sourse {
        case MapViewController
    }
    // MARK: Properties
    var sourse: Sourse
    var controller: UIViewController
    var destinationPlacemark: CLPlacemark
    var transportType: MKDirectionsTransportType =  MKDirectionsTransportType.Walking
    
    // MARK: Constructors
    init(controller: UIViewController, placemark: CLPlacemark) {
        self.controller = controller
        self.destinationPlacemark = placemark
        self.sourse = Sourse.MapViewController
    }
    
    init(controller: UIViewController, placemark: CLPlacemark, sourse: RouteBuilder.Sourse) {
        self.controller = controller
        self.destinationPlacemark = placemark
        self.sourse = sourse
    }
    
    // MARK: Build route
    func build() {
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        
        /* Convert the CoreLocation destination placemark to a MapKit placemark */
        let destinationCoordinates = destinationPlacemark.location.coordinate
        /* Get the placemark of the destination address */
        let destination = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
        
        /* Set request transport type */
        request.transportType = transportType
        
        /* Get the directions */
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response: MKDirectionsResponse!, error: NSError!) -> Void in
            if let error = error {
                self.alert(error)
            } else {
                self.handler()
                /* Display the directions on the Maps app */
                let launchOptions = [ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                MKMapItem.openMapsWithItems([response.source, response.destination], launchOptions: launchOptions)
            }
        }
        
    }
    
    // MARK: Error alert
    func alert(error: NSError) {
        let title = "Building Route Error"
        let message = error.localizedDescription
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(ok)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Completion Handler
    func handler()  {
        switch self.sourse {
        case RouteBuilder.Sourse.MapViewController:
            // TODO: Add some action in controller (if needed)
            break
        }
    }
}