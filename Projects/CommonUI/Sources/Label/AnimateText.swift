
import UIKit
import SwiftHangeul
import Combine
import SnapKit
import RxSwift

open class AnimateTextViewController: UIViewController {
    
    public lazy var animateTextLabel: [AnimateTextLabel] = []
    var stackView = UIStackView()
    var refreshButton = UIButton()
    var disposeBag = DisposeBag()
    var subscriptions = Set<AnyCancellable>()
    var containers = AnimateContainer()
    var animateFont: [UIFont] = []
    
    public override func viewDidLoad() {
        
        let text1 = """
        Hi my name is HyeongHwan Park My Dream is become to succesful person , now days im working hard push my self hard working!
        """
        
        let label1 = AnimateTextLabel.init(text: text1)
        let label2 = AnimateTextLabel.init(text: "저를 소개합니다")
        let label3 = AnimateTextLabel.init(text: "저는 무언가가 되고 싶은 사람입니다.")
        let label4 = AnimateTextLabel.init(text: "열심히 하겠습니다.")
        
        animateTextLabel.append(label1)
        animateTextLabel.append(label2)
        animateTextLabel.append(label3)
        animateTextLabel.append(label4)
        
        containers.append(label: label1)
        containers.append(label: label2)
        containers.append(label: label3)
        containers.append(label: label4)
        
        zip(animateTextLabel, animateFont).forEach {
            $0.0.font = $0.1 
            $0.0.textColor = .whiteGray
            stackView.addArrangedSubview($0.0)
        }
        
        addAutoLayout()
        self.view.backgroundColor = .black
        refreshButton.gesture(.tap())
            .sink(receiveValue: { [weak self] _ in
                guard let vc = self else { return }
                let value = [0].randomElement()!
                if value == 4 { vc.containers.startInOrder() }
                else { vc.containers.start(index: value) }
            }).store(in: &subscriptions)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        containers.startInOrder()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func setFont(_ font: [UIFont]) {
        self.animateFont = font
    }
    
    func addAutoLayout() {
        view.addSubview(stackView)
        view.addSubview(refreshButton)
        
        refreshButton.setImage(UIImage.add, for: .normal)
        refreshButton.tintColor = .systemPink
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(12)
            make.centerX.equalToSuperview()
            make.top.height.equalTo(44)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(100)
            make.leading.trailing.equalToSuperview().inset(40)
        }
    }
}

public enum AnimateText: Equatable {
    case start(UUID)
    case progress(String)
    case text(Character)
    case end
    case none
}

public final class AnimateContainer {
    var labels: [AnimateTextLabel] = []
    var uuids: [UUID: AnimateTextLabel] = [:]
    var subscriptions: AnyCancellable?
    
    func append(label: AnimateTextLabel) {
        labels.append(label)
        uuids[label.id] = label
    }
    
    func start(index: Int) {
        cancel(index: index)
        if let label = labels[safe: index] {
            label.animateTextStart()
        }
    }
    
    func start(id: UUID) {
        cancel(id: id)
        if let label = uuids[id] {
            label.animateTextStart()
        }
    }
    
    private var currentUUID: UUID?
    
    func startInOrder() {
        cancelAll()
        let maps = labels.map { $0.timerTextPublisher() }
        subscriptions = ConcatenateBuild.build(maps)
            .sink(
                receiveValue: { [weak self] text in
                if case let .start(id) = text {
                    self?.currentUUID = id
                    if let label = self?.uuids[id] { label.text = "" }
                }
                if case let .progress(strs) = text,
                   let id = self?.currentUUID,
                   let label = self?.uuids[id] {
                    label.text = strs
                }
            })
    }
    
    func cancel(id: UUID) {
        if let label = uuids[id] {
            label.cancel()
            label.text = ""
        }
    }
    
    func cancel(index: Int) {
        if let label = labels[safe: index] {
            label.cancel()
            label.text = ""
        }
    }
    
