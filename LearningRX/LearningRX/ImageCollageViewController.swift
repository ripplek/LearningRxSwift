//
//  ImageCollageViewController.swift
//  LearningRX
//
//  Created by 张坤 on 2017/5/23.
//  Copyright © 2017年 zhangkun. All rights reserved.
//

import UIKit
import RxSwift
import Photos

class ImageCollageViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private var images = Variable<[UIImage]>([])
    private var imageCache = [Int]()
    private let bag = DisposeBag()
    
    deinit {
        print("resources: \(RxSwift.Resources.total)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("resources: \(RxSwift.Resources.total)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newImages = images.asObservable().share()
        
        newImages.throttle(0.5, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] (photos) in
            guard let preview = self?.imagePreview else { return }
            print(photos)
            preview.image = UIImage.collage(images: photos, size: preview.frame.size)
        }).disposed(by: bag)
        
        newImages.subscribe(onNext: { [weak self] (photos) in
            self?.updateUI(photos: photos)
        }).disposed(by: bag)
    }

    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }


    @IBAction func actionClear(_ sender: Any) {
        images.value = []
        imageCache = []
    }
    
    @IBAction func actionSave(_ sender: Any) {
        guard let image = imagePreview.image else { return }
        PhotoWriter.save(image: image).subscribe(onError: { [weak self] (error) in
            self?.showMessage("Error", description: error.localizedDescription)
        }, onCompleted: { [weak self] in
            self?.showMessage("Save")
            self?.actionClear("actionSave")
        }).disposed(by: bag)
    }

    @IBAction func actionAdd(_ sender: Any) {
        let photosViewController = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        photosViewController.selectedPhotos.filter({ [weak self] (newImage) -> Bool in
            let len = UIImagePNGRepresentation(newImage)?.count ?? 0
            guard self?.imageCache.contains(len) == false else{
                return false
            }
            
            self?.imageCache.append(len)
            return true
        }).takeWhile({ [weak self] (newImage) -> Bool in
            (self?.images.value.count ?? 0) < 6
        }).subscribe(onNext: { [weak self] (image) in
            self?.images.value.append(image)
        }) { 
            print("disposed")
        }.disposed(by: photosViewController.bag)
        
        let newPhotos = photosViewController.selectedPhotos.share()
        newPhotos.filter({ (newImage) -> Bool in
            newImage.size.width > newImage.size.height
        }).subscribe(onCompleted: { [weak self] in
            self?.updateNavigationIcon()
        }).disposed(by: photosViewController.bag)
        
        navigationController?.pushViewController(photosViewController, animated: true)
    }
    
    private func updateNavigationIcon() {
        let icon = imagePreview.image?.scaled(CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func showMessage(_ title: String, description: String? = nil) {
        
        alert(title: title, text: description)
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(bag)
    }
    
    

}

extension UIImage {
    
    static func collage(images: [UIImage], size: CGSize) -> UIImage {
        let rows = images.count < 3 ? 1 : 2
        let columns = Int(round(Double(images.count) / Double(rows)))
        let tileSize = CGSize(width: round(size.width / CGFloat(columns)),
                              height: round(size.height / CGFloat(rows)))
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        for (index, image) in images.enumerated() {
            image.scaled(tileSize).draw(at: CGPoint(
                x: CGFloat(index % columns) * tileSize.width,
                y: CGFloat(index / columns) * tileSize.height
            ))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
    
    func scaled(_ newSize: CGSize) -> UIImage {
        guard size != newSize else {
            return self
        }
        
        let ratio = max(newSize.width / size.width, newSize.height / size.height)
        let width = size.width * ratio
        let height = size.height * ratio
        
        let scaledRect = CGRect(
            x: (newSize.width - width) / 2.0,
            y: (newSize.height - height) / 2.0,
            width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
        defer { UIGraphicsEndImageContext() }
        
        draw(in: scaledRect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}


