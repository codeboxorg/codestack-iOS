import Foundation

public struct JZFetchSubmissionEndpoint: EndPoint {
    
    public var scheme: String {
        "http"
    }
    
    public var host: String {
        judgeZeroLocalBase
    }
    
    public var port: Int? {
        2358
    }
    
    public var path: String = "/submissions"
    
    public var method: RequestMethod {
        .get
    }
    
    public var header: [String : String] = [
        "Content-Type": "application/json",
         "X-RapidAPI-Host" : "judge0-ce.p.rapidapi.com"
    ]
    
    public var body: Data?
    
    public var queryParams: [String : String]? = [
        "base64_encoded": "true",
        "fields": "stdout,time,memory,stderr,token,compile_output,message,status"
    ]
    
    public init(token: String) {
        header["X-RapidAPI-Key"] = "3598034b5bmsh27280d35aab63dbp1679d7jsn909ec73ac288"
        path += "/\(token)"
    }
}
