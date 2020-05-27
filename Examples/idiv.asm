;The code below is an example of using idiv, cbw, cwd and cdq

;idiv (signed divide) instruction - 
;movsx - mov with signed extension
;cbw - convert byte to word
;cwd - convert word to dword
;cdq - convert dword to qword

; General form:
;
;Description (signed Integer DIVision):
;If operand is 8 bits then
;  AL = AX / operand8	     (quotient)
;  AH = AX mod operand8          (remainder)
;If operand is  16 bits then
;  AX = DX:AX / operand16       (quotient)
;  DX = DX:AX mod operand16 (remainder)
;If operand is  32 bits then
;  EAX = EDX:EAX / operand32       (quotient)
;  EDX = EDX:EAX mod operand32 (remainder)

; idiv op2  |divisor |dividend |
; example   |op2     |   op1   |  quotient| remainder
;-----------------------------------------------------
; idiv ebx  |dword   | edx:eax |   eax    | edx 
; idiv cx   | word   |  dx:ax  |    ax    | dx
; idiv cl   | byte   |  ax     |    al    | ah

;Allowable operands:
;  reg, mem
;Flags changed:
;  None.
;Note:
;   Both operands are treated as signed binary integers. 
;   The sign of the remainder is the same as the sign of the dividend.
;   Division by 0 gives unpredictable results.
;Examples:
;   IDIV ECX	; EDX:EAX/ECX  = EAX (quotient) EDX (remainder)
;   IDIV CX	; DX:AX/CX  = AX (quotient) DX (remainder)
;   IDIV BL	; AX/BL     = AL (quotient) AH (remainder)
;
; Signs of the dividend, divisor, quotient and remainder
;----------------------------------------------------------
; In general:
;    If the signs of the dividend and divisor are different the quotient is negative.
;    If the signs of the dividend and divisor are the same the quotient is positive.

;    If the dividend is negative the remainder is negative.
;    If the dividend is positive the remainder is positive.
;
; dividend | + | - | + | - |
;  divisor | + | + | - | - |
; quotient | + | - | - | + |
;remainder | + | - | + | - |
;--------------------------------------------------------
;
;MOVSX - Extend the sign of operand 2 into the upper part of operand 1
;        and copy operand 2 into the lower part of operand 1
; Examples:
; mov cx, -25  cx = FFE7  = [1]111 1111 1110 0111 since leading bit a 1
;                                                 this is a neg number
; movsx eax, cx  EAX = FFFFFFE7   sign extend the sign bit [1] into the 
;                                 high part of eax and copy FFE7 to the 
;                                 low part of eax

;CBW - convert signed byte to signed word
; General form:
; CBW
;             
; Description (signed Convert Byte to Word):
;    Converts signed integer Byte in AL to a signed Word in AX.  
;    This is done by converting all the bits in AH to be the same 
;    as the most significant bit of AL.  This can be used to convert 
;    an 8-bit dividend into a 16-bit dividend for division.  
;    This is especially important when the operand is negative.  
;    The sign is preserved in the conversion process.
; Allowable operand:
;    None.
; Flags changed:
;    None.
; Examples:
;       MOV	al,7fh
; 	CBW			;AH=00H,  so AX=007F
; 	MOV	al,80h  ;AL= 80h
; 	CBW			;AH=0FFh, so AX=FF80

;CWD
; General form:
; CWD
; Description (signed Convert Word to Dword):
;    Converts signed integer Word in AX to a signed Doubleword in DX:AX pair.  
;    Same idea as CBW but converts from 2 to 4 bytes.
; Example:
; 	MOV	ax,7fabh
; 	CWD			   ;DX=0000H,  so DX:AX pair= 0000 7fab
; 	MOV	ax,8000h   ;AX = 8000h
; 	CWD			   ;DX=0FFFFh, so DX:AX pair= ffff 8000
; 
;        To divide a signed word by a signed word, compute  -1023/-63
; 	MOV  ax,-1023	;AX=0FC01h
; 	CWD			    ;DX:AX pair=FFFFFC01
; 	MOV	bx,-63	    ;BX=0FFC1h
; 	IDIV BX		    ;quotient = AX = 16,remainder = DX=-15  (AX=0010h, DX=FFF1h)

