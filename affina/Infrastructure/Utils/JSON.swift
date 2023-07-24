//
//  JSON.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 25/05/2022.
//

import Foundation

class Json {
    public static func parseDataToString(data: Any) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        guard let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as String? else {
            return ""
        }
        return jsonString
    }

//    public static func filterJson(_ data: Any) -> String {
//        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
//        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
//        return jsonString
//    }
    public static func filterJson<T>(_ data: T) -> String where T: (Codable){
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }

    public static func text2ArrayDict(_ text: String) -> [[String: Any]]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    public static func parseDataToDict(_ data: Data) -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            Logger.Logs(event: .error, message: "parseDataToDict FAIL with Error: \(error.localizedDescription)")
        }
        return nil
    }

    public static func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    public static func dictStringToString(_ dict: [String: String]) -> String {
        let json = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let content = String(data: json!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as String
        return content
    }

    public static func dictToString(_ dict: [String: Any]) -> String {
        let json = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let content = String(data: json!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))! as String
        return content
    }

    public static func arrayDictToString(_ arrayDict: [[String: Any]]) -> String {
        let stringDictionaries: [[String: Any]] = arrayDict.map { dictionary in
            var dict: [String: Any] = [:]
            for (key, value) in dictionary {
                dict[key] = value
            }
            return dict
        }

        var string = String()
        string.append("[")
        for i in stringDictionaries {
            string.append(Json.dictToString(i))
            string.append(",")
        }
        string = String(string.dropLast())
        string.append("]")
        return string
    }

    //Alias Func
    public static func json2DictArr(_ json: String?) -> [[String: Any]?]? {
        if (json != nil) {
            if let data = json!.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]?]
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
        }
        return nil
    }

    public static func text2Dict(_ text: String) -> [String: Any] {
        if let data = text.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return dict
                } else {
                    Logger.Logs(event: .error, message: "dict nil")
                }
            } catch {
                Logger.Logs(event: .error, message: "toDict FAIL with Error: \(error.localizedDescription)")
            }
        }
        return [:]
    }

    public static func json2Dict(_ json: String?) -> [String: Any]? {
        if (json != nil) {
            if let data = json!.data(using: .utf8) {
                do {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        return nil
    }

    public static func getCodeRespone(_ json: [String: Any]) -> String {
        if let jsonCode = json["code"] as? String {
            return jsonCode
        }
        return ""
    }

    public static func getDataRespone(_ json: [String: Any]) -> String {
        if let jsonCode = json["data"] as? String {
            return jsonCode
        }
        return ""
    }
}
