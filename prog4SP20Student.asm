;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Ostyn Sy
;  COMSC-260 Spring 2020
;  Date: 3/2/2020
;  Assignment # 4
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
;  pop, and push, function, array, full adder
;  
;  Short description of what program does:
;
;   It takes multiple arrays and applies a full adder to them giving us a sum and carry
;     
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

.STACK 4096            ;allocate 4096 bytes (1000h) for stack


;*******************MACROS********************************

;mPrtStr
;usage: mPrtStr nameOfString
;ie to display a 0 terminated string named message say:
;mPrtStr message

;Macro definition of mPrtStr. Wherever mPrtStr appears in the code
;it will  be replaced with 

mPrtStr  MACRO  arg1    ;arg1 is replaced by the name of string to be displayed
         push edx
         mov edx, offset arg1    ;address of str to display should be in dx
         call WriteString        ;display 0 terminated string
         pop edx
ENDM



;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code


WriteDec PROTO          ;Irvine code to write number stored in eax
                        ;to console in decimal

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
    inputAnum  byte 0,0,0,0,1,1,1,1
    inputBnum  byte 0,0,1,1,0,0,1,1
    carryInNum byte 0,1,0,1,0,1,0,1
    ARRAY_SIZE equ $-carryInNum         
    ;The '$' acts as a place maker where you are currently in memory
    ;which at the end of the carryInNum array.
    ;The ending address of the carryInNum array minus the beginning
    ;address equals the total bytes of the carryInNum array
    ;which is stored in the ARRAY_SIZE constant.
    ;NOTE: there can be no other variables between the 
    ;declation of the ARRAY_SIZE constant and the declaration
    ;of the array you are trying to calculate the size of.

    ;You can add LFs to the strings below for proper output line spacing
    ;but do not change anything between the quotes "do not change".

    ;I will be using a comparison program to compare your output to mine and
    ;the spacing must match exactly.


    ;Change my name to your name
    titleMsg            byte "Program 4 by Ostyn Sy",LF,0

    testingAdderMsg     byte LF," Testing Adder",0

    dashes              byte LF," ------------",0

    inputA              byte LF,LF,"   Input A: ",0
    inputB              byte LF,"   Input B: ",0
    carryin             byte LF,"  Carry in: ",0
    sum                 byte LF,"       Sum: ",0
    carryout            byte LF," Carry Out: ",0


    endingMsg           byte LF,LF,"Hit any key to exit!",0

;************************CODE SEGMENT****************************

.code

main PROC
    mPrtStr titleMsg                ;prints title message
    mPrtStr dashes                  ;prints dashes
    mPrtStr testingAdderMsg         ;prints adder message
    mPrtStr dashes                  ;prints dashes

    mov esi, 0                      ;initiates esi to 0

loopTop:
    cmp     esi  , ARRAY_SIZE       ;compare esi   to the total bytes of the array
    jae     done                    ;if we have processed all bytes then done
    
    mPrtStr inputA                  ;prints input a message
    movzx   eax,inputAnum[esi]      ;copy the byte at [testArray + esi  ] into eax
    call    WriteDec                ;print the number in eax

    mPrtStr inputB                  ;prints input b message
    movzx   eax,inputBnum[esi]      ;copy the byte at [testArray + esi  ] into eax
    call    WriteDec                ;print the number in eax

    mPrtStr carryin                 ;prints carryin message
    movzx   eax,carryInnum[esi]     ;copy the byte at [testArray + esi  ] into eax
    call    WriteDec                ;print the number in eax

    movzx   eax,inputAnum[esi]      ;copy the byte at [testArray + esi  ] into eax
    movzx   ebx,inputBnum[esi]      ;copy the byte at [testArray + esi  ] into eax
    movzx   ecx,carryInnum[esi]     ;copy the byte at [testArray + esi  ] into eax

    mPrtStr dashes                  ;prints dashes
    call    Adder                   ;calls the adder function

    mPrtStr sum                     ;prints sum message
    call    WriteDec                ;prints eac in dec

    mPrtStr carryout                ;prints carryout message
    mov     eax, ecx                ;stores ecx into eax
    call    WriteDec                ;prints eax in dec

    inc     esi                     ;esi   contains the offset from the beginning of the array. 
                                    ;add 1 to esi   so that testArray + esi   points to the 
                                    ;next element of the byte array 
    jmp     loopTop                 ;repeat

done:
    mPrtStr endingMsg               ;prints ending message
    call    ReadChar                ;pause execution
	INVOKE  ExitProcess,0           ;exit to dos: like C++ exit(0)

main ENDP


;************** Adder – Simulate a full Adder circuit  
;  Adder will simulate a full Adder circuit that will add together 
;  3 input bits and output a sum bit and a carry bit
;
;    Each input and output represents one bit.
;
;  Note: do not access the arrays in main directly in the Adder function. 
;        The data must be passed into this function via the required registers below.
;
;       ENTRY - EAX = input bit A 
;               EBX = input bit B
;               ECX = Cin (carry in bit)
;       EXIT  - EAX = sum bit
;               ECX = carry out bit
;       REGS  -  (list registers you use)
;
;       For the inputs in the input columns you should get the 
;       outputs in the output columns below:
;
;        input                  output
;     eax  ebx   ecx   =      eax     ecx
;      A  + B +  Cin   =      Sum     Cout
;      0  + 0 +   0    =       0        0
;      0  + 0 +   1    =       1        0
;      0  + 1 +   0    =       1        0
;      0  + 1 +   1    =       0        1
;      1  + 0 +   0    =       1        0
;      1  + 0 +   1    =       0        1
;      1  + 1 +   0    =       0        1
;      1  + 1 +   1    =       1        1
;
;   Note: the Adder function does not do any output. 
;         All the output is done in the main function.
;
;Do not change the name of the Adder function.
;
;See additional specifications for the Adder function on the 
;class web site.
;
;You should use AND, OR and XOR to simulate the full adder circuit.
;
;You should save any registers whose values change in this function 
;using push and restore them with pop.
;
;The saving of the registers should
;be done at the top of the function and the restoring should be done at
;the bottom of the function.
;
;Note: do not save any registers that return a value (ecx and eax).
;
;Each line of the Adder function must be commented and you must use the 
;usual indentation and formating like in the main function. SP20
;
;Don't forget the "ret" instruction at the end of the function
;
;Do not delete this comment block. FA19 Every function should have 
;a comment block before it describing the function. 


Adder proc
    push    ebx                     ;saves registers
    push    edx                     ;saves registers
    mov     edx, eax                ;creates a copy of eax into edx
    xor     eax, ebx                ;xor eax and ebx stores in eax
    and     ebx, edx                ;and ebx and edx store in ebx
    mov     edx, eax                ;stores a copy of eax into ebx
    xor     eax, ecx                ;xor eax and ecx and stores into eax
    and     ecx, edx                ;and ecx and edx store in ecx
    or      ecx, ebx                ;or ecx and ebx store in ecx
    pop     edx                     ;restores registers
    pop     ebx                     ;resotres registers

ret
Adder endp

END main