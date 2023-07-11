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

extension ProblemCell: CellIdentifierProtocol{}
extension PRSubmissionHistoryCell: CellIdentifierProtocol{
    
    static func submissionHistoryCellSetting(item size: CGSize,
                                      spacing: CGFloat = 16,
                                      insetValue: CGFloat = 15,
                                             background color: UIColor? = .tertiarySystemBackground)
    -> UICollectionView
    {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        
        layout.itemSize = size //CGSize(width: 110, height: 110)
        
        layout.minimumLineSpacing = spacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = color
        collectionView.contentInset = UIEdgeInsets(top: insetValue,
                                                   left: insetValue,
                                                   bottom: insetValue,
                                                   right: insetValue)
        return collectionView
    }
    
}
