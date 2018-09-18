"Filed out from Dolphin Smalltalk 7"!

CompiledMethod variableSubclass: #SSWSpyMethod
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWSpyMethod guid: (GUID fromString: '{57e97f41-21f6-11d6-87e5-0010a70883e2}')!
SSWSpyMethod comment: ''!
!SSWSpyMethod categoriesForClass!Unclassified! !
!SSWSpyMethod methodsFor!

asDebugMethod

	"Overriden to construct a debug version of the receiver spyMethod"

	| spyDebugMethod |

	self isDebugMethod ifTrue: [^self].

	spyDebugMethod := self compilerClass compileDebugMethod: self sourceWithSpies in: self methodClass.

	"Copy across some bits we need as we are an unbound method"
	spyDebugMethod
		sourceDescriptor: self sourceDescriptor;
		selector: self selector;
		isPrivate: self isPrivate.

	spyDebugMethod become: (spyDebugMethod asSpyMethodWithSpies: self methodSpies).
	
	^spyDebugMethod 
		sourceDescriptor: self sourceDescriptor;
		spiedMethod: self spiedMethod;
		yourself!

contactSpies

 	self methodSpies do: [ :each | each method: self]!

currentMethod

	^self methodClass compiledMethodAt: self selector!

debugInfo

	"Always generate the debugInfo for a spy method"

	^self getDebugInfo!

getDebugInfo

	"Overriden to map certain info from the receiver's debugInfo to the actual debugInfo"

	| spyDebugInfo textMap |

	spyDebugInfo := self compilerClass 
		debugInfoFor: self sourceWithSpies
		in: self methodClass 
		debug: self isDebugMethod.

	textMap := spyDebugInfo textMap.

	self methodSpies do: 
		[ :each || spySize |
		spySize := SSWMethodSpy spySource size.
		textMap do: 
			[ :assoc || interval |
			interval := assoc value.
			(interval includes: each methodSourcePosition) 
				ifTrue: [interval stop: ((interval stop - spySize) max: (interval start + each methodSourceInterval size - 1))]
				ifFalse: [interval start > each methodSourcePosition ifTrue: [assoc value: (interval - spySize)]]]].

	spyDebugInfo textMap: textMap.

	^spyDebugInfo!

hasBreakpoint

	^self methodSpies size = 1 and: [self methodSpies first isBreakpoint]!

hash

	"Overriden since superclass implementation directly accesses selector"

	^(self selector hash bitShift: 4) bitXor: methodClass hash!

icon

	^self isPrivate 
		ifTrue: [self class privateIcon] 
		ifFalse: [self class publicIcon]!

infiltrateWithSpies

	"Fill out the receiver's frame with the actual spies (replacing #thisSpyX placeholders)"

	1 to: self size do:
		[ :index || entry |
		entry := self at: index. 
		(entry isSymbol and: [entry beginsWith: 'thisSpy']) ifTrue:
			[self at: index put: (self methodSpies at: (entry allButFirst: 7) asNumber)]]!

initSelector

	selector := Array new: 3!

isPrivate
	"Private - Answer whether the receiver is a debug method."

	^self spiedMethod isPrivate!

isPrivate: aBoolean 
	"Private - Set whether the receiver is a private method."

	self spiedMethod isPrivate: aBoolean!

isSpy

	^true!

isUnbound

	"Additionally check for a change of method instance"

	^super isUnbound or: 
		[| current |
		current := self currentMethod.
		current isSpy not or: [self methodSpies ~= current methodSpies]]!

methodSpies

	"Use embedded storage in selector - cannot add inst vars to CompiledMethod"

	^selector at: 2!

methodSpies: anOrderedCollection

	"Use embedded storage in selector - cannot add inst vars to CompiledMethod"

	selector at: 2 put: anOrderedCollection!

parseTree

	"Overriden to use the SpyParser"

	^(SSWSmalltalkSpyParser parseMethod: self getSource in: self methodClass)
		methodSpies: self methodSpies;
		yourself
!

recompile

	self beSpiedOnByAll: self methodSpies!

recompileWithSpy: aMethodSpy

	(self methodSpies includes: aMethodSpy)
		ifTrue: [self recompile]
		ifFalse: [self beSpiedOnBy: aMethodSpy]!

removeAllSpies

	self methodClass methodDictionary at: self selector put: self spiedMethod.
	self methodSpyManager spiesCompiledIn: 
		(CompilationResult new 
			method: self spiedMethod; 
			oldMethod: self;
			yourself)!

