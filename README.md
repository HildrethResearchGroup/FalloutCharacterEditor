# FalloutCharacterEditor Docs
This document is intended to describe the current status of the MacOS Fallout 1 & 2 Character Save editor Field Session Fall 2024 project. It will describe what is working, what's not working, future implementation suggestions, and provide helpful resources.
## Background
* This tool is intended to be a save file editor for the Fallout 1 and Fallout 2 video games.
* It was being developed for Dr. Hildreth at Colorado School of Mines during the Fall 2024 Computer Science course "Advanced Software Engineering," colloquially known as "Field Session".
	* The developers on this project during this time were: Thomas Coats, Kyle Collins, Hannah Clark, and Jaeden Hillesheim
* What does it do?
	* The tool is intended to allow a user to select a save file from either Fallout 1 or Fallout 2 and provide an easy-to-use interface for manipulating the contents of said save file.
	* Functionally, it should allow the user to select one of their saves, parse that save into a Swift data class, present it to the user through a GUI, allow the user to manipulate the info via the GUI, then repack that new info into a proper save file so the user's manipulations are reflected in the game.
* The most important thing to understand for this project is the format of the Fallout 1 & 2 `SAVE.DAT` file
	* This is a binary encoded file that contains all of the information needed for the game to keep track of the state of a player's playthrough.
	* There way the game creates this file is by encoding the contents of the playthrough's state into the `SAVE.DAT` file via a series of functions.
		* Each of these functions controls the encoding of a different aspect of the game's state.
		* For this project, the Header, Function 5, and Function 6 are the most important.
			* Respectively, these control the character and save's names, the player's location and other player logistics info, and the player's stats.
	* For more information about the `SAVE.DAT` file format breakdown, see the resources section.
* Variable naming across all files should act as self-commenting code, however, some additional contents are included to help.
## Repo/File Breakdown
#### Branches
* There are two branches: Main and Temp. 
* The main branch is where a majority of the time was spent during development. It includes the groundwork for most of the project's functionality. The most featured version of the GUI exists here.
	* There is a lot of code here that was used to figure out how to properly go about the parsing of the save file.
	* Additionally, there is also code present for the first version of the GUI.
* The temp branch was used near the end of the project to test a version of the GUI which incorporated File I/O.
	* The GUI in this branch accepts a file and parses the header and the start of function 5, up to the inventory, and a portion of function 6.
	* To that point, it is the most functional version of the project.
#### Files
* All project code exists in the `Fallout Save Editor` directory
* `Fallout Save Editor`
	* `/Fallout Save Editor.xcodeproj`
		* This file contains all of the workspace information Xcode needs
		* Select this file when loading a project in Xcode and the project should be loaded properly.
	* `/Fallout Save Editor`
		* This directory is where all of the actual functional code is.
		* `/SaveFileComponents`
			* The intent behind this directory was to hold all of the different swift classes needed to hold the data for the different parts of the `SAVE.DAT` file after parsing.
			* Currently, it contains a class that parses all of the `header` information.
		* `/ContentView.swift`
			* This should be the main entry point for the GUI.
			* On the `temp` branch, it contains the most functional version of the GUI, including the ability to import a save file and manipulate stats.
				* It also contains an example of how to use the modern `@Obervable` macro which easily connects data classes (AKA view models) to GUIs which manipulate that data (AKA model views).
				* Exporting functionality was not implemented yet.
				* Additional to-be-implemented blocks of code are included to make extension of this project easier.
			* On the `main` branch, it contains a version of the GUI with the most features.
		* `/FalloutSaveFile.swift`
			* This file contains a class which is meant to hold all of the relevant information needed for manipulating the save file.
			* It also contains functions relevant for parsing the `SAVE.DAT` save file and should also contain functions for repacking back into the proper format.
			* It incorporates the `SaveFileComponents/FalloutSaveFileHeader` class, but otherwise has a majority of the fields hard coded.
				* Work needs to be done in this file to break up these hard-coded fields for better modularity.
		* `/FalloutSaveInspector.swift`
			* This file contains a class which contains helper function for parsing the `SAVE.DAT` file format.
			* It was primarily used to inspect how the format actually worked to figure out how we could properly parse it.
		* `/Fallout-Save_EditorApp.swift`
			* This file controls the launching of the GUI.
			* It calls on `ContentView.swift` to present the GUI, and adds additional functionality to the GUI in the form of keyboard shortcuts.
			* Needs more work for proper functionality of keyboard shortcuts and other usability commands.
		* Other files present are artifacts of Xcode or the MacOS file system.
	* `Fallout Save EditorTests`
		* This directory contains all of the test code for the backend, data handling portion of the project.
	* `Fallout Save EditorUITests`
		* This directory contains all of the test code for the frontend, UI portion of the project.
