//
//  ParseCache.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 25/05/2022.
//

import Foundation

class ParseCache {
    public static func parseCacheToArray<T>(key: String, modelType: T.Type, completion: @escaping (Result<[T], Error>) -> Void) where T : Decodable {
        var resultList = [T]()
        
        if let cacheData = CacheManager.shared.getCacheData(key), let cacheString = cacheData.getJson() {
            guard let data = Json.text2ArrayDict(cacheString) else {
                completion(.failure(ErrorCustom.dataNil))
                return
            }
            do {
                for i in data {
                    let item = try JSONDecoder().decode(modelType, from: try JSONSerialization.data(withJSONObject: i, options: .prettyPrinted))
                    resultList.append(item)
                }
            } catch {
                completion(.failure(error))
                Logger.Logs(event: .error, message: error)
            }
        }
        completion(.success(resultList))
    }
    
    public static func parseCacheToItem<T>(key: String, modelType: T.Type, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        if let cacheData = CacheManager.shared.getCacheData(key), let cacheString = cacheData.getJson() {
            let data = Json.text2Dict(cacheString)
            do {
                let resultDict = try JSONDecoder().decode(modelType, from: try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted))
                completion(.success(resultDict))
            } catch {
                completion(.failure(error))
                Logger.Logs(event: .error, message: error)
            }
        }
    }
}
