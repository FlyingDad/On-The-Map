//
//  LoginViewController.swift
//  On The Map
//
//  Created by Michael Kroth on 10/27/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginEmail.delegate = self
        loginPassword.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func loginBtnPressed(sender: AnyObject) {

        if loginEmail.text == "" || loginPassword.text == "" {
            print("Empty login or password field")
            let alert = UIAlertController(title: "Alert", message: "Invalid Email or Password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()

        UdacityClient.sharedInstance().getSessionId(loginEmail.text!, password: loginPassword.text!){ (success, errorString) in
            
            if success {
                self.stopActivityIndicator()
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                // Login failed alert
                if errorString == "forbidden" {
                    self.displayAlert("Login failed", message: "Invalid Email or Password", action: "Try again")

                } else {
                    // Connection problem alert
                    self.displayAlert("Alert", message: "Failure to connect. Please check your internet connection", action: "Dismiss")
                }
                print(errorString)
                self.stopActivityIndicator()
            }
        }

    }
    
    @IBAction func createUdacityAccount(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com")!)
    }
    
    func displayAlert(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func stopActivityIndicator() -> Void {
        let q = dispatch_get_main_queue()
        dispatch_async(q) { 
            self.activityIndicator.stopAnimating()
        }
    }
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
}
