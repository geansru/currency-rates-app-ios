//
//  MapViewController.swift
//  Best Currency Exchange Rate in Chelyabinsk
//
//  Created by Dmitriy Roytman on 16.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getButton: UIBarButtonItem!
    
    // MARK: - Properties
    var banks = [Bank]()
    var task: NSURLSessionDataTask!
    var location = Location()
    var routeBuilder: RouteBuilder!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        location.controller = self
        
        
        tryToGetBanksList()
        if !banks.isEmpty {
            println("Banks array not empty. Count = \(banks.count)")
            updateLocations()
            showLocations()
        }
        
    }
    
    // MARK: - @IBActions
    @IBAction func showUser() {
        location.getLocation()
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        let region = regionForAnnotations(banks)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Helpers
    func tryToGetBanksList() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if !appDelegate.banks.isEmpty {
            banks = appDelegate.banks
        }
    }
    
    func updateLocations() {
        mapView.addAnnotations(banks)
    }
    
    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            let coord = mapView.userLocation.coordinate
            println(coord.latitude)
            println(coord.longitude)
            region = MKCoordinateRegionMakeWithDistance(coord, 10000, 10000)
            
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    func showLocationDetails(sender: UIButton) {
//        performSegueWithIdentifier("EditLocation", sender: sender)
        let index = sender.tag
        let bank = banks[index]
        let placemark = bank.placemark!
        routeBuilder = RouteBuilder(controller: self, placemark: placemark)
        routeBuilder.build()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! BankDetailViewController
//            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = banks[button.tag]
//            controller.locationToEdit = location
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let centerCoordinate: CLLocationCoordinate2D = mapView.userLocation.coordinate
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.2, 0.2)
        let mapRegion: MKCoordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
        
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is Bank {
            
            let identifier = "Location"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                annotationView.enabled = true
                annotationView.canShowCallout = true
                annotationView.animatesDrop = false
                annotationView.pinColor = .Green
                annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
                
                let rightButton = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
                rightButton.addTarget(self, action: Selector("showLocationDetails:"), forControlEvents: .TouchUpInside)
                annotationView.rightCalloutAccessoryView = rightButton
            } else {
                annotationView.annotation = annotation
            }
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = find(banks, annotation as! Bank) {
                button.tag = index
            }
            
            return annotationView
        }
        
        return nil
    }
}

extension MapViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}