;Example of using the sub instruction

;SUB instruction - 
;
; General form: 
;       SUB operand1,operand2
; Description:
;         operand1 = operand1 - operand2
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

;************************DATA SEGMENT***************************

.data

    aNum    byte   0A7h
    bNum    byte   0Bh

;************************CODE SEGMENT****************************

.code

main PROC
 
    mov     ebx, 0C456CCh  ;ebx = 03456CCh
    mov     eax, 9ABC12h   ;eax = 9ABC12h
    mov     edx, 45234Bh   ;edx = 45234Bh
    mov     bl,  10000b    ;bl = 10000b = 10h = 16 (base 10)

    ;subtract bl from eax

    ;sub    eax, bl        ; illegal.  both operands must be same size

    ;subtract    eax, ebx is legal but ebx does not contain correct number to subtract
    ;solution: use the movzx instruction.
    ;movzx allows you to move a smaller operand into a larger one
    ;and zeros out the upper part of the larger operand

    movzx   edx, bl        ;copy bl to dl and zero out upper part of edx
    sub     eax, edx       ;eax = eax - edx
                           

    ;sub	ax,bl		   ; illegal.  both operands must be same size
    ;sub    eax, bx        ; illegal.  both operands must be same size

    mov     ebx, offset aNum    ;get address of var to look at var in memory
 

    ;sub     aNum, bNum    ; illegal. no memory to memory operations

    ;to subtract one variable from another first copy one of them to a register

    mov     al, bNum       ; copy var to a register
    sub     aNum, al       ; aNum = aNum - al
                           ; subtract al from aNum and store answer back in aNum
                           
    sub     aNum, 25       ; anum = anum - 25                   

	INVOKE	ExitProcess,0  ;exit to dos: like C++ exit(0)

main ENDP
END main