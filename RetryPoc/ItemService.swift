//
//  ItemService.swift
//  RetryPoc
//
//  Created by Ahmed on 22/03/2024.
//

import Foundation

protocol ItemService {
    func loadItems() async throws -> [Item]
}

struct ItemServiceCache: ItemService {
    
    func loadItems() async throws -> [Item] {
        return [Item(userId: 1, id: 101, title: "Hello World!", body: "This is from cache.")]
        //print("***Trying to fetch from cache.")
        //throw NSError(domain: "", code: 500)
    }
    
}

struct ItemServiceApi: ItemService {
    
    func loadItems() async throws -> [Item] {
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

struct Item: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
    
    init(userId: Int, id: Int, title: String, body: String) {
        self.userId = userId
        self.id = id
        self.title = title
        self.body = body
    }
}

struct ItemServiceWithFallback: ItemService {
    private let primary: ItemService
    //Note: Fallback will be changed to cache in future
    private let fallback: ItemService

    init(primary: ItemService,
         fallback: ItemService) {
        self.primary = primary
        self.fallback = fallback
        print("***init called.")
    }

    func loadItems() async throws -> [Item] {
        // Improve this: Check if we have better options than nested do try catch
        do {
            return try await primary.loadItems()
        } catch {
            print("***ItemServiceWithFallback catch - Error")
            do {
                print("***Triggering fallback...")
                return try await fallback.loadItems()
            } catch {
                print("***ItemServiceWithFallback nested catch - Error")
                throw error
            }
        }
    }
}



extension ItemService {
    func retry() -> ItemService {
        fallback(self)
    }

    func fallback(_ fallback: ItemService) -> ItemService {
        ItemServiceWithFallback(primary: self, fallback: fallback)
    }

    func retry(_ retryCount: Int) -> ItemService {
        //retryCount == 0 ? self : fallback(self).retry(retryCount - 1)
        var service: ItemService = self
        for _ in 0..<retryCount {
            service = service.fallback(self)
        }
        return service
    }
}
