//
//  Model.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 4/26/23.
//

import Foundation

// network model
struct SearchResults: Codable {
    var searchType: String
    var expression: String
    var results: [SingleResult]
    var errorMessage: String
}

struct SingleResult: Codable {
    var id: String
    var resultType: String
    var imageURLString: String
    var title: String
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case resultType
        case imageURLString = "image"
        case title
        case description
    }
}

// локальная модель данных для отображения
struct ResultForDisplay {
    var title: String
    var description: String
    var imageURLString: String
    
    init(networkModel: SingleResult) {
        self.title = networkModel.title
        self.description = networkModel.description
        self.imageURLString = networkModel.imageURLString
    }
}
