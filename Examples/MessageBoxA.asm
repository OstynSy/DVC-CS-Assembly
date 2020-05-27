;The code below demonstrates how to create a Win32 MessageBoxA
;
;MessageBoxA is a win32 api function that displays a dialogue box with 
;a caption, message and buttons
;
;MessageBoxA takes 4 parameters: 
;    1. window owner handle (0 means no owner)
;    2. message address (zero terminated string)
;    3. caption address(zero terminated string)    
;    4. which button(s) to display (execution will not continue 
;       until a button is selected)
;         a. 4 - display yes no buttons (yes returns 6 in eax)
;         b. 0 - display an ok button


;The code was copied and modified from www.lomont.org

.386      ;identifies minimum CPU for this program

.MODEL flat,stdcall    ;flat - protected mode program
                       ;stdcall - enables calling of MS_windows programs

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;allocate memory for stack
;(default stack size for 32 bit implementation is 1MB without .STACK directive 
;  - default works for most situations)

.STACK 4096            ;allocate 4096 bytes (1000h) for stack

;************************  Constants  ***************************

LF       equ     0Ah                   ; ASCII Line Feed

;*************************PROTOTYPES*****************************

    ExitProcess PROTO,
    dwExitCode:DWORD        ;from Win32 api not Irvine to exit to dos with exit code

    ;MessageBoxA is a win32 api function (not an Irvine function)
    ;that displays a dialogue box with a caption, message and buttons

    MessageBoxA PROTO,      ;MessageBoxA takes 4 parameters:
      handleOwn:DWORD,      ;1. window owner handle
         msgAdd:DWORD,      ;2. message address (zero terminated string)
     captionAdd:DWORD,      ;3. title address(zero terminated string)
        boxType:DWORD       ;4. which button(s) to display

;************************DATA SEGMENT***************************

.data
    caption byte "Program by Fred Kennedy", 0
   question byte "Do you love assembly?", 0
        yes byte "Perfect!!",0
         no byte "Say the following 3 times, ",'"',
                 "I love assembly",'"',0        

;************************CODE SEGMENT****************************

.code

main PROC

    ;Display message box asking user question.

    ;NOTE: if the number of spaces after the comma and before the comment
    ;is too great you will get an error message: "line too long"

    invoke  MessageBoxA ,   ;call MessageBoxA Win32 API function
                       0,   ;0 indicates no window owner
           addr question,   ;address of message to be displayed in middle of msg box
            addr caption,   ;caption to be displayed in title bar of msg box
                       4    ;display yes, no buttons in msg box
                            ;(6 returned in eax if user hits yes)
                            ;(7 returned in eax if user hits no)

;loop will keep iterating until the user chooses 'yes'
loopTop:

    cmp     eax, 6          ;Did the user choose yes(6)? No need to check for no (7)
    je      done            ;If yes, done. 

    ;display message box asking user to repeat message

    invoke  MessageBoxA ,   ;call MessageBoxA Win32 API function
                       0,   ;0 indicates no window owner
                 addr no,   ;address of message to be displayed in middle of msg box
            addr caption,   ;caption to be displayed in title bar of msg box
                       0    ;display ok button in msg box
                            ;(1 returned in eax after user hits ok)

    ;display message box asking user question

    invoke  MessageBoxA ,   ;call MessageBoxA Win32 API function
                       0,   ;0 indicates no window owner
           addr question,   ;address of message to be displayed in middle of msg box
            addr caption,   ;caption to be displayed in title bar of msg box
                       4    ;display yes, no buttons in msg box
                            ;(6 returned in eax if user hits yes)
                            ;(7 returned in eax if user hits no)

    jmp     loopTop         ;repeat loop

done:

    ;display message box with 'Perfect' msg

    invoke  MessageBoxA ,   ;call MessageBoxA Win32 API function
                       0,   ;0 indicates no window owner
                addr yes,   ;address of message to be displayed in middle of msg box
            addr caption,   ;caption to be displayed in title bar of msg box
                       0    ;display ok button in msg box
                            ;(1 returned in eax after user hits ok)

    invoke  ExitProcess,0   ;exit program with success (0)

main ENDP                   ;end of main
End main                    ;end of program


comment !
The documentation below was copied from the MS web site
http://msdn.microsoft.com/en-us/library/windows/desktop/ms645505%28v=vs.85%29.aspx

C++

int WINAPI MessageBox(
  _In_opt_  HWND hWnd,
  _In_opt_  LPCTSTR lpText,
  _In_opt_  LPCTSTR lpCaption,
  _In_      UINT uType
);

Parameters

hWnd [in, optional]   Type: HWND
A handle to the owner window of the message box to be created. 
If this parameter is NULL, the message box has no owner window.
****
lpText [in, optional]     Type: LPCTSTR
The message to be displayed. If the string consists of more than one line, 
you can separate the lines using a carriage return and/or linefeed character between each line.
****
lpCaption [in, optional]    Type: LPCTSTR
The dialog box title. If this parameter is NULL, the default title is Error.
****
uType [in]     Type: UINT
The contents and behavior of the dialog box. This parameter can be a combination 
of flags from the following groups of flags.

To indicate the buttons displayed in the message box, specify one of the following values.

MB_ABORTRETRYIGNORE 0x00000002L
The message box contains three push buttons: Abort, Retry, and Ignore.

MB_CANCELTRYCONTINUE 0x00000006L
The message box contains three push buttons: Cancel, Try Again, Continue. 
Use this message box type instead of MB_ABORTRETRYIGNORE.

MB_HELP 0x00004000L
Adds a Help button to the message box. When the user clicks the Help button or presses F1, 
the system sends a WM_HELP message to the owner.

MB_OK 0x00000000L
The message box contains one push button: OK. This is the default.

MB_OKCANCEL 0x00000001L
The message box contains two push buttons: OK and Cancel.

MB_RETRYCANCEL 0x00000005L
The message box contains two push buttons: Retry and Cancel.

MB_YESNO 0x00000004L
The message box contains two push buttons: Yes and No.

MB_YESNOCANCEL 0x00000003L
The message box contains three push buttons: Yes, No, and Cancel.

Return value Type: int

If a message box has a Cancel button, the function returns the IDCANCEL value if 
either the ESC key is pressed or the Cancel button is selected. 
If the message box has no Cancel button, pressing ESC has no effect.

If the function fails, the return value is zero. To get extended error information, call GetLastError.

If the function succeeds, the return value is one of the following menu-item values.

Return code/value	Description
IDABORT 3 The Abort button was selected.
IDCANCEL 2 The Cancel button was selected.
IDCONTINUE 11 The Continue button was selected.
IDIGNORE 5 The Ignore button was selected.
IDNO 7 The No button was selected.
IDOK 1 The OK button was selected.
IDRETRY 4 The Retry button was selected.
IDTRYAGAIN 10 The Try Again button was selected.
IDYES 6 The Yes button was selected.
!;end comments