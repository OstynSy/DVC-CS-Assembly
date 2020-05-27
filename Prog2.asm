;  Comment block below must be filled out completely for each assignment
;  ************************************************************* 
;  Student Name: Ostyn Sy
;  COMSC-260 Spring 2020
;  Date: 2/19/2020
;  Assignment # 2
;  Version of Visual Studio used (2015)(2017)(2019):  2019
;  Did program compile? Yes
;  Did program produce correct results? Yes
;  Is code formatted correctly including indentation, spacing and vertical alignment? Yes
;  Is every line of code commented? Yes
;
;  Estimate of time in hours to complete assignment:  
;   1 hour 30mins
;
;  In a few words describe the main challenge in writing this program:
;  implementing multiplication, division, modulo, strings, char, etc. 
;  
;  Short description of what program does:
;
;   Prints out a intro and exit string and calculates enum1+num2/num3*(num4-num5)%num6 – num7 while also
;   printing it out
;  *************************************************************
;  Reminder: each assignment should be the result of your
;  individual effort with no collaboration with other students.
;
;  Reminder: every line of code must be commented and formatted  
;  per the ProgramExpectations.pdf file on the class web site
; *************************************************************



.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096                 ;allocate 4096 bytes (1000h) for stack

;*************************PROTOTYPES*****************************

WriteHex    PROTO           ;write the number stored in eax to the console as a hex number
                            ;before calling WriteHex put the number to write into eax
WriteString PROTO           ; write null-terminated string to console
                            ; edx contains the address of the string to write
                            ; before calling WriteString put the address of the string to write into edx
                            ; e.g. mov edx, offset message ;address of message is copied to edx
ExitProcess PROTO,dwExitCode:DWORD ; exit to the operating system
ReadChar    PROTO           ;Irvine code for getting a single char from keyboard
                            ;Character is stored in the al register.
                            ;Can be used to pause program execution until key is hit.
WriteChar   PROTO           ;Irvine code for printing a single char to the console.
                            ;Character to be printed must be in the al register

;************************ Constants ***************************

   LF       equ   0Ah       ;ASCII Line Feed

;************************DATA SEGMENT***************************

.data

   num1     dword 0CB7FB84h  ;num1 dword 0CB7FB84h
   num2     dword 0F56A2C5h  ;num2 dword 0F56A2C5h
   num3     dword 0ADC154h   ;num3 dword 0ADC154h
   num4     dword 0C7A25A9h  ;num4 dword 0C7A25A9h
   num5     dword 0B461ACBh  ;num5 dword 0B461ACBh
   num6     dword 0D3494h    ;num6 dword 0D3494h
   num7     dword 1514ABCh   ;num7 dword 1514ABCh

   openmsg  byte  "Program 2 by Ostyn Sy", LF, LF, 0   ;opening message
   exitmsg  byte  LF, LF, "Hit any key to exit!" , 0   ;exiting message
   hplus    byte  "h+", 0                              ;display h+
   hminus   byte  "h-", 0                              ;display h-
   hdiv     byte  "h/", 0                              ;display h/
   hequal   byte  "h=", 0                              ;display h=
   hmulparen     byte  "h*(", 0                        ;display h*(
   letterh       byte  'h', 0                          ;display h
   hparenmod     byte  "h)%", 0                        ;display h)%

;************************CODE SEGMENT****************************

.code

main PROC

    ;enum1+num2/num3*(num4-num5)%num6 – num7

    ;num4 - num5 = 134 0ADE
    mov ecx, num4             ;num 4 in ecx
    sub ecx, num5             ;ecx - num5

    ;num2/num3=16 (quotient in eax, remainder in edx ignored)
    mov eax, num2             ;num2 in eax
    mov edx, 0                ;zero out edx
    div num3                  ;quotient in eax

    ;result from step 2 * result from step 1 = 1A78 EF14
    mul ecx                   ;multiplies eax and ecx

    ;result from step 3 % num6 = 2 9280(Remainder is in edx after div, quotient in eax ignored)
    mov edx, 0                ;zeroes out edx
    div num6                  ;remainder in edx

    ;num1 plus result from step 4= CBA 8E04
    mov ebx, num1             ;num1 in ebx
    add ebx, edx              ;ebx plus edx

    ;result from step 5 - num 7 = B69 4348
    sub ebx, num7             ;ebx - num7

    ;print message
    mov edx, offset openmsg   ;copies openmsg to edx
    call WriteString          ;writes string

    mov eax, num1             ;copies num1 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hplus     ;copies hplus to edx
    call WriteString          ;writes string

    mov eax, num2             ;copies num2 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hdiv      ;copies hdiv to edx
    call WriteString          ;writes string

    mov eax, num3             ;copies num3 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hmulparen ;copies hmulparen to edx
    call WriteString          ;writes string

    mov eax, num4             ;copies num4 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hminus    ;copies hminus to edx
    call WriteString          ;writes string

    mov eax, num5             ;copies num5 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hparenmod ;copies hparenmod to edx
    call WriteString          ;writes string

    mov eax, num6             ;copies num6 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hminus    ;copies hminus to edx
    call WriteString          ;writes string

    mov eax, num7             ;copies num7 to eax
    call WriteHex             ;writes in hexadecimal

    mov edx, offset hequal    ;copies hequal to edx
    call WriteString          ;writes string

    mov eax, ebx              ;copies ebx into eax
    call WriteHex             ;writes in hexadecimal

    mov al, letterh           ;copies h to al
    call WriteChar            ;writes char

    mov edx, offset exitmsg   ;copies exitmsg to edx
    call WriteString          ;writes string

    call    ReadChar          ;Pause program execution while user inputs a non-displayed char
	INVOKE	ExitProcess,0     ;exit to dos: like C++ exit(0)

    ;Answer: B69 4348

main ENDP
END main