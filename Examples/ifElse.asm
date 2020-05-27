;examples of if and ifElse with one and more than one condition.
;example of creating and using a macro.
;examples of using the cmp instruction.
;
;cmp is used to compare a destination and source but does not change
;the destination.
;cmp al,4 is the same as sub al,5 except that cmp does not change al.
;
;It is important to note that cmp sets the flags just like sub would.


.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack


;*************************PROTOTYPES*****************************

ExitProcess PROTO,dwExitCode:DWORD  ;from Win32 api not Irvine

DumpRegs PROTO      ;Irvine code for printing registers to the screen

ReadChar PROTO      ;Irvine code for getting a single char from keyboard
				    ;Character is stored in the al register.
			        ;Can be used to pause program execution until key is hit.

WriteChar PROTO     ;write a character to the console. Character in al.

;************************  Constants  ***************************

    LF       equ     0Ah                   ; ASCII Line Feed

;************************DATA SEGMENT***************************

.data



;************************CODE SEGMENT****************************

.code

main PROC

;********************************if statement
;
;the following assembly implements an if statement that is equivalent to the following C++
;int al = 2;
;if(al == 2)
;   bl = 10;
;

;Example 1 - assembly example of if statement where body of if executes
    mov     al,2            ;initialize al
    cmp     al,2            ;cmp al,2 is like al - 2 except that al is not changed
    jne     DONE1           ;if al != 2 then do not execute body of if
    mov     bl, 10          ;if al == 2 execute body of if and copy 10 to bl

DONE1:

;if statement
;
;the following assembly implements an if statement that is equivalent to the following C++
;int al = 3;
;if(al == 2)
;   bl = 10;
;


;Example 2 - assembly example of if statement where body of if is skipped
    mov     al,3            ;initialize al
    cmp     al,2            ;cmp al,2 is like al - 2 except that al is not changed
    jne     DONE2           ;if al != 2 then do not execute body of if
    mov     bl, 10          ;if al == 2 execute body of if and copy 10 to bl
   
DONE2:
    
;********************************if/else statement
;
;The following assembly implements an if/else statement that is equivalent to
;the following C++
;
;int al = 3;
;
;if(al == 2)
;   bl = 10;
;else
;   bl = 5;
;

;Example 3 - example of if/else where if body is skipped and else executes
    mov     al,3            ;initialize al
    cmp     al,2            ;cmp al,2 is like al - 2 except that al is not changed
    jne     ELSE3           ;if al != 2 then do not execute body of if
    mov     bl, 10          ;if al == 2 execute body of if and copy 10 to bl
    jmp     DONE3           ;skip else since if executed
ELSE3:
    mov     bl, 5           ;else al != 2, copy 5 to bl

DONE3:

;if/else statement
;
;The following assembly implements an if/else statement that is equivalent to
;the following C++
;
;int al = 2;
;
;if(al == 2)
;   bl = 10;
;else
;   bl = 5;
;

;Example 4 - example of if/else where if body is executed and else is skipped
    mov     al,2            ;initialize al
    cmp     al,2            ;cmp al,2 is like al - 2 except that al is not changed
    jne     ELSE4           ;if al != 2 then do not execute body of if
    mov     bl, 10          ;if al == 2 execute body of if and copy 10 to bl
    jmp     DONE4           ;skip else since if executed
ELSE4:
    mov     bl, 5           ;else al != 2, copy 5 to bl

DONE4:
   

;**************************more than one condition examples
;
;********************************AND condition
;
;AND condition (same as C++ &&) both conditions must be true.
;C++ example
;int al = 4;
;if(al > 2 && al < 5)
;   bl = 10;
;

;Example 5 - example of AND that satisfies both conditions: 4 > 2 && 4 < 5
;so body of if is executed
    mov     al,4            ;initialize al
    cmp     al,2            ;cmp al,2 is like al - 2 except that al is not changed
    jbe     DONE5           ;if al <= 2 then do not execute body of if
    cmp     al,5            ;cmp al,5 is like al - 5 except that al is not changed
    jae     DONE5           ;if al >= 5 then do not execute body of if
;execution continues here only if both conditions are satisfied: al > 2 && al < 6
    mov     bl,10           ;execute this line if both conditions are met: (al > 2 && al < 5)
    
DONE5:


;AND condition example where body of if does not execute since one of
;conditions is false
;int al = 6;
;if(al > 2 && al < 5)
;   bl = 10;
;

;Example 6 - example of AND that satisfies only one conditions: 6 > 2
;since second condition of AND is not satisfied body of if is skipped
    mov     al,6            ;initialize al
    cmp     al,2            ;cmp al,2 is like al - 2 except that al is not changed
    jbe     DONE6           ;if al <= 2 then do not execute body of if
    cmp     al,5            ;cmp al,5 is like al - 2 except that al is not changed
    jae     DONE6           ;if al >= 5 then do not execute body of if
