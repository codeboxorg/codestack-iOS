//
//  ProblemDescriptionView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/23.
//

import SnapKit
import RxCocoa
import RxGesture
import RxSwift
import WebKit
import Global
import Domain
import CommonUI

// TODO: View -> UIViewCOntroller 로 변경해야됨

final class ProblemPopUpView: UIView {
    
    private var popUpFlag: Bool = false
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    lazy var problemTitle: UILabel = {
        let label = UILabel().headLineLabel(size: 18)
        label.isHidden = true
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        return label
    }()
    
    private let activityIndicator = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .sky_blue
        return view
    }()
    
    private let refreshLabel: UILabel = {
        let label = UILabel().labelSetting("페이지 로드를 실패하였습니다", .gray, .boldSystemFont(ofSize: 20))
        return label
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.tintColor = UIColor.sky_blue
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    private lazy var problemStepButton: NumberButton = {
       let button = NumberButton()
        button.settingNumber(for: 1)
        button.settingText(for: "문제")
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var resultStepButton: NumberButton = {
       let button = NumberButton()
        button.settingNumber(for: 2)
        button.settingText(for: "결과")
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var submissionListStepButton: NumberButton = {
        let button = NumberButton()
         button.settingNumber(for: 3)
         button.settingText(for: "제출현황")
         button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
         return button
    }()
    
    private lazy var popUpContainerView: PopUpcontainer = {
        let containerView = PopUpcontainer()
        return containerView
    }()
    
    
    let heartButton: HeartButton = {
        let button = HeartButton()
        return button
    }()
    
    lazy var backButton: BackButton = {
        let button = BackButton()
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    private let button_width_height: CGFloat = 44
    
    lazy var hideButton: HideButton = {
        let button = HideButton().makeHideButton(height: button_width_height)
        button.addTarget(self, action: #selector(hidebuttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 문제 제출 버튼
    private lazy var sendButton: LoadingUIButton = {
        var button = LoadingUIButton(frame: .zero, title: "제출하기")
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var languageButton: LanguageButton = {
        let button = LanguageButton().makeLanguageButton()
        return button
    }()
    
    // 문제 보여주는 웹뷰
    private lazy var wkWebView: WKWebView = {
        let webView = WKWebView().makeWebView()
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    
    private(set) var editorTitleField = UITextField().then { field in
        field.placeholder = "제목없음"
        field.tintColor = .whiteGray
    }
    
    // 결과 보여주는 뷰
    private let resultStatusView: SubmissionResultView = {
        let resultStatusView = SubmissionResultView()
        return resultStatusView
    }()
    
    private(set) var submissionListView: SubmissionListView = {
        let view = SubmissionListView()
        view.setHidden(true)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        autoLayout()
    }
    
    convenience init(frame: CGRect, _ delegate: CodeEditorViewController) {
        self.init(frame: frame)
        self.delegate = delegate
        problemGestureAction()
        resultGestureAction()
        submissionListGestureAction()
        observingEvent()
        loadingSubmitEvent()
        settingColor()
        self.popUpContainerView.layer.addBorder(side: .bottom, thickness: 1, color: UIColor.red.cgColor)
    }
    
    
    //MARK: - View Color
    func settingColor() {
        self.backgroundColor = .clear
        resultStatusView.backgroundColor = .clear
        submissionListView.backgroundColor = .clear
        submissionListView.tableView.backgroundColor = .clear
        let color = CColor.whiteGray.color
        
        problemStepButton.setTextColor(color: color)
        resultStepButton.setTextColor(color: color)
        submissionListStepButton.setTextColor(color: color)
        
        sendButton.setTitleColor(color, for: .normal)
        languageButton.setTitleColor(color, for: .normal)
        backButton.tintColor = color
        problemTitle.textColor = color
        hideButton.tintColor = color
        sendButton.tintColor = color
        sendButton.buttonColor = color
        
        heartButton.tintColor = .sky_blue
        resultStatusView.setting(color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError occur!")
    }
    
    deinit {
        Log.debug("deinit")
    }
    
    //MARK: receive event from EditorViewController
    
    private weak var delegate: CodeEditorViewController?
    
    var disposeBag = DisposeBag()
    let languageRelay = BehaviorRelay<LanguageVO>(value: LanguageVO.default)
    let pageValue = BehaviorRelay<SolveResultType>(value: .problem)
    let submissionLoadingWating = BehaviorRelay<Bool>(value: false)
    let problemState = PublishRelay<CodeEditorViewModel.ProblemState>()

    private var webViewHeight: CGFloat = 0
    private let leading_trailing_spacing: CGFloat = 8
    
    //MARK: - Observing Event
    private func observingEvent(){
        languageRelay
            .distinctUntilChanged()
            .bind(onNext: { [weak self] language in
                self?.languageButton.setTitle(language.name, for: .normal)
            }).disposed(by: disposeBag)
        
        pageValue.skip(1).subscribe(with: self,
                            onNext: { vm, page in
            switch page {
            case .problem:
                vm.remakeWkWebViewHeight(height: vm.webViewHeight)
                
            case .result(let submission):
                vm.remakeResultStatus(height: 300)
                
                vm.scrollView.contentOffset = CGPoint.zero
                guard let submission else { return }
                vm.resultStatusView.status.onNext(submission)
                
            case .resultList(_):
                vm.remakeSubmissionListResults(height: 300)
            }
        }).disposed(by: disposeBag)
        
        problemRefreshTap
            .drive(with: self, onNext: { view, _ in
                view.refreshButton.isHidden = true
                view.refreshLabel.text = "로딩중......"
                view.activityIndicator.startAnimating()
            }).disposed(by: disposeBag)
        
        problemState
            .subscribe(with: self, onNext: { view, value in
                // Refresh end
                view.activityIndicator.stopAnimating()
                view.refreshButton.isHidden = false
                view.refreshLabel.text = "페이지 로드를 실패하였습니다"
                
                if case let .fetched(problem) = value {
                    view.refreshLabel.removeFromSuperview()
                    view.refreshButton.removeFromSuperview()
                    view.loadHTMLToWebView(html: problem.context)
                    return
                }
            }).disposed(by: disposeBag)
    }
    
    private func loadingSubmitEvent() {
        submissionLoadingWating
            .subscribe(with: self,onNext: { view, value in
                value ? view.sendButton.showLoading() : view.sendButton.hideLoading()
            }).disposed(by: disposeBag)
    }
    
    
    private func problemGestureAction() {
        problemStepButton.container.rx.gesture(.tap())
            .when(.recognized).asDriver(onErrorJustReturn: .init())
            .drive(with: self,
                   onNext: { view, _ in
                view.impact()
                view.pageValue.accept(.problem)
            }).disposed(by: disposeBag)
    }
    
    private func resultGestureAction() {
        resultStepButton.container.rx.gesture(.tap())
            .when(.recognized).asDriver(onErrorJustReturn: .init())
            .drive(with: self,
                   onNext: { view, _ in
                view.impact()
                view.pageValue.accept(.result(nil))
            }).disposed(by: disposeBag)
    }
    
    private func submissionListGestureAction() {
        submissionListGesture
            .drive(with: self,
                   onNext: { view, _ in
                view.impact()
                view.pageValue.accept(.resultList([]))
            }).disposed(by: disposeBag)
    }
    
    lazy var problemRefreshTap = refreshButton.rx.tap.asDriver()
    let linkDetector = PublishSubject<String>()
    lazy var favoriteTap: Driver<Bool>
    =
    heartButton.rx.tap
        .compactMap { [weak self] in
            guard let self else { return false }
            return !self.heartButton.flag
        }.asDriver(onErrorJustReturn: false)
    
    lazy var submissionListGesture
    =
    submissionListStepButton.container.rx
        .gesture(.tap())
        .when(.recognized)
        .asDriver(onErrorJustReturn: .init())
    
    //MARK: - Binding To ViewModel
    func dissmissAction() -> Driver<Void> {
        return backButton.rx.tap.asDriver()
    }
    
    func sendSubmissionAction() -> Driver<Void> {
        sendButton.rx.tap.asDriver()
    }
    
    func languageAction() -> Driver<LanguageVO> {
        languageRelay.asDriver()
    }
    
    /// 언어 모델
    private var languages: [LanguageVO] = []
    
    /// 언어 Title Action && languageRelay에 값 전달 -> ViewModel로 데이터 전달
    private lazy var setTitleAction: (UIAction) -> () = { [weak self] action in
        guard let self else {return}
        self.languageButton.setTitle(action.title, for: .normal)
        if let value = languages.filter({ $0.name == action.title }).first {
            self.languageRelay.accept(value)
        }
    }
    
    /// 언어 설정 하기 위한 함수
    /// - Parameter languages: 언어 배열
    func setLangueMenu(languages: [LanguageVO]){
        self.languages = languages
        
        let element = languages.map { lan in
            UIAction(title: lan.name, handler: setTitleAction)
        }
        
        if let lan = languages.first{
            languageButton.setTitle(lan.name, for: .normal)
        }
        
        languageButton.showsMenuAsPrimaryAction = true
        languageButton.menu = UIMenu(title: "언어", image: nil, identifier: nil, options: .destructive, children: element)
    }
    
}


//MARK: - WebView Delegate
extension ProblemPopUpView: WKNavigationDelegate{
    
    /// Load To WebView HTMLString
    /// - Parameter string: HTML String
    func loadHTMLToWebView(html string: String) {
        if string.isEmpty || string.count < 3 {
            wkWebView.addSubview(refreshLabel)
            wkWebView.addSubview(refreshButton)
            wkWebView.addSubview(activityIndicator)
            
            refreshLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(50)
            }
            
            refreshButton.snp.makeConstraints { make in
                make.top.equalTo(refreshLabel.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(60)
            }
            
            activityIndicator.isHidden = true
            activityIndicator.snp.makeConstraints { make in
                make.top.equalTo(refreshLabel.snp.bottom).offset(12)
                make.centerX.equalToSuperview()
                make.width.height.equalTo(60)
            }
        }
        
        let htmlString = wkWebView.htmlSetting(string: string)
        wkWebView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
           if navigationAction.navigationType == WKNavigationType.linkActivated,
              let url = navigationAction.request.url {
                linkDetector.onNext(url.absoluteString)
               decisionHandler(WKNavigationActionPolicy.cancel)
               return
           }
           decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight",
                                   completionHandler: { [weak self] (height, error) in
            guard let self else { return }
            let float = height as! CGFloat
            self.webViewHeight = float
            self.remakeWkWebViewHeight(height: float)
            self.wkWebView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                self?.wkWebView.isHidden = false
            }
        })
    }
}


//MARK: View Autolayout,Animation 액션
extension ProblemPopUpView{
    
    private var flag: Bool {
        get{
            popUpFlag
        }set{
            popUpFlag = newValue
        }
    }
    
    @objc func hidebuttonTapped(_ sender: UIButton){
        self.impact()
        flag == true ? show() : hide(completion: {})
        flag.toggle()
    }
    
    func settingEditor(type: EditorTypeProtocol) {
        if type.isOnlyEditor() {
            self.editorTitleField.isHidden = false
            self.hideButton.isHidden = true
            self.problemStepButton.isHidden = true
            self.wkWebView.isHidden = true
            self.sendButton.originalButtonText = "저장하기"
        }
    }
    
    func show() {
        showRemakeAnimation()
        
        self.delegate!.showProblemDiscription()

        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.popUpContainerView.alpha = 1
                self?.scrollView.alpha = 1
                self?.delegate!.view.layoutIfNeeded()
                self?.layoutIfNeeded()
                self?.resultStatusView.layoutIfNeeded()
                self?.submissionListView.layoutIfNeeded()
                // self.popUpContainerView.layoutIfNeeded()
            },
            completion: { _ in
                print(self.frame)
            }
        )
    }
    
    func hide(completion: (() -> Void)? ) {
        let buttonHeight: CGFloat = 44
        hideRemakeAnimation()
        self.delegate!.dismissProblemDiscription(button: buttonHeight)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.popUpContainerView.alpha = 0
                self.scrollView.alpha = 0
                self.delegate!.view.layoutIfNeeded()
            },
            completion: { flag in
                if flag == true,
                   completion != nil {
                    completion!()
                }
            }
        )
    }
    
    private func hiddenAlphaEnable(result: SolveResultType) {
        
        if case .resultList = result {
             scrollView.isScrollEnabled = false
             scrollView.resignFirstResponder()
             submissionListView.tableView.becomeFirstResponder()
        } else {
             scrollView.isScrollEnabled = true
             scrollView.becomeFirstResponder()
             submissionListView.tableView.resignFirstResponder()
        }
        
        let views: [(UIView, UIButton)] =
        [
            (wkWebView, problemStepButton),
            (resultStatusView, resultStepButton),
            (submissionListView, submissionListStepButton)
        ]
        
        let types: [SolveResultType] = [.problem, .result(nil), .resultList([])]
        let zip = zip(views, types)
        
        zip.forEach { value in
            let (view,button) = value.0
            let type = value.1
            let state = result.isEqualStep(step: type)
            view.isHidden = !state
            button.isEnabled = !state
            button.alpha = state ? 1 : 0.5
        }
    }
    
    private func remakeWkWebViewHeight(height: CGFloat){
        let height = self.webViewHeight
        hiddenAlphaEnable(result: .problem)
        
        self.wkWebView.snp.remakeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(height)
            $0.bottom.equalToSuperview()
        }
        
        // TODO: autolayout warnig resultStatusView 의 레이아웃 수정 해야함
        self.popUpContainerView.layoutIfNeeded()
    }
    
    private func remakeResultStatus(height: CGFloat = 300) {
        hiddenAlphaEnable(result: .result(nil))
        
        resultStatusView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func remakeSubmissionListResults(height: CGFloat) {
        hiddenAlphaEnable(result: .resultList([]))
        
        submissionListView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300) // TODO: 고정 상수값 -> 변경
            make.bottom.equalToSuperview().priority(.low)
        }
    }
    
    private func autoLayout() {
        [scrollView,
         hideButton,
         sendButton].forEach { view in
            self.addSubview(view)
        }
        
        scrollView.addSubview(popUpContainerView)
        
        [backButton,
         problemTitle,
         languageButton,
         problemStepButton,
         heartButton,
         resultStepButton,
         submissionListStepButton,
         editorTitleField
        ].forEach { view in
            self.addSubview(view)
        }
        
        
        // TODO: fix AutoLayout constraint
        [wkWebView, resultStatusView, submissionListView].forEach{
            popUpContainerView.addSubview($0)
        }
        
        
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(200).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        popUpComponentSetUp()
        popUpContentSetUp()
        
        popUpContainerView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(44)
            $0.height.equalTo(UIScreen.main.bounds.height / 2).priority(.low) //.priority(.low)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        editorTitleField.isHidden = true
        
        editorTitleField.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(5)
            make.trailing.equalTo(languageButton.snp.leading).offset(5)
            make.height.equalTo(40)
            make.centerY.equalTo(languageButton.snp.centerY)
        }
    }
    
    
    // MARK: WebView, 결과 뷰, 제출리스트 현황 뷰
    private func popUpContentSetUp() {
        submissionListView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300).priority(.low)
            make.bottom.equalToSuperview()
        }
        
        //        resultStatusView.isHidden = true
        resultStatusView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300).priority(.low)
            make.bottom.equalToSuperview()
        }
        
        wkWebView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 백버튼, 언어 버튼, 숨김버튼, 제출 버튼, (문제, 결과, 제출현황) 버튼 리스트
    private func popUpComponentSetUp() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.bottom.equalToSuperview().priority(.high)
            make.width.height.equalTo(44)
        }
        
        problemTitle.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(8)
            make.trailing.greaterThanOrEqualTo(languageButton.snp.leading).offset(-8)
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton.snp.centerY)
        }
         problemTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        

        languageButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        languageButton.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(hideButton.snp.centerY)
            make.trailing.equalTo(sendButton.snp.leading).offset(-leading_trailing_spacing - 5)
        }
        
        problemStepButton.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(leading_trailing_spacing + 2)
            make.centerY.equalTo(hideButton.snp.centerY)
        }
        
        heartButton.isHidden = true
        resultStepButton.isHidden = true
        submissionListStepButton.isHidden = true
      
        heartButton.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.centerX.equalTo(languageButton.snp.centerX)
            make.centerY.equalTo(problemStepButton.snp.centerY)
        }
        
        resultStepButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalTo(problemStepButton.snp.trailing).offset(leading_trailing_spacing)
            make.height.equalTo(44).priority(.low)
        }
        
        submissionListStepButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalTo(resultStepButton.snp.trailing).offset(leading_trailing_spacing)
            make.height.equalTo(44).priority(.low)
        }
        
        hideButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().priority(.high)
            make.width.height.equalTo(button_width_height).priority(.high)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
            make.width.equalTo(sendButton.sendButtonWidth)
            make.height.equalTo(sendButton.sendButtonHeight)
            make.centerY.equalTo(hideButton.snp.centerY)
        }
    }
}

