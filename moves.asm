DisplayString macro Stringo
    mov AH,09h
    mov dx,offset Stringo
    int 21h
ENDM DisplayString
setTextCursor macro Coordinates
    pusha
    mov ah,02h
    mov DX, Coordinates
    int 10h
    popa
ENDM setTextCursor

endl macro ;prints a new line
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h 
ENDM endl
ReadString macro Stringo ;Stringo dw MaxSize, Actual Size, BufferData(initialize $)
    mov ah,0Ah
    mov dx,offset Stringo
    int 21h
ENDM ReadString
Drawpaddel MACRO BALLX2,BALLY2,BALLwidth,Ballheight
        LOCAL Draw1
        mov cx,BALLX2
        mov dx,BALLY2
 Draw1:  mov al,0fh
        mov ah,0ch
        int 10h
        inc cx
        mov ax,cx
        sub ax,BALLX2
        cmp ax,BALLwidth
        jng Draw1
        mov cx,BALLX2
        inc dx
        mov ax,dx
        sub ax,BALLY2
        cmp ax,Ballheight
        jng Draw1
  

        
    
ENDM
staticWave macro y, x ;x, y relate to the waves position
   local whileWaveBeingDrawn
   mov ah,0ch
    mov bx, offset wave
    whileWaveBeingDrawn:
       drawDynamicPixel [bx],[bx+1],[bx+2], y, x
       add bx,3
       cmp bx,offset waveSize
    JNE whileWaveBeingDrawn
 endm staticWave
drawDynamicPixel macro column, row, color, Y_t, X_t ;x, y, color...the last two parameters are the dynamic position of the pixel
        xor ch,ch
        xor dh,dh
        mov dl, row
        mov cl, column
        mov al, color
        ;Dynamics:
        add dx, Y_t
        add cx, X_t
        int 10h
ENDM drawDynamicPixel
blankScreen macro color
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,color  ;color to blank the screen with
	mov cx,0000h  ;start from row 0, column 0
	mov dx,184fh ;to the end of the screen
	int 10h
ENDM blankScreen
 .MODEL SMALL
    .STACK 64


.DATA 
	
	Time DB 0 
    ;Timeafter db 10
	WINDOW_WIDTH DW 140h   ;the width of the window (320 pixels)
	WINDOW_HEIGHT DW 0C8h  ;the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6     ;variable used to check collisions early
	BALLX dw 0AH,45H,65h ,1ch,2Bh,70h
    BALLY dw 0AH,01H,03h,0Eh,1eh,2Ch
	TIME_AUX DB 0 ;variable used when checking if the time has changed
	VecloictyX dw 01h,01h,01h,01h,01h,01H
    VecloictyY dw 02h,02h,02h,02h,02h,02h
	BALL_X DW 0Ah ;X position (column) of the ball
	BALL_Y DW 0Ah ;Y position (line) of the ball
	;BALL_SIZE DW 04h ;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 05h ;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h ;Y (vertical) velocity of the ball
    ball db 6,0,17,7,0,17,8,0,17,9,0,17,10,0,17,11,0,17,12,0,17,13,0,17
        db 4,1,17,5,1,17,6,1,17,7,1,17,8,1,17,9,1,17,10,1,17,11,1,17,12,1,17,13,1,17,14,1,17,15,1,17
        db 3,2,16,4,2,17,5,2,17,6,2,17,7,2,17,8,2,17,9,2,17,10,2,17,11,2,17,12,2,17,13,2,17,14,2,17,15,2,17,16,2,16
        db 2,3,16,3,3,17,4,3,17,5,3,17,6,3,17,7,3,17,8,3,17,9,3,17,10,3,17,11,3,17,12,3,17,13,3,17,14,3,17,15,3,17,16,3,17,17,3,16
        db 1,4,17,2,4,17,3,4,17,4,4,17,5,4,17,6,4,17,7,4,17,8,4,17,9,4,17,10,4,17,11,4,17,12,4,17,13,4,17,14,4,17,15,4,17,16,4,17,17,4,17,18,4,17
        db 1,5,17,2,5,17,3,5,17,4,5,17,5,5,17,6,5,17,7,5,17,8,5,17,9,5,17,10,5,17,11,5,17,12,5,17,13,5,17,14,5,17,15,5,17,16,5,17,17,5,17,18,5,17
        db 0,6,17,1,6,17,2,6,17,3,6,17,4,6,17,5,6,17,6,6,17,7,6,17,8,6,17,9,6,17,10,6,17,11,6,17,12,6,17,13,6,17,14,6,17,15,6,17,16,6,17,17,6,17,18,6,17,19,6,17
        db 0,7,17,1,7,17,2,7,17,3,7,17,4,7,17,5,7,17,6,7,17,7,7,17,8,7,17,9,7,17,10,7,17,11,7,17,12,7,17,13,7,17,14,7,17,15,7,17,16,7,17,17,7,17,18,7,17,19,7,17
        db 0,8,17,1,8,17,2,8,17,3,8,17,4,8,17,5,8,17,6,8,17,7,8,17,8,8,17,9,8,17,10,8,17,11,8,17,12,8,17,13,8,17,14,8,17,15,8,17,16,8,17,17,8,17,18,8,17,19,8,17
        db 0,9,17,1,9,17,2,9,17,3,9,17,4,9,17,5,9,17,6,9,17,7,9,17,8,9,17,9,9,17,10,9,17,11,9,17,12,9,17,13,9,17,14,9,17,15,9,17,16,9,17,17,9,17,18,9,17,19,9,17
        db 0,10,17,1,10,17,2,10,17,3,10,17,4,10,17,5,10,17,6,10,17,7,10,17,8,10,17,9,10,17,10,10,17,11,10,17,12,10,17,13,10,17,14,10,17,15,10,17,16,10,17,17,10,17,18,10,17,19,10,17
        db 0,11,17,1,11,17,2,11,17,3,11,17,4,11,17,5,11,17,6,11,17,7,11,17,8,11,17,9,11,17,10,11,17,11,11,17,12,11,17,13,11,17,14,11,17,15,11,17,16,11,17,17,11,17,18,11,17,19,11,17
        db 0,12,17,1,12,17,2,12,17,3,12,17,4,12,17,5,12,17,6,12,17,7,12,17,8,12,17,9,12,17,10,12,17,11,12,17,12,12,17,13,12,17,14,12,17,15,12,17,16,12,17,17,12,17,18,12,17,19,12,17
        db 0,13,17,1,13,17,2,13,17,3,13,17,4,13,17,5,13,17,6,13,17,7,13,17,8,13,17,9,13,17,10,13,17,11,13,17,12,13,17,13,13,17,14,13,17,15,13,17,16,13,17,17,13,17,18,13,17,19,13,17
        db 1,14,17,2,14,17,3,14,17,4,14,17,5,14,17,6,14,17,7,14,17,8,14,17,9,14,17,10,14,17,11,14,17,12,14,17,13,14,17,14,14,17,15,14,17,16,14,17,17,14,17,18,14,17
        db 1,15,17,2,15,17,3,15,17,4,15,17,5,15,17,6,15,17,7,15,17,8,15,17,9,15,17,10,15,17,11,15,17,12,15,17,13,15,17,14,15,17,15,15,17,16,15,17,17,15,17,18,15,17
        db 2,16,16,3,16,17,4,16,17,5,16,17,6,16,17,7,16,17,8,16,17,9,16,17,10,16,17,11,16,17,12,16,17,13,16,17,14,16,17,15,16,17,16,16,17,17,16,16
        db 3,17,16,4,17,17,5,17,17,6,17,17,7,17,17,8,17,17,9,17,17,10,17,17,11,17,17,12,17,17,13,17,17,14,17,17,15,17,17,16,17,16
        db 4,18,17,5,18,17,6,18,17,7,18,17,8,18,17,9,18,17,10,18,17,11,18,17,12,18,17,13,18,17,14,18,17,15,18,17
        db 6,19,17,7,19,17,8,19,17,9,19,17,10,19,17,11,19,17,12,19,17,13,19,17
        Ball_Size dw 20 
    wave db 7,35,54,8,35,54,9,35,54,10,35,54,11,35,54,12,35,54,13,35,54,14,35,54,15,35,54,46,35,54,47,35,54,48,35,54,49,35,54,50,35,54,51,35,54,52,35,54,53,35,54,54,35,54,55,35,54,86,35,54,87,35,54,88,35,54,89,35,54,90,35,54,91,35,54,92,35,54,93,35,54
