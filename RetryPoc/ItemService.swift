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

struct ItemServiceApi: ItemService {
    
    func loadItems() async throws -> [Item] {
        let urlString = "https://jsonplaceholder.typicode.com/posts"
        
        do {
            print("***Api call triggered.")
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: URL(string: urlString)!))
            let items = try JSONDecoder().decode([Item].self, from: data)
            return items
            
        } catch {
            print("***Api error :\(error)")
            throw error
        }
    }
    
}

struct Item: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct ItemServiceWithFallback: ItemService {
    private let primary: ItemService
    //Note: Fallback will be changed to cache in future
    private let fallback: ItemService

    init(primary: ItemService = ItemServiceApi(),
         fallback: ItemService = ItemServiceApi()) {
        self.primary = primary
        self.fallback = fallback
    }

    

    func loadItems() async throws -> [Item] {
        // Improve this: Check if we have better options than nested do try catch
        do {
            return try await primary.loadItems()
        } catch {
            //print("***ItemServiceWithFallback catch - Error: \(error)")
            do {
                return try await fallback.loadItems()
            } catch {
                print("***ItemServiceWithFallback nested catch - Error: \(error)")
                throw error
            }
        }
    }
}



extension ItemService {
//    func retry() -> ItemService {
//        fallback(self)
//    }

    func fallback(_ fallback: ItemService) -> ItemService {
        ItemServiceWithFallback(primary: self, fallback: fallback)
    }

    func retry(_ retryCount: Int = 1) -> ItemService {
        retryCount == 0 ? self : fallback(self).retry(retryCount - 1)
    }
}