;execution continues here only if both conditions are satisfied: al > 2 && al < 5
    mov     bl,10           ;execute this line if both conditions are met: (al > 2 && al < 5)
    
DONE6:

;
;********************************OR condition
;
;OR condition (only one of the conditions has to be true for the body of
;if to execute)
;char al = 'y';
;if(al == 'y' || al == 'Y')
;   bl = 10;
;

;Example 7 - example of OR (only one of the conditions has to be true)
;since one of conditions is true body of if executes
    mov     al,'Y'          ;initialize al
    cmp     al,'y'          ;cmp al,'y' is like al - 'y' except that al is not changed
    je      IFBODY7         ;execute if body if equal
    cmp     al,'Y'          ;cmp al,'Y' is like al - 'Y' except that al is not changed
    ;je      IFBODY7        ;execute if body if equal
    ;jmp     DONE7          ;skip IFBODY if both of above condtions are false
    
    ;program efficiency can be improved by replacing the above 2 jumps with the single jump below
    
    jne     DONE7           ;skip IFBODY if both of above condtions are false
IFBODY7:
    mov     bl,10           ;execute this line if one of the conditions is true: (al == 'y' || al == 'Y')
    
DONE7:;if both conditions are false jump to here. Also executes when if done


    
;OR condition example where both conditions are false so body of if does not
;execute
;C++ example
;char al = 'm';
;if(al == 'y' || al == 'Y')
;   bl = 10;
;
  

;Example 8 - example of OR (only one of the conditions has to be true)
;Since neither of the conditions is true, the body of if does not execute
    mov     al,'m'          ;initialize al
    cmp     al,'y'          ;cmp al,'y' is like al - 'y' except that al is not changed
    je      IFBODY8         ;execute if body if equal
    cmp     al,'Y'          ;cmp al,'Y' is like al - 'Y' except that al is not changed
    ;je      IFBODY8        ;execute if body if equal
    ;jmp     DONE8          ;skip IFBODY if both of above condtions are false
    
    ;program efficiency can be improved by replacing the above 2 jumps with the single jump below
    
    jne     DONE8           ;skip IFBODY if both of above condtions are false
IFBODY8:
    mov     bl,10           ;execute this line if one of the conditions is true: (al == 'y' || al == 'Y')
    
DONE8:;if both conditions are false jump to here. Also executes when if done
    
;series of if/else only the first true statement will execute
;and the rest of the if/elses will be skipped
;C++ example
;
;int al = 75
;if(al >= 90)
;   cout << "A";
;else if(al >= 80)
;   cout << "B";
;else if(al >= 70)
;   cout << "C";
;else if(al >= 60)
;   cout << "D";
;else
;   cout << "F";


    mov     al,75            ;initialize al to grade you are testing for
    
;Example 9 - example of series of if/else where only first true statement executes
;and the rest of the if/elses will be skipped
;
;check for 'A' grade
    cmp     al,90           ;compare al to 90
    jb      IFELSEB         ;if al < 90 then do not execute body of if
    mov     al,'A'          ;al gets 'A' (al >= 90)
    jmp     DISPLAY         ;skip rest of if/elses
IFELSEB: ;check for 'B' grade
    cmp     al,80           ;compare al to 80
    jb      IFELSEC         ;if al < 80 then do not execute body of if
    mov     al,'B'          ;al gets 'B'(al >= 80)
    jmp     DISPLAY         ;skip rest of if/elses
IFELSEC:  ;check for 'C' grade
    cmp     al,70           ;compare al to 70
    jb      IFELSED         ;if al < 70 then do not execute body of if
    mov     al,'C'          ;al gets 'C' (al >= 70)
    jmp     DISPLAY         ;skip rest of if/elses
IFELSED:  ;check for 'D' grade
    cmp     al,60           ;compare al to 60
    jb      ELSEF           ;if al < 60 then do not execute body of if
    mov     al,'D'          ;al gets 'D'(al >= 60)
    jmp     DISPLAY         ;skip rest of if/elses
ELSEF:  ;no condition necessary since 'F' only choice left
    mov     al,'F'          ;al gets 'F' (al < 60)
    
    ;no jmp needed since execution naturally exits series of if/else
DISPLAY:

    call WriteChar          ;display character in al
    mov     al, LF          ;al = linefeed
    call    WriteChar       ;print linefeed

    ;-------------- Exit to MSDOS

    call	ReadChar		;pause execution
	INVOKE	ExitProcess,0	;exit to dos

main ENDP
END main