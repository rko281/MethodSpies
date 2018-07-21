"Filed out from Dolphin Smalltalk 7"!

Debugger subclass: #SSWDebugger
	instanceVariableNames: 'debugState'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWDebugger guid: (GUID fromString: '{9f0c6cc1-3da8-11d6-87e5-0010a70883e2}')!
SSWDebugger comment: ''!
!SSWDebugger categoriesForClass!Unclassified! !
!SSWDebugger methodsFor!

breakFrameOrMethod: aStackFrame

	self makeDebugFrame: aStackFrame.

	self breakWhen: [ :iFrame | (iFrame index <= aStackFrame index) or: [iFrame method = aStackFrame method]]!

createSchematicWiring

	super createSchematicWiring.

	self methodSpyManager 
		when: #methodSpiesCompiledIn: send: #onMethodSpiesCompiledIn: to: self!

debuggerToolbar

	^(self view viewNamed: 'debuggerTools' ifNone: [nil]) ifNotNil: [ :refView | refView presenterConnectionPoint]!

methodSpyManager

	^SSWMethodSpyManager current!

onMethodSpiesCompiledIn: aCompiledMethod

	"Check for a relevant change in spies and restart if necessary"

	self selectedMethod ifNotNil: 
		[ :method |
		"Only restart if the current method is affected"
		(method methodClass = aCompiledMethod methodClass and: [method selector = aCompiledMethod selector]) ifTrue: [self restartMethod]]!

onViewClosed

	"Unattach from the spy manager"

	self methodSpyManager removeEventsTriggeredFor: self.

	^super onViewClosed 
!

onViewOpened

	super onViewOpened.

	self debuggerToolbar ifNotNil: 
		[ :toolbar |
		toolbar addItem: 
			(ToolbarIconButton new
				commandDescription: 
					(CommandDescription new
						command: #stepThrough;
						description: 'Step into Block';
						image: self class stepThroughIcon;
						yourself);
				yourself) after: (toolbar itemWithCommand: #stepOver)]!

queryCommand: aCommandQuery

	| stepOver |

	(super queryCommand: aCommandQuery) ifTrue: [^true].

	(aCommandQuery commandSymbol == #stepThrough) ifTrue: 
		["Same rules as #stepOver"
		stepOver := CommandQuery commandDescription: (CommandDescription command: #stepOver) source: aCommandQuery source.
		self queryFrameCommand: stepOver.
		aCommandQuery isEnabled: stepOver isEnabled.
		^true].

	^false!

stepThrough

	| frame |

	self beRunning.
	self debugState: 'Step through'.
	frame := self frame.
	
	frame isBlockFrame
		ifTrue: [self breakFrameOrMethod: (self frames detect: [ :each | each ~~ frame and: [each method = frame method]])]
		ifFalse: [self breakFrameOrMethod: frame].

	self makeDebugFrame: frame sender.
	self resume! !
!SSWDebugger categoriesFor: #breakFrameOrMethod:!commands!private! !
!SSWDebugger categoriesFor: #createSchematicWiring!initializing!public! !
!SSWDebugger categoriesFor: #debuggerToolbar!accessing!private! !
!SSWDebugger categoriesFor: #methodSpyManager!accessing!public! !
!SSWDebugger categoriesFor: #onMethodSpiesCompiledIn:!event handling!public! !
!SSWDebugger categoriesFor: #onViewClosed!event handling!public! !
!SSWDebugger categoriesFor: #onViewOpened!event handling!public! !
!SSWDebugger categoriesFor: #queryCommand:!commands!private! !
!SSWDebugger categoriesFor: #stepThrough!commands!private! !

!SSWDebugger class methodsFor!

stepThroughIcon

	^InternalIcon fromBytes: #[0 0 1 0 1 0 16 16 0 0 1 0 32 0 104 4 0 0 22 0 0 0 40 0 0 0 16 0 0 0 32 0 0 0 1 0 32 0 0 0 0 0 64 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 39 39 39 2 39 39 39 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 38 38 38 2 0 0 0 0 0 0 0 0 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 18 18 18 20 6 6 6 212 6 6 6 212 6 6 6 212 6 6 6 212 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 6 6 6 212 6 6 6 212 6 6 6 212 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 43 43 43 47 43 43 43 47 0 0 0 0 0 0 0 0 40 40 40 5 45 45 45 7 0 0 0 0 0 0 0 0 43 43 43 47 43 43 43 47 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 0 0 0 0 0 0 0 0 0 0 0 0 29 29 29 13 28 28 28 116 46 46 46 112 52 52 52 21 0 0 0 0 0 0 0 0 0 0 0 0 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 0 0 0 0 0 0 0 0 29 29 29 15 23 23 23 137 2 2 2 246 9 9 9 235 45 45 45 128 52 52 52 23 0 0 0 0 0 0 0 0 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 0 0 0 0 30 30 30 7 17 17 17 128 2 2 2 244 0 0 0 254 0 0 0 253 8 8 8 230 39 39 39 103 41 41 41 7 0 0 0 0 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 0 0 0 0 30 30 30 3 14 14 14 37 13 13 13 66 4 4 4 216 19 19 19 190 31 31 31 64 26 26 26 27 35 35 35 1 0 0 0 0 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 0 0 0 0 0 0 0 0 0 0 0 0 12 12 12 20 5 5 5 207 25 25 25 175 48 48 48 18 0 0 0 0 0 0 0 0 0 0 0 0 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 23 23 23 169 43 43 43 47 43 43 43 47 0 0 0 0 13 13 13 20 5 5 5 207 25 25 25 175 48 48 48 18 0 0 0 0 43 43 43 47 43 43 43 47 23 23 23 169 6 6 6 212 18 18 18 20 18 18 18 20 6 6 6 212 6 6 6 212 6 6 6 212 6 6 6 212 0 0 0 0 14 14 14 20 5 5 5 207 25 25 25 175 49 49 49 18 0 0 0 0 6 6 6 212 6 6 6 212 6 6 6 212 6 6 6 212 18 18 18 20 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 0 0 0 0 18 18 18 20 5 5 5 207 25 25 25 175 49 49 49 18 0 0 0 0 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 50 50 50 28 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 18 18 18 20 5 5 5 207 25 25 25 175 49 49 49 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 23 23 23 1 46 46 46 16 50 50 50 28 50 50 50 29 49 49 49 29 43 43 43 47 6 6 6 212 25 25 25 175 49 49 49 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 20 20 20 19 13 13 13 175 13 13 13 215 14 14 14 216 14 14 14 216 12 12 12 219 3 3 3 246 23 23 23 169 44 44 44 15 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 17 17 17 10 8 8 8 98 10 10 10 121 10 10 10 121 10 10 10 121 10 10 10 121 10 10 10 121 22 22 22 67 33 33 33 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 207 251 0 0 7 224 0 0 7 224 0 0 6 96 0 0 28 56 0 0 24 24 0 0 16 8 0 0 16 8 0 0 28 56 0 0 4 32 0 0 4 32 0 0 4 32 0 0 252 63 0 0 128 63 0 0 128 63 0 0 128 63 0 0]! !
!SSWDebugger class categoriesFor: #stepThroughIcon!constants!private! !

