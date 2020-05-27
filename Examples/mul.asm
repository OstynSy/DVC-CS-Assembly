;mul (multiply) instruction 
;
;(From class notes by Gary Montante and Paul Lou)
;(Modified by Fred Kennedy for 32 bits and Irvine Library)
;
; General form
;         MUL operand
; Description (unsigned MULtiply):
;   If operand is 8 bits then  AX = AL * operand8
;   If operand is  16 bits then DX:AX pair = AX * operand16
;   If operand is  32 bits then EDX:EAX pair = EAX * operand32
; Allowable operands:
;   reg  -  mem
; Flags changed:
;   O,C
; Note:
;   Both operands are treated as unsigned binary integers.
;   OF and CF set if result does not fit in AL alone (byte operand)
;     or AX alone (word operand) or EAX alone (dword operand).
;
; example   |op2   | op1 |     product
;--------------------------------------
; mul ebx   |dword | eax |     edx:eax
; mul cx    | word |  ax |      dx:ax
; mul cl    | byte |  al |      ax

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack


;*************************PROTOTYPES*****************************

ExitProcess PROTO,
    dwExitCode:DWORD    ;from Win32 api not Irvine to exit to dos with exit code

ReadChar PROTO          ;Irvine code for getting a single char from keyboard
                        ;Character is stored in the al register.
                        ;Can be used to pause program execution until key is hit.


;************************DATA SEGMENT***************************

.data

    byte1	byte	0F7h        ;byte1 = 0F7h
    byte2   byte    07h         ;byte2 = 07h
    word1	word	1234h       ;word1 = 1234h
    word2	word	0A274h      ;word2 = 0A274h
    dword1  dword   1234abcdh   ;dword1 = 1234abcdh
        
.code

Main PROC


;---- byte * byte
    ;test register operand: mul register8
    mov	    al,byte1        ;al = 0F7h
    mov     bl,23h          ;bl = 23h  		
    mul     bl              ;ax= al*bl = F7h * 23h = 21C5h
                            ;OF and CF set since product does not fit in al alone

    ;test variable operand: mul memory8
    mov     al,23h          ;al = 23h
    mul     byte2	        ;ax= al*byte2 = 23h * 07h = 00F5h
                            ;OF and CF cleared since product does fit in al

;---- word*word
    ;test register operand: mul register16
    mov	    ax,word1        ;ax = 1234h
    mov     cx,0A274h       ;cx = 0A274h
    mul	    cx		        ;dx:ax pair= ax*cx 
                            ;          = 1234h * 0A274h 
                            ;   answer in     dx    ax
                            ;               = 0B8D  2790
                            ;   OF and CF set since product does not fit in ax alone

    ;test variable operand: mul memory16
    mov	    ax,word1        ; ax = 1234h
    mul	    word2	        ;dx:ax pair= ax*word2 = 1234h * 0A274h = same as above
                            ;   OF and CF set since product does not fit in ax alone

;---- byte * word (convert byte to word, then multiply)
    movzx   ax,byte1        ;changed byte F7 to word 00F7
    mul	    word1	        ;dx:ax pair = ax*word1 
                            ;           = 00F7h * 1234h
                            ;answer in     dx    ax
                            ;           = 0011  902C 
                            ;   OF and CF set since product does not fit in ax alone

;---- dword*dword
    ;test register operand: mul register32
    mov	    eax,dword1      ;eax = 1234abcdh
    mov     ecx,0abcdef12h  ;ecx = 0abcdef12h
    mul	    ecx		        ;edx:eax pair  =    eax     *    ecx 
                            ;              = 11234abcdh * abcdef12h 
                            ; answer in     edx        eax
                            ;            = 0C37D3EF  F641776A
                            ; OF and CF set since product does not fit in eax alone

;To multiply a dword times a word or byte first convert the word or byte
;to a dword then multiply
; To multiply the dword in eax times the byte in cl do the following:
;    movzx ebx,cl
;    mul   ebx
;
;; To multiply the dword in eax times the word in cx do the following:
;    movzx ebx,cx
;    mul   ebx
;

;error: cannot mul immed since immediate operand not allowed
;        mul    12h         ;illegal since immediate operand not allowed
     
    call    ReadChar        ;pause execution
	INVOKE  ExitProcess,0   ;exit to dos: like C++ exit(0)

Main ENDP

END Main