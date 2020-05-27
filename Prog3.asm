;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Ostyn Sy
;  COMSC-260 Spring 2020
;  Date: 2/26/2020
;  Assignment # 3
;  Version of Visual Studio used (2015)(2017)(2019):  2019
;  Did program compile? Yes
;  Did program produce correct results? Yes
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes
;  Is every line of code commented? Yes
;
;  Estimate of time in hours to complete assignment:  
;   1 hour 30mins
;
;  In a few words describe the main challenge in writing this program:
;  comparing, if-else loops, jumps, input, printing with ui, random generator, and macros.
;  
;  Short description of what program does:
;
;   A game that randomly generates a hex number between a-f and player has to guess. The program
;   will tell you if it is too high or too low. When player gets the correct answer it will prompt
;   the player if they want to play again.
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096                 ;allocate 4096 bytes (1000h) for stack

;************************MACROS********************************

mPrtStr  MACRO  arg1    ;arg1 is replaced by the name of string to be displayed
		 push edx				;save edx
         mov  edx, offset arg1  ;address of str to display should be in edx
         call WriteString       ;display 0 terminated string
         pop  edx				;restore edx
ENDM

;*************************PROTOTYPES*****************************
ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

RandomRange PROTO       ; Returns an unsigned pseudo-random 32-bit integer
                        ; in EAX, between 0 and n-1. Input parameter:
                        ; EAX = n.

Randomize   PROTO       ; Re-seeds the random number generator with the current time
                        ; in seconds.

ReadHex  PROTO          ;Irvine code to read 32 bit decimal number from console
                        ;and store it into eax

WriteString PROTO	    ; Irvine code to write null-terminated string to output
                                          ; EDX points to string                              

MessageBoxA PROTO,      ;MessageBoxA takes 4 parameters:
handleOwn:DWORD,        ;1. window owner handle
msgAdd:DWORD,           ;2. message address (zero terminated string)
captionAdd:DWORD,       ;3. title address(zero terminated string)
boxType:DWORD           ;4. which button(s) to display
;************************ Constants ****************************

   LF       equ   0Ah   ;ASCII Line Feed

;************************DATA SEGMENT***************************

.data

    caption     byte    "Program 3 by Ostyn Sy" ,LF, 0
    guess       byte    LF,"Guess a hex number in the range Ah - Fh." ,LF, 0
    input       byte    "Guess: " ,0
    highmsg     byte    "High! (Guess lower)" ,LF, 0
    lowmsg      byte    "Low! (Guess higher)" ,LF, 0
    correct     byte    "Correct! Play again?" , 0

;************************CODE SEGMENT****************************

.code

main PROC
    mPrtStr caption     ;print caption string
    call Randomize      ;seeds the random number generator

loop1:
    mPrtStr guess       ;print guess string
    mov eax, 6          ;initialize counter
    call RandomRange    ;generate random number in range
    add eax, 10         ;adds 10 to create hex number from A-F
    mov ebx, eax        ;moves eax into ebx

loop2:
    mPrtStr input       ;prints input string
    call ReadHex        ;reads input in hex
    cmp eax, ebx        ;compares eax and ebx
    ja ifhigh           ;if eax is above jump to ifhigh loop
    je Done             ;if eax equals ebx jump to done loop

iflow:                  ;loop that follows if neither ja or je are true
    mPrtStr lowmsg      ;prints lowmsg
    jmp loop2           ;jumps to loop2

ifhigh:
    mPrtStr highmsg     ;prints highmsg
    jmp loop2           ;jumps to loop2

Done:
    invoke  MessageBoxA ,   ;call MessageBoxA Win32 API function
                       0,   ;0 indicates no window owner
           addr correct,    ;address of message to be displayed in middle of msg box
           addr caption,    ;caption to be displayed in title bar of msg box
                       4    ;display yes, no buttons in msg box
                            ;(6 returned in eax if user hits yes)
                            ;(7 returned in eax if user hits no)
loopTop:
    cmp     eax, 6          ;Did the user choose yes(6)? No need to check for no (7)
    je      loop1           ;If yes, done. 

	INVOKE  ExitProcess,0   ;exit to dos: like C++ exit(0)

main ENDP
END main