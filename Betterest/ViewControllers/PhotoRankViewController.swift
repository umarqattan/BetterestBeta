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
        
        cell.configure(image: self.photos[indexPath.row].image)
        
        return cell
        
    }
}
