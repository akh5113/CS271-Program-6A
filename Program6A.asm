TITLE Program 6A     (program6A.asm)

; Author: Anne Harris		harranne@oregonstate.edu
; Course / Project ID: CS 271-400 / Project 6A                 Date: 3/18/2018
; Description: This program takes 10 user enterd unsigned integers as a digit string
;	and converts that digit string into an integer and stores it in an array. The sum and
;	average of the array is calculated and displayed. Then the integers are converted back 
;	to a string-digit and displayed
;IMPLEMENTATION NOTE: I couldn't get the writeVal function to work. It successfully reads the numbers
;	but doesn't store them into the right location to be printed. Thus I have printed out the array of integers
;	and printed the sum and average as integers rather than converting them to strings first.
;	If you want to see you can uncomment the section within main that's named "UNSUCCESSFUL" and you can see how
;	it will get the first number of the array correct but it fails with the rest of the array.

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

;macro to get user string input
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
buffer		DWORD	0							;temp variable to store integer 
stringBuff	BYTE	MAXSIZE DUP(?)				;temp variable to store converted string
	

.code
main PROC
	;call introduction procedure {parameters by address: intro, directions}
	push	OFFSET directions		;[esb + 8]
	push	OFFSET intro			;[esp + 4]
	call	introduction			;[esp]

	;call readval procedure {parameters: array address, count value, temp value, address of sizeActual, address of error, stringNum value, address of prompt, address of inputStr}
	push	OFFSET array			;[esp + 32]
	push	count					;[esp + 28]
	push	temp					;[esp + 24]
	push	OFFSET sizeActual		;[esp + 20]
	push	OFFSET error			;[esp + 16]
	push	stringNum				;[esp + 12]
	push	OFFSET inputStr			;[esp + 8]
	push	OFFSET prompt			;[esp + 4]
	call	readVal					;[esp]

;	print integer array for debugging {parameters: address of summary, address of array}
	push	OFFSET summary			;[esp + 8]
	push	OFFSET array			;[esp + 4]
	call	printArray				;[esp]

	;calculate sum and average of array {parameters: address of avgDisp, address of sumDisp, address of array, userSum value, userAvg value}
	push	OFFSET avgDisp			;[esp + 20]
	push	OFFSET sumDisp			;[esp + 16]
	push	OFFSET array			;[esp + 12]
	push	userSum					;[esp + 8]
	push	userAvg					;[esp + 4]
	call	calculations			;[esp]

;------------------------------------------------------------------------------
	;UNSUCCESSFUL
	;uncomment this section if you would like to see my attempt at the writeVal proc
	;print array of numbers as string
;	displayString OFFSET summary
;	mov		esi, OFFSET array
;	mov		ecx, 10
;convertToNum:
;	mov		eax, [esi]
;	mov		buffer, eax
	;set up stack for writeVal procedure {parameters: address of stringBuffer, buffer value}
;	push	buffer					;[esp + 8]
;	push	OFFSET stringBuff		;[esp + 4]
;	call	writeVal				;[esp]
;	add		esi, 4
;	loop	convertToNum
;-------------------------------------------------------------------------------

	;call goodbye procedure {parameters: thanks(address)}
	push	OFFSET	thanks			;[esp+4]
	call	goodbye					;[esp]

	exit	; exit to operating system
main ENDP

;-------------------------------------------------------------------
;Introduces the program and displays the instructions using the 
;	displayString macro
;Receives: address of directions and address of intro
;Returns: n/a
;Preconditions: n/a
;Registers Changed: edx
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
;Prompts the user to enter a value (read in as a string) and converts
;	that string-digit as an integer. uses getString macro
;Receives:address of: array, temp sizeActual, error message, stringNum
;	inputStr, prompt; value of: count
;Returns: an array of integers
;Preconditions: n/a
;Registers Changed: eax, ebx, ecx, edx
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
;Prints an array of integers
;Receives: address of: summary, array
;Returns: n/a
;Preconditions: array has 10 integers stored in it
;Registers Changed: eax, ecx
;-------------------------------------------------------------------
printArray PROC
	;[epb + 12]		address of summary string
	;[ebp + 8]		address of array
	;[ebp + 4]		return address

	push	ebp
	mov		ebp, esp
	pushad

	displayString	[ebp + 12]

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
	ret		12
printArray ENDP

;-------------------------------------------------------------------
;Calculates the sum and average of the numbers in the array
;Receives: address of: avgDisp, sumDisp, array; value of: userSum,
;	userAvg
;Returns: n/a
;Preconditions:	array has 10 integer values 
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
	;would convert to string-digit if I got writeVal working properly
	call	writeDec
	call	crlf

	;calculate average
	mov		ebx, 10
	cdq
	div		ebx
	mov		[ebp + 8], eax
	;display average
	displayString	[ebp + 24]
	;would convert to string-digit if I got writeVal working properly
	call	WriteDec
	call	crlf


	pop		ebp
	popad

	ret		16
calculations ENDP



;-------------------------------------------------------------------
;Converts an integer number to string-digit and displays it using
;	displayString macro
;Receives: address of stringBuff, value of buffer
;Returns: n/a	
;Preconditions: buffer is an integer
;Registers Changed: eax, ebx, edx,
;-------------------------------------------------------------------
WriteVal PROC
	;[ebp + 12]	number to convert
	;[ebp + 8]  address of string to store number in
	;[ebp + 4]	return address
	;[ebp]

	push	ebp
	mov		ebp, esp
	pushad

	mov		edi, [ebp + 8]		;address of string
	add		edi, 2	;number of digits
	dec		edi
	cld
;	std

;	mov		esi, [ebp + 12]
;	mov		eax, [esi]
	mov		eax, [ebp + 12]

toAscii:
	;convert the int to the ascii char
	mov		ebx, 10
	cdq
	div		ebx
	add		edx, 48
	push	eax
	mov		eax, edx
	;temp print statement
	call	writeChar
	call	crlf

	stosb
	pop		eax
	cmp		eax, 0
	jne		toAscii

	;add null terminating 0
;	inc		edi
;	mov		edi, 0
	mov		edi, [ebp + 8]	;beginning of array
	displayString edi


	pop		ebp
	popad	

	ret	12
WriteVal ENDP

;-------------------------------------------------------------------
;Displays goodbye message to user using displayString macro
;Receives: address of thanks
;Returns: n/a
;Preconditions: n/a 
;Registers Changed: edx
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
