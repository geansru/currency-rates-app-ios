//
//  Location.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreLocation

class Location: NSObject {
    // MARK: - Properties
    let locationManager: CLLocationManager = CLLocationManager()
    var controller: UIViewController!
    var location: CLLocation! {
        didSet {
            if DEBUG { println("didUpdateLocations \(location)") }
        }
    }
    
    let geocoder: Geocoder = Geocoder()
    var updatingLocation = false
    var lastLocationError: NSError?
    
    // MARK: Constructors
    override init() {
        super.init()
        getLocation()
    }
    
    init(controller: UIViewController) {
        self.controller = controller
        super.init()
        getLocation()
    }
    
    func getLocation() {
        if !checkAuth() { return }
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
        }
        startLocationManager()
        configureGetButton()
    }
    
    func configureGetButton() {
        if let mapVC = controller as? MapViewController {
            if updatingLocation {
                mapVC.getButton?.enabled = false
            } else {
                mapVC.getButton?.enabled = true
            }
        }
    }
}

extension Location: CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        if error.code == CLError.LocationUnknown.rawValue { return }
        if DEBUG { println("didFailWithError \(error)") }
        lastLocationError = error
        stopLocationManager()
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let newLocation = locations.last as! CLLocation
        if DEBUG { println(newLocation) }
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        if newLocation.horizontalAccuracy < 0 { return }
        
        if location == nil || location?.horizontalAccuracy > newLocation.horizontalAccuracy {
            lastLocationError = nil
            location = newLocation
            configureGetButton()
            if newLocation.horizontalAccuracy < locationManager.desiredAccuracy {
                if DEBUG { println("*** We're done!") }
                stopLocationManager()
                configureGetButton()
                geocoder.startReverseGeocoding(location, completion: { (placemark: CLPlacemark!) -> () in
                    if DEBUG { println("In closure startReverseGeocoding") }
                })
            }
        }
    }
    
    // MARK: - Helpers
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func checkAuth() -> Bool {
            let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if authStatus == .NotDetermined {
                locationManager.requestWhenInUseAuthorization()
                return false
            }
            if authStatus == .Denied || authStatus == .Restricted {
                showLocationServicesDeniedAlert()
                return false
            }
            
            return true
    }
    
    func showLocationServicesDeniedAlert() {
            let title = "Location Services Disabled"
            let message = "Please enable location services for this app in Settings."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            if DEBUG { println("Error: Location Services Disabled") }
            controller?.presentViewController(alert, animated: true, completion: nil)
    }
}