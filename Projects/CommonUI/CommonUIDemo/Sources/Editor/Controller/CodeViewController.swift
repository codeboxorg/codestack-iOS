//
//  CodeViewController.swift
//  CommonUIDemo
//
//  Created by hwan on 3/25/25.
//  Copyright © 2025 com.hwan. All rights reserved.
//

import UIKit
import CommonUI
import Then
import Highlightr
import SafariServices
import Global

final class CodeViewController: BaseViewController {
    
    var editorContainerView = EditorContainerView.init(frame: .zero)
    lazy var undoableManager  : UndoableManager  = DefaultUndoableManager(editor: self.editor)
    lazy var suggestionLayout : SuggestionLayout = SuggestionLayoutManager(editor: self.editor)
    private let wordSuggestion: WordSuggenstion  = DefaultWordSuggenstion()
    
    lazy var suggestionManager: SuggestionManager = DefaultSuggestionManager(
       dependency: .init(
           suggestion: self.wordSuggestion,
           editor: self.editor,
           suggestionLayout: self.suggestionLayout,
           suggestionCommand: SuggestionCommand(
               editor: self.editor,
               invoker: self.undoableManager
           )
       )
   )
    
    var editor             : UITextView { self.editorContainerView.codeUITextView }
    var changeSelected     : ChangeSelectedRange { self.editorContainerView.numbersView as ChangeSelectedRange }
    var textViewWidthUpdate: TextViewWidthUpdateProtocol { self.editorContainerView as TextViewWidthUpdateProtocol }
    
    lazy var editorController = EditorController(
        dependency: .init(
            textView: self.editor,
            changeSelecteRange: self.changeSelected,
            widthUpdater: self.textViewWidthUpdate,
            undoableManager: self.undoableManager,
            suggestionManager: self.suggestionManager,
            suggestionLayout: self.suggestionLayout,
            textInputCommandExcuteManager: TextInputCommandExcuteManager(
                editor: self.editor,
                undoableManager: self.undoableManager,
                suggestionManager: self.suggestionManager,
                suggestionLayoutManger: self.suggestionLayout
            ),
            buttonCommandExecuteManager: DefaultButtonCommandExecuteManager(
                editor: self.editor,
                undoableManager: self.undoableManager
            )
        )
    )
    
    private lazy var availableThemes: [String] = getAvailableThemes() // Replace with your own theme loader
    private var selectedThemeIndex: Int = 0

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait // 또는 .portraitUpsideDown 포함 가능
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    private lazy var themePickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .systemBackground
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private lazy var settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("⚙️", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        editorContainerView.codeUITextView.layoutManager.delegate = self.editorController
        editorContainerView.codeUITextView.delegate = self.editorController
        layoutConfigure()
        configureSettingButton()
        configureThemePicker()
        addKeyboardObserver()
    }
    
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self = self,
                  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

            UIView.animate(withDuration: duration) {
                self.editorContainerView.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                        .inset(keyboardFrame.height - self.editorController.inputViewLayoutManager.toolBarHeight)
                }
                self.view.layoutIfNeeded()
            }
        }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
            guard let self = self,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

            UIView.animate(withDuration: duration) {
                self.editorContainerView.snp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func configureSettingButton() {
        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(16)
            make.width.height.equalTo(36)
        }
    }
    
    private func configureThemePicker() {
        view.addSubview(themePickerView)
        themePickerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(200)
        }

        themePickerView.transform = CGAffineTransform(translationX: 0, y: 200)
        themePickerView.alpha = 0
    }
    
    private func getAvailableThemes() -> [String] {
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: HighlightrResources.bundle.bundlePath) else {
            Log.debug("Highlightr.bundle not found")
            return []
        }
        let themes = fileNames
            .filter { $0.hasSuffix(".min.css") }
            .map { $0.replacingOccurrences(of: ".min.css", with: "") }
        return themes
    }
    
    @objc private func didTapSetting() {
        let isHidden = themePickerView.alpha == 0
        
        if isHidden {
            themePickerView.selectRow(selectedThemeIndex, inComponent: 0, animated: false)
            if editorContainerView.codeUITextView.isFirstResponder {
                editorContainerView.codeUITextView.resignFirstResponder()
            }
        }

        UIView.animate(withDuration: 0.3) {
            self.themePickerView.transform = isHidden ? .identity : CGAffineTransform(translationX: 0, y: 200)
            self.themePickerView.alpha = isHidden ? 1 : 0
        }
    }
    
    private func applyTheme(_ theme: String) {
        self.editorContainerView.highlightr?.setTheme(to: theme)
        let color = self.editorContainerView.highlightr?.theme.themeBackgroundColor
        self.editorContainerView.numberTextViewContainer.backgroundColor = color
        self.editorContainerView.codeUITextView.backgroundColor = color
        self.editorContainerView.numbersView.backgroundColor = color
    }
}

//MARK: - 코드 문제 설명 뷰의 애니메이션 구현부
extension CodeViewController {
    func showProblemDiscription() {
        editorContainerView.numbersView.layer.setNeedsDisplay()
    }
    
    //이거 먼저 선언
    func dismissProblemDiscription(button height: CGFloat = 44){
        editorContainerView.numbersView.layer.setNeedsDisplay()
    }
}

//MARK: - layout setting
extension CodeViewController {
    private func layoutConfigure() {
        self.view.addSubview(editorContainerView)
        editorContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(self.view.snp.height).priority(.low)
        }
    }
}

extension CodeViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CodeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableThemes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableThemes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedThemeIndex = row
        let theme = self.availableThemes[row]
        applyTheme(theme)
    }
}
