;Example of using DspDword to print an unsigned decimal number to the console
;
;All data in an assembly program is stored in binary.

;To output to the console the digits must be converted from binary
;to characters.

;This means that the program has to convert for example 123 to '1' '2' '3'.

;DspDword performs this conversion.


.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*******************MACROS********************************

;*************mPrtChar macro****************
;mPrtChar - used to print single characters
;usage: mPrtChar character
;ie to display a 'm' say:
;mPrtChar 'm'


mPrtChar  MACRO  arg1    ;arg1 is replaced by the name of character to be displayed
         push eax        ;save eax
         mov al, arg1    ;character to display should be in al
         call WriteChar  ;display character in al
         pop eax         ;restore eax
ENDM

mPrtStr  MACRO  arg1    ;arg1 is replaced by the name of string to be displayed
         push edx
         mov edx, offset arg1    ;address of str to display should be in dx
         call WriteString        ;display 0 terminated string
         pop edx
ENDM

;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteChar PROTO         ;write the character in al to the console
WriteString PROTO		;Irvine code to write null-terminated string to output
                        ;EDX points to string
                        
;************************  Constants  ***************************

    LF         equ     0Ah                   ; ASCII Line Feed
    
;************************DATA SEGMENT***************************

.data

operand1 dword   -2147483600,-2147483648,-2147482612,-5, -2147483648,1062741823,2147483647,2147483547, 0, -94567 ,4352687,-2147483648,-249346713,-678, -2147483643,32125, -2147483648, -2147483648,2147483647
operators byte    '-','-', '+','*','*', '*', '+', '%', '/',  '/', '+', '-','/', '%','-','*','/', '+','-'
operand2 dword    -200,545,12, 2, -8, 2, 10, -5635, 543,   383, 19786, 150,43981, 115,5,31185,365587,-10,-10

ARRAY_SIZE equ $-carryInNum  

titleMsg            byte "Program 4 by Ostyn Sy",LF,0

posOF  byte    "+Error: Positive Overflow+",0
negOF  byte    "-Error: Negative Overflow-",0
multOF byte    "*Multiplication Overflow*",0

;
;EXPRESSIONS NEED TO DO
;************************CODE SEGMENT****************************

.code

Main PROC
    mPrtStr titleMsg                ;prints title message
    mov     eax, 8954               ;move number to print into eax for DspDword
    call    DspDword                ;print the number in eax

    call    ReadChar                ;pause execution
	INVOKE  ExitProcess,0           ;exit to dos: like C++ exit(0)

Main ENDP


;************** DspDword - display DWORD in decimal
;
;
;       ENTRY - eax contains unsigned number to display
;       EXIT  - none
;       REGS  - EAX,ECX,EDX,EDI,EFLAGS
;
;       To call DspDword: populate eax with number to print then call DspDword
;
;           mov  eax, 8954
;           call DspDword
;           
;
;       DspDword was originally written by Paul Lou and Gary Montante to display a
;       64 bit number and to use stack parameters.
;       It was modified to pass a parameter via register and to 
;       work with 32 bits and Irvine library by Fred Kennedy SP20
;       
;
;-------------- Input Parameters
        
    ;byte array beginning = ebp - 1
    ;ebp           ebp + 0
    ;ret address   ebp + 4
    

    ; 0FDCh | eax            [ebp - 28] <--ESP
    ; 0FE0h | edx            [ebp - 24]
    ; 0FE4h | ebx            [ebp - 20]
    ; 0FE8h | edi            [ebp - 16]
    ; 0FECh |  ?             [ebp - 12]
    ; 0FEDh |  ?             [ebp - 11]
    ; 0FEEh | '0'            [ebp - 10]
    ; 0FEFh | '0'            [ebp - 9]
    ; 0FF0h | '0'            [ebp - 8]
    ; 0FF1h | '0'            [ebp - 7]
    ; 0FF2h | '0'            [ebp - 6]
    ; 0FF3h | '0'            [ebp - 5]
    ; 0FF4h | '8'            [ebp - 4]
    ; 0FF5h | '9'            [ebp - 3]
    ; 0FF6h | '5'            [ebp - 2]
    ; 0FF7h | '4'            [ebp - 1]
    ; 0FF8h | ebp            [ebp + 0]  <--EBP
    ; 0FFCh | return address [ebp + 4]
    ; 1000h | 




    ;digits are peeled off and put on stack in reverse order (right to left)
    
DspDword proc
    push     ebp                    ;save ebp to stack
    mov      ebp,esp                ;save stack pointer
    sub      esp,12                 ;allocate 12 bytes for byte array
                                    ;note: must be an increment of 4
                                    ;otherwise WriteChar will  not work
    push     edi                    ;save edi to stack
    push     ecx                    ;save ecx to stack
    push     edx                    ;save edx to stack
    push     eax                    ;save eax to stack

    mov      edi,-1                 ;edi = offset of beginning of byte array from ebp 
    mov 	 ecx,10                 ;ecx = divisor for peeling off decimal digits

