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
    //@IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension PhotoRankViewController: UITableViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

extension PhotoRankViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photo") as! PhotoTableViewCell
        cell.configure(photo: photos[indexPath.row], rank: indexPath.row)
        return cell
        
    }
}

//extension PhotoRankViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.photos.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as! PhotoCollectionViewCell
//
//        cell.configure(image: self.photos[indexPath.row].image, rank: indexPath.row)
//
//        return cell
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
//    }
//
//}



