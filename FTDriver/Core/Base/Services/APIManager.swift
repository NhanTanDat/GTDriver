//
//  APIManager.swift
//  FTDriver
//
//  Created by Tan Dat on 8/9/24.
//

import Alamofire
import SwiftyJSON

class APIManager {
    
    static var interceptor = AuthInterceptor(accessToken: "")
    static let shared = APIManager()
 
    static let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 10
        
        return Session(configuration: configuration)
    }()
    private let baseURL = "https://localhost:3000/"  // Thay đổi URL cơ sở của bạn
    
    static func logResponseForDebug(_ endPoint: URL, success data: Data?) {
        let output: String
        let resultJS = JSON(data as Any)
        if let data = data {
            if resultJS.type != .null {
                output = resultJS.rawString() ?? ""
            } else {
                output = String(data: data, encoding: .utf8) ?? ""
            }
        } else {
            output = ""
        }
        
        _ = """
        --- Response info ---
        ENDPOINT: \(endPoint.absoluteString)
        OUTPUT: \(output)
        ---------------------
        """
    }
    static func logRequestForDebug(_ endPoint: URL, _ mHeaders: HTTPHeaders, _ params: Parameters?) {
        var headerDic: [String : Any] = [:]
        for header in mHeaders {
            headerDic[header.name] = header.value
        }
        let headerJSON: String = headerDic.getStringJsonFromDic(option: [.prettyPrinted, .withoutEscapingSlashes]) ?? ""
        let requestJSON: String = (params ?? [:]).getStringJsonFromDic(option: [.prettyPrinted]) ?? ""
        let a = """
        --- Request info ---
        ENDPOINT: \(endPoint.absoluteString)
        HEADER: \(headerJSON)
        BODY: \(requestJSON)
        --------------------
        """
        print(a)
    }
    
    static func logResponseForDebug(_ endPoint: URL, fail error: Error) {
        let a = """
        --- Response info ---
        ENDPOINT: \(endPoint.absoluteString)
        ERROR: \(error)
        ---------------------
        """
       print(a)
    }
    
    static func generateHeader(optionalHeaders: HTTPHeaders?) -> HTTPHeaders {
        let language = "vi"
        var mHeaders:HTTPHeaders = [
            "lang": language,
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""
        ]
        
        if optionalHeaders != nil {
            optionalHeaders?.forEach({ item in
                mHeaders.add(item)
            })
        }
        return mHeaders
    }
    static func checkError(error:AFError, handlePopupNoInternet: @escaping (_ statusResult: StatusResult) -> Void, handlePopupOtherError: @escaping () -> Void) {
        if let noInternetError = error.asNoInternetError() {
            // show popup noInternet
            handlePopupNoInternet(noInternetError)
        } else if let noConnectionError = error.asNoConnectionError() {
            // show popup noInternet
            handlePopupNoInternet(noConnectionError)
        } else if error.asInAppOtpBack() != nil {
            // break
        } else {
            // show popup other error
            handlePopupOtherError()
        }
        
    }
    
    static func requestAPI(
        endPoint: URL,
        params: Parameters? = nil,
        signatureHeader: Bool,
        optionalHeaders: HTTPHeaders? = nil,
        showProgressLoading: Bool = true,
        vc: UIViewController? = nil,
        rawResult: Bool,
        noShowPopupError: Bool = false,
        methodHTTP: HTTPMethod = .post,
        errorCompletion: ((_ statusResult: Int)->())? = nil,
        acceptCompletion: @escaping () -> Void = {},
        cancelCompletion: (() -> Void)? = nil,
        customOtpHandler: ((_ otpStatusResult: StatusResult) -> Void)?,
        handlerTextContent: @escaping (_ dataJS: JSON?, _ textContent: JSON?, _ statusResult: StatusResult) -> () = { _, _, _ in },
        handler: @escaping (_ dataJS: JSON?, _ statusResult: StatusResult) -> ()
    ) {
        
        let mHeaders = generateHeader(optionalHeaders: optionalHeaders)
        
        logRequestForDebug(endPoint, mHeaders, params)
        
        let uuidStr = UUID().uuidString
        
        let _session = signatureHeader ? sessionManager : AF
        let autoRetryWhenOtpSuccess = customOtpHandler == nil
        
        _session
            .request(endPoint, method: methodHTTP, parameters: params, encoding: JSONEncoding.default, headers: mHeaders, interceptor: signatureHeader ? interceptor : nil)
            .response {[weak vc] dataResponse in
                DispatchQueue.main.async {
                    if showProgressLoading {
//                        HiFPTCore.shared.hideLoading()
                    }
                }
                
                
                switch dataResponse.result {
                case .success(let data):
                    logResponseForDebug(endPoint, success: data)
                    
                    let result = JSON(data as Any)
                    var stCode = StatusCode.CLIENT_ERROR.rawValue
                    if(result["statusCode"].type != .null){
                        stCode = result["statusCode"].intValue
                    }
                    
                    var dataJson:JSON? = nil
                    if result["data"].type != .null && !rawResult {
                        dataJson = JSON(result["data"])
                    } else if rawResult {
                        dataJson = result
                    }
                    
                    var textContent: JSON? = nil
                    if result["textContent"].null != NSNull() && !rawResult {
                        textContent = result["textContent"]
                    }
                    
                    let statusResult = StatusResult(message: result["message"].stringValue, statusCode: stCode)
                    
                    
                    switch stCode {
                    case StatusCode.AUTHEN_NEED_OTP.rawValue:
                        let authCode = result["authCode"].stringValue
//                        InAppAuthenManager.pushToAuthenInAppOtp(vc: vc, authCode: authCode, completion: customOtpHandler ?? { _ in })
                    case StatusCode.FORCE_UPDATE.rawValue:
                        DispatchQueue.main.async {
//                            HiFPTCore.shared.delegate?.showPopupForceUpdate(vc: vc, content: statusResult.message)
                        }
                    case StatusCode.CLIENT_ERROR.rawValue:
                        let parseDataError = StatusResult.parseDataError
                        if noShowPopupError {
                            handler(nil, parseDataError)
                            handlerTextContent(nil, nil, parseDataError)
                        } else {
//                            showPopupParseDataError(vc: vc, errorCode: endPoint.errorCode ?? "", acceptCompletion: acceptCompletion)
                            errorCompletion?(parseDataError.statusCode)
                        }
                    default:
                        handler(dataJson, statusResult)
                        handlerTextContent(dataJson, textContent, statusResult)
                    }
                    
                case .failure(let error):
                    logResponseForDebug(endPoint, fail: error)
                    if noShowPopupError {
                        let statusResult = StatusResult(message: error.localizedDescription, statusCode: error._code)
                        handler(nil, statusResult)
                        handlerTextContent(nil, nil, statusResult)
                    } else {
                        checkError(error: error) { statusResult in
                            // popup no internet
//                            showPopupNoInternet(vc: vc, errorCode: "\(endPoint.errorCode ?? "")_\(statusResult.statusCode)", acceptCompletion: acceptCompletion)
                            errorCompletion?(statusResult.statusCode)
                        } handlePopupOtherError: {
                            // popup other error
//                            showPopupOtherError(vc: vc, errorCode: "\(endPoint.errorCode ?? "")_\(error._code)", acceptCompletion: acceptCompletion)
                            errorCompletion?(error._code)
                        }
                    }
                }
            }
    }
}

// Định nghĩa lỗi API tùy chỉnh
enum APIError: Error {
    case networkError(Error)
    case serverError(statusCode: Int?)
    case decodingError
    
    init(statusCode: Int?, error: Error) {
        if let statusCode = statusCode, statusCode >= 400 && statusCode < 500 {
            self = .serverError(statusCode: statusCode)
        } else {
            self = .networkError(error)
        }
    }
}

extension Dictionary {
    func getStringJsonFromDic(option: JSONSerialization.WritingOptions = []) -> String? {
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: option
        ), let theJSONText = String(
            data: theJSONData,
            encoding: String.Encoding.utf8
        ) {
            return theJSONText
        }
        
        return nil
    }
}
