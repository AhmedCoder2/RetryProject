//
//  ItemModel.swift
//  ItemDomain
//
//  Created by Ahmed on 11/05/2024.
//

import Foundation

public struct Item: Codable, Identifiable {
    public let userId: Int
    public let id: Int
    public let title: String
    public let body: String
    
    public init(userId: Int, id: Int, title: String, body: String) {
        self.userId = userId
        self.id = id
        self.title = title
        self.body = body
    }
}
