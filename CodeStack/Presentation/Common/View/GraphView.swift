//
//  GraphView.swift
//  CodeStack
//
//  Created by 박형환 on 2023/06/26.
//

import UIKit
import SnapKit

enum Constants{
    static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
    static let margin: CGFloat = 20.0
    static let topBorder: CGFloat = 60
    static let bottomBorder: CGFloat = 50
    static let colorAlpha: CGFloat = 0.3
    static let circleDiameter: CGFloat = 8.0
}

class GraphView: UIView{
    
    var startColor: UIColor = UIColor.darkGray
    var endColor: UIColor = UIColor.tertiarySystemBackground
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    //MARK: - Graph Point
    /// Graph 의 좌표를 정하는 프로퍼티 이다.
    var graphPoints = [0,0,0,0,0,0,2]
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let graphWidth = frame.width - Constants.margin * 2 - 4
        let spacing = graphWidth / CGFloat(6) - Constants.margin
        
        layoutConfigure(spacing: spacing + 2)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("required init fatalError")    
    }
    
    let dayArray: [String] = ["월","화","수","목","금","토","일"]
    
    
    private let graphNameLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "COMMIT HISTORY"
        return label
    }()
    
    lazy var dayLabel: [UILabel] = {
        return graphPoints.indices.map{ (value) -> UILabel in
            let label = UILabel()
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.text = dayArray[value]
            label.textColor = .white
            return label
        }
    }()

    private func layoutConfigure(spacing: CGFloat) {
        hStackView.spacing = spacing + 1
        addSubview(hStackView)
        addSubview(graphNameLabel)
        dayLabel.forEach{
            hStackView.addArrangedSubview($0)
        }
        
        graphNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        hStackView.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(Constants.margin - 5)
            make.top.equalToSuperview().offset(200 - Constants.bottomBorder + 8)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        
        //MARK: - 먼저 path로 clip을 해야한다. -> drawLinearGradient먼저 하게되면 그 뒤에 패스를 적용하므로 layer에 라운드처리가 되지 않는다.
        let path = UIBezierPath(roundedRect: rect,
                          byRoundingCorners: .allCorners,
                                cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let colors: [CGColor] = [startColor.cgColor , endColor.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0,1]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                             colors: colors as CFArray,
                                          locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: .zero, y: bounds.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
          //Calculate the gap between points
          let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
          return CGFloat(column) * spacing + margin + 2
        }
        
        
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y // Flip the graph
        }
        
        
        UIColor.lightGray.setFill()
        UIColor.lightGray.setStroke()
        
        // set up the points line
        let graphPath = UIBezierPath()
        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
            
        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
          let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
          graphPath.addLine(to: nextPoint)
        }
        graphPath.stroke()
        
        
        
        
        //Create the clipping path for the graph gradient

        //1 - save the state of the context (commented out for now)
        context.saveGState()
        //2 - make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
            
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y:height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0), y:height))
        clippingPath.close()
            
        //4 - add the clipping path to the context
        clippingPath.addClip()
            
        //5 - check clipping path - temporary code
        let rectPath = UIBezierPath(rect: rect)
        rectPath.fill()
        
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
                
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        // 이거 안하면 path때문에 밑의 코드에서 원점을 추가할때 clip 된다.
        context.restoreGState()
        
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        //Draw the circles on top of the graph stroke
        for i in 0..<graphPoints.count {
          var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
          point.x -= Constants.circleDiameter / 2
          point.y -= Constants.circleDiameter / 2
              
          let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
          circle.fill()
        }
        //draw the line on top of the clipped gradient
        
        
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()

        //top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))

        //center line
        linePath.move(to: CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight/2 + topBorder))

        //bottom line
        linePath.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:  width - margin, y: height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
            
        linePath.lineWidth = 1.0
        linePath.stroke()
    }
}
