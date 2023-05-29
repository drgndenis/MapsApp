//
//  ViewController.swift
//  MapsApp
//
//  Created by Denis DRAGAN on 27.05.2023.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
}
