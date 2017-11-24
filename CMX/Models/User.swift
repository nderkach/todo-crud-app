//
//  User.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/6/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Foundation

struct User: Decodable {
    let email: String
    let name: String
    let avatarUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case email
        case name
        case avatarUrl = "avatar_url"
    }
}
