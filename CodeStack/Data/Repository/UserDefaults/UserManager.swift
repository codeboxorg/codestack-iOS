//
//  UserDefaultManager.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/08.
//

import Foundation


@propertyWrapper
struct UserDefault<T> {
    let key: String
    
    init(key: String) {
        self.key = key
    }
    
    var wrappedValue: T? {
        get { UserDefaults.standard.object(forKey: key) as? T }
        set { UserDefaults.standard.set(newValue, forKey: key)}
    }
}

final class UserManager {
    
    static var shared = UserManager()
    
    var profile: User {
        get {
            return User(userName: UserManager.userName,
                        nickName: UserManager.nickName,
                        email: UserManager.email ,
                        profileImage: UserManager.profileImage)
        }
    }
    
    var tokenInfo: TokenInfo {
        get {
            return TokenInfo(expiresIn: UserManager.expiresIn,
                             tokenType: UserManager.tokenType)
        }
    }
    
    private init() {}
    
    // MARK: - User Profile
    @UserDefault(key: UserManagerKey.userName.rawValue)
    static var userName: String?
    
    @UserDefault(key: UserManagerKey.nickName.rawValue)
    static var nickName: String?
    
    @UserDefault(key: UserManagerKey.email.rawValue)
    static var email: String?
    
    @UserDefault(key: UserManagerKey.profileImage.rawValue)
    static var profileImage: String?

    @UserDefault(key: UserManagerKey.expiresIn.rawValue)
    static var expiresIn: TimeInterval?
    
    @UserDefault(key: UserManagerKey.tokenType.rawValue)
    static var tokenType: String?
}

extension UserManager {
    
    enum UserManagerKey: String, CaseIterable {
        case userName
        case nickName
        case email
        case profileImage
        case problemCalendar
        case year
        case expiresIn
        case tokenType
    }
    
    func saveUser(with user: User) {
        UserManager.userName = user.username
        UserManager.nickName = user.nickname
        UserManager.email = user.email
        UserManager.profileImage = user.profileImage
    }
    
    func saveTokenInfo(with token: TokenInfo) {
        UserManager.tokenType = token.tokenType
        UserManager.expiresIn = token.expiresIn
    }
    
    func logout(completion: @escaping () -> Void) {
        
        UserManagerKey.allCases.forEach { key in
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        
        //TODO: logout 시 keychain 에 저장된 토큰 제거 -> 컴플리션 호출 완료
        completion()
    }
    
    func logUserInfo() {
        
        let log = """
        \n-------------------- 💡 User Log 💡 --------------------
        Profile: \(profile)
        Access Token: \(KeychainItem.currentAccessToken)
        Refresh Token: \(KeychainItem.currentRefreshToken)
        ----------------------- 💡 End Log 💡 -----------------------
        """
        Log.debug(log)
    }
}
