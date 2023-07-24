//
//  HashString.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 24/05/2022.
//

import Foundation
import CommonCrypto

class HashString {
    // MARK: MD5
    static public func encryptWithMD5(message: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = message.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    // MARK: RSA
    static public func encryptWithRsa(message: String) -> String? {
        guard let url = Bundle.main.url(forResource: API.networkEnvironment == .live ? "live-password-public" : "publicKeyBinary2", withExtension: "rsa") else { return "" }
        
        var dataPublicKey = Data()
        do {
            dataPublicKey = try Data(contentsOf: url)
        } catch {
            Logger.Logs(event: .error, message: "Public key error")
        }
        
        let data = dataPublicKey
        
        var attributes: CFDictionary {
            return [
                        kSecAttrKeyType: kSecAttrKeyTypeRSA,
                        kSecAttrKeyClass: kSecAttrKeyClassPublic,
                        kSecAttrKeySizeInBits: NSNumber(value: 2048),
                        kSecReturnPersistentRef: true as NSObject
                    ] as CFDictionary
        }
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            Logger.Logs(event: .error, message: "publicKeyBinary2 key is nil")
            print(error.debugDescription)
            return nil
        }
        return encrypt(string: message, publicKey: secKey)
    }

    static func encrypt(string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)

        var keySize   = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)

        // Encrypto  should less than key length
        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return nil }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
    }
}
