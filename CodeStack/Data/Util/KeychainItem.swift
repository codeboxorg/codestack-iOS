//
//  KeychainService.swift
//  CodeStack
//
//  Created by 박형환 on 2023/07/06.
//

import Foundation





enum AuthServiceKey: String{
    case bundle = "kr.co.codestack.ios"
}

enum TokenType: String{
    case access = "access_token"
    case refresh = "refresh_token"
}


struct KeychainItem {
    
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
    init(service: AuthServiceKey, account: TokenType) {
        self.service = service
        self.account = account
    }
    
    
    // MARK: Keychain access
    func readItem() throws -> String {
        /*
         Build a query to find the item that matches the service, account
         */
        var query = KeychainItem.query(account: account, service: service)
        
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        
        let status = withUnsafeMutablePointer(to: &queryResult) {
            Log.debug("isMainThread: \(Thread.current.isMainThread)")
            return SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        
        if let existing = queryResult as? [String : AnyObject]{
            if let string = existing[kSecValueData as String]{
                let data = string as? Data
                let testData = String(data: data!, encoding: .utf8)
                Log.debug("token: \(String(describing: testData))")
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
    
    
    func saveItem(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        Log.debug("save ItemThread: \(Thread.isMainThread)")
        
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
    func deleteItem() throws {
        let query = KeychainItem.query(account: account, service: service)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }
    
}

//MARK: - KeychainItem static func

extension KeychainItem{
    
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
    
    static func saveAccessToken(access: ReissueAccessToken) throws {
        do{
            try KeychainItem(service: .bundle, account: .access).saveItem(access.accessToken)
        }catch{
            Log.error("Access Token 저장 실패")
            throw TokenAcquisitionError.storeKeychainFailed
        }
    }
    
    
    static func saveTokens(access: String,refresh: String) {
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
    
    static var currentAccessToken: String {
        do{
            let accessToken = try KeychainItem(service: .bundle, account: .access).readItem()
            return accessToken
        }catch{
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
}
