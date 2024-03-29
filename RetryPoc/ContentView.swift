import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.items) { item in
                        Text(item.body)
                        .font(.headline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color.blue)
                    }
                }
                .padding()
            }
            .task {
                await viewModel.loadItems()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color.blue)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.gray)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
