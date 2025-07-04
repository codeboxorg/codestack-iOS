//
//  KeychainService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/06.
//

import Foundation
import Global

public enum AuthServiceKey: String{
    case bundle = "kr.co.codestack.ios"
}

public enum TokenType: String{
    case access = "access_token"
    case refresh = "refresh_token"
    case idToken = "firebase_idToken"
    case fbRefreshToken = "firebase_refreshToken"
    case localId = "firebase_localId"
}

public struct KeychainItem {
    
    enum KeychainError: Error{
        case tokenEncodingError
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }
    
    
    let service: AuthServiceKey

    // MARK: -account is token (access_token,refresh_token)
    private(set) var account: TokenType
    
    // MARK: Init
    public init(service: AuthServiceKey, account: TokenType) {
        self.service = service
        self.account = account
    }
    
    
    // MARK: Keychain access
    public func readItem() throws -> String {
        /*
         Build a query to find the item that matches the service, account
         */
        var query = KeychainItem.query(account: account, service: service)
        
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        
        let status = withUnsafeMutablePointer(to: &queryResult) {
            return SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        
        if let existing = queryResult as? [String : AnyObject]{
            if let string = existing[kSecValueData as String]{
                let _ = string as? Data
                // let testData = String(data: data!, encoding: .utf8)
            }else{
                Log.error("키체인에 데이터 없음")
            }
        }
        
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        return password
    }
    
    
    public func saveItem(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // keychain에 존재하는지 확인
            try _ = readItem()
            
            // readItem으로 한번 읽어와 보니 이미 존재하여 update 한다.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            
            let query = KeychainItem.query(account: account, service: service)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            /*
             key chain에 데이터가 존재하지 않아서 add 해준다.
             */
            var newItem = KeychainItem.query(account: account, service: service)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // 데이터 추가
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // 에러핸들
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }
    
    /// token 제거
    public func deleteItem() throws {
        let query = KeychainItem.query(account: account, service: service)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
}

//MARK: - KeychainItem static func

public extension KeychainItem {
    
    /// Keychain을 위한 query 작성함수
    /// - Parameters:
    ///   - type: 토큰의 type access or refresh
    ///   - server: git,apple,email
    /// - Returns: query
    static func query(account: TokenType,
                      service: AuthServiceKey) -> [String: AnyObject]
    {
        let query: [String : AnyObject] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : service.rawValue as AnyObject,
            kSecAttrAccount as String: account.rawValue as AnyObject,
        ]
        return query
    }
    
    static func deleteToken() {
        do {
            try KeychainItem(service: .bundle, account: .access).deleteItem()
            try KeychainItem(service: .bundle, account: .refresh).deleteItem()
        } catch {
            Log.error("deleteToken error :\(error)")
        }
    }
    
    static func saveAccessToken(access: AsessToken) throws {
        do{
            try KeychainItem(service: .bundle, account: .access).saveItem(access.accessToken)
        }catch{
            Log.error("Access Token 저장 실패")
            throw TokenAcquisitionError.storeKeychainFailed
        }
    }
    
    static func saveTokens(access: String, refresh: String) {
        do{
            try KeychainItem(service: .bundle, account: .access).saveItem(access)
        }catch{
            Log.error("Access Token 저장 실패")
        }
        
        do{
            try KeychainItem(service: .bundle, account: .refresh).saveItem(refresh)
        }catch{
            Log.error("Refresh Token 저장 실패")
        }
    }
    
    
    static func saveFirebaseIDToken(idToken: String) {
        try? KeychainItem(service: .bundle, account: .idToken).saveItem(idToken)
    }
        
    static func saveFirebaseToken(idToken: String, refresh: String, localID: String) throws {
        do{
            try KeychainItem(service: .bundle, account: .idToken).saveItem(idToken)
            try KeychainItem(service: .bundle, account: .fbRefreshToken).saveItem(refresh)
            try KeychainItem(service: .bundle, account: .localId).saveItem(localID)
        }catch{
            Log.error("currentFBIdToken Token 저장 실패")
        }
    }
    
    static func deleteFirebaseToken() throws {
        do{
            try KeychainItem(service: .bundle, account: .idToken).deleteItem()
            try KeychainItem(service: .bundle, account: .fbRefreshToken).deleteItem()
            try KeychainItem(service: .bundle, account: .localId).deleteItem()
        }catch{
            Log.error("currentFBIdToken Token 저장 실패")
        }
    }
    
    static var currentAccessToken: String {
        do{
            let accessToken = try KeychainItem(service: .bundle, account: .access).readItem()
            return accessToken
        } catch {
            Log.debug("current AccessToken keychain에 없음")
            return ""
        }
    }
    
    static var currentRefreshToken: String{
        do{
            let refresh = try KeychainItem(service: .bundle, account: .refresh).readItem()
            return refresh
        }catch{
            Log.debug("current refreshToken keychain에 없음")
            return ""
        }
    }
    
    static var currentFBIdToken: String {
        do{
            let currentFBIdToken = try KeychainItem(service: .bundle, account: .idToken).readItem()
            return currentFBIdToken
        }catch{
            Log.debug("current AccessToken keychain에 없음")
            return ""
        }
    }
    
    static var currentFBRefreshToken: String {
        do{
            let currentFBIdToken = try KeychainItem(service: .bundle, account: .fbRefreshToken).readItem()
            return currentFBIdToken
        }catch{
            Log.debug("current AccessToken keychain에 없음")
            return ""
        }
    }
    
    static var currentFBLocalID: String {
        do{
            let currentFBIdToken = try KeychainItem(service: .bundle, account: .localId).readItem()
            return currentFBIdToken
        }catch{
            Log.debug("current AccessToken keychain에 없음")
            return ""
        }
    }
}
