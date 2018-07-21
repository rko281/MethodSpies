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

	^self publicIcon!

new: anInteger

	"Overriden to initialize the 'borrowed' selector inst var"

	^(super new: anInteger)
		initSelector;
		yourself!

privateIcon

	"Generated from:
	self createIconMethod: #privateIcon ofSize: 16@16 fromFile: 'D:\Dolphin Smalltalk 7.1\Spies\private_spy.png'.
	"
	^InternalIcon fromBytes: #[137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 1 115 82 71 66 0 174 206 28 233 0 0 0 4 103 65 77 65 0 0 177 143 11 252 97 5 0 0 0 9 112 72 89 115 0 0 14 195 0 0 14 195 1 199 111 168 100 0 0 2 16 73 68 65 84 56 79 99 160 9 216 95 95 207 179 56 33 193 118 85 126 126 220 146 156 156 240 89 89 89 218 51 103 206 100 133 74 227 6 171 66 67 153 215 7 6 230 222 154 60 249 225 151 155 55 255 253 122 251 246 255 207 151 47 255 191 61 124 248 247 174 180 180 35 173 193 193 182 255 25 24 24 161 202 81 1 208 86 150 221 62 62 203 222 111 221 250 239 247 211 167 255 127 93 187 246 255 215 217 179 255 127 157 63 255 255 247 157 59 255 127 61 122 244 255 70 109 237 183 92 91 219 148 250 250 122 38 168 54 4 88 239 228 84 6 164 128 22 48 252 255 190 98 197 255 111 211 166 253 255 214 223 255 255 219 196 137 255 191 207 153 243 255 199 166 77 255 191 239 216 241 255 92 100 228 87 152 58 32 134 128 133 206 206 194 64 10 44 248 101 194 132 255 159 26 27 255 127 170 174 254 255 169 178 242 255 167 170 170 255 159 106 107 255 127 110 107 251 255 5 104 40 76 93 189 143 15 23 144 134 3 176 224 155 252 252 127 143 203 203 255 223 175 168 128 96 160 230 251 64 67 96 108 152 186 173 22 22 31 227 204 205 245 64 26 65 0 46 65 44 62 106 96 240 39 94 95 63 0 200 6 131 255 192 64 249 255 246 246 109 48 13 194 32 49 24 198 38 183 71 81 241 119 180 142 78 24 144 13 6 40 10 96 138 174 169 169 129 105 108 114 11 196 197 63 5 235 235 59 128 52 131 0 220 38 152 2 16 190 38 32 0 103 163 203 165 138 139 159 9 52 51 147 1 178 225 0 46 9 194 23 153 153 255 95 98 100 252 127 25 136 209 229 230 242 242 126 53 211 215 207 73 51 54 70 77 153 32 129 120 105 233 201 251 196 197 255 92 80 80 248 119 73 76 236 223 37 126 254 127 151 4 5 255 93 146 146 254 119 6 40 54 79 64 224 155 141 154 218 140 0 83 83 80 180 99 130 92 21 21 118 63 37 165 140 102 33 225 155 27 37 36 126 30 146 149 253 183 87 70 230 223 98 17 145 239 105 162 162 87 77 116 117 75 3 45 45 197 160 202 177 131 122 6 6 166 8 117 117 169 32 21 21 223 8 57 185 236 16 69 197 28 95 13 141 160 0 61 61 53 144 5 80 101 212 2 12 12 0 170 134 61 52 170 56 224 235 0 0 0 0 73 69 78 68 174 66 96 130]!

publicIcon

	"Generated from:
	self createIconMethod: #publicIcon ofSize: 16@16 fromFile: 'D:\Dolphin Smalltalk 7.1\Spies\public_spy.png'.
	"
	^InternalIcon fromBytes: #[137 80 78 71 13 10 26 10 0 0 0 13 73 72 68 82 0 0 0 16 0 0 0 16 8 6 0 0 0 31 243 255 97 0 0 0 1 115 82 71 66 0 174 206 28 233 0 0 0 4 103 65 77 65 0 0 177 143 11 252 97 5 0 0 0 9 112 72 89 115 0 0 14 195 0 0 14 195 1 199 111 168 100 0 0 1 250 73 68 65 84 56 79 99 160 9 40 94 84 204 29 220 227 111 21 50 33 40 202 183 198 43 40 114 66 164 106 125 125 61 19 84 26 55 8 93 21 202 108 210 104 144 213 184 179 246 193 229 23 23 255 190 250 242 242 239 147 143 143 255 238 186 179 227 167 255 116 143 221 94 93 174 6 80 165 152 0 164 89 183 69 117 241 210 107 11 255 222 250 120 243 223 225 151 7 254 109 123 186 233 223 206 103 219 254 157 125 115 250 223 141 247 215 254 37 109 140 253 172 149 161 236 7 213 130 10 148 107 100 138 129 212 127 16 174 187 92 241 175 224 104 214 191 85 87 150 255 155 126 102 242 191 236 211 201 255 250 110 116 254 155 123 107 198 63 179 217 250 239 96 234 128 24 2 228 42 228 4 129 20 88 48 233 68 212 63 143 131 118 255 18 246 70 252 251 251 247 239 191 179 143 78 255 179 223 107 242 47 232 176 199 191 220 83 105 255 96 234 128 24 5 128 5 93 118 217 252 245 219 238 250 207 103 155 243 191 236 157 41 96 3 46 62 190 240 207 99 139 221 191 128 109 238 112 205 210 245 34 79 4 67 5 249 65 26 65 0 102 34 209 88 178 91 224 59 175 29 155 42 144 13 6 255 129 81 244 255 237 237 219 96 26 132 65 98 48 140 77 78 180 153 231 43 155 46 155 58 144 13 6 40 10 96 138 188 87 57 130 157 140 77 142 63 155 253 17 175 51 175 48 72 51 8 192 109 130 41 0 97 151 101 86 112 63 163 203 177 89 48 206 101 168 103 64 73 88 112 73 16 230 159 202 244 79 122 134 192 191 144 85 62 200 161 14 198 2 57 28 207 89 149 89 181 129 108 12 192 200 233 200 220 32 223 46 246 75 115 182 252 95 249 217 34 255 164 102 241 253 147 158 205 255 87 101 142 228 95 205 233 242 127 69 242 121 95 49 203 49 135 64 213 99 5 140 108 70 204 62 252 17 92 199 20 154 196 190 170 79 144 251 171 218 35 243 71 178 84 232 13 151 3 203 58 22 53 22 83 144 26 136 82 60 64 222 158 129 131 77 139 77 139 219 152 221 149 91 143 221 137 205 0 24 101 30 12 236 80 105 106 2 6 6 0 190 30 25 183 191 155 120 40 0 0 0 0 73 69 78 68 174 66 96 130]! !
!SSWSpyMethod class categoriesFor: #icon!accessing!public! !
!SSWSpyMethod class categoriesFor: #new:!instance creation!public! !
!SSWSpyMethod class categoriesFor: #privateIcon!constants!public! !
!SSWSpyMethod class categoriesFor: #publicIcon!constants!public! !

