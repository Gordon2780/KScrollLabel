# KScrollLabel 
跑马灯labe。轻量级可滚动label，使用简单方便，支持pod，CADisplayLink实现。
支持 水平 垂直滚动。支持xib storyboard autolayout


例子：

 let label1 = KScrollLabel(frame: CGRect(x: 20, y: 200, width: UIScreen.main.bounds.width-40, height: 40))
        label1.titleLabel.textColor = .white
        label1.backgroundColor = .purple
        label1.duration = 0.5
        label1.text = "无代码污染，无入侵项目,轻量级可滚动label，使用简单方便，支持pod，CADisplayLink实现。无代码污染，无入侵项目,轻量级可滚动label，使用简单方便，支持pod，CADisplayLink实现。无代码污染，无入侵项目,轻量级可滚动label，使用简单方便，支持pod，CADisplayLink实现。"
        view.addSubview(label1)
