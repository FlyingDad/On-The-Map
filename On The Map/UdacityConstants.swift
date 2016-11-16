//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Michael Kroth on 11/1/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let Scheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ParseHost = "parse.udacity.com"
    }
    
    struct URLPaths {
    
        // MARK: URL Paths
        static let Api = "/api"
        static let Parse = "/parse/classes/StudentLocation"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Session
        static let Session = "/session"
        static let PublicUserData = "/users"
    }
    
    // MARK: Header Values
    struct HeaderValues {
        static let ParseID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct HeaderFields {
        static let ParseAppID = "X-Parse-Application-Id"
        static let ParseRestApiKey = "X-Parse-REST-API-Key"
        
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let UniqueKeyWhere = "where"
        //=%7B%22uniqueKey%22%3A%22"
        //static let UniqueKeyEnd = "%22%7D"
        static let Limit = "limit"
    }
    
    // MARK: JSON Body Keys for HTTPBody
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firsName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // ????? Below?
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        
    }
    
}
