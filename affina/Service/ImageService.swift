//
//  ImageService.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/03/2023.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImageService {
    
    func upload(image: Data, to url: Alamofire.URLRequestConvertible, params: [String: Any], imageKey: String = "file", completion: @escaping (Result<APIResponse<LinkData>, Error>) -> Void) {
        let manager = AF
        manager.sessionConfiguration.timeoutIntervalForRequest = 60
        
        manager.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                        if let num = element as? Int {
                            let value = "\(num)"
                            multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
            }
            multiPart.append(image, withName: imageKey, fileName: "file.png", mimeType: "image/png")
        }, with: url)
        .uploadProgress(queue: .main, closure: { progress in
            //Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response { response in
            switch response.result {
                case .success(let data):
                    guard let result = try? JSONDecoder().decode(APIResponse<LinkData>.self, from: data!) else {
                        completion(.failure(NSError()))
                        return
                    }
                    completion(.success(result))
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    if error._code == NSURLErrorTimedOut {
                        print("Request timeout!")
                    }
                    completion(.failure(error))
                    break
            }
        }
    }
    
    func uploadMultiImages(images: [Data], to url: Alamofire.URLRequestConvertible, params: [String: Any], imageKey: String = "file", completion: @escaping (Result<APIResponse<LinkImagesData>, ApiError>) -> Void) {
        let manager = AF
        manager.sessionConfiguration.timeoutIntervalForRequest = 60
        
        manager.upload(multipartFormData: { multiPart in
            for (key, value) in params {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                if let temp = value as? NSArray {
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multiPart.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                        if let num = element as? Int {
                            let value = "\(num)"
                            multiPart.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                }
            }
            for (i, image) in images.enumerated() {
                multiPart.append(image, withName: "\(imageKey)\(i)", fileName: "file\(i).png", mimeType: "image/png")
            }
        }, with: url)
        .uploadProgress(queue: .global(qos: .background), closure: { progress in
            //Current upload progress of file
            Logger.Logs(message: "Upload Progress: \(progress.fractionCompleted)")
        })
        .response { response in
            switch response.result {
                case .success(let data):
                    let json = try? JSON(data: data!, options: .fragmentsAllowed) // For debug logging
                    Logger.Logs(message: json)
                    guard let result = try? JSONDecoder().decode(APIResponse<LinkImagesData>.self, from: data!) else {
                        // Error code 413
                        completion(.failure(ApiError.invalidData(ApiError.otherError, data)))
                        return
                    }
                    
                    completion(.success(result))
                    break
                case .failure(let error):
                    Logger.Logs(event: .error, message: error)
                    completion(.failure(ApiError.otherError))
                    break
            }
        }
    }
    
}
