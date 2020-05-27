;Example of passing parameters on the stack


; To allocate memory for a local variable in a function the following setup 
; and cleanup code is required at the top and bottom of your function.

;Note: in some cases ESP and EBP may be the same but to avoid problems and to write consistent code,
;aways follow the order of the code below.
;
; AddFcn  PROC
;**********required code at top**********
;       push	ebp	               
;	    mov	    ebp,esp	     
;
;       add code to save registers if any used by function by pushing them onto stack
;       except do not save a register that returns a value to the caller
;
;**********end required code at top of function
;
; main part of function that processes data
;
;**********required code at bottom of funtion**********
;
;   add code to restore registers if any that were saved at the top 
;   except ebp which is restored below (use pop to restore)
;
;    pop     ebp                 ;restore ebp
;	 ret                        
;AddFcn ENDP

;

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack


;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

ReadChar PROTO  ;Irvine code for getting a single char from keyboard
				;Character is stored in the al register.
			    ;Can be used to pause program execution until key is hit.

;************************DATA SEGMENT***************************

.data

        varX	dword 34h	;parm1
        varY	dword 21h	;parm2  

;************************CODE SEGMENT****************************

.code

main PROC

    mov     ebp,0BBBBBBBBh	    ;EBP = some junk for the demo

    ;push parameters on stack before calling function
    ;always push operand2 first

    push    varY		        ;copy parm2 to stack: 00000021h
    push    varX		        ;copy parm1 to stack: 00000034h
    call	AddFcn              ;returns EAX=parm1+parm2=00000055h
    add	    esp,8	            ;remove two dwords from the stack
                                ;if you use ret 8 in function then
                                ;this line is not needed
                                ;(this is known as the 'C' calling convention
                                ;which allows for a variable number of arguments
                                ;like printf since caller knows the num of args)

    ;push parameters on stack before calling function
    ;always push operand2 first

    push    12h		            ;copy parm2 to stack: 00000012h
    push    16h		            ;copy parm1 to stack: 00000016h

    call	AddFcnB             ;returns EAX=parm1+parm2=00000028h
                                ;add esp 8 not needed since ret 8 in AddFcnB
                                ;(this is known as the stdcall calling convention) 

	call	ReadChar		    ;pause execution
	INVOKE	ExitProcess,0	    ;exit to dos

main ENDP

;******************** AddFcn – compute sum
;           ENTRY – first “word parm1”, then “word parm2” on stk
;           EXIT  - EAX = parm1+parm2
;           REGS  - EAX,FLAGS (all others preserved)

AddFcn  PROC

;-------------------  Stack usage
;Note: stack grows from high to low memory

        ;The stack looks like the following
 ;low mem        ;orig ebp  [ebp + 0]   (BBBBBBBBh  after push ebp)                 
                 ;ret addr  [ebp + 4]     
 ;                parm1     [ebp + 8]   0000000034h
 ;high mem       ;parm2     [ebp + 12]	0000000021h

;in order to keep track of the correct adjustments for the addresses of the 
;parameters and local variables on the stack always do the following
;2 instructions in the following order: push ebp; mov ebp,esp 


    push	ebp	                ;Save original value of EBP on stack
	mov	    ebp,esp	            ;EBP= address of original EBP on stack (00f8)
			                    ; Aim at a fixed location on the stack so
			                    ;   we can access other stack locations
                                ;   relative to this location!

    ;brackets [ ] below are needed to dereference the address
    ;this is like *ptr in C++
    mov     eax, [ebp + 8]      ; eax = 34h
    add     eax, [ebp + 12]     ; eax = 34h + 21h = 55h

	pop     ebp                 ;restore ebp

	ret
    ;ret     8                  ;option for removing 2 dword parameters from stack
                                ;can use this instead of add esp, 8 in main
        				
AddFcn ENDP

;******************** AddFcn – compute sum
;           ENTRY – first “word parm1”, then “word parm2” on stk
;           EXIT  - EAX = parm1+parm2
;           REGS  - EAX,FLAGS (all others preserved)

;create user friendly constants to access parameters on stack

$parm1 EQU DWORD PTR [ebp + 8]   ;parameter 1
$parm2 EQU DWORD PTR [ebp + 12]  ;parameter 2

AddFcnB  PROC

;-------------------  Stack usage
        ;The stack looks like the following
        ;low memory    orig ebp  [ebp + 0]    BBBBBBBBh after push ebp
        ;              ret addr  [ebp + 4]    
        ;              parm1     [ebp + 8]    00000016h
        ;high memory   parm2     [ebp + 12]	  00000012h



;in order to keep track of the correct adjustments for the addresses of the 
;parameters and local variables on the stack always do the following
;2 instructions in the following order: push ebp; mov ebp,esp 


    push	ebp	                ;Save original value of EBP on stack
	mov	    ebp,esp	            ;EBP= address of original EBP on stack (00f8)
			                    ; Aim at a fixed location on the stack so
			                    ;   we can access other stack locations
                                ;   relative to this location!
   
    mov     eax, $parm1         ; eax = 16h (parameter 1)
    add     eax, $parm2         ; eax = 16h  (parameter 1)+ 12h (parameter 2) = 28h

    ;without the constants the above lines would be:
    ;mov     eax, [ebp + 8]     ; eax = 16h
    ;add     eax, [ebp + 12]    ; eax = 16h + 12h = 28h

	pop     ebp                 ;restore ebp
    ret     8                   ;ret 8 removes 2 dword parameters from stack
                                ;can use this instead of add esp 8 in main
        				
AddFcnB ENDP

END main