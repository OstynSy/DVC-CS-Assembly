;Examples of select functions from kennedyDspFloat.lib 

;Example of using DspFloat or DspFloatP to print floating point numbers to the console.
;DspFloat or DspFloatP checks if the floating point number is valid.
;If the floating point number is not valid an error message is printed.

;Also demonstrates how to use the following:
;  - SetFloatPlaces to set the number of places to round a float to before printing. 
;  - SetFieldWidth to print floats lined up in a vertical column
;  - TSeparatorOn to turn on a thousands separator when floats print: 2,300.00
;  - TSeparatorOff to turn off a thousands separator when floats print: 2300.00
;  - PrefixOn to print a leading character. Default is '$'
;  - PrefixOff to stop printing a prefix character


;To call DspFloat, SetFloatPlaces or SetFieldWidth in your program you must first include
;kennedyDspFloat.lib in your project and declare the prototypes below

.586      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;*************************CONSTANTS*****************************
LF equ 0Ah

;*************mPrtChar macro****************

mPrtChar  MACRO  arg1    ;arg1 is replaced by the name of character to be displayed
         push eax        ;save eax
         mov al, arg1    ;character to display should be in al
         call WriteChar  ;display character in al
         pop eax         ;restore eax
ENDM

;mPrtStr will print a zero terminated string to the console
mPrtStr  MACRO  arg1            ;arg1 is replaced by the name of string to be displayed
         push edx               ;save edx
         mov edx, offset arg1   ;address of str to display should be in dx
         call WriteString       ;display 0 terminated string
         pop edx                ;restore edx
ENDM

;mPrtDec will print a decimal number to the console
mPrtDec  MACRO  arg1            ;arg1 is replaced by the dec num to be displayed
         push eax               ;save eax
         mov eax, arg1          ;eax = numberto print
         call WriteDec          ;display number to console
         pop eax                ;restore eax
ENDM


;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine


ReadChar PROTO          ;Irvine code for getting a single char from keyboard
				        ;Character is stored in the al register.
			            ;Can be used to pause program execution until key is hit.

WriteChar PROTO         ;Irvine code for displaying a single char in al to the console

WriteString PROTO		;Irvine code to write null-terminated string to output
                        ;EDX points to string

WriteDec PROTO          ;Irvine code to write number stored in eax
                        ;to console in decimal


;To call DspFloat, DspFloat, SetFloatPlaces, SetFieldWidth, TSeparatorOn or TSeparatorOff in your program you must first include
;kennedyDspFloat.lib in your project and declare the prototypes below

SetFloatPlaces PROTO    ;sets the number of places a float should round to while printing 
                        ;The default places is 1.
                        ;populate ecx with the number of places to round a floating point num to
                        ;then call SetFloatPlaces.
                        ;If the places to round to  is 2 then 7.466
                        ;would display as 7.47 after calling DspFloat or DspFloatP
                        ;The rounding is for printing purposes only and
                        ;does not change the original number.
                        ;The places to round to does not change until
                        ;you call SetFloatPlaces again.

DspFloat PROTO          ;prints a float in st(0) to the console formatted to a field width and rounding places.
                        ;DspFloat does not pop the floating point stack.
                        ;Caution: if you use DspFloat in a loop and do not pop, the floating point stack
                        ;might fill up and you will get errors. To avoid issues use DspFloatP.
                        ;DspFloat checks if the floating point number is valid.
                        ;If the floating point number is not valid an error message is printed.

DspFloatP PROTO         ;prints a float in st(0) to the console formatted to a field width and rounding places.
                        ;DspFloatP pops the floating point stack.
                        ;If you display a series of floating point numbers in a loop
                        ;best to use DspFloatP to avoid filling the floating point stack.
                        ;DspFloatP checks if the floating point number is valid.
                        ;If the floating point number is not valid an error message is printed.


SetFieldWidth PROTO     ;set the space a float should occupy when printed.
                        ;populate ecx with the total space you want want a displayed float to occupy.
                        ;use this to help right justify a displayed float to line up a column of numbers vertically
                        ;The default field width is 0.
                        ;To change the field width from the default call SetFieldWidth before calling DspFloat or DspFloatP.
                        ;The field width does not change until you call SetFieldWidth again.


TSeparatorOn proto      ;Print a comma to separate thousands when calling DspFloat or DspFloatP. 10,000.00 will print instead of 10000.00.
                        ;To turn on the thousands separator call TSeparatorOn before calling DspFloat or DspFloatP.
                        ;The thousands separator will remain on until TSeparatorOff is called.
                        ;The default is no thousands separator.

TSeparatorOff proto     ;Turn off thousands separator. Since the default is no thousands separator you only need to call TSeparatorOff
                        ;if TSeparatorOn was previously called.
                        ;To turn off the thousands separator call TSeparatorOff before calling DspFloat or DspFloatP.

PrefixOn  proto         ; If prefix is on, a character will be printed in front of the floating point number. 
                        ;The default prefix character is a '$'.  This is useful in conjunction with SetFieldWidth. 
                        ;If the user manually prints a prefix character and the field width is other than zero then 
                        ;spaces will appear between the prefix character and the floating point number. 
                        ;With PrefixOn the prefix character will print in front of the floating point number with 
                        ;no spaces even if the field width is greater than zero.
                        ;
                        ;The default is no prefix.

PrefixOff proto         ;Turn off printing a prefix character.


