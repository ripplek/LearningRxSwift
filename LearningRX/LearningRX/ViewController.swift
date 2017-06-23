//
//  ViewController.swift
//  LearningRX
//
//  Created by 张坤 on 2017/5/16.
//  Copyright © 2017年 zhangkun. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var start = 0
        func getStartNumber() -> Int {
            start += 1
            return start
        }
        let dispose = DisposeBag()
        
        let numbers = Observable<Int>.create({ (observer) -> Disposable in
            let start = getStartNumber()
            observer.onNext(start)
            observer.onNext(start + 1)
            observer.onNext(start + 2)
            observer.onCompleted()
            return Disposables.create()
        }).share()
        
        numbers.filter({ (value) -> Bool in
            value != 1
        }).subscribe(onNext: { (el) in
            print(el)
        },onCompleted: {
            print("----------------")
        }).disposed(by: dispose)
        
        numbers.subscribe(onNext: { (el) in
            print(el)
        },onCompleted: {
            print("----------------")
        }).disposed(by: dispose)
        
        numbers.subscribe({ (event) in
            print(event)
        }).disposed(by: dispose)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerItemClick(_ sender: Any) {
        navigationController?.pushViewController(RegisterViewController(), animated: true)
    }
    

}

enum ConversionError: Error {
    case InvalidFormat, OutOfBounds, Unknown
}

extension UInt8 {
    init(frmString string: String) throws {
        
        if let _ = string.range(of: "^\\d+$", options: [.regularExpression]) {
            if string.compare("\(UInt8.max)", options: [.regularExpression]) != ComparisonResult.orderedAscending {
                throw ConversionError.OutOfBounds
            }
            if let value = UInt8(string) {
                self.init(value)
            } else {
                throw ConversionError.Unknown
            }
        }
        throw ConversionError.InvalidFormat
    }
    
    init(fromString string: String) throws {
        guard let _ = string.range(of: "^\\d+$", options: [.regularExpression])
            else { throw ConversionError.InvalidFormat }
        
        guard string.compare("\(UInt8.max)", options: [.regularExpression]) != ComparisonResult.orderedAscending
            else { throw ConversionError.OutOfBounds }
        
        guard let value = UInt8(string)
            else { throw ConversionError.Unknown }
        
        self.init(value)
    }
}











