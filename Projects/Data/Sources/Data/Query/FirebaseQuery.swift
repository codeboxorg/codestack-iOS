//
//  FirebaseQuery.swift
//  Data
//
//  Created by 박형환 on 3/18/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation



enum FirebaseQuery {
    
    
    static func postListQuery(_ offset: Int, _ limit: Int) -> Data? {
        """
        {
            "structuredQuery": {
                "from": [{ "collectionId": "posts", "allDescendants": true }],
                "orderBy": {
                    "field": {
                        "fieldPath" : "date"
                    },
                    "direction" : "DESCENDING"
                },
                "offset": \(offset),
                "limit": \(limit)
            }
        }
        """.data(using: .utf8)
    }
    
}
