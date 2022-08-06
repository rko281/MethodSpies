"Filed out from Dolphin Smalltalk"!

VirtualMethodCategory subclass: #SSWSpiedMethodsCategory
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWSpiedMethodsCategory guid: (GUID fromString: '{9cf1d5a1-51ea-11d6-87e7-0010a70883e2}')!
SSWSpiedMethodsCategory comment: ''!
!SSWSpiedMethodsCategory categoriesForClass!Unclassified! !
!SSWSpiedMethodsCategory methodsFor!

includesMethod: aMethod

	^aMethod isSpy! !
!SSWSpiedMethodsCategory categoriesForMethods!
includesMethod:!public!testing! !
!

!SSWSpiedMethodsCategory class methodsFor!

initialize
	"Private - Initialize the receiver.
		SSWSpiedMethodsCategory initialize.
	"

	self addPseud: (self newNamed: self pseudPrefix, 'method spies')!

uninitialize
	"Private - Uninitialize the receiver as it is about to be removed from the system."

	self removePseud: self pseudPrefix, 'method spies'! !
!SSWSpiedMethodsCategory class categoriesForMethods!
initialize!initializing!private! !
uninitialize!class hierarchy-removing!private! !
!

