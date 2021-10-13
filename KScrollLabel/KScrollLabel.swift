//
//  JScrollLabel.swift
//  JYLive
//
//  Created by 秦宽 on 2021/9/23.
//

import UIKit

class KScrollLabel: UIView {
    
    /// 滚动样式，默认滚动到结尾从头开始
    var style: ScrollDirection.Style = .reset
    /// 滚动中的方向
    private(set) var scrolling: ScrollDirection = .left
    /// 滚动内容大小
    private(set) var contentSize: CGSize = .zero
    /// 滚动方向 默认水平
    @IBInspectable var direction: UICollectionView.ScrollDirection = .horizontal{
        didSet{ setString(text) }
    }
    /// 首尾间距
    @IBInspectable var tailSpace: CGFloat = 20
    /// 滚动频率/秒
    @IBInspectable var duration: CGFloat = 0.25
    /// 屏幕刷新率 默认60hz
    @IBInspectable var hertz: CGFloat = 60
    /// 文本内容
    @IBInspectable var text: String? {
        didSet{ setString(oldValue) }
    }
    /// 字体
    @IBInspectable var font: UIFont = .systemFont(ofSize: 14) {
        didSet{
            firstLabel.font = font
            lastLabel.font = font
        }
    }
    /// 文字颜色
    @IBInspectable var textColor: UIColor = .black {
        didSet{
            firstLabel.textColor = textColor
            lastLabel.textColor = textColor
        }
    }
    
    
    /// 阴影颜色
    @IBInspectable var shadowColor: UIColor? {
        didSet {
            firstLabel.shadowColor = shadowColor
            lastLabel.shadowColor = shadowColor
        }
    }
    /// 内边距
    @IBInspectable var insets: UIEdgeInsets = .zero{
        didSet{ setNeedsLayout() }
    }
    
    private var displayLink: CADisplayLink?
    private var rollOffset: CGFloat = 0
    private var maxOffset: CGFloat = 0
    private var minOffset: CGFloat = 0
    private var scrollView: UIScrollView!
    private var lastLabel: UILabel!
    private var firstLabel: UILabel!
    private var displayLabel: UILabel?
    private var contentSizeIsEmpty: Bool { contentSize.width == 0 || contentSize.height == 0}

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createViews()
    }

    override func layoutSubviews() {
        
        if contentSizeIsEmpty {
            setContentSize()
        }
        
        firstLabel.frame = CGRect(x: 0, y: 0, width: contentSize.width , height:  contentSize.height)
        if  direction == .horizontal {
            lastLabel.frame = CGRect(x: firstLabel.frame.maxX + tailSpace, y: 0, width: contentSize.width, height: contentSize.height)
        }else if direction == .vertical {
            lastLabel.frame = CGRect(x: 0, y: firstLabel.frame.maxY + tailSpace, width: contentSize.width, height: contentSize.height)
        }
       scrollView.frame = CGRect(x: insets.left, y: insets.top, width: bounds.width - insets.left - insets.right, height: bounds.height - insets.top - insets.bottom)
       
        if !contentSizeIsEmpty && displayLink == nil {
            startScrollable()
        }
   }
    
}

