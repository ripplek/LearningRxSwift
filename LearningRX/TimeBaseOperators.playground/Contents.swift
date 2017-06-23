//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

PlaygroundPage.current.needsIndefiniteExecution = true

example(of: "replay") {
    let bag = DisposeBag()
    
    let observable = Observable<Int>.create({ (observable) -> Disposable in
        for i in 1...5 {
            observable.onNext(i)
        }
        return Disposables.create()
    }).replay(2)
    
    observable.subscribe({ (event) in
        print(event)
    }).addDisposableTo(bag)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: { 
        observable.subscribe({ (event) in
            print("deadline  \(event)")
        }).addDisposableTo(bag)
    })
    
    observable.connect()
}