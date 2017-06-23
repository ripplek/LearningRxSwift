//
//  UIAlertViewController+Rx.swift
//  LearningRX
//
//  Created by 张坤 on 2017/5/26.
//  Copyright © 2017年 zhangkun. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    func alert(title: String, text: String?) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: {_ in
                observer.onCompleted()
            }))
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
