"Filed out from Dolphin Smalltalk"!

MethodWorkspace subclass: #SSWMethodWorkspace
	instanceVariableNames: ''
	classVariableNames: 'IndicatorStylesWithSpies'
	poolDictionaries: 'SmalltalkParseErrorCodes'
	classInstanceVariableNames: ''!
SSWMethodWorkspace guid: (GUID fromString: '{648bbbf3-5dc4-4b25-b2fd-61a1f6a8e190}')!
SSWMethodWorkspace comment: ''!
!SSWMethodWorkspace categoriesForClass!Unclassified! !
!SSWMethodWorkspace methodsFor!

autoParse

	super autoParse.

	self selectedMethod ifNotNil: 
		[ :method |
		(self isModified not and: [method isSpy]) ifTrue: [self highlightMethodSpies: 0 in: method]]!

canEditSpies

	^self isModified not and: [self isReadOnly not and: [self selectedMethod ifNil: [false] ifNotNil: [ :method | method isUnbound not]]]!

createSchematicWiring

	super createSchematicWiring.

	self methodSpyManager 
		when: #methodSpyChangedIn: send: #onMethodSpyChangedIn: to: self;
		when: #methodSpyChanged send: #onMethodSpyChanged to: self!

currentSpy

	| currentSpyNode |

	currentSpyNode := self spyInsertNode.
	currentSpyNode isNil ifTrue: [^nil].

	^self selectedMethod methodSpies detect: [ :each | each methodSourceInterval start = currentSpyNode start] ifNone: 
		[self selectedMethod methodSpies detect: 
			[ :each | each methodSourceInterval includes: currentSpyNode start] ifNone: [nil]]!

editSpy

	self editSpy: self highlightCurrentSpy!

editSpy: aMethodSpy

	| editor range rectangle style font|

	editor := InplaceTextEditor createOn: aMethodSpy spySource.
	editor validationBlock: 
		[ :spySource || oldSource |
		spySource trimBlanks isEmpty ifTrue: [^self removeSpy].
		oldSource := aMethodSpy spySource.
		aMethodSpy spySource: spySource.
		[self preserveSelectionDuring: [self methodSpyManager _compileSpy: aMethodSpy]. true] on: CompilerErrorNotification do: 
			[ :exc |
			aMethodSpy spySource: oldSource.
			exc return: false]].

	range := aMethodSpy methodSourceInterval.
	rectangle := self view boundingRectangleOfTextRange: range.
	editor textRectangle: rectangle.
	"Set the same font as the existing text so there is no visible 'jump'"
	style := self view styleAt: range start.
	font := self fontOfStyle: style.
	editor font: font.
	editor showModalWithoutAdjustment!

highlightCurrentSpy

	"Highlight the range of the current spy. Return the spy"

	^self currentSpy ifNotNil: 
		[ :spy | 
		self view selectionRange: spy methodSourceInterval.
		spy]!

highlightMethodSpies: anInteger in: method

	self view indicators: 
		(self view indicators 
			addAll:
				(method methodSpies collect: 
					[:each | 
					each scintillaIndicator: anInteger]);
			yourself)!

highlightSpyInsertPositionRange

	"Highlight and return the spy insert position range
	The highlighted range may be different (but equivalent) to the returned range 
	if auto-code formatting is in use"

	| methodParseTree highlightNode targetNode start source end range |

	methodParseTree := self unmodifiedParseTree.
	highlightNode := self spyInsertNodeIn: methodParseTree.
	highlightNode isNil ifTrue: [^nil].

	(self selectedMethod isSpy not and: [MethodBrowser autoFormat])
	ifTrue:
		[| normalParseTree |
		normalParseTree := self selectedMethod parseTree.
		targetNode := normalParseTree nodeAtIndex: (methodParseTree identityIndexOfNode: highlightNode).
		source := methodParseTree formattedCode]
	ifFalse:
		[targetNode := highlightNode.
		source := methodParseTree source].

	start := highlightNode start.
	end := source indexOfAnyOf: ':; ' startingAt: start.
	end = 0 ifTrue: [end := source size].

	range := start to: end.
	self view selectionRange: range.
	^targetNode start to: (targetNode start + (range size - 1))!

insertBreakpoint

	self insertSpy: SSWMethodSpy breakpoint!

insertConditionalBreakpoint

	self editSpy: 
		(SSWMethodSpy conditionalBreakpoint
			method: self selectedMethod;
			methodSourceInterval: self highlightSpyInsertPositionRange;
			yourself)!

insertOrEditSpy

	self highlightCurrentSpy
		ifNil: [self insertSpy]
		ifNotNil: [ :spy | self editSpy: spy]!

