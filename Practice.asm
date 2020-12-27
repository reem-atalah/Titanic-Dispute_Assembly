DisplayString macro Stringo
    mov AH,09h
    mov dx,offset Stringo
    int 21h
ENDM DisplayString

DisplayCharacter macro Char
    mov dl, Char
    mov ah, 2h
    int 21h
ENDM DisplayCharacter

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

DisplayAx macro
   pusha
   mov     bx,10            ;This is our divisor, by diving by 10 everytime we move the LSB to Dx and the rest of the number(Quotient) stays in Ax
   xor     cx,cx            ;Reset counter

    whileQuotient: 
        xor     dx,dx          ;Setup for division DX:AX / BX
        div     bx             ;AX is Quotient, Remainder DX=[0,9]
        push    dx             ;Save remainder(LSB) for now
        inc     cx             ;To keep track of the no. of digits
    test    ax,ax          ;To check if the quotient is zero, test is ANDs the inputs but then discards the result
    jnz whileQuotient      ;No, use as next dividend 

    whileCx: 
        pop     dx             ;(1)
        add     dl,"0"         ;Converting the digit to its correct ASCII code
        mov     ah,02h         ;Displaying the character
        int     21h            ; -> AL
    dec cx
    jnz WhileCx
    popa
ENDM DisplayAx

setTextCursor macro Coordinates
    pusha
    mov ah,02h
    mov DX, Coordinates
    int 10h
    popa
ENDM setTextCursor

clearScreen macro 
    mov ax,0600h
    mov dx,2479h
    mov cx,0
    mov bh,07
    int 10h
ENDM clearScreen

graphicsMode macro Mode
    mov ah,00h
    mov al,Mode
    int 10h
ENDM graphicsMode

drawPixel macro color, row, column
    mov ah,0ch
    mov bh,00h ;Page no.
    mov al,color
    mov dx,row
    mov cx,column
    int 10h
ENDM drawPixel
        ;Assumes that mov ah, 0ch was priorly done.
        
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


drawPixel_implicit macro color ;Assumes that spatial parameters are already initialized.
    mov ah,0ch
    mov bh,00h ;Page no.
    mov al,color
    int 10h
ENDM drawPixel_implicit

return macro
    int 20h
ENDM return

Delay macro timeH,timeL ;TimeHTimeL represents the no. of microseconds
    pusha
    mov cx,timeH
    mov dx,timeL
    mov ah,86h
    int 15h
    popa
ENDM Delay

checkPossibleKey macro ; RETURNS cl=0 : NO KEY PRESSED, cl!=0 : KEY PRESSED.
  push ax
  mov ah, 0bh
  int 21h      
  mov cl,al
  pop ax
  test cl,cl
ENDM checkPossibleKey

getkeyboardStatus macro ;	ZF = 0 if a key pressed, AX = 0 if no scan code is available otherwise AX=[ScanCode][ASCII], does not interrupt the program.
    ;push ax 
    mov ah,1
    int 16h
    ;pop ax
ENDM getKeyboardStatus

readKey macro ;halts program until a key is present in the keyboard buffer to consume, reads the scan code on Ah and the ASCII on AL.
    ;push ax
    mov ah,0
    int 16h
    ;pop ax
ENDM readKey

check macro
    push ax
    mov ah,01h
    int 16h
    pop ax
ENDM check

setBackgroundColor macro color ;Does not work.
    mov ah,0bh
    mov bh,00h ;BH = palette color ID= 0 to set background and border color, = 1 to select 4 color palette
    mov bl,color ;color or palette value
    int 10h
ENDM setBackgroundColor

blankScreen macro color
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,color  ;color to blank the screen with
	mov cx,0000h  ;start from row 0, column 0
	mov dx,184fh ;to the end of the screen
	int 10h
ENDM blankScreen

checKDifference macro A,B,C ;checks if A-B=C and yields 0 if that's true
push ax
            mov ax,A
            sub ax,B
            cmp ax,C
pop ax
ENDM checKDifference
        
checkTimePassed macro previous_time ;CH = hour CL = minute DH = second DL = 1/100 seconds
    mov ah,2ch
    int 21h ;gets the current time
    cmp dl,previous_time ;checks if a centisecond has passed and returns zero in that case
endm getSystemTime 



