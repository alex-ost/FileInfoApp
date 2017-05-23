# FileInfoApp
FileInfoApp - its an OS X application, implemented as example how can be created, installed and used by XPC HelperTool for main UI application.
In other words, it's daemon based application example, when all calculations and heavy tasks working in daemon and UI application works without any freezes, crashes, etc.

[![Platform](https://img.shields.io/badge/Platform-OS%20X-lightgrey.svg)]

## Conditions for run:
It's condition from apple - App and HelperTool should be signed.
1)   Build (not run!) FileInfoApp target - app (product) needed for step #2.1
2)	 Sign: Select your team and check your MacOS Developer certificate it should be downloaded and valid.
2.1) Sign: Use example #2 from "SMJobBlessUtil.txt" for code sign fixing.
3)   Clean and Run.

Why it needed?
Project will be buildable anyway, but our app won't connected to HelperTool, because codeSign conditions won't incorrect.

## Description
### Workspace:
This app is example how can be orginized and implemented HelperTool for OS X app.
FileInfoApp.xcworkspace contains 2 main projects:
1) FileInfoApp.xcodeproj - main OS X application.
2) FileProcessorTool.xcodeproj - HelperTool.

Folder “Utils” which contains:
1) Unistall.sh - script to remove everything installed by the sample.
2) SMJobBlessUtil.py - tool for checking and correcting apps that use SMJobBless.
3) SMJobBlessUtil.txt - example how to use codeSign check and how to fix codeSign.

Folder “Docs” which contains:
1) ABOUT.txt - main info about project.
2) README.txt - contains instruction for re-use.

### Dependecies:
FileProcessorTool projects contains 2 targets:
- FileProcessorInterface - it’s framework which shares Interface for remote object which will be obtained from XPC connection, also it shares name of helperTool by which main app will be connected to HelperTool.
- FileProcessorTool - directly HelperTool.

Both those targets included to FileInfoApp.

### Usability / Logic:
- Files cab be added by “+” button.
- All files will be saved in Database.
- Each file has some properties, which can be calculated by filePath, and properties which can’t, for example, hash and size. For properties which should be calculated will be used HelperTool.
- Also app contains actions with files. “Remove from DB” and “Remove from Disk”, for first action, file will be removed from database, but for second it will be removed from disk and from database too. For action “Remove from Disk”, will be used HelperTool.

### HelperTool installing:
- HelperTool will be installed on demand - when user select calculating some property.
Installing operation contains next stages:
- Get Authorization for our HelperTool - on this step user should enter his password.
- Using this Authorization and SMJobBless - install and run our HelperTool.
- Connect to HelperTool by XPC service.

For uninstall use “Uninstall.sh” script.

### Conditions for application re-use:
If you want to re-use some code (keep mind the License), here is steps what are you have to change for full app-reuse.
1)	 ID: Change "com.alexost.fileinfoapp.FileProcessorTool" in all files to you HelperTool name:
	- FPToolDefines.m
	- FileProcessorTool-Info.plist
	- FileProcessorTool-Launchd.plist
	- Uninstall.sh
	- README.txt
	- Info.plist (FileInfoApp)
	- FileProcessorTool.xcodeproj -> bundle identifier.
1.1) Optional: Change Product Names.
// Re-sign the app.
2)   Build (not run!) FileInfoApp target - app (product) needed for step #3.1
3)	 Sign: Select your team and check your MacOS Developer certificate it should be downloaded and valid.
3.1) Sign: User example #2 from "SMJobBlessUtil.txt" for code sign fixing.
4)   Clean and Run.

### One more thing.
Project was created using Xcode 8.2 - so storyboard won't compiled and also opened by Xcode with less version.
