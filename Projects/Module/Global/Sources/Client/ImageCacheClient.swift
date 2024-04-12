//
//  ImageClient.swift
//  Data
//
//  Created by 박형환 on 2/26/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit
import Combine

public final class ImageCacheClient {
    
    public static let shared: ImageCacheClient = ImageCacheClient()
    
    static let myProfileImageKey = CacheKey(key: .myProfileImage)
    
    private init() {}
    
    private let cache = NSCache<CacheKey, UIImage>()
    private var subscriptions = Set<AnyCancellable>()
    
    public func getMyImageFromCache() -> UIImage? {
        cache.object(forKey: Self.myProfileImageKey)
    }
    
    public func getOtherImageFromCache(_ nickname: CacheKey) -> UIImage? {
        cache.object(forKey: nickname)
    }
    
    public func getOtherImageFromCache(_ nickname: CacheKey, _ imageURL: String) async -> UIImage? {
        if let cacheImage = cache.object(forKey: nickname) {
            return cacheImage
        }
        guard let url = URL(string: imageURL) else { return nil }
        let request = URLRequest(url: url)
        let task = try? await URLSession.shared.data(for: request)
        
        if let task {
            let (data, _) = task
            let image = UIImage(data: data)
            
            if let image { cache.setObject(image, forKey: nickname) }
            
            return image
        }
        return nil
    }
    
    public func setMyImageInCache(_ data: Data) {
        guard let image = UIImage(data: data) else { return }
        cache.setObject(image, forKey: Self.myProfileImageKey)
    }
    
    public func setOtherInCache(_ data: Data, _ nickname: CacheKey) {
        guard let image = UIImage(data: data) else { return }
        cache.setObject(image, forKey: nickname)
    }
}


public enum KeyType {
    case myProfileImage
    case other(String)
    case post(String)
    
    var value: String {
        switch self {
        case .post(let string):
            return "\(string)"
            
        case .myProfileImage:
            return "MyProfileImage"
            
        case .other(let string):
            return "\(string)"
        }
    }
}

public final class CacheKey: NSObject {
    
    public let key: String
    
    public init(key: KeyType) {
        self.key = key.value
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CacheKey else {
            return false
        }
        return key == other.key
    }
    
    public override var hash: Int {
        return key.hashValue
    }
}
