//
//  SubmissionViewModel.swift
//  CodeStack
//
//  Created by 박형환 on 11/22/23.
//

import SwiftUI
import RxCocoa
import RxFlow
import RxSwift
import Global
import Domain

class ContributionViewModel: ObservableObject, RxFlow.Stepper {
    
    private var contribution_day_count: Int = 105
    
    var steps = PublishRelay<Step>()
    
    @Published var contributions: [SubmissionContribution] = [SubmissionContribution(date: .now,
                                                                                     submit: 1,
                                                                                     depth: .one)]
    struct Dependency {
        let submissionUsecase: SubmissionUseCase
    }
    
    private var submissionUsecase: SubmissionUseCase?
    
    static func create(depenedency: Dependency) -> ContributionViewModel {
        let viewModel = ContributionViewModel()
        viewModel.submissionUsecase = depenedency.submissionUsecase
        viewModel.binding()
        return viewModel
    }
    
    func binding() {
        // TODO: 해야할일 -> 지금 날짜별로 자신의 submission을 가져오는게 불가능 하다....
        // GraphQL API 아직 없는 상황
        // -> 그냥 Core Data Layer추가 하는게 나을듯 하다
        // submissionUsecase?.fetchProblemHistoryEqualStatus(status: {})
        _ = submissionUsecase?.fetchSubmissionCalendar()
            .map { try $0.get() }
            .subscribe(with: self, onNext: { vm, calendar in
                vm.contributions = vm.caculateCurrentContribution(value: SubmissionCalendarVO.generateMockCalendar())
            })
    }
    
    func setCellColor(columnsCount: Int) -> [[Color]] {
        guard let lastDate = contributions.last?.date else {
            return []
        }
        let rows = 7
        let columns = columnsCount
        let cellCount = rows * columns - (rows - Calendar.current.component(.weekday, from: lastDate))
        let levels = contributions.suffix(cellCount).map(\.depth).chunked(into: rows)
        let result = levels.map { $0.map { depth in
            return CellColor.cellColor.opacity(depth.applyOpacity())
        } }
        return result
    }
    
    
    private func caculateCurrentContribution(value: SubmissionCalendarVO) -> [SubmissionContribution] {
        
        var dayArray: [String: SubmissionContribution] = self.getContributionDates(size: contribution_day_count)
        
        let contributionDic: [String: Int]
        =
        value.dates.reduce(into: [String: Int](), { original, date in
            guard let dateString = date.toDateStringKST(format: .YYYYMMDD) else { return }
            original[dateString, default: 0] += 1
        })
        
        contributionDic.forEach { key, value in
            guard let date = key.toYYMMDD() else { return }
            dayArray[key] = SubmissionContribution(date: date, submit: value)
        }
        return dayArray.sortDictionaryKeysByDate()
    }
    
    private func getContributionDates(size: Int) -> [String : SubmissionContribution] {
        var currentDate = Date()
        var dateArray: [String : SubmissionContribution] = [:]
        
        let calendar = Calendar.current
        let dateFormatter = Fommater.formatter
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for _ in 1...size {
            let dateString = dateFormatter.string(from: currentDate)
            dateArray[dateString] = SubmissionContribution(date: currentDate, submit: 0, depth: .zero)
            if let previousMonthDate = calendar.date(byAdding: .day, value: -1, to: currentDate) {
                currentDate = previousMonthDate
            } else {
                break  // 날짜를 더 이상 계산할 수 없으면 종료
            }
        }
        return dateArray
    }
}
