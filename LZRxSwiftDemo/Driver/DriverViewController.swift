//
//  ViewController.swift
//  DoveLarkRX
//
//  Created by Pro on 2020/2/3.
//  Copyright © 2020 Pro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DriverViewController: UIViewController {
    
    
    @IBOutlet weak var lab: UILabel!
    
    @IBOutlet weak var tf: UITextField!
    
    @IBOutlet weak var btn: UIButton!
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Driver"
        
//        序列中的序列  将textField映射成序列，
//        let result = tf.rx.text.skip(1)
//            .flatMap{[weak self](input) -> Observable<Any> in
//                return (self?.dealWithData(inputText:input ?? ""))!
//                    .observeOn(MainScheduler.instance)
//                .catchErrorJustReturn("检测到了error事件")
//        }.share(replay: 1, scope: .whileConnected)
////        订阅序列
//        result.subscribe(onNext:{ (element) in
//            print("订阅到\(element)")
//        })
//        result.subscribe(onNext:{ (element) in
//            print("订阅到：\(Thread.current) --- \(element)")
//        })
        
        let result = tf.rx.text.orEmpty
            .asDriver()
            .flatMap {
                return self.dealWithData(inputText: $0)
                .asDriver(onErrorJustReturn: "检测到错误事件")
                
        }
        result.map{"长度\(($0 as! String).count)"}
            .drive(self.lab.rx.text)
        result.map{"长度\($0 as! String)"}
            .drive(self.btn.rx.title())

    }
    
    func dealWithData(inputText:String) -> Observable<Any> {
        print("请求网络\(Thread.current)")
        
        return Observable<Any>.create { (ob) -> Disposable in
            if inputText == "1234" {
                ob.onError(NSError.init(domain: "log.error", code: 10096, userInfo: nil))
            }
            
            DispatchQueue.global().async {
                print("发送之前的内容：\(Thread.current)")
                ob.onNext("已经输入：\(inputText)")
                ob.onCompleted()
//                self.btn.setTitle("123", for: .normal)
            }
            return Disposables.create()
        }
    }

}


