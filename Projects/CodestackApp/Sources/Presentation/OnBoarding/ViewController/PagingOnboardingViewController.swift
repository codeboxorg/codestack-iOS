//
//  PagingOnboardingViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/30.
//

import UIKit
import SnapKit
import RxFlow
import RxRelay
import Combine

class PagingOnboardingViewController: BaseCMViewController, Stepper {
    
    let imageArray: [UIImage?] = [CodestackAppAsset.homeScreen.image,
                                  CodestackAppAsset.problemScreen.image,
                                  CodestackAppAsset.historyScreen.image,
                                  CodestackAppAsset.myPageScreen.image]

    var testValue: Int = 0 {
        didSet{
            switch self.testValue {
            case 0:
                self.titleContent.textWithAnimation(text: firstContent, duration: 0.2)
            case 1:
                self.titleContent.textWithAnimation(text: secondContent, duration: 0.2)
            case 2:
                self.titleContent.textWithAnimation(text: thirdContent, duration: 0.2)
            default:
                break
            }
        }
    }
    
    var steps: PublishRelay<RxFlow.Step> = PublishRelay<Step>()
    
    var initialStep: Step {
        CodestackStep.none
    }
    
    let firstContent: String = "문제를 풀면서 성장하세요"
    let secondContent: String = "문제를 기록하세요"
    let thirdContent: String = "다양한 기능이 함께 합니다"
    
    private lazy var titleContent: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .sky_blue
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.lineBreakMode = .byWordWrapping
        var pargraphStyle = NSMutableParagraphStyle()
        pargraphStyle.lineHeightMultiple = 1.05
        label.attributedText = NSMutableAttributedString(string: firstContent, attributes: [NSAttributedString.Key.kern : 0.2, NSAttributedString.Key.paragraphStyle : pargraphStyle])
        return label
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .label
        var pargraphStyle = NSMutableParagraphStyle()
        pargraphStyle.lineHeightMultiple = 1.2
        label.attributedText = NSMutableAttributedString(string: "코드스택에 오신걸 환영합니다", attributes: [NSAttributedString.Key.kern : -0.01, NSAttributedString.Key.paragraphStyle : pargraphStyle])
        return label
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(OnBoardingCell.self, forCellWithReuseIdentifier: OnBoardingCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.indicatorStyle = .black
        
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let page = UIPageControl()
        page.pageIndicatorTintColor = .systemGray
        page.currentPageIndicatorTintColor = .juhwang
        
        page.numberOfPages = 1
        page.addTarget(self, action: #selector(handlePageControl(_:)), for: .valueChanged)
        return page
    }()
    
    
    @objc func handlePageControl(_ sender: UIPageControl){
        let indexPath = IndexPath(row: sender.currentPage, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        navigationSetting()
    }
    
    
    @objc func dismissVC(_ sender: Any){
        steps.accept(CodestackStep.onBoardingComplte)
    }
    
    private func navigationSetting(){
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        
        nav?.topItem?.leftBarButtonItem
        = makeSFSymbolButton(self, action: #selector(dismissVC(_:)), symbolName: "xmark")
        
        nav?.topItem?.title = "OnBoarding"
    }
    
    
    private func configure() {
        self.view.backgroundColor = .systemGray6
        self.view.addSubview(collectionView)
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }

        collectionView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}

extension PagingOnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPage = scrollView.contentOffset.x / view.frame.width
        pageControl.currentPage = Int(scrollPage)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor(scrollView.contentOffset.x - pageWidth / 2) / pageWidth + 1)
        self.testValue = page
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor(scrollView.contentOffset.x - pageWidth / 2) / pageWidth + 1)
        self.testValue = page
    }
}

extension PagingOnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Position.screenWidth - 10,
                      height: Position.screenHeihgt)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
}

extension PagingOnboardingViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: OnBoardingCell.identifier, for: indexPath) as? OnBoardingCell else {return UICollectionViewCell()}
        
        cell.updataUI(imageArray[indexPath.row] ?? UIImage())
        
        return cell
    }
}
