;Example of using a loop to print out a dword array


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

WriteChar PROTO          ;Irvine code to write character stored in al to console

WriteDec PROTO

;************************  Constants  ***************************

LF       equ     0Ah                   ; ASCII Line Feed

;************************DATA SEGMENT***************************

.data
                ;offset  0  4  8 12 
    testArray   dword   34,45,23,45          ;dword array
    ARRAY_SIZE    equ     ($ - testArray)    ;'$' is placeholder for address after end of array
                                             ;$ - testArray = number of bytes in array
                                             ;ARR_SIZE should be 16 since 4 elements * 4 bytes each = 16
   

;************************CODE SEGMENT****************************

.code

Main PROC

    ;confirm the array size
    mov     eax, ARRAY_SIZE         ;eax = ARR_SIZE in bytes
    call    WriteDec                ;print the number in eax

    mov     al, LF                  ;copy Line Feed to al
    call    WriteChar               ;print line feed

    ;while loop to print out array
    ;iterate through the array until all bytes have been processed.

    mov     ebx, 0                  ;ebx is the offset from the beginning of the array.
                                    ;Initialize ebx to 0 since the first element of the
                                    ;is at testArray + 0
loopTop:
    cmp     ebx, ARRAY_SIZE         ;compare ebx to the total bytes of the array
    jae     done                    ;if we have processed all bytes then done
    
    mov     eax,testArray[ebx]      ;copy the dword at [testArray + ebx] into eax
    call    WriteDec                ;print the number in eax
    mov     al, ' '                 ;al = space
    call    WriteChar               ;print the space
    add     ebx,4                   ;ebx contains the offset from the beginning of the array. 
                                    ;add 4 to ebx so that testArray + ebx points to the 
                                    ;next element of the dword array 
    jmp     loopTop                 ;repeat
    
done:      

    call    ReadChar                ;pause execution
	INVOKE  ExitProcess,0           ;exit to dos: like C++ exit(0)

Main ENDP

END Main