//
//  ItemService.swift
//  RetryPoc
//
//  Created by Ahmed on 22/03/2024.
//

import Foundation

public protocol ItemService {
    func loadItems() async throws -> [Item]
}

public struct ItemServiceCache: ItemService {
    
    public init() {}
    
    public func loadItems() async throws -> [Item] {
        print("***Data returned from cache.")
        return [Item(userId: 1, id: 101, title: "Hello World!", body: "This is from cache.")]
        //throw NSError(domain: "", code: 500)
    }
    
}

public struct ItemServiceApi: ItemService {
    
    public init() {}
    
    public func loadItems() async throws -> [Item] {
        let urlString = "https://jsonplaceholder.typicode.com/posts"
        do {
            print("***Api call triggered.")
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: URL(string: urlString)!))
            let items = try JSONDecoder().decode([Item].self, from: data)
            return items
        } catch {
            print("***Api error")
            throw error
        }
    }    
}

public struct ItemServiceWithFallback: ItemService {
    private let primary: ItemService
    private let fallback: ItemService

    public init(primary: ItemService,
         fallback: ItemService) {
        self.primary = primary
        self.fallback = fallback
        print("***ItemServiceWithFallback init called.")
    }

    public func loadItems() async throws -> [Item] {
        do {
            return try await primary.loadItems()
        } catch {
            print("***Triggering fallback...")
            return try await fallback.loadItems()
        }
    }
}
