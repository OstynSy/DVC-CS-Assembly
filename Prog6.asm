;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Ostyn Sy
;  COMSC-260 Spring 2020
;  Date: 4/13/2020
;  Assignment # 6
;  Version of Visual Studio used (2015)(2017)(2019):  2019
;  Did program compile? Yes
;  Did program produce correct results? yes
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes
;  Is every line of code commented? Yes
;
;  Estimate of time in hours to complete assignment:  
;  5 hours
;
;  In a few words describe the main challenge in writing this program:
;  pop, and push, function, arrays, rotating and shifting bits, binary oeprators.
;  
;  Short description of what program does:
;
;   shifts bits around if cl is equal to 1. Testing the shifter function. As well as converting
;   binary to char and printing them out with dspbin  
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************


.386                    ;identifies minimum CPU for this program

.MODEL flat,stdcall     ;flat - protected mode program
                        ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096              ;allocate 4096 bytes (1000h) for stack

mPrtChar  MACRO  arg1    ;arg1 is replaced by the name of character to be displayed
         push eax        ;save eax
         mov al, arg1    ;character to display should be in al
         call WriteChar  ;display character in al
         pop eax         ;restore eax
ENDM


mPrtStr macro   arg1          ;arg1 is replaced by the name of character to be displayed
         push edx             ;save eax
         mov edx, offset arg1 ;character to display should be in al
         call WriteString     ;display character in al
         pop edx              ;restore eax
ENDM

;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteChar PROTO         ;Irvine code to write character stored in al to console

WriteString PROTO		; write null-terminated string to output
                        ;EDX points to string

WriteDec PROTO          ;Irvine code for writing a dec number to the console

;************************  Constants  ***************************

LF       equ     0Ah                   ; ASCII Line Feed

;************************DATA SEGMENT***************************

.data

    ;inputs for testing the Shifter function
    inputA  byte 0,1,0,1,0,1,0,1
    inputB  byte 0,0,1,1,0,0,1,1
    inputC  byte 1,1,1,1,0,0,0,0
    ARRAY_SIZE equ $ - inputC         

    ;numbers for testing DoLeftShift
    nums   dword 10101010101010101010101010101010b
           dword 01010101010101010101010101010101b
           dword 11010101011101011101010101010111b
    NUM_SIZE EQU $-nums               ;total bytes in the nums array

    NUM_OF_BITS EQU SIZEOF(DWORD) * 8 ;Total bits for a dword

    ;You can add LFs to the strings below for proper output line spacing
    ;but do not change anything between the quotes "do not change".
    ;You can also combine messages where appropriate.

    ;I will be using a comparison program to compare your output to mine and
    ;the spacing must match exactly.

    endingMsg           byte LF,"Hit any key to exit!",0

    ;Change my name to your name
    titleMsg            byte "Program 6 by Ostyn Sy",LF,0

    testingShifterMsg   byte LF,"Testing Shifter",LF,0
    enabledMsg          byte "(Shifting enabled C = 1, Disabled C = 0)",LF,0

    header              byte  "A B C | Output",LF,0

    dashes              byte "------------------------------------",LF,0

    testingDspBin       byte LF,"Testing DpsBin",LF,0

    space               byte " ",0

    bar                 byte " | ",0

;************************CODE SEGMENT****************************

.code

Main PROC

;start student code here
;See the pdf file for the pseudo code for the main function

    mPrtStr  titleMsg                ;prints title msg
    mPrtStr  testingShifterMsg       ;pritns testing shifter msg
    mPrtStr  enabledMsg              ;prints enabled msg
    mPrtStr  dashes                  ;prints dashes
    mPrtStr  header                  ;prints header

    mov      esi, 0                  ;moves 0 into esi

