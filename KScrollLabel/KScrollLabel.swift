//
//  JScrollLabel.swift
//  JYLive
//
//  Created by 秦宽 on 2021/9/23.
//

import UIKit

class KScrollLabel: UIView {
    
    /// 滚动中的方向
    private(set) var scrolling: ScrollDirection = .left
    /// 显示文本的控件
    private(set) var titleLabel: UILabel!
    /// 滚动方向 默认水平
    var direction: UICollectionView.ScrollDirection = .horizontal{
        didSet{ setString(text) }
    }
    /// 滚动频率/秒
    @IBInspectable var duration: CGFloat = 0.25
    /// 屏幕刷新率 默认60hz
    @IBInspectable var hertz: CGFloat = 60
    /// 文本内容
    @IBInspectable var text: String? {
        didSet{ setString(oldValue) }
    }
    /// 滚动内容大小
    @IBInspectable var contentSize: CGSize = .zero {
        didSet{ setScrollContentSize() }
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createViews()
    }

    override func layoutSubviews() {
       titleLabel.frame = CGRect(x: 0, y: 0, width: contentSize.width , height:  contentSize.height)
       scrollView.frame = CGRect(x: insets.left, y: insets.top, width: bounds.width - insets.left - insets.right, height: bounds.height - insets.top - insets.bottom)
   }
    
}

fileprivate extension KScrollLabel {
    
    func createViews(){
        let lay = UICollectionViewFlowLayout()
        lay.scrollDirection = .horizontal
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = false
        addSubview(scrollView)
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        scrollView.addSubview(titleLabel)
    }
    
    func setString(_ oldValue: String?){
        
        guard let string = text else { return }
        titleLabel.text = string
        if contentSize == .zero || (contentSize != .zero && string != oldValue){
            let font = titleLabel.font ?? .systemFont(ofSize: 15)
            var maxSize: CGSize = .zero
            if  direction == .horizontal {
                maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.height-insets.top-insets.bottom)
            }else if direction == .vertical{
                maxSize = CGSize(width: bounds.width-insets.left-insets.right, height: CGFloat.greatestFiniteMagnitude)
            }
            let stringSize = string.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [.font:font], context: nil).size
            
            if direction == .horizontal {
                contentSize = CGSize(width: stringSize.width, height: maxSize.height)
            }else if direction == .vertical{
                contentSize = CGSize(width: maxSize.width, height: stringSize.height)
            }
            
           
        }else{
           setScrollContentSize()
        }
    }
    
    func setScrollContentSize(){
        setNeedsLayout()
        scrollView.contentSize = contentSize
        
        var scrollable: Bool = false
        
        if direction == .horizontal {
            rollOffset = contentSize.width / (hertz * (duration * 60))
            maxOffset = contentSize.width - bounds.width
            scrolling = (scrollView.contentOffset.x < maxOffset) ? .right:.left
            scrollable = (contentSize.width > bounds.width &&
                          text?.isEmpty == false &&
                          displayLink == nil)
        }else if direction == .vertical {
            rollOffset = contentSize.height / (hertz * (duration * 60))
            maxOffset = contentSize.height - bounds.height
            scrolling = (scrollView.contentOffset.y < maxOffset) ? .top:.bottom
            scrollable = (contentSize.height > bounds.height &&
                          text?.isEmpty == false &&
                          displayLink == nil)
        }
        
        if scrollable{
            displayLink = CADisplayLink(target: self, selector: #selector(displayLinkAction))
            displayLink?.add(to: RunLoop.current, forMode: .default)
            displayLink?.isPaused = false
        }else{
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
    
    func setScrolling(){
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
            
            switch scrolling {
            case .right,.bottom:
                
                if offset >= maxOffset {
                    setScrolling()
                }
                setOffset(offset+rollOffset)
            case .left,.top:
                
                if offset <= minOffset{
                    setScrolling()
                }
                setOffset(offset-rollOffset)
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
    }
}

