//
//  ViewController.swift
//  Map_Route_Pins
//
//  Created by Zhora Babakhanyan on 9/2/22.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    let mapView: MKMapView = {
      let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plusButtonImage"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let addRouteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "add_Route"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let addResetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "trash"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    var annotationsArray = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setConstraints()
        
        let oLongTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongtapGesture(gestureRecogniazer:)))
        self.mapView.addGestureRecognizer(oLongTapGesture)
        
        self.addAdressButton.addTarget(self, action: #selector(self.addAdressButtonTapped) , for: .touchUpInside)
        self.addRouteButton.addTarget(self, action: #selector(self.addRouteButtonTapped) , for: .touchUpInside)
        self.addResetButton.addTarget(self, action: #selector(self.addResetButtonTapped) , for: .touchUpInside)
    }
    
    
// MARK: - Functions 
    @objc func handleLongtapGesture(gestureRecogniazer: UILongPressGestureRecognizer){
        if gestureRecogniazer.state != UIGestureRecognizer.State.ended{
            let touchLocation = gestureRecogniazer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
              makePins(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        }
    }
    
    func makePins(latitude : CLLocationDegrees , longitude : CLLocationDegrees){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        setupPlacemarkFromGesture(annotation: annotation)
    }
    
    @objc func addAdressButtonTapped() {
        alertAddAdress(title: "Add", placeholder: "Enter Address") { [self] (text) in
            setupPlacemark(addressPlace: text)
        }
    }
    
    @objc func addRouteButtonTapped() {
        for index in 0...annotationsArray.count - 2 {
            createDirectionRequest(startCordinate: annotationsArray[index].coordinate,
                                   destionationCoordinate: annotationsArray[index + 1].coordinate)
        }
        mapView.showAnnotations(annotationsArray, animated: true)
    }
    
    @objc func addResetButtonTapped() {
        mapView.removeAnnotations(mapView.annotations)
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        annotationsArray = [MKPointAnnotation]()
        
        addResetButton.isHidden = true
        addRouteButton.isHidden = true
    }
    
    private func setupPlacemark(addressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { [self] (placemarks, error) in
            if let error = error {
                print(error)
               alertError(title: "Error", message: "Server Not available. Try to add one more time")
               return
            }
            
            guard let placemarks = placemarks else {return}
     
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(addressPlace)"
            guard let placemarkLocation = placemark?.location else {return}
            annotation.coordinate  = placemarkLocation.coordinate
            
            self.annotationsArray.append(annotation)
        
            if self.annotationsArray.count > 2 {
                self.addResetButton.isHidden = false
                self.addRouteButton.isHidden = false
            }
            self.mapView.showAnnotations(self.annotationsArray, animated: true)
        }
    }
    
    
    func setupPlacemarkFromGesture (annotation: MKPointAnnotation){
        self.annotationsArray.append(annotation)
        if self.annotationsArray.count > 2 {
            self.addResetButton.isHidden = false
            self.addRouteButton.isHidden = false
        }
        self.mapView.showAnnotations(self.annotationsArray, animated: true)
    }
    
    private func createDirectionRequest(startCordinate: CLLocationCoordinate2D, destionationCoordinate: CLLocationCoordinate2D){
        let startLocation = MKPlacemark(coordinate: startCordinate)
        let destinationLocation = MKPlacemark(coordinate: destionationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let directtion = MKDirections(request: request)
        directtion.calculate { (response, error) in
           
            if let error = error {
                print(error)
                return
            }
      
            guard let response = response else {
                self.alertError(title: "Error", message: "Direction is not available")
                return
            }
     
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            
            self.mapView.addOverlay(minRoute.polyline)
            
        }
    }
}


// MARK: - Map View Delegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}


// MARK: - Set Constraints
extension ViewController {
    func setConstraints(){
        // Map View
        self.view.addSubview(self.mapView)
        NSLayoutConstraint.activate([
            self.mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            self.mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            self.mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            self.mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        // Address Button
        self.mapView.addSubview(addAdressButton)
        NSLayoutConstraint.activate([
            self.addAdressButton.topAnchor.constraint(equalTo: self.mapView.topAnchor, constant: 50),
            self.addAdressButton.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -20),
            self.addAdressButton.heightAnchor.constraint(equalToConstant: 60),
            self.addAdressButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        // Route Button
        self.mapView.addSubview(addRouteButton)
        NSLayoutConstraint.activate([
            self.addRouteButton.topAnchor.constraint(equalTo: self.mapView.topAnchor, constant: 50),
            self.addRouteButton.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor, constant: 20),
            self.addRouteButton.heightAnchor.constraint(equalToConstant: 60),
            self.addRouteButton.widthAnchor.constraint(equalToConstant: 60)
        ])
        
        // Reset Button
        self.mapView.addSubview(addResetButton)
        NSLayoutConstraint.activate([
            self.addResetButton.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: -50),
            self.addResetButton.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -20),
            self.addResetButton.heightAnchor.constraint(equalToConstant: 60),
            self.addResetButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
}

