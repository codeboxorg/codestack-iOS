//
//  SubmissionListView.swift
//  CodeStack
//
//  Created by 박형환 on 11/30/23.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

final class SubmissionListView: UIView {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        return tableView
    }()
    
    let emptyLabel: UILabel = {
        let label = UILabel()
        return label.headLineLabel(size: 18, text: "💡현재 제출된 기록이 존재하지 않습니다", color: .whiteGray)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addAutoLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHidden(_ hidden: Bool) {
        self.tableView.isHidden = hidden
        self.emptyLabel.isHidden = hidden
    }
    
    func addEmptyLayout(flag: Bool) {
        if flag {
            tableView.addSubview(emptyLabel)
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
                emptyLabel.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 20)
            ])
        } else {
            emptyLabel.removeFromSuperview()
        }
    }
    
    private func addAutoLayout() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -24)
        ])
    }
}
