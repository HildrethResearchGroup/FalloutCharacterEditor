//
//  ContentView.swift
//  Fallout Save Editor
//
//  Created by Kyle Collins on 10/9/24.
//
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var fileReader = FileReader()
    @State private var isFileImporterPresented = false
    
    // Define a custom UTType for .DAT files
    let datFileType = UTType(filenameExtension: "dat") ?? .data

    var body: some View {
        VStack {
            Text("Selected File: \(fileReader.fileName)")
                .padding()

            Text(fileReader.fileSize) // Display file size
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 50)
            
            Button("Select File") {
                isFileImporterPresented.toggle()
            }
            .padding()
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [datFileType], // Accept only .DAT files
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        fileReader.urlToPresent = url
                        fileReader.updateContent() // read the file and display its size
                    case .failure(let error):
                        fileReader.fileSize = "File selection failed: \(error.localizedDescription)"
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
