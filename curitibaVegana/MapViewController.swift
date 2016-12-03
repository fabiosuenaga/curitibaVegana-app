//
//  ViewController.swift
//  curitibaVegana
//
//  Created by Fabio Suenaga on 24/04/16.
//  Copyright © 2016 gorpalabs. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {

    // MapView IBOutlet
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // Artworks receive objects from the JSON file
    var artworks = [Artwork]()
    var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // load json
        loadInitialData()
        
        // map location initialize
        let initialLocation = CLLocation(latitude: -25.4284, longitude: -49.2733)
        centerMapOnLocation(location: initialLocation)
        
        if (CLLocationManager.locationServicesEnabled()){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // delegate mapView apply the map resources
        mapView.delegate = self
        
        // show artwork on map to test
        mapView.addAnnotations(artworks)
        
//        self.navigationController?.navigationBar.barTintColor =  UIColor.init(red: 0.25, green: 0.71, blue: 0.18, alpha: 1.0)
        

    }
    
    
    
    // set visualization distance
    let regionRadius: CLLocationDistance = 4000
    // set region
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    
    // Load JSON file
    func loadInitialData() {
        // 01) Read the PublicArt.json file into an NSdata object
        let fileName = Bundle.main.path(forResource: "Vegan", ofType: "json");
        
        var optData:NSData? = nil
        do {
            optData = try NSData(contentsOfFile: fileName!, options: NSData.ReadingOptions.mappedIfSafe)
        }
        catch {
            optData = nil
        }
        
        if let data = optData {
         
            // 02) Use NSJSONSerialization to obtain a JSON object
            var jsonObject: AnyObject? = nil
            
            do {
                jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as AnyObject
                
                // 03) Check that the JSON object is a dictionary where the keys are Strings and the values can be AnyObject
                if let jsonObject = jsonObject as? [String: AnyObject], 
                    
                    // 04) You’re only interested in the JSON object whose key is "data" and you loop through that array of arrays, checking that each element is an array
                    let jsonData = JSONValue.fromObject(jsonObject as AnyObject)?["data"]?.array {
                    for artworkJSON in jsonData {
                        if let artworkJSON = artworkJSON.array,
                            
                            // 05) Pass each artwork’s array to the fromJSON method that you just added to the Artwork class. If it returns a valid Artwork object, you append it to the artworks array.
                            let artwork = Artwork.fromJSON(artworkJSON) {
                            artworks.append(artwork)
                        }
                    }
                }
                
            }
            catch {
                jsonObject = nil
            }

        }
        
        
    }
}

