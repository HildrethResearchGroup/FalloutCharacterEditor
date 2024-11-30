import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var fileReader = FalloutSaveFile()
    @State private var isFileImporterPresented = false
    @State private var selectedTab = "Header" // State to track the selected tab

    // Header fields and their initial values
    @State private var playerName = ""
    @State private var saveGameName = ""
    @State private var initialPlayerName = ""
    @State private var initialSaveGameName = ""

    // Stats fields and their initial values
    @State private var strengthBonus = 0
    @State private var perceptionBonus = 0
    @State private var enduranceBonus = 0
    @State private var charismaBonus = 0
    @State private var intelligenceBonus = 0
    @State private var agilityBonus = 0
    @State private var luckBonus = 0
    @State private var initialStats: [String: Int] = [:] // Stores initial values for stats

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
                    labeledRow(label: "Save Game Name", value: saveGameName.isEmpty ? "No File Selected" : saveGameName)
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
                        playerName = header.playerName ?? ""
                        saveGameName = header.saveGameName ?? ""
                        initialPlayerName = playerName
                        initialSaveGameName = saveGameName

                        // Populate stats
                        strengthBonus = fileReader.strength
                        perceptionBonus = fileReader.perception
                        enduranceBonus = fileReader.endurance
                        charismaBonus = fileReader.charisma
                        intelligenceBonus = fileReader.intelligence
                        agilityBonus = fileReader.agility
                        luckBonus = fileReader.luck

                        initialStats = [
                            "Strength": strengthBonus,
                            "Perception": perceptionBonus,
                            "Endurance": enduranceBonus,
                            "Charisma": charismaBonus,
                            "Intelligence": intelligenceBonus,
                            "Agility": agilityBonus,
                            "Luck": luckBonus
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
                labeledEditableRow(label: "Player Name", value: $playerName, isEditable: isFileLoaded)
                labeledEditableRow(label: "Save Game Name", value: $saveGameName, isEditable: isFileLoaded)
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
                statRow(label: "Strength", value: $strengthBonus)
                statRow(label: "Perception", value: $perceptionBonus)
                statRow(label: "Endurance", value: $enduranceBonus)
                statRow(label: "Charisma", value: $charismaBonus)
                statRow(label: "Intelligence", value: $intelligenceBonus)
                statRow(label: "Agility", value: $agilityBonus)
                statRow(label: "Luck", value: $luckBonus)
            }
            Spacer()
        }
        .padding()
    }

    private func resetCurrentTab() {
        switch selectedTab {
        case "Header":
            playerName = initialPlayerName
            saveGameName = initialSaveGameName
        case "Stats":
            if let initial = initialStats["Strength"] { strengthBonus = initial }
            if let initial = initialStats["Perception"] { perceptionBonus = initial }
            if let initial = initialStats["Endurance"] { enduranceBonus = initial }
            if let initial = initialStats["Charisma"] { charismaBonus = initial }
            if let initial = initialStats["Intelligence"] { intelligenceBonus = initial }
            if let initial = initialStats["Agility"] { agilityBonus = initial }
            if let initial = initialStats["Luck"] { luckBonus = initial }
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
