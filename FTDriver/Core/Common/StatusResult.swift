//
//  StatusResult.swift
//  FTDriver
//
//  Created by Tan Dat on 8/9/24.
//

import Foundation
import Alamofire

public struct StatusResult: Error {
    public var message:String
    public var statusCode:Int
    
    public init (message:String, statusCode:Int) {
        self.message = message
        self.statusCode = statusCode
    }
    
    var description: String {
        return "message: \(message), statusCode: \(statusCode)"
    }
    
//    static let accessTokenExpired = HiFPTStatusResult(message: "", statusCode: HiFPTStatusCode.AUTHEN_EXPIRE_TOKEN.rawValue)
    public func isNoInternetError() -> Bool {
        return self.statusCode == StatusCode.NO_INTERNET.rawValue
    }
    
    public func isNoConnectionError() -> Bool {
        return self.statusCode == StatusCode.CANNOT_CONNECT_TO_HOST.rawValue || self.statusCode == StatusCode.NETWORK_CONNECTION_LOST.rawValue
    }
    
    public func isInAppOtpBackError() -> Bool {
        return self.statusCode == StatusCode.IN_APP_AUTH_OTP_BACK.rawValue
    }
    
    static let noInternetError = StatusResult(message: "Mất kết nối internet, vui lòng kiểm tra kết nối và thử lại.", statusCode: StatusCode.NO_INTERNET.rawValue)
    static let noConnectionError = StatusResult(message:"Mất kết nối internet, vui lòng kiểm tra kết nối và thử lại.", statusCode: StatusCode.NETWORK_CONNECTION_LOST.rawValue)
    static let parseDataError = StatusResult(message: "Ứng dụng hiện đang gặp sự cố hiển thị do lỗi từ máy chủ, vui lòng thử lại sau.", statusCode: StatusCode.CLIENT_ERROR.rawValue)
    static let inAppOtpBackError = StatusResult(message: "", statusCode: StatusCode.IN_APP_AUTH_OTP_BACK.rawValue)
    static let authenticationRequired = StatusResult(message: "Authentication is required to access the resource.", statusCode: StatusCode.AUTHENICATION_REQUIRED.rawValue)
}

enum AuthenApiError: Error {
    case accessTokenExpired
    case refreshTokenExpired(message: String)
    case forceUpdate(message: String)
    case needOTP(authCode: String)
    case needDirection
}

extension AFError {
    func asInAppOtpBack() -> StatusResult? {
        if case AFError.requestRetryFailed(let retryError, _) = self,
           let statusResult = retryError as? StatusResult,
           statusResult.isInAppOtpBackError() {
            return .inAppOtpBackError
        } else {
            return nil
        }
    }
    
    func isNoInternetError() -> Bool {
        if case AFError.sessionTaskFailed(let error) = self,
           error._code == StatusCode.NO_INTERNET.rawValue { // case not retry
            return true
        } else if case AFError.requestRetryFailed(let retryError, _) = self,
                  case AFError.sessionTaskFailed(let sessionTaskErr) = retryError,
                  sessionTaskErr._code == NSURLErrorNotConnectedToInternet { // case retry
            return true
        } else {
            return false
        }
    }
    
    func isNoConnectionError() -> Bool {
        if case AFError.sessionTaskFailed(let error) = self,
           (error._code == StatusCode.CANNOT_CONNECT_TO_HOST.rawValue || error._code == StatusCode.NETWORK_CONNECTION_LOST.rawValue) {
            return true
        } else if case AFError.requestRetryFailed(let retryError, _) = self,
                  case AFError.sessionTaskFailed(let error) = retryError,
                  (error._code == StatusCode.CANNOT_CONNECT_TO_HOST.rawValue || error._code == StatusCode.NETWORK_CONNECTION_LOST.rawValue) {
            return true
        } else {
            return false
        }
    }
    
    func asNoInternetError() -> StatusResult? {
        if isNoInternetError() {
            return .noInternetError
        } else {
            return nil
        }
    }
    
    func asNoConnectionError() -> StatusResult? {
        if isNoConnectionError() {
            return .noConnectionError
        } else {
            return nil
        }
    }
}

public enum StatusCode: Int {
    init(_ type: Int) {
        if let type = StatusCode(rawValue: type) {
            self = type
        } else {
            self = .UNDEFINED
        }
    }
    
    case UNDEFINED = -9999
    case CLIENT_ERROR = -1
    case IN_APP_AUTH_OTP_BACK = 999
    case SUCCESS = 0
    case AUTHEN_EXPIRE_TOKEN = 10403
    case AUTHEN_EXPIRE_REFRESH_TOKEN = 38015
    case FORCE_UPDATE = 50000
    case AUTHEN_NEED_OTP = 10005
    case AUTHEN_NEED_DIRECTION = 10006
    
    
    /// Login error need to pop view controller
    case AUTH_ENTER_PASS_FAIL = 38043
    case OTP_WRONG = 38009
    case PASS_WRONG = 38010
    case OTP_WRONG_LOCKED = 38014
    case PASS_LOCKED = 38028
    case OLD_PASS_WRONG = 38029
    case AUTH_CODE_EXPIRE_NEED_GO_TO_LOGIN = 38031
    
    case BIOMETRIC_EXPIRE = 38021 //Token sinh trắc học hết hạn hoặc tài khoản cũ chưa khởi tạo mật khẩu.
    
    /// A connection could not be established to the host.
    case CANNOT_CONNECT_TO_HOST = -1004
    
    /// The network connection was lost during the transfer.
    case NETWORK_CONNECTION_LOST = -1005
    
    /// The device is not connected to the internet.
    case NO_INTERNET = -1009
    case AUTHENICATION_REQUIRED = -1013
}

