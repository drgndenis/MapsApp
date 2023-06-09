//
//  ViewController.swift
//  MapsApp
//
//  Created by Denis DRAGAN on 27.05.2023.
//

import UIKit
import CoreData
import MapKit
import CoreLocation // get the users location

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var nameTextFields: UITextField!
    @IBOutlet var notesTextField: UITextField!
    
    var locationManager = CLLocationManager()
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    var selectedName = ""
    var selectedId: UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude =  Double()
    var annotationLongitude = Double()
    
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
        
        addData()
    }
    
    
    @objc func selectLocation(gestureRecognizer : UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchedLocation = gestureRecognizer.location(in: mapView)
            let touchedCoordinate  = mapView.convert(touchedLocation, toCoordinateFrom: mapView)
            selectedLatitude = touchedCoordinate.latitude
            selectedLongitude = touchedCoordinate.longitude
            
            // Pin ekleme
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = nameTextFields.text
            annotation.subtitle = notesTextField.text
            mapView.addAnnotation(annotation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].coordinate.latitude)  // Enlem oranlari
        print(locations[0].coordinate.longitude)  // Boylam oranlari
        if selectedName == "" {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Harita acildiginda var olan konumun ne kadar yakin veya uzak gosterecegi
            let region = MKCoordinateRegion(center: location, span: span) // Konum degisikligi
            mapView.setRegion(region, animated: true)
        }
    }
    
    //MARK: Special Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationID = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationID)
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationID)
            pinView?.canShowCallout = true
            pinView?.tintColor = .darkGray
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //MARK: Special annotation icinde verilen butonun yapacaklari
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedName != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude) // Harita olusturma
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkArray, error) in
                if let placemarks = placemarkArray {
                    if placemarks.count > 0 {
                        let newPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.annotationTitle
                        
                        // Navigasyonu yani Harita appini acma
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    // Core Data'dan veri cekme, ekleme
    func addData() {
        if selectedName != "" {
            // Core Data'dan verileri cek
            if let uuidString = selectedId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            
                            if let name = result.value(forKey: "name") as? String {
                                annotationTitle = name
                                if let note = result.value(forKey: "note") as? String {
                                    annotationSubtitle = note
                                    if let latitude = result.value(forKey: "latitude") as? Double {
                                        annotationLatitude = latitude
                                        if let longitude = result.value(forKey: "longitude") as? Double {
                                            annotationLongitude = longitude
                                            // Pin ekleme
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            nameTextFields.text = annotationTitle
                                            notesTextField.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation() // Konum guncellemesi durdur
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print("Error")
                }
            }
        } else {
            // Veri ekleme
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        newLocation.setValue(nameTextFields.text, forKey: "name")
        newLocation.setValue(notesTextField.text, forKey: "note")
        newLocation.setValue(selectedLatitude, forKey: "latitude")
        newLocation.setValue(selectedLongitude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Saved")
        } catch {
            print("Error")
        }
        //MARK: Veriyi girdikten sonra kaydet butonuna basildiginda ListView'a yonlendirmek icin
        NotificationCenter.default.post(name: NSNotification.Name("newLocationCreated"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}