fileprivate extension KScrollLabel {
    
    func createViews(){
        
        func defaultLabel(tag: Int) -> UILabel{
            let label = UILabel()
            label.tag = tag
            label.numberOfLines = 0
            label.font = font
            label.textColor = textColor
            label.textAlignment = .left
            return label
        }
        
        
        let lay = UICollectionViewFlowLayout()
        lay.scrollDirection = .horizontal
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = false
        addSubview(scrollView)
        
        firstLabel = defaultLabel(tag: 1)
        scrollView.addSubview(firstLabel)
        
        lastLabel = defaultLabel(tag: 2)
        scrollView.addSubview(lastLabel)
        
        displayLabel = firstLabel
        
    }
    
    func setString(_ oldValue: String?){
        
        guard let string = text else { return }
        firstLabel.text = string
        lastLabel.text = string
        if string != oldValue {
            setContentSize()
        }
        if frame != .zero {
            setNeedsLayout()
            startScrollable()
        }
    }
    
    func setContentSize(){
        
        guard let string = firstLabel.text else { return  }
        
        var maxSize: CGSize = .zero
        if  direction == .horizontal {
            maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.height-insets.top-insets.bottom)
        }else if direction == .vertical{
            maxSize = CGSize(width: bounds.width-insets.left-insets.right, height: CGFloat.greatestFiniteMagnitude)
        }
        
        let stringSize = string.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.font : font], context: nil).size
        
        if direction == .horizontal {
            contentSize = CGSize(width: stringSize.width, height: maxSize.height)
        }else if direction == .vertical {
            contentSize = CGSize(width: maxSize.width, height: stringSize.height)
        }
        scrollView.contentSize = contentSize
    }
    
    
    func startScrollable(){
        print("startScrollable")
        var scrollable: Bool = false
        
        if direction == .horizontal {
            rollOffset = contentSize.width / (hertz * (duration * 60))
            if style == .reset {
                maxOffset = contentSize.width + scrollView.bounds.width + tailSpace
            }else if style == .reverse {
                maxOffset = contentSize.width - bounds.width
                scrolling = (scrollView.contentOffset.x < maxOffset) ? .right:.left
            }
            scrollable = (contentSize.width > bounds.width &&
                          text?.isEmpty == false &&
                          displayLink == nil)
        }else if direction == .vertical {
            rollOffset = (contentSize.height + tailSpace) / (hertz * (duration * 60))
            if style == .reverse {
                maxOffset = contentSize.height - bounds.height
                scrolling = (scrollView.contentOffset.y < maxOffset) ? .top:.bottom
            }else if style == .reset {
                maxOffset = contentSize.height + tailSpace
            }
            scrollable = (contentSize.height > bounds.height &&
                          text?.isEmpty == false &&
                          displayLink == nil)
        }
        
        if scrollable{
            invalidate()
            lastLabel.isHidden = false
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
            displayLink?.add(to: .current, forMode: .default)
            displayLink?.isPaused = false
            
        }else{
            lastLabel.isHidden = true
            invalidate()
        }
    }
    
    func setOffset(_ value: CGFloat){
        if direction == .horizontal {
            scrollView.setContentOffset(CGPoint(x: value, y: 0), animated: false)
        }else if direction == .vertical {
            scrollView.setContentOffset(CGPoint(x: 0, y: value), animated: false)
        }
    }
    
    func reverseStyleScroll(){
        displayLink?.isPaused = true
            switch scrolling {
            case .left:
                scrolling = .right
            case .right:
                scrolling = .left
            case .top:
                scrolling = .bottom
            case .bottom:
                scrolling = .top
            }
       displayLink?.isPaused = false
    }
    
    func tailedSpaceScroll(_ offset: CGFloat){
        
        guard let display = displayLabel else { return  }
        
            let value = direction == .horizontal ?  display.frame.maxX:display.frame.maxY
            if  offset > value {
                displayLink?.isPaused = true
                if display.tag == 1 {
                    if direction == .horizontal {
                        firstLabel.frame.origin.x = lastLabel.frame.maxX + tailSpace
                    }else if direction == .vertical {
                        firstLabel.frame.origin.y = lastLabel.frame.maxY + tailSpace
                    }
                    displayLabel = lastLabel
                }else if display.tag == 2 {
                    if direction == .horizontal {
                        lastLabel.frame.origin.x = firstLabel.frame.maxX + tailSpace
                    }else if direction == .vertical {
                        lastLabel.frame.origin.y = firstLabel.frame.maxY + tailSpace
                    }
                    displayLabel = firstLabel
                }
                displayLink?.isPaused = false
            }
    }
    
    func invalidate(){
        displayLink?.isPaused = true
        displayLink?.invalidate()
        displayLink = nil
    }
    
    
    @objc func displayLinkAction(){
        
        if superview == nil {
            invalidate()
        }else{
            let offset = (direction == .horizontal) ? scrollView.contentOffset.x:scrollView.contentOffset.y
            
            if style == .reset {
                tailedSpaceScroll(offset)
                setOffset(offset+rollOffset)
            }else if style == .reverse {
                switch scrolling {
                case .right,.bottom:
                        if offset >= maxOffset {
                            reverseStyleScroll()
                        }
                    setOffset(offset+rollOffset)
                case .left,.top:
                        if offset <= minOffset{
                            reverseStyleScroll()
                        }
                    setOffset(offset-rollOffset)
                }
            }
        }
    }
}

extension KScrollLabel {
    enum ScrollDirection {
        case left
        case right
        case top
        case bottom
        
        enum Style {
        case reset
        case reverse
        }
    }
}

