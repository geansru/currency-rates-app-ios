//
//  Geocoder.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import CoreLocation
import MapKit

class Geocoder {
    let geocoder = CLGeocoder()

    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    func startGeocoding(var address: String, completion: (CLPlacemark)->()) {
        address += ",Челябинск, Россия"
        
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let err = error { println(err.localizedDescription) }
            if DEBUG { println(address) }
            if let placemark = placemarks?[0] as? CLPlacemark {
                completion(placemark)
                if DEBUG { println(self.coordinateStringFromPlacemark(placemark)) }
            }
        })
    }
    
    func startReverseGeocoding(location: CLLocation!, completion: (CLPlacemark!)->()) {
        performingReverseGeocoding = true
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            self.lastGeocodingError = error
            if let placemark = (placemarks as? [CLPlacemark])?.last {
                self.performingReverseGeocoding = false
                if DEBUG { println(self.stringFromPlacemark(placemark)) }
                completion(placemark)
            }
        })
    }
    
    func coordinateStringFromPlacemark(placemark: CLPlacemark) -> String {
        return  "\(stringFromPlacemark(placemark))\n" +
                "latitude:\(placemark.location.coordinate.latitude)\n" +
                "longitude:\(placemark.location.coordinate.longitude)"
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        return "\(placemark.subThoroughfare) \(placemark.thoroughfare)\n" + "\(placemark.locality) \(placemark.administrativeArea) " + "\(placemark.postalCode)"
    }
}
