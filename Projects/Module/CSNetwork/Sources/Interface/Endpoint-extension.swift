//
//  Endpoint-extension.swift
//  Data
//
//  Created by 박형환 on 1/17/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation

extension EndPoint {
    var firestoreBase: String {
        guard let base = Bundle.main.infoDictionary?["firestore_endpoint"] as? String
        else { return "" }
        return base
    }
    
    var judgeZeroLocalBase: String {
        guard let base = Bundle.main.infoDictionary?["Judge0APIURL"] as? String
        else { return "" }
        return base
    }
    
    var judgeZeroBase: String {
        guard let base = Bundle.main.infoDictionary?["judgezero_endpoint"] as? String
        else { return "" }
        return base
    }
    
    var judgeAPIKey: String {
        guard let base = Bundle.main.infoDictionary?["judgeZero_APIKey"] as? String
        else { return "" }
        return base
        
    }
    
    var firebaseAuthBase: String {
        guard let base = Bundle.main.infoDictionary?["firebase_annony_auth_endpoint"] as? String
        else { return "" }
        return base
    }
    
    var projectPath: String {
        guard let base = Bundle.main.infoDictionary?["firestore_project_path"] as? String
        else { return "" }
        return base
    }
    
    var storagePath: String {
        guard let base = Bundle.main.infoDictionary?["fireStorage_project_path"] as? String
        else { return "" }
        return base
    }
    
    var firebaseAPIKey: String {
        guard let value = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
        let dict = NSDictionary(contentsOfFile: value) else { fatalError("error") }
        return dict["API_KEY"] as! String
    }
    
    var fireStorageBase: String {
        guard let base = Bundle.main.infoDictionary?["firestorage_endpoint"] as? String
        else { return "" }
        return base
    }
}
