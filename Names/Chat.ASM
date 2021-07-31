
; setTextCursor macro dlValue,dhValue
;     pusha
;     MOV  DL, dlValue    ;SCREEN COLUMN.
;     MOV  DH, dhValue    ;SCREEN ROW.
;     MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
;     MOV  BH, 0     ;PAGE NUMBER.
;     INT  10H       ;BIOS SCREEN SERVICES.
;     popa
; ENDM setTextCursor


getkeyboardStatus macro ;	ZF = 0 if a key pressed, AX = 0 if no scan code is available otherwise AX=[ScanCode][ASCII], does not interrupt the program.
    push ax 
    mov ah,1
    int 16h
    pop ax
ENDM getKeyboardStatus

readKey macro ;halts program until a key is present in the keyboard buffer to consume, reads the scan code on Ah and the ASCII on AL.
    ;push ax
    mov ah,0
    int 16h
    ;pop ax
ENDM readKey

ReadString macro Stringo ;Stringo dw MaxSize, Actual Size, BufferData(initialize $)
    mov ah,0Ah
    mov dx,offset Stringo
    int 21h
ENDM ReadString

videoMode macro Mode
    mov ah,00h
    mov al,Mode
    int 10h
ENDM videoMode

Print macro Stringo
    mov AH,09h
    mov dx,offset Stringo
    int 21h
ENDM Print

; DisplayCharacter macro Char
;     mov dl, Char
;     ;add dl,30h
;     mov ah, 2h
;     int 21h
; ENDM DisplayCharacter

readChar macro ;al stores input ascii
    mov ah,7 ;without echo
    int 21h
endm readChar
getcursorposition macro
mov ah,3h
mov bh,00h
int 10h
endm getcursorposition

; clearfrist macro
; ;clear first half of screen
;  mov ah,6 ; function 6
;  mov al,0 ; scroll by 1 line
;  mov bh,12 ; normal video attribute
;  mov ch,0 ; upper left Y
;  mov cl,0 ; upper left X
;  mov dh,12 ; lower right Y
;  mov dl,79 ; lower right X
;  int 10h
; endm clearfrist

; clearsecond macro
; ;clear second half of screen with blue
; mov ah,6 ; function 6
;  mov al,0 ; scroll by 1 line
;  mov bh,21 ; normal video attribute
;  mov ch,12 ; upper left Y
;  mov cl,0 ; upper left X
;  mov dh,24 ; lower right Y
;  mov dl,79 ; lower right X
;  int 10h

; endm clearsecond 
 extrn UserName:byte
 extrn playerName2:byte

 public MAINChAT
.286
.MODEL HUGE
.STACK 64   
.DATA

    chatOne db 30,?, 30 dup('$')
    chatTwo db 30,?, 30 dup('$')
    dummyMsg db ?
    MsgRecive db ?
    position db 0h
    position2 db 0h
    ;userName1 db "Radwa",'$'
    ;userName2 db "Raghad",'$'
    exitMessage1 db "to end the chatting with ",'$' 
    exitMessage2 db " press F3",'$'
    Y1 db 1
    Y2 db 13

.code 

clearAllscreen proc
 mov ah,6 ; function 6
 mov al,0 ; scroll by 1 line
 mov bh,12 ; normal video attribute
 mov ch,0 ; upper left Y
 mov cl,0 ; upper left X
 mov dh,12 ; lower right Y
 mov dl,79 ; lower right X
 int 10h

 mov ah,6 ; function 6
 mov al,0 ; scroll by 1 line
 mov bh,21 ; normal video attribute
 mov ch,12 ; upper left Y
 mov cl,0 ; upper left X
 mov dh,24 ; lower right Y
 mov dl,79 ; lower right X
 int 10h
 ret
clearAllscreen endp

clearfrist proc
;clear first half of screen
 mov ah,6 ; function 6
 mov al,0 ; scroll by 1 line
 mov bh,12 ; normal video attribute
 mov ch,1 ; upper left Y
 mov cl,0 ; upper left X
 mov dh,11 ; lower right Y
 mov dl,79 ; lower right X
 int 10h
 ret
clearfrist endp

clearsecond proc
;clear second half of screen with blue
 mov ah,6 ; function 6
 mov al,0 ; scroll by 1 line
 mov bh,21 ; normal video attribute
 mov ch,13 ; upper left Y
 mov cl,0 ; upper left X
 mov dh,23 ; lower right Y
 mov dl,79 ; lower right X
 int 10h
 ret
clearsecond endp

setTextCursorsend proc
    
    MOV  DL, position    ;SCREEN COLUMN.
    MOV  DH, Y1    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    
    ret
setTextCursorsend endp

setTextCursorrecive proc
    
    MOV  DL, position2    ;SCREEN COLUMN.
    MOV  DH, Y2    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
   
    ret
