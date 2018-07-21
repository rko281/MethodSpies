"Filed out from Dolphin Smalltalk 7"!

Object subclass: #SSWMethodSpy
	instanceVariableNames: 'spySource methodSourceInterval spySourceInterval activations isLocallyEnabled method context description'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWMethodSpy guid: (GUID fromString: '{f9497940-1eee-11d6-87e4-0010a70883e2}')!
SSWMethodSpy comment: ''!
!SSWMethodSpy categoriesForClass!Unclassified! !
!SSWMethodSpy methodsFor!

<= anSSWSpypoint

	"Always order by source position"

	^self methodSourcePosition <= anSSWSpypoint methodSourcePosition!

activated

	self activations addLast: Dictionary new!

activationContext

	"Return the context for the current activation"

	^self activations last
!

activationCount

	"Return the number of activations since the last reset"

	^self activations size
!

activations

	"activations stores an OrderedCollection of Dictionaries, 
	providing an individual context for each activation of the receiver"

	^activations
!

activations: anOrderedCollection

	"activations stores an OrderedCollection of Dictionaries, 
	providing an individual context for each activation of the receiver"

	activations := anOrderedCollection
!

at: aKey

	"Forward to the context"

	^self context at: aKey!

at: aKey put: aValue

	"Forward to the context"

	^self context at: aKey put: aValue!

break

	"Bring up the Smalltalk debugger (suspending the active process) ...
	Compared to halt this method will have the method containing the spy at the top, rather than the spy code"

	Processor activeProcess halt: self hostFrame cause: self description!

breakIf: aBoolean

	aBoolean ifTrue: [self break]!

captureArguments

	"Capture the arguments to the host frame and store in the activationContext"

	| hostFrame |

	hostFrame := self hostFrame.

	hostFrame argumentNames keysAndValuesDo: [ :index :argName | self activationContext at: argName put: (hostFrame argAt: index)]!

commentedSpySource

	^'"<1s>"<N><2s>' expandMacrosWith: self description with: self spySource!

context

	"context stores a Dictionary for arbitary storage by the spySource code.
	This provides the 'context' for a Spy, allowing information to persist across activations.

	The context is generally accessed by sending at: and at:put: directly to the receiver"

	^context!

context: aDictionary

	"context stores a Dictionary for arbitary storage by the spySource code.
	This provides the 'context' for a Spy, allowing information to persist across activations.

	The context is generally accessed by sending at: and at:put: directly to the receiver"

	context := aDictionary!

description
	^description!

description: anObject
	description := anObject!

displayOn: aStream

	aStream
		nextPutAll: self commentedSpySource; cr;
		cr;
		nextPutAll: 'Activations: ', self activationCount displayString!

handle

	"Code is expressed this way to minimize additional frames in the debugger"
	self spiedFrame ifNotNil: 
		[ :frame |
		self activated.
		(self spyExpressionFor: frame) value: (self spyReceiverFor: frame) withArguments: #() .
		self handledFor: frame]!

handledFor: aFrame

	"Spy handling finished. If we are running in the debugger arrange to drop back into the spied method"

	aFrame process debugger ifNotNil: [ :debugger | debugger makeDebugFrame: aFrame]!

hostFrame

	"Private - This spy has been activated. Locate and return the stack frame in the current process where the receiver's method is located"

	| hostFrame |

	"Spied method could be anywhere in the stack but will be at least (and usually) 4 senders down from here (this method>spy action>spy code>spy invocation>host method)"
	hostFrame := Processor activeProcess topFrame sender sender sender.
	[hostFrame := hostFrame sender.
	hostFrame method ifNil: [false] ifNotNil: [ :frameMethod | (frameMethod literalsDetect: [ :each | each == self] ifNone: [nil]) notNil]] whileFalse.

	^hostFrame!

