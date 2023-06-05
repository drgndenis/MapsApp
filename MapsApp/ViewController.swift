//
//  ViewController.swift
//  MapsApp
//
//  Created by Denis DRAGAN on 27.05.2023.
//

import UIKit
import MapKit
import CoreLocation // get the users location

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Konumu mesafe
        locationManager.requestWhenInUseAuthorization() // Uygulamayi kullanirken konumun kullanilmasina izin verilmesi
        locationManager.startUpdatingLocation() // Konumun guncellenmesi
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLocation))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @objc func selectLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedLocation = gestureRecognizer.location(in: mapView)
            let touchedCoordinate  = mapView.convert(touchedLocation, toCoordinateFrom: mapView)
            // Pin ekleme
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = "User choice"
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].coordinate.latitude)  // Enlem oranlari
        print(locations[0].coordinate.longitude)  // Boylam oranlari
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Harita acildiginda var olan konumun ne kadar yakin veya uzak gosterecegi
        let region = MKCoordinateRegion(center: location, span: span) // Konum degisikligi
        mapView.setRegion(region, animated: true)
    }
}
