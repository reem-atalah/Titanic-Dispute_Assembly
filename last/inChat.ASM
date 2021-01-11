include TML.asm
 extrn UserName:byte
 extrn playerName2:byte

 public inGameChat
.286
.MODEL HUGE
.STACK 64   
.DATA
    ;Characters to be sent and received (out, in):
        byteOut db ? 
        byteIn db ?
    ;Column cursor positions of the current send and receive characters:
        columnOut db 0h
        columnIn db 0h
    ;Row cursor positions of the current send and receive characters:
        rowOut db 19
        rowIn db 22
    ;Exit notes:
        leaveNote db "to continue playing with ",'$' 
        leaveNoteKey db " press F4",'$'
        exitKey db 3Eh 

.code 

inGameChat proc far             
mov ax,@data
mov ds,ax 
;Resetting the cursor position
    mov ah,0
    mov columnOut, ah
    mov columnIn, ah
    mov ah,19
    mov rowOut, 19
    mov ah, 22
    mov rowIn, 22
setBaudRate 00h, 03h
setProtocol 00011011b

CALL clearAllscreen
CALL DispalyPlayerName

letActionBegins:

    setTextCursor columnOut, rowOut
    
    getKeyboardStatus
        jnz Send                  ; if we get a char Send it!
        jmp Receive               ; if we don't get check the Receive! 


    Send:
        readKey
        cmp ah, exitKey
        je timeToLeave           ;Upon pressing the exit key, both parties should be out.
        jmp sendAscii
    
    timeToLeave:                 ;We still need to send ah so the other party knows that its time to leave.
        mov byteOut, ah
        jmp sendingAction

    sendAscii:
        mov byteOut, al
        printCharacter byteOut
        call senderCursorLogic
    
    sendingAction:
        sendByte byteOut
        mov ch, exitKey           ;Make sure it's not the forbidden key, otherwise quit.
        cmp byteOut, ch
        je ExitChat

    

    Receive:
   setTextCursor columnIn, rowIn
        mov dx , 3FDH                           ;Line Status Register
        in al , dx
        test al, 1                              ;Checking data ready
        JZ  letActionBegins                     ;Not Ready (This line may need to change), otherwise receive incoming data:
        mov dx, 03F8H
        in al, dx
        ;Check if it's time to quit.
        cmp al,exitKey
        je ExitChat
        ;It's not so how about printing the character and doing cursor logic:
        mov byteIn , al
        printCharacter byteIn  ;display the char recived
        call receiverCursorLogic
        
    jmp letActionBegins

    ExitChat: 
    videoMode 13h 
    ret
   

inGameChat endp


clearAllscreen proc near 
    clearSection 12, 0, 39, 18, 20, 0    ;Has parameters: color, x1, x2, currentSendRow, currentReceiveRow, scroll
    clearSection 21, 0, 39, 21, 23, 0
 ret
clearAllscreen endp

clearfirst proc near
    clearSection 12, 0, 39, 19, 20, 0    ;Leaving space for the username and the press any key message.
ret
clearfirst endp

clearsecond proc near
clearSection 21, 0, 39, 22, 23, 0    ;Leaving space for the username and the press any key message.
ret
clearsecond endp


DispalyPlayerName proc near
    setTextCursor 0, 18
    Print userName
    setTextCursor 0, 21
    Print playerName2
    setTextCursor 0,24
    Print leaveNote
    Print  playerName2
    Print leaveNoteKey
ret
DispalyPlayerName endp

senderCursorLogic proc near 
    inc columnOut                   
    setTextCursor columnOut, rowOut     ;Set the new cursor position
    cmp columnOut, 39        
    jle  timeToSend                     ;If we still aren't at the end of the row, otherwise:
    inc rowOut
    mov columnOut,00h                   ;start a new line, and reset to the first column
    cmp rowOut, 20                       
    jle timeToSend                      ;if we still aren't at the end of the half screen (last row), otherwise:
    CALL clearfirst                     
    mov rowOut, 19                        ;clear screen and reset row
    timeToSend:
ret
senderCursorLogic endp


receiverCursorLogic proc near

    inc columnIn            
    setTextCursor columnIn, rowIn   ;Now that we've printed a character, set the new cursor position
    cmp columnIn,39                 
    jle Try                         ;If we still aren't at the end of the row, otherwise:
    inc rowIn
    mov columnIn,00h                ;Start a new row and reset the column position
    cmp rowIn, 23                    
    jle Try                         ;If we still haven't reached the end of the screen, otherwise:
    CALL clearsecond                ;Clear the Receive part
    mov rowIn, 22
    Try:
    ret
    receiverCursorLogic endp

end inGameChat
