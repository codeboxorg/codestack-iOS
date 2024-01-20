//
//  Configuration.swift
//  Domain
//
//  Created by 박형환 on 1/14/24.
//  Copyright © 2024 hyeong. All rights reserved.
//

import Foundation


enum FBQuery {
    
    static func query(document id: String) -> Data? {
        """
        { "structuredQuery": {
                "where": { "compositeFilter": {
                        "op": "AND",
                        "filters": [
                            { "fieldFilter": { "field": { "fieldPath": "dateTime" },
                                    "op": "GREATER_THAN_OR_EQUAL",
                                    "value": { "timestampValue": "\(id)" }
                            }}
                        ]
                    }
                },
                "from": [ { "collectionId": "records", "allDescendants": true } ]
            }
        }
        """.data(using: .utf8)
    }
}
