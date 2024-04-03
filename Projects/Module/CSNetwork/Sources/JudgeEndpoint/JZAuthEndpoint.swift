import Foundation

public struct JZAuthEndpoint: EndPoint {
    
    public var host: String {
        judgeZeroBase
    }
    
    public var path: String {
        "/authenticate"
    }
    
    public var method: RequestMethod {
        .post
    }
    
    public var header: [String : String] = [
        :
    ]
    
    public var body: Data?
    
    public var queryParams: [String : String]? {
        [:]
    }
    
    public init() {}
}
