import SwiftUI
import UniformTypeIdentifiers
import Observation
import Combine

@Observable
class SaveData {
    // Header fields and their initial values
    var playerName = ""
    var saveGameName = ""
    var initialPlayerName = ""
    var initialSaveGameName = ""

    // Stats fields and their initial values
    var strengthBonus : Int = 0
    var perceptionBonus : Int = 0
    var enduranceBonus : Int = 0
    var charismaBonus : Int = 0
    var intelligenceBonus : Int = 0
    var agilityBonus : Int = 0
    var luckBonus: Int = 0
    var initialStats: [String: Int] = [:] // Stores initial values for stats
    
    // Additional Player stats
    var armourClass : Int = 0
    var carryWeight : Int = 0
    var playerLevel : Int = 0
    var playerHealth : Int = 0
    
    // Variables for input
    var inputVar : Int = 0
}

// Class to be expanded on for game perk tree
@Observable
class PerkStates {
    var isHovering = false
    var hoverLocation: CGPoint = .zero
    var showInformationActionBoy = false
    var actionBoyisOn = false
}

// Class to be expanded on for game traits
@Observable
class TraitStates {
    var isHovering = false
    var hoverLocation: CGPoint = .zero
    var showInformationTrait = false
    var TraitisOn = false
}

struct ContentView: View {
    @State private var fileReader = FalloutSaveFile()
    @State private var isFileImporterPresented = false
    @State private var selectedTab = "Header" // State to track the selected tab
    
    @State private var saveData = SaveData()
    @State private var perksVar = PerkStates()
    @State private var traitsVar = TraitStates()
    
    @State private var errorPresent = false
    
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
                    Text("Inventory").tag("Inventory")
                }
                .pickerStyle(.segmented)
                .padding()

                Group {
                    if selectedTab == "Header" {
                        HStack{
                            VStack{
                                headerView
                                perksListView
                                perksInfoView
                                traitsListView
                                traitsInfoView
                            }//.frame(width: 250)
                            VStack{
                                statsView
                                if errorPresent{
                                    Text("Error Present: Unable to Save File Changes.").bold()
                                }
                            }//.frame(width: 350, height: 700)
                         }
                    } else if selectedTab == "Inventory" {
                        comingSoonView(title: "Inventory")
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
                    // save button is disabled with any invalid input entered
                    .disabled(errorPresent)
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
            Form{
                HStack{
                    statRow(label: "Strength", value: $saveData.strengthBonus)
                }
                HStack{
                    statRow(label: "Perception", value: $saveData.perceptionBonus)
                }
                HStack{
                    statRow(label: "Endurance", value: $saveData.enduranceBonus)
                }
                HStack{
                    statRow(label: "Charisma", value: $saveData.charismaBonus)
                }
                HStack{
                    statRow(label: "Intelligence", value: $saveData.intelligenceBonus)
                }
                HStack{
                    statRow(label: "Agility", value: $saveData.agilityBonus)
                }
                HStack{
                    statRow(label: "Luck", value: $saveData.luckBonus)
                }
                HStack{
                    statRow(label: "Armour Class", value: $saveData.armourClass)
                }
                HStack{
                    statRow(label: "Carry Weight", value: $saveData.carryWeight)
                }
                HStack{
                    statRow(label: "Level", value: $saveData.playerLevel)
                }
                HStack{
                    statRow(label: "Health", value: $saveData.playerHealth)
                }
                /*
                 The below strength stat is a sort of test stack to show
                 another way it appears user input could be taken. However,
                 this solution appears redundant with code so writing a
                 function similar to statRow that handles value
                 slightly different might be a good direction.
                 */
                HStack{
                    Text("Strength II: \(saveData.strengthBonus + saveData.inputVar)")
                    TextField("", value: $saveData.inputVar, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
            }.formStyle(.grouped)
            Spacer()
        }
        .padding()
    }
    
    // view to display list of game perks
    var perksListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Perks")
                .font(.headline)
            Form{
                VStack{
                    Toggle(isOn : $perksVar.actionBoyisOn){
                        Text("Action Boy")
                    }.toggleStyle(.checkbox)
                }
            }.onContinuousHover{ phase in
                switch phase {
                case .active(let location):
                    perksVar.hoverLocation = location
                    perksVar.isHovering = true
                    perksVar.showInformationActionBoy = true
                case .ended:
                    perksVar.isHovering = false
                    perksVar.showInformationActionBoy = false
                }
            }
        }
    }
    
    // View to display description of game perks
    var perksInfoView: some View {
        Form{
            VStack{
                if perksVar.showInformationActionBoy {
                    Text("Additional Action Point Available in Combat")
                }
            }.frame(width: 150, height: 85)
        }
    }
    
    // view to display list of game perks
    var traitsListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Traits")
                .font(.headline)
            Form{
                VStack{
                    Toggle(isOn : $traitsVar.TraitisOn){
                        Text("Bloody Mess")
                    }.toggleStyle(.checkbox)
                }
            }.onContinuousHover{ phase in
                switch phase {
                case .active(let location):
                    traitsVar.hoverLocation = location
                    traitsVar.isHovering = true
                    traitsVar.showInformationTrait = true
                case .ended:
                    traitsVar.isHovering = false
                    traitsVar.showInformationTrait = false
                }
            }
        }
    }
    
    // View to display description of game perks
    var traitsInfoView: some View {
        Form{
            VStack{
                if traitsVar.showInformationTrait {
                    Text("More Violent Death Annimations. No Penalty.")
                }
            }.frame(width: 150, height: 85)
        }
    }

    // Function that resets any changes made to SPECIAL STATS
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

    //Function populates rows of stats
    // Future imporvements: error handling for user input and correctly handling bonuses
    private func statRow(label: String, value: Binding<Int>) -> some View {
            HStack {
                Text("\(label):")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                /*
                 This function is great for populating the entire stats table without
                 redundant code; however, it has caused some difficulties regarding
                 each character stat needing to be indivdually changed based on
                 user input. Either creating more functions to handle
                 parts of that separately or another solution will need to be
                 found so that not every textfield is changed.
                 
                 TextField("\(value.wrappedValue + saveData.inputVar)" , value: $saveData.inputVar, format: .number)
                     .onChange(of : value.wrappedValue) {
                         // If value is negative or very large
                         if (value.wrappedValue<0 || value.wrappedValue>100) {
                             errorPresent = true
                         }
                         else {
                             errorPresent = false
                             saveData.inputVar = 0
                         }
                     }
                 */
                
                
                // This version of this function does not change every textfield for the user changing it
                // which is nice, however, it does not add to the initial character stat
                TextField("\(value.wrappedValue + 0)" , value: value, format: .number)
                    .onChange(of : value.wrappedValue) {
                        // If value is negative or very large
                        if (value.wrappedValue<0 || value.wrappedValue>100) {
                            errorPresent = true
                        }
                        else {
                            errorPresent = false
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 100)
                    .fixedSize()
            }
    }
    
    // function to return proper initial stat for when user changes a stat
    // Could be expanded on for rest of stats or values could be passed more efficiently if needed
    private func retrieveStat(label: String) -> Int{
        if label=="Strength"{
            return saveData.strengthBonus
        }
        else if label=="Perception"{
            return saveData.perceptionBonus
        }
        else{
            return 0
        }
    }

    // Placeholder to TODO functionality
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
