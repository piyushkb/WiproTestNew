//
//  ResponseHandler.swift
//  ImageInTableDemo
//
//  Created by Nitu Kumari on 25/02/20.
//  Copyright © 2020 apple. All rights reserved.
//

import Foundation
enum APIResponse<String>{
    case success
    case failure(String)
}

public enum ResponseStatus:String {
    case success
    case authenticationError = "You need to be authenticated first"
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated"
    case failed = "You're not connected to the internet. Check your Internet Connection and try again"
    case noData = "Response returned with no data to decode"
    case unableToDecode = "We could not decode the response"
    case internalServerError = "Something went wrong, Please try again later"
    case sessionExpire = "Your session expired due to inactivity. Please login again"
    case timeout = "Please respond within '2' minutes to continue."
    case generic = "We have encountered an error"
    case permission = "Object view permission not allowed"
    
}
class ResponseStatusHandler: NSObject {
    
    static func handleNetworkResponse(_ response: HTTPURLResponse) -> APIResponse<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(ResponseStatus.internalServerError.rawValue)
        case 501...599: return .failure(ResponseStatus.badRequest.rawValue)
        case 600: return .failure(ResponseStatus.outdated.rawValue)
        default: return .failure(ResponseStatus.failed.rawValue)
        }
    }
}
