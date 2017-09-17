//
//  PhotoRankViewController.swift
//  Photoshoot
//
//  Created by Umar Qattan on 9/16/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit


class PhotoRankViewController: UIViewController {
    
    var photos:[Photo] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.dataSource = self
    }
    
    
    
}


extension PhotoRankViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as! PhotoCollectionViewCell
        
        cell.configure(image: self.photos[indexPath.row].image, rank: indexPath.row)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
    }
    
}


