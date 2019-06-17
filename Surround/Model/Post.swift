//
//  Post.swift
//  Surround
//
//  Created by Frank Chen on 2019-04-18.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

struct Post {
    let uid: String
    let imageUrl: String
    let creationDate: Date
    let long: Double
    let lat: Double
    let colour: String
    
    init(dictionary:[String:Any]) {
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.creationDate = dictionary["creationDate"] as? Date ?? Date()
        self.uid = dictionary["uid"] as? String ?? ""
        self.long = dictionary["longitude"] as? Double ?? 0
        self.lat = dictionary["latitude"] as? Double ?? 0
        self.colour = dictionary["colour"] as? String ?? ""
    }
}


