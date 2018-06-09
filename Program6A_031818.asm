TITLE Program 6A     (program6A.asm)

; Author: Anne Harris		harranne@oregonstate.edu
; Course / Project ID: CS 271-400 / Project 6A                 Date: 3/18/2018
; Description:

INCLUDE Irvine32.inc
;Global variables
MAXSIZE = 11
RUNTIMES = 10

; MACROs

;Write string macro - writes the string to the console
displayString	MACRO	printMe
	push	edx			
	mov		edx, printMe
	call	WriteString
	call	Crlf
	pop		edx
ENDM

;macro to get user input
getString	MACRO	printMe, inNum, sizeOut
	;prompt user
	push	ecx
	push	edx
	push	eax

	mov		edx, printMe
	call	WriteString
	mov		edx, inNum
	mov		ecx, MAXSIZE-1
	call	ReadString
	mov		sizeOut, eax
	
	pop		ecx
	pop		edx
	pop		eax
ENDM

.data
;string variables
intro		BYTE	"Programming Assignment 6A",0dh, 0ah
			BYTE	"Desinging low-level I/O Procedures - Programmed by Anne Harris",0
directions	BYTE	"Please provide 10 unsigned decimal integer values.", 0dh, 0ah
			BYTE	"Each number needs to be small enought to fit inside a 32-bit register",0dh, 0ah
			BYTE	"After you have inputed 10 numbers, I will display a list of the numbers,", 0dh, 0ah
			BYTE	"The sum, and the average of the numbers. Here we go!",0
prompt		BYTE	"Enter an unsigned integer: ",0
error		BYTE	"ERROR. Your number was not an unsigned number OR it was too large.",0
prompt1		BYTE	"Please enter again: ",0
summary		BYTE	"You entered the following numbers: ",0
sumDisp		BYTE	"The sum is: ",0
avgDisp		BYTE	"The average is: ",0
thanks		BYTE	"Thanks for playing, have a nice day!",0

inputStr	BYTE	MAXSIZE DUP(?)				;user entered string of digits
stringNum	DWORD	0							;the string converted to an integer
sizeActual	DWORD	?							;size of the user entered string
temp		DWORD	0							;temp value to aid in the "readInt" calculations
array		DWORD	10 DUP(?)					;array to hold user numbers
userSum		DWORD	0							;sum of array
userAvg		DWORD	?							;average of array
count		DWORD	0							;count of array
buffer		DWORD	0							;temp variable
stringBuff	BYTE	MAXSIZE DUP(?)				;temp variable for writeVal
	

.code
main PROC
	;call introduction procedure {parameters by address: intro, directions}
	push	OFFSET directions		;[esb + 8]
	push	OFFSET intro			;[esp + 4]
	call	introduction			;[esp]

	;call readval procedure {parameters (all by address): prompt, inputStr}
	push	OFFSET array			;[esp + 32]
	push	count					;[esp + 28]
	push	temp					;[esp + 24]
	push	OFFSET sizeActual		;[esp + 20]
	push	OFFSET error			;[esp + 16]
	push	stringNum				;[esp + 12]
	push	OFFSET inputStr			;[esp + 8]
	push	OFFSET prompt			;[esp + 4]
	call	readVal					;[esp]

;	print integer array for debugging
;	push	OFFSET array			;[esp + 4]
;	call	printArray				;[esp]

	;calculate sum and average of array
	push	OFFSET avgDisp			;[esp + 20]
	push	OFFSET sumDisp			;[esp + 16]
	push	OFFSET array			;[esp + 12]
	push	userSum					;[esp + 8]
	push	userAvg					;[esp + 4]
	call	calculations			;[esp]

	;print the array as a string
;	push	buffer					;[esp + 16]
;	push	count					;[esp + 12]
;	push	OFFSET array			;[esp + 8]
;	push	OFFSET stringBuff		;[esp + 4]
;	call	WriteVal				;[esp]

	push	OFFSET array			;[esp + 12]
	push	buffer					;[esp + 8]
	push	OFFSET stringBuff		;[esp + 4]
	call	writeArray				;[esp]

	;call goodbye procedure {parameters: thanks(address)}
	push	OFFSET	thanks			;[esp+4]
	call	goodbye					;[esp]

	exit	; exit to operating system
main ENDP

;-------------------------------------------------------------------
;
;Receives: 
;Returns: 
;Preconditions:
;Registers Changed:
;-------------------------------------------------------------------
introduction PROC
	;[ebp + 12]	address of directions
	;[ebp + 8]	address of intro
	;[ebp + 4]	return address
	;[ebp]

	;set up stack frame
	push	ebp					;save epb on stack
	mov		ebp, esp			;set ebp to esp
	pushad						;save all registers

	;call displayString macros to print
	displayString	[ebp + 8]
	call	crlf
	displayString	[ebp + 12]

	pop		ebp
	popad

	ret		12
introduction ENDP


;-------------------------------------------------------------------
;
;Receives:
;Returns: 
;Preconditions: 
;Registers Changed: 
;-------------------------------------------------------------------
readVal PROC
	;[ebp + 36]	address of array
	;[ebp + 32]	count
	;[ebp + 28]	address of temp
	;[ebp + 24]	address of sizeActual
	;[ebp + 20] address of error message
	;[ebp + 16] address of stringNum
	;[ebp + 12]	address of inputStr
	;[ebp + 8]	address of prompt
	;[ebp + 4]	return address
	;[ebp]

	push	ebp
	mov		ebp, esp
	pushad

	;setup fill array	
	mov		ecx, 10
	mov		edi, [ebp + 36]
