//
//  ProblemCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import UIKit
import SnapKit


class ProblemCell: UITableViewCell{
    
    let lableSize: CGFloat = 14
    
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var problem_number: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.titlePadding = 8
        let button = UIButton(configuration: configuration)
        button.tintColor = UIColor.systemBlue
        button.setTitle("1", for: .normal)
        return button
    }()
    
    private lazy var problem_title: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize + 10)
        return label
    }()
    
    
    private lazy var graphCollectionView: UICollectionView = {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0 // 상하간격
        flowLayout.estimatedItemSize = CGSize(width: 50.0, height: 50.0)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collection.delegate = self
        collection.dataSource = self
        
        collection.register(GraphCell.self, forCellWithReuseIdentifier: GraphCell.identifier)
        return collection
    }()
    
    
    // MARK: - SubView array Property
    private lazy var subviewsToBeAdded: [UIView] = [
        problem_number,
        problem_title,
        graphCollectionView
    ]
    
    
    var model: ProblemListItemViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }
    
    func bind(_ model: ProblemListItemViewModel){
        problem_number.setTitle("\(model.problemNumber)", for: .normal)
        problem_title.text = "\(model.problemTitle)"
        self.model = model
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //레이아웃 추가
        layoutConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let edge: CGFloat = 10
        contentView.frame.inset(by: UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge))
    }
    
    private func addSubviewsToContentView() {
        contentView.addSubview(containerView)
        subviewsToBeAdded.forEach { subview in
            containerView.addSubview(subview)
        }
    }
    
    private func layoutConfigure(){
        // contentView의 서브뷰로 추가
        addSubviewsToContentView()
        
        containerView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(12)
            
        }
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        
        problem_number.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.width.height.equalTo(32)
        }
        
        
        problem_title.snp.makeConstraints { make in
            make.leading.equalTo(problem_number.snp.trailing).offset(8)
            make.centerY.equalTo(problem_number)
        }
        
        graphCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(problem_number.snp.bottom).offset(8)
            make.leading.equalTo(problem_number.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(100).priority(.low)
            make.bottom.equalToSuperview()
        }
        
        
    }
}
//
//if ViewSection(rawValue: indexPath.section) == .review{
//    let reviewCell = ReviewCell()
//
//    let width = collectionView.frame.size.width
//    reviewCell.contentView.bounds.size.width = width
//
//    reviewCell.calculateViewHeight( indexPath,
//                                    viewModel.getCellData(indexPath.row))
//
//    reviewCell.contentView.setNeedsLayout()
//    reviewCell.contentView.layoutIfNeeded()
//
//    // uiview.layoutFittingCompressedSize -> 뷰의 적절한 최소 크기 반환
//    let height = reviewCell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)).height
//
//    reviewCell.prepareForReuse()
//
//    return CGSize(width: width, height: height)
//}
extension ProblemCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = GraphCell(frame: .zero)
        let width = collectionView.frame.size.width
        
        cell.contentView.bounds.size.width = width
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        let height = cell.contentView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)).height
        
        return CGSize(width: width, height: height)
    }
}
extension ProblemCell: UICollectionViewDelegate{
    
}


extension ProblemCell: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GraphCell.identifier, for: indexPath) as? GraphCell else {return UICollectionViewCell()}
        if indexPath.row == 1{
            if let model = model{
                cell.bind(GraphCell.GraphModel(submitCount: "\(model.submitCount)\(model.submitCount)\(model.submitCount)\(model.submitCount)\(model.submitCount)",
                                               correctAnswer: "\(model.correctAnswer)",
                                               correctRate: "\(model.correctRate)"))
            }
            
            return cell
        }
        
        return cell
    }
}
//


//        problem_submit_tag.snp.makeConstraints { make in
//            make.left.equalTo(problem_number)
//            make.top.equalTo(problem_number.snp.bottom).offset(16)
//        }
//
//        problem_submit.snp.makeConstraints { make in
//            make.left.equalTo(problem_submit_tag.snp.right).offset(8)
//            make.centerY.equalTo(problem_submit_tag)
//        }
//
//        problem_correct_tag.snp.makeConstraints { make in
//            make.left.equalTo(problem_submit_tag)
//            make.top.equalTo(problem_submit_tag.snp.bottom).offset(16)
//        }
//
//        problem_correct.snp.makeConstraints { make in
//            make.left.equalTo(problem_correct_tag.snp.right).offset(8)
//            make.centerY.equalTo(problem_correct_tag)
//        }
//
//        problem_correctRate_tap.snp.makeConstraints { make in
//            make.left.equalTo(problem_correct_tag)
//            make.top.equalTo(problem_correct_tag.snp.bottom).offset(16)
//        }
//
//        problem_correctRate.snp.makeConstraints { make in
//            make.left.equalTo(problem_correctRate_tap.snp.right).offset(8)
//            make.centerY.equalTo(problem_correctRate_tap)
//            make.bottom.equalToSuperview().offset(-8)
//        }


//2023-04-16 16:28:38.600244+0900 CodeStack[4603:722406] [LayoutConstraints] Changing the translatesAutoresizingMaskIntoConstraints property of the contentView of a UITableViewCell is not supported and will result in undefined behavior, as this property is managed by the owning UITableViewCell. Cell: <CodeStack.ProblemCell: 0x101111800; baseClass = UITableViewCell; frame = (0 0; 320 44); layer = <CALayer: 0x283173600>>
//2023-04-16 16:28:38.605959+0900 CodeStack[4603:722406] [LayoutConstraints] Changing the translatesAutoresizingMaskIntoConstraints property of the contentView of a UITableViewCell is not supported and will result in undefined behavior, as this property is managed by the owning UITableViewCell. Cell: <CodeStack.ProblemCell: 0x101032200; baseClass = UITableViewCell; frame = (0 0; 320 44); layer = <CALayer: 0x28314c4e0>>

