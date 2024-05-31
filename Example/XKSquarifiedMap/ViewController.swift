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

    lazy var values: [Double] = [477985157, 367307473, 350472264, 216917349, 216427129, 205720723, 189556783, 157510547, 149931421, 145997978, 138368184, 122888219, 119277147, 115591424, 112695066, 111294088, 106461399, 105396682, 100222370, 97950881].prefix(20).map { $0 }
    
    lazy var treeMap: XKTreeMap = {
        let treeMap = XKTreeMap()
        treeMap.dataSource = self
        treeMap.delegate = self
        treeMap.register(cellWithClass: Cell.self)
        
        return treeMap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        view.backgroundColor = .white
        treeMap.backgroundColor = .white
        view.addSubview(treeMap)
        treeMap.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(252.0)
            make.top.equalTo(100)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        treeMap.treeValues = values
    }

//    func createSubviews() {
//        
//        let frames = XKSquarifiedMap.fetchRects(values: values, containerSize: container.frame.size)
//        
//        for (i, frame) in frames.enumerated() {
//            
//            let subView = UIView()
//            subView.backgroundColor = UIColor.random
//            subView.frame = frame
//            let textLabel = UILabel()
//            textLabel.textColor = .black
//            textLabel.textAlignment = .center
//            textLabel.numberOfLines = 0
//            textLabel.text = "\(i)\n \(values[i])"
//            container.addSubview(subView)
//            subView.addSubview(textLabel)
//            textLabel.snp.makeConstraints { make in
//                make.center.equalToSuperview()
//            }
//        }
//        
//    }
    

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return values.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: Cell = collectionView.dequeueReusableCell(withClass: Cell.self, for: indexPath)
        cell.contentView.backgroundColor = .random
        cell.textLabel.text = "\(indexPath.item)"
        return cell
    }
}

class Cell: UICollectionViewCell {
    lazy var textLabel: UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        textLabel.font = .systemFont(ofSize: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