Motion macro V_x, V_y ;Pass horizontal and vertical velocities (i.e. position changes that should applied every centisecond in the main loop)

    ;Trigger the desired motion along x
    mov ax,V_x
    add S_x,ax ;Add V_x to S_x (done every centisecond >> velocity)

    ;Check vertical walls and do necessary action if colliding with any
    cmp S_x,10h
    JL Disappear
    cmp S_x,310;320 (from resolution)-Ball_size - some_margin
    JG Disappear

    ;Trigger the desired motion along y
    mov ax,V_y ;Moving the ball for 5 pixels along y=x whenever a centisecond passes (velocity = 5 px/cs)
    add S_y,ax
   ;check horizontal walls and do necessary action if colliding with any
    cmp S_y,10h
    JL Reverse_Velocity_Y
    cmp S_y,170 ;200 (from resolution) - Ball_size - some_margin
    JG Reverse_Velocity_Y

    call checkRightShieldCollisions ;Escapes to done if non detected, does necessary action otherwise
    call checkLeftShieldCollisions ;Escapes to next check if non detected, does necessary action otherwise

JMP Done ;If none of the above was satisfied, do nothing.
    
    ;But in case any was satisified:
        Reverse_Velocity_X:
        neg V_x ;Finding the 2's complementing (multiplying by -1)
        JMP Done

        Reverse_Velocity_Y:
        neg V_y
        JMP Done

        Reset_Position: ;Don't think we'll need this
            resetPosition 0,0
            JMP Done 

        Disappear:
            mov al,00h
            mov colorBall,al

    Done:

endm Motion



drawShield macro P_x, P_y;The last one is just a label
        local whileShieldweingDrawn
        ;Setting up the initial pixel
        mov cx,P_x
        mov dx,P_y
        whileShieldweingDrawn:
            drawPixel_implicit colorShield
            inc cx ;the x-coordinate
            checkDifference cx, P_x, P_width
         JNG whileShieldweingDrawn ;Keep adding Pixels till Cx-S_x=ball_size
            mov cx, P_x
            inc dx
            checkDifference dx, P_y, P_Height
        JNG whileShieldweingDrawn
endm drawShield