;each time through loop peel off one digit (division by 10),
;(the digit peeled off is the remainder after division by 10)
;convert the digit to ascii and store the digit on the stack
;in reverse order: 8954 stored as 4598
next_digit:
    mov      edx,0                  ; before edx:eax / 10, set edx to 0 
    div      ecx                    ; eax = quotient = dividend shifted right
                                    ; edx = remainder = digit to print.
                                    ; next time through loop quotient becomes
                                    ; new dividend.
    add      dl,'0'                 ; convert digit to ascii character: i.e. 1 becomes '1'
    mov      [ebp+edi],dl           ; Save converted digit to buffer on stack
    dec      edi                    ; Move down in stack to next digit position
    cmp      edi, -10               ; only process 10 digits
    jge      next_digit             ; repeat until 10 digits on stack
                                    ; since working with a signed number, use jge not jae

    inc      edi                    ; when above loop ends we have gone 1 byte too far
                                    ; so back up one byte

;loop to display all digits stored in byte array on stack
DISPLAY_NEXT_DIGIT:      
    cmp      edi,-1                 ; are we done processing digits?
    jg       DONE10                 ; repeat loop as long as edi <= -1
    mPrtChar byte ptr[ebp+edi]      ; print digit
    inc      edi                    ; edi = edi + 1: if edi = -10 then edi + 1 = -9
    jmp      DISPLAY_NEXT_DIGIT     ; repeat
DONE10:
    
    pop      eax                    ; eax restored to original value
    pop      edx                    ; edx restored to original value
    pop      ebx                    ; ebx restored to original value
    pop      edi                    ; edi restored to original value

    mov      esp,ebp                ;restore stack pointer which removes local byte array
    pop      ebp                    ;restore ebp to original value
    ret
DspDword endp

doSub  PROC
;************** doSub - dword subtraction
;
; ENTRY - operand 1 and operand 2 are pushed on the stack
;
; EXIT -EAX = result (operand 1 - operand 2)
; REGS - List registers changed in this function
;
; note: Before calling doSub push operand 2 onto the stack and then push operand 1.
;
; to call doSub in main function:
; push 2 ;32 bit operand2
; push 10 ;32 bit operand1
; call doSub ;10 – 2 = 8 (answer in eax)
;
; Remove parameters by using ret 8 rather than just ret at the end of this function
doSub ENDP

doAdd  PROC
;************** doAdd - dword addition
;
; ENTRY – operand 1 and operand 2 are on the stack
;
; EXIT - EAX = result (operand 1 + operand 2) (any carry is ignored so the answer must fit in 32 bits)
; REGS - List registers changed in this function
;
; note: Before calling doAdd push operand 2 onto the stack and then push operand 1.
;
;
; to call doAdd in main function:
; push 9 ;32 bit operand2
; push 1 ;32 bit operand1
; call doAdd ;1 + 9 = 10 (answer in eax)
;
; Remove parameters by using ret 8 rather than just ret at the end of this function
;
;--------------
doAdd ENDP

doMult PROC
;************** doMult - signed dword multiplication
;
; ENTRY - operand 1 and operand 2 are on the stack
;
; EXIT - EDX:EAX = result (operand 1 * operand 2)
; (for this assignment the product is assumed to fit in EAX and EDX is ignored)
;
; REGS - List registers changed in this function
;
; note: Before calling doMult push operand 2 onto the stack and then push operand 1.
;
; to call doMult in main function:
; push 2 ;32 bit operand2
; push 6 ;32 bit operand1
; call doMult ; 6 * 2 = 12 (answer in eax)
;
; Remove parameters by using ret 8 rather than just ret at the end of this function
;
doMult ENDP

doDiv  PROC
;************** doDiv - signed dword / dword division
;
; ENTRY - operand 1(dividend) and operand 2(divisor) are on the stack
;
; EXIT - EAX = quotient
; EDX = remainder
; REGS - List registers changed in this function
;
; note: Before calling doDiv push operand 2(divisor) onto the stack and then push operand 1(dividend).
;
; to call doDiv in main function:
; push 4 ;32 bit operand2 (Divisor)
; push 19 ;32 bit operand1 (Dividend)
; call doDiv ;19/ 4 = 4 R3(4 = quotient in eax, 3 = remainder in edx )
;
; Remove parameters by using ret 8 rather than just ret at the end of this function
doDiv ENDP

$parm1 EQU DWORD PTR [ebp + 8]   ;parameter 1
$parm2 EQU DWORD PTR [ebp + 12]  ;parameter 2

END Main