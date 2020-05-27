;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: 
;  COMSC-260 Fall 2019
;  Date:
;  Assignment #
;  Version of Visual Studio used (2015)(2017)(2019):  
;  Did program compile? Yes/No
;  Did program produce correct results? Yes/No
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes/No
;  Is every line of code commented? Yes/No
;
;  Estimate of time in hours to complete assignment:  
;
;  In a few words describe the main challenge in writing this program:
;  
;  Short description of what program does:
;
;
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************


;Example of using the add instruction

;add instruction - 
;
; General form: 
;       ADD operand1,operand2
; Description:
;         operand1 = operand1 + operand2
; Allowable operands:
;         reg,reg  -  reg,mem  -  reg,immed
;         mem,reg  -  mem,immed
; Flags changed:
;         O,S,Z,A,P,C
; Note:
;         Both operands must be of the same size.  
;         Can be unsigned or signed binary integers.


.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

ReadChar PROTO                     ;Irvine code for getting a single char from keyboard
				                   ;Character is stored in the al register.
			                       ;Can be used to pause program execution until key is hit.


WriteHex PROTO                      ;Irvine function to write a hex number in EAX to the console


;************************DATA SEGMENT***************************

.data

    aNum    byte   7h
    bNum    byte   1h

;************************CODE SEGMENT****************************

.code

main PROC

    mov     ebx, 0C456CCh   ;ebx = 0C456CCh
    mov     eax, 9ABC12h    ;eax = 9ABC12h
    mov     edx, 45234Bh    ;edx = 45234Bh
    mov     bl,  10000b     ;bl = 10000b = 10h = 16 (base 10)

    ;add bl to eax

    ;add    eax, bl         ; illegal.  both operands must be same size

    ;add    eax, ebx is legal but ebx does not contain correct number to add
    ;solution: use the movzx instruction
    ;movzx allows you to move a smaller operand into a larger one
    ;and zeros out the upper part of the larger operand

    movzx   edx, bl         ;copy bl to dl and zero
						    ; out upper part of edx
    add     eax, edx        ;add edx to eax

    call    WriteHex        ;Print number in eax to the console in hex

    ;add	ax,  bl		    ; illegal.  both operands must be same size
    ;add    eax, bx         ; illegal.  both operands must be same size
    
    ;Problem if sum will not fit into destination
    mov     bx, 0ffffh      ;bx = fffffh. ffffh is the largest 2 byte number
    mov     dx, 1ch         ;dx = 1ch
    add     dx,bx           ;error: sum will not fit into dx (FFFF+1C = 1001Bh but edx contains only 1bh)
    
    ;solution if sum will not fit into destination: copy both operands to a larger type using movzx
    ;then do addition
    
    mov     dx, 1ch         ;reinitialize dx to 1ch
    movzx   ecx, dx         ;copy dx to cx and zero out the upper part of ecx
    movzx   esi, bx         ;copy bx to si and zero out the upper part of esi
    add     ecx,esi         ;add esi to ecx: ffffh+1cH =1001bh 

    ;add 2 variables
    
    mov     ebx, offset bNum;get address of bNum to look at bNum in memory window
 
    ;add     aNum, bNum; illegal. no memory to memory operations

    ;to add one variable to another first copy one of them to a register

    mov     al, aNum        ; copy aNum to a register
    add     bNum, al        ; add al to bNum and store answer back in bNum

    call    ReadChar        ; Pause program execution while user inputs a non-displayed char
	INVOKE	ExitProcess,0   ;exit to dos: like C++ exit(0)

main ENDP
END main