//
//  CellIdentifierProtocol.swift
//  CodeStack
//
//  Created by 박형환 on 2023/04/16.
//

import UIKit

protocol CellIdentifierProtocol{
    static var identifier: String { get }
}
extension CellIdentifierProtocol{
    static var identifier: String{
        String(describing: Self.self)
    }
}

extension CodestackListCell: CellIdentifierProtocol { }
extension RecentSectionHeader: CellIdentifierProtocol { }
extension HistoryCell: CellIdentifierProtocol { }
extension ProblemCell: CellIdentifierProtocol { }
extension SubmissionCell: CellIdentifierProtocol{ }
extension OnBoardingCell: CellIdentifierProtocol { }
extension OnBoardingHeader : CellIdentifierProtocol { }
extension WritingListCell: CellIdentifierProtocol { }
extension PRSubmissionHistoryCell: CellIdentifierProtocol { }
extension MyPostingListCell: CellIdentifierProtocol { }

extension UICollectionView {
    static func submissionHistoryCellSetting(item size: CGSize = CGSize(),
                                      spacing: CGFloat = 0,
                                      insetValue: CGFloat = 0,
                                             background color: UIColor? = .tertiarySystemBackground)
    -> UICollectionView
    {
        let compositional = UICollectionView.getCompositional()
        
        compositional.configuration.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositional)
        collectionView.register(RecentSectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecentSectionHeader.identifier)
        collectionView.register(PRSubmissionHistoryCell.self, forCellWithReuseIdentifier: PRSubmissionHistoryCell.identifier)
        collectionView.register(WritingListCell.self, forCellWithReuseIdentifier: WritingListCell.identifier)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = color
        collectionView.isScrollEnabled = false
        
        // contentInset 설정하면 layout scrollDirection이 수평, 수직 다 적용된다.
        collectionView.contentInset = UIEdgeInsets(top: insetValue,
                                                   left: insetValue,
                                                   bottom: insetValue,
                                                   right: insetValue)
        return collectionView
    }
}

enum SectionKind: Int, CaseIterable {
    case continuous, continuousGroupLeadingBoundary, paging, groupPaging, groupPagingCentered, none

    // ✅ orthogonalScrollingBehavior 종류
    func orthogonalScrollingBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
        switch self {
        case .none:
            return UICollectionLayoutSectionOrthogonalScrollingBehavior.none
        case .continuous:
            return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuous
        case .continuousGroupLeadingBoundary:
            return UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary
        case .paging:
            return UICollectionLayoutSectionOrthogonalScrollingBehavior.paging
        case .groupPaging:
            return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPaging
        case .groupPagingCentered:
            return UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered
        }
    }
}

extension UICollectionView{
    static func getCompositional() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 10
        config.scrollDirection = .vertical
        
        let layout =
        UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            if sectionIndex == 0 {
                return UICollectionView.firstSectionItem()
            }
            if sectionIndex == 1 {
                return UICollectionView.secondSectionItem()
            }
            return UICollectionView.firstSectionItem()
        }, configuration: config)
        return layout
    }
    
    static func firstSectionItem() -> NSCollectionLayoutSection {
        // ✅ leadingItem의 contentInsets을 할당
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(0.9))
        let leadingItem = NSCollectionLayoutItem(layoutSize: size)
        
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        // ✅ group의 fractionalWidth를 1.0 보다 작게 설정
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension:.fractionalWidth(0.55),
                                               heightDimension: .absolute(150)),
            subitems: [leadingItem]
        )  
        // 주의 - trailingItem이 아니라 trailingGroup
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        // ✅ orthogonalScrollingBehavior 설정
        section.orthogonalScrollingBehavior = .groupPaging
        
        // section header 설정
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(20)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
        
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    static func secondSectionItem() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                          heightDimension: .fractionalHeight(1.0))
        let leadingItem = NSCollectionLayoutItem(layoutSize: size)
        
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension:.fractionalWidth(0.8),
                                               heightDimension: .absolute(220))
        let containerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [leadingItem]
        )
        
        let section = NSCollectionLayoutSection(group: containerGroup)
        
        section.orthogonalScrollingBehavior = .groupPaging
        
        // section header 설정
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(20)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        
        section.contentInsets = .init(top: 10, leading: 0, bottom: 0, trailing: 0)
        
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
}