removeSpies: aCollection

	self methodSpies size = aCollection size ifTrue: [^self removeAllSpies].

	self beSpiedOnByAll: 
		(self methodSpies copy
			removeAll: aCollection;
			yourself)!

removeSpy: aMethodSpy

	self removeSpies: (Array with: aMethodSpy)!

selector

	"Overriden since we 'borrow' the selector inst var for methodSpies/spiedMethod"

	^selector at: 1!

selector: aSymbol

	"Overriden since we 'borrow' the selector inst var for methodSpies/spiedMethod"

	selector at: 1 put: aSymbol asSymbol!

sourceDescriptor

	"Override to check whether this message is sent from unbound
	 - need to force unbound for comparisons of CompiledMethod with SpyMethod"

	^Processor activeProcess topFrame sender method == (CompiledMethod compiledMethodAt: #isUnbound)
		ifTrue: [0]
		ifFalse: [super sourceDescriptor]!

sourceWithSpies

	^self sourceWithSpies: self methodSpies!

spiedMethod

	"Use embedded storage in selector - cannot add inst vars to CompiledMethod"

	^selector at: 3!

spiedMethod: anSSWSpyMethod

	"Use embedded storage in selector - cannot add inst vars to CompiledMethod"

	selector at: 3 put: anSSWSpyMethod! !
!SSWSpyMethod categoriesFor: #asDebugMethod!development!private! !
!SSWSpyMethod categoriesFor: #contactSpies!compiling!public! !
!SSWSpyMethod categoriesFor: #currentMethod!accessing!public! !
!SSWSpyMethod categoriesFor: #debugInfo!compiling!public! !
!SSWSpyMethod categoriesFor: #getDebugInfo!development!private! !
!SSWSpyMethod categoriesFor: #hasBreakpoint!public!testing! !
!SSWSpyMethod categoriesFor: #hash!comparing!public! !
!SSWSpyMethod categoriesFor: #icon!accessing!public! !
!SSWSpyMethod categoriesFor: #infiltrateWithSpies!compiling!public! !
!SSWSpyMethod categoriesFor: #initSelector!compiling!initializing!public! !
!SSWSpyMethod categoriesFor: #isPrivate!private!testing! !
!SSWSpyMethod categoriesFor: #isPrivate:!accessing!private! !
!SSWSpyMethod categoriesFor: #isSpy!public!testing! !
!SSWSpyMethod categoriesFor: #isUnbound!public!testing! !
!SSWSpyMethod categoriesFor: #methodSpies!accessing!public! !
!SSWSpyMethod categoriesFor: #methodSpies:!accessing!public! !
!SSWSpyMethod categoriesFor: #parseTree!accessing!public! !
!SSWSpyMethod categoriesFor: #recompile!compiling!public! !
!SSWSpyMethod categoriesFor: #recompileWithSpy:!compiling!public! !
!SSWSpyMethod categoriesFor: #removeAllSpies!compiling!public! !
!SSWSpyMethod categoriesFor: #removeSpies:!compiling!public! !
!SSWSpyMethod categoriesFor: #removeSpy:!compiling!public! !
!SSWSpyMethod categoriesFor: #selector!accessing!public! !
!SSWSpyMethod categoriesFor: #selector:!accessing!public! !
!SSWSpyMethod categoriesFor: #sourceDescriptor!accessing!public! !
!SSWSpyMethod categoriesFor: #sourceWithSpies!accessing!public! !
!SSWSpyMethod categoriesFor: #spiedMethod!accessing!public! !
!SSWSpyMethod categoriesFor: #spiedMethod:!accessing!public! !

!SSWSpyMethod class methodsFor!

icon

	^##((TextTileIcon text: $\x1F576 fontName: 'Segoe UI Symbol' color: (ARGB r: 2 g: 121 b: 215)) textcolor: Color white; yourself)!

new: anInteger

	"Overriden to initialize the 'borrowed' selector inst var"

	^(super new: anInteger)
		initSelector;
		yourself!

privateIcon

	^##((TextTileIcon text: $\x1F576 fontName: 'Segoe UI Symbol' color: Color red) textcolor: Color white; yourself)!

publicIcon

	^##((TextTileIcon text: $\x1F576 fontName: 'Segoe UI Symbol' color: (ARGB named: #limeGreen)) textcolor: Color white; yourself)! !
!SSWSpyMethod class categoriesFor: #icon!accessing!public! !
!SSWSpyMethod class categoriesFor: #new:!instance creation!public! !
!SSWSpyMethod class categoriesFor: #privateIcon!constants!public! !
!SSWSpyMethod class categoriesFor: #publicIcon!constants!public! !

