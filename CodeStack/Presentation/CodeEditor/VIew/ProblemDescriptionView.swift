//
//  ProblemDescriptionView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/23.
//

import UIKit
import SnapKit
import WebKit
import RxCocoa
import RxSwift
import RxGesture




final class ProblemPopUpView: UIView{
    
    private var popUpFlag: Bool = false
    
    let pagingTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        
        return tableView
    }()
    
    lazy var scrollView: CustomScrollView = {
        let scrollView = CustomScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    
    private lazy var problemStepButton: NumberButton = {
       let button = NumberButton()
        button.settingNumber(for: 1)
        button.settingText(for: "문제")
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    typealias ResultButton = NumberButton

    private lazy var resultStepButton: ResultButton = {
       let button = ResultButton()
        button.settingNumber(for: 2)
        button.settingText(for: "결과")
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    typealias PopUpcontainer = UIView
    private lazy var popUpContainerView: PopUpcontainer = {
        let containerView = PopUpcontainer()
        return containerView
    }()
    
    lazy var backButton: BackButton = {
        let button = BackButton()
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var hideButton: HideButton = {
        let button = HideButton().makeHideButton(height: button_width_height)
        button.addTarget(self, action: #selector(hidebuttonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 문제 제출 버튼
    private lazy var sendButton: SendButton = {
        let button = UIButton().makeSendButton()
        button.addTarget(self, action: #selector(feedBackGenerate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var languageButton: LanguageButton = {
        let button = LanguageButton().makeLanguageButton()
        return button
    }()
    
    // 결과 보여주는 뷰
    private lazy var resultStatusView: ReusltStatusView = {
        let resultStatusView = ReusltStatusView()
        resultStatusView.isHidden = true
        return resultStatusView
    }()
    
    // 문제 보여주는 웹뷰
    private lazy var wkWebView: WKWebView = {
        let webView = WKWebView().makeWebView()
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        return webView
    }()
    
    private weak var delegate: CodeEditorViewController?
    
    private let button_width_height: CGFloat = 44
    
    private let vertical_spacing: CGFloat = 25
    
    private let leading_trailing_spacing: CGFloat = 8
    
    lazy var languageRelay = BehaviorRelay<Language>(value: languages.first!)
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    private var webViewHeight: CGFloat = 0
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        autoLayout()
    }
    
    convenience init(frame: CGRect, _ delegate: CodeEditorViewController) {
        self.init(frame: frame)
        self.delegate = delegate
        self.backgroundColor = .clear
        problemGestureAction()
        resultGestureAction()
        observingPage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError occur!")
    }
    
    deinit{
        Log.debug("deinit")
    }
    
    let pageValue = BehaviorRelay<SolveResultType>(value: .problem)
    
    
    @objc func feedBackGenerate(_ button: UIButton){
        feedbackGenerator.impactOccurred()
    }
    
    //MARK: - Observing Event
    private func observingPage(){
        pageValue.subscribe(with: self,
                            onNext: { vm, page in
            switch page{
            case .problem:
                vm.wkWebView.isHidden = false
                vm.resultStatusView.isHidden = true
                vm.problemStepButton.alpha = 1
                vm.resultStepButton.alpha = 0.5
                vm.problemStepButton.isEnabled = false
                vm.resultStepButton.isEnabled = true
                vm.remakeWkWebViewHeight(height: vm.webViewHeight)
                
            case .result(let submission):
                vm.wkWebView.isHidden = true
                vm.resultStatusView.isHidden = false
                vm.problemStepButton.alpha = 0.5
                vm.resultStepButton.alpha = 1
                vm.problemStepButton.isEnabled = true
                vm.resultStepButton.isEnabled = false
                vm.remakeResultStatus(height: 300,priority: .high)
                vm.scrollView.contentOffset = CGPoint.zero
                guard let submission else { return }
                vm.resultStatusView.status.onNext(submission)
            }
        }).disposed(by: disposeBag)
    }
    
    
    private func problemGestureAction() {
        
        problemStepButton.container.rx.gesture(.tap())
            .when(.recognized).asDriver(onErrorJustReturn: .init())
            .drive(with: self,
                   onNext: { view, _ in
                view.feedbackGenerator.impactOccurred()
                view.pageValue.accept(.problem)
            }).disposed(by: disposeBag)
    }
    
    private func resultGestureAction() {
        resultStepButton.container.rx.gesture(.tap())
            .when(.recognized).asDriver(onErrorJustReturn: .init())
            .drive(with: self,
                   onNext: { view, _ in
                view.feedbackGenerator.impactOccurred()
                view.pageValue.accept(.result(nil))
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Binding To ViewModel
    func dissmissAction() -> Driver<Void>{
        return backButton.rx.tap.asDriver()
    }
    
    func sendSubmissionAction() -> Driver<Void>{
        return sendButton.rx.tap.asDriver()
    }
    
    func languageAction() -> Driver<Language>{
        return languageRelay.asDriver()
    }
    
    /// 언어 모델
    private var languages: [Language] = []
    
    /// 언어 Title Action && languageRelay에 값 전달 -> ViewModel로 데이터 전달
    private lazy var setTitleAction: (UIAction) -> () = { [weak self] action in
        guard let self else {return}
        self.languageButton.setTitle(action.title, for: .normal)
        if let value = languages.filter({ $0.name == action.title }).first{
            self.languageRelay.accept(value)
        }
    }
    
    /// 언어 설정 하기 위한 함수
    /// - Parameter languages: 언어 배열
    func setLangueMenu(languages: [Language]){
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
        let htmlString = wkWebView.htmlSetting(string: string)
        wkWebView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight",
                                   completionHandler: { [weak self] (height, error) in
            
            guard let self else { return }
            let float = height as! CGFloat
            self.webViewHeight = float
            self.remakeWkWebViewHeight(height: float)
        })
        
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
            if let htmlString = html as? String {
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
        feedbackGenerator.impactOccurred()
        flag == true ? show() : hide(completion: nil)
        flag.toggle()
    }
    
    func show(){
        showRemakeAnimation()
        
        self.delegate!.showProblemDiscription()

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.popUpContainerView.alpha = 1
                self.scrollView.alpha = 1
                self.delegate!.view.layoutIfNeeded()
                self.layoutIfNeeded()
                self.popUpContainerView.layoutIfNeeded()
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
                Log.debug("\(self.frame)")
                if flag == true,
                   completion != nil{
                    completion!()
                }
            }
        )
    }
    
    private func configure() {
        self.backgroundColor = .tertiarySystemBackground
    }
    
    private func remakeWkWebViewHeight(height: CGFloat){
        let height = self.webViewHeight
        
        popUpContainerView.snp.remakeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(44)
            $0.height.equalTo(434).priority(.low)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.wkWebView.snp.remakeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(height)
            $0.bottom.equalToSuperview()
        }
    
        self.popUpContainerView.layoutIfNeeded()
    }
    
    private func remakeResultStatus(height: CGFloat = 300, priority: ConstraintPriority = .medium){
        
        popUpContainerView.snp.remakeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(44)
            $0.height.equalTo(300)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        resultStatusView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        UIView.animate(withDuration: 1.0) {
            self.resultStatusView.layoutIfNeeded()
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
         languageButton,
         problemStepButton,
         resultStepButton
        ].forEach { view in
            self.addSubview(view)
        }
        
        [wkWebView,resultStatusView].forEach{
            popUpContainerView.addSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        languageButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(30)
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        problemStepButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.height.equalTo(44).priority(.low)
        }
        
        resultStepButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalTo(problemStepButton.snp.trailing).offset(leading_trailing_spacing)
            make.height.equalTo(44).priority(.low)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(resultStepButton.snp.bottom)//.inset(button_width_height * 2 + 5)
            make.height.equalTo(200).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(button_width_height)
        }
        
        hideButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(button_width_height).priority(.high)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
            make.centerY.equalTo(hideButton.snp.centerY)
        }
        
        popUpContainerView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(44)
            $0.height.equalTo(434).priority(.low) //.priority(.low)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
    
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
}


//MARK: View 오토레이아웃 재생성
extension ProblemPopUpView{
    
    
    func showRemakeAnimation(){
        down_remake_scrollView()
        down_remake_hideButton()
        down_remake_numberStepButton()
        down_remake_backButton()
        down_remake_resultStepButton()
        down_remake_languageButton()
    }
    
    func hideRemakeAnimation(){
        up_remake_scrollView()
        up_remake_hideButton(height: 44)
        up_remake_numberStepButton()
        up_remake_backButton()
        up_remake_resultStepButton()
        up_remake_languageButton()
    }
    
    
    private func down_remake_scrollView(){
        scrollView.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(button_width_height * 2 + 5)
            make.height.equalTo(200).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(button_width_height)
        }
    }
    
    private func up_remake_scrollView(){
        scrollView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(200).priority(.low)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    
    private func down_remake_hideButton(){
        hideButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        hideButton.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
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
    
    private func down_remake_backButton(){
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    private func up_remake_backButton(){
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.bottom.equalToSuperview().priority(.high)
            make.width.height.equalTo(44)
        }
    }
    
    private func down_remake_numberStepButton(){
        problemStepButton.snp.remakeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(leading_trailing_spacing + 8)
        }
    }
    
    private func up_remake_numberStepButton(){
        problemStepButton.snp.remakeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(leading_trailing_spacing + 2)
            make.centerY.equalTo(hideButton.snp.centerY)
        }
    }
    
    private func down_remake_resultStepButton(){
        resultStepButton.isHidden = false
    }
    private func up_remake_resultStepButton(){
        resultStepButton.isHidden = true
    }
    
    
    private func down_remake_languageButton(){
        languageButton.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
    }
    
    private func up_remake_languageButton(){
        languageButton.snp.remakeConstraints { make in
            make.height.equalTo(30)
            make.centerY.equalTo(hideButton.snp.centerY)
            make.trailing.equalTo(sendButton.snp.leading).offset(-leading_trailing_spacing - 5)
        }
    }
}
