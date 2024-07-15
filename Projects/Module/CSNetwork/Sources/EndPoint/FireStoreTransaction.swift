

import Foundation




public struct BeginTransactionEndPoint: EndPoint {
    
    public var host: String { firestoreBase }
    
    public var path: String = ""
    
    public var method: RequestMethod = .post
    
    public var header: [String : String]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(token: String) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        self.body = nil
        self.path = "\(self.projectPath)" + ":beginTransaction"
    }
}

public struct CommitTransactionEndPoint: EndPoint {
    
    public var host: String { firestoreBase }
    
    public var path: String = ""
    
    public var method: RequestMethod = .post
    
    public var header: [String : String]
    
    public var body: Data?
    
    public var queryParams: [String : String]?
    
    public init(token: String, transaction: Data) {
        self.header = ["Content-Type": "application/json",
                       "Authorization" : "Bearer \(token)"]
        self.body = transaction
        self.path = "\(self.projectPath)" + ":commit"
    }
}



public enum FireStoreTransaction {
    
    case postingTransaction(
        transactionID: String,
        transcationData: (markDown: Data?, storeData: Data?)
    )
    
    public static func createMarkDown(_ path: String, _ markDown: String) -> Data? {
        let jsonString = """
        {
            "create": {
                "document": {
                    "name": "\(path)",
                    "fields": {
                        "markdown" : {
                            "stringValue" : "\(markDown)"
                        }
                    }
                }
            }
        }
        """
        return jsonString.data(using: .utf8)
    }
    
    public static func createPosting(_ path: String, _ store: Store) -> Data? {
        let tagsArray = store.tags.map { tag in
            return """
            {
                "stringValue": "\(tag)"
            }
            """
        }.joined(separator: ", ")
        
        let jsonString = """
        {
            "create": {
                "document": {
                    "name": "\(path)",
                    "fields": {
                        "date": {
                            "stringValue": "\(store.date)"
                        },
                        "description": {
                            "stringValue": "\(store.description)"
                        },
                        "markdown": {
                            "stringValue": "\(store.markdownID)"
                        },
                        "name": {
                            "stringValue": "\(store.name)"
                        },
                        "tag": {
                            "arrayValue": {
                                "values": [
                                    \(tagsArray)
                                ]
                            }
                        },
                        "title": {
                            "stringValue": "\(store.title)"
                        },
                        "userId": {
                            "stringValue": "\(store.userId)"
                        }
                    }
                }
            }
        }
        """
        return jsonString.data(using: .utf8)
    }
}


func transaction() {
    let token = "your-auth-token"

//    URLSession.shared.dataTask(with: beginTransactionEndPoint.request) { data, response, error in
//        guard let data = data, error == nil else {
//            print("Error starting transaction: \(String(describing: error))")
//            return
//        }
//
//        do {
//            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//               let transactionId = json["transaction"] as? String {
//                
//                // 2. 트랜잭션 커밋
//                let path1 = "projects/your-project-id/databases/(default)/documents/yourCollection/markdownDocumentId"
//                let path2 = "projects/your-project-id/databases/(default)/documents/yourCollection/postingDocumentId"
//                
//                let store = Store(
//                    date: "2024-07-03",
//                    description: "Sample description",
//                    markdownID: "markdown123",
//                    name: "Sample Name",
//                    tags: ["tag1", "tag2"],
//                    title: "Sample Title",
//                    userId: "user123"
//                )
//                
//                guard let markDownData = Transaction.createMarkDown(path1, "Sample Markdown Content"),
//                      let postingData = Transaction.createPosting(path2, store) else {
//                    print("Failed to create creation data")
//                    return
//                }
//                
//                let writesArray = [markDownData, postingData]
//                let writePayloads = writesArray.compactMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
//                
//                let commitBody: [String: Any] = [
//                    "writes": writePayloads,
//                    "transaction": transactionId
//                ]
//                
//                guard let commitData = try? JSONSerialization.data(withJSONObject: commitBody, options: []) else {
//                    print("Failed to create commit data")
//                    return
//                }
//                
//                let commitTransactionEndPoint = CommitTransactionEndPoint(token: token, transaction: commitData)
//                
//                URLSession.shared.dataTask(with: commitTransactionEndPoint.request) { data, response, error in
//                    guard let data = data, error == nil else {
//                        print("Error committing transaction: \(String(describing: error))")
//                        return
//                    }
//
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                           let _ = json["writeResults"] as? [[String: Any]] {
//                            print("Transaction committed successfully")
//                        } else {
//                            print("Failed to commit transaction")
//                        }
//                    } catch {
//                        print("JSON parsing error: \(error)")
//                    }
//                }.resume()
//            } else {
//                print("Failed to parse transaction ID")
//            }
//        } catch {
//            print("JSON parsing error: \(error)")
//        }
//    }.resume()
}
