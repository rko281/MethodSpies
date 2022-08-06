"Filed out from Dolphin Smalltalk"!

Presenter subclass: #SSWMethodSpyPresenter
	instanceVariableNames: 'spySourcePresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWMethodSpyPresenter guid: (GUID fromString: '{7c99fb61-40b6-11d6-87e5-0010a70883e2}')!
SSWMethodSpyPresenter comment: ''!
!SSWMethodSpyPresenter categoriesForClass!Unclassified! !
!SSWMethodSpyPresenter methodsFor!

accept

	| newSource oldSource |

	newSource := spySourcePresenter text.
	(newSource isNil or: [newSource isEmpty]) ifTrue: [newSource := '"<no spy source>"'].

	oldSource := self methodSpy spySource.
	self methodSpy spySource: newSource.

	(self spyManager compileSpy: self methodSpy) 
		ifTrue: [self refreshSpySource]
		ifFalse: [self methodSpy spySource: oldSource]!

createComponents

	super createComponents.

	spySourcePresenter := self add: SmalltalkWorkspace new name: 'spySource'!

icon

	^SSWMethodSpy icon!

method

	"Make the receiver polymorphic with a MethodBrowser
	 - in as much as a MethodSpy is polymorphic with a CompiledMethod"

	^self methodSpy!

methodSpy

	^self model value!

onViewOpened

	super onViewOpened.
	self refreshSpySource!

queryCommand: aCommandQuery

	| symbol |

	symbol := aCommandQuery commandSymbol.

	symbol == #accept ifTrue:
		[aCommandQuery isEnabled: (spySourcePresenter isModified or: [self methodSpy isExisting not]).
		^true].

	symbol == #toggleEnabled ifTrue:
		[aCommandQuery isChecked: self methodSpy isEnabled; isEnabled: true.
		^true].

	symbol == #removeSpy ifTrue:
		[aCommandQuery isEnabled: self methodSpy method isSpy.
		^true].

	^super queryCommand: aCommandQuery!

refreshSpySource

	spySourcePresenter text: self model value spySource!

removeSpy

	(MessageBox confirm: 'Remove this Method Spy?') ifFalse: [^self].

	self methodSpy removeFromMethod.
	self view topView close!

resetSpy

	self methodSpy reset!

spiedMethod

	^self methodSpy method!

spyManager

	^SSWMethodSpyManager current!

toggleEnabled

	self methodSpy isLocallyEnabled: self methodSpy isLocallyEnabled not.

	self spiedMethod isSpy ifTrue: [self spyManager spyChangedIn: self spiedMethod]! !
!SSWMethodSpyPresenter categoriesForMethods!
accept!accessing!commands!public! !
createComponents!initializing!public! !
icon!accessing!public! !
method!accessing!public! !
methodSpy!accessing!public! !
onViewOpened!initializing!public! !
queryCommand:!accessing!commands!public! !
refreshSpySource!helpers!public! !
removeSpy!accessing!commands!public! !
resetSpy!accessing!commands!public! !
spiedMethod!accessing!public! !
spyManager!accessing!public! !
toggleEnabled!accessing!commands!public! !
!

!SSWMethodSpyPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853516 131137 544 nil 496 nil 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 135 4 60 213 87 1 0 0 204 53 87 1 3 0 20 59 0 0 0 0 15 1 5 86 135 1] 328198 ##(Smalltalk.Point) 193 193 nil 544 496 8 1962422656 170 192 8 #() 170 192 34 8 48297 1115206 1 ##(Smalltalk.ToolbarIconButton) 544 1 1180998 4 ##(Smalltalk.CommandDescription) #removeSpy 8 'Remove this Spy' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'EditClear.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 48297 44163 802 544 1 834 #resetSpy 8 'Reset Spy' 1 1 788806 1 ##(Smalltalk.TextTileIcon) $\x29BF 8 'Cambria' nil nil nil nil 1 nil nil 44163 44161 802 544 1 834 #toggleEnabled 8 'Enable/Disable the Spy' 1 1 1058 $\x2611 8 'Segoe UI Emoji' nil 482 #hotlight nil nil 1 nil nil 44161 44159 802 544 1 834 #accept 8 'Accept changes' 1 1 882 nil true 928 8 'FileSave.ico' 976 44159 34 6 1200 1104 1008 1049158 1 ##(Smalltalk.ToolbarSeparator) 544 1 816 1298 544 1 nil nil 1 nil 690 33 33 690 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 690 1 1 690 701 51 544 1442 #updateSizePosted 752 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 25 0 0 0] 8 #() 690 193 193 nil 27 nil nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 1616 nil nil nil 5 nil nil nil 1616 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.ValueWorkspace) #resource_Default_view nil 1378 138 144 34 1 1442 #createAt:extent: 34 2 690 1 51 690 701 451 1616 1538 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 94 1 0 0 250 0 0 0] 752 1600 nil 27 170 192 34 2 1616 8 'spySource' nil 1378 138 144 34 1 1442 #createAt:extent: 34 2 690 5119 21 690 701 501 416 1538 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 9 0 0 10 0 0 0 93 11 0 0 4 1 0 0] 34 2 544 1616 1600 nil 27 )! !
!SSWMethodSpyPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

