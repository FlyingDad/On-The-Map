//
//  Student.swift
//  On The Map
//
//  Created by Michael Kroth on 11/3/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation

struct Student {
    
    var firstName: String = ""
    var lastName: String = ""

    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mapString: String = "Not provided"
    var mediaURL: String = "No URL provided"
    
    var objectID: String = ""
    var uniqueKey: String = ""
    var createdDate: String = ""
    var updateDate: String = ""
    
    init(student: NSDictionary){
        if let firstName = student["firstName"] as? String{
            self.firstName = firstName
        }
        if let lastname = student["lastName"] as? String {
            self.lastName = lastname
        }
        if let latitude = student["latitude"] as? Double {
            self.latitude = latitude
        }
        if let longitude = student["longitude"] as? Double {
            self.longitude = longitude
        }
        if let mapString = student["mapString"] as? String {
            self.mapString = mapString
        }
        if let mediaURL = student["mediaUrl"] as? String {
            self.mediaURL = mediaURL
        }
        if let objectId = student["objectId"] as? String {
            self.objectID = objectId
        }
        if let uniqueKey = student["uniqueKey"] as? String {
            self.uniqueKey = uniqueKey
        }
        if let createdAt = student["createdAt"] as? String {
            self.createdDate = createdAt
        }
        if let updtaedAt = student["updatedAt"] as? String {
            self.updateDate = updtaedAt
        }
    }
}
