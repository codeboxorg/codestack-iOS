//
//  ViewController-ContributionGraph.swift
//  CodeStack
//
//  Created by 박형환 on 2023/09/19.
//

import UIKit
import SwiftUI

extension ViewController {
    //MARK: - 컨티리뷰션 그래프 뷰
    func calendarView() {
        
        guard let viewModel = self.contiributionViewModel else { return }
        
        let vc = UIHostingController(rootView: SubmissionChartView(viewModel: viewModel))
        
        let submissionChartView = vc.view!
        submissionChartView.translatesAutoresizingMaskIntoConstraints = false
        submissionChartView.backgroundColor = graphBackground
        submissionChartView.layer.cornerRadius = 12
        
        // 2
        // Add the view controller to the destination view controller.
        addChild(vc)
        
        graphContainerView.addSubview(submissionChartView)
        
        // 3
        // Create and activate the constraints for the swiftui's view.
        NSLayoutConstraint.activate([
            submissionChartView.topAnchor.constraint(equalTo: graphContainerView.topAnchor),
            submissionChartView.leadingAnchor.constraint(equalTo: graphContainerView.leadingAnchor),
            submissionChartView.trailingAnchor.constraint(equalTo: graphContainerView.trailingAnchor),
            submissionChartView.bottomAnchor.constraint(equalTo: graphContainerView.bottomAnchor)
        ])
        
        // 4
        // Notify the child view controller that the move is complete.
        vc.didMove(toParent: self)
    }
}
