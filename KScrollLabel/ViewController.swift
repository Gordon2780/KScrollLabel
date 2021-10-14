//
//  ViewController.swift
//  KScrollLabel
//
//  Created by 秦宽 on 2021/9/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var label: KScrollLabel!
    @IBOutlet weak var lcHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lcTop: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickItem)))
        
        
        let label1 = KScrollLabel()
        label1.frame = CGRect(x: 20, y: 200, width: UIScreen.main.bounds.width-40, height: 40)
        label1.textColor = .white
        label1.tailSpace = 30
        label1.backgroundColor = .purple
        label1.duration = 0.1
        label1.shadowColor = UIColor.magenta
        label1.text = "无代码污染，"
        
        view.addSubview(label1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            label1.text =  "无入侵项目,无代码污染，无入侵项目无代码污染，无入侵项目无代码污染，无入侵项目无代码污染，无入侵项目无代码污染，无入侵项目无代码污染，无入侵项目"
        }

        
        let label2 = KScrollLabel(frame: CGRect(x: 40, y: 300, width: 15, height: UIScreen.main.bounds.width-40))
        label2.backgroundColor = .orange
        label2.style = .reverse
        label2.tailSpace =  50
        label2.direction = .vertical
        label2.duration = 0.8
        label2.textColor = .red
        label2.text = "无代码污染，无入侵项目,轻量级可滚动label，CADisplayLink实现。我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，"
        view.addSubview(label2)

//
        let label3 = KScrollLabel(frame: CGRect(x: 140, y: 300, width: 40, height: UIScreen.main.bounds.width-40))
        label3.backgroundColor = .green
        label3.direction = .vertical
        label3.tailSpace = 100
        label3.duration = 0.2
        label3.tailSpace = 15
        label3.textColor = .white

        label3.text = "无代码污染，无入侵项目,轻量级可滚动label，CADisplayLink实现。我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，我是滚动内容，"
        view.addSubview(label3)
        
    }

    @objc func clickItem(){
       let alertController = UIAlertController.init(title: "提示", message: "点击了滚动label", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}