isBreakpoint

	| sentMessages |

	sentMessages := self parseTree sentMessages.
	^(sentMessages includes: #break) or: [sentMessages includes: #breakIf:]!

isEnabled

	"Return a Boolean indicating whether this spy is enabled:
	 - to be enabled, a spy must be locally enabled, plus spies must be enabled globally"

	^self isLocallyEnabled and: [self spyManager areSpiesEnabled]!

isExisting

	"Does this spy exist in its method?"

	^self method isSpy and: [self method methodSpies identityIncludes: self]!

isLocallyEnabled

	"isLocallyEnabled stores a Boolean indicating whether this particular spy is enabled
	(c.f. isEnabled)"

	^isLocallyEnabled!

isLocallyEnabled: aBoolean

	"isLocallyEnabled stores a Boolean indicating whether this particular spy is enabled
	(c.f. isEnabled)"

	isLocallyEnabled := aBoolean
!

isVirgin

	"Has this spy never been activated?"

	^self activationCount <= 1!

method

	"method stores the CompiledMethod which the receiver spies on"

	^method!

method: aCompiledMethod

	"method stores the CompiledMethod which the receiver spies on"

	method := aCompiledMethod!

methodSourceInterval

	"methodSourceInterval stores the Interval range within which the receiver's 
	spySource 'exists' in the host CompiledMethod's sourceString.

	The significant factor is the start of this Interval; the length is purely for IDE use"

	^methodSourceInterval!

methodSourceInterval: anInterval

	"methodSourceInterval stores the Interval range within which the receiver's 
	spySource 'exists' in the host CompiledMethod's sourceString.

	The significant factor is the start of this Interval; the length is purely for IDE use"

	methodSourceInterval := anInterval!

methodSourcePosition

	^self methodSourceInterval start!

parseTree

	^SmalltalkParser parseExpression: self spySource in: self method methodClass!

publishedAspects

	^super publishedAspects
		add: 
			(Aspect name: #spySource 
					presenterBlock: 
						(MessageSend 
							receiver: TextPresenter 
							selector: #create:in:on:
							arguments: #('Static text' nil nil)) 
					editBlock: 
						(MessageSend
							receiver: self
							selector: #editAndRecompileIn:
							arguments: #(nil)));
		yourself!

removeFromMethod

	^self method removeSpy: self!

reset

	self 
		activations: OrderedCollection new;
		isLocallyEnabled: true;
		context: Dictionary new!

scintillaIndicator: anInteger

	^ScintillaIndicator
		styleName: (self isLocallyEnabled ifTrue: [#SpyEnabled] ifFalse: [#SpyDisabled])
		range: (self methodSourceInterval + anInteger)
		tag: self!

spiedFrame

	^self isEnabled 
		ifTrue: [Processor activeProcess topFrame sender sender]
		ifFalse: [nil]!

spyExpressionFor: aFrame

	| tempPool expression |

	tempPool := PoolDictionary new.
	aFrame temps do: 
		[ :triplet || index |
		index := triplet third.
		index > 0 ifTrue: 
			[tempPool at: triplet first put: ((aFrame getOuter: triplet second) at: index)]]. 
	tempPool at: 'thisSpy' put: self.

	expression := Compiler 
		compileForEvaluation: self commentedSpySource
		in: aFrame receiver class
		evaluationPools: (Array with: tempPool)
		logged: false
		flags: 0. 

	^expression method 
		isImmutable: false;
		selector: 'spyIt';
		yourself!

spyManager

	^SSWMethodSpyManager current!

spyReceiverFor: aFrame

	^aFrame receiver!

spySource

	"spySource stores the source code String which forms this spypoint"

	^spySource!

spySource: aString

	"spySource stores the source code String which forms this spypoint"

	spySource := aString!

spySourceAt: aPosition spyCount: anInteger

	| source |

	source := self class spySourceCount: anInteger.

	self spySourceInterval: (aPosition to: (aPosition + (source size - 1))).

	^source
!

spySourceForTest

	"Return the receiver's source code in a format which can be tested for compilation failures"

	| tree |

	tree := [SmalltalkParser parseExpression: spySource] on: Error do: [ :exc | exc return: nil].

	"Unspecified problem; return a value which will throw an appropriate compilation error"
	tree isNil ifTrue: [^'<error>'].

	"Rename the thisSpy pseudo special symbol so code will compile"
	(ParseTreeRewriter rename: 'thisSpy' to: '#thisSpy') executeTree: tree.

	^tree formattedCode!

spySourceInterval

	"spySourceInterval stores the Interval range of the receiver's spySource
	when the full source (including all spies) of the associated SSWSpyMethod is displayed"

	^spySourceInterval!

spySourceInterval: anInterval

	"spySourceInterval stores the Interval range of the receiver's spySource
	when the full source (including all spies) of the associated SSWSpyMethod is displayed"

	spySourceInterval := anInterval!

toggleLocallyEnabled

	self isLocallyEnabled: (self isLocallyEnabled not)! !
!SSWMethodSpy categoriesFor: #<=!comparing!public! !
!SSWMethodSpy categoriesFor: #activated!debugger-step over!private! !
!SSWMethodSpy categoriesFor: #activationContext!accessing!public! !
!SSWMethodSpy categoriesFor: #activationCount!accessing!public! !
!SSWMethodSpy categoriesFor: #activations!accessing!public! !
!SSWMethodSpy categoriesFor: #activations:!accessing!public! !
!SSWMethodSpy categoriesFor: #at:!accessing!public! !
!SSWMethodSpy categoriesFor: #at:put:!accessing!public! !
!SSWMethodSpy categoriesFor: #break!public!spy actions! !
!SSWMethodSpy categoriesFor: #breakIf:!public!spy actions! !
!SSWMethodSpy categoriesFor: #captureArguments!public!spy actions! !
!SSWMethodSpy categoriesFor: #commentedSpySource!accessing!public! !
!SSWMethodSpy categoriesFor: #context!accessing!public! !
!SSWMethodSpy categoriesFor: #context:!accessing!public! !
!SSWMethodSpy categoriesFor: #description!accessing!public! !
!SSWMethodSpy categoriesFor: #description:!accessing!public! !
!SSWMethodSpy categoriesFor: #displayOn:!displaying!public! !
!SSWMethodSpy categoriesFor: #handle!debugger-step through!handling!public! !
!SSWMethodSpy categoriesFor: #handledFor:!debugger-step over!handling!private! !
!SSWMethodSpy categoriesFor: #hostFrame!accessing!private! !
!SSWMethodSpy categoriesFor: #isBreakpoint!public!testing! !
!SSWMethodSpy categoriesFor: #isEnabled!public!testing! !
!SSWMethodSpy categoriesFor: #isExisting!public!testing! !
!SSWMethodSpy categoriesFor: #isLocallyEnabled!accessing!public! !
!SSWMethodSpy categoriesFor: #isLocallyEnabled:!accessing!public! !
!SSWMethodSpy categoriesFor: #isVirgin!public!testing! !
!SSWMethodSpy categoriesFor: #method!accessing!public! !
!SSWMethodSpy categoriesFor: #method:!accessing!public! !
!SSWMethodSpy categoriesFor: #methodSourceInterval!accessing!public! !
!SSWMethodSpy categoriesFor: #methodSourceInterval:!accessing!public! !
!SSWMethodSpy categoriesFor: #methodSourcePosition!accessing!public! !
!SSWMethodSpy categoriesFor: #parseTree!accessing!public! !
!SSWMethodSpy categoriesFor: #publishedAspects!accessing!public! !
!SSWMethodSpy categoriesFor: #removeFromMethod!actions!public! !
!SSWMethodSpy categoriesFor: #reset!actions!public! !
!SSWMethodSpy categoriesFor: #scintillaIndicator:!accessing!public! !
!SSWMethodSpy categoriesFor: #spiedFrame!debugger-step over!handling!private! !
!SSWMethodSpy categoriesFor: #spyExpressionFor:!debugger-step over!handling!private! !
!SSWMethodSpy categoriesFor: #spyManager!accessing!public! !
!SSWMethodSpy categoriesFor: #spyReceiverFor:!debugger-step over!handling!private! !
!SSWMethodSpy categoriesFor: #spySource!accessing!public! !
!SSWMethodSpy categoriesFor: #spySource:!accessing!public! !
!SSWMethodSpy categoriesFor: #spySourceAt:spyCount:!accessing!public! !
!SSWMethodSpy categoriesFor: #spySourceForTest!accessing!public! !
!SSWMethodSpy categoriesFor: #spySourceInterval!accessing!public! !
!SSWMethodSpy categoriesFor: #spySourceInterval:!accessing!public! !
!SSWMethodSpy categoriesFor: #toggleLocallyEnabled!actions!public! !

!SSWMethodSpy class methodsFor!

activationCounter

	^self newWithSource: '' description: 'Activation Counter'!

breakpoint

	^self newWithSource: 'thisSpy break.' description: 'Breakpoint'!

captureArguments

	^self newWithSource: 'thisSpy captureArguments' description: 'Capture Arguments'!

convenienceSpyNames

	^#(#breakpoint #oneTimeBreakpoint #activationCounter #captureArguments)!

icon

	^SSWSpyMethod icon!

new

	^super new
		description: 'Method Spy';
		reset;
		yourself!

newInstanceAspect: aSymbol class: aspectClass

	^aspectClass
		name: aSymbol
		presenterBlock: [:p :m | SSWMethodSpyPresenter createIn: p on: m]!

newWithSource: aString description: descString

	^self new
		spySource: aString;
		description: descString;
		yourself!

oneTimeBreakpoint

	^self newWithSource: 'thisSpy isVirgin ifTrue: [thisSpy break].' expandMacros description: 'One-time Breakpoint'!

publishedAspectsOfInstances

	^super publishedAspectsOfInstances
		add: (Aspect string: #description);
		add: (Aspect integer: #activationCount);
		add: (Aspect boolean: #isLocallyEnabled);
		add: (Aspect collection: #activations);
		add: (Aspect dictionary: #context);
		yourself!

spySource

	"Arbitrary number. Note we limit spies to max. 9 per method to ensure source is always the same length"

	^self spySourceCount: 1!

spySourceCount: anInteger

	^self spySourceTemplate expandMacrosWith: anInteger!

spySourceTemplate

	^'#thisSpy<1d> handle. '! !
!SSWMethodSpy class categoriesFor: #activationCounter!instance creation!public! !
!SSWMethodSpy class categoriesFor: #breakpoint!instance creation!public! !
!SSWMethodSpy class categoriesFor: #captureArguments!instance creation!public! !
!SSWMethodSpy class categoriesFor: #convenienceSpyNames!constants!public! !
!SSWMethodSpy class categoriesFor: #icon!constants!public! !
!SSWMethodSpy class categoriesFor: #new!instance creation!public! !
!SSWMethodSpy class categoriesFor: #newInstanceAspect:class:!constants!development!instance creation!public! !
!SSWMethodSpy class categoriesFor: #newWithSource:description:!instance creation!private! !
!SSWMethodSpy class categoriesFor: #oneTimeBreakpoint!instance creation!public! !
!SSWMethodSpy class categoriesFor: #publishedAspectsOfInstances!development!public! !
!SSWMethodSpy class categoriesFor: #spySource!development!private! !
!SSWMethodSpy class categoriesFor: #spySourceCount:!development!private! !
!SSWMethodSpy class categoriesFor: #spySourceTemplate!constants!development!private! !