LoopTop1:                            ;start of loop
    cmp      esi, ARRAY_SIZE         ;compares esi to the array size
    jae      LoopEnd1                ;if esi is larger or equal to array size then jump to loop end

    movzx    eax, inputA[esi]        ;moves inputA at esi into eax
    call     WriteDec                ;prints out eax as a decimal
    mPrtChar space                   ;prints a space

    movzx    eax, inputB[esi]        ;moves inputB at esi int eax
    call     WriteDec                ;prints eax as a decimal
    mPrtChar space                   ;prints out a space

    movzx    eax, inputC[esi]        ;moves inputc at esi into eax
    call     WriteDec                ;prints out eax as a decimal
    
    mPrtStr  bar                     ;prints out the bar string
    
    mov      al, inputA[esi]         ;moves inputA at esi into al
    mov      bl, inputB[esi]         ;moves inputB at esi into bl
    mov      cl, inputC[esi]         ;moves inputC at esi into cl
    mPrtChar space                   ;prints out the character space
    call     Shifter                 ;calls the shifter function
    call     WriteDec                ;prints out the char as a decimal
    mPrtChar LF                      ;prints linefeed

    inc      esi                     ;increments esi by 1
    jmp      LoopTop1                ;loops back to top of loop

LoopEnd1:                            ;end of loop

    mPrtStr  testingDspBin           ;prints out testing dspbin
    mPrtStr  dashes                  ;prints out dashes
    mov      esi, 0                  ;moves esp to 0

LoopTop2:                            ;start of loop2
    cmp      esi, NUM_SIZE           ;Compares esi with numsize
    jae      LoopEnd2                ;if esi is equal or above numsize then loop will end
    
    mov      eax, nums[esi]          ;moves nums at esi into eax
    call     DspBin                  ;calls DspBin function
    mPrtChar LF                      ;prints a line feed

    add      esi,4                   ;adds 4 to esi        
    jmp      LoopTop2                ;jumps to the top of loop 2

LoopEnd2:

    mPrtStr  endingMsg               ;prints ending message
    call     ReadChar                ;pause execution
	INVOKE   ExitProcess,0           ;exit to dos: like C++ exit(0)

Main ENDP



;************** Shifter – Simulate a partial shifter circuit per the circuit diagram in the pdf file.  
;  Shifter will simulate part of a shifter circuit that will input 
;  3 bits and output a shifted or non-shifted bit.
;
;
;   CL--------------------------
;              |               |
;              |               |
;             NOT    BL        |     AL
;              |     |         |     |
;              --AND--         --AND--
;                 |                |
;                 --------OR--------
;                          |
;                          AL
;
; NOTE: To implement the NOT gate use XOR to flip a single bit.
;
; Each input and output represents one bit.
;
;  Note: do not access the arrays in main directly in the Adder function. 
;        The data must be passed into this function via the required registers below.
;
;       ENTRY - AL = input bit A 
;               BL = input bit B
;               CL = enable (1) or disable (0) shift
;       EXIT  - AL = shifted or non-shifted bit
;       REGS  -  (list registers you use)
;
;       For the inputs in the input columns you should get the 
;       output in the output column below.
;
;The chart below shows the output for 
;the given inputs if shifting is enabled (cl = 1)
;If shift is enabled (cl = 1) then output should be the shifted bit (al).
;In the table below shifting is enabled (cl = 1)
;
;        input      output
;     al   bl  cl |   al 
;--------------------------
;      0   0   1  |   0 
;      1   0   1  |   1 
;      0   1   1  |   0 
;      1   1   1  |   1   
;
;The chart below shows the output for 
;the given inputs if shifting is disabled (cl = 0)
;If shift is disabled (cl = 0) then the output should be the non-shifted bit (B).

;        input      output
;     al   bl  cl |   al 
;--------------------------
;      0   0   0  |   0 
;      1   0   0  |   0 
;      0   1   0  |   1 
;      1   1   0  |   1   

;
;Note: the Shifter function does not do any output to the console.All the output is done in the main function
;
;Do not access the arrays in main directly in the shifter function. 
;The data must be passed into this function via the required registers.
;
;Do not change the name of the Shifter function.
;
;See additional specifications for the Shifter function on the 
;class web site.
;
;You should use AND, OR and XOR to simulate the shifter circuit.
;
;Note: to flip a single bit use XOR do not use NOT.
;
;You should save any registers whose values change in this function 
;using push and restore them with pop.
;
;The saving of the registers should
;be done at the top of the function and the restoring should be done at
;the bottom of the function.
;
;Note: do not save any registers that return a value (eax).
;
;Each line of this function must be commented and you must use the 
;usual indentation and formating like in the main function.
;
;Don't forget the "ret" instruction at the end of the function
;
;Do not delete this comment block. Every function should have 
;a comment block before it describing the function. FA17

