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

enum APIError: Error {
    case serverError(String)
    case unknownError(Int)
    case invalidURL
    case invalidResponse
}

struct ServerError: Codable {
    let error, errorDescription: String

    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}

public struct ItemServiceApi: ItemService {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func loadItems() async throws -> [Item] {
        let urlString = "https://jsonplaceholder.typicode.com/posts"
        do {
            print("***Api call triggered.")
            let (data, response) = try await session.data(for: URLRequest(url: URL(string: urlString)!))
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decoder = JSONDecoder()
                    let decoded = try decoder.decode([Item].self, from: data)
                    return decoded
                } catch {
                    throw APIError.invalidResponse
                }
            case 400...499:
                if let error = try? JSONDecoder().decode(ServerError.self, from: data) {
                    throw APIError.serverError(error.errorDescription)
                } else {
                    throw APIError.invalidResponse
                }
            case 500...599:
                throw APIError.unknownError(httpResponse.statusCode)
            default:
                throw APIError.invalidResponse
            }
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
