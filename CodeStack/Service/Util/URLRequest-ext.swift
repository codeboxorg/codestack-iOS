//
//  URLRequest-ext.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/30.
//

import Foundation


extension URLRequest{
    
    static private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    static private func createBody(parameters: [String: String],
                                   boundary: String,
                                   data: Data,
                                   mimeType: String,
                                   filename: String) -> Data {
        var body = Data()
        let imgDataKey = "img"
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(imgDataKey)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--".appending(boundary.appending("--")).data(using: .utf8)!)
        
        return body as Data
    }
    
    static func requestMultipart(url: URL, image data: Data) -> URLRequest {
        
        let boundary = generateBoundaryString()
        
        let data = data
        
        let body = createBody(parameters: [:],
                              boundary: boundary,
                              data: data,
                              mimeType: "image/png",
                              filename: "profile")
        
        var request = URLRequest(url: url )
        
        request.httpMethod = "PUT"
        
        let imageHeader: [String : String] = {
            [ "Content-Type": "multipart/form-data; boundary=\(boundary)",
              "Autorization" : "Bearer \(KeychainItem.currentAccessToken)"]
        }()
        
        imageHeader.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        request.httpBody = body
        
        return request
    }
    
    static func request(url: URL,
                        headers: [String: String] = [:],
                        body: [String : String] = [:],
                        method: String) -> URLRequest {
        
        var request = URLRequest(url: url )
        
        request.httpMethod = method
        
        headers.forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body,
                                                          options: [])
        }catch{
            fatalError("postHeader(with token: GitToken) -> URLRequest: \(error)")
        }
        
        return request
    }
}