;shifts the left most byte into the carry flag depending if cl is enabled or not
Shifter proc

    push     ecx                     ;pushes ecx onto the stack

    and      al, cl                  ;ands al and cl and stores in al
    xor      cl, 1                   ;xor cl and 1 and saves into cl
    and      cl, bl                  ;ands cl and bl store in cl
    or       al, cl                  ;or al and cl and stores into al
    
    pop      ecx                     ;pops ecx off the stack
   
    ret                              ;returns
Shifter endp

;************** DspBin - display a Dword in binary including leading zeros
;
;       ENTRY – EAX contains operand1, the number to print in binary
;
;       For Example if parm1 contained contained AC123h the following would print:
;                00000000000010101100000100100011
;       For Example if parm1 contained 0005h the following would print:
;                00000000000000000000000000000101
;
;       EXIT  - None
;       REGS  - List registers you use
;
; to call DspBin:
;               mov eax, 1111000110100b    ;number to print in binary is in eax
;               call DspBin            ; 00000000000000000001111000110100 should print
;     
;       Note: leading zeros do print
;       Note; at the end of this function use ret 4 (instead of just ret) to remove the parameter from the stack
;                 Do not use add esp, 4 in the main function.
;--------------

    ;You should have a loop that will do the following:

    ;The loop should execute NUM_OF_BITS times(32 times) times so that all binary digits will print including leading 0s.

    ;You should use the NUM_OF_BITS constant as the terminating loop condition and not hard code it.
    
    ;You should start at bit 31 down to and including bit 0 so that the digits will 
    ;   print in the correct order, left to right.
    ;Each iteration of the loop will print one binary digit.

    ;Each time through the loop you should do the following:
    
    ;clear al to 0
    ;You should use a shift instruction to shift the bit starting at position 31 to the carry flag 
    ;   then use a rotate command to copy the carry flag to the right end of al.

    ;Then Use the OR instruction to convert the 1 or 0 to a character ('1' or '0').
    
    ;then print it with WriteChar.

    ;You should keep processing the number until all 32 bits have been printed from bit 31 to bit 0. 
    
    ;Efficiency counts.

    ;DspBin just prints the raw binary number.

    ;No credit will be given for a solution that uses mul, imul, div or idiv. 
    ;
    ;You should save any registers whose values change in this function 
    ;using push and restore them with pop.
    ;
    ;The saving of the registers should
    ;be done at the top of the function and the restoring should be done at
    ;the bottom of the function.
    ;
    ;Each line of this function must be commented and you must use the 
    ;usual indentation and formating like in the main function.
    ;
    ;
    ;Do not delete this comment block. Every function should have 
    ;a comment block before it describing the function. FA17

;DspBin prints a binary number in 32bits
DspBin proc
    push     eax                     ;pushes eax onto the stack
    push     ebx                     ;pushes ebx onto the stack
    push     ecx                     ;pushes ecx onto the stack

    mov      ebx, eax                ;moves eax into ebx
    mov      ecx, 0                  ;moves 0 into ecx (counter for loop)
    
STARTLOOP:                           ;start of loop
    cmp      ecx, NUM_OF_BITS        ;compares ecx with num of bits
    jae      ENDLOOP                 ;if ecx is above or equal to num of bits then jump to endloop

    mov      al, 0                   ;mov 0 into al
    shl      ebx, 1                  ;shift ebx left by 1
    rcl      al, 1                   ;rotates the carry flag into the right of al
    or       al, 00110000b           ;or al with 00110000b to convert binary to char
    call     WriteChar               ;write the character out

    inc      ecx                     ;increment ecx
    jmp      STARTLOOP               ;jump to startloop

ENDLOOP:
    pop      ecx                     ;removes ecx from stack
    pop      ebx                     ;removes ebx from stack
    pop      eax                     ;removes eax from stack

    ret                              ;returns
DspBin endp

END Main