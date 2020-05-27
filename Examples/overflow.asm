;The code below is an example of signed overflow 
;
;overflow can occur during addition, subtraction and multiplication
;
;You can test the overflow flag by using the jo (jump if overflow flag set)
;or jno (jump if the overflow flag is clear).

;overflow can be caused by 4 conditions:
;
;   1. if you add 2 positive numbers and get a negative number the overflow flag is set(positive overflow)
;      Positive overflow is an error condition which means the result is not correct.

;   2. if you add 2 negative  numbers and get a positive number the overflow flag is set(negative overflow)
;      Negative overflow is an error condition which means the result is not correct.

;   3. if you multiply 2 numbers using the single operand version of imul and 
;      the upper half of the product is not a signed extension of the lower part
;      the overflow and carry flags are set.
;      Overflow after using the single operand version of imul is not an error condition.
;      It just means the product would not fit in the lower half and you have to 
;      look at both halves to get the complete answer. 
;
;      For example if 2 8 bit signed numbers are
;      multiplied and the answer does not fit in al (part of the product is in ah) 
;      the overflow and carry flags are set.
;      If the product fits in al, ah will be a signed extension of al and the overflow flag will be clear.
;
;      If 2 16 bit signed numbers are multiplied and the product does not fit in 
;      ax (part of the product is in dx) the overflow and carry flags are set. 
;      If the product fits in ax, dx will be a signed extension of ax and the overflow flag will be clear.
;
;      If 2 32 bit signed numbers are multiplied and the product does not fit in 
;      eax (part of the product is in edx) the overflow and carry flags are set.
;      If the product fits in eax, edx will be a signed extension of eax and the overflow flag will be clear.

;   4. if you multiply 2 numbers using the two or three operand version of imul and
;      the product does not fit in the destination the overflow and carry flags are set.
;      If you get overflow after the 2 or 3 op version of imul this is an error condition
;      because it means part of the product is lost.



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

;************************CODE SEGMENT****************************

.code

main PROC

;addition results in overflow if the answer should be
;negative and it is positive and if the answer should
;be positive and it is negative

;Positive overflow (error condition)

    mov     eax, 7FFFFFFDh  ;eax = +2147483645
    add     eax, 5          ;eax = 80000002h = 2147483650 (-2147483646)
    jo      next            ;overflow occured since
                            ;answer negative when it
                            ;should be positive
    mov     ebx, 10         ;if jump not taken assign 10 to ebx

next:

;addition results in overflow if the answer should be
;negative and it is positive and if the answer should
;be positive and it is negative

;Negative overflow (error condition)

    mov     eax, 80000003h      ;EAX = 80000003 = -2147483645
    sub     eax, 5              ;EAX = 7FFFFFFE = +2147483646
    jo      next2               ;overflow occured since
                                ;answer positive when it
                                ;should be negative
    mov     ebx, 25             ;if jump not taken assign 25 to ebx

;The single op version of imul causes overflow if the upper half
;of the product is not a sign extension of the lower half

;Overflow after The single op version of imul is not an error condition.
;It just means the product would not fit in the lower half

next2:
    mov     eax, 7FFFFFFDh      ;2147483645
    mov     ecx, 2              ;ECX = 2
    imul    ecx                 ;edx       :   eax     = eax * ecx
                                ;00000000    FFFFFFFA = 4294967290
                                ;Overflow occured since product did not fit in eax alone and
                                ;edx is not a sign extension of eax
                                ;(leftmost bit of eax is a 1 and edx is not all 1's)
                                ;If product did fit the product would be -6 (FFFFFFFA) and
                                ;edx would be FFFFFFFFh
                                ;But the product is +4294967290(FFFFFFFA) and edx is 00000000h
    jo      next3               ;Jump taken since overflow occured
    mov     ebx,45              ;if jump not taken assign 45 to ebx

next3:
;another example example of single operand imul overflow (product does not fit in ax)

    mov     ax, 0E12h           ;ax = 0E12h
    mov     bx, 1C5h            ;bx = 1C5h
                                ;                 DX      AX
    imul    bx                  ;0E12h * 1C5h = 0018h   0E5DAh
    jo      next4               ;jump is taken since product did not fit in ax alone
                                ;(dx is not a signed extension of ax)
                                ;(leftmost bit of ax is a 0 and dx is not all 0's)
    mov     cl,45               ;if jump is not taken set cl to 45

next4:		
;example of single operand imul NO overflow (product fits in ax)
    mov     ax, 0FFFEh          ;ax = 0FFFEh = -2
    mov     bx, 10h             ;bx = 10h = 16
                                ;                 DX      AX
    imul    bx                  ;0FFFEh * 10h = FFFFh   0FFE0h    (-2 * 16 = -32)
    jo      next5               ;jump is not taken since product fits in ax
                                ;(dx is a signed extension of ax)
                                ;(leftmost bit of ax is 1 and dx is all 1's)
    mov     cl,55               ;if jump is not taken set cl to 55

next5:		
    
;Example of 2 operand version of imul where product does not fit in destination

    mov	    ax,-32000           ;ax = -32000
    imul	ax,2		        ; OF = 1, CF = 1 
    jo      next6               ;jump is taken since product does not fit in ax and OF flag is set
    mov     cl, 65              ;if jump is not taken set cl to 65 
    
next6:
    
;Example of 3 operand version of imul where product does not fit in destination

    ;example where product does not fit into the destination
    ;and the carry and overflow flags are set

    mov     ecx, 4              ;ecx = 4
    imul	ebx,ecx,-2000000000	; OF = 1, CF = 1
    jo      next7               ;jump taken since product does not in ebx and OF flag set
    mov     cl, 85              ;if jump is not taken set cl to 85
next7:    

    ;example of using not and neg to do two's complement
    ;not flips the bits (1's become 0's and 0's become 1's)

    mov     eax, 5              ;eax = 5
    not     eax                 ;flip the bits
    add     eax,1               ;add 1 - eax = -5

    ;neg flips the bits and adds 1
    neg     eax                 ;do two's complement on eax 
                                ;eax = 5

   	call	ReadChar		    ;pause execution
	INVOKE	ExitProcess,0	    ;exit to dos

main ENDP
END main