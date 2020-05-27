;The code below is an example of using imul
;Adopted from the idiv example by Gary Montante
;The 2 operand and 3 operand examples are taken from
;the Irvine text book.

; Signed Multiplication
;
; Use IMUL for signed multiplication
; 
; IMUL	operand (single operand version)
; Description (signed Integer MULtiply):
; If operand is 8 bits then
;     AX = AL * operand8
; If operand is  16 bits then
;     DX:AX = AX * operand16
; If operand is 32 bits then
;     EDX:EAX = EAX * operand32
; Allowable operands:
;     reg  -  mem
; Flags changed:
;     O,C … (S, Z, A, and P are undefined after this operation)
;     Products too large to fit in 8, 16 or 32 bits set the overflow and carry flags
; Note:
;     All operands are treated as signed binary integers by IMUL 
;     whereas MUL treats all operands as unsigned.  MUL only has one format.  
;     To multiply  byte * word, must use CBW.
; Warning:
;      Signed (±) integer multiplication and unsigned integer multiplication do 
;      not necessarily produce the same results.  For example,
; 	  FFH  mul 12H = 11EEH        but     FFH  imul 12H = FFEEH.
;             (255 *  18   = 4590)             (-1  *   18   =  -18)
;             
;   	  FFFF  mul FFFE = FFFD0002      but       FFFF  imul FFFE =  2.
;         (65535 *  65534  = 4294770690)            (-1    *     -2  =  2)


;IMUL also comes in a 2 operand version and 3 operand version
;
; The 2 operand version is as follows: (product stored in first operand)
; (op1 = op1 * op2)
;first operand must be a register,
;the second operand can be a reg, mem, or immediate
;
; For 16 bits:
;   imul reg16 , reg16/mem16
;   imul reg16 , imm8
;   imul reg16 , imm16
;
; for 32 bits:
;   imul reg32 , reg32/mem32
;   imul reg32 , imm8
;   imul reg32 , imm32
;
; The 3 operand version is as follows: (product stored in first operand)
; op1 = op2 * op3
;the first operand must be a register
;the second operand can be a reg or mem
;the third operand must be an immediate value
;
; For 16 bits:
;   imul reg16 , reg16/mem16 ,imm8
;   imul reg16 , reg16/mem16 , imm16
; 
; for 32 bits:
;   imul reg32 , reg32/mem32 , imm8
;   imul reg32 , reg32/mem32 , imm32
;
; Note: for the 2 and 3 operand verisons of imul, if the product does not fit
; in the destinatinon, the CF and OF are set.
;

; MOVSX – Copy byte or word into a larger operand and sign extends into the upper half of the destination
; 
; movsx for signed numbers is the counterpart of movzx for unsigned numbers.
; 
; Examples:
; 	MOV	 al,7fh  ;AL = 7fh ([0]1111111) 
; 	MOVSX bx,al   ;after MOVSX, BH=00H (00000000),BL= 7fh (01111111) 
;                    ;so BX=007F (00000000[0]1111111)
; 	al was copied to bl and the sign bit(0) was extended into bh
; 
; 	MOV   cx,-1023	;CX=0FC01h ([1]111110000000001)
; 	MOVSX ebx, cx  ;ebx = FFFFFC01h (1111111111111111[1]111110000000001)
; 	cx was copied to bx and the sign bit (1) was extended into the upper part of ebx

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

;the following are defined as decimal numbers
        byte1   sbyte         -122  ; 86h
        byte2	sbyte	        20  ; 14h
        byte3   sbyte           -4  ; FBh
        word1	sword	      -247  ; FF09h
        word2	sword	        85  ; 0055h
        word4	SWORD	        4
        dword4	SDWORD	        4


;************************CODE SEGMENT****************************

.code

main PROC

;Single operand version of imul


;---- byte * byte
    ;test register operand: imul register8
    mov	    al,byte1        ;al = 86h (-122)
    mov     bl,byte2        ;al = 14h  (20)		
    imul    bl              ;ax= al*bl = 88h * 14h = -122 * 20 = -2440(F678h)
    ;test variable operand: imul memory8
    mov     al,byte2        ;al = 14h (20)
    imul    byte3	        ;ax= al*byte3 = 14h * FBh = 20 * -4 = -80(FFB0h)

