//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}

example(of: "What is an observable?") { 
    let one = 1
    let two = 2
    let three = 3
    let observable: Observable<Int> = Observable<Int>.just(one)

}

example(of: "of") { 
    let one = 1
    let two = 2
    let three = 3
    let observable = Observable.of(one, two, three)
    
    observable.subscribe({ (event) in
        print(event)
    })
}

example(of: "from") {
    let one = 1
    let two = 2
    let three = 3
    let observable = Observable.from([one, two, three])
    
    observable.subscribe({ (event) in
        print(event)
    })
}

example(of: "subscribe") {
    let one = 1
    let two = 2
    let three = 3
    
    let observable: Observable<Int> = Observable<Int>.just(one)
    let observable2 = Observable.of(one, two, three)
    let observable3 = Observable.of([one, two, three])
    let observable4 = Observable.from([one, two, three])
    observable4.subscribe({ (event) in
        print(event)
        if let element = event.element {
            print(element)
        }
    })
}

example(of: "empty") { //只能收到completed
    let observable = Observable<Void>.empty()
    observable.subscribe({ (event) in
        print(event)
    })
}

example(of: "never") { 
    let observable = Observable<Any>.never()
    observable.subscribe({ (event) in
        print(event)
    })
}

example(of: "range") { 
    let observable = Observable<Int>.range(start: 1, count: 10)
    observable.subscribe(onNext: { (i) in
//        print(i)
        let n = Double(i)
        let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
            2.23606).rounded())
        print(fibonacci)
    })
}

example(of: "DisposeBag") {
    let disposeBag = DisposeBag()
    Observable.of("A", "B", "C").subscribe({
        print($0)
    }).addDisposableTo(disposeBag) //addDisposableTo释放observable
}

example(of: "create") {
    enum MyError: Error {
        case anError
    }
    
    Observable<String>.create({ (observer) -> Disposable in
        observer.onNext("1")
//        observer.onError(MyError.anError)
//        observer.onCompleted()
        observer.onNext("?")
        return Disposables.create()
    }).subscribe({ (event) in
        print(event)
    }).disposed(by: DisposeBag())
}

example(of: "deferred") { 
    let disposeBag = DisposeBag()
    var flip = false
    
    let factory:Observable<Int> = Observable.deferred({ () -> Observable<Int> in
        flip = !flip
        if flip {
            return Observable.of(1,2,3)
        } else {
            return Observable.of(4,5,6)
        }
    })
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        }).addDisposableTo(disposeBag)
        print()
    }
}

/*
 • PublishSubject: Starts empty and only emits new elements to subscribers.
 • BehaviorSubject: Starts with an initial value and replays it or the latest element to new subscribers.
 • ReplaySubject: Initialized with a buffer size and will maintain a buffer of elements up to that size and replay it to new subscribers.
 • Variable: Wraps a BehaviorSubject, preserves its current value as state, and replays only the latest/initial value to new subscribers.
 */

example(of: "PublishSubject") {
    let subject = PublishSubject<String>()
    subject.onNext("Is anyone listening?")
    let subscriptionOne = subject.subscribe(onNext: { string in
            print(string)
        })
    subject.on(.next("1"))
    subject.onNext("2")
    
    let subscriptionTwo = subject
        .subscribe { event in
            print("2)", event.element ?? event)
    }
    subject.onNext("3")
    subscriptionOne.dispose()
    subject.onNext("4")
    
    // 1
    subject.onCompleted()
    // 2
    subject.onNext("5")
    // 3
    subscriptionTwo.dispose()
    let disposeBag = DisposeBag()
    // 4
    subject.subscribe {
            print("3)", $0.element ?? $0)
    }.addDisposableTo(disposeBag)
    subject.onNext("?")
}

// 1
enum MyError: Error {
    case anError
}
// 2
func print<T: CustomStringConvertible>(label: String, event: Event<T>) {
    print(label, event.element ?? event.error ?? event)
}
// 3
example(of: "BehaviorSubject") {
    // 4
    let subject = BehaviorSubject(value: "Initial value")
    let disposeBag = DisposeBag()
    
    subject.subscribe {
            print(label: "1)", event: $0)
        }.addDisposableTo(disposeBag)
    subject.onNext("X")
    // 1
    subject.onError(MyError.anError)
    // 2
    subject.subscribe {
            print(label: "2)", event: $0)
        }.addDisposableTo(disposeBag)
}

example(of: "ReplaySubject") {
    // 1
    let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()
    // 2
    subject.onNext("1")
    subject.onNext("2")
    subject.onNext("3")
    // 3
    subject
        .subscribe {
            print(label: "1)", event: $0)
        }
        .addDisposableTo(disposeBag)
    subject
        .subscribe {
            print(label: "2)", event: $0)
        }
        .addDisposableTo(disposeBag)
    
    subject.onNext("4")
    subject.onError(MyError.anError)
    subject.dispose()

    subject
        .subscribe {
            print(label: "3)", event: $0)
    }
        .addDisposableTo(disposeBag)
}

example(of: "Variable") {
    // 1
    var variable = Variable("Initial value")
    let disposeBag = DisposeBag()
    // 2
    variable.value = "New initial value"
    // 3
    variable.asObservable()
        .subscribe {
            print(label: "1)", event: $0)
        }
        .addDisposableTo(disposeBag)
    // 1
    variable.value = "1"
    // 2
    variable.asObservable()
        .subscribe {
            print(label: "2)", event: $0)
        }
        .addDisposableTo(disposeBag)
    // 3
    variable.value = "2"
    
    // These will all generate errors
//    variable.value.onError(MyError.anError)
//    variable.asObservable().onError(MyError.anError)
//    variable.value = MyError.anError
//    variable.value.onCompleted()
//    variable.asObservable().onCompleted()
 
}
