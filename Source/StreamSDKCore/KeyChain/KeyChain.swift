//
//  KeyChain.swift
//  StreamSDKCore
//
//  Created by Mike Hall on 22/02/2021.
//

import Security
import Foundation
/**
 Provides secure access to the iOS Keychain for storing user information
 */
public class KeyChain {

    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]
        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    /**
     Totally removes a KeyChain entry for the current application
     * @param key The key (id) of the entry to remove
     */
    public class func remove(key: String) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key] as [String : Any]
        return SecItemDelete(query as CFDictionary)
    }
    
    /**
     Adds a String type KeyChain entry for the current application
     * @param key The key (id) of the entry to add
     * @param data The data to add
     */
    public class func store(key: String, data: String) -> OSStatus? {
            if let storedData = data.data(using: .utf8){
       return KeyChain.save(key: key, data: storedData)
            }
        return nil
    }
    
    /**
     Adds an Integer type KeyChain entry for the current application
     * @param key The key (id) of the entry to add
     */
    public class func store(key: String, data: Int) -> OSStatus {
       return KeyChain.save(key: key, data: Data(from: data))
    }
    
    /**
     Returns a String type KeyChain entry for the current application
     * @param key The key (id) of the entry to return
     */
    public class func retrieveString(key: String) -> String? {
        if let data = KeyChain.load(key: key){
        return String(data: data , encoding: .utf8)
        }
        return nil
    }
    
    /**
      Returns an Integer type KeyChain entry for the current application
     * @param key The key (id) of the entry to return
     */
    public class func retrieveInt(key: String) -> Int? {
        return KeyChain.load(key: key)?.to(type: Int.self)
    }
    
    
    
}

extension Data {
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}
