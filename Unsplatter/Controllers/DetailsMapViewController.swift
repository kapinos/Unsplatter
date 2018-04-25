//
//  DetailsMapViewController.swift
//  Unsplatter
//
//  Created by Anastasia on 4/25/18.
//  Copyright © 2018 Anastasia. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class DetailsMapViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private  weak var mapView: MKMapView!
    
    // MARK: - Properties
    var photoDetails: PhotoDetails?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let details = photoDetails, let title = details.location?.title else { return }
        self.title = title
        configureMapAndAnnotation()
    }
}

// MARK: - MKMapViewDelegate
extension DetailsMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        
        guard let imageUrl = photoDetails?.urls?.thumb else { return annotationView }
        
        let leftIconView = UIImageView(frame: CGRect(x: 0, y: 0, width: Constants.pinImageSize, height: Constants.pinImageSize))
        leftIconView.contentMode = .scaleAspectFill
        
        Alamofire.request(imageUrl).responseImage { response in
            guard let image = response.result.value else { return }
            DispatchQueue.main.async {
                leftIconView.image = image
                annotationView?.leftCalloutAccessoryView = leftIconView
                annotationView?.pinTintColor = .orange
            }
        }
        return annotationView
    }
}

// MARK: - Private
private extension DetailsMapViewController {
    func configureMapAndAnnotation() {
        if let photo = photoDetails,
            let location  = photo.location,
            let position  = location.position,
            let latitude  = position.latitude,
            let longitude = position.longitude  {
            
            let coordinates = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            
            // add annotation
            let annotation = MKPointAnnotation()
            
            guard let city = photo.location?.city, let country = photo.location?.country else { return }
            annotation.title = city
            annotation.subtitle = country
            annotation.coordinate = placemark.coordinate
            
            // display the annotation
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
            
            let regionDistance:CLLocationDistance = 10000
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            mapView.setRegion(regionSpan, animated: true)
        }
    }
}
