//
//  PhotoTableViewCell.swift
//  Betterest
//
//  Created by Umar Qattan on 9/18/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//


import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var incomingLabel: UILabel!
    @IBOutlet weak var outgoingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(photo: Photo, rank:Int) {
        photoImageView.image = photo.image
        rankLabel.text = "\(rank+1)"
        nameLabel.text = photo.name
        incomingLabel.text = "\(photo.incoming)"
        outgoingLabel.text = "\(photo.outgoing)"
    }
    
    
}