//MARK: View 오토레이아웃 재생성
extension ProblemPopUpView {
    
    func showRemakeAnimation() {
        problemTitle.isHidden = false
        resultStepButton.isHidden = false
        submissionListStepButton.isHidden = false
        heartButton.isHidden = false
        submissionListView.setHidden(false)
        down_remake_scrollView()
        down_remake_hideButton()
        down_remake_numberStepButton()
        down_remake_backButton()
        down_remake_languageButton()
    }
    
    func hideRemakeAnimation() {
        problemTitle.isHidden = true
        resultStepButton.isHidden = true
        submissionListStepButton.isHidden = true
        heartButton.isHidden = true
        submissionListView.setHidden(true)
        up_remake_scrollView()
        up_remake_hideButton(height: 44)
        up_remake_numberStepButton()
        up_remake_backButton()
        up_remake_languageButton()
    }
}



//MARK: Down Animation AutoLayout
extension ProblemPopUpView{
    
    private func down_remake_hideButton(){
        hideButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        hideButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    private func down_remake_backButton(){
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    private func down_remake_scrollView(){
        scrollView.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(button_width_height * 2 + 5)
            make.height.equalTo(200).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(button_width_height)
        }
    }
    
    private func down_remake_languageButton(){
        languageButton.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
    }
    
    private func down_remake_numberStepButton(){
        problemStepButton.snp.remakeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(leading_trailing_spacing + 8)
        }
    }
}


//MARK: -UP Animation AutoLayout
extension ProblemPopUpView{
    private func up_remake_scrollView(){
        scrollView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(200).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func up_remake_hideButton(height: CGFloat){
        hideButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        hideButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().priority(.high)
            make.width.equalTo(height)
            make.height.equalTo(height)
        }
    }
    
    private func up_remake_backButton(){
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.bottom.equalToSuperview().priority(.high)
            make.width.height.equalTo(44)
        }
    }
    
    private func up_remake_numberStepButton(){
        problemStepButton.snp.remakeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(leading_trailing_spacing + 2)
            make.centerY.equalTo(hideButton.snp.centerY)
        }
    }
    
    private func up_remake_languageButton(){
        languageButton.snp.remakeConstraints { make in
            make.height.equalTo(sendButton.snp.height)
            make.centerY.equalTo(hideButton.snp.centerY)
            make.leading.equalTo(hideButton.snp.trailing).offset(8)
            make.trailing.equalTo(sendButton.snp.leading).offset(-leading_trailing_spacing - 3)
        }
    }
}
