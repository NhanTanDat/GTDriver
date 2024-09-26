//
//  Endpoint.swift
//  FTDriver
//
//  Created by Tan Dat on 8/9/24.
//

import UIKit
import Alamofire

public struct Endpoint {
    public var url: URL
    public var errorCode: String?
    
    public init(endpointName:String, errorCode: String? = nil) {
    
        let theUrl = URL(string: "localhost:5001/api/drivers/register")
        if theUrl == nil {
            fatalError("URL or Endpoint not valid")
        }
        self.url = theUrl!
        self.errorCode = errorCode
    }
    
    
    public init(rawUrl: String, errorCode: String? = nil) {
        let theUrl = URL(string: rawUrl)
        if theUrl == nil {
            fatalError("URL or Endpoint not valid")
        }
        self.url = theUrl!
        self.errorCode = errorCode
    }
}


