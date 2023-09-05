//
//  PagingOnboardingViewController.swift
//  CodeStack
//
//  Created by 박형환 on 2023/08/30.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    //collectionView title content
    let imageArray: [UIImage?] = [UIImage(named: "Illustration 1")
                                 ,UIImage(named: "Illustration 3")
                                 ,UIImage(named: "Illustration 5")]
    
    
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
    
    let firstContent: String = "Managing your\ncoding has never been so easy."
    let secondContent: String = "Spend smarter \nevery day. all \nfrom one app."
    let thirdContent: String = "Safe and secure international ppak-coding deep dive"
    
    private lazy var titleContent: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor(red: 0.07, green: 0.202, blue: 0.542, alpha: 1)
        label.font = UIFont(name: "NanumGothicExtraBold", size: 34)
        label.lineBreakMode = .byWordWrapping
        var pargraphStyle = NSMutableParagraphStyle()
        pargraphStyle.lineHeightMultiple = 1.05
        label.attributedText = NSMutableAttributedString(string: firstContent, attributes: [NSAttributedString.Key.kern : 0.2, NSAttributedString.Key.paragraphStyle : pargraphStyle])
        return label
    }()
    
    private lazy var welcomeLabel: UILabel = {
       let label = UILabel()
        
        label.font = UIFont(name: "NanumGothicBold", size: 15)
        label.textColor = UIColor(red: 0.529, green: 0.529, blue: 0.529, alpha: 1)
        var pargraphStyle = NSMutableParagraphStyle()
        pargraphStyle.lineHeightMultiple = 1.2
        label.attributedText = NSMutableAttributedString(string: "welcome to PpakCoding", attributes: [NSAttributedString.Key.kern : -0.01, NSAttributedString.Key.paragraphStyle : pargraphStyle])
        return label
    }()
    
  
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
//        collectionView.backgroundColor = .systemBlue
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.indicatorStyle = .black
        
        return collectionView
    }()
    private lazy var pageControl: UIPageControl = {
        let page = UIPageControl()
        page.pageIndicatorTintColor = .systemGray
        page.currentPageIndicatorTintColor = .systemBlue
        
        page.numberOfPages = 3
        page.addTarget(self, action: #selector(handlePageControl(_:)), for: .valueChanged)
        return page
    }()
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        var pargraphStyle = NSMutableParagraphStyle()
        button.titleLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.layer.backgroundColor = UIColor(red: 0.136, green: 0.345, blue: 0.883, alpha: 1).cgColor
        button.layer.cornerRadius = 12
        
        let att = NSMutableAttributedString(string: "회원가입", attributes: [
            NSAttributedString.Key.kern : -0.05,
            NSAttributedString.Key.font : UIFont(name: "NanumGothicExtraBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)])

        button.setAttributedTitle(att, for: .normal)
        
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        var pargraphStyle = NSMutableParagraphStyle()
        button.titleLabel?.textColor = UIColor(red: 0.136, green: 0.345, blue: 0.883, alpha: 1)
        button.layer.backgroundColor = UIColor(red: 0.906, green: 0.911, blue: 0.922, alpha: 1).cgColor
        button.layer.cornerRadius = 12
        
        let att = NSMutableAttributedString(string: "로그인", attributes: [
            NSAttributedString.Key.kern : -0.05,
            NSAttributedString.Key.font : UIFont(name: "NanumGothicExtraBold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)])

        button.setAttributedTitle(att, for: .normal)
        
        return button
    }()
    
    
        @objc func handlePageControl(_ sender: UIPageControl){
        let indexPath = IndexPath(row: sender.currentPage, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        
        self.view.backgroundColor = .systemBackground
        
        [welcomeLabel,titleContent,collectionView,pageControl,registerButton,loginButton].forEach{
            self.view.addSubview($0)
        }
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        welcomeLabel.snp.makeConstraints{
            $0.top.equalToSuperview().inset(72)
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
        registerButton.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(pageControl.snp.bottom).offset(50)
            $0.height.equalTo(48)
        }
        loginButton.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(registerButton.snp.bottom).offset(18)
            $0.height.equalTo(48)
        }
    }
}

extension ViewController: UIScrollViewDelegate{
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
extension ViewController: UICollectionViewDelegateFlowLayout{
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
extension ViewController: UICollectionViewDelegate{

    
}
extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {return UICollectionViewCell()}
        
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