db 7,36,54,8,36,54,9,36,54,10,36,54,11,36,54,12,36,54,13,36,54,14,36,54,15,36,54,16,36,52,46,36,54,47,36,54,48,36,54,49,36,54,50,36,54,51,36,54,52,36,54,53,36,54,54,36,54,55,36,54,86,36,54,87,36,54,88,36,54,89,36,54,90,36,54,91,36,54,92,36,54,93,36,54
db 2,37,52,3,37,54,4,37,54,5,37,54,6,37,54,7,37,54,8,37,54,9,37,54,10,37,54,11,37,54,12,37,54,13,37,54,14,37,54,15,37,54,16,37,54,17,37,54,18,37,54,19,37,53,20,37,54,41,37,32,42,37,54,43,37,54,44,37,54,45,37,54,46,37,54,47,37,54,48,37,54,49,37,54,50,37,54,51,37,54,52,37,54,53,37,54,54,37,54,55,37,54,56,37,54,57,37,54,58,37,54,81,37,53,82,37,54,83,37,54,84,37,54,85,37,54,86,37,54,87,37,54,88,37,54,89,37,54,90,37,54,91,37,54,92,37,54,93,37,54,94,37,54,95,37,54,96,37,54,97,37,54
db 2,38,54,3,38,54,4,38,54,5,38,54,6,38,54,7,38,54,8,38,54,9,38,54,10,38,54,11,38,54,12,38,54,13,38,54,14,38,54,15,38,54,16,38,54,17,38,54,18,38,54,19,38,54,20,38,54,41,38,54,42,38,54,43,38,54,44,38,54,45,38,54,46,38,54,47,38,54,48,38,54,49,38,54,50,38,54,51,38,54,52,38,54,53,38,54,54,38,54,55,38,54,56,38,54,57,38,54,58,38,54,81,38,54,82,38,54,83,38,54,84,38,54,85,38,54,86,38,54,87,38,54,88,38,54,89,38,54,90,38,54,91,38,54,92,38,54,93,38,54,94,38,54,95,38,54,96,38,54,97,38,54
db 1,39,54,2,39,54,3,39,54,4,39,54,5,39,54,6,39,54,7,39,54,8,39,54,9,39,54,10,39,54,11,39,54,12,39,54,13,39,54,14,39,54,15,39,54,16,39,54,17,39,54,18,39,54,19,39,54,20,39,54,21,39,54,22,39,54,39,39,54,40,39,54,41,39,54,42,39,54,43,39,54,44,39,54,45,39,54,46,39,54,47,39,54,48,39,54,49,39,54,50,39,54,51,39,54,52,39,54,53,39,54,54,39,54,55,39,54,56,39,54,57,39,54,58,39,54,59,39,54,60,39,54,61,39,54,62,39,54,79,39,54,80,39,54,81,39,54,82,39,54,83,39,54,84,39,54,85,39,54,86,39,54,87,39,54,88,39,54,89,39,54,90,39,54,91,39,54,92,39,54,93,39,54,94,39,54,95,39,54,96,39,54,97,39,54,98,39,54
db 1,40,54,2,40,54,3,40,54,4,40,54,5,40,54,6,40,54,7,40,54,8,40,54,9,40,54,10,40,54,11,40,54,12,40,54,13,40,54,14,40,54,15,40,54,16,40,54,17,40,54,18,40,54,19,40,54,20,40,54,21,40,54,22,40,54,39,40,54,40,40,54,41,40,54,42,40,54,43,40,54,44,40,54,45,40,54,46,40,54,47,40,54,48,40,54,49,40,54,50,40,54,51,40,54,52,40,54,53,40,54,54,40,54,55,40,54,56,40,54,57,40,54,58,40,54,59,40,54,60,40,54,61,40,54,62,40,54,79,40,54,80,40,54,81,40,54,82,40,54,83,40,54,84,40,54,85,40,54,86,40,54,87,40,54,88,40,54,89,40,54,90,40,54,91,40,54,92,40,54,93,40,54,94,40,54,95,40,54,96,40,54,97,40,54,98,40,54
db 1,41,54,2,41,54,3,41,54,4,41,54,5,41,54,6,41,54,7,41,54,8,41,54,9,41,54,10,41,54,11,41,53,12,41,54,13,41,54,14,41,54,15,41,54,16,41,54,17,41,54,18,41,54,19,41,54,20,41,54,21,41,54,22,41,54,23,41,54,24,41,54,25,41,54,36,41,54,37,41,54,38,41,54,39,41,54,40,41,54,41,41,54,42,41,54,43,41,54,44,41,54,45,41,54,46,41,54,47,41,54,48,41,54,49,41,54,50,41,54,51,41,54,52,41,54,53,41,54,54,41,54,55,41,54,56,41,54,57,41,54,58,41,54,59,41,54,60,41,54,61,41,54,62,41,54,63,41,54,76,41,54,77,41,54,78,41,54,79,41,54,80,41,54,81,41,54,82,41,54,83,41,54,84,41,54,85,41,54,86,41,54,87,41,54,88,41,54,89,41,54,90,41,54,91,41,54,92,41,54,93,41,54,94,41,54,95,41,54,96,41,54,97,41,54,98,41,54
db 1,42,54,2,42,54,3,42,54,4,42,54,5,42,54,6,42,54,7,42,54,8,42,54,9,42,54,10,42,54,11,42,53,12,42,54,13,42,54,14,42,54,15,42,54,16,42,54,17,42,54,18,42,54,19,42,54,20,42,54,21,42,54,22,42,54,23,42,54,24,42,54,25,42,54,36,42,54,37,42,54,38,42,54,39,42,54,40,42,54,41,42,54,42,42,54,43,42,54,44,42,54,45,42,54,46,42,54,47,42,54,48,42,54,49,42,54,50,42,54,51,42,54,52,42,54,53,42,54,54,42,54,55,42,54,56,42,54,57,42,54,58,42,54,59,42,54,60,42,54,61,42,54,62,42,54,63,42,54,64,42,32,76,42,54,77,42,54,78,42,54,79,42,54,80,42,54,81,42,54,82,42,54,83,42,54,84,42,54,85,42,54,86,42,54,87,42,54,88,42,54,89,42,54,90,42,54,91,42,54,92,42,54,93,42,54,94,42,54,95,42,54,96,42,54,97,42,54,98,42,54
db 2,43,54,3,43,54,4,43,54,5,43,54,6,43,54,7,43,54,16,43,54,17,43,54,18,43,54,19,43,54,20,43,54,21,43,54,22,43,54,23,43,54,24,43,54,25,43,54,26,43,54,27,43,54,28,43,54,29,43,52,30,43,52,32,43,54,33,43,54,34,43,54,35,43,54,36,43,54,37,43,54,38,43,54,39,43,54,40,43,54,41,43,54,42,43,54,43,43,54,44,43,54,45,43,54,56,43,54,57,43,54,58,43,54,59,43,54,60,43,54,61,43,54,62,43,54,63,43,54,64,43,54,65,43,54,66,43,54,67,43,54,68,43,54,71,43,53,72,43,54,73,43,54,74,43,54,75,43,54,76,43,54,77,43,54,78,43,54,79,43,54,80,43,54,81,43,54,82,43,54,83,43,54,84,43,54,85,43,54,94,43,54,95,43,54,96,43,54,97,43,54,98,43,54
db 2,44,54,3,44,54,4,44,54,5,44,54,6,44,54,7,44,53,16,44,54,17,44,54,18,44,54,19,44,54,20,44,54,21,44,54,22,44,54,23,44,54,24,44,54,25,44,54,26,44,54,27,44,54,28,44,54,29,44,54,30,44,54,32,44,54,33,44,54,34,44,54,35,44,54,36,44,54,37,44,54,38,44,54,39,44,54,40,44,54,41,44,54,42,44,54,43,44,54,44,44,54,45,44,54,56,44,54,57,44,54,58,44,54,59,44,54,60,44,54,61,44,54,62,44,54,63,44,54,64,44,54,65,44,54,66,44,54,67,44,54,68,44,54,71,44,54,72,44,54,73,44,54,74,44,54,75,44,54,76,44,54,77,44,54,78,44,54,79,44,54,80,44,54,81,44,54,82,44,54,83,44,54,84,44,54,85,44,54,94,44,54,95,44,54,96,44,54,97,44,54,98,44,54
db 19,45,54,20,45,54,21,45,54,22,45,54,23,45,54,24,45,54,25,45,54,26,45,54,27,45,54,28,45,54,29,45,54,30,45,54,31,45,54,32,45,54,33,45,54,34,45,54,35,45,54,36,45,54,37,45,54,38,45,54,39,45,54,40,45,54,41,45,54,42,45,54,57,45,53,58,45,54,59,45,54,60,45,54,61,45,54,62,45,54,63,45,54,64,45,54,65,45,54,66,45,54,67,45,54,68,45,54,69,45,54,70,45,54,71,45,54,72,45,54,73,45,54,74,45,54,75,45,54,76,45,54,77,45,54,78,45,54,79,45,54,80,45,54,81,45,54,82,45,54
db 19,46,54,20,46,54,21,46,54,22,46,54,23,46,54,24,46,54,25,46,54,26,46,54,27,46,54,28,46,54,29,46,54,30,46,54,31,46,54,32,46,54,33,46,54,34,46,54,35,46,54,36,46,54,37,46,54,38,46,54,39,46,54,40,46,54,41,46,54,42,46,54,57,46,52,58,46,54,59,46,54,60,46,54,61,46,54,62,46,54,63,46,54,64,46,54,65,46,54,66,46,54,67,46,54,68,46,54,69,46,54,70,46,54,71,46,54,72,46,54,73,46,54,74,46,54,75,46,54,76,46,54,77,46,54,78,46,54,79,46,54,80,46,54,81,46,54,82,46,54
db 6,47,54,7,47,54,8,47,54,9,47,54,10,47,54,11,47,54,12,47,54,13,47,54,14,47,54,15,47,54,16,47,54,17,47,54,22,47,54,23,47,54,24,47,54,25,47,54,26,47,54,27,47,54,28,47,54,29,47,54,30,47,54,31,47,54,32,47,54,33,47,54,34,47,54,35,47,54,36,47,54,37,47,54,38,47,54,44,47,54,45,47,54,46,47,54,47,47,54,48,47,54,49,47,54,50,47,54,51,47,54,52,47,54,53,47,54,54,47,54,55,47,54,61,47,54,62,47,54,63,47,54,64,47,54,65,47,54,66,47,54,67,47,54,68,47,54,69,47,54,70,47,54,71,47,54,72,47,54,73,47,54,74,47,54,75,47,54,76,47,54,77,47,54,78,47,54,84,47,54,85,47,54,86,47,54,87,47,54,88,47,54,89,47,54,90,47,54,91,47,54,92,47,54,93,47,54,94,47,54,95,47,52
db 6,48,54,7,48,54,8,48,54,9,48,54,10,48,54,11,48,54,12,48,54,13,48,54,14,48,54,15,48,54,16,48,54,17,48,54,22,48,54,23,48,54,24,48,54,25,48,54,26,48,54,27,48,54,28,48,54,29,48,54,30,48,54,31,48,54,32,48,54,33,48,54,34,48,54,35,48,54,36,48,54,37,48,54,38,48,54,44,48,54,45,48,54,46,48,54,47,48,54,48,48,54,49,48,54,50,48,54,51,48,54,52,48,54,53,48,54,54,48,54,55,48,54,56,48,32,61,48,54,62,48,54,63,48,54,64,48,54,65,48,54,66,48,54,67,48,54,68,48,54,69,48,54,70,48,54,71,48,54,72,48,54,73,48,54,74,48,54,75,48,54,76,48,54,77,48,54,78,48,54,84,48,54,85,48,54,86,48,54,87,48,54,88,48,54,89,48,54,90,48,54,91,48,54,92,48,54,93,48,54,94,48,54,95,48,54
db 2,49,54,3,49,54,4,49,54,5,49,54,6,49,54,7,49,54,8,49,54,9,49,54,10,49,54,11,49,54,12,49,54,13,49,54,14,49,54,15,49,54,16,49,54,17,49,54,18,49,54,19,49,54,20,49,54,25,49,32,26,49,54,27,49,54,28,49,54,29,49,54,30,49,54,31,49,54,32,49,54,33,49,54,34,49,54,35,49,54,41,49,54,42,49,54,43,49,54,44,49,54,45,49,54,46,49,54,47,49,54,48,49,54,49,49,54,50,49,54,51,49,54,52,49,54,53,49,54,54,49,54,55,49,54,56,49,54,57,49,54,58,49,54,59,49,54,60,49,54,66,49,54,67,49,54,68,49,54,69,49,54,70,49,54,71,49,54,72,49,54,73,49,54,74,49,54,75,49,54,81,49,54,82,49,54,83,49,54,84,49,54,85,49,54,86,49,54,87,49,54,88,49,54,89,49,54,90,49,54,91,49,54,92,49,54,93,49,54,94,49,54,95,49,54,96,49,54,97,49,54,98,49,54
db 2,50,54,3,50,54,4,50,54,5,50,54,6,50,54,7,50,54,8,50,54,9,50,54,10,50,54,11,50,54,12,50,54,13,50,54,14,50,54,15,50,54,16,50,54,17,50,54,18,50,54,19,50,54,20,50,54,26,50,54,27,50,54,28,50,54,29,50,54,30,50,54,31,50,54,32,50,54,33,50,54,34,50,54,35,50,54,41,50,54,42,50,54,43,50,54,44,50,54,45,50,54,46,50,54,47,50,54,48,50,54,49,50,54,50,50,54,51,50,54,52,50,54,53,50,54,54,50,54,55,50,54,56,50,54,57,50,54,58,50,54,59,50,54,60,50,53,66,50,54,67,50,54,68,50,54,69,50,54,70,50,54,71,50,54,72,50,54,73,50,54,74,50,54,75,50,54,81,50,54,82,50,54,83,50,54,84,50,54,85,50,54,86,50,54,87,50,54,88,50,54,89,50,54,90,50,54,91,50,54,92,50,54,93,50,54,94,50,54,95,50,54,96,50,54,97,50,54,98,50,54
db 1,51,54,2,51,54,3,51,54,4,51,54,5,51,54,6,51,54,7,51,54,8,51,54,9,51,54,10,51,54,11,51,54,12,51,54,13,51,54,14,51,54,15,51,54,16,51,54,17,51,54,18,51,54,19,51,54,20,51,54,21,51,54,22,51,54,39,51,54,40,51,54,41,51,54,42,51,54,43,51,54,44,51,54,45,51,54,46,51,54,47,51,54,48,51,54,49,51,54,50,51,54,51,51,54,52,51,54,53,51,54,54,51,54,55,51,54,56,51,54,57,51,54,58,51,54,59,51,54,60,51,54,61,51,54,62,51,54,79,51,54,80,51,54,81,51,54,82,51,54,83,51,54,84,51,54,85,51,54,86,51,54,87,51,54,88,51,54,89,51,54,90,51,54,91,51,54,92,51,54,93,51,54,94,51,54,95,51,54,96,51,54,97,51,54,98,51,54
db 1,52,54,2,52,54,3,52,54,4,52,54,5,52,54,6,52,54,7,52,54,8,52,54,9,52,54,10,52,54,11,52,54,12,52,54,13,52,54,14,52,54,15,52,54,16,52,54,17,52,54,18,52,54,19,52,54,20,52,54,21,52,54,22,52,54,39,52,54,40,52,54,41,52,54,42,52,54,43,52,54,44,52,54,45,52,54,46,52,54,47,52,54,48,52,54,49,52,54,50,52,54,51,52,54,52,52,54,53,52,54,54,52,54,55,52,54,56,52,54,57,52,54,58,52,54,59,52,54,60,52,54,61,52,54,62,52,54,79,52,54,80,52,54,81,52,54,82,52,54,83,52,54,84,52,54,85,52,54,86,52,54,87,52,54,88,52,54,89,52,54,90,52,54,91,52,54,92,52,54,93,52,54,94,52,54,95,52,54,96,52,54,97,52,54,98,52,54
db 1,53,54,2,53,54,3,53,54,4,53,54,5,53,54,6,53,54,7,53,54,8,53,54,9,53,54,10,53,54,12,53,52,13,53,54,14,53,54,15,53,54,16,53,54,17,53,54,18,53,54,19,53,54,20,53,54,21,53,54,22,53,54,23,53,54,24,53,54,25,53,54,36,53,54,37,53,54,38,53,54,39,53,54,40,53,54,41,53,54,42,53,54,43,53,54,44,53,54,45,53,54,46,53,54,47,53,54,48,53,54,49,53,32,52,53,54,53,53,54,54,53,54,55,53,54,56,53,54,57,53,54,58,53,54,59,53,54,60,53,54,61,53,54,62,53,54,63,53,54,64,53,54,65,53,54,76,53,54,77,53,54,78,53,54,79,53,54,80,53,54,81,53,54,82,53,54,83,53,54,84,53,54,85,53,54,86,53,54,87,53,54,88,53,54,91,53,54,92,53,54,93,53,54,94,53,54,95,53,54,96,53,54,97,53,54,98,53,54
db 1,54,54,2,54,54,3,54,54,4,54,54,5,54,54,6,54,54,7,54,54,8,54,54,9,54,54,10,54,52,12,54,32,13,54,54,14,54,54,15,54,54,16,54,54,17,54,54,18,54,54,19,54,54,20,54,54,21,54,54,22,54,54,23,54,54,24,54,54,25,54,54,26,54,32,36,54,54,37,54,54,38,54,54,39,54,54,40,54,54,41,54,54,42,54,54,43,54,54,44,54,54,45,54,54,46,54,54,47,54,54,48,54,54,52,54,54,53,54,54,54,54,54,55,54,54,56,54,54,57,54,54,58,54,54,59,54,54,60,54,54,61,54,54,62,54,54,63,54,54,64,54,54,65,54,54,75,54,32,76,54,54,77,54,54,78,54,54,79,54,54,80,54,54,81,54,54,82,54,54,83,54,54,84,54,54,85,54,54,86,54,54,87,54,54,88,54,52,91,54,54,92,54,54,93,54,54,94,54,54,95,54,54,96,54,54,97,54,54,98,54,54
db 2,55,54,3,55,54,4,55,54,5,55,54,17,55,54,18,55,54,19,55,54,20,55,54,21,55,54,22,55,54,23,55,54,24,55,54,25,55,54,26,55,54,27,55,54,28,55,54,29,55,54,30,55,54,31,55,54,32,55,54,33,55,54,34,55,54,35,55,54,36,55,54,37,55,54,38,55,54,39,55,54,40,55,54,41,55,54,42,55,54,43,55,54,56,55,54,57,55,54,58,55,54,59,55,54,60,55,54,61,55,54,62,55,54,63,55,54,64,55,54,65,55,54,66,55,54,67,55,54,68,55,54,69,55,54,70,55,54,71,55,54,72,55,54,73,55,54,74,55,54,75,55,54,76,55,54,77,55,54,78,55,54,79,55,54,80,55,54,81,55,54,82,55,54,83,55,54,84,55,52,94,55,54,95,55,54,96,55,54,97,55,54,98,55,54
db 2,56,54,3,56,54,4,56,54,5,56,54,17,56,54,18,56,54,19,56,54,20,56,54,21,56,54,22,56,54,23,56,54,24,56,54,25,56,54,26,56,54,27,56,54,28,56,54,29,56,54,30,56,54,31,56,54,32,56,54,33,56,54,34,56,54,35,56,54,36,56,54,37,56,54,38,56,54,39,56,54,40,56,54,41,56,54,42,56,54,43,56,54,56,56,54,57,56,54,58,56,54,59,56,54,60,56,54,61,56,54,62,56,54,63,56,54,64,56,54,65,56,54,66,56,54,67,56,54,68,56,54,69,56,54,70,56,54,71,56,54,72,56,54,73,56,54,74,56,54,75,56,54,76,56,54,77,56,54,78,56,54,79,56,54,80,56,54,81,56,54,82,56,54,83,56,54,94,56,54,95,56,54,96,56,54,97,56,54,98,56,53
db 19,57,54,20,57,54,21,57,54,22,57,54,23,57,54,24,57,54,25,57,54,26,57,54,27,57,54,28,57,54,29,57,54,30,57,54,31,57,54,32,57,54,33,57,54,34,57,54,35,57,54,36,57,54,37,57,54,38,57,54,39,57,54,40,57,54,41,57,54,42,57,54,59,57,54,60,57,54,61,57,54,62,57,54,63,57,54,64,57,54,65,57,54,66,57,54,67,57,54,68,57,54,69,57,54,70,57,54,71,57,54,72,57,54,73,57,54,74,57,54,75,57,54,76,57,54,77,57,54,78,57,54,79,57,54,80,57,54,81,57,54,82,57,54
db 19,58,54,20,58,54,21,58,54,22,58,54,23,58,54,24,58,54,25,58,54,26,58,54,27,58,54,28,58,54,29,58,54,30,58,54,31,58,54,32,58,54,33,58,54,34,58,54,35,58,54,36,58,54,37,58,54,38,58,54,39,58,54,40,58,54,41,58,54,42,58,54,59,58,54,60,58,54,61,58,54,62,58,54,63,58,54,64,58,54,65,58,54,66,58,54,67,58,54,68,58,54,69,58,54,70,58,54,71,58,54,72,58,54,73,58,54,74,58,54,75,58,54,76,58,54,77,58,54,78,58,54,79,58,54,80,58,54,81,58,54,82,58,54
db 6,59,54,7,59,54,8,59,54,9,59,54,10,59,54,11,59,54,12,59,54,13,59,54,14,59,54,15,59,54,16,59,54,17,59,54,22,59,54,23,59,54,24,59,54,25,59,54,26,59,54,27,59,54,28,59,54,29,59,54,30,59,54,31,59,54,32,59,54,33,59,54,34,59,54,35,59,54,36,59,54,37,59,54,38,59,54,39,59,32,44,59,54,45,59,54,46,59,54,47,59,54,48,59,54,49,59,54,50,59,54,51,59,54,52,59,54,53,59,54,54,59,54,55,59,54,56,59,54,57,59,54,61,59,53,62,59,54,63,59,54,64,59,54,65,59,54,66,59,54,67,59,54,68,59,54,69,59,54,70,59,54,71,59,54,72,59,54,73,59,54,74,59,54,75,59,54,76,59,54,77,59,54,78,59,54,84,59,54,85,59,54,86,59,54,87,59,54,88,59,54,89,59,54,90,59,54,91,59,54,92,59,54,93,59,54,94,59,54,95,59,54
db 6,60,54,7,60,54,8,60,54,9,60,54,10,60,54,11,60,54,12,60,54,13,60,54,14,60,54,15,60,54,16,60,54,17,60,54,22,60,54,23,60,54,24,60,54,25,60,54,26,60,54,27,60,54,28,60,54,29,60,54,30,60,54,31,60,54,32,60,54,33,60,54,34,60,54,35,60,54,36,60,54,37,60,54,38,60,54,44,60,54,45,60,54,46,60,54,47,60,54,48,60,54,49,60,54,50,60,54,51,60,54,52,60,54,53,60,54,54,60,54,55,60,54,56,60,54,57,60,54,61,60,52,62,60,54,63,60,54,64,60,54,65,60,54,66,60,54,67,60,54,68,60,54,69,60,54,70,60,54,71,60,54,72,60,54,73,60,54,74,60,54,75,60,54,76,60,54,77,60,54,78,60,54,84,60,54,85,60,54,86,60,54,87,60,54,88,60,54,89,60,54,90,60,54,91,60,54,92,60,54,93,60,54,94,60,54,95,60,54
db 2,61,54,3,61,54,4,61,54,5,61,54,6,61,54,7,61,54,8,61,54,9,61,54,10,61,54,11,61,54,12,61,54,13,61,54,14,61,54,15,61,54,16,61,54,17,61,54,18,61,54,19,61,54,20,61,54,27,61,54,28,61,54,29,61,54,30,61,54,31,61,54,32,61,54,33,61,54,34,61,52,41,61,54,42,61,54,43,61,54,44,61,54,45,61,54,46,61,54,47,61,54,48,61,54,49,61,54,50,61,54,51,61,54,52,61,54,53,61,54,54,61,54,55,61,54,56,61,54,57,61,54,58,61,54,59,61,54,60,61,54,66,61,54,67,61,54,68,61,54,69,61,54,70,61,54,71,61,54,72,61,54,73,61,54,81,61,54,82,61,54,83,61,54,84,61,54,85,61,54,86,61,54,87,61,54,88,61,54,89,61,54,90,61,54,91,61,54,92,61,54,93,61,54,94,61,54,95,61,54,96,61,54,97,61,54,98,61,54
db 2,62,54,3,62,54,4,62,54,5,62,54,6,62,54,7,62,54,8,62,54,9,62,54,10,62,54,11,62,54,12,62,54,13,62,54,14,62,54,15,62,54,16,62,54,17,62,54,18,62,54,19,62,54,20,62,54,21,62,52,27,62,52,28,62,54,29,62,54,30,62,54,31,62,54,32,62,54,33,62,54,41,62,54,42,62,54,43,62,54,44,62,54,45,62,54,46,62,54,47,62,54,48,62,54,49,62,54,50,62,54,51,62,54,52,62,54,53,62,54,54,62,54,55,62,54,56,62,54,57,62,54,58,62,54,59,62,54,60,62,54,66,62,54,67,62,54,68,62,54,69,62,54,70,62,54,71,62,54,72,62,54,73,62,54,80,62,32,81,62,54,82,62,54,83,62,54,84,62,54,85,62,54,86,62,54,87,62,54,88,62,54,89,62,54,90,62,54,91,62,54,92,62,54,93,62,54,94,62,54,95,62,54,96,62,54,97,62,54,98,62,54
db 1,63,54,2,63,54,3,63,54,4,63,54,5,63,54,6,63,54,7,63,54,8,63,54,9,63,54,10,63,54,11,63,54,12,63,54,13,63,54,14,63,54,15,63,54,16,63,54,17,63,54,18,63,54,19,63,54,20,63,54,21,63,54,22,63,54,23,63,54,37,63,53,38,63,54,39,63,54,40,63,54,41,63,54,42,63,54,43,63,54,44,63,54,45,63,54,46,63,54,47,63,54,48,63,54,49,63,54,50,63,54,51,63,54,52,63,54,53,63,54,54,63,54,55,63,54,56,63,54,57,63,54,58,63,54,59,63,54,60,63,54,61,63,54,62,63,54,77,63,54,78,63,54,79,63,54,80,63,54,81,63,54,82,63,54,83,63,54,84,63,54,85,63,54,86,63,54,87,63,54,88,63,54,89,63,54,90,63,54,91,63,54,92,63,54,93,63,54,94,63,54,95,63,54,96,63,54,97,63,54,98,63,54
db 1,64,54,2,64,54,3,64,54,4,64,54,5,64,54,6,64,54,7,64,54,8,64,54,9,64,54,10,64,54,11,64,54,12,64,54,13,64,54,14,64,54,15,64,54,16,64,54,17,64,54,18,64,54,19,64,54,20,64,54,21,64,54,22,64,54,23,64,54,37,64,54,38,64,54,39,64,54,40,64,54,41,64,54,42,64,54,43,64,54,44,64,54,45,64,54,46,64,54,47,64,54,48,64,54,49,64,54,50,64,54,51,64,54,52,64,54,53,64,54,54,64,54,55,64,54,56,64,54,57,64,54,58,64,54,59,64,54,60,64,54,61,64,54,62,64,54,77,64,54,78,64,54,79,64,54,80,64,54,81,64,54,82,64,54,83,64,54,84,64,54,85,64,54,86,64,54,87,64,54,88,64,54,89,64,54,90,64,54,91,64,54,92,64,54,93,64,54,94,64,54,95,64,54,96,64,54,97,64,54,98,64,54
db 1,65,54,2,65,54,3,65,54,4,65,54,5,65,54,6,65,54,7,65,54,8,65,54,14,65,54,15,65,54,16,65,54,17,65,54,18,65,54,19,65,54,20,65,54,21,65,54,22,65,54,23,65,54,24,65,54,25,65,54,26,65,54,27,65,54,34,65,48,35,65,50,36,65,54,37,65,54,38,65,54,39,65,54,40,65,54,41,65,54,42,65,54,43,65,54,44,65,54,45,65,54,46,65,54,47,65,54,54,65,54,55,65,54,56,65,54,57,65,54,58,65,54,59,65,54,60,65,54,61,65,54,62,65,54,63,65,54,64,65,54,65,65,54,74,65,54,75,65,54,76,65,54,77,65,54,78,65,54,79,65,54,80,65,54,81,65,54,82,65,54,83,65,54,84,65,54,85,65,54,86,65,54,87,65,54,92,65,54,93,65,54,94,65,54,95,65,54,96,65,54,97,65,54,98,65,54
db 1,66,54,2,66,54,3,66,54,4,66,54,5,66,54,6,66,54,7,66,54,8,66,54,14,66,54,15,66,54,16,66,54,17,66,54,18,66,54,19,66,54,20,66,54,21,66,54,22,66,54,23,66,54,24,66,54,25,66,54,26,66,54,27,66,54,34,66,52,35,66,51,36,66,54,37,66,54,38,66,54,39,66,54,40,66,54,41,66,54,42,66,54,43,66,54,44,66,54,45,66,54,46,66,54,47,66,54,54,66,54,55,66,54,56,66,54,57,66,54,58,66,54,59,66,54,60,66,54,61,66,54,62,66,54,63,66,54,64,66,54,65,66,54,66,66,32,74,66,54,75,66,54,76,66,54,77,66,54,78,66,54,79,66,54,80,66,54,81,66,54,82,66,54,83,66,54,84,66,54,85,66,54,86,66,54,87,66,54,92,66,54,93,66,54,94,66,54,95,66,54,96,66,54,97,66,54,98,66,54
db 2,67,54,3,67,54,4,67,54,5,67,54,17,67,54,18,67,54,19,67,54,20,67,54,21,67,54,22,67,54,23,67,54,24,67,54,25,67,54,26,67,54,27,67,54,28,67,54,29,67,54,30,67,54,31,67,54,32,67,54,33,67,54,34,67,54,35,67,54,36,67,54,37,67,54,38,67,54,39,67,54,40,67,54,41,67,54,42,67,54,43,67,54,57,67,54,58,67,54,59,67,54,60,67,54,61,67,54,62,67,54,63,67,54,64,67,54,65,67,54,66,67,54,67,67,54,68,67,54,69,67,54,70,67,54,71,67,54,72,67,54,73,67,54,74,67,54,75,67,54,76,67,54,77,67,54,78,67,54,79,67,54,80,67,54,81,67,54,82,67,54,83,67,54,94,67,54,95,67,54,96,67,54,97,67,32
db 2,68,54,3,68,54,4,68,54,5,68,54,17,68,54,18,68,54,19,68,54,20,68,54,21,68,54,22,68,54,23,68,54,24,68,54,25,68,54,26,68,54,27,68,54,28,68,54,29,68,54,30,68,54,31,68,54,32,68,54,33,68,54,34,68,54,35,68,54,36,68,54,37,68,54,38,68,54,39,68,54,40,68,54,41,68,54,42,68,54,43,68,54,57,68,54,58,68,54,59,68,54,60,68,54,61,68,54,62,68,54,63,68,54,64,68,54,65,68,54,66,68,54,67,68,54,68,68,54,69,68,54,70,68,54,71,68,54,72,68,54,73,68,54,74,68,54,75,68,54,76,68,54,77,68,54,78,68,54,79,68,54,80,68,54,81,68,54,82,68,54,83,68,54,94,68,32,95,68,54,96,68,54
db 19,69,52,20,69,54,21,69,54,22,69,54,23,69,54,24,69,54,25,69,54,26,69,54,27,69,54,28,69,54,29,69,54,30,69,54,31,69,54,32,69,54,33,69,54,34,69,54,35,69,54,36,69,54,37,69,54,38,69,54,39,69,54,40,69,54,41,69,54,42,69,54,59,69,54,60,69,54,61,69,54,62,69,54,63,69,54,64,69,54,65,69,54,66,69,54,67,69,54,68,69,54,69,69,54,70,69,54,71,69,54,72,69,54,73,69,54,74,69,54,75,69,54,76,69,54,77,69,54,78,69,54,79,69,54,80,69,54,81,69,54,82,69,54
db 19,70,32,20,70,54,21,70,54,22,70,54,23,70,54,24,70,54,25,70,54,26,70,54,27,70,54,28,70,54,29,70,54,30,70,54,31,70,54,32,70,54,33,70,54,34,70,54,35,70,54,36,70,54,37,70,54,38,70,54,39,70,54,40,70,54,41,70,53,42,70,54,59,70,54,60,70,54,61,70,54,62,70,54,63,70,54,64,70,54,65,70,54,66,70,54,67,70,54,68,70,54,69,70,54,70,70,54,71,70,54,72,70,54,73,70,54,74,70,54,75,70,54,76,70,54,77,70,54,78,70,54,79,70,54,80,70,54,81,70,54,82,70,32
db 22,71,54,23,71,54,24,71,54,25,71,54,26,71,54,27,71,54,28,71,54,29,71,54,30,71,54,31,71,54,32,71,54,33,71,54,34,71,54,35,71,54,36,71,54,37,71,54,38,71,54,62,71,54,63,71,54,64,71,54,65,71,54,66,71,54,67,71,54,68,71,54,69,71,54,70,71,54,71,71,54,72,71,54,73,71,54,74,71,54,75,71,54,76,71,54,77,71,54,78,71,54
db 22,72,52,23,72,54,24,72,54,25,72,54,26,72,54,27,72,54,28,72,54,29,72,54,30,72,54,31,72,54,32,72,54,33,72,54,34,72,54,35,72,54,36,72,54,37,72,54,38,72,54,62,72,54,63,72,54,64,72,54,65,72,54,66,72,54,67,72,54,68,72,54,69,72,54,70,72,54,71,72,54,72,72,54,73,72,54,74,72,54,75,72,54,76,72,54,77,72,54,78,72,54
db 28,73,52,29,73,52,30,73,32,31,73,32,32,73,54,33,73,32,70,73,52,71,73,52,72,73,54,73,73,32
db 29,74,32,31,74,32,32,74,32,71,74,32,72,74,32

