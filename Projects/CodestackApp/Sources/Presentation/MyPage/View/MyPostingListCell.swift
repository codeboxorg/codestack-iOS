

import UIKit
import CommonUI

final class MyPostingListCell: UITableViewCell {
    
    private let containerView = UIView()
    
    let colorline: UIView = {
        let view = UIView()
        return view
    }()
    
    let titleTagView: TagView = {
        let view = TagView(frame: .zero, corner: 8, background: .magenta, text: .label)
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Stack"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "View 를 레이아웃 하고 이미지를 디코딩 하여 Render Server에 전달 합니다. 2. Commit Transaction 으로 부터 받은 Package를 분석하고 deserialize하여 rendering tree에 보낸다 "
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.layer.cornerRadius = 8
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = Date().toString(format: .YMD)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.layer.cornerRadius = 4
        return label
    }()
    
    lazy var tagContainer: TagContainer = {
        let container = TagContainer(frame: self.frame, spacing: 10)
        return container
    }()
    
    var tags: [String]? {
        didSet {
            if let tags {
                self.tagContainer.setTagItem(tags)
                let height = self.tagContainer.getCurrentIntrinsicHeight()
                self.tagContainer.snp.updateConstraints { make in
                    make.height.equalTo(height).priority(.low)
                }
            } else {
                self.tagContainer.removeLaguageTag()
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addAutoLayout()
        applyAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentViewFrame = self.contentView.frame
        let insetContentViewFrame
        = contentViewFrame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        self.contentView.frame = insetContentViewFrame
        self.selectedBackgroundView?.frame = insetContentViewFrame
    }
    
    func applyTitleTagSize() {
        let width = titleTagView.getItemWidh()
        let height = titleTagView.getItemHeight()
        titleTagViewWidthAnchor?.constant = width
        titleTagViewHeightAnchor?.constant = height
        titleTagView.updateConstraintsIfNeeded()
    }
    
    private func applyAttributes() {
        let colors: [UIColor] = [.sky_blue, .red, .juhwang, .green, .powder_blue, .purple]
        titleTagView.featureLabel.font = .boldSystemFont(ofSize: 18)
        titleTagView.featureLabel.textColor = .label
        colorline.backgroundColor = colors.randomElement()!
        colorline.layer.cornerRadius = 3
        descriptionLabel.numberOfLines = 3
        dateLabel.textColor = .lightGray
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = dynamicBackground()
    }
    
    private var titleTagViewWidthAnchor: NSLayoutConstraint?
    private var titleTagViewHeightAnchor: NSLayoutConstraint?
    
    private func addAutoLayout() {
        contentView.addSubview(self.containerView)
        [
            colorline,
            titleTagView,
            descriptionLabel,
            dateLabel,
            tagContainer
        ].forEach { self.containerView.addSubview($0) }
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        colorline.translatesAutoresizingMaskIntoConstraints = false
        titleTagView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConst = containerView.heightAnchor.constraint(equalToConstant: 200)
        heightConst.priority = .defaultLow
        
        let colorHeight = colorline.heightAnchor.constraint(equalToConstant: 50)
        colorHeight.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            heightConst,
            
            colorline.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            colorline.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 6),
            colorline.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            colorline.widthAnchor.constraint(equalToConstant: 8),
            colorHeight
        ])
        
        
        self.titleTagViewWidthAnchor = titleTagView.widthAnchor.constraint(equalToConstant: 20)
        self.titleTagViewHeightAnchor = titleTagView.heightAnchor.constraint(equalToConstant: 20)
        
        NSLayoutConstraint.activate([
            titleTagView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleTagView.leadingAnchor.constraint(equalTo: colorline.trailingAnchor, constant: 12),
            titleTagView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            titleTagViewWidthAnchor!,
            titleTagViewHeightAnchor!
        ])
            
         let labelHeight = descriptionLabel.heightAnchor.constraint(equalToConstant: 60)
        descriptionLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleTagView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: colorline.trailingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            labelHeight
        ])
        
        NSLayoutConstraint.activate([
            tagContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            tagContainer.leadingAnchor.constraint(equalTo: colorline.trailingAnchor, constant: 5),
            tagContainer.trailingAnchor.constraint(greaterThanOrEqualTo: dateLabel.leadingAnchor, constant: -10),
            tagContainer.heightAnchor.constraint(equalToConstant: 40),
            tagContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
        let dateTop = dateLabel.centerYAnchor.constraint(equalTo: tagContainer.centerYAnchor)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            dateTop,
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
        ])
    }
}