fillLoop:
	mov		[ebp + 32], ecx

	;get user input via macro
gsMacro:
	getString	[ebp + 8], [ebp + 12], [ebp + 24]
	;set up loop for to convert sring digit to int
	mov		ecx, [ebp + 24]
	mov		esi, [ebp + 12]
	cld
	;convert string digit to int
L1:
	lodsb
	cmp		al, 48
	jb		errorMsg
	cmp		al, 57
	ja		errorMsg
	sub		al, 48
	movzx	eax, al	

	mov		[ebp + 28], eax	;store in temp
	add		eax, [ebp + 16]

	cmp		ecx, 1
	je		lastDigit
	mov		ebx, 10
	mul		ebx
lastDigit:
	mov		[ebp + 16], eax
	loop	L1
;store number in stringNum variable
done:
	mov		[edi], eax
	add		edi, 4
;	print statements for debugging
;	call	WriteDec
;	call	crlf
	mov		ecx, [ebp + 32]
	mov		ebx, 0
	mov		[ebp + 16], ebx
	loop	fillLoop

	jmp		fin
;error message
errorMsg:
	displayString	[ebp + 20]
	jmp		gsMacro
;exit procedure
fin:
	pop		ebp
	popad	

	ret		28
readVal ENDP

;-------------------------------------------------------------------
;
;Receives:
;Returns: 
;Preconditions: 
;Registers Changed: 
;-------------------------------------------------------------------
printArray PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		ecx, 10
	mov		esi, [ebp + 8]

print:
	mov		eax, [esi]
	call	WriteDec
	call	Crlf
	add		esi, 4
	loop	print

	pop		ebp
	popad
	ret		8
printArray ENDP

;-------------------------------------------------------------------
;
;Receives: 
;Returns:
;Preconditions: 
;Registers Changed: 
;-------------------------------------------------------------------
calculations PROC
	;[ebp + 24] address of avgDisp
	;[ebp + 20]	address of sumDisp
	;[ebp + 16]	address of array
	;[ebp + 12]	value userSum
	;[ebp + 8]	value userAvg
	;[ebp + 4]	return address
	;[ebp]

	push	ebp
	mov		ebp, esp
	pushad

	mov		ecx, 10
	mov		esi, [ebp + 16]

	;calculate the sum
sum:
	mov		eax, [esi]
	add		[ebp + 12], eax
	add		esi, 4
	loop	sum

	mov		eax, [ebp + 12]

	;display sum
	displayString	[ebp + 20]
	call	writeDec
	call	crlf

	;calculate average
	mov		ebx, 10
	cdq
	div		ebx
	mov		[ebp + 8], eax
	;display average
	displayString	[ebp + 24]
	call	WriteDec
	call	crlf


	pop		ebp
	popad

	ret		16
calculations ENDP

;-------------------------------------------------------------------
;
;Receives: 
;Returns:
;Preconditions: 
;Registers Changed: 
;-------------------------------------------------------------------
writeArray	PROC
	;epb + 16	address of array
	;ebp + 12	buffer
	;ebp + 8	address of string buff
	;ebp + 4	return address

	pop		ebp
	mov		ebp, esp
	popad

	mov		ecx, 10
	mov		esi, [ebp + 16]
convertNum:
	push	esi
	push	[ebp + 8]
	call	writeVal
	add		esi, 4
	loop	convertNum

	pop		ebp
	popad
	ret		8
writeArray	ENDP

;-------------------------------------------------------------------
;
;Receives: 
;Returns:
;Preconditions: 
;Registers Changed: 
;-------------------------------------------------------------------
WriteVal PROC
	;[ebp + 12] int to convert to char
	;[ebp + 8]  string buffer
	;[ebp + 4]	return address
	;[ebp]

	push	ebp
	pushad


	mov		edi, [ebp + 8]
	add		edi, 2
	dec		edi
	std
	mov		eax, [ebp + 12]

	mov		ecx, 2
toAscii:
	;convert the int to the ascii char
	mov		ebx, 10
	cdq
	div		ebx
	add		edx, 48
	mov		eax, edx
	call	writeChar
	call	crlf
	stosb

	call	writeChar
	call	crlf

	loop	toAscii
	
finished:
	displayString	[ebp + 8]

	pop		ebp
	popad	

	ret	12
WriteVal ENDP

;-------------------------------------------------------------------
;
;Receives: 
;Returns:
;Preconditions: 
;Registers Changed: 
;-------------------------------------------------------------------
goodbye PROC
	;[ebp + 8]	address of thanks
	;[ebp + 4]	return address
	;[ebp]

	;set up stack frame
	push	ebp					;save epb on stack
	mov		ebp, esp			;set ebp to esp
	pushad						;save all registers

	;call displayString macros to print
	call	Crlf
	displayString	[ebp + 8]
	call	Crlf

	;validate and convert to integers

	pop		ebp
	popad

	ret		8
goodbye ENDP

END main