waveSize dw 100 
         
 
   VAR1 DW ?
   VAR2 DW ?
   Varbp dw ?
   Msg db "Please Enter Your Name",'$'
   Msg2 db "PLease Enter Any Key To continue",'$'
   position dw 0C02h
    ;;;;
    PADDLE_LEFT_X DW 0Ah
	PADDLE_LEFT_Y DW 0Ah
	
	PADDLE_RIGHT_X DW 130h
	PADDLE_RIGHT_Y DW 0Ah
	
	PADDLE_WIDTH DW 05h
	PADDLE_HEIGHT DW 1Fh
    PADDEL_VECLOITY DW 05H


.CODE 

	MAIN PROC FAR
      MOV         AX,@DATA
	 mov         ds,ax
     CALL CLEAR_SCREEN
     
      mov ah,02h
       mov DX, position
      int 10h
	   DisplayString Msg
      
      ; endl
       DisplayString Msg2
		
	     CALL CLEAR_SCREEN
           blankScreen 15
         staticWave 100,160
         Check: mov ah,2ch
                     int 21h ; CH = hour CL = minute DH = second DL = 1/100 seconds
                     CMP DL,Time
                     je Check
                     mov Time,dl
		 			CALL CLEAR_SCREEN  
                       blankScreen 15
                      staticWave 100,160
                         mov bp,0h
                         Drawnewball: 
                             ;six balls    
                             lea si,BALLX
                             lea di,BALLY
                         try: 
                          mov VAR1,si ; store index  position of x
                          mov var2,di ; store index position of y
                          mov Varbp,bp
                          CALL MOVE_BALL  ; here si,di changes so i need to know where was my postion so i can get it from var1,var2
                    				  
                                  mov si,var1 ; index position of x
                                  mov di,var2 ; index postion of y
                                  add si,2h ; next index of x
                                  add di,2h ;next index of y
                              add bp,2  ; counter
                              cmp bp,0Ch  ;size of array              
                              jl try
					
                          mov bp,0           ;draw
                          lea si,BALLX
                        lea di,BALLY
                         try1: 
    
                            mov VAR1,si
                            mov var2,di
                        	CALL DRAWBALL
                            mov si,var1
                            mov di,var2
                            add si,2h
                            add di,2h
                            add bp,2
                            cmp bp,0Ch          
                            jL try1
                            mov bp,0h
                            lea si,BALLX
                            lea di,BALLY
                            Jmp check
		
	MAIN ENDP
	drawBall proc near
   mov ah,0ch
    mov bx, offset ball
    whilePixels:
       drawDynamicPixel [bx],[bx+1],[bx+2],[di], [si]
       add bx,3
       cmp bx,offset Ball_Size
    JNE whilePixels
   ret
   drawBall endp
	MOVE_BALL PROC NEAR
     
		mov bx,Varbp
		MOV AX,VecloictyX+bx  
		ADD [si],AX             ;move the ball horizontally
		
		MOV AX,WINDOW_BOUNDS
		CMP  [si],AX                         
		JL NEG_VELOCITY_X         ;BALL_X < 0 + WINDOW_BOUNDS (Y -> collided)
		
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP [si],AX	          ;BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS (Y -> collided)
		JG NEG_VELOCITY_X
		
		
		MOV AX,VecloictyY+bx
		ADD [di],AX             ;move the ball vertically
		
		MOV AX,WINDOW_BOUNDS
		CMP [di],AX   ;BALL_Y < 0 + WINDOW_BOUNDS (Y -> collided)
		JL NEG_VELOCITY_Y                          
		
		MOV AX,WINDOW_HEIGHT	
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP [di],AX
		JG NEG_VELOCITY_Y		  ;BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS (Y -> collided)
		
		RET
		
		NEG_VELOCITY_X:
			NEG VecloictyX+bx   ;BALL_VELOCITY_X = - BALL_VELOCITY_X
			RET
			
		NEG_VELOCITY_Y:
			NEG VecloictyY+bx   ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			RET
		
	MOVE_BALL ENDP
	
	DRAW_BALL PROC NEAR
		 MOV CX,[si] ;set the column (X)
	     MOV DX,[di] ;set the line (Y)
	
		DRAW_BALL_HORIZONTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     ;CX = CX + 1
			MOV AX,CX          ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,[si]
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
			
			MOV CX,[si] ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			
			MOV AX,DX              ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,[di]
			CMP AX,BALL_SIZE
			JNG DRAW_BALL_HORIZONTAL
		
		RET
	DRAW_BALL ENDP
	
