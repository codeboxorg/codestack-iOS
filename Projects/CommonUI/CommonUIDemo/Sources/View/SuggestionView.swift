import UIKit
import Global
import CommonUI


final class SuggestionView: BaseView {
    private(set) var tableView = UITableView()
    
    private var suggestions: [String] = []
    
    private var selectAction: (String) -> Void
    private var gestureAction: (String) -> Void
    
    public init(
        tableView: UITableView = UITableView(),
        suggestions: [String],
        selectAction: @escaping (String) -> Void,
        gestureAction: @escaping (String) -> Void
    ) {
        self.tableView = tableView
        self.suggestions = suggestions
        self.selectAction = selectAction
        self.gestureAction = gestureAction
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layerAttributes() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    override func addAutoLayout() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    override func applyAttributes() {
        backgroundColor = UIColor.systemGray6.withAlphaComponent(0.6)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = 30
        self.isUserInteractionEnabled = true
        setupPanGesture()
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        tableView.isScrollEnabled = false  // 제스처로만 스크롤 제어
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: tableView)
        let adjustedLocation = CGPoint(x: location.x, y: location.y + gesture.translation(in: self).y)
        let indexPath = tableView.indexPathForRow(at: adjustedLocation)
        self.suggestionView(didHoverOver: indexPath)
        
        let translation = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)
        
        let maxOffsetY = tableView.contentSize.height - tableView.bounds.height
        var newOffsetY = tableView.contentOffset.y + translation.y
        
        newOffsetY = max(0, min(newOffsetY, maxOffsetY))
        let point = CGPoint(x: 0, y: newOffsetY)
        
        tableView.setContentOffset(point, animated: false)
    }
    
    func updateSuggestions(words: [String]) {
        suggestions = Array(words.prefix(10))
        tableView.reloadData()
        let rowHeight: CGFloat = 40
        let maxVisibleRows = 5
        let visibleRowCount = min(suggestions.count, maxVisibleRows)
        let height = CGFloat(visibleRowCount) * rowHeight
        NSLayoutConstraint.deactivate(self.constraints.filter { $0.firstAttribute == .height })
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        suggestionView(didHoverOver: IndexPath(row: 0, section: 0))
    }
}


extension SuggestionView {
    func suggestionView(didHoverOver indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }

        for visible in tableView.visibleCells {
            visible.backgroundColor = .clear
        }

        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor.systemGray5
            gestureAction(cell.textLabel?.text ?? "")
        }
    }
}

extension SuggestionView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectAction(suggestions[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.textColor = .label
        cell.backgroundColor = .clear
        return cell
    }
}
