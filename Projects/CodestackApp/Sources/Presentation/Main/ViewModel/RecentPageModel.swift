//
//  RecentPageModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/19.
//

import Foundation
import RxDataSources
import Domain
//typealias RecentSubmissionSection = SectionModel<String, RecentSubmission>

// MARK: 확인후 제거
//extension Submission: IdentifiableType, Equatable{
//    static func == (lhs: Submission, rhs: Submission) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    var identity: some Hashable{
//        return self.id
//    }
//}

extension SubmissionVO: IdentifiableType {
    public var identity: some Hashable {
        return self.id
    }
}

extension Array where Element == SubmissionVO {
    func toRecentModels(title: String = "최근 제출 10개") -> [RecentSubmission] {
        return [RecentSubmission(headerTitle: title, items: self)]
    }
}

struct RecentSubmission {
    var headerTitle: String
    var items: [Item]
}

extension RecentSubmission: AnimatableSectionModelType {
    typealias Item = SubmissionVO
    
    var identity: String {
        return headerTitle
    }
    
    init(original: RecentSubmission, items: [Item]) {
        self = original
        self.items = items
    }
}
