//
//  PhotoCollectionViewCell.swift
//  Betterest
//
//  Created by Umar Qattan on 9/7/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(image: UIImage) {
        imageView.image = image
       
    }
    
}
