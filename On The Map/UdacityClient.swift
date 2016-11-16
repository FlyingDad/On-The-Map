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
    
    // User info. We get this if the user us submitting a new location
    var user = User()
    
    func getSessionId (userName: String, password: String, completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(withParameters: nil, parse: false, withPathExtension: UdacityClient.Methods.Session))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                completionHandlerForSession(success: false, errorString: "Session ID error: \(error)")
            }
            guard (error == nil) else {
                sendError("There was an error in your request:\(error)")
                return
            }
        
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if (response as? NSHTTPURLResponse)?.statusCode == 403 {
                    sendError("forbidden")
                } else {
                    sendError("Request returned status code other then 2xx: \(response as? NSHTTPURLResponse)?.statusCode)")
                }
                return
            }
            
            guard let  data = data else {
                sendError("No data was returned")
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
                sendError("Unable to get session results")
                return
            }
            guard let accountDict = resultsDict["account"] as? [String: AnyObject] else {
                sendError("Unable to get account dictionary")
                return
            }
            guard let sessionDict = resultsDict["session"] as? [String: AnyObject] else {
                sendError("Unable to get session dictionary")
                return
            }

            if let registered = accountDict["registered"] as? Bool{
                if registered {
                    if let sessionIDString = sessionDict["id"] as? String, key = accountDict["key"] as? String {
                        self.sessionID = sessionIDString
                        self.user.uniqueKey = key
                        completionHandlerForSession(success: true, errorString: nil)
                    }
                }
            } else {
                completionHandlerForSession(success: false, errorString: "Login failed")
            }
        }
        task.resume()
    }
    
    func deleteSession() {
        
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(withParameters: nil, parse: false, withPathExtension: UdacityClient.Methods.Session))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request as NSURLRequest) { data, response, error in
            if error != nil {
                print("Error")
            }
            guard let data = data else {
                print("Data error in deleteing session")
                return
            }
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            print(NSString(data: newData, encoding: NSUTF8StringEncoding)!)
        }
        task.resume()
    }
    
    func getStudentLocations(completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?order=-updatedAt")!)
        request.addValue(UdacityClient.HeaderValues.ParseID, forHTTPHeaderField: UdacityClient.HeaderFields.ParseAppID)
        request.addValue(UdacityClient.HeaderValues.RestApiKey, forHTTPHeaderField: UdacityClient.HeaderFields.ParseRestApiKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                print(error)
                completionHandlerForSession(success: false, errorString: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error in your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returned status code other then 2xx")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the session ID")
            }

            if let studentLocationArray = parsedResult["results"] as? [[String: AnyObject]] {
                // clear student array in case we are refreshing data
                (UIApplication.sharedApplication().delegate as! AppDelegate).students.removeAll()
                for eachStudent in studentLocationArray {
                    let newStudent = Student(student: eachStudent)
                    (UIApplication.sharedApplication().delegate as! AppDelegate).students.append(newStudent)
                }
                completionHandlerForSession(success: true, errorString: nil)
            } else {
                completionHandlerForSession(success: false, errorString: "Unable to create array from parsed results")
            }

        }
        task.resume()    
    }
    
    func getPublicUserInfo(userKey: String, completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/" + userKey)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                print(error)
                completionHandlerForSession(success: false, errorString: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error in your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returned status code other then 2xx")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the session ID")
            }
            
            if let user = parsedResult["user"] as? [String: AnyObject] {
                if let firstName = user["first_name"] as? String, lastName = user["last_name"] as? String {
                    self.user.firstName = firstName
                    self.user.lastName = lastName
                    completionHandlerForSession(success: true, errorString: nil)
                }
            } else {
                completionHandlerForSession(success: false, errorString: "Unable to get user name")
            }
        }
        task.resume()
    
    
    }
    
    // checks to see if the logged on user has already entered a location into the DB
    func getUserLocation(completionHandlerForSession: (success: Bool, errorString: String?) -> Void){

        let uniqueKey = "{\"uniqueKey\":\"" + self.user.uniqueKey + "\"}"
        var parameters = [UdacityClient.ParameterKeys.UniqueKeyWhere: uniqueKey]
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(withParameters: parameters, parse: true, withPathExtension: nil))
        print(request.URL)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                print(error)
                completionHandlerForSession(success: false, errorString: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error in your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returned status code other then 2xx")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse student location data")
            }

            guard let results = parsedResult["results"] as? [[String: AnyObject]]else {
                print("Error getting student location array")
                return
            }
            if results.count == 0 {
                self.user.hasLocation = false
            } else {
                if let objectId = results[0]["objectId"] as? String {
                    self.user.hasLocation = true
                    self.user.objectID = objectId
                    completionHandlerForSession(success: true, errorString: nil)
                }
            }
            
        }
        task.resume()
    }
    
    // This function posts a new location
    func postNewLocation(completionHandlerForSession: (success: Bool, errorString: String?) -> Void){    
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(withParameters: nil, parse: true, withPathExtension: nil))
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let httpBodyString = "{\"uniqueKey\": \"" + self.user.uniqueKey +
            "\", \"firstName\": \"" + self.user.firstName +
            "\", \"lastName\": \"" + self.user.lastName +
            "\", \"mapString\": \"" + self.user.mapString +
            "\", \"mediaURL\": \"" + self.user.mediaUrl! +
            "\", \"latitude\": " + String(self.user.latitude) +
            ", \"longitude\": " + String(self.user.longitude) + "}"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                completionHandlerForSession(success: false, errorString: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error in your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returned status code other then 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            
            do {
                // if we can parse json, assume success
                let _ = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                completionHandlerForSession(success: true, errorString: nil)
            } catch {
                sendError("Could not post student location")
            }
        }
        task.resume()
    }
    
    // This function updates an existing location
    func putNewLocation(completionHandlerForSession: (success: Bool, errorString: String?) -> Void){
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/" + self.user.objectID
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        request.HTTPMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBodyString = "{\"uniqueKey\": \"" + self.user.uniqueKey +
            "\", \"firstName\": \"" + self.user.firstName +
            "\", \"lastName\": \"" + self.user.lastName +
            "\", \"mapString\": \"" + self.user.mapString +
            "\", \"mediaURL\": \"" + self.user.mediaUrl! +
            "\", \"latitude\": " + String(self.user.latitude) +
            ", \"longitude\": " + String(self.user.longitude) + "}"
        request.HTTPBody = httpBodyString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            func sendError(error: String) {
                completionHandlerForSession(success: false, errorString: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error in your request:\(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Request returned status code other then 2xx: \((response as? NSHTTPURLResponse)?.statusCode))")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            
            do {
                // if we can parse json, assume success
                let _ = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                completionHandlerForSession(success: true, errorString: nil)
            } catch {
                sendError("Could not put student location")
            }

        }
        task.resume()
    }
    
    // create a URL from parameters
    private func udacityURLFromParameters(withParameters parameters: [String:AnyObject]? = nil, parse: Bool, withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.Scheme
        if parse {
            components.host = UdacityClient.Constants.ParseHost
            components.path = UdacityClient.URLPaths.Parse
        } else {
            components.host = UdacityClient.Constants.ApiHost
            components.path = UdacityClient.URLPaths.Api + (withPathExtension ?? "")
        }
        
        if parameters != nil {
            components.queryItems = [NSURLQueryItem]()
        
            for (key, value) in parameters! {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        return components.URL!
    }

    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
