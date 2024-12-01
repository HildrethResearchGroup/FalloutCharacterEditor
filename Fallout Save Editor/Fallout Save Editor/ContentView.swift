import SwiftUI
import UniformTypeIdentifiers
import Observation

@Observable
class SaveData {
    // Header fields and their initial values
    var playerName = ""
    var saveGameName = ""
    var initialPlayerName = ""
    var initialSaveGameName = ""

    // Stats fields and their initial values
    var strengthBonus = 0
    var perceptionBonus = 0
    var enduranceBonus = 0
    var charismaBonus = 0
    var intelligenceBonus = 0
    var agilityBonus = 0
    var luckBonus = 0
    var initialStats: [String: Int] = [:] // Stores initial values for stats
}

struct ContentView: View {
    @State private var fileReader = FalloutSaveFile()
    @State private var isFileImporterPresented = false
    @State private var selectedTab = "Header" // State to track the selected tab
    
    @State private var saveData = SaveData()
    
    private var isFileLoaded: Bool {
        fileReader.header != nil
    }

    let datFileType = UTType(filenameExtension: "dat") ?? .data

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar for file upload functionality
            VStack(alignment: .leading, spacing: 15) {
                Text("File Upload")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 5) {
                    labeledRow(label: "Save Game Name", value: saveData.saveGameName.isEmpty ? "No File Selected" : saveData.saveGameName)
                    labeledRow(label: "File Size", value: fileReader.fileSize)
                }
                Spacer()

                Button("Select File") {
                    isFileImporterPresented.toggle()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: 200)
            .background(Color.gray.opacity(0.1))

            // Central pane with tabs and stats
            VStack(alignment: .center, spacing: 10) {
                Picker("", selection: $selectedTab) {
                    Text("Header").tag("Header")
                    Text("Stats").tag("Stats")
                    Text("Inventory").tag("Inventory")
                    Text("Skills/Perks").tag("Skills/Perks")
                }
                .pickerStyle(.segmented)
                .padding()

                Group {
                    if selectedTab == "Header" {
                        headerView
                    } else if selectedTab == "Stats" {
                        statsView
                    } else if selectedTab == "Inventory" {
                        comingSoonView(title: "Inventory")
                    } else if selectedTab == "Skills/Perks" {
                        comingSoonView(title: "Skills/Perks")
                    }
                }
                .frame(maxWidth: 600) // Limit width of central content
                .padding(.top, 10)

                Spacer()

                // Buttons
                HStack {
                    Spacer()
                    Button("Save") {
                        print("Saving current data...")
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Reset") {
                        resetCurrentTab()
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .padding(.top, 20)
            }
            .frame(maxWidth: 800) // Limit overall central view width
            .padding()
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [datFileType],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    fileReader.loadSaveFile(from: url)
                    if let header = fileReader.header {
                        // Populate initial values
                        saveData.playerName = header.playerName ?? ""
                        saveData.saveGameName = header.saveGameName ?? ""
                        saveData.initialPlayerName = saveData.playerName
                        saveData.initialSaveGameName = saveData.saveGameName

                        // Populate stats
                        saveData.strengthBonus = fileReader.strength
                        saveData.perceptionBonus = fileReader.perception
                        saveData.enduranceBonus = fileReader.endurance
                        saveData.charismaBonus = fileReader.charisma
                        saveData.intelligenceBonus = fileReader.intelligence
                        saveData.agilityBonus = fileReader.agility
                        saveData.luckBonus = fileReader.luck

                        saveData.initialStats = [
                            "Strength": saveData.strengthBonus,
                            "Perception": saveData.perceptionBonus,
                            "Endurance": saveData.enduranceBonus,
                            "Charisma": saveData.charismaBonus,
                            "Intelligence": saveData.intelligenceBonus,
                            "Agility": saveData.agilityBonus,
                            "Luck": saveData.luckBonus
                        ]

                        // Print to terminal
                        fileReader.printHeaderContents()
                        fileReader.printSpecialStats()
                    }
                case .failure(let error):
                    print("Error importing file: \(error.localizedDescription)")
                }
            }
        )
    }

    // Header View Content
    var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Header Information")
                .font(.headline)

            Group {
                labeledEditableRow(label: "Player Name", value: $saveData.playerName, isEditable: isFileLoaded)
                labeledEditableRow(label: "Save Game Name", value: $saveData.saveGameName, isEditable: isFileLoaded)
            }
            Spacer()
        }
        .padding()
    }

    // Stats View Content
    var statsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Character Stats")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                statRow(label: "Strength", value: $saveData.strengthBonus)
                statRow(label: "Perception", value: $saveData.perceptionBonus)
                statRow(label: "Endurance", value: $saveData.enduranceBonus)
                statRow(label: "Charisma", value: $saveData.charismaBonus)
                statRow(label: "Intelligence", value: $saveData.intelligenceBonus)
                statRow(label: "Agility", value: $saveData.agilityBonus)
                statRow(label: "Luck", value: $saveData.luckBonus)
            }
            Spacer()
        }
        .padding()
    }

    private func resetCurrentTab() {
        switch selectedTab {
        case "Header":
            saveData.playerName = saveData.initialPlayerName
            saveData.saveGameName = saveData.initialSaveGameName
        case "Stats":
            if let initial = saveData.initialStats["Strength"] { saveData.strengthBonus = initial }
            if let initial = saveData.initialStats["Perception"] { saveData.perceptionBonus = initial }
            if let initial = saveData.initialStats["Endurance"] { saveData.enduranceBonus = initial }
            if let initial = saveData.initialStats["Charisma"] { saveData.charismaBonus = initial }
            if let initial = saveData.initialStats["Intelligence"] { saveData.intelligenceBonus = initial }
            if let initial = saveData.initialStats["Agility"] { saveData.agilityBonus = initial }
            if let initial = saveData.initialStats["Luck"] { saveData.luckBonus = initial }
        default:
            break
        }
    }

    // Helper functions
    private func labeledEditableRow(label: String, value: Binding<String>, isEditable: Bool) -> some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            TextField("Enter \(label)", text: value)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 200)
                .disabled(!isEditable)
                .opacity(isEditable ? 1 : 0.5)
        }
    }

    private func labeledRow(label: String, value: String) -> some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body)
                .bold()
                .foregroundColor(.primary)
        }
    }

    private func statRow(label: String, value: Binding<Int>) -> some View {
        HStack {
            Text("\(label):")
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("0", value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 100)
        }
    }

    private func comingSoonView(title: String) -> some View {
        VStack {
            Text("\(title)")
                .font(.largeTitle)
                .bold()
            Text("Coming Soon!")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
