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

    init(itemService: ItemService) {
        self.itemService = itemService
    }

    @MainActor
    func loadItems() async {
        isLoading = true
        do {
            let items = try await itemService.loadItems()
            self.items = items
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}
