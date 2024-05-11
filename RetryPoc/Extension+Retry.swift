//
//  Extension+Retry.swift
//  RetryPoc
//
//  Created by Ahmed on 11/05/2024.
//

import Foundation
import ItemDomain

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