CLEAR_SCREEN PROC NEAR
			MOV AH,00h ;set the configuration to video mode
			MOV AL,13h ;choose the video mode
			INT 10h    ;execute the configuration 
		
			MOV AH,0Bh ;set the configuration
			MOV BH,00h ;to the background color
			MOV BL,00h ;choose black as background color
			INT 10h    ;execute the configuration
			
			RET
CLEAR_SCREEN ENDP

MOve_Paddel PROC
    mov ah,01h
    int 16h
    JZ CHECK_RIGHT
    mov ah,00h
    int 16h
    CMP AL,77h ;'w'
    je MOVE_UP
    CMP AL, 73h ;'s'
    je MOVE_DOWN
    
   MOVE_UP:
        MOV AX,PADDEL_VECLOITY
        sub PADDLE_LEFT_Y,AX
        MOV AX,WINDOW_BOUNDS
        CMP PADDLE_LEFT_Y,AX
        JL FIX_PADDEL
        jmp CHECK_RIGHT
          
      
   MOVE_DOWN:
        MOV AX,PADDEL_VECLOITY
        add PADDLE_LEFT_Y,AX
        
        mov ax,Window_height
        sub ax,WINDOW_BOUNDS
        sub ax,PADDLE_HEIGHT
        cmp PADDLE_LEFT_Y,ax
        jg FIX_PADDEL2
        jmp CHECK_RIGHT
          

   
    
   FIX_PADDEL: mov ax,WINDOW_BOUNDS
               mov PADDLE_LEFT_Y,ax
                jmp CHECK_RIGHT
   
   FIX_PADDEL2: MOV PADDLE_LEFT_Y,AX
    
    CHECK_RIGHT:  
    mov ah,01h
    int 16h
    jz close
    mov ah,00h
    int 16h
    CMP AL,70h ;'p'
    je MOVE_UP1
    CMP AL, 6ch ;'l'
    je MOVE_DOWN1
    RET
   MOVE_UP1:
        MOV AX,PADDEL_VECLOITY
        sub PADDLE_RIGHT_Y,AX
        MOV AX,WINDOW_BOUNDS
        CMP PADDLE_RIGHT_Y,AX
        JL FIX_PADDEL1
          RET
      
   MOVE_DOWN1:
        MOV AX,PADDEL_VECLOITY
        add PADDLE_RIGHT_Y,AX
        
        mov ax,Window_height
        sub ax,WINDOW_BOUNDS
        sub ax,PADDLE_HEIGHT
        cmp PADDLE_RIGHT_Y,ax
        jg FIX_PADDEL22
        RET
    FIX_PADDEL1: mov ax,WINDOW_BOUNDS
               mov PADDLE_right_Y,ax
                RET
   
    FIX_PADDEL22: MOV PADDLE_right_Y,AX

    close:     
       RET
                
    
MOve_Paddel ENDP


END MAIN
  
