//
//  User.swift
//  On The Map
//
//  Created by Michael Kroth on 11/11/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation

struct User {
    
    var firstName: String = ""
    var lastName: String = ""
    var uniqueKey = ""
    var hasLocation = false
    var latitude = 0.0
    var longitude = 0.0
    var mediaUrl: String? = ""
    var mapString = ""
    var objectID = ""
    
//    init(user: NSDictionary){
//        if let firstName = user["firstName"] as? String{
//            self.firstName = firstName
//        }
//        if let lastname = user["lastName"] as? String {
//            self.lastName = lastname
//        }
//        if let uniqueKey = user["key"] as? String {
//            self.uniqueKey = uniqueKey
//        }
//
//    }
//    
//    init(){
//        self.firstName = ""
//        self.lastName = ""
//        self.uniqueKey = ""
//    }
}
