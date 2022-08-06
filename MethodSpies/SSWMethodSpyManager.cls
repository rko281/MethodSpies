"Filed out from Dolphin Smalltalk"!

Model subclass: #SSWMethodSpyManager
	instanceVariableNames: 'areSpiesEnabled'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'current'!
SSWMethodSpyManager guid: (GUID fromString: '{72e11082-3f59-11d6-87e5-0010a70883e2}')!
SSWMethodSpyManager comment: ''!
!SSWMethodSpyManager categoriesForClass!Unclassified! !
!SSWMethodSpyManager methodsFor!

_compileSpy: anSSWMethodSpy

	anSSWMethodSpy method recompileWithSpy: anSSWMethodSpy!

areSpiesEnabled

	"areSpiesEnabled stores a Boolean indicating whether all spies are enabled/disabled.
	areSpiesEnabled = false overrides a spy's isLocallyEnabled setting"

	^areSpiesEnabled!

areSpiesEnabled: aBoolean

	"areSpiesEnabled stores a Boolean indicating whether all spies are enabled/disabled.
	areSpiesEnabled = false overrides a spy's isLocallyEnabled setting setting"

	areSpiesEnabled := aBoolean.

	self onSpyChanged!

compileSpy: anSSWMethodSpy

	"return success"

	^[self _compileSpy: anSSWMethodSpy.
	true] 
		on: CompilerErrorNotification do:
			[ :exc | 
			MessageBox warning: 'Did not compile: ', exc description.
			exc return: false]

!

displayOn: aStream

	aStream nextPutAll: 'Method Spies'!

hookInspector: anInspector

	anInspector renderers do: 
		[ :each |
		(each isKindOf: AspectInspector) ifTrue: 
			[each aspectTreePresenter view contextMenu ifNotNil: 
				[ :menu | 
				menu
					addSeparator;
					addItem: (CommandMenuItem commandDescription: (ClosedCommandDescription command: (Message selector: #insertObjectBreakpointForInspecteeOf: argument: anInspector) description: 'Insert Breakpoint...' receiver: self))]]]!

icon

	^SSWMethodSpy icon!

initialize

	self areSpiesEnabled: true.

	Smalltalk developmentSystem registerTool: self.

	Debugger when: #viewOpened: send: #onDebuggerOpened: to: self.
	FlipperInspector when: #viewOpened: send: #onInspectorOpened: to: self!

insertObjectBreakpointFor: anObject

	(ChoicePrompter multipleChoices: anObject class allSelectors asSortedCollection caption: 'Select method(s) to insert breakpoints for this object') ifNotNil: 
		[ :selectors |
		selectors do: 
			[ :selector |
			(anObject class lookupMethod: selector) insertSpy: (SSWMethodSpy objectBreakpointFor: anObject)]]!

insertObjectBreakpointForInspecteeOf: anInspector

	self insertObjectBreakpointFor: anInspector object!

onDebuggerClosed: aDebugger
	self removeEventsTriggeredFor: aDebugger
!

onDebuggerOpened: aDebugger

	self when: #methodSpiesCompiledIn: send: #onMethodSpiesCompiledIn: to: aDebugger.
	aDebugger when: #viewClosed send: #onDebuggerClosed: to: self with: aDebugger!

onInspectorClosed: anInspector
	self removeEventsTriggeredFor: anInspector
!

onInspectorOpened: anInspector

	[self hookInspector: anInspector] postToInputQueue.
	anInspector when: #viewClosed send: #onInspectorClosed: to: self with: anInspector!

onSpiesCompiledIn: aCompiledMethod

	self trigger: #methodSpiesCompiledIn: with: aCompiledMethod!

onSpyChanged

	self trigger: #methodSpyChanged!

onSpyChangedIn: aCompiledMethod

	self trigger: #methodSpyChangedIn: with: aCompiledMethod!

spiesCompiledIn: aCompilationResult

	| spyMethod |

	spyMethod := aCompilationResult method.

	SmalltalkSystem current onMethodTransparentlyUpdated: aCompilationResult.
	self onSpiesCompiledIn: spyMethod!

spyChangedIn: aCompiledMethod

	self onSpyChangedIn: aCompiledMethod!

uninitialize

	Smalltalk developmentSystem unregisterTool: self.

	Debugger removeEventsTriggeredFor: self.
	FlipperInspector removeEventsTriggeredFor: self! !
!SSWMethodSpyManager categoriesForMethods!
_compileSpy:!actions!private! !
areSpiesEnabled!accessing!public! !
areSpiesEnabled:!accessing!public! !
compileSpy:!actions!public! !
displayOn:!displaying!public! !
hookInspector:!operations!private! !
icon!accessing!public! !
initialize!initializing!public! !
insertObjectBreakpointFor:!operations!private! !
insertObjectBreakpointForInspecteeOf:!operations!private! !
onDebuggerClosed:!event handling!public! !
onDebuggerOpened:!event handling!public! !
onInspectorClosed:!event handling!public! !
onInspectorOpened:!event handling!public! !
onSpiesCompiledIn:!event handling!public! !
onSpyChanged!event handling!public! !
onSpyChangedIn:!event handling!public! !
spiesCompiledIn:!operations!public! !
spyChangedIn:!operations!public! !
uninitialize!initializing!public! !
!

!SSWMethodSpyManager class methodsFor!

current

	"current stores the singleton instance of the receiver"

	current isNil ifTrue: [current := self new initialize].

	^current!

initialize

	self current!

publishedAspectsOfInstances
	
	^(super publishedAspectsOfInstances)
		add: (Aspect boolean: #areSpiesEnabled);
		yourself!

publishedEventsOfInstances
	"Answer a <Set> of <Symbol>s, being the names of all events published 
	by instances of the receiver."

	^super publishedEventsOfInstances
		add: #methodSpiesCompiledIn:;
		add: #methodSpyChanged;
		add: #methodSpyChangedIn:;
		yourself!

reset

	"Destroy the singleton instance (it will be lazily recreated on next use)"

	current ifNotNil: [ :curr | curr uninitialize].
	current := nil!

uninitialize

	self reset! !
!SSWMethodSpyManager class categoriesForMethods!
current!accessing!public! !
initialize!class initialization!public! !
publishedAspectsOfInstances!constants!public! !
publishedEventsOfInstances!constants!public! !
reset!accessing!public! !
uninitialize!class initialization!public! !
!

