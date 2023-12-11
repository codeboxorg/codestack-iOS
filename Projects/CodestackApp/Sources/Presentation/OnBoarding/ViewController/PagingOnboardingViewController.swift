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

class PagingOnboardingViewController: UIViewController, Stepper {
    
    //collectionView title content
    let imageArray: [UIImage?] = [UIImage(named: "codeStack")]
    
    
    // collectionView Content page 1,2,3 animation
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
//        label.textColor = UIColor(red: 0.07, green: 0.202, blue: 0.542, alpha: 1)
        label.textColor = .sky_blue
//        label.font = UIFont(name: "NanumGothicExtraBold", size: 34)
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.lineBreakMode = .byWordWrapping
        var pargraphStyle = NSMutableParagraphStyle()
        pargraphStyle.lineHeightMultiple = 1.05
        label.attributedText = NSMutableAttributedString(string: firstContent, attributes: [NSAttributedString.Key.kern : 0.2, NSAttributedString.Key.paragraphStyle : pargraphStyle])
        return label
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        
//        label.font = UIFont(name: "NanumGothicBold", size: 15)
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .label
//        label.textColor = UIColor(red: 0.529, green: 0.529, blue: 0.529, alpha: 1)
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
        
//        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
        
        nav?.topItem?.leftBarButtonItem = makeSFSymbolButton(self, action: #selector(dismissVC(_:)), symbolName: "xmark")
        nav?.topItem?.title = "OnBoarding"
    }
    
    
    func makeSFSymbolButton(_ target: Any?, action: Selector, symbolName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: symbolName)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.tintColor = .sky_blue
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return barButtonItem
    }
    
    
    
    private func configure() {
        
        self.view.backgroundColor = .systemGray6
        
        [welcomeLabel,titleContent,collectionView,pageControl].forEach{
            self.view.addSubview($0)
        }
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        welcomeLabel.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        titleContent.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(8)
        }
        
        collectionView.snp.makeConstraints{
            $0.top.equalTo(titleContent.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        pageControl.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(collectionView.snp.bottom).offset(10)
        }
    }
}

extension PagingOnboardingViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPage = scrollView.contentOffset.x / view.frame.width
        pageControl.currentPage = Int(scrollPage)
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("tag = \(scrollView.tag)")
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor(scrollView.contentOffset.x - pageWidth / 2) / pageWidth + 1)
        self.testValue = page
        print("page = \(page)")
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("ani tag = \(scrollView.tag)")
        let pageWidth = scrollView.frame.size.width
        print(pageWidth)
        let page = Int(floor(scrollView.contentOffset.x - pageWidth / 2) / pageWidth + 1)
        self.testValue = page
        print("ani page = \(page)")
    }
}
extension PagingOnboardingViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 37.5, bottom: 0, right: 37.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 75
    }
    
}
extension PagingOnboardingViewController: UICollectionViewDelegate{
    
    
}
extension PagingOnboardingViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: OnBoardingCell.identifier, for: indexPath) as? OnBoardingCell else {return UICollectionViewCell()}
        
        cell.updataUI(imageArray[indexPath.row] ?? UIImage())
        
        return cell
    }
    
    
}

// 폰트 이름 출력
//UIFont.familyNames.sorted().forEach { familyName in
//    print("*** \(familyName) ***")
//    UIFont.fontNames(forFamilyName: familyName).forEach { fontName in
//        print("\(fontName)")
//    }
//    print("---------------------")
//}
