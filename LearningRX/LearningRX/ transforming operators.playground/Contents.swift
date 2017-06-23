//: Playground - noun: a place where people can play

import UIKit
import RxSwift
import PlaygroundSupport

var str = "Hello, playground"

public func example(of description: String, action: () -> Void) {
    print("\n--- Example of:", description, "---")
    action()
}


example(of: "toArray") { //将序列中的若干元素转换为一个数组元素
    let disposeBag = DisposeBag()
    
    Observable.of("A", "B", "C").toArray().subscribe({ (event) in
        print(event)
    }).disposed(by: disposeBag)
}

example(of: "map") { 
    let disposeBag = DisposeBag()
    
    Observable<Int>.of(1,2,3).map({
        $0 * 2
    }).subscribe(onNext: { (value) in
        print(value)
    }).disposed(by: disposeBag)
}

example(of: "mapWithIndex") {
    let disposeBag = DisposeBag()
    
    Observable.of(1,2,3,4,5,6).mapWithIndex({ (integer, index) in
        index > 2 ? integer * 2 : integer
    }).subscribe({
        print($0)
    }).disposed(by: disposeBag)
}

example(of: "flatMap") { //当Observable序列中的元素仍然是个Observable的时候，flatMap帮我们获取到我们需要的值,并生成一个新的Sequence
    struct Student {
        var score: Variable<Int>
    }
    
    let disposeBag = DisposeBag()
    
    let xiaoMing = Student(score: Variable(80))
    let xiaoHong = Student(score: Variable(95))
    
    let student = PublishSubject<Student>()
    
    student.asObservable().flatMap({
        $0.score.asObservable()
    }).subscribe({
        print($0)
    }).disposed(by: disposeBag)
    
    student.onNext(xiaoHong)
    student.onNext(xiaoMing)
    
    xiaoMing.score.value = 100
    
}

example(of: "flatMapLatest") {//跟flatMap相比较，flatMapLatest只能响应最后一个元素值的变化
    struct Student {
        var score: Variable<Int>
    }
    
    let disposeBag = DisposeBag()
    
    let xiaoMing = Student(score: Variable(80))
    let xiaoHong = Student(score: Variable(95))
    
    let student = PublishSubject<Student>()
    
    student.asObservable().flatMapLatest({
        $0.score.asObservable()
    }).subscribe({
        print($0)
    }).disposed(by: disposeBag)
    
    student.onNext(xiaoMing)
    xiaoMing.score.value = 65
    
    student.onNext(xiaoHong)
    xiaoMing.score.value = 88
    xiaoHong.score.value = 100
    
}

example(of: "challenge") {
    let dispose = DisposeBag()
    
    Observable.of(1,2,nil,3)
                .flatMap({
                    $0 == nil ? Observable.empty() : Observable.just($0!)
                })
                .subscribe({
                    print($0)
                }).disposed(by: dispose)
    
    
}

example(of: "startWith") { 
    let numbers = Observable.of(2,3,4)
    
    let observable = numbers.startWith(1)
    observable.subscribe(onNext: { (element) in
        print(element)
    }).dispose()
}

example(of: "Observable.concat") {
    let first = Observable.of(1,2,3)
    let second = Observable.of(4,5,6)
    
    let observable = Observable.concat([first, second])
    observable.subscribe(onNext: { (element) in
        print(element)
    }).dispose()
}

example(of: "concat") { 
    let germanCities = Observable.of("Berlin", "Münich", "Frankfurt")
    let spanishCities = Observable.of("Madrid", "Barcelona", "Valencia")
    let observable = germanCities.concat(spanishCities)
    observable.subscribe(onNext: { value in
        print(value)
    }).dispose()
}

example(of: "concat one element") {  //MARK: - concat合并的两个sequence元素必须是相同类型
    let numbers = Observable.of(2,3,4)
    
    let observable = Observable.just(1).concat(numbers)
    observable.subscribe(onNext: { (element) in
        print(element)
    }).dispose()
}

example(of: "merge") { 
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let source = Observable.of(left.asObservable(), right.asObservable())
    let observable = source.merge()
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    
    var leftValues = ["Berlin", "Munich", "Frankfurt"]
    var rightValues = ["Madrid", "Barcelona", "Valencia"]
    repeat {
        if arc4random_uniform(2) == 0 {
            if !leftValues.isEmpty {
                left.onNext("Left:  " + leftValues.removeFirst())
            }
        } else if !rightValues.isEmpty {
            right.onNext("Right: " + rightValues.removeFirst())
        }
    } while !leftValues.isEmpty || !rightValues.isEmpty
    
    disposable.dispose()
}

