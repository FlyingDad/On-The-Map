//
//  StudentTableViewController.swift
//  On The Map
//
//  Created by Michael Kroth on 10/30/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {

    var students: [Student] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).students
    }
    
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentTableViewCell") as! StudentTableViewCell
        let student = students[indexPath.row]
        cell.name.text = student.firstName + " " + student.lastName
        cell.mapString.text = student.mapString
        
        // Gray pin for invalid URL, Blue pin for valid URL
        if let url = NSURL(string: student.mediaURL) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                cell.pinImage.image = UIImage(named: "MapPinforTable")
            } else {
                cell.pinImage.image = UIImage(named: "MapPinNoUrl")
            }
        } else {
            cell.pinImage.image = UIImage(named: "MapPinNoUrl")
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = students[indexPath.row].mediaURL
        let app = UIApplication.sharedApplication()
        guard let studentUrl = NSURL(string: url) else {
            print("Invalid URL: \(students[indexPath.row].mediaURL)")
                return
            }
        if app.canOpenURL(studentUrl) {
            app.openURL(studentUrl)
        } else {
            print("Unable to open \(studentUrl)")
        }
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        
        // create view on top of table and show activity indicator
        let refreshView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height))
        refreshView.backgroundColor = UIColor.whiteColor()
        refreshView.alpha = 0.75
        self.view.addSubview(refreshView)
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        activityIndicator.center = CGPointMake(self.tableView.frame.size.width / 2, self.tableView.frame.size.height / 3)
        refreshView.addSubview(activityIndicator)
    
        UdacityClient.sharedInstance().getStudentLocations { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                    refreshView.removeFromSuperview()
                }
            } else {
                self.displayAlert("Alert", message: "Unable to update student data", action: "Dismiss")
                refreshView.removeFromSuperview()
            }
        }
        
    }
    
    @IBAction func logoutPressed(sender: AnyObject) {
        let logoutAlert = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        logoutAlert.addAction(cancelAction)
        let logoutAction = UIAlertAction(title: "Logout", style: .Destructive, handler: { (UIAlertAction) in
            UdacityClient.sharedInstance().deleteSession()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        logoutAlert.addAction(logoutAction)
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(logoutAlert, animated: true, completion: nil)
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
