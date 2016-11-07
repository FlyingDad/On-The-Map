//
//  StudentMapViewController.swift
//  On The Map
//
//  Created by Michael Kroth on 11/3/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var students: [Student] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).students
    }
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        UdacityClient.sharedInstance().getStudentLocations { (success, errorString) in
            if success {
                self.createAnnotationArray()
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotations(self.annotations)
                }
            } else {
                self.displayAlert("Alert", message: "Unable to retrieve map data", action: "Dismiss")
            }
        }
    }
    
    func createAnnotationArray () {
        for eachStudent in students {
            let lat = CLLocationDegrees(eachStudent.latitude)
            let long = CLLocationDegrees(eachStudent.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(eachStudent.firstName) \(eachStudent.lastName)"
            annotation.subtitle = eachStudent.mediaURL
            annotations.append(annotation)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                guard let studentUrl = NSURL(string: toOpen) else {
                    return
                }
                app.openURL(studentUrl)
            }
        }
    }
    
    func displayAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
