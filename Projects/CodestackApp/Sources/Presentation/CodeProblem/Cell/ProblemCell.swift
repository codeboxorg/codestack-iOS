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
import Domain

class ProblemCell: UITableViewCell{
    
    let lableSize: CGFloat = 16
    let containerSpacing: CGFloat = 10
    
    
    private lazy var containerView: UIView = {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)
        problemCell_tapGesture = tapGesture
        return view
    }()
    
    
    private let horizontalTitleContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    
    private let problem_number: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.titlePadding = 8
        let button = UIButton(configuration: configuration)
        button.setTitle("1", for: .normal)
        return button
    }()
    
    private lazy var problem_title: UILabel = {
        let label = UILabel().headLineLabel(size: lableSize)
        label.numberOfLines = 1
        label.contentMode = .left
        label.textAlignment = .left
        return label
    }()
    
    
    //TODO: CollectionView에서 UIView로 변경해야댐 -> 완료인가?
    private let graphSubmit: GraphSubmitView = {
        let view = GraphSubmitView()
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private let languageContainerContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var langugeContainer: TagContainer = {
        let container = TagContainer(frame: self.frame, spacing: containerSpacing)
        return container
    }()
    
    //MARK: - Binding to VC
    // using ControlProperty when seletedChange
    let foldButton: FoldButton = {
        let view = FoldButton(frame: .zero)
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private var languages: [LanguageVO]? {
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
    
    var flag: Bool = false
    
    //foldButton Tap
    lazy var foldButtonTap: ControlEvent<Void>? = foldButton.rx.tap
    
    // UITapGesture
    weak var problemCell_tapGesture: UITapGestureRecognizer?
    
    
    var disposeBag = DisposeBag()
    var cellDisposeBag = DisposeBag()
    
    
    var binder: Binder<DummyModel> {
        return Binder(self){ cell , dummy in
            let (model,language,flag) = dummy
            cell.problem_number.setTitle("\(model.problemNumber)", for: .normal)
            cell.problem_title.text = "\(model.problemTitle)"
            cell.model = model
            cell.languages = language + model.tags.map{ tag in LanguageVO(id: "none",
                                                                        name: tag.name ,
                                                                        extension: "none")}
            
            cell.graphSubmit.bind(.init(submitCount: String(describing: model.submitCount),
                                        correctAnswer: String(describing: model.correctAnswer),
                                        correctRate: String(format: "%.\(2)f", model.correctRate)))
    
            cell.flag = flag
            cell.styleFlag.onNext(flag)
        }
    }
    
    
    deinit{
        print("\(String(describing: Self.self)) - deinint")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
        languages = nil
        disposeBag = DisposeBag()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //레이아웃 추가
        
        layoutConfigure()
        
        foldButtonTap?
            .subscribe(with:self,onNext: { cell,_ in
                cell.foldButton.isSelected.toggle()
                let flag = cell.foldButton.isSelected
                flag ? cell.strechTableView() : cell.foldTableView()
                self.layoutIfNeeded()
            }).disposed(by: cellDisposeBag)
        
        _ = self.styleFlag
            .asDriver(onErrorJustReturn: true)
            .drive(with: self,onNext: {cell,layoutFlag in
                layoutFlag ? cell.strechTableView() : cell.foldTableView()
                cell.foldButton.isSelected = layoutFlag
            }).disposed(by: cellDisposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    
    private func strechTableView(){
        self.langugeContainer.isHidden = false
        self.graphSubmit.isHidden = false
        horizontalTitleContainer.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    
    
    
    //MARK: - Fold Action
    private func foldTableView(){
        self.langugeContainer.isHidden = true
        self.graphSubmit.isHidden = true
        
        horizontalTitleContainer.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52).priority(.high)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - SubView array Property
    private lazy var subviewsToBeAdded: [UIView] = [
        horizontalTitleContainer,
        graphSubmit,
        //        graphCollectionView,
        languageContainerContainer
    ]
    
    private func addSubviewsToContentView() {
        contentView.addSubview(containerView)
        subviewsToBeAdded.forEach { subview in
            containerView.addSubview(subview)
        }
        
        [problem_number,
         foldButton,
         problem_title].forEach{
            horizontalTitleContainer.addSubview($0)
        }
        
        languageContainerContainer.addSubview(langugeContainer)
    }
    
    private func layoutConfigure(){
        // contentView의 서브뷰로 추가
        self.selectionStyle = .none
        addSubviewsToContentView()
        makeConfigure()
    }
    
    fileprivate func setViewPriority() {
        // 추가 Vertical
        problem_number.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        problem_number.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        problem_title.setContentHuggingPriority(.defaultLow, for: .horizontal)
        problem_title.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        foldButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func makeConfigure(){
        containerView.snp.makeConstraints{ make in
            make.edges.equalToSuperview().inset(containerSpacing)
            make.height.equalTo(200).priority(.low)
        }
        
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.sky_blue.cgColor
        
        horizontalTitleContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(52)
        }
        
        problem_number.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(12)
            make.height.equalTo(30) //.priority(.high)
            make.width.equalTo(30).priority(.low)
        }
        
        problem_title.snp.makeConstraints { make in
            make.centerY.equalTo(problem_number.snp.centerY)
            make.leading.equalTo(problem_number.snp.trailing).offset(8)
            make.trailing.equalTo(foldButton.snp.leading).offset(-8)
        }
        
        setViewPriority()
        
        foldButton.snp.makeConstraints { make in
            // 아 이거때문에 하ㅏㅏ
//            make.top.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
            make.centerY.equalTo(problem_number.snp.centerY)
        }
        
        graphSubmit.snp.makeConstraints { make in
            make.top.equalTo(horizontalTitleContainer.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(60)
        }
        
        //view의 우선순위 살펴보기
        languageContainerContainer.snp.makeConstraints{make in
            make.top.equalTo(graphSubmit.snp.bottom).offset(12)
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