;************************DATA SEGMENT***************************

	.data

         ;array of floats to print to the console
         floats             real8 0.8,-34432.8595,0.1,0.1235,2345566.5675,-234.1235,0.0
         FLOATS_SIZE equ sizeof floats      ;FLOATS_SIZE contains the total bytes of the array

         Default            byte "Print floats with default rounding to one place and 0 field width.",LF,0
         changeRounding     byte LF,"Change rounding to: ",0
         changeFieldWidth   byte LF,"Change field width to: ",0
         turnTseparatorOn   byte "Turn thousands separator on.",LF,0
         turnTseparatorOff  byte "Turn thousands separator off.",LF,0
         turnPrefixOn       byte "Turn prefix on",LF,0
         turnPrefixOff      byte "Turn prefix off",LF,0
         printPi            byte LF,"Print Pi to 15 places.",LF,0

;************************CODE SEGMENT****************************

.code

main PROC

    mPrtStr  default            ;print default msg

    ;call DspfloatP with default field width = 0 and places = 1

    mov      esi,0              ;initialize counter

floatsLoop1:
    cmp      esi, FLOATS_SIZE   ;compare counter to total bytes
    jae      doneFloatsLoop1    ;if above or equal, done

    fld      floats[esi]        ;push float onto floating point stack
    call     DspFloatP          ;print float in st(0) and pop
    mPrtChar LF                 ;print linefeed
    add      esi, sizeof(real8) ;increment counter by size of real8 (64)

    jmp      floatsLoop1        ;repeat loop

doneFloatsLoop1:
    ;change field width
    mov      ecx, 13            ;ecx contains field width
    call     SetFieldWidth      ;set field width for DspFloat to line up floats vertically
                                ;field width will not change until SetFieldWidth called again
    mPrtStr  changeFieldWidth   ;print change field width msg
    mPrtDec  ecx                ;print new field width

    ;change number of places to round to
    mov      ecx, 3             ;ecx contains the number of places to round to
    call     SetFloatPlaces     ;set the places for DspFloat round to
                                ;rounding will not change until SetFloatPlaces called again
    mPrtStr  changeRounding     ;print change rounding msg
    mPrtDec  ecx                ;print the places to round to

    mPrtChar LF                 ;print linefeed
    mPrtStr  turnTseparatorOn   ;print turn thousands separator on msg
    call     TSeparatorOn       ;turn thousands separator on

    mov      esi,0              ;reinitialize counter

;the loop below will print the float array in a vertically aligned column
floatsLoop2:
    cmp      esi, FLOATS_SIZE   ;compare counter to total bytes
    jae      doneFloatsLoop2    ;if above or equal, done

    fld      floats[esi]        ;push float onto floating point stack
    call     DspFloatP          ;print float in st(0) and pop
    mPrtChar LF                 ;print linefeed
    add      esi, sizeof(real8) ;increment counter by size of real8 (64)

    jmp      floatsLoop2        ;repeat loop

doneFloatsLoop2:
    ;change field width
    mov      ecx, 12            ;ecx contains field width
    call     SetFieldWidth      ;set field width for DspFloat to line up floats vertically
                                ;field width will not change until SetFieldWidth called again
    mPrtStr  changeFieldWidth   ;print change field width msg
    mPrtDec  ecx                ;print new field width

    ;change number of places to round to
    mov      ecx, 2             ;ecx contains the number of places to round to
    call     SetFloatPlaces     ;set the places for DspFloat round to
                                ;rounding will not change until SetFloatPlaces called again
    mPrtStr  changeRounding     ;print change rounding msg
    mPrtDec  ecx                ;print the places to round to
    mPrtChar LF                 ;print linefeed

    mPrtStr  turnTseparatorOff  ;print turn thousands separator off msg
    call     TSeparatorOff      ;turn thousands separator off

    mPrtStr  turnPrefixOn       ;turn prefix on so '$' prints
    call     PrefixOn           ;turn prefix on
    mov      esi,0              ;reinitialize counter
    
;the loop below will print the float array in a vertically aligned column
;DspFloat is used below instead of DspFloatP. DspFloat does not pop the fp stack
floatsLoop3:
    cmp      esi, FLOATS_SIZE   ;compare counter to total bytes
    jae      doneFloatsLoop3    ;if above or equal, done

    fld      floats[esi]        ;push float onto floating point stack
    call     DspFloat           ;print float in st(0). Don't pop
    mPrtChar LF                 ;print linefeed

    add      esi, sizeof(real8) ;increment counter by size of real8 (64)
    jmp      floatsLoop3        ;repeat loop

doneFloatsLoop3:

    mPrtStr  printPi            ;print Pi msg
    fldpi                       ;st(0) = pi
    mov      ecx, 15            ;ecx contains the number of places to round to
    call     SetFloatPlaces     ;set the places for DspFloat round to
                                ;rounding will not change until SetFloatPlaces called again

    mPrtStr  turnPrefixOff      ;print PrefixOff msg
    call     PrefixOff          ;turn prefix off - '$' won't print

    call     DspFloat           ;print float in  st(0). Don't pop
    mPrtChar LF                 ;print linefeed

    ;At this point the fp stack is full.
    ;There are only 8 fp registers and
    ;we pushed 8 values onto the fp stack to print them with DspFloat.
    ;but DspFloat did not pop the fp stack so it filled up

    ;If we push one more value onto the fp stack we get an error

    fld      floats[0]          ;push float onto floating point stack
    call     DspFloat           ;print float in st(0). Don't pop

    call	 ReadChar		    ;pause execution
	INVOKE	 ExitProcess,0      ;exit to dos

main ENDP

END main