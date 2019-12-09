//
//  LineChart.swift
//  LinearChart
//
//  Created by Dmytro Mashtaler on 12/7/19.
//  Copyright © 2019 Dmytro Mashtaler. All rights reserved.
//

import UIKit

struct PointEntry {
    let value: Int
    let label: String
}

extension PointEntry: Comparable {
    static func <(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value < rhs.value
    }
    static func ==(lhs: PointEntry, rhs: PointEntry) -> Bool {
        return lhs.value == rhs.value
    }
}

class LineChart: UIView {
    
    let lineGap: CGFloat = 60.0
    let topSpace: CGFloat = 40.0
    let bottomSpace: CGFloat = 40.0
    let topHorizontalLine: CGFloat = 110.0 / 100.0
    var isCurved: Bool = false
    
    var dataEntries: [PointEntry]? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private let dataLayer: CALayer = CALayer()
    private let mainLayer: CALayer = CALayer()
    private let scrollView: UIScrollView = UIScrollView()
    private let gridLayer: CALayer = CALayer()
    private var dataPoints: [CGPoint]?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        mainLayer.addSublayer(dataLayer)
        scrollView.layer.addSublayer(mainLayer)
        
        self.layer.addSublayer(gridLayer)
        self.addSubview(scrollView)
        self.backgroundColor = #colorLiteral(red: 0, green: 0.3529411765, blue: 0.6156862745, alpha: 1)
    }
    
    override func layoutSubviews() {
        scrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        if let dataEntries = dataEntries {
            scrollView.contentSize = CGSize(width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            mainLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(dataEntries.count) * lineGap, height: self.frame.size.height)
            dataLayer.frame = CGRect(x: 0, y: topSpace, width: mainLayer.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            dataPoints = convertDataEntriesToPoints(entries: dataEntries)
            gridLayer.frame = CGRect(x: 0, y: topSpace, width: self.frame.width, height: mainLayer.frame.height - topSpace - bottomSpace)
            
            clean()
            
            drawHorizontalLines()
            if isCurved {
                drawCurvedChart()
            } else {
                drawChart()
            }
            drawLables()
        }
    }
    
    //Convert [PointEntry] -> [CGPoint] on coordinate system
    private func convertDataEntriesToPoints(entries: [PointEntry]) -> [CGPoint] {
        if let max = entries.max()?.value,
            let min = entries.min()?.value {
            
            var result: [CGPoint] = []
            let minMaxRange: CGFloat = CGFloat(max - min) * topHorizontalLine
            
            for i in 0..<entries.count {
                let height = dataLayer.frame.height * (1 - ((CGFloat(entries[i].value) - CGFloat(min)) / minMaxRange))
                let point = CGPoint(x: CGFloat(i)*lineGap + 40, y: height)
                result.append(point)
            }
            return result
        }
        return []
    }
    
    //Draw line with path
    private func drawChart() {
        if let dataPoints = dataPoints,
            dataPoints.count > 0,
            let path = createPath() {
            
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    //Create bezier path that connects all points
    private func createPath() -> UIBezierPath? {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return nil
        }
        let path = UIBezierPath()
        path.move(to: dataPoints[0])
        
        for i in 1..<dataPoints.count {
            path.addLine(to: dataPoints[i])
        }
        return path
    }
    
    //Draw curved live
    private func drawCurvedChart() {
        guard let dataPoints = dataPoints, dataPoints.count > 0 else {
            return
        }
        if let path = CurveAlgorithm.shared.createCurvedPath(dataPoints) {
            let lineLayer = CAShapeLayer()
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = UIColor.white.cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            dataLayer.addSublayer(lineLayer)
        }
    }
    
    //bottom titles
    private func drawLables() {
        if let dataEntries = dataEntries,
            dataEntries.count > 0 {
            for i in 0..<dataEntries.count {
                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: lineGap*CGFloat(i) - lineGap/2 + 40, y: mainLayer.frame.size.height - bottomSpace/2 - 8, width: lineGap, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.alignmentMode = CATextLayerAlignmentMode.center
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 11
                textLayer.string = dataEntries[i].label
                mainLayer.addSublayer(textLayer)
            }
        }
    }
    
    //create horizontal lines
    private func drawHorizontalLines() {
        guard let dataEntries = dataEntries else {
            return
        }

        var gridValues: [CGFloat]? = nil
        if dataEntries.count < 4 && dataEntries.count > 0 {
            gridValues = [0, 1]
        } else if dataEntries.count >= 4 {
            gridValues = [0, 0.25, 0.5, 0.75, 1]
        }
        if let gridValues = gridValues {
            for value in gridValues {
                let height = value * gridLayer.frame.size.height

                let path = UIBezierPath()
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: gridLayer.frame.size.width, y: height))

                let lineLayer = CAShapeLayer()
                lineLayer.path = path.cgPath
                lineLayer.fillColor = UIColor.clear.cgColor
                lineLayer.strokeColor = #colorLiteral(red: 0.2784313725, green: 0.5411764706, blue: 0.7333333333, alpha: 1).cgColor
                lineLayer.lineWidth = 0.5
                if (value > 0.0 && value < 1.0) {
                    lineLayer.lineDashPattern = [4, 4]
                }

                gridLayer.addSublayer(lineLayer)

                var minMaxGap:CGFloat = 0
                var lineValue:Int = 0
                if let max = dataEntries.max()?.value,
                    let min = dataEntries.min()?.value {
                    minMaxGap = CGFloat(max - min) * topHorizontalLine
                    lineValue = Int((1-value) * minMaxGap) + Int(min)
                }

                let textLayer = CATextLayer()
                textLayer.frame = CGRect(x: 4, y: height, width: 50, height: 16)
                textLayer.foregroundColor = #colorLiteral(red: 0.5019607843, green: 0.6784313725, blue: 0.8078431373, alpha: 1).cgColor
                textLayer.backgroundColor = UIColor.clear.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
                textLayer.fontSize = 12
                textLayer.string = "\(lineValue)"

                gridLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func clean() {
        mainLayer.sublayers?.forEach({
            if $0 is CATextLayer {
                $0.removeFromSuperlayer()
            }
        })
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
        gridLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
    //clean data line
    open func cleanChart() {
        dataLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
    }
    
}
  