setTextCursorrecive endp

DispalyPlayerName proc
    MOV  DL, 00h    ;SCREEN COLUMN.
    MOV  DH, 00h    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    Print userName
    MOV  DL, 00h    ;SCREEN COLUMN.
    MOV  DH, 12    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    Print playerName2
    MOV  DL, 00h    ;SCREEN COLUMN.
    MOV  DH, 24    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    Print exitMessage1
    Print  playerName2
    Print exitMessage2
    
ret
DispalyPlayerName endp

DisplayCharacterS proc
    mov dl, dummyMsg
    ;add dl,30h
    mov ah, 2h
    int 21h
    ret
DisplayCharacterS endp

DisplayCharacterR proc
    mov dl, MsgRecive
    ;add dl,30h
    mov ah, 2h
    int 21h
    ret
DisplayCharacterR endp

MAINChAT proc far             
mov ax,@data
mov ds,ax 

;Initialize baud rate

;Set Divisor Latch Access Bit
mov dx,3fbh ; Line Control Register
mov al,10000000b ;Set Divisor Latch Access Bit
out dx,al ;Out it


;Set LSB byte of the Baud Rate Divisor Latch register.
mov dx,3f8h
mov al,0ch          ;configuration of LSB line			
out dx,al           ;remember: dx, holds line address, then we
                    ; put al inside the address dx points to.


;Set MSB byte of the Baud Rate Divisor Latch register.
mov dx,3f9h
mov al,00h      ;configuration of MSB line, we must put it as there may be garbage.
out dx,al       

;Set port configuration
mov dx,3fbh
mov al,00011011b
; 0:Access to Receiver buffer, Transmitter buffer
; 0:Set Break disabled
; 011:Even Parity
; 0:One Stop Bit
; 11:8bits
out dx,al

;CALL clearfrist
;CALL clearsecond
videoMode 03h
CALL clearAllscreen
CALL DispalyPlayerName

letActionBegins:

    
    
    ;send it to the uart
    ;Sending a value
    ;Check that Transmitter Holding Register is Empty
    CALL setTextCursorsend
    ;mov al,0h              ;get key pressed
    mov ah,1h;
    int 16h
    ;cmp al,0h
    jnz Send                 ; if we get a char Send it!
    jmp Recive               ; if we don't get check the Recive! 


    Send:
    mov ah,0h           ;get the char from the buffer    
    int 16h
    cmp ah,3Dh
    je sendScan
    jmp sendAscii
    
    sendScan:
    mov dummyMsg,ah
    jmp Gooooo

    sendAscii:
    mov dummyMsg,al
    CALL  DisplayCharacterS     
    inc position
    CALL setTextCursorsend
    cmp position,79        ;if we get the end of the line
    jle  Gooooo
    inc Y1
    mov position,00h
    cmp Y1,11             ;if we get the end of the half screen
    jle Gooooo
    CALL clearfrist       ;if we get the end we need to clear this part
    mov Y1,1
    
    Gooooo:
    mov dx , 3FDH ; Line Status Register
    AGAIN: 
        In al , dx ;Read Line Status , A byte is input into AL from the port addressed by DX
        test al , 00100000b  ;test: AND without changing values
        JZ Recive ;Not empty (This line may need to change)
        ;If empty put the VALUE in Transmit data register
        mov dx , 3F8H ; Transmit data register
        mov al,dummyMsg
        out dx , al
        cmp dummyMsg,3Dh
        je ExitChat
        jmp Recive

    ;Receiving a value
    ;Check that Data is Ready

    Recive:
    CALL setTextCursorrecive
    mov dx , 3FDH ; Line Status Register
    CHK: in al , dx
        test al , 1
        JZ  letActionBegins;Not Ready (This line may need to change)
        ;If Ready read the VALUE in Receive data register
        mov dx , 03F8H
        in al , dx
        cmp al,3Dh
        je ExitChat
        mov MsgRecive , al
        CALL DisplayCharacterR  ;display the char recived
        inc position2            ;increase the curser postion 
        CALL setTextCursorrecive

        cmp position2,79         ;check if we get the end of the line
        jle Try
        inc Y2
        mov position2,00h
        cmp Y2,23                ;check if we reach the end of half screen
        jle Try
        CALL clearsecond         ;clear the recive part
        mov Y2,13


    ;getkeyboardStatus                ;repeated until one of the users presses the ESC key
    ;cmp al,1Bh                       ;asscii code for ESC
    ;Jz ExitGame
    Try:
    jmp letActionBegins

    ExitChat: 
    videoMode 03h ;Text mode.
    mov AH,4CH  ;end programm
    INT 21H

    ;videoMode 03h ;Text mode.
    ;return
    ;jmp letActionBegins


MAINChAT endp




end MAINChAT
