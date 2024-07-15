import Foundation

public struct JZSubmissionEndpoint: EndPoint {
    
    public var scheme: String {
        "https"
    }
    
    public var host: String {
        judgeZeroBase
    }
    
    public var path: String {
        "/submissions"
    }
    
//    public var port: Int? {
//        2358
//    }
    
    public var method: RequestMethod {
        .post
    }
    
    public var header: [String : String] = [
        "Content-Type": "application/json",
         "X-RapidAPI-Host" : "judge0-ce.p.rapidapi.com"
    ]
    
    public var body: Data?
    
    public var queryParams: [String : String]? { 
        [
            "base64_encoded" : "true"
        ]
    }
    
    public init(dto: JudgeZeroSubmissionRequestDTO) {
        // header["X-RapidAPI-Key"] = "3598034b5bmsh27280d35aab63dbp1679d7jsn909ec73ac288"
        let data = try? JSONEncoder().encode(dto)
        body = data
    }
}