    func cancelAll() {
        subscriptions?.cancel()
        labels.forEach {
            $0.text = ""
            $0.cancel()
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct ConcatenateBuild {
    private static func makeConcat<Item: Equatable>(_ first: AnyPublisher<Item,Never>, _ second: AnyPublisher<Item,Never>) -> some Publisher<Item, Never> {
        Publishers.Concatenate(prefix: first, suffix: second)
    }
    
    static func build<Item: Equatable>(_ pub: [AnyPublisher<Item,Never>])
    -> some Publisher<Item, Never> {
        switch pub.count {
        case 2:
            return makeConcat(pub[0], pub[1]).eraseToAnyPublisher()
        case 3:
            let first = makeConcat(pub[0], pub[1]).eraseToAnyPublisher()
            return makeConcat(first, pub[2]).eraseToAnyPublisher()
        case 4:
            let first = makeConcat(pub[0], pub[1]).eraseToAnyPublisher()
            let second = makeConcat(first, pub[2]).eraseToAnyPublisher()
            return makeConcat(second, pub[3]).eraseToAnyPublisher()
        case 5:
            let first = makeConcat(pub[0], pub[1]).eraseToAnyPublisher()
            let second = makeConcat(first, pub[2]).eraseToAnyPublisher()
            let third = makeConcat(second, pub[3]).eraseToAnyPublisher()
            return makeConcat(third, pub[4]).eraseToAnyPublisher()
            
        case 6:
            let first = makeConcat(pub[0], pub[1]).eraseToAnyPublisher()
            let second = makeConcat(first, pub[2]).eraseToAnyPublisher()
            let third = makeConcat(second, pub[3]).eraseToAnyPublisher()
            let four = makeConcat(third, pub[4]).eraseToAnyPublisher()
            return makeConcat(four, pub[5]).eraseToAnyPublisher()
        default:
            return Empty<Item, Never>().eraseToAnyPublisher()
        }
    }
}

public protocol AnimateTextType: AnyObject {
    var id: UUID { get set }
    var seconds: TimeInterval! { get set }
    var animateText: String! { get set }
    var defaultText: String! { get set }
    var swiftHanguel: SwiftHangeul { get set }
    var separatedText: [AnimateText] { get }
    var timerSubscriptions: AnyCancellable? { get set }
    var gestureSubscription: AnyCancellable? { get }
}

public extension AnimateTextType {
    
    var gestureSubscription: AnyCancellable? { nil }
    
    func cancel() {
        timerSubscriptions?.cancel()
//        swiftHanguel.clear()
    }
    
    func timerTextPublisher(separted text: [AnimateText] = []) -> AnyPublisher<AnimateText, Never> {
//        swiftHanguel.clear()
        let timer
        = Timer.publish(every: seconds, on: RunLoop.main, in: .default).autoconnect()
        
        let text = text.isEmpty ? separatedText : text
        
        return Publishers.Zip(text.publisher, timer)
            .receive(on: DispatchQueue.main)
            .map(\.0)
            .handleEvents(receiveOutput:  { [weak self] char in
                if case let .text(char) = char {
                    self?.swiftHanguel.input(char: char)
                }
            })
            .compactMap { [weak self] val in
                switch val {
                case .start(let id):
                    return .start(id)
                case .text(_):
                    if let text = self?.swiftHanguel.getTotoal() {
                        return .progress(text)
                    } else {
                        return nil
                    }
                case .end:
                    return .end
                default:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
}


open class AnimateTextLabel: UILabel, AnimateTextType {
    
    public var id: UUID = UUID()
    public var seconds: TimeInterval!
    public var animateText: String!
    public var defaultText: String!
    public var swiftHanguel: SwiftHangeul = SwiftHangeul()
    public var timerSubscriptions: AnyCancellable?
    public var gestureSubscription: AnyCancellable?
    
    public var separatedText: [AnimateText] {
        [.start(self.id)]
        +
        swiftHanguel.separate(input: defaultText).map { char in .text(char)}
        +
        [.end]
    }
    
    public convenience init(frame: CGRect = .zero,
                            seconds: TimeInterval = 0.03,
                            text: String)
    {
        self.init(frame: frame)
        self.seconds = seconds
        self.animateText = text
        self.defaultText = text
        self.applyAttribute()
        self.retryAnimationAction()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    open func applyAttribute() {
        self.numberOfLines = 0
        self.textColor = .label
    }
    
    public func animateTextStart() {
        cancel()
        text = ""
        let publisher = timerTextPublisher()
        timerSubscriptions
        = publisher
            .sink(receiveCompletion: { complete in  },
                  receiveValue: { [weak self] text in
                if case .start = text { self?.text = "" }
                if case let .progress(str) = text { self?.text = str }
            })
    }
    
    open func retryAnimationAction() {
        self.isUserInteractionEnabled = true
        gestureSubscription
        = gesture()
            .sink(
                receiveValue: { [weak self] val in
                    self?.animateTextStart()
                }
            )
    }
}

