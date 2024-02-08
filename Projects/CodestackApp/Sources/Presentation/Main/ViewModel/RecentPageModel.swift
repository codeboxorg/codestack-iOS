//
//  RecentPageModel.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/19.
//

import Foundation
import RxDataSources
import Domain

extension SubmissionVO: IdentifiableType {
    public var identity: some Hashable {
        return self.id
    }
}

extension Array where Element == StoreVO {
    func toHomePostingSectionModel() -> HomeSection.HomeSectionModel {
        let items = self.map { store in HomeSection.HomeItem.writingList(store) }
        return HomeSection.HomeSectionModel(model: .writing, items: items)
    }
}

extension Array where Element == SubmissionVO {
    func toRecentModels(title: String = "최근 제출 10개") -> [RecentSubmission] {
        let items = self.map { subVo in RecentSubmission.Item.recent(subVo) }
        return [RecentSubmission(headerTitle: title, items: items)]
    }
    
    func toHomeSubmissionSectionModel() -> HomeSection.HomeSectionModel {
        let items = self.map { subVo in HomeSection.HomeItem.recent(subVo) }
        return HomeSection.HomeSectionModel(model: .recent, items: items)
    }
}

struct RecentSubmission: Equatable {
    var headerTitle: String
    var items: [Item]
}

extension RecentSubmission: AnimatableSectionModelType {
    typealias Item = HomeSection.HomeItem
    
    var identity: String {
        return headerTitle
    }
    
    init(original: RecentSubmission, items: [Item]) {
        self = original
        self.items = items
    }
}


extension StoreVO: IdentifiableType {
    public var identity: some Hashable {
        return self.id
    }
}

struct HomeSection {
    typealias HomeSectionModel = SectionModel<HomeViewSection, HomeItem>
    
    enum HomeViewSection: String, Equatable {
        case recent = "최근 제출 10개"
        case writing = "관련 글"
    }
    
    enum HomeItem: Equatable {
        case recent(SubmissionVO)
        case writingList(StoreVO)
    }
}

extension HomeSection.HomeItem: IdentifiableType {
    public var identity: some Hashable {
        return UUID().uuidString
    }
}
