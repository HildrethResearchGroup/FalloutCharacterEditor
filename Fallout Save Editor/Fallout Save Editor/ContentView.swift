//
//  ContentView.swift
//  Fallout Save Editor
//
//  Created by Kyle Collins on 10/9/24.
//
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject private var fileReader = FalloutSaveFile()
    @State private var isFileImporterPresented = false
    
    // Define the DAT file type for the file importer
    let datFileType = UTType(filenameExtension: "dat") ?? .data
    
    var body: some View {
        VStack {
            Text("Selected File: \(fileReader.fileName)")
                .padding()

            Text(fileReader.fileSize)
                .padding()
                .border(Color.gray, width: 1)
                .frame(height: 50)
            
            Button("Select File") {
                isFileImporterPresented.toggle()
            }
            Button("Cancel"){
                //change button activity
            }
            .buttonStyle(.borderedProminent)
            
            .padding()
            .fileImporter(
                isPresented: $isFileImporterPresented,
                allowedContentTypes: [datFileType],
                onCompletion: { result in
                    switch result {
                    case .success(let url):
                        fileReader.urlToPresent = url
                        fileReader.loadSaveFile(from: url) // Call the file loader
                        fileReader.printHeaderContents()    // Print header contents
                        
                        // Initialize the inspector with the loaded data
                        if let fileData = try? Data(contentsOf: url) {
                            let inspector = FalloutSaveInspector(data: fileData)
                            inspector.inspectFunction5()  // Inspect and print Function 5 data
                            inspector.inspectFunction6()  // Inspect and print Function 6 data
                        }

                    case .failure(let error):
                        fileReader.fileSize = "File selection failed: \(error.localizedDescription)"
                    }
                }
            )
        }
        .padding()
    }
}