shieldControl macro P_y, upKey, downKey ;Takes the dimension that we would like to control, and the two keys using for controling that dimension
    local Read, movesUp, movesDown, resetPositionHigh, resetPositionLow, None
    ;So for vertical motion of the left shield pass Pl_y and vice versa.
    ;Check if any key is pressed, if yes then check if it's w, W or s, S for the former move up and for the latter move down, check collisions with upper and lower boundaries for each.
    getKeyboardStatus
    JZ None ;No key was pressed, see if any neccessary action is needed.
        readKey ;else key was pressed
        cmp Ah,upKey ;Left
        JE movesUp
        cmp Ah,downKey ;Right
        JE movesDown
        JMP None ;Do nothing if any other key was pressed.


    movesUp:
        mov ax,P_Velocity
        sub P_y, ax
        ;Check collisions with y=0
        cmp P_y,0
        Jl resetPositionHigh
        JMP None

    movesDown:
        mov ax,P_velocity
        add P_y, ax
        ;Check collisions with y=windowHeight-shieldHight
        cmp P_y,150
        JG resetPositionLow
        JMP None

    resetPositionHigh:
    ;Attempt to surpass y=0: reset position to y=0
        mov ax,0
        mov P_y,ax
        JMP None

    resetPositionLow:
    ;Attempt to surpass y=200 (the bottom pixel): reset position to y=200 
        mov ax,150 ;WindowHeight-ShieldHeight (Since we're dealing with the top left pixel of the shield)
        mov P_y,ax
        JMP None

    None:
    
endm shieldControl 


resetPosition macro So_x,So_y ;Positions to which we would like to reset the ball
    ;Resetting x-position
    mov ax, So_x
    mov S_x,ax
    ;Reseting y-position
    mov ax, So_y
    mov S_y,ax
endm resetPosition 

   staticWave macro y, x ;x, y relate to the waves position
   local whileWaveBeingDrawn
   mov ah,0ch
    mov SI, offset wave
    whileWaveBeingDrawn:
       drawDynamicPixel [SI],[SI+1],[SI+2], y, x
       add SI,3
       cmp SI,offset waveSize
    JNE whileWaveBeingDrawn
    endm staticWave
;____________________________________________________________________________________________________________________
;Let the code beign.

.286
.MODEL HUGE
.STACK 64   
.DATA
    ;Data variables relating to the ball
    S_x dw 100 ;x position of the ball
    S_y dw 30 ;y position of the ball
    V_x dw 3H ;Horizontal Velocity
    V_y dw 3H ;Vertical Velocity
    colorBall db 0eh
    ;Ball_Size dw 20h; height, width of the ball 
    Centiseconds db 0;To check if a centisecond has passed.
    ;Data variables relating to the Shield (Pl (Left), Pr(Right))
    colorShield db 0h
    Pl_x dw 45
    Pl_y dw 50
    Pr_x dw 275
    Pr_y dw 50
    ;P_width dw 02
    ;P_height dw 50
    P_Velocity dw 20
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
 
 

shield db 26,2,4
        db 26,3,40
        db 24,4,40,25,4,40,26,4,40
        db 23,5,40,24,5,40,26,5,40
        db 23,6,40,24,6,40,25,6,40
        db 23,7,40,24,7,40,25,7,40
        db 21,8,40,22,8,40,23,8,40,25,8,40,26,8,40
        db 20,9,40,21,9,40,22,9,40,24,9,40,25,9,40,26,9,40
        db 20,10,40,21,10,40,22,10,40,23,10,40,25,10,40,26,10,40,27,10,40
        db 20,11,40,21,11,40,23,11,40,25,11,40,26,11,40,27,11,40
        db 20,12,40,21,12,40,23,12,40,24,12,40,25,12,40,26,12,40
        db 21,13,40,22,13,40,23,13,40,24,13,40,25,13,40,26,13,40
        db 21,14,40,22,14,40,23,14,40,24,14,40,25,14,40,26,14,40
        db 21,15,40,22,15,40,23,15,40,24,15,40,25,15,40
        db 21,16,40,22,16,40,23,16,40,24,16,40,25,16,40
        db 21,17,40,22,17,40,23,17,40,24,17,40,25,17,40
        db 21,18,40,22,18,40,23,18,40,24,18,40,25,18,40
        db 21,19,40,22,19,40,23,19,40,24,19,40,25,19,40
        db 21,20,40,22,20,40,23,20,40,24,20,40,25,20,40
        db 21,21,40,22,21,40,23,21,40,24,21,40,25,21,40
        db 21,22,40,22,22,40,23,22,40,24,22,40,25,22,40
        db 21,23,40,22,23,40,23,23,40,24,23,40,25,23,40
        db 21,24,40,22,24,40,23,24,40,24,24,40,25,24,40
        db 21,25,40,22,25,40,23,25,40,24,25,40,25,25,40
        db 21,26,40,22,26,40,23,26,40,24,26,40,25,26,40
        db 21,27,40,22,27,40,23,27,40,24,27,40,25,27,40
        db 21,28,40,22,28,40,23,28,40,24,28,40,25,28,40
        db 21,29,40,22,29,40,23,29,40,24,29,40,25,29,40
        db 21,30,40,22,30,40,23,30,40,24,30,40,25,30,40
        db 21,31,40,22,31,40,23,31,40,24,31,40,25,31,40
        db 21,32,40,22,32,40,23,32,40,24,32,40,25,32,40
        db 21,33,40,22,33,40,23,33,40,24,33,40,25,33,40
        db 21,34,40,22,34,40,23,34,40,24,34,40,25,34,40
        db 21,35,40,22,35,40,23,35,40,24,35,40,25,35,40
        db 21,36,40,22,36,40,23,36,40,24,36,40,25,36,40
        db 21,37,40,22,37,40,23,37,40,24,37,40,25,37,40
        db 21,38,40,22,38,40,23,38,40,24,38,40,25,38,40
        db 21,39,40,22,39,40,23,39,40,24,39,40,25,39,40
        db 21,40,40,22,40,40,23,40,40,24,40,40,25,40,40
        db 21,41,40,22,41,40,23,41,40,24,41,40,25,41,40
        db 21,42,40,22,42,40,23,42,40,24,42,40,25,42,40
        db 21,43,40,22,43,40,23,43,40,24,43,40,25,43,40,26,43,40
        db 20,44,40,21,44,40,22,44,40,24,44,40,25,44,40,26,44,40
        db 20,45,40,21,45,40,23,45,40,25,45,40,26,45,40
        db 20,46,40,21,46,40,22,46,40,23,46,40,25,46,40,26,46,40,27,46,40
        db 20,47,40,21,47,40,22,47,40,23,47,40,24,47,40,25,47,40,26,47,40
        db 21,48,40,22,48,40,25,48,40,26,48,40
        db 21,49,40,23,49,40,24,49,40,25,49,40
        db 23,50,40,24,50,40,25,50,40
        db 24,51,40,25,51,40,26,51,40
        db 24,52,40,26,52,40
        db 25,53,40,26,53,40
        db 26,54,40
        P_height dw 55
        P_Width dw 21


    wave db 5,18,54,6,18,54,7,18,54,8,18,54,9,18,52,28,18,54,29,18,54,30,18,54,31,18,54,32,18,54,52,18,54,53,18,54,54,18,54,55,18,54
        db 2,19,54,3,19,54,4,19,54,5,19,54,6,19,54,7,19,54,8,19,54,9,19,54,10,19,54,11,19,54,25,19,54,26,19,54,27,19,54,28,19,54,29,19,54,30,19,54,31,19,54,32,19,54,33,19,54,34,19,54,49,19,54,50,19,54,51,19,54,52,19,54,53,19,54,54,19,54,55,19,54,56,19,54,57,19,54
        db 1,20,54,2,20,54,3,20,54,4,20,54,5,20,54,6,20,53,7,20,54,8,20,54,9,20,54,10,20,54,11,20,54,12,20,54,24,20,54,25,20,54,26,20,54,27,20,54,28,20,54,29,20,54,30,20,48,31,20,54,32,20,54,33,20,54,34,20,54,35,20,54,36,20,54,48,20,54,49,20,54,50,20,54,51,20,54,52,20,54,54,20,54,55,20,54,56,20,54,57,20,54,58,20,54
        db 2,21,54,3,21,54,10,21,54,11,21,54,12,21,54,13,21,54,14,21,54,22,21,54,23,21,54,24,21,54,25,21,54,26,21,54,34,21,54,35,21,54,36,21,54,37,21,54,38,21,32,46,21,54,47,21,54,48,21,54,49,21,54,50,21,54,57,21,54,58,21,54
        db 12,22,54,13,22,54,14,22,54,15,22,54,16,22,54,17,22,53,20,22,54,21,22,54,22,22,54,23,22,54,24,22,54,25,22,32,35,22,54,36,22,54,37,22,54,38,22,54,39,22,54,40,22,54,43,22,54,44,22,54,45,22,54,46,22,54,47,22,54,48,22,54
        db 14,23,54,15,23,54,16,23,54,17,23,54,18,23,54,19,23,54,20,23,54,21,23,54,22,23,54,37,23,54,38,23,54,39,23,54,40,23,54,41,23,54,42,23,54,43,23,54,44,23,54,45,23,54,46,23,54
        db 4,24,54,5,24,54,6,24,54,7,24,54,8,24,54,9,24,54,15,24,32,16,24,54,17,24,54,18,24,54,19,24,54,20,24,54,27,24,54,28,24,54,29,24,54,30,24,54,31,24,54,32,24,54,33,24,32,40,24,54,41,24,54,42,24,54,43,24,54,44,24,54,51,24,54,52,24,54,53,24,54,54,24,54,55,24,54,56,24,54
        db 2,25,54,3,25,54,4,25,54,5,25,54,6,25,54,7,25,54,8,25,54,9,25,54,10,25,54,11,25,54,25,25,54,26,25,54,27,25,54,28,25,54,29,25,54,30,25,54,31,25,54,32,25,54,33,25,54,34,25,54,35,25,54,49,25,54,50,25,54,51,25,54,52,25,54,53,25,54,54,25,54,55,25,54,56,25,54,57,25,54,58,25,54
        db 1,26,54,2,26,54,3,26,54,4,26,54,5,26,54,8,26,54,9,26,54,10,26,54,11,26,54,12,26,54,24,26,54,25,26,54,26,26,54,27,26,54,28,26,54,29,26,32,32,26,54,33,26,54,34,26,54,35,26,54,36,26,54,48,26,54,49,26,54,50,26,54,51,26,54,52,26,53,55,26,54,56,26,54,57,26,54,58,26,54
        db 2,27,54,10,27,52,11,27,54,12,27,54,13,27,54,14,27,54,15,27,32,22,27,54,23,27,54,24,27,54,25,27,54,34,27,54,35,27,54,36,27,54,37,27,54,38,27,54,45,27,32,46,27,54,47,27,54,48,27,54,49,27,54,50,27,52,57,27,54,58,27,54
        db 12,28,54,13,28,54,14,28,54,15,28,54,16,28,54,17,28,54,18,28,54,19,28,54,20,28,54,21,28,54,22,28,54,23,28,54,24,28,54,36,28,54,37,28,54,38,28,54,39,28,54,40,28,54,41,28,54,42,28,54,43,28,54,44,28,54,45,28,54,46,28,54,47,28,54,48,28,54
        db 14,29,54,15,29,54,16,29,54,17,29,54,18,29,54,19,29,54,20,29,54,21,29,54,22,29,54,23,29,32,37,29,53,38,29,54,39,29,54,40,29,54,41,29,54,42,29,54,43,29,54,44,29,54,45,29,54,46,29,54
        db 4,30,54,5,30,54,6,30,54,7,30,54,8,30,54,9,30,54,16,30,52,17,30,54,18,30,54,19,30,54,20,30,52,27,30,54,28,30,54,29,30,54,30,30,54,31,30,54,32,30,54,33,30,54,40,30,54,41,30,54,42,30,54,43,30,54,51,30,54,52,30,54,53,30,54,54,30,54,55,30,54,56,30,54
        db 1,31,32,2,31,54,3,31,54,4,31,54,5,31,54,6,31,54,7,31,54,8,31,54,9,31,54,10,31,54,11,31,54,12,31,52,25,31,54,26,31,54,27,31,54,28,31,54,29,31,54,30,31,54,31,31,54,32,31,54,33,31,54,34,31,54,35,31,54,48,31,32,49,31,54,50,31,54,51,31,54,52,31,54,53,31,54,54,31,54,55,31,54,56,31,54,57,31,54,58,31,54
        db 1,32,54,2,32,54,3,32,54,4,32,54,9,32,54,10,32,54,11,32,54,12,32,54,13,32,54,23,32,54,24,32,54,25,32,54,26,32,54,27,32,54,28,32,52,33,32,54,34,32,54,35,32,54,36,32,54,47,32,54,48,32,54,49,32,54,50,32,54,51,32,54,56,32,54,57,32,54,58,32,54
        db 2,33,54,11,33,54,12,33,54,13,33,54,14,33,54,15,33,54,21,33,51,22,33,54,23,33,54,24,33,54,25,33,54,35,33,54,36,33,54,37,33,54,38,33,54,39,33,32,45,33,54,46,33,54,47,33,54,48,33,54,49,33,54,57,33,54,58,33,32
        db 12,34,54,13,34,54,14,34,54,15,34,54,16,34,54,17,34,54,18,34,54,19,34,54,20,34,54,21,34,54,22,34,54,23,34,54,24,34,54,36,34,54,37,34,54,38,34,54,39,34,54,40,34,54,41,34,54,42,34,54,43,34,54,44,34,54,45,34,54,46,34,54,47,34,54,48,34,54
        db 14,35,54,15,35,54,16,35,54,17,35,54,18,35,54,19,35,54,20,35,54,21,35,54,22,35,54,38,35,54,39,35,54,40,35,54,41,35,54,42,35,54,43,35,54,44,35,54,45,35,54,46,35,54
        db 17,36,54,18,36,32,19,36,54,42,36,52,43,36,54

waveSize db ? ;Need not to know this since the wave is static
 

.Code
    MAIN PROC FAR 
    MOV AX,@Data
    MOV DS,AX


;Think of game objects >>Shields, Balls.
;Ball must reverse direction whenever it collides with a Shield or wall
;it it collides with boundaries then points should be given to the right player.
;Game over conditions
;Layout overview :Main Menu, Game it self, Game over menu
    graphicsMode 13h ;https://stanislavs.org/helppc/int_10.html click on set video modes for all modes
    setBackgroundColor 0bh
    ;Updating the objects' position with time is how we get to move them. Get system time, check if time has passed, erase screen and redraw.
    ;Check if the current 100ths of a second is different than the previous one.
    whileTime: ;while centisecond hasn't passed yet
         staticWave 100,160
        ;call drawBall 
        ;call drawShieldLeft     
        ;drawShield Pr_x,Pr_y
        checkTimePassed Centiseconds
    JE whileTime 
    ;if a centisecond passes (won't be triggered for any less time)
    mov Centiseconds,dl ;centisecond(s) has passed update the time variable with the new time.
    Motion V_x, V_y ;Call the velocity macro, note that it deals with collisions inside.
    blankScreen 15
    staticWave 100,160
    call drawBall
    shieldControl Pr_y,4Dh,4Bh ;control Pr_y up and down with right and left arrows.
    shieldControl Pl_y,0fh,10h ;control Pl_y up and down with Tab and Q.
    call drawShieldLeft     
    drawShield Pr_x,Pr_y
    jmp whileTime
    return
    MAIN ENDP 
    


    ;New Proceducre
    drawSquare proc near
    ;{
        ;drawPixel 0fh,S_x,S_y
        ;Setting up the initial pixel
        mov cx,s_x
        mov dx,s_y
        whileBallBeingDrawn:
            drawPixel_implicit colorBall
            inc cx ;the x-coordinate
            checkDifference cx, S_x, ball_size
         JNG whileBallBeingDrawn ;Keep adding Pixels till Cx-S_x=ball_size
            mov cx, S_x
            inc dx
            checkDifference dx, S_y, ball_size
        JNG whileBallBeingDrawn
    ret
    ;}
    drawSquare endp
    
   drawBall proc near
   mov ah,0ch
    mov SI, offset ball
    whilePixels:
       drawDynamicPixel [SI],[SI+1],[SI+2], S_y, S_x
       add SI,3
       cmp SI,offset Ball_Size
    JNE whilePixels
   ret
   drawBall endp
   
      drawShieldLeft proc near
   mov ah,0ch
    mov SI, offset shield
    whileBeingDrawn:
       drawDynamicPixel [SI],[SI+1],[SI+2], Pl_y, Pl_x
       add SI,3
       cmp SI,offset P_height
    JNE whileBeingDrawn
   ret
   drawShieldLeft endp

 
checkLeftShieldCollisions proc near
    ;Check collisions with the left shield and do necessary action based on that
    ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
    ; M is the left shield and N is the ball                                 
    mov ax,Pl_x
    add ax,P_width
    cmp ax,S_x
    JNG bye ;first condition not satisified, no need to check anymore.

    mov ax,S_x
    add ax,Ball_Size
    cmp ax,Pl_X
    JNG bye ;second condition

    mov ax,Pl_y
    add ax,P_height
    cmp ax,S_y
    JNG bye

    mov ax,S_y
    add ax,Ball_Size
    cmp ax, Pl_y
    JNG bye
    ;Reaching this point indicates that the conditions are satisified.
    Neg V_x
    mov ax,3
    add V_y,ax ;Widening the angle of reflection
    bye: ;Do nothing if none is satisfied
    ret
 checkLeftShieldCollisions endp

checkrightShieldCollisions proc near
    ;Check collisions with the right shield and do necessary action based on that
    ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
    ; M is the ball and N is the right shield                                  
    mov ax,S_x
    add ax,ball_Size
    cmp ax,Pr_x
    JNG exit ;first condition not satisified, no need to check anymore.

    mov ax,Pr_X
    add ax,P_width
    cmp ax,S_x
    JNG exit ;second condition

    mov ax,S_y
    add ax,ball_size
    cmp ax,Pr_y
    JNG exit

    mov ax,Pr_y
    add ax,P_height
    cmp ax, S_y
    JNG exit
    ;Reaching this point indicates that the conditions are satisified.
    Neg V_x
    mov ax,3
    add V_y,ax ;Widening the angle of reflection
    exit:
    ret
 checkrightShieldCollisions endp

END MAIN 




;Dynamic Collisions:
;Axis alligned bounding box collision: Can be done when The two colliding objects have their axes alligned with each other.
;A collision is satisfied whenever they occupy the same space: 
;M _______________
; |               |             This implies:
; |               |                 1)The right edge of box M is within or past the left edge of box N
; |               |                 2)The left edge of box M is within or before the right edge of box N
; |        N _____|__               3)The bottom edge of box M is within or past the Top edge of box N
; |_________|_____|  |              4)The top edge of box M is within or before the bottom edge of box N
;           |        |              So:
;           |________|              if M and N are the top-left local origin of the boxes, we can write the above as:
;                                   1)M.x+M.width>=N.x
;                                   2)M.x<=N.x+N.width
;                                   3)M.y+M.height>=N.y
;                                   4)M.y<=N.y+N.height
;  