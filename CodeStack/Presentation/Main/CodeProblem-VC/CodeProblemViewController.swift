//
//  CodeProblemViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/15.
//

import UIKit
import SnapKit

class CodeProblemViewController: UIViewController{
    
    weak var delegate: SideMenuDelegate?
    
    lazy var problemTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProblemCell.self, forCellReuseIdentifier: ProblemCell.identifier)
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        
        
        
        self.title = "Problem List"
        
        self.view.addSubview(problemTableView)
        problemTableView.snp.makeConstraints{
            $0.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
    }
    
}

extension CodeProblemViewController: UITableViewDelegate{
    
}
extension CodeProblemViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProblemCell.identifier, for: indexPath) as? ProblemCell else { return UITableViewCell() }
        let model = ProblemListItemViewModel(problemNumber: 1,
                                             problemTitle: "Hellow world",
                                             submitCount: 12,
                                             correctAnswer: 14,
                                             correctRate: 86.2)
        cell.bind(model)
        return cell
    }
    
    
}
