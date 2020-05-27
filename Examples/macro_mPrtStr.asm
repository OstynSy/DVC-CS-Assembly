;Example of using the the mPrtStr macro
;
;This file is the same as WriteStringLFconstants.asm except
;that the mPrtStr macro is used to print the strings

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*******************MACROS********************************

;mPrtStr
;usage: mPrtStr nameOfString
;ie to display a 0 terminated string named message say:
;mPrtStr message

;Macro definition of mPrtStr. Wherever mPrtStr appears in the code
;it will  be replaced with 

mPrtStr  MACRO  arg1    ;arg1 is replaced by the name of string to be displayed
		 push edx				;save edx
         mov  edx, offset arg1  ;address of str to display should be in edx
         call WriteString       ;display 0 terminated string
         pop  edx				;restore edx
ENDM

;Wherever "mPrtStr message" appears in the code it will  be replaced with 
;push edx
;mov edx, offset arg1   
;call WriteString       
;pop edx

;arg1 is replaced with message if that is the name of the string passed in.



;*************************PROTOTYPES*****************************

WriteString PROTO		; write null-terminated string to output
                        ;EDX points to string

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

        
ReadChar PROTO  ;Irvine code for getting a single char from keyboard
				;Character is stored in the al register.
			    ;Can be used to pause program execution until key is hit.
				        

;************************  Constants  ***************************

    LF       equ     0Ah                   ; ASCII Line Feed

;************************DATA SEGMENT***************************

.data

    ;create strings with embedded line feeds

    openingMsg          byte  "Hello!",LF,LF,0  
    rainMsg             byte  "It looks like",LF,       
                              "it is going to rain today!",LF,LF,0
    tomorrowMsg         byte  "Tomorrow " 
                        byte  "it will be clear!",0 
    endingMsg           byte  LF,LF,"Hit any key to exit",0

    
;************************CODE SEGMENT****************************

.code

main PROC

	;examples of printing a zero terminated strings to the console.
	;using the mPrtStr macro
	
	mPrtStr openingMsg      ;call mPrtStr macro to print zero terminated string

    mPrtStr rainMsg         ;call mPrtStr macro to print zero terminated string

    mPrtStr tomorrowMsg     ;call mPrtStr macro to print zero terminated string

    mPrtStr endingMsg       ;call mPrtStr macro to print zero terminated string

	call	ReadChar		;pause execution
	INVOKE	ExitProcess,0	;exit to dos: like C++ exit(0)

main ENDP
END main