"Filed out from Dolphin Smalltalk 7"!

MethodWorkspace subclass: #SSWMethodWorkspace
	instanceVariableNames: 'lastPlainText unmodifiedParseTree'
	classVariableNames: 'IndicatorStylesWithSpies'
	poolDictionaries: 'SmalltalkParseErrorCodes'
	classInstanceVariableNames: ''!
SSWMethodWorkspace guid: (GUID fromString: '{648bbbf3-5dc4-4b25-b2fd-61a1f6a8e190}')!
SSWMethodWorkspace comment: ''!
!SSWMethodWorkspace categoriesForClass!Unclassified! !
!SSWMethodWorkspace methodsFor!

additionalAccelerators

	^OrderedCollection new
		add: #(#toggleBreakpoint 'F9');
		add: #(#insertSpy 'Ctrl+F9');
		add: #(#removeSpy 'Shift+F9');
		add: #(#removeAllSpies 'Shift+Ctrl+F9');
		yourself!

autoParse
	| method |

	super autoParse.

	method := self selectedMethod.

	(method notNil and: [self isModified not and: [method isSpy]]) ifTrue: [self highlightMethodSpies: 0 in: method]!

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

highlightCurrentSpy

	"Highlight the range of the current spy. Return the spy"

	| spy |

	spy := self currentSpy.

	self view selectionRange: spy methodSourceInterval.

	^spy!

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

	"Create and insert a conditional breakpoint, obtaining the code from a dialog"

	| positionRange condition |

	positionRange := self highlightSpyInsertPositionRange.

	condition := Prompter on: '' asValue prompt: 'Enter Condition' caption: 'Insert Conditional Breakpoint'.
	(condition isNil or: [condition isEmpty]) ifFalse:
		[self methodSpyManager compileSpy:
			(SSWMethodSpy new 
				method: self selectedMethod;
				description: 'Conditional Breakpoint';
				spySource: ('thisSpy breakIf: (<1s>)' expandMacrosWith: condition);
				methodSourceInterval: positionRange;
				yourself)]!

insertSpy

	"Create and insert a Method Spy, obtaining the code from a dialog"

	| positionRange spySource |

	positionRange := self highlightSpyInsertPositionRange.

	spySource := Prompter on: 'self halt.' asValue prompt: 'Enter Spy code' caption: 'Insert Spy'.
	(spySource isNil or: [spySource isEmpty]) ifFalse:
		[self methodSpyManager compileSpy:
			(SSWMethodSpy new 
				method: self selectedMethod;
				spySource: spySource; 
				methodSourceInterval: positionRange;
				yourself)]!

