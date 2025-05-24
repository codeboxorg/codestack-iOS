

import UIKit
import CommonUI
import Then
import Highlightr
import Global

final class ResultViewController: BaseViewController {
    
    lazy var textView: UITextView = {
        let label = UITextView()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white
        label.backgroundColor = .black
        return label
    }()
    
    private var result: String = ""
    
    static func create(with result: String) -> ResultViewController {
        let vc = ResultViewController()
        vc.result = result
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(equalToConstant: 300),
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        
        textView.text = result
    }
}

final class CodeViewController: BaseViewController {
    
    private let editor        : some EditorWrapper = DefaultEditorWrapper(frame: .zero)
    private let codeSendButton: some Loading = SendButton.create(font: .boldSystemFont(ofSize: 10))
    
    private lazy var availableThemes: [String] = getAvailableThemes() // Replace with your own theme loader
    private var selectedThemeIndex: Int = 0
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait } // 또는 .portraitUpsideDown 포함 가능
    override var shouldAutorotate: Bool { false }
    
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
        view.addSubview(editor)
        editor.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide.snp.edges)
        }
        
        configureSettingButton()
        configureThemePicker()
        configureCodeSendButton()
        
        view.bringSubviewToFront(settingButton)
        view.bringSubviewToFront(themePickerView)
        view.bringSubviewToFront(codeSendButton)
        
        codeSendButton.addAction(
            UIAction(handler: { [weak self] action in
                guard
                    let code = self?.editor.code,
                    let base64 = code.data(using: .utf8)?.base64EncodedString()
                else {
                    return
                }
                Task {
                    do {
                        let service = TestSubmissions()
                        let result = try await service.post(base64: base64)
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        let result2 = try await service.fetchResult(using: result)
                        let vc = ResultViewController.create(with: result2.description)
                        self?.show(vc, sender: nil)
                    } catch {
                        Log.debug(error)
                    }
                }
            }),
            for: .touchUpInside
        )
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
    
    private func configureCodeSendButton() {
        view.addSubview(codeSendButton)
        codeSendButton.snp.makeConstraints { make in
            make.top.equalTo(self.settingButton.snp.bottom)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing).inset(16)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
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
            editor.resignTextView()
        }

        UIView.animate(withDuration: 0.3) {
            self.themePickerView.transform = isHidden ? .identity : CGAffineTransform(translationX: 0, y: 200)
            self.themePickerView.alpha = isHidden ? 1 : 0
        }
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
        editor.applyTheme(theme)
    }
}

