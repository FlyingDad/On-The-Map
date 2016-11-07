//
//  UdacityClient.swift
//  On The Map
//
//  Created by Michael Kroth on 11/1/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    // MARK: Properties
    // shared session
    var session = NSURLSession.sharedSession()
    
    var studentss: [Student] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).students
    }
    
    // authentication state
    var sessionID: String? = nil

    
    func getSessionId (userName: String, password: String, completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"mkroth65@gmail.com\", \"password\": \"Imstrong65\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        // MARK: UNCOMMENT FOR FINAL VERSION
        //request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func displayError(error: String) {
                print(error)
                completionHandlerForSession(success: false, errorString: error)
            }
            guard (error == nil) else {
                displayError("There was an error in your request:\(error)")
                return
            }
        
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if (response as? NSHTTPURLResponse)?.statusCode == 403 {
                    displayError("forbidden")
                } else {
                    displayError("Request returned status code other then 2xx: \(response as? NSHTTPURLResponse)?.statusCode)")
                }
                return
            }
            
            guard let data = data else {
                displayError("No data was returned")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the session ID")
            }

            guard let resultsDict = parsedResult as? [String: AnyObject] else {
                displayError("Unable to get session results")
                return
            }
            guard let accountDict = resultsDict["account"] as? [String: AnyObject] else {
                displayError("Unable to get account dictionary")
                return
            }
            guard let sessionDict = resultsDict["session"] as? [String: AnyObject] else {
                displayError("Unable to get session dictionary")
                return
            }

            if let registered = accountDict["registered"] as? Bool {
                if registered {
                    if let sessionIDString = sessionDict["id"] as? String {
                        self.sessionID = sessionIDString
                        completionHandlerForSession(success: true, errorString: nil)
                    }
                }
            } else {
                completionHandlerForSession(success: false, errorString: "Login failed")
            }
            
        }
        task.resume()
    }
    
    func getStudentLocations(completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt")!)
        request.addValue(UdacityClient.HeaderValues.ParseID, forHTTPHeaderField: UdacityClient.HeaderFields.ParseAppID)
        request.addValue(UdacityClient.HeaderValues.RestApiKey, forHTTPHeaderField: UdacityClient.HeaderFields.ParseRestApiKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func displayError(error: String) {
                print(error)
                completionHandlerForSession(success: false, errorString: error)
            }
            
            guard (error == nil) else {
                displayError("There was an error in your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                displayError("Request returned status code other then 2xx")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the session ID")
            }

            if let studentLocationArray = parsedResult["results"] as? [[String: AnyObject]] {
                
                for eachStudent in studentLocationArray {
                    let newStudent = Student(student: eachStudent)
                    (UIApplication.sharedApplication().delegate as! AppDelegate).students.append(newStudent)
                }
                completionHandlerForSession(success: true, errorString: nil)
            } else {
                completionHandlerForSession(success: false, errorString: "Unable to create array from parsed reults")
            }

        }
        task.resume()    
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
