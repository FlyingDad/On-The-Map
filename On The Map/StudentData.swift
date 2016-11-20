//
//  StudentData.swift
//  On The Map
//
//  Created by Michael Kroth on 11/17/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation

class StudentData {
    
    var students = [Student]()
    
    class func sharedInstance() -> StudentData {
        struct Singleton {
            static var sharedInstance = StudentData()
        }
        return Singleton.sharedInstance
    }
}
