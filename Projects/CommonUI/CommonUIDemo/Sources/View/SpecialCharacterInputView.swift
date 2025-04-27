import Then
import UIKit
import SnapKit


private class SpecialCharacterFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let flatCharacters = SpecialLigature.all.compactMap { $0 }
        
        guard let spaceIndex = flatCharacters.firstIndex(of: .space),
              let enterIndex = flatCharacters.firstIndex(of: .enter),
              let collectionView = collectionView else {
            return attributesArray
        }
        
        var spaceAttr: UICollectionViewLayoutAttributes?
        var enterAttr: UICollectionViewLayoutAttributes?
        
        var modifiedAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attr in attributesArray {
            let item = attr.indexPath.item
            
            if item == spaceIndex {
                spaceAttr = attr
            } else if item == enterIndex {
                enterAttr = attr
            }
            
            modifiedAttributes.append(attr)
        }
        
        if let spaceAttr = spaceAttr {
            let totalWidth = collectionView.bounds.width
            let inset = sectionInset.left + sectionInset.right
            
            if let enterAttr = enterAttr, enterAttr.frame.origin.y == spaceAttr.frame.origin.y {
                let spacing = minimumInteritemSpacing
                let enterWidth = enterAttr.frame.width
                let width = totalWidth - inset - enterWidth - spacing
                spaceAttr.frame = CGRect(
                    x: sectionInset.left,
                    y: spaceAttr.frame.origin.y,
                    width: width,
                    height: spaceAttr.frame.height
                )
                enterAttr.frame.origin.x = spaceAttr.frame.maxX + spacing
            } else {
                let width = totalWidth - inset
                spaceAttr.frame = CGRect(
                    x: sectionInset.left,
                    y: spaceAttr.frame.origin.y,
                    width: width,
                    height: spaceAttr.frame.height
                )
            }
        }
        return modifiedAttributes
    }
}

final class SpecialCharacterInputView: UIView {
    private let inputViewHeight: CGFloat
    private var inputHandler: ((SpecialLigature) -> Void)?
    
    private lazy var collectionView: UICollectionView = {
        let layout = SpecialCharacterFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 8
            $0.minimumInteritemSpacing = 8
            let totalSpacing = 72
            let cellWidth = (UIScreen.main.bounds.width - CGFloat(totalSpacing)) / 6
            $0.itemSize = CGSize(width: cellWidth, height: 36)
            $0.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alpha = 0.0
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SpecialCharacterCell.self, forCellWithReuseIdentifier: SpecialCharacterCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(inputViewHeight: CGFloat, input handler: @escaping (SpecialLigature) -> Void) {
        self.inputViewHeight = inputViewHeight
        self.inputHandler = handler
        super.init(frame: .zero)
        self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupUI()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil else { return }
        UIView.transition(with: collectionView, duration: 0.3, options: [.transitionCrossDissolve]) { [weak self] in
            self?.collectionView.alpha = 1.0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .systemGray6
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: inputViewHeight)
    }
    
}

extension SpecialCharacterInputView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SpecialLigature.strings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpecialCharacterCell.identifier, for: indexPath) as! SpecialCharacterCell
        let char = SpecialLigature.strings[indexPath.item]
        if char == " " {
            cell.configure(with: "Space")
        } else if char == "\n" {
            cell.configure(with: "N")
        } else {
            cell.configure(with: char)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedChar = SpecialLigature.all[indexPath.item]
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        inputHandler?(selectedChar)
    }
}