;---- word*word
    ;test register operand: imul register16
    mov	    ax,word1        ;ax = FF09h
    mov     cx,word2        ;cx = 0055h
    imul	cx		        ;dx:ax pair= ax*cx 
;                                          = FF09h * 0055h 
;                                          = -247  *  85
;                               answer in     dx    ax
;                                          = FFFF  ADFD (-20,995)
    ;test variable operand: imul memory16
    mov	    ax,word1        ; ax = FF09h
    imul	word2	        ;dx:ax pair= ax*word2 = FF09h * 0055h = same as above

;---- byte * word (convert byte to word, then multiply)
;use movsx to copy a smaller signed number to a larger one (see notes above)
    movsx   ax,byte1        ;AX = byte1 (86h) converted to word (2 bytes)
                            ;AX = FF 86h
    imul	word1	        ;dx:ax pair= ax*word1 
;                                          = FF86h * FF09h
;                                          = -122  * -247
;                               answer in     dx    ax
;                                          = 0000  75B6h = (30,134)

;---- dword*dword
    mov     eax, 0ABCDEF12h ;EAX = ABCDEF12h
    mov     ebx, 012345678H ;EBX = 12345678h
    imul    ebx             ;edx:eax pair= eax*ebx
                            ;            = ABCDEF12h * 12345678h
                            ;            = FA034433 8A801C70h

;error:the single operand version of imul does not allow an immediate operand 
;    imul  12h       ;illegal since immediate operand not allowed

;---- word*dword (convert word to dword then multiply)
;use movsx to copy a smaller signed number to a larger one (see notes above)

    movsx   eax, word1      ; EAX = -247
    mov     ebx, 10         ; EBX = 10
    imul    ebx             ; edx:eax pair= eax*ebx
                            ;             = -247 * 10
                            ;                EDX           EAX
                            ;             = FFFFFFFF    FFFFF65A   (-2470)

;Examples of 2 operand version of imul (From Irvine, ch. 7.4.2)
;operand1 = operand1 * operand2
;
;first operand must be a register,
;the second operand can be a reg, mem, or immediate

    mov	    ax,-16          ; AX = -16
    mov	    bx,2	        ; BX = 2
    imul	bx,ax		    ; BX = BX * AX = -32
    imul	bx,2		    ; BX = BX * 2  = -64
    imul	bx,word4	    ; BX = BX * word4 (4) = -256
  	   	
    mov	    eax,-16         ; EAX = -16
    mov	    ebx,2           ; EBX = 2
    imul	ebx,eax		    ; EBX = EBX * EAX = -32
    imul	ebx,2		    ; EBX = EBX * 2 = -64
    imul	ebx,dword4	    ; EBX = EBX * dword4 (4) = -256

    ;example where product does not fit into the destination
    ;and the carry and overflow flags are set

    mov	    ax,-32000       ; AX = -32000
    imul	ax,2			; OF = 1, CF = 1 

;Examples of 3 operand version of imul (From Irvine, ch. 7.4.2)
;operand1 = operand2 * operand3
;
;the first operand must be a register
;the second operand can be a reg or mem
;the third operand must be an immediate value

    imul	bx,word4,-16	; BX = word4(4) * -16 = = -64
    imul	ebx,dword4,-16	; EBX = dword4(4) * -16 = -64
    mov     eax,2           ;eax = 2
    
    imul    ebx,eax,3
    ;imul    dword4,eax,3   ;error since 1st operand must be a reg not mem
    ;imul    ebx,4,5        ;error since 2nd operand must be reg or mem not immediate
    ;imul    ebx,eax,dword4 ;error since 3 operand must be immediate not mem

    ;example where product does not fit into the destination
    ;and the carry and overflow flags are set

    imul	ebx,dword4,-2000000000	; OF = 1, CF = 1


    
   	call	ReadChar		;pause execution
	INVOKE	ExitProcess,0	;exit to dos

main ENDP
END main