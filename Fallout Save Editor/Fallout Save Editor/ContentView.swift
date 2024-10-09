//
//  ContentView.swift
//  Fallout Save Editor
//
//  Created by Kyle Collins on 10/9/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var fileReader = FileReader() // Initialize FileReader as a state object
    @State private var isFileImporterPresented = false // State for handling file importer presentation

    var body: some View {
        VStack {
            Text("Selected File: \(fileReader.fileName)")
                .padding()

            Text(fileReader.content)
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 200) // Set a fixed height for the Text view
            
            Button("Select File") {
                isFileImporterPresented.toggle()
            }
            .padding()
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [.plainText],
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        fileReader.urlToPresent = url
                        fileReader.updateContent()
                    case .failure(let error):
                        fileReader.content = "File selection failed: \(error.localizedDescription)"
                    }
                }
            )
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
