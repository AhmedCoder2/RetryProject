//
//  RetryPocApp.swift
//  RetryPoc
//
//  Created by Ahmed on 22/03/2024.
//

import SwiftUI

@main
struct RetryPocApp: App {
    //let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            let api = ItemServiceApi()
            let cache = ItemServiceCache()
            let serviceWithFallback = ItemServiceWithFallback(primary: api, fallback: cache)
            let vm = ViewModel(itemService: api.retry(2).fallback(cache))
            ContentView(viewModel: vm)
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
