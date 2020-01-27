"Filed out from Dolphin Smalltalk 7"!

Model subclass: #SSWMethodSpyManager
	instanceVariableNames: 'areSpiesEnabled'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'current'!
SSWMethodSpyManager guid: (GUID fromString: '{72e11082-3f59-11d6-87e5-0010a70883e2}')!
SSWMethodSpyManager comment: ''!
!SSWMethodSpyManager categoriesForClass!Unclassified! !
!SSWMethodSpyManager methodsFor!

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

	^[anSSWMethodSpy method recompileWithSpy: anSSWMethodSpy.
	true] 
		on: CompilerErrorNotification do:
			[ :exc | 
			MessageBox warning: 'Did not compile: ', exc description.
			exc return: false]

!

displayOn: aStream

	aStream nextPutAll: 'Method Spies'!

icon

	^SSWMethodSpy icon!

initialize

	self areSpiesEnabled: true.

	Smalltalk developmentSystem registerTool: self.

	Debugger when: #viewOpened: send: #onDebuggerOpened: to: self!

onDebuggerClosed: aDebugger
	self removeEventsTriggeredFor: aDebugger
!

onDebuggerOpened: aDebugger

	self when: #methodSpiesCompiledIn: send: #onMethodSpiesCompiledIn: to: aDebugger.
	aDebugger when: #viewClosed send: #onDebuggerClosed: to: self with: aDebugger!

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

spyChanged

	self onSpyChanged!

spyChangedIn: aCompiledMethod

	self onSpyChangedIn: aCompiledMethod!

toggleAreSpiesEnabled

	self areSpiesEnabled: self areSpiesEnabled not!

uninitialize

	Smalltalk developmentSystem unregisterTool: self.

	Debugger removeEventsTriggeredFor: self! !
!SSWMethodSpyManager categoriesFor: #areSpiesEnabled!accessing!public! !
!SSWMethodSpyManager categoriesFor: #areSpiesEnabled:!accessing!public! !
!SSWMethodSpyManager categoriesFor: #compileSpy:!actions!public! !
!SSWMethodSpyManager categoriesFor: #displayOn:!displaying!public! !
!SSWMethodSpyManager categoriesFor: #icon!accessing!public! !
!SSWMethodSpyManager categoriesFor: #initialize!initializing!public! !
!SSWMethodSpyManager categoriesFor: #onDebuggerClosed:!event handling!public! !
!SSWMethodSpyManager categoriesFor: #onDebuggerOpened:!event handling!public! !
!SSWMethodSpyManager categoriesFor: #onSpiesCompiledIn:!event handling!public! !
!SSWMethodSpyManager categoriesFor: #onSpyChanged!event handling!public! !
!SSWMethodSpyManager categoriesFor: #onSpyChangedIn:!event handling!public! !
!SSWMethodSpyManager categoriesFor: #spiesCompiledIn:!operations!public! !
!SSWMethodSpyManager categoriesFor: #spyChanged!operations!public! !
!SSWMethodSpyManager categoriesFor: #spyChangedIn:!operations!public! !
!SSWMethodSpyManager categoriesFor: #toggleAreSpiesEnabled!actions!public! !
!SSWMethodSpyManager categoriesFor: #uninitialize!initializing!public! !

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
!SSWMethodSpyManager class categoriesFor: #current!accessing!public! !
!SSWMethodSpyManager class categoriesFor: #initialize!class initialization!public! !
!SSWMethodSpyManager class categoriesFor: #publishedAspectsOfInstances!constants!public! !
!SSWMethodSpyManager class categoriesFor: #publishedEventsOfInstances!constants!public! !
!SSWMethodSpyManager class categoriesFor: #reset!accessing!public! !
!SSWMethodSpyManager class categoriesFor: #uninitialize!class initialization!public! !

