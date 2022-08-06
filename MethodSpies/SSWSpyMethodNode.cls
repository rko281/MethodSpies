"Filed out from Dolphin Smalltalk"!

StMethodNode subclass: #SSWSpyMethodNode
	instanceVariableNames: 'methodSpies'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWSpyMethodNode guid: (GUID fromString: '{90039801-3670-11d6-87e5-0010a70883e2}')!
SSWSpyMethodNode comment: ''!
!SSWSpyMethodNode categoriesForClass!Unclassified! !
!SSWSpyMethodNode methodsFor!

formattedCode

	"Do not use formattedSource for a SpyMethod"

	^self source

!

methodSpies

	^methodSpies!

methodSpies: aCollection

	methodSpies := aCollection! !
!SSWSpyMethodNode categoriesForMethods!
formattedCode!accessing!public! !
methodSpies!accessing!public! !
methodSpies:!accessing!public! !
!

!SSWSpyMethodNode class methodsFor!

selectorParts: tokenCollection arguments: variableNodes 

	"Overriden to use the receiver class rather than hard-coded StMethodNode"

	^((tokenCollection anySatisfy: [:each | each isPatternVariable]) ifTrue: [RBPatternMethodNode] ifFalse: [self]) new selectorParts: tokenCollection arguments: variableNodes! !
!SSWSpyMethodNode class categoriesForMethods!
selectorParts:arguments:!instance creation!public! !
!

