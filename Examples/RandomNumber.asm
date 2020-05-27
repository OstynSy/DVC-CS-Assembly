;Example of using the Irvine Randomize and RandomRange functions
;
;The loop directive will loop until ecx = 0.
;You should initialize ecx to the number of times to loop
;
;mov ecx,10
;loopTop:
;   ;code
;   ;code
;   loop loopTop

;Each time through the above loop ecx is automatically decremented
;and the loop repeats (jumps to L1) until ecx is 0.
;The above loop repeats 10 times.
;The jump cannot be more than -128 to +127 bytes.

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteChar PROTO         ;Irvine code for printing a single char to the console.
				        ;Character to be printed must be in the al register.

RandomRange PROTO       ; Returns an unsigned pseudo-random 32-bit integer
                        ; in EAX, between 0 and n-1. Input parameter:
                        ; EAX = n.

Randomize   PROTO       ; Re-seeds the random number generator with the current time
                        ; in seconds.

ReadDec  PROTO          ;Irvine code to read 32 bit decimal number from console
                        ;and store it into eax

WriteDec PROTO          ;Irvine code to write number stored in eax
                                          ;to console in decimal

WriteString PROTO	    ; Irvine code to write null-terminated string to output
                                          ; EDX points to string
                                          

WriteHex  PROTO         ;write 32 bit number stored in eax
                        ;to console in hex

       MessageBoxA PROTO,      ;MessageBoxA takes 4 parameters:
      handleOwn:DWORD,      ;1. window owner handle
         msgAdd:DWORD,      ;2. message address (zero terminated string)
     captionAdd:DWORD,      ;3. title address(zero terminated string)
        boxType:DWORD       ;4. which button(s) to display
;************************  Constants  ***************************

LF       equ     0Ah                   ; ASCII Line Feed

;************************DATA SEGMENT***************************

.data
    openingMsg      byte    "Generating 7 random numbers in the range 0-9",LF,LF,0
    endingMsg       byte    LF,"Hit any key to exit",0

;************************CODE SEGMENT****************************

.code

Main PROC

    mov     edx, offset openingMsg  ;edx points to opening message
    call    WriteString             ;write message to console
    call    Randomize               ;seed the random number generator
    mov     ecx, 7                  ;initialize counter

    ;for loop below will print 7 random numbers in the range 0-9
    
    jecxz   noLoop                  ;if ecx == 0 skip loop
    
	;note: if ecx is initialized to a value <= 0, the loop below will possibly execute 4 billion times.
   
loopTop:
    mov     eax, 10                 ;range to generate random numbers 0-9
    call    RandomRange             ;generate random number in range
                                    ;random number is in eax
    call    WriteDec                ;write random number (eax) to console
    mov     al,  LF                 ;al = 0ah line feed
    call    WriteChar               ;print line feed
    loop    loopTop                 ;repeat loop until ecx = 0 (decrement ecx and then check for 0)
    
noLoop:    

    mov		edx, offset endingMsg   ;edx points to ending message
    call	WriteString             ;print message

    call    ReadChar                ;pause execution
	INVOKE  ExitProcess,0           ;exit to dos: like C++ exit(0)

Main ENDP

END Main