## What is working?
At the time of writing this, the most functional version of the project is present in the `temp` branch.

* File input
	* At it's current stage, the GUI in `ContentView.swift` has a field (`.fileImporter`) which allows the user to select a file to load into the application.
	* This file is not currently checked for correctness.
* GUI interactions
	* The user is able to click on the different tabs present in the GUI to navigate to the different data fields.
	* Data fields can be edited.
* Altering header data
	* In the GUI, whenever the header contents are edited, those edits are reflected on the file import bar.
## What is not working?
This section contains a list of several aspects of the project which we weren't able to fully implement throughout the duration of this project, but that should be included for proper functionality.

* Parsing past function 5's inventory list
	* Function 5 ends with a variable-sized list of every item in the player's inventory.
	* These items follow another specific format which contains information about the item, and which *should* be 64-bytes.
	* During our time on this project, we were not able to reliably parse this list, but we believe that there may be a way to recursively traverse this list by looking at the `is_container` field of each item to decide how many items are in the player's containers.
	* Since function 6 immediately follows function 5, it should be easy to target function 6 once the inventory list has been figured out.
* Writing the save file out
	* In theory, the process of repacking the save file after all the data has been conveniently collected into a class should be easy.
	* Assuming data types are properly handled, the Swift `Pack` package should help make this process easy.
* Testing
	* A majority of the time spent during this project was on figuring out how to parse the save file, and as such, no tests were actually implemented.
	* That said, there are two directories, `Fallout Save EditorTests` and `Fallout Save EditorUITests`, that contain some starter code to working the the swift `XCTest` testing framework package.
	* These can be expanded on to implement a proper testing framework, or they can be scrapped for a different testing framework.
		* We believe that the `XCTest` framework is the easiest way to go about testing Xcode projects as it integrates directly with Xcode's testing workflow 
		* For more information about `XCTest`, start here: [Apple Official XCTest Documentation](https://developer.apple.com/documentation/xctest)
## What's next?
* Figure out how to properly parse function 5
	* Properly parsing function 5 would allow for a full list of all items in the player's inventory.
	* Additionally, it should allow for much easier targeting of function 6.
* Figure out how to properly parse function 6
	* This function contains the player's base S.P.E.C.I.A.L. stats which are important to the save editor's functionality.
	* Function 6 utilizes another sub-format, the "PRO" file format.
		* Consider making a method that parses this file format which could be utilized for parsing other potentially relevant fallout files in the future.
* Figure out binary repacking
	* The Swift `Pack` package allows for relatively easy parsing and packing of binary files and should be utilized to repack any parsed and edited save file contents back into the `SAVE.DAT` file format.
	* Since the `SAVE.DAT` file format has specific sizes for each data field, proper data types should be utilized to make repacking more convenient.
		* During parsing, these type may be converted to Swift data types for ease of use, but be aware that they will need to be cast into the correct types when repacking.
* Proper testing
	* Implementing a properly functional testing framework allows for good AGILE development practice.
		* A test can be designed for a new feature before it's even implemented to get an idea of what the functionality of the feature should be.
	* Proper testing ensures some level of functionality and edge case consideration before any real user ever gets their hands on the finished project.
* Modularize the codebase
	* In its current state, there is very minimal modularity.
	* Ideally, the codebase is refactored to make it so different aspects are easily distinguishable from one another.
		* This could look like making all `SAVE.DAT` functions have their own class file so it's more apparent what the shape of their data is.
		* Modularization to this degree makes it much easier to digest the codebase should another developer want to work on it.
	* Another idea to improve legibility of the parsing was to have a hashmap that stored all the required offsets so they were easily accessible.
* Any other extensions
	* Parsing other fields that other users may find useful.
	* Adding a hex view so advanced users can directly see how their manipulations will be reflected in the final save file.
## Resources
* This project was developed using the Xcode IDE found in the MacOS App Store.
* The Swift `Pack` package was very helpful in parsing the save file: [Pack](https://swiftpackageindex.com/mattcox/Pack).
* The [Vault-Tec Labs Modding Wiki](https://falloutmods.fandom.com/wiki/Main_Page) has been immensely helpful for the development of this application.
	* Especially the page on the [SAVE.DAT File Format](https://falloutmods.fandom.com/wiki/SAVE.DAT_File_Format)
* There are several open-source save editors we referenced to help clarify some procedures needed for our application:
	* https://github.com/nousrnam/F12se
	* https://github.com/efossvold/fallout2-save-editor
	* https://github.com/freesalu/fallout-2-editor
* The Fallout 2 community edition can be found here: https://github.com/alexbatalov/fallout2-ce
	* Read the included README for installation instructions.
