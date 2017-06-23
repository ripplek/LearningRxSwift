//
//  RegisterViewController.swift
//  LearningRX
//
//  Created by 张坤 on 2017/5/18.
//  Copyright © 2017年 zhangkun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum ValidationResult {
    case empty
    case validating
    case success(message:String)
    case failed(message:String)
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var usernameValidation: UILabel!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordValidation: UILabel!
    
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet var repeatPasswordValidation: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    
    let dispose = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validatedUsername.bind(to: usernameValidation.rx.validationResult).disposed(by: dispose)
        
        validatedPassword.bind(to: passwordValidation.rx.validationResult).disposed(by: dispose)
        
        validatedRepeatPassword.bind(to: repeatPasswordValidation.rx.validationResult).disposed(by: dispose)
        
        registerEnabled.subscribe(onNext: {[weak self] (valid) in
            guard let Strongself = self else {
                return
            }
            printLog(valid)
            Strongself.registerButton.isEnabled = valid
            Strongself.registerButton.alpha = valid ? 1.0 : 0.5
        }).disposed(by: dispose)
        
        registerButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { (_) in
            //获取usernameAndPassword发送网络请求注册
            printLog(self.userName.text,self.password.text)
        }.disposed(by: dispose)
    }
    

     //MARK: - Observable
    /// validatedUsername
    private var validatedUsername: Observable<ValidationResult> {
        return userName.rx.text.orEmpty.asObservable().map { (username) -> ValidationResult in
            //是否为空
            if username.characters.count == 0{
                return .empty
            }
            //是否是数字和字母
            if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
                return  .failed(message: "Username can only contain numbers or digits")
            }
            //发送请求验证用户名是否存在
            //if valid
            return .success(message: "验证通过")
            //else
//            return .failed(message: "The username has been registered")
            }.shareReplay(1)
    }
    
    /// validatedPassword
    private var validatedPassword: Observable<ValidationResult> {
        return password.rx.text.orEmpty.asObservable().map { (text) -> ValidationResult in
            return text == "" ? .empty : .success(message: "验证通过")
            }.shareReplay(1)
    }
    
    /// validatedRepeatPassword
    private var validatedRepeatPassword: Observable<ValidationResult> {
        return Observable.combineLatest(password.rx.text.orEmpty.asObservable(), repeatPassword.rx.text.orEmpty.asObservable()) { (password, repeatPassword) -> ValidationResult in
            if repeatPassword == "" {
                return .empty
            } else if repeatPassword != password {
                return .failed(message: "两次输入的密码不一致")
            } else if repeatPassword == password {
                return .success(message: "验证通过")
            } else {
                return .empty
            }
        }.shareReplay(1)
    }
    
    /// registerEnabled
    private var registerEnabled: Observable<Bool> {
        return Observable.combineLatest(validatedUsername, validatedPassword, validatedRepeatPassword) { (username, password, repeatPassword) -> Bool in
            if username.isValid && password.isValid && repeatPassword.isValid {
                return true
            }
            return false
        }.distinctUntilChanged().shareReplay(1)
    }

}

 //MARK: - EXT
extension Reactive where Base: UILabel {
    var validationResult: UIBindingObserver<Base, ValidationResult> {
        return UIBindingObserver(UIElement: base, binding: { (label, result) in
            label.text = result.description
            label.textColor = result.textColor
        })
    }
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case .empty:
            return ""
        case .validating:
            return "validating..."
        case let .success(message):
            return message
        case let .failed(message):
            return message
        }
    }
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .success:
            return ValidationClolrs.successColor
        case .failed:
            return ValidationClolrs.errorColor
        }
    }
}

struct ValidationClolrs {
    static let successColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

func printLog<T>(_ message: T..., file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)],\(method):\(message)")
    #endif
}
