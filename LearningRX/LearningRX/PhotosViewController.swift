//
//  PhotosViewController.swift
//  LearningRX
//
//  Created by 张坤 on 2017/5/23.
//  Copyright © 2017年 zhangkun. All rights reserved.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "Cell"

class PhotosViewController: UICollectionViewController {
    let bag = DisposeBag()
    
    //MARK: private propertise
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObserver()
    }
    
    //MARK: private propertise
    fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
    
    private lazy var imageManager = PHImageManager()
    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale,
                      height: cellSize.height * UIScreen.main.scale)
    }()
    
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotoOptions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let authorized = PHPhotoLibrary.authorized.share()
        
        authorized
            .skipWhile { $0 == false }
            .take(1)
            .subscribe { [weak self] (_) in
                self?.photos = PhotosViewController.loadPhotos()
                print(Thread.current)
                DispatchQueue.main.async {
                    self?.collectionView?.reloadData()
                }
        }.disposed(by: bag)
        
        authorized
            .skip(1)
            .takeLast(1)
            .filter { $0 == false }
            .subscribe(onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else { return }
                DispatchQueue.main.async(execute: errorMessage)
        }).disposed(by: bag)
    }

    private func errorMessage() {
        alert(title: "No access to Camera Roll",
              text: "You can grant access to Combinestagram from the Settings app")
            .take(5, scheduler: MainScheduler.instance)
            .subscribe(onDisposed: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
            })
            .addDisposableTo(bag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        selectedPhotosSubject.onCompleted()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, _) in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                if let image = image {
                    cell.imageView.image = image
                }
            }
        }
        // Configure the cell
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            guard let image = image, let info = info else { return }
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self.selectedPhotosSubject.onNext(image)
            }
        }
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
