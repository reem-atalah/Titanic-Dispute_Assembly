
setTextCursor macro dlValue,dhValue
    pusha
    MOV  DL, dlValue    ;SCREEN COLUMN.
    MOV  DH, dhValue    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    popa
ENDM setTextCursor


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

DisplayCharacter macro Char
    mov dl, Char
    ;add dl,30h
    mov ah, 2h
    int 21h
ENDM DisplayCharacter

readChar macro ;al stores input ascii
    mov ah,7 ;without echo
    int 21h
endm readChar

.286
.MODEL HUGE
.STACK 64   
.DATA

    chatOne db 30,?, 30 dup('$')
    chatTwo db 30,?, 30 dup('$')
    dummyMsg db ?
    MsgRecive db ?

.code 

MAIN proc far             
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

;clear first half of screen
 mov ah,6 ; function 6
 mov al,0 ; scroll by 1 line
 mov bh,12 ; normal video attribute
 mov ch,0 ; upper left Y
 mov cl,0 ; upper left X
 mov dh,12 ; lower right Y
 mov dl,79 ; lower right X
 int 10h

;clear second half of screen with blue
mov ah,6 ; function 6
 mov al,0 ; scroll by 1 line
 mov bh,21 ; normal video attribute
 mov ch,12 ; upper left Y
 mov cl,0 ; upper left X
 mov dh,24 ; lower right Y
 mov dl,79 ; lower right X
 int 10h
 
MAIN endp 

TrnasmitRecieveProc proc

letActionBegins:

    ; readKey   
    ; JZ letActionBegins
    
    ; readChar
    ; DisplayCharacter al

    ; ReadString chatOne
    ; Print chatOne ;I think it will be character by character not whole string
    
    ;send it to the uart
    ;Sending a value
    ;Check that Transmitter Holding Register is Empty
    setTextCursor 0,0
    mov al,0h
    mov ah,1h;
    int 16h
    cmp al,0h
    jnz Send
    jmp Recive


    Send:
    mov ah,1
    int 16
    mov ah,2
    mov dl,al
    int 21h
    mov dummyMsg,al
    setTextCursor 0,0
    mov dx , 3FDH ; Line Status Register
    AGAIN: 
        In al , dx ;Read Line Status , A byte is input into AL from the port addressed by DX
        test al , 00100000b  ;test: AND without changing values
        JZ Recive ;Not empty (This line may need to change)
        ;If empty put the VALUE in Transmit data register
        mov dx , 3F8H ; Transmit data register
        mov al,dummyMsg
        out dx , al

    ;Receiving a value
    ;Check that Data is Ready
    Recive:
    setTextCursor 0,12
    mov dx , 3FDH ; Line Status Register
    CHK: in al , dx
        test al , 1
        JZ  letActionBegins;Not Ready (This line may need to change)
        ;If Ready read the VALUE in Receive data register
        mov dx , 03F8H
        in al , dx
        mov MsgRecive , al
        DisplayCharacter MsgRecive


    ;getkeyboardStatus                ;repeated until one of the users presses the ESC key
    ;cmp al,1Bh                       ;asscii code for ESC
    ;Jz ExitGame
     jmp letActionBegins

    ExitGame:  
        videoMode 03h ;Text mode.
        ;return
    
    jmp letActionBegins

TrnasmitRecieveProc endp

end MAIN 
