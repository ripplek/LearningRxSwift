//
//  PhotoWriter.swift
//  LearningRX
//
//  Created by 张坤 on 2017/5/23.
//  Copyright © 2017年 zhangkun. All rights reserved.
//

import UIKit
import RxSwift

class PhotoWriter: NSObject {
    typealias Callback = (NSError?)->()
    
    private var callback: Callback
    private init(callback: @escaping Callback) {
        self.callback = callback
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        callback(error)
    }
    
    static func save(image: UIImage) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let writer = PhotoWriter(callback: { (error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onCompleted()
                }
            })
            UIImageWriteToSavedPhotosAlbum(image, writer, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            return Disposables.create()
        })
    }
}

