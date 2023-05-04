//
//  ProblemCell.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ProblemCell: UITableViewCell{
    
    let lableSize: CGFloat = 14
    let containerSpacing: CGFloat = 10
    
    
    var languages: PMLanguage? {
        didSet{
            if let languages{
                self.langugeContainer.setLanguage(languages)
                let height = self.langugeContainer.getCurrentIntrinsicHeight()
                self.languageContainerContainer.snp.updateConstraints { make in
                    make.height.equalTo(height).priority(.low)
                }
            }else{
                self.langugeContainer.removeLaguageTag()
            }
        }
    }
    
    var model: ProblemListItemModel?
    
    var styleFlag = PublishSubject<Bool>()
    
    lazy var subscription: Driver<Bool> =
    styleFlag
        .asDriver(onErrorJustReturn: true)
        .asSharedSequence()
    
    
    
    var disposeBag = DisposeBag()
    var cellDisposeBag = DisposeBag()
    
    var binder: Binder<DummyModel> {
        return Binder(self){ cell , dummy in
            let (model,language,flag) = dummy
            cell.problem_number.setTitle("\(model.problemNumber)", for: .normal)
            cell.problem_title.text = "\(model.problemTitle)"
            cell.model = model
            cell.languages = language
            cell.styleFlag.onNext(flag)
        }
    }
    
    
    let fo = FoldView()
    
    
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
        label.contentMode = .left
        label.textAlignment = .left
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
    
    
    private lazy var languageContainerContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var langugeContainer: LanguageTagContainer = {
        let container = LanguageTagContainer(frame: self.frame, spacing: containerSpacing)
        return container
    }()
    
    //MARK: - Binding to VC
    // using ControlProperty when seletedChange
    lazy var foldView: FoldView = {
        let view = FoldView(frame: .zero)
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
        languages = nil
        disposeBag = DisposeBag()
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //레이아웃 추가
        
        
        _ = subscription
            .drive(foldView.rx.isSelected)
            .disposed(by: cellDisposeBag)
        
        subscription
            .drive(onNext: { layoutFlag in
                if layoutFlag {
                    self.layoutConfigure()
                }else{
                    
                }
            }).disposed(by: cellDisposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let self else {return}
            self.foldTableView()
            
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    //MARK: - Fold Action
    func foldTableView(){
        self.graphCollectionView.isHidden = true
        self.langugeContainer.isHidden = true
        
        
        problem_number.snp.remakeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.width.height.equalTo(32)
        }
        
        problem_title.snp.remakeConstraints { make in
            make.leading.equalTo(problem_number.snp.trailing).offset(8)
            make.centerY.equalTo(problem_number)
            make.trailing.equalTo(foldView.snp.leading).offset(8)
        }
        
        problem_title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        foldView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        foldView.snp.remakeConstraints { make in
            make.width.height.equalTo(30)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(problem_title.snp.top)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        UIView.animate(withDuration: 0.5,
                       animations: {
            self.layoutIfNeeded()
        },
                       completion: {_ in
            
        })
    }
    
    
    // MARK: - SubView array Property
    private lazy var subviewsToBeAdded: [UIView] = [
        problem_number,
        foldView,
        problem_title,
        graphCollectionView,
        languageContainerContainer
    ]
    
    private func addSubviewsToContentView() {
        contentView.addSubview(containerView)
        subviewsToBeAdded.forEach { subview in
            containerView.addSubview(subview)
        }
        languageContainerContainer.addSubview(langugeContainer)
    }
    
    private func layoutConfigure(){
        // contentView의 서브뷰로 추가
        addSubviewsToContentView()
        
        containerView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(containerSpacing)
            make.height.equalTo(200).priority(.low)
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
            make.trailing.equalTo(foldView.snp.leading).offset(8)
        }
        
        problem_title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        foldView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        foldView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.trailing.equalToSuperview().inset(12)
            make.top.equalTo(problem_title.snp.top)
        }
        
        
        graphCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(problem_number.snp.bottom).offset(8)
            make.leading.equalTo(problem_number.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
        
        //view의 우선순위 살펴보기
        languageContainerContainer.snp.makeConstraints{make in
            make.top.equalTo(graphCollectionView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100).priority(.low)
            // 왜 .high 를 해야 자리를 잡지?
            make.bottom.equalTo(containerView.snp.bottom).offset(-12).priority(.high)
        }
        
        langugeContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

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
                
                cell.bind(GraphCell.GraphModel(submitCount: "\(model.submitCount)",
                                               correctAnswer: "\(model.correctAnswer)",
                                               correctRate: "\(round(model.correctRate * 100) / 100)"))
            }
            
            return cell
        }
        
        return cell
    }
}
