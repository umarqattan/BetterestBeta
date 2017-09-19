//
//  PhotoPickerViewController.swift
//  FitFilter
//
//  Created by Umar Qattan on 9/7/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//

import UIKit
import PhotosUI


class PhotoPickerViewController: UIViewController {

    var photoShootAlbum = PhotoShootAlbum.shared
    var photos:[UIImage] = []
    var photosStructs:[Photo] = []
    var favoritePhotos:[UIImage] = []
    var unFavoritePhotos:[UIImage] = []
    var photoPairs:[(UIImage, UIImage)] = []
    var photoPageRank:PhotoPageRank!
    
    var rightSwipeGestureRecognizer: UISwipeGestureRecognizer!
    var leftSwipeGestureRecognizer: UISwipeGestureRecognizer!
    var photoMatrix:[[Int]]!
    var i = 0
    var j = 1
    var photoCount = 0
    @IBOutlet weak var pairsRemainingLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var rankButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        photoPairs = generatePhotoPairs(photos: photos)

        if photoPairs.count >= 1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.leftImageView.image = self.photoPairs.first!.0
                self.rightImageView.image = self.photoPairs.first!.1
            })
            
        }
        pairsRemainingLabel.text = "\(photoPairs.count)"

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        rankButton.isEnabled = false
        rankButton.isHidden = true
        rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PhotoPickerViewController.swipe(_:)))
        leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PhotoPickerViewController.swipe(_:)))
        rightSwipeGestureRecognizer.direction = .right
        leftSwipeGestureRecognizer.direction = .left
        
        
        view.addGestureRecognizer(rightSwipeGestureRecognizer)
        view.addGestureRecognizer(leftSwipeGestureRecognizer)
        
        let assetCollection = photoShootAlbum.fetchAssetCollectionForAlbum()
        
        let imageManager = PHImageManager()
        
        if let assetCollection = assetCollection {
            let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
            
            assets.enumerateObjects{ (object:AnyObject!, count:Int, stop: UnsafeMutablePointer<ObjCBool>)  in
                    if object is PHAsset{
                    let asset = object as! PHAsset
                    
                    
                    let imageSize = CGSize(width: asset.pixelWidth,
                    height: asset.pixelHeight)
                    
                    let options = PHImageRequestOptions()
                        options.deliveryMode = .fastFormat
                        options.isSynchronous = true
                    
                        imageManager.requestImage(for: asset,
                                                  targetSize: imageSize,
                                                  contentMode: .aspectFit,
                                                  options: options,
                                                  resultHandler: {
                                                    (image, info) -> Void in
                                                    if let image = image {
                                                        
                                                        self.photos.append(image)
                                                        let photo = Photo(name: self.photoCount, image: image)
                                                        self.photosStructs.append(photo)
                                                        self.photoCount += 1
                                                        print("Count=\(count)")
                        }
                    })
                }
            }
        }
    }
    
    @objc func swipe(_ sender: UISwipeGestureRecognizer) {
       
        
        
        if photoPairs.count == 0 {
            
            return
        }
        
        
        
        if photoPairs.count > 1 {
            
            _ = photoPairs.removeFirst()
            UIView.animate(withDuration: 1.0, animations: {
                self.leftImageView.image = self.photoPairs.first!.0
                self.rightImageView.image = self.photoPairs.first!.1
            })
            
            
            if sender.direction == .left {
                photosStructs[i].incoming += 1
                photosStructs[j].outgoing += 1
                photoMatrix[i][j] = -1
                photoMatrix[j][i] = 1
            }
            if sender.direction == .right {
                photosStructs[i].outgoing += 1
                photosStructs[j].incoming += 1
                photoMatrix[i][j] = 1
                photoMatrix[j][i] = -1
            }
        
            if j == (photos.count-1) {
                i += 1
                j = i+1
            } else {
                j = j+1
            }
        } else if photoPairs.count == 1 {
            
            
            UIView.animate(withDuration: 1.0, animations: {
                self.leftImageView.image = self.photoPairs.first!.0
                self.rightImageView.image = self.photoPairs.first!.1
            })
            
            if sender.direction == .left {
                photosStructs[i].incoming += 1
                photosStructs[j].outgoing += 1
                photoMatrix[i][j] = -1
                photoMatrix[j][i] = 1
            }
            if sender.direction == .right {
                photosStructs[i].outgoing += 1
                photosStructs[j].incoming += 1
                photoMatrix[i][j] = 1
                photoMatrix[j][i] = -1
            }
            
            if j == (photos.count-1) {
                i += 1
                j = i+1
            } else {
                j = j+1
            }
            
            photoPageRank = PhotoPageRank(photos: photosStructs, iterations: 3)
            if let photosRankings = photoPageRank.rankings(photosMatrix: photoMatrix) {
                for photo in photosRankings {
                    print(photo.name)
                }
                
            }
            
            for row in photoMatrix {
                print(row)
            }
            
            _ = photoPairs.removeFirst()
            leftImageView.image = nil
            rightImageView.image = nil
            rankButton.isHidden = false
            rankButton.isEnabled = true
            
        }
        
        print("PhotoPairsCount=\(photoPairs.count)")
        pairsRemainingLabel.text = "\(photoPairs.count)"
    }
    
    func generatePhotoPairs(photos:[UIImage]) -> [(UIImage, UIImage)] {
        
        var photoPairs:[(UIImage, UIImage)] = []
        for x in 0...photos.count-1 {
            for y in (x+1)..<photos.count {
                print("i=\(x),j=\(y)")
                photoPairs.append((photos[x], photos[y]))
            }
        }
        photoMatrix = Array(repeating: Array(repeating: 0,
                                             count: photos.count),
                            count: photos.count)
        return photoPairs
    }
    
    
    
    
    @IBAction func rank(_ sender: UIButton) {
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "PhotoRank" {
                let destination = segue.destination as! PhotoRankViewController
                destination.photos = photoPageRank.finalPhotoSortedRankings
            }
        }
    }
    
    
}


