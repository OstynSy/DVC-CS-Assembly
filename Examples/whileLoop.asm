;Example of a while loop 

;Since the condition for a while loop is tested at the top of the loop,
;a while loop may not even execute once

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

    ;mov     eax, 'F'       ;Why will 'F' not print if loop condition initialize to this value?
    mov     eax, 'A'        ;initialize loop condition

;while loop to print consecutive characters

loopTop:
    cmp     eax, 'E'        ;cmp performs a non-destructive subtraction(destination is not changed)
                            ;and sets the flags like sub would

    ;check loop termination condition

    ja      loopEnd         ;If character in eax is above 'E'
                            ;exit the loop
    call    WriteChar       ;display character in al
    inc     eax             ;advance to next character (eax = eax + 1)
    jmp     loopTop         ;repeat loop unconditionally
    
loopEnd:
	call	ReadChar		;pause execution
	INVOKE	ExitProcess,0	;exit to dos

main ENDP
END main