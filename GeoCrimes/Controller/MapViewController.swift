//
//  MapViewController.swift
//  GeoCrimes
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import GoogleMaps
import MBProgressHUD
import PromiseKit

class MapViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // initial position
        let camera = GMSCameraPosition.camera(withLatitude: kInitialLatitude, longitude: kInitialLongitude, zoom: kDefaultZoom)
        mapView.camera = camera
        mapView.delegate = self
        
        // initial month
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        monthTextField.text = dateFormatter.string(from: date)
        
        monthTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Custom methods
    /*
     * Calls the API and displays markers in the map
     */
    func getCrimeLocations() {
        guard let text = monthTextField.text,
            let yearString = text.components(separatedBy: "-").first,
            let monthString = text.components(separatedBy: "-").last,
            let year = Int(yearString),
            let month = Int(monthString) else {
                return
        }
        
        // clear any markers first
        clearMarkers()
        
        let api = PoliceAPI()
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        print("orig center=\(latitude, longitude)")
        
        MBProgressHUD.showAdded(to: view, animated: true)
        firstly {
            api.searchCrimes(onYear: year, onMonth: month, atLatitude: latitude, atlongitude: longitude)
        }.done { (crimes: [Crime]?) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.monthTextField.resignFirstResponder() // hide keyboard

            guard let crimes = crimes else {
                return
            }
            
            for crime in crimes {
                guard let location = crime.location,
                    let street = location.street,
                    let name = street.name,
                    let category = crime.category else {
                    continue
                }
                    
                self.addMarker(latitude: latitude, longitude: longitude, title: category, snippet: name)
            }
            
        }.catch { error in
            MBProgressHUD.hide(for: self.view, animated: true)
            print("\(error)")
            CoreDataAPI.sharedInstance.deleteCrimes()
        }
    }
    
    /*
     * Adds markers in the map at the given coordinates.
     */
    func addMarker(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
    }

    /*
     * Removes existing markers in the map.
     */
    func clearMarkers() {
        mapView.clear()
    }
    
    /*
     * Returns the bounds in the map.
     */
    func getVisibleBounds() -> GMSCoordinateBounds {
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        return bounds
    }
}

// MARK: UITextFieldDelegate
extension MapViewController : UITextFieldDelegate {
    /*
     * Calls the API after the user taps on the Enter key.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        // check if valid month input
        guard let text = textField.text,
            let _ = formatter.date(from: text) else {
            let alert = UIAlertController(title: "Error", message: "Invalid yyyy-MM date format.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return true
        }
        
        getCrimeLocations()
        
        return true
    }
}

// MARK: GMSMapViewDelegate
extension MapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        monthTextField.resignFirstResponder() // hide the keyboard
    }
    
    /*
     * This is called after initial view load and after user moves the map.
     */
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        getCrimeLocations()
    }
}


