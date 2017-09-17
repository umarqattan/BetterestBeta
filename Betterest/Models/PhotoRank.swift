//
//  PhotoRank.swift
//  Betterest
//
//  Created by Umar Qattan on 9/15/17.
//  Copyright © 2017 Umar Qattan. All rights reserved.
//

import Foundation
import UIKit

struct PhotoPageRank {
    
    var photos:[Photo]
    var photoRanks:[[Float]]
    var iterations: Int
    var finalPhotoSortedRankings:[Photo]
    
    init(photos: [Photo], iterations:Int) {
        self.photos = photos
        self.iterations = iterations
        self.finalPhotoSortedRankings = []
        self.photoRanks = Array(repeating: Array(repeating: 0.0,
                                                 count: self.photos.count),
                                count: self.iterations)
        for j in 0...self.photos.count-1 {
            self.photoRanks[0][j] = 1.0/Float(self.photos.count)
            
        }
        
    }
    
    public mutating func rankings(photosMatrix:[[Int]]) -> [Photo]? {
        for k in 1...self.iterations-1 {
            for i in 0...self.photos.count-1 {
                for j in 0...self.photos.count-1 {
                    if photosMatrix[i][j] == -1 && i != j && self.photos[j].outgoing > 0 {
                        self.photoRanks[k][i] += (self.photoRanks[k-1][j]/Float(self.photos[j].outgoing))
                    }
                }
            }
        }
        var finalPhotoRankings = self.photoRanks[self.iterations-1]
        for i in 0...self.photos.count-1 {
            self.photos[i].photoRank = finalPhotoRankings[i]
        }
        self.finalPhotoSortedRankings = self.photos.sorted(by: {($0.photoRank > $1.photoRank)})
        return self.finalPhotoSortedRankings
    }
    
    public func displayPhotoRankings() -> String {
        var rankingsString = ""
        
        for photo in finalPhotoSortedRankings {
            rankingsString += " \(photo.description)"
        }
        
        return rankingsString
    }
}

struct Photo {
    var name: String
    var image:UIImage
    var incoming:Int
    var outgoing:Int
    var photoRank:Float
    
    
    init(name:Int, image: UIImage) {
        self.name = "\(name)"
        self.incoming = 1
        self.outgoing = 0
        self.photoRank = 0.0
        self.image = image
    }
    
}

extension Photo: CustomStringConvertible {
    public var description: String {
        return name
    }
}


