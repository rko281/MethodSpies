| folderName packageName tempFilename shell zipFile zipRepositoryFolder zipRepositoryItems destination |
folderName := 'MethodSpies'.
packageName := 'Method Spies'.
tempFilename := URLMonLibrary default urlDownloadToCacheFile: ('https://api.github.com/repos/rko281/<1s>/zipball/master' expandMacrosWith: folderName).
shell := IDispatch createObject: 'Shell.Application'.
zipFile := shell nameSpace: tempFilename.
zipRepositoryFolder := shell nameSpace: (File composePath: tempFilename subPath: (zipFile items item: 0) name).
zipRepositoryItems := zipRepositoryFolder items.
zipRepositoryItems filter: 16r20 pattern: folderName.
zipRepositoryFolder := (zipRepositoryItems item: 0) getFolder.
zipRepositoryItems := zipRepositoryFolder items.
destination := File fullPathOf: folderName relativeTo: SessionManager current imageBase.
File createDirectoryPath: destination.
(shell nameSpace: destination) copyHere: zipRepositoryItems vOptions: 4.
File delete: tempFilename.
Package manager install: (File composePath: destination subPath: packageName)!