insertSpy: aMethodSpy

	| oldRange positionRange |

	(self querySpyCommandSymbol: #insertSpy) ifFalse: [Sound beep. ^self].

	oldRange  := self selectionRange. 
	positionRange := self highlightSpyInsertPositionRange.

	self safeRecompile:
		[self selectedMethod beSpiedOnBy: 
			(aMethodSpy
				method: self selectedMethod;
				methodSourceInterval: positionRange;
				yourself)].

	self selectionRange: oldRange !

insertSpyNamed: aSymbol

	self insertSpy: (SSWMethodSpy perform: aSymbol)!

inspectSpy

	self highlightCurrentSpy inspect!

isCurrentlyAtSpy

	^self selectedMethod notNil and: [self selectedMethod isSpy and: [self currentSpy notNil]]!

isSpyCommand: aSymbol

	^#(#toggleBreakpoint #insertSpySubmenu insertSpy #insertSpyNamed: #inspectSpy #toggleSpyEnablement #resetSpy #removeSpy #removeAllSpies) includes: aSymbol!

isSpyEnabled

	^self currentSpy isLocallyEnabled!

methodSpyManager

	^SSWMethodSpyManager current!

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
	aBlock ensure: [self selectionRange: oldRange]!

queryCommand: aCommandQuery

	| symbol |

	symbol := aCommandQuery commandSymbol.

	symbol == #methodSpies ifTrue:
		[aCommandQuery isEnabled: (self view isModified not and: [self view isReadOnly not]).
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

	(self isModified or: [self selectedMethod isNil or: [self selectedMethod isUnbound]]) ifTrue: [^false].

	aSymbol = #toggleBreakpoint ifTrue: [^self currentSpy ifNil: [true] ifNotNil: [ :spy | spy isBreakpoint]].
	aSymbol = #removeAllSpies ifTrue: [^self selectedMethod isSpy].

	isInsert := #(#insertSpySubmenu #insertSpy #insertSpyNamed: #insertConditionalBreakpoint) includes: aSymbol.

	^self isCurrentlyAtSpy
	ifTrue: 	
		[isInsert not]
	ifFalse:
		[isInsert
			ifTrue: [self selectedMethod notNil and: [self spyInsertNode notNil]]
			ifFalse: [false]]!

removeAllSpies

	self selectedMethod removeAllSpies!

removeSpy

	self preserveSelectionDuring: 
		[self highlightCurrentSpy.
		self currentSpy removeFromMethod]!

resetSpy

	self highlightCurrentSpy reset!

safeRecompile: aBlock

	"Private - Evaluate aBlock, trapping and notifying any compilation errors"

	[aBlock value] on: CompilerErrorNotification do:
		[ :exc |
		MessageBox warning: ('Failed to compile: ', exc description).
		exc return]!

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

	self isCurrentlyAtSpy
		ifTrue: [self removeSpy]
		ifFalse: [self insertBreakpoint]!

toggleSpyEnablement

	self currentSpy toggleLocallyEnabled.
	self methodSpyManager spyChangedIn: self selectedMethod!

unmodifiedParseTree

	^self selectedMethod parseTree! !
!SSWMethodWorkspace categoriesFor: #additionalAccelerators!accessing!private! !
!SSWMethodWorkspace categoriesFor: #autoParse!helpers!private! !
!SSWMethodWorkspace categoriesFor: #createSchematicWiring!initializing!public! !
!SSWMethodWorkspace categoriesFor: #currentSpy!helpers:spies!public! !
!SSWMethodWorkspace categoriesFor: #highlightCurrentSpy!helpers:spies!public! !
!SSWMethodWorkspace categoriesFor: #highlightMethodSpies:in:!helpers!private! !
!SSWMethodWorkspace categoriesFor: #highlightSpyInsertPositionRange!helpers:spies!public! !
!SSWMethodWorkspace categoriesFor: #insertBreakpoint!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #insertConditionalBreakpoint!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #insertSpy!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #insertSpy:!commands:spies!private! !
!SSWMethodWorkspace categoriesFor: #insertSpyNamed:!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #inspectSpy!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #isCurrentlyAtSpy!private!testing! !
!SSWMethodWorkspace categoriesFor: #isSpyCommand:!commands:spies!private! !
!SSWMethodWorkspace categoriesFor: #isSpyEnabled!private!testing! !
!SSWMethodWorkspace categoriesFor: #methodSpyManager!accessing!private! !
!SSWMethodWorkspace categoriesFor: #onMethodSpyChanged!event handling!private! !
!SSWMethodWorkspace categoriesFor: #onMethodSpyChangedIn:!event handling!public! !
!SSWMethodWorkspace categoriesFor: #onViewOpened!event handling!public! !
!SSWMethodWorkspace categoriesFor: #preserveSelectionDuring:!helpers!private! !
!SSWMethodWorkspace categoriesFor: #queryCommand:!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #querySpyCommandSymbol:!commands:spies!private! !
!SSWMethodWorkspace categoriesFor: #removeAllSpies!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #removeSpy!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #resetSpy!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #safeRecompile:!helpers!private! !
!SSWMethodWorkspace categoriesFor: #spyInsertNode!helpers:spies!private! !
!SSWMethodWorkspace categoriesFor: #spyInsertNodeIn:!helpers:spies!private! !
!SSWMethodWorkspace categoriesFor: #spySubmenu!accessing!public! !
!SSWMethodWorkspace categoriesFor: #text:!accessing!public! !
!SSWMethodWorkspace categoriesFor: #toggleBreakpoint!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #toggleSpyEnablement!commands:spies!public! !
!SSWMethodWorkspace categoriesFor: #unmodifiedParseTree!accessing!private! !

!SSWMethodWorkspace class methodsFor!

indicatorStyles

	^IndicatorStylesWithSpies ifNil: 
		[IndicatorStylesWithSpies := 
			super indicatorStyles copy
				addAll: self spyIndicatorStyles;
				yourself]!

spyIndicatorStyles

	^OrderedCollection new
		add: (ScintillaIndicatorStyle new name: #SpyEnabled; style: #roundBox; forecolor: Color red; hoverStyle: #straightBox; hoverForecolor: Color red; yourself);
		add: (ScintillaIndicatorStyle new name: #SpyDisabled; style: #roundBox; forecolor: Color darkGray; hoverStyle: #straightBox; hoverForecolor: Color darkGray; yourself);
		yourself! !
!SSWMethodWorkspace class categoriesFor: #indicatorStyles!public! !
!SSWMethodWorkspace class categoriesFor: #spyIndicatorStyles!public! !