insertSpy

	"Create and insert a Method Spy, obtaining the code from an in-place editor"

	self editSpy:
		(SSWMethodSpy breakpoint
			method: self selectedMethod;
			methodSourceInterval: self highlightSpyInsertPositionRange;
			yourself)!

insertSpy: aMethodSpy

	(self querySpyCommandSymbol: #insertSpy) ifFalse: [Sound beep. ^self].

	self preserveSelectionDuring: 
		[self safeRecompile:
			[self selectedMethod beSpiedOnBy: 
				(aMethodSpy
					method: self selectedMethod;
					methodSourceInterval: self highlightSpyInsertPositionRange;
					yourself)]]!

insertSpyNamed: aSymbol

	self insertSpy: (SSWMethodSpy perform: aSymbol)!

inspectIt

	self highlightCurrentSpy
		ifNil: [super inspectIt]
		ifNotNil: [ :spy | spy inspect]!

inspectSpy

	self highlightCurrentSpy inspect!

isCurrentlyAtSpy

	^self selectedMethod notNil and: [self selectedMethod isSpy and: [self currentSpy notNil]]!

isSpyCommand: aSymbol

	^#(#toggleBreakpoint #insertSpySubmenu #insertSpy #insertOrEditSpy #insertSpyNamed: #inspectSpy #toggleSpyEnablement #resetSpy #removeSpy #removeAllSpies) includes: aSymbol!

isSpyEnabled

	^self currentSpy isLocallyEnabled!

methodSpyManager

	^SSWMethodSpyManager current!

onLeftButtonDoubleClicked: aMouseEvent

	^(self spyIndicatorIn: (self view indicatorsUnder: aMouseEvent position))
		ifNil: [super onLeftButtonDoubleClicked: aMouseEvent]
		ifNotNil: [ :spyIndicator | self editSpy: spyIndicator tag]!

onMethodSpyChanged

	self isModified not ifTrue: [self autoParse]!

onMethodSpyChangedIn: aCompiledMethod

	aCompiledMethod = self selectedMethod ifTrue: [self onMethodSpyChanged]!

onViewOpened

	super onViewOpened.

	self view contextMenu
		addSeparator;
		addItem: self spySubmenu!

preserveSelectionDuring: aBlock

	| oldRange |

	oldRange  := self selectionRange. 
	view noRedrawDo: [aBlock ensure: [self selectionRange: oldRange]]!

processAcceleratorKey: aString

	| keyCode |

	keyCode := AcceleratorTable keyCodeFromString: aString.

	(ScintillaView.DefaultKeyBindings detect: [ :each | each  acceleratorKey = keyCode] ifNone: [nil]) ifNotNil: [ :action | view perform: action commandSymbol]!

queryCommand: aCommandQuery

	| symbol |

	symbol := aCommandQuery commandSymbol.

	symbol == #methodSpies ifTrue:
		[aCommandQuery isEnabled: self canEditSpies.
		^true].

	(self isSpyCommand: symbol) ifTrue:
		[aCommandQuery isEnabled: (self querySpyCommandSymbol: symbol).
		aCommandQuery isEnabled ifTrue: 
			[symbol = #toggleBreakpoint ifTrue: [aCommandQuery isChecked: self selectedMethod hasBreakpoint].
			symbol = #toggleSpyEnablement ifTrue: [aCommandQuery isChecked: self isSpyEnabled]].
		^true].

	^super queryCommand: aCommandQuery!

querySpyCommandSymbol: aSymbol

	| isInsert |

	self canEditSpies ifFalse: [^false].

	aSymbol = #insertOrEditSpy ifTrue: [^true].
	aSymbol = #toggleBreakpoint ifTrue: [^self currentSpy ifNil: [true] ifNotNil: [ :spy | spy isBreakpoint]].
	aSymbol = #removeAllSpies ifTrue: [^self selectedMethod isSpy].

	isInsert := #(#insertSpySubmenu #insertSpy #insertSpyNamed: #insertConditionalBreakpoint) includes: aSymbol.

	^self isCurrentlyAtSpy
	ifTrue: 	
		[isInsert not]
	ifFalse:
		[isInsert
			ifTrue: [self spyInsertNode notNil]
			ifFalse: [false]]!

removeAllSpies

	self preserveSelectionDuring: [self selectedMethod removeAllSpies]!

removeAllSpiesShiftCtrlDelete

	(self canEditSpies and: [self selectedMethod isSpy])
		ifTrue: [self removeAllSpies]
		ifFalse: [self processAcceleratorKey: 'SHIFT+CTRL+DELETE']!

removeSpy

	self removeSpyIfNone: []!

removeSpyCtrlDelete

	self canEditSpies ifFalse: [^self processAcceleratorKey: 'CTRL+DELETE'].

	self removeSpyIfNone: [self processAcceleratorKey: 'CTRL+DELETE']!

removeSpyIfNone: aBlock

	self highlightCurrentSpy 
		ifNil: [aBlock value]
		ifNotNil: [ :spy | self preserveSelectionDuring: [spy removeFromMethod]]!

resetSpy

	self highlightCurrentSpy reset!

safeRecompile: aBlock

	"Private - Evaluate aBlock, trapping and notifying any compilation errors"

	[aBlock value] on: CompilerErrorNotification do:
		[ :exc |
		MessageBox warning: ('Failed to compile: ', exc description).
		exc return]!

selectedMethod

	"Occasional temporary process at: BoundsError when quickly toggling breakpoint in Debugger - retry once"

	^parentPresenter ifNotNil: 
		[:p | 
		[p selectedMethod] on: BoundsError do: 
			[ :exc | 
			"This seems to resolve things:"
			SessionManager inputState pumpMessages; processDeferredActions. 
			exc return: p selectedMethod]]!

spyIndicatorIn: aCollection

	^aCollection detect: [ :indicator |  ##(self) spyIndicatorStyles anySatisfy: [ :style | indicator styleName = style name]] ifNone: [nil]!

spyInsertNode

	^self spyInsertNodeIn: self unmodifiedParseTree!

spyInsertNodeIn: methodParseTree

	| targetPos targetNodes |

	targetPos := self selectionRange start.
	targetNodes := IdentitySet new.
	methodParseTree body nodesDo: [ :each | each isSpyable ifTrue: [targetNodes add: each statementNode]]. 

	^(targetNodes asSortedCollection: [ :n1 :n2 | n1 spySourceInterval size <= n2 spySourceInterval size])
		detect: [ :each | each spySourceInterval includes: targetPos] 
		ifNone: [methodParseTree firstSpyableNode]!

spySubmenu 

	| insertSubmenu |

	insertSubmenu := Menu description: 'Insert Spy...'.
	insertSubmenu name: #insertSpySubmenu.
	SSWMethodSpy convenienceSpyNames do: [ :each | insertSubmenu addCommand: (Message selector: #insertSpyNamed: argument: each) description: (SSWMethodSpy perform: each) description].
	insertSubmenu 
		addItem: (CommandMenuItem command: #insertConditionalBreakpoint description: 'Conditional Breakpoint');
		addItem: ((CommandMenuItem command: #insertSpy description: 'Other...') acceleratorKeyString: 'Ctrl+F9'; yourself).

	^Menu new
		description: 'Method Spies';
		addItem: ((CommandMenuItem command: #toggleBreakpoint description: 'Toggle Breakpoint') acceleratorKeyString: 'F9'; yourself);
		addItem: insertSubmenu;
		addCommand: #toggleSpyEnablement description: 'Enabled';
		addCommand: #editSpy description: 'Edit Spy';
		addCommand: #inspectSpy description: 'Inspect Spy';
		addCommand: #resetSpy description: 'Reset Spy';
		addItem: ((CommandMenuItem command: #removeSpy description: 'Remove Spy') acceleratorKeyString: 'Shift+F9'; yourself);
		addSeparator;
		addItem: ((CommandMenuItem command: #removeAllSpies description: 'Remove All Spies') acceleratorKeyString: 'Shift+Ctrl+F9'; yourself);
		yourself!

text: aString

	super text: aString.

	"So we don't have to wait"
	self selectedMethod ifNotNil: [ :meth | meth isSpy ifTrue: [self autoParse]]!

toggleBreakpoint

	self canEditSpies ifFalse: [^self].

	self isCurrentlyAtSpy
		ifTrue: [self removeSpy]
		ifFalse: [self insertBreakpoint]!

toggleOneTimeBreakpoint

	self canEditSpies ifFalse: [^self].

	self isCurrentlyAtSpy
		ifTrue: [self removeSpy]
		ifFalse: [self insertSpy: SSWMethodSpy oneTimeBreakpoint]!

toggleSpyEnablement

	self currentSpy toggleLocallyEnabled.
	self methodSpyManager spyChangedIn: self selectedMethod!

toggleSpyEnablementCtrlUp

	^(self canEditSpies and: [self isCurrentlyAtSpy])
		ifTrue: [self toggleSpyEnablement]
		ifFalse: [self processAcceleratorKey: 'CTRL+UP']!

unmodifiedParseTree

	^self selectedMethod parseTree! !
!SSWMethodWorkspace categoriesForMethods!
autoParse!helpers!private! !
canEditSpies!public!testing! !
createSchematicWiring!initializing!public! !
currentSpy!helpers:spies!public! !
editSpy!commands:spies!public! !
editSpy:!helpers!private! !
highlightCurrentSpy!helpers:spies!public! !
highlightMethodSpies:in:!helpers!private! !
highlightSpyInsertPositionRange!helpers:spies!public! !
insertBreakpoint!commands:spies!public! !
insertConditionalBreakpoint!commands:spies!public! !
insertOrEditSpy!commands:spies!public! !
insertSpy!commands:spies!public! !
insertSpy:!helpers!private! !
insertSpyNamed:!commands:spies!public! !
inspectIt!commands:spies!public! !
inspectSpy!commands:spies!public! !
isCurrentlyAtSpy!private!testing! !
isSpyCommand:!private!testing! !
isSpyEnabled!private!testing! !
methodSpyManager!accessing!private! !
onLeftButtonDoubleClicked:!event handling!public! !
onMethodSpyChanged!event handling!private! !
onMethodSpyChangedIn:!event handling!public! !
onViewOpened!event handling!public! !
preserveSelectionDuring:!helpers!private! !
processAcceleratorKey:!helpers!private! !
queryCommand:!commands:spies!public! !
querySpyCommandSymbol:!commands:spies!private! !
removeAllSpies!commands:spies!public! !
removeAllSpiesShiftCtrlDelete!commands:spies!public! !
removeSpy!commands:spies!public! !
removeSpyCtrlDelete!commands:spies!public! !
removeSpyIfNone:!helpers!private! !
resetSpy!commands:spies!public! !
safeRecompile:!helpers!private! !
selectedMethod!accessing!public! !
spyIndicatorIn:!helpers:spies!private! !
spyInsertNode!helpers:spies!private! !
spyInsertNodeIn:!helpers:spies!private! !
spySubmenu!accessing!public! !
text:!accessing!public! !
toggleBreakpoint!commands:spies!public! !
toggleOneTimeBreakpoint!commands:spies!public! !
toggleSpyEnablement!commands:spies!public! !
toggleSpyEnablementCtrlUp!commands:spies!public! !
unmodifiedParseTree!accessing!private! !
!

!SSWMethodWorkspace class methodsFor!

defaultKeyBindings

	^Dictionary new
		at: 'F9' put: #toggleBreakpoint;
		at: 'Ctrl+F9' put: #toggleOneTimeBreakpoint;
		at: 'Ctrl+Enter' put: #insertOrEditSpy;
		at: 'Ctrl+Up' put: #toggleSpyEnablementCtrlUp;
		at: 'Ctrl+Delete' put: #removeSpyCtrlDelete;
		at: 'Shift+Ctrl+Delete' put: #removeAllSpiesShiftCtrlDelete;
		yourself!

indicatorStyles

	^IndicatorStylesWithSpies ifNil: 
		[IndicatorStylesWithSpies := 
			super indicatorStyles copy
				addAll: self spyIndicatorStyles;
				yourself]!

initialize

	SmalltalkSystem current methodWorkspaceClass: self.

	self useDefaultKeyBindings!

legacyKeyBindings

	^Dictionary new
		at: 'F9' put: #toggleBreakpoint;
		at: 'Ctrl+F9' put: #insertSpy;
		at: 'Shift+F9' put: #removeSpy;
		at: 'Shift+Ctrl+F9' put: #removeAllSpies;
		yourself!

spyIndicatorStyles

	"IndicatorStylesWithSpies := nil"

	^{ 
		(ScintillaIndicatorStyle new name: #SpyEnabled; style: #roundBox; forecolor: Color red; hoverStyle: #straightBox; hoverForecolor: Color red; yourself).
		(ScintillaIndicatorStyle new name: #SpyDisabled; style: #roundBox; forecolor: Color blue ; hoverStyle: #straightBox; hoverForecolor: Color blue; yourself)
	}!

uninitialize

	SmalltalkSystem current methodWorkspaceClass: MethodWorkspace!

useDefaultKeyBindings

	self acceleratorKeyBindings: self defaultKeyBindings!

useLegacyKeyBindings

	self acceleratorKeyBindings: self legacyKeyBindings! !
!SSWMethodWorkspace class categoriesForMethods!
defaultKeyBindings!constants!public! !
indicatorStyles!public! !
initialize!class initialization!public! !
legacyKeyBindings!constants!public! !
spyIndicatorStyles!public! !
uninitialize!class initialization!public! !
useDefaultKeyBindings!class initialization!public! !
useLegacyKeyBindings!class initialization!public! !
!

