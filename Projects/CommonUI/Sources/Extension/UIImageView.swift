//
//  UIImageView.swift
//  CommonUI
//
//  Created by 박형환 on 1/31/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import UIKit

public extension UIImageView {
    
    func load(url: URL, completion: @escaping (UIImage) -> () ) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let data = try? Data(contentsOf: url) {
                self.load(data: data, completion: completion)
            }
        }
    }
    
    func load(data: Data, completion: @escaping (UIImage) -> ()) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.image = image
                completion(image)
            }
        }
    }
    
}
