;The code below is an example of using AND, OR, XOR
;
; The operands to AND, OR, XOR can be:

;op1  op2    example
;reg, reg   and al,bl
;reg, mem   or  dl,num
;mem, reg   xor num, cl
;reg, imm   and al, 1001b
;mem, imm   or num, 1001b

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack


;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

DumpRegs PROTO  ;Irvine code for printing registers to the screen

ReadChar PROTO  ;Irvine code for getting a single char from keyboard
				;Character is stored in the al register.
			    ;Can be used to pause program execution until key is hit.

;************************DATA SEGMENT***************************

.data

    num byte 00000101b
;************************CODE SEGMENT****************************

.code

main PROC

    ;**********************************************************
    ;AND

    mov     al, 10000111b   ;al =  1000 0111 (87h)
    and     al, num         ;and   0000 0101 
                            ;al =  0000 0101 (5)
    ;**********************************************************

    ;OR
    
    mov     bl, 00000101b   ;bl = 0000 0101
    mov     al, 10000010b   ;al = 1000 0010
    or      al, bl          ;al = 1000 0111 (87h)
                             
    
                          
    ;**********************************************************
                            
    ;XOR
    
 
    mov     al, 10000110b   ;al = 1000 0110 (87h)
    xor     al, 00000101b   ;xor  0000 0101 
                            ;al = 1000 0011 (83h)
  
   	call	ReadChar		;pause execution
	INVOKE	ExitProcess,0	;exit to dos

main ENDP
END main