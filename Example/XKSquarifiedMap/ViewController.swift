//
//  ViewController.swift
//  XKSquarifiedMap
//
//  Created by kenneth on 06/22/2022.
//  Copyright (c) 2022 kenneth. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift
import XKSquarifiedMap

class ViewController: UIViewController {

    let values = [6.0, 6.0, 4.0, 3.0, 2.0, 2.0, 1.0]
    
    let container = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        view.backgroundColor = .white
        
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(100.0)
            make.left.right.equalToSuperview()
            make.height.equalTo(container.snp.width).dividedBy(6.0/4.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.createSubviews()
        }
        
    }

    func createSubviews() {
        
        let frames = XKSquarifiedMap.fetchRects(values: values, containerSize: container.frame.size)
        
        for (i, frame) in frames.enumerated() {
            
            let subView = UIView()
            subView.backgroundColor = UIColor.random
            subView.frame = frame
            let textLabel = UILabel()
            textLabel.textColor = .black
            textLabel.textAlignment = .center
            textLabel.numberOfLines = 0
            textLabel.text = "\(i)\n \(values[i])"
            container.addSubview(subView)
            subView.addSubview(textLabel)
            textLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