;CDQ
; General form:
; CDQ
; Description (signed Convert DWord to Qword):
;    Converts signed integer DWord in EAX to a signed Quadword in EDX:EAX pair.  
;    Same idea as CWD but converts from 4 to 8 bytes.
; Example:
; 	MOV	eax,71234fabh
; 	CDQ			         ;EDX=00000000H,  so EDX:EAX pair= 0000000071234fabh
; 	MOV	eax,80000000h    ;EAX = 80000000h
; 	CDQ			         ;EDX=0FFFFFFFFh, so EDX:EAX pair= ffffffff80000000h
; 
;        To divide a signed dword by a signed dword, compute  -1023/-63
; 	MOV  eax,-1023	;EAX=0FFFFFC01h
; 	CDQ			    ;EDX:EAX pair=FFFFFFFF FFFFFC01
; 	MOV	ebx,-63	    ;BX=0FFFFFFC1h
; 	IDIV EBX		;quotient = EAX = 16,remainder = EDX = -15  (EAX=00000010h, EDX=FFFFFFF1h)

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

;the following are defined as signed decimal numbers
        byte1   sbyte         -122  ; 86h
        byte2	sbyte	        20  ; 14h
        word1	sword	      -247  ; FF09h
        word2	sword	        85  ; 0055h
        dword1  sdword      306125  ;0004abcdh 
        dword2  sdword      -1147483648
        dword3  sdword      -147483648
        qword1  sqword      0EF1234567890h
        dword4  sdword      7FFF1234h
        


;************************CODE SEGMENT****************************

.code

main PROC

;---- BYTE / BYTE (convert byte to word, then divide)
    mov	    al,byte1                ;al = 86h 
    cbw                             ;AX= byte1 converted to word (2 bytes) = FF86h
    idiv    byte2                   ;quotient in  AL = AX/byte1 =  FF86h/14h 
                                    ;                           = -122/20 = -6 (FA)
                                    ;remainder in AH = -2h (FE)

;---- WORD/BYTE

    mov	    ax,word1                ;ax = FF09h  (word dividend) FF09h (-247)
    idiv	byte1	                ;quotient in  AL = AX/byte1 =  FF09h/86h =
                                    ;                             = -247/-122
                                    ;                             =  2
                                    ;remainder in AH =  -3 (FDh)



;---- WORD/WORD (convert word to dword, then divide)

    mov	    ax,word1                ; AX contains word dividend FF09h (-247)	 
    cwd                             ;DX:AX pair= word1 converted to dword (4 bytes)
                                    ;FFFF FF09
    idiv	word2	                ;quotient in AX = DX:AX/word2 
                                    ;               = FFFFFF09/0055H
                                    ;               = -247/85
                                    ;               = -2 (FFFE)
                                    ;Remainder in DX = -77 (FFB3h)

;---- DWORD/WORD 
    mov	    ax,word ptr dword1+0    ;AX = abcdh (low word of dword1)
    mov	    dx,word ptr dword1+2	;DX = 0004h (high word of dword1)
    idiv    word2                   ;quotient in AX = DX:AX/word2 
                                    ;               = 4abcdh/55h
                                    ;               = 306125/85 (decimal)
                                    ;               = 3601 (E11h)
                                    ;Remainder in DX = 40 (28h)

;---- DWORD/DWORD (convert dword to qword, then divide

    mov     eax, dword2             ;EAX = BB9ACA00 (-1147483648)
    cdq                             ;EDX = FFFFFFFF (sign extend eax into edx)
    idiv    dword3                  ;quotient in EAX  = EDX:EAX / dword3 (dword 3 = -147483648)
                                    ;                 = FFFFFFFFBB9ACA00/F7359400
                                    ;                 = 7
                                    ;Remainder in EDX = F923BE00
;---- QWORD/DWORD
    mov	    eax,dword ptr qword1+0  ;EAX = 34567890h (low dword of qword1)
    mov	    edx,dword ptr qword1+4	;EDX = 0000EF12h (high dword of qword1)
    idiv    dword4                  ;quotient in EAX  = EDX:EAX/dword4 
                                    ;                 = 0000EF12 34567890/ 7FFF1234h
                                    ;                 = 1DE27h
                                    ;Remainder in EDX = 707D9AA4h

    call	ReadChar		        ;pause execution
    INVOKE	ExitProcess,0	        ;exit to dos

main ENDP
END main