;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Ostyn Sy
;  COMSC-260 Spring 2020
;  Date: 1/29/2020
;  Assignment # 1
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
;   adding and subtracting with operands and with mismatching sizes.
;  
;  Short description of what program does:
;
;   adds a binary, decimal, and hexidecimal values together and returns the value
;   ax = edx + cx - num2 + num1 - bl + bh
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

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD ;from Win32 api not Irvine

ReadChar PROTO                     ;Irvine code for getting a single char from keyboard
				                   ;Character is stored in the al register.
			                       ;Can be used to pause program execution until key is hit.


WriteHex PROTO                      ;Irvine function to write a hex number in EAX to the console


;************************DATA SEGMENT***************************

.data

   num2     word 0FDEBh     ;num2 word OFDEBh
   num1     word 321h       ;num1 word 321h

;************************CODE SEGMENT****************************

.code

main PROC

    ;initializes data
    mov     ebx, 0BBBBBBBBh  ; ebx = 0BBBBBBBBh
    mov     eax, 0AAAAAAAAh  ; eax = 0AAAAAAAAh
    mov     ecx, 0CCCCCCCCh  ; ecx = 0CCCCCCCCh
    mov     edx, 0F4D8DEE2h  ; edx = 0F4D8DEE2h
    mov     bh , 11110101b   ; bh  = 11110101b
    mov     bl , 249d        ; bl  = 249d
    mov     cx , 0FFA2h      ; cx  = 0FFA2h

    ;eax = edx + cx - num2 + num1 - bl + bh

    ;edx + cx
    ;edx and cx are not the same size, can not be added together
    movzx   eax, cx          ;movzx copies cx to ax and zeroes first half of eax
    add     edx, eax         ;adds eax to edx

    ;- num2
    ;eax and ecx not the same size         
    movzx   ecx, num2        ;copies num2 to ecx and zeroes first half of ecx
    sub     edx, ecx         ;subtracts ecx from edx

    ;+ num1
    ;eax not same size as num1
    movzx   ecx, num1        ;copies num1 to ecx and zeroes first half of ecx
    add     edx, ecx         ; adds edx and edx

    ;- bl
    ;eax and bl are not the same size
    movzx   ecx, bl          ;copies bl to ecx and zeroes first half of ecx
    sub     edx, ecx         ;subtracts ecx from edx

    ;+ bh
    ;eax and bh are not the same size
    movzx   ecx, bh          ;copies bh to ecx and zeroes first half of ecx
    add     edx, ecx         ;adds eax and edx

    mov     eax, edx         ;copies edx into eax for read

    call    WriteHex         ;writes in hexadecimal
    call    ReadChar         ;Pause program execution while user inputs a non-displayed char
	INVOKE	ExitProcess,0    ;exit to dos: like C++ exit(0)

    ;Answer: F4D8E3B6

main ENDP
END main