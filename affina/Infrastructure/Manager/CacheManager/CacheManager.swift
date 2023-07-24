//
//  CacheManager.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 13/05/2022.
//

import Foundation
import UIKit

class CacheData: NSObject {
    var json: String?
    
    override init() {
        super.init()
        json = ""
    }
    
    init(json: String?) {
        self.json = json
    }
    
    public func getJson() -> String? {
        return json
    }
}

class CacheManager {
    static let shared = CacheManager()

    private let imageCaches = NSCache<NSString, UIImage>()
    private var arrayCacheData: [String: CacheData]?
    private var arrayNormalData: [String: Any]
    
    var task = URLSessionDataTask()
    var session = URLSession.shared
    var otpFor: Int = 0
    
    private init() {
        self.arrayCacheData = [String: CacheData]()
        self.arrayNormalData = [String: Any]()
    }
    
    //insert cache by key
    public func insertCacheWithKey(_ key: String, _ cache: CacheData) {
        Logger.Logs(event: .info, message: "Insert Cache with KEY: \(key)\n Cache Data: \(cache)")
        
        arrayCacheData?.removeValue(forKey: key)
        arrayCacheData?.updateValue(cache, forKey: key)
    }
    
    //get cache by key
    public func getCacheData(_ key: String) -> CacheData? {
        let cache = CacheData()
        guard let data = arrayCacheData?[key] else {
            return cache
        }
        return data
    }
 
    //delete cache by key
    public func deleteCacheData(_ key: String) {
        arrayCacheData?.removeValue(forKey: key)
    }
    
    //determine cache exist
    func isExistCacheWithKey(_ key: String) -> Bool {
        return (arrayCacheData?[key]) != nil
    }
    
    public func clearAllCaches() {
        self.arrayCacheData?.removeAll()
        self.imageCaches.removeAllObjects()
    }
    
    // Image Caches
    func imageFor(url: URL, completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        if let imageInCache = self.imageCaches.object(forKey: url.absoluteString as NSString) {
            completionHandler(imageInCache, nil)
            return
        }

        self.task = self.session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, error)
                return
            }

            if let image = UIImage(data: data) {
                self.imageCaches.setObject(image, forKey: url.absoluteString as NSString)
                completionHandler(image, nil)
            }

        }

        self.task.resume()
    }
}
