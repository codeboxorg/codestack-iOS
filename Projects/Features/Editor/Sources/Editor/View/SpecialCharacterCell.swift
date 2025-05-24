import UIKit
import Then

final class SpecialCharacterCell: UICollectionViewCell {
    private let label = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with character: String) {
        label.text = character
    }
}

protocol CellIdentifierProtocol {
    static var identifier: String { get }
}
extension CellIdentifierProtocol {
    static var identifier: String{
        String(describing: Self.self)
    }
}

extension SpecialCharacterCell: CellIdentifierProtocol {}

