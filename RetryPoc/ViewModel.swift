//
//  ViewModel.swift
//  RetryPoc
//
//  Created by Ahmed on 22/03/2024.
//

import Foundation
class ViewModel: ObservableObject {

    @Published var items: [Item] = []
    @Published var isLoading: Bool = false
    private let itemService: ItemService

    init(itemService: ItemService = ItemServiceWithFallback()) {
        self.itemService = itemService
    }

    @MainActor
    func loadItems() async {
        isLoading = true
        do {
            //Fixme: Whenever the retry count goes beyond 2 or 3 the api gets triggered multiple times like for retry(2) api is triggered 4 times, for retry(3) api is triggered 6 times.
            let items = try await itemService.retry().loadItems()
            self.items = items
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
