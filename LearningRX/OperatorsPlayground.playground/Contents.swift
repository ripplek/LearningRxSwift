//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport

var str = "Hello, playground"

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

enum MyError: Error {
    case myError
}

let dispose = DisposeBag()

example(of: "ignoreElements") {
    let strikes = PublishSubject<String>()
    
    strikes.ignoreElements().subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
    
    strikes.onNext("X")
    strikes.onNext("X")
    strikes.onCompleted()
//    stries.onError(MyError.myError)
}

example(of: "elementAt") { 
    let strikes = PublishSubject<String>()
    
    strikes.elementAt(2).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
    
    strikes.onNext("1")
    strikes.onNext("2")
    strikes.onCompleted()
    strikes.onNext("3")
    strikes.onNext("4")
}

example(of: "filter") { 
    Observable.of(1,2,3,4,5,6,7,8,9,10).filter({ (value) -> Bool in
        value % 2 == 0
    }).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
}

example(of: "skip") { 
    Observable.of("A", "B", "C", "D", "E", "F", "G").skip(3).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
}

example(of: "skipWhile") { 
    Observable.of(1,2,3,4,5,6,7,8,9,10,2,3,4).skipWhile({ (value) -> Bool in
        return value < 5
    }).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
}

example(of: "skipUntil") {
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject.skipUntil(trigger).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
    
    subject.onNext("A")
    subject.onNext("B")
    trigger.onNext("aaa")
    subject.onNext("C")
    subject.onNext("D")
}

example(of: "take") { 
    Observable.of(1,2,3,4,5,6,7,8,9).take(3).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
}

example(of: "takeWhileWithIndex") { 
    Observable.of(1,2,3).takeWhileWithIndex({ (element, index) -> Bool in
        return element > 1 && index > 1
    }).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
}

example(of: "takeUntil") {
    let subject = PublishSubject<String>()
    let trigger = PublishSubject<String>()
    
    subject.takeUntil(trigger).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
    
    subject.onNext("1")
    subject.onNext("2")
    trigger.onNext("X")
    subject.onNext("3")
}


example(of: "distinctUntilChanged") {
    Observable.of("A", "A", "B", "B", "A").distinctUntilChanged()
        .subscribe(onNext: {
        print($0)
    }).addDisposableTo(dispose)
}

example(of: "distinctUntilChanged(comparer: @escaping (Self.E, Self.E) throws -> Bool)") {
    Observable.of(1,2,3,10,10,5,6,70,8,9).distinctUntilChanged({ (element1, element2) -> Bool in
        print("element1:", element1, "element2:", element2)
        return element1 > element2
    }).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
}

example(of: "Challenge 1") {
    
    let disposeBag = DisposeBag()
    
    let contacts = [
        "603-555-1212": "Florent",
        "217-555-1212": "Junior",
        "408-555-1212": "Marin",
        "617-555-1212": "Scott"
    ]
    
    func phoneNumber(from inputs: [Int]) -> String {
        var phone = inputs.map(String.init).joined()
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 7)
        )
        
        return phone
    }
    
    let convert: (String) -> UInt? = { (value) in
        if let number = UInt(value), number < 10 {
            return number
        }
        
        let convert: [String: UInt] = [
            "abc": 2, "def": 3, "ghi": 4,
            "jkl": 5, "mno": 6, "pqrs": 7,
            "tuv": 8, "wxyz": 9
        ]
        
        var converted: UInt? = nil
        
        convert.keys.forEach {
            if $0.contains(value.lowercased()) {
                converted = convert[$0]
            }
        }
        
        return converted
    }
    
    let format: ([UInt]) -> String = {
        var phone = $0.map(String.init).joined()
        phone.insert("-", at: phone.index(
            phone.startIndex,
            offsetBy: 3)
        )
        phone.insert("-", at: phone.index(phone.startIndex,offsetBy: 7))
        return phone
    }
    
    let dial: (String) -> String = {
        if let contact = contacts[$0] {
            return "Dialing \(contact) (\($0))..."
        } else {
            return "Contact not found"
        }
    }

    
    let input = PublishSubject<Int>()
    
    // Add your code here
    input
        .skipWhile { $0 == 0 }
        .filter { $0 < 10 }
        .take(10)
        .toArray()
        .subscribe(onNext: {
            print($0)
            let phone = phoneNumber(from: $0)
            
            if let contact = contacts[phone] {
                print("Dialing \(contact) (\(phone))...")
            } else {
                print("Contact not found")
            }
        })
        .addDisposableTo(disposeBag)
    
    input.onNext(0)
    input.onNext(603)
    
    input.onNext(2)
    input.onNext(1)
    
    // Confirm that 7 results in "Contact not found", and then change to 2 and confirm that Junior is found
    input.onNext(7)
    
    "5551212".characters.forEach {
        if let number = (Int("\($0)")) {
            input.onNext(number)
        }
    }
    
    input.onNext(9)
}

example(of: "share") {
    var start = 0
    func getStartNumber() -> Int {
        start += 1
        return start
    }
    
    let numbers = Observable<Int>.create({ (observer) -> Disposable in
        let start = getStartNumber()
        observer.onNext(start)
        observer.onNext(start + 1)
        observer.onNext(start + 2)
        observer.onCompleted()
        return Disposables.create()
    }).shareReplay(2)
    /*
        - share()  当有多个subscribes的时候observable不会被再次创建一个队列，除了第一个subscribe，其它的subscribe也就收不到next事件
        - shareReplay(<#T##bufferSize: Int##Int#>)  搞一个缓冲区指定其大小，用来保存第一次subscribe队列中发出的后几个value，其它的subscribe响应到的是缓冲区中的值
        - shareReplayLatestWhileConnected()
     */
    numbers.subscribe(onNext: { (el) in
        print(el)
    },onCompleted: {
        print("----------------")
    })
    
    numbers.subscribe(onNext: { (el) in
        print(el)
    },onCompleted: {
        print("----------------")
    })
    
    numbers.subscribe({ (event) in
        print(event)
    })
}
PlaygroundPage.current.needsIndefiniteExecution = true

//example(of: "take(duration)") {
    //在指定的schedule，只能响应到前5s的事件。5s后执行completed结束响应队列。如果提前响应到了completed事件则提前结束
//    PublishSubject<String>().take(5, scheduler: MainScheduler.instance).subscribe({ (event) in
//        print(event)
//    }).disposed(by: dispose)
//}

example(of: "throttle(_ dueTime: RxTimeInterval, latest: Bool = default, scheduler: SchedulerType)") {
    //节流。在dueTime时间段内只能响应一次next事件
    //latest是否保留最后一次响应。默认是true
    let variable = Variable([])
    variable.asObservable().throttle(2, latest: true, scheduler: MainScheduler.instance).subscribe({ (event) in
        print(event)
    }).disposed(by: dispose)
    
    variable.value.append(1)
    variable.value.append(2)
    variable.value.append(2)
    variable.value.append(2)
    variable.value.append(2)
//    for i in 1...10000 {
//        variable.value.append(i)
//    }
    
}







