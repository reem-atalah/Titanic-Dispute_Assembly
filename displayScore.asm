graphicsMode macro Mode
    mov ah,00h
    mov al,Mode
    int 10h
ENDM graphicsMode

setTextCursor macro dlValue,dhValue
    pusha
    MOV  DL, dlValue    ;SCREEN COLUMN.
    MOV  DH, dhValue    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    popa
ENDM setTextCursor


blankScreen macro color, from, to
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,color  ;color to blank the screen with
    mov ch,00h
    mov cl,from
    mov dh,18h
    mov dl,to
 ;to the end of the screen
	int 10h

ENDM blankScreen 

.286
.model small
.stack 64
.DATA
    inst1 db 'To drop a disc into one of the columns press: 1, 2, 3 or 4.',13,10,13,10,'$'

.code
MAIN PROC FAR 
    MOV AX,@Data
    MOV DS,AX

hi:
    graphicsMode 13h   
    setTextCursor 35,2 ;first: column, second: row
    ;blankScreen 104,0,4fh

    Instructions1:
        lea dx, [inst1]
        mov dx, offset inst1
        mov ah, 9
        int 21h
;JMP hi

MAIN ENDP 
END MAIN 