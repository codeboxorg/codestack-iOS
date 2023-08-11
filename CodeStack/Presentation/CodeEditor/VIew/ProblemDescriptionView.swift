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


final class ProblemPopUpView: UIView{
    
    var popUpFlag: Bool = false
    
    lazy var scrollView: CustomScrollView = {
        let scrollView = CustomScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private let topNaviagtionView: UIView = {
       let nav = UIView()
        return nav
    }()
    
    private let problemStepButton: NumberButton = {
       let button = NumberButton()
        button.settingText(for: "문제")
        button.settingNumber(for: 1)
        return button
    }()
    
    private let resultStepButton: NumberButton = {
       let button = NumberButton()
        button.settingText(for: "결과")
        button.settingNumber(for: 2)
        return button
    }()
    
    private lazy var popUpContainerView: UIView = {
        let containerView = UIView()
        return containerView
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = UIColor.systemGray
        button.imageView?.contentMode = .scaleAspectFill
        
        return button
    }()
    
    lazy var hideButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(hidebuttonTapped(_:)), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = UIColor.black
        button.tintColor = UIColor.systemPink
        button.layer.cornerRadius = button_width_height / 2
        return button
    }()
    
    /// 문제 제출 버튼
    private let sendButton: UIButton = {
        let view = UIButton()
        view.setTitle("제출하기", for: .normal)
        view.tintColor = .sky_blue
        return view
    }()
    
    private let languageButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    
    
    private lazy var wkWebView: WKWebView = {
        
        guard let path = Bundle.main.path(forResource: "style", ofType: "css") else {
            return WKWebView()
        }
        
        let cssString = try! String(contentsOfFile: path).components(separatedBy: .newlines).joined()
        
        Log.debug(cssString)
        
        let source = """
              var style = document.createElement('style');
              style.innerHTML = '\(cssString)';
              document.head.appendChild(style);
            """
        
        let userScript = WKUserScript(source: source,
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero,
                                configuration: configuration)
        
        
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        Log.debug(source)
        return webView
    }()
    
    private weak var delegate: CodeEditorViewController?
    
    private let button_width_height: CGFloat = 44
    
    private let vertical_spacing: CGFloat = 25
    
    private let leading_trailing_spacing: CGFloat = 8
    
    lazy var languageRelay = BehaviorRelay<Language>(value: languages.first!)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        autoLayout()
    }
    
    convenience init(frame: CGRect, _ delegate: CodeEditorViewController) {
        self.init(frame: frame)
        self.delegate = delegate
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError occur!")
    }
    
    deinit{
        Log.debug("deinit")
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
    
    /// Load To WebView HTMLString
    /// - Parameter string: HTML String
    func loadHTMLToWebView(html string: String) {
        let htmlStart = "<!DOCTYPE html><head> <meta charset=\"utf-8\"> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></head><body>"
        let htmlEnd = "</body></html>"
        let htmlString = "\(htmlStart)\(string)\(htmlEnd)"
        
        wkWebView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    
    private var languages: [Language] = []
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.scrollHeight",
                                   completionHandler: { [weak self] (height, error) in
            
            guard let self else { return }
            
            self.wkWebView.snp.remakeConstraints{
                $0.top.equalToSuperview()
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(height as! CGFloat)
                $0.bottom.equalToSuperview()
            }
        })
        
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, error: Error?) in
            if let htmlString = html as? String {
                // HTML을 출력하거나 원하는 작업을 수행합니다.
//                print("__________________\n")
//                print("\(htmlString)")
//                print("__________________")
            }
        })
    }
}



//MARK: View 오토레이아웃 재생성
extension ProblemPopUpView{
    
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
            make.centerY.equalToSuperview()
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
            make.centerY.equalToSuperview()
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
            make.centerY.equalToSuperview()
        }
    }
    
    private func down_remake_resultStepButton(){
        resultStepButton.alpha = 1
    }
    private func up_remake_resultStepButton(){
        resultStepButton.alpha = 0
    }
    
    
    private func down_remake_languageButton(){
        languageButton.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
    }
    
    private func up_remake_languageButton(){
        languageButton.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.trailing.equalTo(sendButton.snp.leading).offset(-leading_trailing_spacing - 10)
        }
    }
}


//MARK: View Autolayout,Animation 액션
extension ProblemPopUpView{
    
    @objc func hidebuttonTapped(_ sender: UIButton){
        popUpFlag == true ? show() : hide(completion: nil)
        popUpFlag.toggle()
    }
    
    func show(){
        self.delegate!.showProblemDiscription()
        
        down_remake_hideButton()
        down_remake_backButton()
        down_remake_numberStepButton()
        down_remake_resultStepButton()
        down_remake_languageButton()
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
//                self.popUpContainerView.backgroundColor = .tertiarySystemBackground
                self.popUpContainerView.alpha = 1
                self.delegate!.view.layoutIfNeeded()
                self.layoutIfNeeded()
                self.popUpContainerView.layoutIfNeeded()
            },
            completion: { _ in
            }
        )
    }
    
    func hide(completion: (() -> Void)? ) {
        
        let buttonHeight: CGFloat = 44
        self.delegate!.dismissProblemDiscription(button: buttonHeight)
        
        up_remake_hideButton(height: buttonHeight)
        up_remake_backButton()
        up_remake_numberStepButton()
        up_remake_resultStepButton()
        up_remake_languageButton()
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.popUpContainerView.alpha = 0
                self.delegate!.view.layoutIfNeeded()
            },
            completion: { flag in
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
         resultStepButton].forEach { view in
            self.addSubview(view)
        }
        
        [wkWebView].forEach{
            popUpContainerView.addSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
            make.top.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        languageButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(44)
            make.trailing.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        problemStepButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(leading_trailing_spacing)
        }
        
        resultStepButton.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(5)
            make.leading.equalTo(problemStepButton.snp.trailing).offset(leading_trailing_spacing)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(problemStepButton.snp.bottom).offset(5)
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
            $0.bottom.equalToSuperview().offset(-30)
            $0.height.equalTo(434).priority(.low) //.priority(.low)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
    
        wkWebView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
