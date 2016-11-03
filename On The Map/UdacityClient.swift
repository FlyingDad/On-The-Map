//
//  UdacityClient.swift
//  On The Map
//
//  Created by Michael Kroth on 11/1/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    // MARK: Properties
    // shared session
    var session = NSURLSession.sharedSession()
    
    // authentication state
    var sessionID: String? = nil
    
    
    
    /*
    // MARK: Properties
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // configuration object
    var config = TMDBConfig()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    */
    
    /* Steps for authentication
    1. https://www.udacity.com/api/session
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.HTTPBody = "{\"udacity\": {\"username\": \"account@domain.com\", \"password\": \"********\"}}"
    2.
 
 */
    
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
                displayError("Request returned status code other then 2xx")
                return
            }
            
            guard let data = data else {
                displayError("No data was returned")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            // print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the session ID")
            }

            if let resultsDict = parsedResult as? [String: AnyObject] {
                if let sessionDict = resultsDict["session"] as? [String: AnyObject] {
                    if let sessionIDString = sessionDict["id"] as? String {
                        self.sessionID = sessionIDString
                        completionHandlerForSession(success: true, errorString: nil)
                    } else {
                        completionHandlerForSession(success: false, errorString: "Login failed")
                    }
                }
                
            }
        }
        task.resume()
        
        /* Response
         {
         "account":{
         "registered":true,
         "key":"3903878747"
         },
         "session":{
         "id":"1457628510Sc18f2ad4cd3fb317fb8e028488694088",
         "expiration":"2015-05-10T16:48:30.760460Z"
         }
         }
         */
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
