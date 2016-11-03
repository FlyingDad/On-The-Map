//
//  LoginViewController.swift
//  On The Map
//
//  Created by Michael Kroth on 10/27/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction func loginBtnPressed(sender: AnyObject) {
        
        // MARK: UNCOMMENT FOR FINAL
        /*
        if loginEmail.text == "" || loginPassword.text == "" {
            print("Empty login or password field")
            let alert = UIAlertController(title: "Alert", message: "Invalid Email or Password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        */
        activityIndicator.alpha = 1.0
        activityIndicator.startAnimating()
        
        UdacityClient.sharedInstance().getSessionId(loginEmail.text!, password: loginPassword.text!){ (success, errorString) -> () in
            
            if success {
                self.stopActivityIndicator()
                //var controller: MapViewController
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                
                // put a popup alert here
                print(errorString)
                self.stopActivityIndicator()
            }
        }

    }
    
    func stopActivityIndicator() -> Void {
        let q = dispatch_get_main_queue()
        dispatch_async(q) { 
            self.activityIndicator.stopAnimating()
        }
    }
}