example(of: "combineLatest") { 
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    
    let observable = Observable.combineLatest(left,right)
    let disposable = observable.subscribe(onNext: { (left,right) in
        print(left,right)
    })
    
    print("> Sending a value to Left")
    left.onNext("Hello,")
    print("> Sending a value to Right")
    right.onNext("world")
    print("> Sending another value to Right")
    right.onNext("RxSwift")
    print("> Sending another value to Left")
    left.onNext("Have a good day,")
    
    disposable.dispose()
}

example(of: "combine user choice and value") {
    let bag = DisposeBag()
    
    let choice : Observable<DateFormatter.Style> =
        Observable.of(.short, .long)
    let dates = Observable.of(Date())
    let observable = Observable.combineLatest(choice, dates) {
        (format, when) -> String in
        let formatter = DateFormatter()
        formatter.dateStyle = format
        return formatter.string(from: when)
    }
    observable.subscribe(onNext: { value in
        print(value)
    }).addDisposableTo(bag)
}

example(of: "zip") {//把多个sequence合并为一个sequence，当所有的observable都产生element的时候，selector function会生成一个对应索引的element
    enum Weather {
        case cloudy
        case sunny
    }
    let bag = DisposeBag()
    
    let left = Observable<Weather>.of(.sunny, .cloudy, .cloudy, .sunny)
    let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid", "Vienna")
    
    let observable = Observable.zip(left, right){ (weather, city) -> String in
        "it's \(weather) in \(city)"
    }
    observable.subscribe(onNext: { (result) in
        print(result)
    }).addDisposableTo(bag)
}

example(of: "withLatestFrom") {//将两个 observable sequence 合并到一个 observable sequence ，每当self发出element将获取到第二个 observable sequence 的最新element
    let bag = DisposeBag()
    
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = button.withLatestFrom(textField)
    observable.subscribe(onNext: { (text) in
        print(text)
    }).addDisposableTo(bag)
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    
    button.onNext()
    button.onNext()
}

example(of: "sample") { //每当sampler产生一个`.next()`事件，将从源sequence中获取最新element，如果在sampler两次事件间隔中源sequence没有新element产生，则获取不到element
    let bag = DisposeBag()
    
    let button = PublishSubject<Void>()
    let textField = PublishSubject<String>()
    
    let observable = textField.sample(button)
    observable.subscribe(onNext: { (text) in
        print(text)
    }).addDisposableTo(bag)
    
    textField.onNext("Par")
    textField.onNext("Pari")
    textField.onNext("Paris")
    
    button.onNext()
    button.onNext()

}

example(of: "amb") {//两个observable sequence谁先发送element谁就是第一响应者。
    let left = PublishSubject<String>()
    let right = PublishSubject<String>()
    // 1
    let observable = left.amb(right)
    let disposable = observable.subscribe(onNext: { value in
        print(value)
    })
    // 2
    right.onNext("Copenhagen")
    left.onNext("Lisbon")
    left.onNext("London")
    left.onNext("Madrid")
    right.onNext("Vienna")
    disposable.dispose()
}

example(of: "switchLatest") {//响应最新的observable sequence中的element
    let one = PublishSubject<String>()
    let two = PublishSubject<String>()
    let three = PublishSubject<String>()
    
    let source = PublishSubject<Observable<String>>()
    let observable = source.switchLatest()
    let dispose = observable.subscribe(onNext: { (value) in
        print(value)
    })
    
    source.onNext(one)
    one.onNext("one first")
    two.onNext("two first")
    
    source.onNext(two)
    one.onNext("one second")
    two.onNext("two second")
    
    source.onNext(three)
    three.onNext("three first")
    one.onNext("one third")
    three.onNext("three second")
    
    source.onNext(two)
    two.onNext("two third")
    three.onNext("three third")
}

example(of: "reduce") { //将一个observable sequence中的元素做一个累加，返回一个单一的结果。第一个参数为最初的累加值
    let source = Observable.of(1, 3, 5, 7, 9)
    
    let observable = source.reduce(0, accumulator: { summary, newValue in
        return summary + newValue
    }) //可简写为    let observable = source.reduce(0, accumulator: +)
    
    observable.subscribe(onNext: { value in
        print(value)
    })
}

example(of: "scan") { //将一个observable sequence中的元素做一个累加，返回每个累加结果。第一个参数为最初的累加值
    let source = Observable.of(1,3,5,7,9)
    
    let observable = source.scan(0, accumulator: { (summary, newValue) -> Int in
        return summary + newValue
    }) // 可简写为      let observable = source.scan(0, accumulator: +)
    observable.subscribe(onNext: { (value) in
        print(value)
    })
}








