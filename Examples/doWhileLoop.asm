;example of a doWhile loop in assembly language

;In a doWhile loop the loop condition is tested at the bottom of the loop
;so the loop will execute at least once

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

WriteChar PROTO ;write the character in al to the console

WriteDec PROTO  ;Irvine code for writing a dec number to the console

;************************DATA SEGMENT***************************

.data


;************************CODE SEGMENT****************************

.code

main PROC
    
    ;mov     eax, 'F'       ;Why will 'F' print if loop condition initialize to this value?
    mov     eax, 'A'        ;initialize loop condition

;doWhile loop to print consecutive characters

loopTop:  
    call	WriteChar       ;display character in al
    inc     eax             ;advance to next character  (eax = eax + 1)
    cmp     eax, 'E'        ;cmp performs a non-destructive subtraction(destination is not changed)
                            ;and sets the flags like sub would

    ;check loop continuation condition

    jbe     loopTop         ;If character in eax is below or equal to 'E'
                            ;repeat the loop
                            ;otherwise control falls off the bottom of the loop
                            ;and the loop is done
    call	ReadChar		;pause execution
	INVOKE	ExitProcess,0	;exit to dos

main ENDP
END main