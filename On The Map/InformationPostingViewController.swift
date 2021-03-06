//
//  InformationPostingViewController.swift
//  On The Map
//
//  Created by Michael Kroth on 11/8/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
        
    @IBOutlet weak var studentLocation: UITextField!
    @IBOutlet weak var whereAreYouView: UIView!
    @IBOutlet weak var previewMapView: UIView!
    @IBOutlet weak var submitButton: SubmitButton!
    @IBOutlet weak var mediaUrl: UITextField!
    
    @IBOutlet weak var previewMap: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorPreview: UIActivityIndicatorView!
    
    var geocoder = CLGeocoder()
    var annotation = [MKPointAnnotation]()
    var coords: CLLocation?
    var coordsloc: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        previewMap.delegate = self
        studentLocation.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        activityIndicatorPreview.hidesWhenStopped = true
        activityIndicatorPreview.stopAnimating()
        whereAreYouView.hidden = false
        previewMapView.hidden = true
        studentLocation.becomeFirstResponder()
    }
    
    @IBAction func findOnMapPressed(sender: AnyObject) {
        guard let location = studentLocation.text where !location.isEmpty else {
            self.displayAlert("Alert", message: "Please enter a location", action: "Try again")
            return
        }
        activityIndicator.startAnimating()
        CLGeocoder().geocodeAddressString(location, completionHandler: {(placemarks, error)  -> Void in
            if error != nil {
                self.activityIndicator.stopAnimating()
                self.displayAlert("Alert", message: "Failed to get a location for your entry", action: "Try again")
                print("Geocode failed with error:“\(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                dispatch_async(dispatch_get_main_queue()) {
                let placemark = placemarks![0]
                self.activityIndicator.stopAnimating()
                self.focusOnMap(placemark)
                self.whereAreYouView.hidden = true
                self.previewMapView.hidden = false
            }}
        })
    }
    
    @IBAction func submitPressed(sender: AnyObject) {
        activityIndicatorPreview.startAnimating()
        // Get public info for user. We need the name and uniqueID
        UdacityClient.sharedInstance().getPublicUserInfo(UdacityClient.sharedInstance().user.uniqueKey) { (success, errorString) in
            if !success {
                print("Error getting public user information: \(errorString)")
                self.updateFailure()
            } else {
                // Successfully found user, now lets check if the user has a location in the DB
                UdacityClient.sharedInstance().getUserLocation() {(success, errorString) in
                    if !success {
                        print("Error geting student location data: \(errorString)")
                        self.updateFailure()
                    } else {
                        // Save mediaUrl that user entered
                        UdacityClient.sharedInstance().user.mediaUrl = self.mediaUrl.text ?? ""
                        
                        // No location found, so POST a new one
                        if !UdacityClient.sharedInstance().user.hasLocation {
                            UdacityClient.sharedInstance().postNewLocation({ (success, errorString) in
                                if !success {
                                    print("Error posting user location \(errorString)")
                                    self.updateFailure()
                                } else {
                                    // Diplay success alert
                                    self.activityIndicatorPreview.stopAnimating()
                                    let alert = UIAlertController(title: "Success", message: "Your information was posted successfully", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    }))
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                }
                            })
                        } else {
                           // Location found, so update (PUT) new location after alert
                            self.activityIndicatorPreview.stopAnimating()
                            let locationUpdateAlert = UIAlertController(title: "Previous location found!", message: "Do you want to update your information?", preferredStyle: UIAlertControllerStyle.Alert)
                            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (UIAlertAction) in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            })
                            locationUpdateAlert.addAction(cancelAction)
                            
                            let updateAction = UIAlertAction(title: "Update", style: .Destructive, handler: { (UIAlertAction) in
                                //put(update) new info for user here
                                self.activityIndicatorPreview.startAnimating()
                                UdacityClient.sharedInstance().putNewLocation({ (success, errorString) in
                                    if !success {
                                        print("Error putting user information \(errorString)")
                                        self.updateFailure()
                                    } else {
                                        self.updateSuccess()
                                    }
                                })
                            })
                            
                            locationUpdateAlert.addAction(updateAction)
                            dispatch_async(dispatch_get_main_queue()) {
                                self.presentViewController(locationUpdateAlert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateFailure(){
        self.activityIndicatorPreview.stopAnimating()
        let alert = UIAlertController(title: "Connection Error", message: "Please check your Internet connection", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func updateSuccess(){
        activityIndicatorPreview.stopAnimating()
        let alert = UIAlertController(title: "Success", message: "Your information was updated.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func focusOnMap(locationMark: CLPlacemark) {
        self.coords = locationMark.location
        // set user values
        UdacityClient.sharedInstance().user.mapString = locationMark.name ?? "Unknown"
        UdacityClient.sharedInstance().user.latitude = (locationMark.location?.coordinate.latitude)!
        UdacityClient.sharedInstance().user.longitude = (locationMark.location?.coordinate.longitude)!

        let span = MKCoordinateSpan(latitudeDelta: 0.02225, longitudeDelta: 0.02225)
        let region = MKCoordinateRegion(center: locationMark.location!.coordinate, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationMark.location!.coordinate
        previewMap.setRegion(region, animated: true)
        self.previewMap.addAnnotation(annotation)
    }
    
    func displayAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    // Getting rid of keyboard after hitting return
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        findOnMapPressed(submitButton)
        return false
    }
    
    // Getting rid of keyboard after touching outside inputs
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func cancelPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
