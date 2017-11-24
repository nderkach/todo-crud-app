//
//  Idea.swift
//  CMX
//
//  Created by Nikolay Derkach on 11/6/17.
//  Copyright © 2017 Nikolay Derkach. All rights reserved.
//

import Foundation

class Idea: Codable {
    let id: String
    let content: String
    let impact: Int
    let ease: Int
    let confidence: Int
    let averageScore: Double
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case impact
        case ease
        case confidence
        case averageScore = "average_score"
        case createdAt = "created_at"
    }

    init(id: String = "", content: String = "", impact: Int = 10, ease: Int = 10, confidence: Int = 10, averageScore: Double = 10, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.impact = impact
        self.ease = ease
        self.confidence = confidence
        self.averageScore = averageScore
        self.createdAt = createdAt
    }
}

