Print macro Stringo
    mov AH,09h
    mov dx,offset Stringo
    int 21h
ENDM Print


DisplayCharacter macro Char
    mov dl, Char
    add dl,30h
    mov ah, 2h
    int 21h
ENDM DisplayCharacter

DisplayNumber MACRO number
    pusha
    mov al, number
    mov ah,0
    mov bl,100
    div bl
    mov dl,al
    push ax
    add dl,30h
    mov ah,02h
    int 21h
    pop ax
    mov bl,10
    mov al,ah
    mov ah,0
    div bl  
    mov dl,al
    push ax
    add dl,30h
    mov ah,02h
    int 21h
    pop ax
    mov dl,ah
    add dl,30h
    mov ah,02h
    int 21h
    popa
ENDM DisplayNumber

endl macro ;Prints a new line
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

DisplayAx macro number
local whileQuotient, whileCx
   pusha
   mov ax, number
   ;mov ah,0
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

setTextCursor macro dlValue,dhValue
    pusha
    MOV  DL, dlValue    ;SCREEN COLUMN.
    MOV  DH, dhValue    ;SCREEN ROW.
    MOV  AH, 2     ;SERVICE TO SET CURSOR POSITION.
    MOV  BH, 0     ;PAGE NUMBER.
    INT  10H       ;BIOS SCREEN SERVICES.
    popa
ENDM setTextCursor

clearScreen macro 
    mov ax,0600h
    mov dx,2479h
    mov cx,0
    mov bh,07
    int 10h
ENDM clearScreen

videoMode macro Mode
    mov ah,00h
    mov al,Mode
    int 10h
ENDM videoMode

    drawPlatform macro x, y, color, height, width ;x, y are the starting position (top left corner)
       local whilePlatformBeingDrawn
        pusha
        mov cx,x                        
        mov dx,y                                
        whilePlatformBeingDrawn:
            drawPixel_implicit color
            inc cx ;the x-coordinate
            checkDifference cx, x, width ;Keep adding Pixels till Cx-P_x=widthPlatform
         JNG whilePlatformBeingDrawn 
            mov cx, x
            inc dx
            checkDifference dx, y, height
        JNG whilePlatformBeingDrawn
        popa
    endm drawPlatform


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

checkMousePointer macro ;CX, DX has the position, BX is 1 in case of a click. 
mov ax,3
int 33h
endm checkMousePointer


setMousePointer macro column, row
    mov ax, 4
    mov cx, column
    mov dx, row
    int 33h
endm setMousePointer


blankScreen macro color, from, to
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,color  ;color to blank the screen with
    mov ch,0h 
    mov cl,from
    mov dh,18h
    mov dl,to
 ;to the end of the screen
	int 10h

ENDM blankScreen 

blankScreen2 macro color, from, to
	mov ah,06     ;Scroll (Zero lines anyway)
    mov al,00h    ;to blank the screen
	mov bh,color  ;color to blank the screen with
    mov ch,from
    mov cl,00h
    mov dh,to
    mov dl,4fh
 ;to the end of the screen
	int 10h

ENDM blankScreen 


    resetMouse macro
    mov  ax, 0000h  ; reset mouse
    int  33h       
    endm resetMouse
    
    showMouse macro
   mov  ax, 0001h  ; show mouse
    int  33h
    endm resetMouse

blankTextScreen macro 
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,104 ;color to blank the screen with
    mov cx,0
    mov dx,184fh
 ;to the end of the screen
	int 10h

ENDM blankTextScreen 


checkDifference macro A,B,C ;checks if A-B=C and yields 0 if that's true
push ax
            mov ax,A
            sub ax,B
            cmp ax,C
pop ax
ENDM checkDifference
        
checkTimePassed macro previous_time ;CH = hour CL = minute DH = second DL = 1/100 seconds
    mov ah,2ch
    int 21h ;gets the current time
    cmp dl,previous_time ;checks if a centisecond has passed and returns zero in that case
endm getSystemTime 


;We might borrow comments from this and then take it down.
Motion macro ;V_x, V_y ;Pass horizontal and vertical velocities (i.e. position changes that should applied every centisecond in the main loop)

    ;Trigger the desired motion along x
    mov ax, V_x+BP
    add [bx+S_x], ax ;Add V_x to S_x (done every centisecond >> velocity)
    ;Check vertical walls and do necessary action if colliding with any
    cmp [bx+S_x], 10h
    JL reverse_Velocity_x
    cmp [bx+S_x], 310;320 (from resolution)-ballSize - some_margin
    JG reverse_Velocity_X

    ;Trigger the desired motion along y
    mov ax, V_y+BP ;Moving the ball for 5 pixels along y=x whenever a centisecond passes (velocity = 5 px/cs)
    add [bx+S_y], ax
   ;check horizontal walls and do necessary action if colliding with any
    cmp [bx+S_x], 10h
    JL Reverse_Velocity_Y
    cmp [bx+S_y], 170 ;200 (from resolution) - ballSize - some_margin
    JG Reverse_Velocity_Y

    call checkRightShieldCollisions ;Escapes to done if non detected, does necessary action otherwise
    call checkLeftShieldCollisions ;Escapes to next check if non detected, does necessary action otherwise

JMP Done ;If none of the above was satisfied, do nothing.
    
    ;But in case any was satisified:
        Reverse_Velocity_X:
        neg V_x+BP ;Finding the 2's complementing (multiplying by -1)
        JMP Done
        Reverse_Velocity_Y:
        neg V_y+BP
        JMP Done
        Reset_Position: ;Don't think we'll need this
            resetPosition 0,0
            JMP Done 
        Disappear:
            mov al,00h
            mov colorBall,al
    Done:

endm Motion


shieldControlFirst macro P_y, upKey, downKey ;Takes the dimension that we would like to control, and the two keys using for controling that dimension
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
    
endm shieldControlFirst 


shieldControlSecond macro P_y, upKey, downKey ;Takes the dimension that we would like to control, and the two keys using for controling that dimension
    local Reads, movesUps, movesDowns, resetPositionHighs, resetPositionLows, Nones
    ;So for vertical motion of the left shield pass Pl_y and vice versa.
    ;Check if any key is pressed, if yes then check if it's w, W or s, S for the former move up and for the latter move down, check collisions with upper and lower boundaries for each.
    ;getKeyboardStatus
    JZ Nones ;No key was pressed, see if any neccessary action is needed.
        ;readKey ;else key was pressed
        cmp Ah,upKey ;Left
        JE movesUps
        cmp Ah,downKey ;Right
        JE movesDowns
        JMP Nones ;Do nothing if any other key was pressed.


    movesUps:
        mov ax,P_Velocity
        sub P_y, ax
        ;Check collisions with y=0
        cmp P_y,0
        Jl resetPositionHighs
        JMP Nones

    movesDowns:
        mov ax,P_velocity
        add P_y, ax
        ;Check collisions with y=windowHeight-shieldHight
        cmp P_y,150
        JG resetPositionLows
        JMP Nones

    resetPositionHighs:
    ;Attempt to surpass y=0: reset position to y=0
        mov ax,0
        mov P_y,ax
        JMP Nones

    resetPositionLows:
    ;Attempt to surpass y=200 (the bottom pixel): reset position to y=200 
        mov ax,150 ;WindowHeight-ShieldHeight (Since we're dealing with the top left pixel of the shield)
        mov P_y,ax
        JMP Nones

    Nones:
    
endm shieldControlSecond

checkMouseRegion macro from_x,to_x,from_y,to_y
      local itsOver
      cmp cx,from_x
      jb itsOver
      cmp cx,to_x
      ja itsOver
      cmp dx,from_y
      jb itsOver
      cmp dx,to_y
     ja itsOver
     xor ax,ax
     itsOver:
endm checkMouseRegion

resetPosition macro So_x,So_y ;Positions to which we would like to reset the ball
    ;Resetting x-position
    mov ax, So_x
    mov S_x,ax
    ;Reseting y-position
    mov ax, So_y
    mov S_y,ax
endm resetPosition 

   staticWave macro y, x,whileWavesBeingDraw ;x, y relate to the waves position
    local whileWavesBeingDrawn
        ;inc cx
        ;inc dx
        mov ah,0ch
        mov BX, offset wave
    whileWavesBeingDrawn:
       drawDynamicPixel [BX],[BX+1],[BX+2], y, x
       add BX,3
       cmp BX,offset waveSize
    JNE whileWavesBeingDrawn
    endm staticWave

Logo macro y, x ;x, y relate to the waves position
    local whileLogo
        mov ah,0ch
        mov BX, offset logoFront
    whileLogo:
       drawDynamicPixel [BX],[BX+1],[BX+2], y, x
       add BX,3
       cmp BX,offset logoFrontSize
    JNE whileLogo
    endm staticWave
    
    LeftWinsScreen macro y, x ;x, y relate to the waves position
    local whileVictory
        mov ah,0ch
        mov BX, offset Victory
    whileVictory:
       drawDynamicPixel [BX],[BX+1],[BX+2], y, x
       add BX,3
       cmp BX,offset VictorySize
    JNE whileVictory
    endm leftWinsScreen
    
    RightWinsScreen macro y, x ;x, y relate to the waves position
    local whileDefeat
        mov ah,0ch
        mov BX, offset Defeat
    whileDefeat:
       drawDynamicPixel [BX],[BX+1],[BX+2], y, x
       add BX,3
       cmp BX,offset defeatSize
    JNE whileDefeat
    endm RightWinsScreen

staticShipLeft macro y, x ;x, y relate to the waves position
    local whileShipBeingDrawn
    mov ah,0ch
    mov BX, offset shipLeft
    whileShipBeingDrawn:
        drawDynamicPixel [BX],[BX+1],[BX+2], y, x
        add BX,3
        cmp BX,offset shipLeftSize
    JNE whileShipBeingDrawn
endm staticShipLeft
       
staticShipRight macro y, x ;x, y relate to the waves position
    local whileShipisBeingDrawn
    mov ah,0ch
    mov BX, offset shipRight
    whileShipisBeingDrawn:
        drawDynamicPixel [BX],[BX+1],[BX+2], y, x
        add BX,3
        cmp BX,offset shipRightSize
    JNE whileShipisBeingDrawn
endm staticShipRight
       

dynamicBalls macro
        mov bx,0h
        ballDynamics:
            mov currentBallIndex,bx
            call moveBall
            add bx,2  ; counter
            cmp bx,ballCount  ;size of array              
        jl ballDynamics
        mov bx,0h
        ballGraphics:
            mov currentBallIndex,bx
            call checkDestroyedCount
            CALL drawBall
            add bx,2
            cmp bx,ballCount
        jL ballGraphics
endm dynamicBalls

Waves macro
        staticWave 100,160,A           ;Once we design all the waves, we can take them to a macro.
        staticWave 50,50,B
        staticWave 200,320,B
        staticWave 150,180,B
endm Waves
;____________________________________________________________________________________________________________________
;Let the code beign.

.286
.MODEL HUGE
.STACK 64   
.DATA
    ;Data variables relating to the ball
	screenWidth DW 320      ;the width of the window (320 pixels)
	screenHeight DW 200     ;the height of the window (200 pixels)
    screenMarginx DW 32       ;variable used to check collisions early
	screenMarginy DW 6       ;variable used to check collisions early
    destroyedCount DW 0
    positionThreshold dw 5h
    S_x dw 70,240,70,240,70,240      ;x position of the ball
    S_y dw 50,150,150,50,50,150         ;y position of the ball
    V_x dw 4H,0fffcH,4h,0fffch,4h,0fffch         ;Horizontal Velocity
    V_y dw 0H,0H,0h,0h,0h,0h        ;Vertical Velocity
    ;Refresher Quantities
    Sx dw 70,240,70,240,70,240      ;x position of the ball
    Sy dw 160,40,40,160,150,50         ;y position of the ball
    Vx dw 4H,0fffcH,4h,0fffch,4h,0fffch         ;Horizontal Velocity
    Vy dw 0H,0H,0h,0h,0h,0h        ;Vertical Velocity
    currentBallIndex dw ? 
    ballCount dw 4h
    colorBall db 0h
    Centiseconds db 0;To check if a centisecond has passed.
    ;Data variables relating to the Shield (Pl (Left), Pr(Right)):
    colorShieldLeft db 41
    colorShieldRight db  41
    Pl_x dw 40
    Pl_y dw 50
    Pr_x dw 250
    Pr_y dw 50
    P_Velocity dw 18
    Msg db 20 dup(10,13),09h,"Please Enter Your Name:",2 dup(10,13),09h,'$'
    UserName db 30,?, 30 dup('$')
    playerName2 db "Radwa",'$'
    sendchat db 11 dup(10,13),"you sent a chat invitation to ",'$'
    sendgame db 11 dup(10,13),"you sent a game invitation to ",'$'
    Msg2 db 2 dup(10,13),09h,"PLease Enter Any Key To continue",'$'
    MSGFrist db 2 dup(10,13),09h,"PLease Try Again with Letter in Frist, Press any Key To continue",'$'
    MSGLong db 2 dup(10,13),09h,"PLease Try Again with shoter name, Press any Key To continue",'$'
    MSGshort db 2 dup(10,13),09h,"PLease Try Again with your name, Press any Key To continue",'$'
    MSGSpecial db 2 dup(10,13),09h,"PLease Try Again Don't use Spcial char, Press any Key To continue",'$'
    Msg3 db 7 dup(10,13),09h,"*To start chatting press F1",2 dup(10,13),09h,"*To start game press F2",2 dup(10,13),09h,"*To end the program press ESC",'$'
;Graphics:
 
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
        ballSize dw 20 
 
 

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

    rightShield db 3,5,40
        db 3,6,40,4,6,40
        db 3,7,40,5,7,40
        db 3,8,40,4,8,40,5,8,40
        db 4,9,40,5,9,40,6,9,40
        db 4,10,40,5,10,40,6,10,40,8,10,40
        db 3,11,40,4,11,40,7,11,40,8,11,40
        db 3,12,40,4,12,40,5,12,40,6,12,40,7,12,40,8,12,40,9,12,40
        db 2,13,40,3,13,40,4,13,40,6,13,40,7,13,40,8,13,40,9,13,40
        db 3,14,40,4,14,40,6,14,40,8,14,40,9,14,40
        db 3,15,40,4,15,40,5,15,40,7,15,40,8,15,40,9,15,40
        db 3,16,40,4,16,40,5,16,40,6,16,40,7,16,40,8,16,40
        db 4,17,40,5,17,40,6,17,40,7,17,40,8,17,40
        db 4,18,40,5,18,40,6,18,40,7,18,40,8,18,40
        db 4,19,40,5,19,40,6,19,40,7,19,40,8,19,40
        db 4,20,40,5,20,40,6,20,40,7,20,40,8,20,40
        db 4,21,40,5,21,40,6,21,40,7,21,40,8,21,40
        db 4,22,40,5,22,40,6,22,40,7,22,40,8,22,40
        db 4,23,40,5,23,40,6,23,40,7,23,40,8,23,40
        db 4,24,40,5,24,40,6,24,40,7,24,40,8,24,40
        db 4,25,40,5,25,40,6,25,40,7,25,40,8,25,40
        db 4,26,40,5,26,40,6,26,40,7,26,40,8,26,40
        db 4,27,40,5,27,40,6,27,40,7,27,40,8,27,40
        db 4,28,40,5,28,40,6,28,40,7,28,40,8,28,40
        db 4,29,40,5,29,40,6,29,40,7,29,40,8,29,40
        db 4,30,40,5,30,40,6,30,40,7,30,40,8,30,40
        db 4,31,40,5,31,40,6,31,40,7,31,40,8,31,40
        db 4,32,40,5,32,40,6,32,40,7,32,40,8,32,40
        db 4,33,40,5,33,40,6,33,40,7,33,40,8,33,40
        db 4,34,40,5,34,40,6,34,40,7,34,40,8,34,40
        db 4,35,40,5,35,40,6,35,40,7,35,40,8,35,40
        db 4,36,40,5,36,40,6,36,40,7,36,40,8,36,40
        db 4,37,40,5,37,40,6,37,40,7,37,40,8,37,40
        db 4,38,40,5,38,40,6,38,40,7,38,40,8,38,40
        db 4,39,40,5,39,40,6,39,40,7,39,40,8,39,40
        db 4,40,40,5,40,40,6,40,40,7,40,40,8,40,40
        db 4,41,40,5,41,40,6,41,40,7,41,40,8,41,40
        db 4,42,40,5,42,40,6,42,40,7,42,40,8,42,40
        db 4,43,40,5,43,40,6,43,40,7,43,40,8,43,40
        db 4,44,40,5,44,40,6,44,40,7,44,40,8,44,40
        db 3,45,40,4,45,40,5,45,40,6,45,40,7,45,40,8,45,40
        db 3,46,40,4,46,40,5,46,40,6,46,40,7,46,40,8,46,40
        db 3,47,40,4,47,40,5,47,40,6,47,40,8,47,40,9,47,40
        db 2,48,40,3,48,40,4,48,40,6,48,40,8,48,40,9,48,40
        db 2,49,40,3,49,40,4,49,40,6,49,40,7,49,40,8,49,40,9,49,40
        db 3,50,40,4,50,40,5,50,40,7,50,40,8,50,40,9,50,40
        db 3,51,40,4,51,40,6,51,40,7,51,40,8,51,40
        db 4,52,40,5,52,40,6,52,40
        db 4,53,40,5,53,40,6,53,40
        db 3,54,40,5,54,40,6,54,40
        db 3,55,40,4,55,40,5,55,40
        db 3,56,40
        db 3,57,4
        rightShieldSize dw 60 

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

 
    shipLeft db 0,3,16,1,3,16,2,3,16,3,3,16,4,3,16,5,3,16,6,3,16
        db 0,5,208,1,5,209,2,5,209,3,5,209,4,5,208,5,5,209,6,5,18,8,5,16
        db 0,6,137,1,6,137,2,6,137,3,6,137,4,6,137,5,6,137,6,6,208,8,6,16
        db 0,7,20,1,7,20,2,7,20,3,7,20,4,7,20,5,7,20,6,7,18,8,7,16
        db 0,8,20,1,8,20,2,8,20,3,8,20,4,8,20,5,8,20,6,8,19,8,8,16
        db 0,9,20,1,9,20,2,9,20,3,9,20,4,9,20,5,9,20,6,9,235,7,9,16,9,9,16
        db 0,10,20,1,10,20,2,10,20,3,10,20,4,10,20,5,10,20,6,10,20,7,10,18,9,10,16
        db 0,11,20,1,11,20,2,11,20,3,11,20,4,11,20,5,11,20,6,11,20,7,11,224,9,11,16
        db 0,12,20,1,12,20,2,12,20,3,12,20,4,12,20,5,12,20,6,12,20,7,12,229,9,12,16
        db 0,13,20,1,13,20,2,13,20,3,13,20,4,13,20,5,13,20,6,13,20,7,13,235,8,13,16
        db 0,14,20,1,14,20,2,14,20,3,14,20,4,14,20,5,14,20,6,14,20,7,14,20,8,14,18,10,14,16
        db 0,15,20,1,15,20,2,15,20,3,15,20,4,15,20,5,15,20,6,15,20,7,15,20,8,15,18,10,15,16
        db 0,16,20,1,16,20,2,16,20,3,16,20,4,16,20,5,16,20,6,16,20,7,16,20,8,16,20,10,16,16
        db 0,17,20,1,17,20,2,17,20,3,17,20,4,17,20,5,17,20,6,17,20,7,17,20,8,17,231,10,17,16
        db 0,18,20,1,18,20,2,18,20,3,18,20,4,18,20,5,18,20,6,18,20,7,18,20,8,18,230
        db 0,19,20,1,19,20,2,19,20,3,19,20,4,19,20,5,19,20,6,19,20,7,19,20,8,19,20,9,19,18,11,19,16
        db 0,20,20,1,20,20,2,20,20,3,20,20,4,20,20,5,20,20,6,20,20,7,20,20,8,20,20,9,20,17,11,20,16
        db 0,21,20,1,21,20,2,21,20,3,21,20,4,21,20,5,21,20,6,21,20,7,21,20,8,21,20,9,21,17,11,21,16
        db 0,22,20,1,22,20,2,22,20,3,22,20,4,22,20,5,22,20,6,22,20,7,22,20,8,22,20,9,22,17,11,22,16
        db 0,23,20,1,23,20,2,23,20,3,23,20,4,23,20,5,23,20,6,23,20,7,23,20,8,23,20,9,23,18,11,23,16
        db 0,24,20,1,24,20,2,24,20,3,24,20,4,24,20,5,24,20,6,24,20,7,24,20,8,24,20,9,24,20,11,24,16
        db 0,25,20,1,25,20,2,25,20,3,25,20,4,25,20,5,25,20,6,25,20,7,25,20,8,25,20,9,25,19,11,25,16
        db 0,26,20,1,26,20,2,26,20,3,26,20,4,26,20,5,26,20,6,26,20,7,26,20,8,26,20,9,26,19,11,26,16
        db 0,27,20,1,27,20,2,27,20,3,27,20,4,27,20,5,27,20,6,27,20,7,27,20,8,27,20,9,27,233,11,27,16
        db 0,28,230,1,28,20,2,28,20,3,28,20,4,28,20,5,28,20,6,28,20,7,28,20,8,28,20,9,28,233,11,28,16
        db 0,29,170,1,29,20,2,29,235,3,29,234,4,29,235,5,29,20,6,29,20,7,29,20,8,29,20,9,29,233,11,29,16
        db 0,30,78,1,30,78,2,30,7,3,30,24,4,30,170,5,30,20,6,30,234,7,30,235,8,30,20,9,30,209,11,30,16
        db 0,31,78,1,31,78,2,31,78,3,31,78,4,31,78,5,31,27,6,31,24,7,31,8,8,31,20,9,31,22,11,31,16
        db 0,32,78,1,32,78,2,32,78,3,32,78,4,32,78,5,32,78,6,32,78,7,32,78,8,32,7,9,32,22,11,32,16
        db 0,33,78,1,33,78,2,33,78,3,33,78,4,33,78,5,33,78,6,33,78,7,33,78,8,33,27,9,33,195,11,33,16
        db 0,34,78,1,34,78,2,34,78,3,34,78,4,34,78,5,34,78,6,34,78,7,34,27,8,34,20,10,34,16
        db 0,35,78,1,35,27,2,35,27,3,35,27,4,35,78,5,35,78,6,35,78,7,35,25,9,35,16
        db 0,36,30,1,36,29,2,36,102,3,36,75,4,36,78,5,36,78,6,36,7,7,36,19,9,36,16
        db 0,37,15,1,37,15,2,37,15,3,37,0,4,37,0,5,37,29,6,37,24,8,37,16,9,37,16
        db 0,38,30,1,38,30,2,38,0,3,38,0,4,38,15,5,38,28,6,38,29,7,38,27,8,38,224,10,38,16,11,38,16
        db 0,39,15,1,39,0,2,39,30,3,39,30,4,39,29,5,39,27,6,39,0,7,39,0,8,39,0,9,39,24,11,39,16,12,39,16
        db 0,40,28,1,40,30,2,40,30,3,40,15,4,40,27,5,40,29,6,40,0,7,40,30,8,40,0,9,40,15,10,40,25,12,40,16
        db 0,41,18,1,41,233,2,41,8,3,41,23,4,41,24,6,41,0,7,41,0,8,41,0,9,41,30,10,41,15,11,41,25,13,41,16
        db 0,42,19,1,42,233,2,42,209,3,42,18,4,42,209,5,42,19,6,42,22,7,42,27,8,42,0,9,42,0,10,42,30,11,42,15,12,42,23,14,42,16
        db 0,43,19,1,43,19,2,43,19,3,43,19,4,43,19,5,43,19,6,43,18,7,43,18,8,43,8,9,43,30,10,43,0,11,43,0,12,43,30,13,43,19,15,43,16
        db 0,44,19,1,44,19,2,44,19,3,44,19,4,44,19,5,44,19,6,44,19,7,44,19,8,44,18,9,44,20,10,44,29,11,44,0,12,44,15,13,44,27,15,44,16
        db 0,45,19,1,45,19,2,45,19,3,45,19,4,45,19,5,45,19,6,45,19,7,45,19,8,45,19,9,45,209,10,45,232,11,45,28,12,45,15,13,45,0,14,45,224,16,45,16
        db 0,46,20,1,46,235,2,46,19,3,46,19,4,46,19,5,46,19,6,46,19,7,46,19,8,46,19,9,46,19,10,46,232,11,46,18,12,46,7,13,46,15,14,46,24,16,46,16
        db 0,47,20,1,47,20,2,47,20,3,47,19,4,47,233,5,47,233,6,47,19,7,47,19,8,47,19,9,47,19,10,47,19,11,47,19,12,47,18,13,47,24,14,47,30,16,47,16
        db 0,48,20,1,48,20,2,48,20,3,48,20,4,48,19,5,48,19,6,48,19,7,48,19,8,48,232,9,48,19,10,48,19,11,48,19,12,48,19,13,48,18,14,48,23,15,48,200,17,48,16
        db 0,49,20,1,49,20,2,49,20,3,49,20,4,49,235,5,49,22,6,49,22,7,49,17,8,49,8,9,49,232,10,49,19,11,49,234,12,49,232,13,49,19,14,49,18,15,49,245,16,49,18,18,49,16
        db 0,50,137,1,50,20,2,50,20,3,50,19,4,50,19,5,50,19,6,50,22,8,50,16,9,50,16,10,50,19,11,50,18,12,50,235,13,50,232,14,50,19,15,50,232,16,50,19,17,50,17,19,50,16,20,50,16,21,50,16
        db 0,51,64,1,51,64,2,51,23,3,51,25,4,51,164,5,51,161,6,51,20,7,51,8,8,51,18,10,51,16,12,51,16,14,51,17,15,51,19,16,51,20,17,51,240,18,51,18,20,51,16
        db 0,52,161,1,52,162,2,52,161,3,52,12,4,52,12,5,52,164,6,52,164,7,52,137,8,52,235,9,52,208,10,52,209,11,52,208,12,52,208,13,52,185,14,52,184,15,52,137,16,52,23,17,52,137,18,52,137,19,52,20,20,52,232,21,52,17,23,52,16
        db 0,53,137,1,53,138,2,53,137,3,53,137,4,53,137,5,53,137,6,53,6,7,53,161,8,53,162,9,53,136,10,53,136,11,53,136,12,53,114,13,53,138,14,53,138,15,53,138,16,53,113,17,53,136,18,53,136,19,53,136,20,53,136,21,53,209,23,53,16
        db 0,54,23,1,54,64,2,54,64,3,54,23,4,54,65,5,54,66,6,54,66,7,54,28,9,54,16,14,54,0,15,54,74,19,54,16,20,54,16
        db 0,55,23,1,55,64,2,55,64,3,55,23,4,55,164,5,55,66,6,55,66,7,55,66,9,55,16,14,55,23
        db 0,56,23,1,56,64,2,56,23,3,56,64,4,56,163,5,56,65,6,56,66,7,56,66,8,56,163,10,56,16
        db 0,57,23,1,57,23,2,57,23,3,57,23,4,57,163,5,57,164,6,57,66,7,57,66,8,57,65,10,57,16
        db 0,58,23,1,58,64,2,58,23,3,58,23,4,58,164,5,58,23,6,58,65,7,58,66,8,58,66,9,58,166,11,58,16
        db 0,59,23,1,59,64,2,59,23,3,59,23,4,59,164,5,59,23,6,59,64,7,59,66,8,59,66,9,59,7,11,59,16
        db 0,60,23,1,60,64,2,60,23,3,60,23,4,60,164,5,60,64,6,60,23,7,60,65,8,60,66,9,60,66,10,60,20,12,60,16
        db 0,61,23,1,61,64,2,61,23,3,61,23,4,61,164,5,61,64,6,61,23,7,61,64,8,61,66,9,61,66,10,61,139,12,61,16
        db 0,62,23,1,62,64,2,62,23,3,62,23,4,62,164,5,62,64,6,62,23,7,62,23,8,62,66,9,62,66,10,62,66,12,62,16
        db 0,63,23,1,63,64,2,63,23,3,63,23,4,63,164,5,63,64,6,63,64,7,63,23,8,63,65,9,63,66,10,63,66,11,63,236,13,63,16
        db 0,64,23,1,64,64,2,64,23,3,64,23,4,64,164,5,64,64,6,64,64,7,64,23,8,64,64,9,64,66,10,64,66,11,64,24,13,64,16
        db 0,65,23,1,65,64,2,65,23,3,65,23,4,65,12,5,65,64,6,65,23,7,65,64,8,65,12,9,65,65,10,65,66,11,65,65,13,65,16
        db 0,66,164,1,66,164,2,66,164,3,66,164,4,66,164,5,66,64,6,66,23,7,66,64,8,66,163,9,66,64,10,66,66,11,66,66,12,66,236,14,66,16
        db 0,67,23,1,67,64,2,67,64,3,67,23,4,67,164,5,67,23,6,67,23,7,67,23,8,67,22,9,67,64,10,67,66,11,67,66,12,67,24,14,67,16
        db 0,68,164,1,68,23,2,68,12,3,68,12,4,68,12,5,68,12,6,68,12,7,68,12,8,68,12,9,68,12,10,68,65,11,68,66,12,68,65,14,68,16
        db 0,69,138,1,69,138,2,69,138,3,69,12,4,69,12,5,69,6,6,69,6,7,69,6,8,69,6,9,69,6,10,69,12,11,69,66,12,69,66,13,69,210,15,69,16
        db 0,70,162,1,70,162,2,70,6,3,70,12,4,70,12,5,70,139,6,70,139,7,70,139,8,70,139,9,70,6,10,70,140,11,70,65,12,70,65,13,70,162,15,70,16
        db 0,71,162,1,71,162,2,71,6,3,71,12,4,71,12,5,71,6,6,71,6,7,71,6,8,71,6,9,71,6,10,71,6,11,71,12,12,71,65,13,71,139,15,71,16
        db 0,72,162,1,72,162,2,72,6,3,72,12,4,72,12,5,72,139,6,72,139,7,72,139,8,72,139,9,72,139,10,72,6,11,72,12,12,72,12,13,72,12,15,72,16
        db 0,73,162,1,73,162,2,73,6,3,73,12,4,73,12,5,73,6,6,73,6,7,73,139,8,73,6,9,73,139,10,73,6,11,73,140,12,73,12,13,73,12,14,73,17,16,73,16
        db 0,74,162,1,74,162,2,74,6,3,74,12,4,74,12,5,74,139,6,74,6,7,74,6,8,74,6,9,74,139,10,74,6,11,74,140,12,74,12,13,74,12,14,74,210,16,74,16
        db 0,75,162,1,75,162,2,75,162,3,75,12,4,75,12,5,75,12,6,75,12,7,75,12,8,75,12,9,75,12,10,75,12,11,75,12,12,75,12,13,75,65,14,75,139,16,75,16
        db 0,76,162,1,76,162,2,76,162,3,76,162,4,76,162,5,76,162,6,76,162,7,76,162,8,76,161,9,76,162,10,76,162,11,76,162,12,76,12,13,76,12,14,76,140,16,76,16
        db 0,77,162,1,77,162,2,77,162,3,77,162,4,77,162,5,77,162,6,77,162,7,77,162,8,77,162,9,77,162,10,77,162,11,77,162,12,77,12,13,77,12,14,77,12,15,77,18,17,77,16
        db 0,78,162,1,78,162,2,78,162,3,78,162,4,78,161,5,78,162,6,78,162,7,78,162,8,78,162,9,78,162,10,78,162,11,78,162,12,78,164,13,78,12,14,78,12,15,78,18,17,78,16
        db 0,79,138,1,79,161,2,79,162,3,79,162,4,79,162,5,79,163,6,79,162,7,79,162,8,79,161,9,79,162,10,79,162,11,79,162,12,79,163,13,79,12,14,79,12,15,79,138,17,79,16
        db 0,80,19,1,80,19,2,80,234,3,80,235,4,80,137,5,80,160,6,80,161,7,80,162,8,80,162,9,80,162,10,80,162,11,80,162,12,80,162,13,80,12,14,80,12,15,80,137,17,80,16,19,80,16,20,80,16,21,80,16
        db 0,81,19,1,81,19,2,81,19,3,81,19,4,81,19,5,81,240,6,81,19,7,81,234,8,81,137,9,81,138,10,81,162,11,81,163,12,81,162,13,81,12,14,81,12,15,81,140,17,81,16,18,81,16,19,81,16
        db 0,82,19,1,82,19,2,82,19,3,82,19,4,82,19,5,82,19,6,82,19,7,82,19,8,82,19,9,82,19,10,82,19,11,82,137,12,82,160,13,82,12,14,82,12,15,82,12,16,82,210,19,82,17,20,82,19,21,82,224,22,82,16
        db 0,83,19,1,83,19,2,83,19,3,83,19,4,83,19,5,83,19,6,83,19,7,83,19,8,83,233,9,83,233,10,83,19,11,83,19,12,83,224,13,83,235,14,83,140,15,83,12,16,83,23,17,83,8,18,83,8,19,83,25,20,83,28,21,83,27,22,83,23,24,83,16
        db 0,84,235,1,84,19,2,84,19,3,84,19,4,84,19,5,84,19,6,84,19,7,84,19,8,84,19,9,84,19,10,84,19,11,84,233,12,84,234,13,84,19,14,84,234,15,84,139,16,84,164,17,84,22,18,84,23,19,84,25,20,84,25,21,84,25,22,84,24,24,84,16
        db 0,85,20,1,85,20,2,85,20,3,85,20,4,85,235,5,85,19,6,85,19,7,85,19,8,85,19,9,85,19,10,85,19,11,85,19,12,85,19,13,85,19,14,85,19,15,85,233,16,85,161,17,85,22,18,85,23,19,85,25,20,85,7,21,85,7,22,85,24,24,85,16
        db 0,86,20,1,86,20,2,86,20,3,86,20,4,86,20,5,86,20,6,86,20,7,86,235,8,86,19,9,86,19,10,86,19,11,86,19,12,86,19,13,86,19,14,86,19,15,86,19,16,86,19,17,86,8,18,86,23,19,86,24,20,86,25,21,86,25,22,86,23,24,86,16
        db 0,87,20,1,87,20,2,87,20,3,87,20,4,87,20,5,87,20,6,87,20,7,87,20,8,87,20,9,87,19,10,87,19,11,87,19,12,87,19,13,87,19,14,87,19,15,87,19,16,87,19,17,87,19,18,87,20,19,87,24,20,87,25,21,87,7,22,87,23,24,87,16
        db 0,88,20,1,88,20,2,88,20,3,88,20,4,88,20,5,88,20,6,88,20,7,88,20,8,88,20,9,88,20,10,88,19,11,88,19,12,88,19,13,88,19,14,88,19,15,88,19,16,88,19,17,88,19,18,88,232,19,88,174,20,88,172,21,88,20,22,88,18,24,88,16
        db 0,89,20,1,89,20,2,89,20,3,89,20,4,89,20,5,89,20,6,89,20,7,89,20,8,89,20,9,89,20,10,89,20,11,89,235,12,89,19,13,89,19,14,89,19,15,89,19,16,89,19,17,89,19,18,89,19,19,89,209,20,89,19,21,89,17,23,89,16
        db 0,90,20,1,90,20,2,90,20,3,90,20,4,90,20,5,90,20,6,90,20,7,90,20,8,90,20,9,90,20,10,90,20,11,90,20,12,90,235,13,90,19,14,90,233,15,90,19,16,90,233,17,90,19,18,90,19,19,90,19,20,90,233,21,90,19,22,90,17,24,90,16
        db 0,91,20,1,91,237,2,91,237,3,91,20,4,91,20,5,91,20,6,91,20,7,91,20,8,91,20,9,91,20,10,91,20,11,91,20,12,91,20,13,91,20,14,91,19,15,91,19,16,91,19,17,91,233,18,91,233,19,91,233,20,91,19,21,91,19,22,91,209,23,91,215,25,91,16
        db 0,92,161,1,92,161,2,92,160,3,92,137,4,92,137,5,92,20,6,92,20,7,92,20,8,92,237,9,92,20,10,92,20,11,92,20,12,92,20,13,92,20,14,92,20,15,92,236,16,92,235,17,92,19,18,92,233,19,92,234,20,92,233,21,92,19,22,92,19,23,92,235,24,92,19,26,92,16,27,92,16
        db 0,93,162,1,93,162,2,93,163,3,93,162,4,93,162,5,93,162,6,93,161,7,93,161,8,93,160,9,93,137,10,93,20,11,93,20,12,93,237,13,93,20,14,93,20,15,93,20,16,93,140,17,93,8,18,93,223,19,93,19,20,93,19,21,93,235,22,93,234,23,93,233,24,93,19,25,93,18,27,93,16,28,93,16,29,93,16
        db 0,94,162,1,94,162,2,94,162,3,94,162,4,94,162,5,94,162,6,94,162,7,94,162,8,94,162,9,94,162,10,94,162,11,94,161,12,94,160,13,94,137,14,94,20,15,94,243,16,94,20,17,94,19,19,94,16,20,94,16,21,94,16,22,94,18,23,94,18,24,94,232,25,94,208,26,94,19,28,94,16,29,94,16,30,94,16
        db 0,95,162,1,95,162,2,95,162,3,95,162,4,95,162,5,95,162,6,95,162,7,95,162,8,95,162,9,95,162,10,95,162,11,95,162,12,95,162,13,95,162,14,95,162,15,95,139,16,95,138,17,95,235,18,95,125,20,95,18,22,95,16,24,95,196,25,95,244,26,95,20,27,95,245,28,95,17,30,95,16
        db 0,96,138,1,96,138,2,96,138,3,96,138,4,96,138,5,96,138,6,96,138,7,96,138,8,96,138,9,96,138,10,96,137,11,96,138,12,96,138,13,96,138,14,96,138,15,96,6,16,96,6,17,96,138,18,96,137,19,96,160,20,96,160,21,96,138,22,96,138,23,96,162,24,96,138,25,96,138,26,96,161,27,96,136,28,96,235,29,96,137,30,96,209,32,96,16
        db 0,97,138,1,97,138,2,97,138,3,97,138,4,97,138,5,97,138,6,97,138,7,97,138,8,97,138,9,97,138,10,97,138,11,97,138,12,97,138,13,97,138,14,97,138,15,97,6,16,97,6,17,97,138,18,97,161,19,97,161,20,97,161,21,97,162,22,97,138,23,97,113,24,97,113,25,97,208,26,97,208,27,97,209,28,97,209,29,97,208,30,97,208,32,97,16
        db 0,98,162,1,98,162,2,98,162,3,98,162,4,98,162,5,98,162,6,98,162,7,98,162,8,98,162,9,98,162,10,98,162,11,98,162,12,98,162,13,98,162,14,98,162,15,98,12,16,98,42,17,98,164,18,98,23,19,98,25,20,98,7,21,98,7,22,98,24,24,98,16
        db 0,99,162,1,99,162,2,99,162,3,99,162,4,99,162,5,99,162,6,99,162,7,99,162,8,99,162,9,99,162,10,99,162,11,99,162,12,99,162,13,99,162,14,99,162,15,99,12,16,99,12,17,99,163,18,99,22,19,99,24,20,99,25,21,99,25,22,99,23,24,99,16,25,99,16,26,99,16,27,99,16,28,99,16,29,99,16,30,99,16
        db 0,100,162,1,100,162,2,100,162,3,100,162,4,100,162,5,100,162,6,100,162,7,100,162,8,100,162,9,100,162,10,100,162,11,100,162,12,100,162,13,100,162,14,100,162,15,100,12,16,100,42,17,100,163,18,100,173,19,100,24,20,100,25,21,100,7,22,100,23,24,100,16
        db 0,101,162,1,101,162,2,101,162,3,101,162,4,101,162,5,101,162,6,101,162,7,101,162,8,101,162,9,101,162,10,101,162,11,101,162,12,101,162,13,101,162,14,101,162,15,101,12,16,101,12,17,101,24,19,101,19,20,101,20,21,101,20,22,101,18,24,101,16
        db 0,102,162,1,102,162,2,102,162,3,102,162,4,102,162,5,102,162,6,102,162,7,102,162,8,102,162,9,102,162,10,102,162,11,102,162,12,102,162,13,102,162,14,102,162,15,102,12,16,102,42,17,102,164,19,102,16
        db 0,103,162,1,103,162,2,103,162,3,103,162,4,103,162,5,103,162,6,103,162,7,103,162,8,103,162,9,103,162,10,103,162,11,103,162,12,103,162,13,103,162,14,103,162,15,103,12,16,103,12,17,103,164,19,103,16,20,103,16,21,103,16,22,103,16
        db 0,104,162,1,104,162,2,104,162,3,104,162,4,104,162,5,104,162,6,104,162,7,104,162,8,104,162,9,104,162,10,104,162,11,104,162,12,104,162,13,104,162,14,104,162,15,104,12,16,104,12,17,104,164,19,104,16
        db 0,105,162,1,105,162,2,105,162,3,105,162,4,105,162,5,105,162,6,105,162,7,105,162,8,105,162,9,105,162,10,105,162,11,105,162,12,105,162,13,105,162,14,105,162,15,105,12,16,105,12,17,105,164,19,105,16
        db 0,106,162,1,106,162,2,106,162,3,106,162,4,106,162,5,106,162,6,106,162,7,106,162,8,106,162,9,106,162,10,106,162,11,106,162,12,106,162,13,106,162,14,106,162,15,106,12,16,106,12,17,106,164,19,106,16,20,106,16,21,106,16,22,106,16
        db 0,107,162,1,107,162,2,107,162,3,107,162,4,107,162,5,107,162,6,107,162,7,107,162,8,107,162,9,107,162,10,107,162,11,107,162,12,107,162,13,107,162,14,107,162,15,107,140,16,107,12,17,107,164,19,107,16,22,107,16
        db 0,108,162,1,108,162,2,108,162,3,108,162,4,108,162,5,108,162,6,108,162,7,108,162,8,108,162,9,108,162,10,108,162,11,108,162,12,108,162,13,108,162,14,108,162,15,108,12,16,108,42,17,108,164,19,108,17,20,108,19,21,108,19,22,108,18
        db 0,109,162,1,109,162,2,109,162,3,109,162,4,109,162,5,109,162,6,109,162,7,109,162,8,109,162,9,109,162,10,109,162,11,109,162,12,109,162,13,109,162,14,109,162,15,109,12,16,109,12,17,109,164,18,109,174,19,109,25,20,109,28,21,109,27,22,109,23,24,109,16
        db 0,110,162,1,110,162,2,110,162,3,110,162,4,110,162,5,110,162,6,110,162,7,110,162,8,110,162,9,110,162,10,110,162,11,110,162,12,110,162,13,110,162,14,110,162,15,110,12,16,110,12,17,110,163,18,110,23,19,110,25,20,110,25,21,110,25,22,110,24,24,110,16
        db 0,111,162,1,111,162,2,111,162,3,111,162,4,111,162,5,111,162,6,111,162,7,111,162,8,111,162,9,111,162,10,111,162,11,111,162,12,111,162,13,111,162,14,111,162,15,111,12,16,111,12,17,111,163,18,111,23,19,111,25,20,111,7,21,111,7,22,111,23,24,111,16
        db 0,112,162,1,112,162,2,112,162,3,112,162,4,112,162,5,112,162,6,112,162,7,112,162,8,112,162,9,112,162,10,112,162,11,112,162,12,112,162,13,112,162,14,112,162,15,112,12,16,112,12,17,112,163,18,112,22,19,112,24,20,112,25,21,112,25,22,112,23,24,112,16
        db 0,113,162,1,113,162,2,113,162,3,113,162,4,113,162,5,113,162,6,113,162,7,113,162,8,113,161,9,113,162,10,113,162,11,113,162,12,113,162,13,113,162,14,113,162,15,113,140,16,113,12,17,113,164,18,113,173,19,113,24,20,113,25,21,113,7,22,113,23,24,113,16
        db 0,114,162,1,114,162,2,114,162,3,114,162,4,114,162,5,114,162,6,114,162,7,114,162,8,114,161,9,114,162,10,114,162,11,114,162,12,114,162,13,114,161,14,114,162,15,114,12,16,114,42,17,114,163,19,114,19,20,114,20,21,114,20,22,114,17,24,114,16
        db 0,115,162,1,115,162,2,115,162,3,115,162,4,115,161,5,115,12,6,115,12,7,115,12,8,115,12,9,115,12,10,115,12,11,115,12,12,115,12,13,115,12,14,115,12,15,115,12,16,115,65,17,115,137,19,115,16
        db 0,116,139,1,116,138,2,116,138,3,116,138,4,116,137,5,116,12,6,116,65,7,116,140,8,116,6,9,116,139,10,116,139,11,116,139,12,116,6,13,116,6,14,116,139,15,116,12,16,116,65,17,116,137,19,116,16,20,116,16,21,116,16,22,116,16
        db 0,117,161,1,117,137,2,117,137,3,117,137,4,117,137,5,117,12,6,117,12,7,117,139,8,117,6,9,117,6,10,117,6,11,117,6,12,117,6,13,117,6,14,117,139,15,117,12,16,117,65,17,117,138,19,117,16
        db 0,118,161,1,118,137,2,118,137,3,118,138,4,118,137,5,118,12,6,118,65,7,118,140,8,118,6,9,118,139,10,118,139,11,118,139,12,118,139,13,118,6,14,118,140,15,118,12,16,118,12,17,118,18,19,118,16
        db 0,119,161,1,119,137,2,119,138,3,119,138,4,119,137,5,119,12,6,119,12,7,119,139,8,119,6,9,119,6,10,119,6,11,119,6,12,119,6,13,119,6,14,119,140,15,119,65,16,119,12,17,119,17,19,119,16
        db 0,120,139,1,120,137,2,120,137,3,120,138,4,120,137,5,120,12,6,120,65,7,120,140,8,120,6,9,120,139,10,120,139,11,120,139,12,120,139,13,120,6,14,120,12,15,120,65,16,120,42,17,120,17,19,120,16
        db 0,121,140,1,121,137,2,121,137,3,121,138,4,121,137,5,121,12,6,121,12,7,121,139,8,121,6,9,121,139,10,121,6,11,121,6,12,121,139,13,121,6,14,121,140,15,121,65,16,121,42,17,121,17,19,121,16
        db 0,122,139,1,122,6,2,122,6,3,122,6,4,122,137,5,122,12,6,122,12,7,122,139,8,122,139,9,122,139,10,122,139,11,122,139,12,122,139,13,122,6,14,122,12,15,122,65,16,122,12,17,122,17,19,122,16
        db 0,123,234,1,123,234,2,123,137,3,123,137,4,123,137,5,123,12,6,123,65,7,123,139,8,123,6,9,123,139,10,123,6,11,123,6,12,123,6,13,123,6,14,123,12,15,123,12,16,123,12,17,123,16,19,123,16
        db 0,124,19,1,124,19,2,124,19,3,124,19,4,124,233,5,124,137,6,124,140,7,124,140,8,124,139,9,124,139,10,124,139,11,124,139,12,124,139,13,124,6,14,124,12,15,124,12,16,124,64,19,124,16
        db 0,125,19,1,125,19,2,125,19,3,125,19,4,125,19,5,125,224,6,125,224,7,125,19,8,125,137,9,125,6,10,125,6,11,125,6,12,125,6,13,125,6,14,125,65,15,125,66,16,125,164,18,125,16
        db 0,126,19,1,126,233,2,126,19,3,126,19,4,126,19,5,126,19,6,126,234,7,126,19,8,126,240,9,126,138,10,126,12,11,126,12,12,126,12,13,126,12,14,126,65,15,126,66,16,126,139,18,126,16
        db 0,127,19,1,127,19,2,127,19,3,127,19,4,127,19,5,127,19,6,127,19,7,127,19,8,127,233,9,127,224,10,127,20,11,127,23,12,127,64,13,127,22,14,127,65,15,127,66,16,127,139,18,127,16
        db 0,128,235,1,128,19,2,128,19,3,128,19,4,128,19,5,128,19,6,128,19,7,128,19,8,128,19,9,128,231,10,128,224,11,128,235,12,128,163,13,128,64,14,128,65,15,128,66,16,128,139,18,128,16
        db 0,129,20,1,129,20,2,129,235,3,129,19,4,129,19,5,129,19,6,129,19,7,129,19,8,129,19,9,129,19,10,129,19,11,129,19,12,129,19,13,129,163,14,129,66,15,129,66,16,129,139,18,129,16
        db 0,130,20,1,130,20,2,130,20,3,130,20,4,130,19,5,130,19,6,130,240,7,130,19,8,130,19,9,130,19,10,130,19,11,130,19,12,130,19,13,130,19,14,130,164,15,130,67,16,130,139,18,130,16
        db 0,131,20,1,131,20,2,131,20,3,131,20,4,131,20,5,131,20,6,131,137,7,131,230,8,131,19,9,131,224,10,131,232,11,131,19,12,131,19,13,131,19,14,131,18,15,131,164,16,131,163,18,131,16
        db 0,132,20,1,132,235,2,132,19,3,132,235,4,132,20,5,132,20,6,132,163,7,132,64,8,132,163,9,132,161,10,132,160,11,132,235,12,132,19,13,132,224,14,132,18,15,132,18,16,132,20,18,132,16,19,132,16,20,132,16,21,132,16
        db 0,133,164,1,133,163,2,133,162,3,133,160,4,133,20,5,133,20,6,133,243,7,133,161,8,133,64,9,133,64,10,133,64,11,133,64,12,133,163,13,133,163,14,133,163,15,133,236,16,133,232,17,133,243,18,133,17,20,133,16
        db 0,134,163,1,134,12,2,134,12,3,134,12,4,134,163,5,134,162,6,134,138,7,134,20,8,134,160,9,134,163,10,134,163,11,134,163,12,134,162,13,134,64,14,134,65,15,134,65,16,134,171,17,134,20,18,134,209,19,134,18,20,134,19,21,134,16,23,134,16
        db 0,135,137,1,135,137,2,135,137,3,135,137,4,135,137,5,135,137,6,135,6,7,135,6,8,135,137,9,135,137,10,135,137,11,135,137,12,135,136,13,135,136,14,135,136,15,135,136,16,135,137,17,135,137,18,135,137,19,135,137,20,135,137,21,135,137,23,135,16
        db 0,136,163,1,136,163,2,136,163,3,136,163,4,136,163,5,136,163,6,136,163,7,136,163,8,136,163,9,136,12,10,136,163,11,136,163,12,136,162,13,136,12,14,136,65,15,136,65,16,136,19,17,136,18,18,136,8,19,136,20,20,136,19,21,136,18,23,136,16
        db 0,137,64,1,137,64,2,137,64,3,137,64,4,137,164,5,137,64,6,137,64,7,137,64,8,137,23,9,137,64,10,137,64,11,137,64,12,137,23,13,137,65,14,137,66,15,137,66,17,137,16
        db 0,138,23,1,138,23,2,138,23,3,138,23,4,138,163,5,138,164,6,138,164,7,138,12,8,138,163,9,138,23,10,138,23,11,138,64,12,138,22,13,138,65,14,138,66,15,138,140,17,138,16,18,138,16,19,138,16,20,138,16,21,138,16
        db 0,139,23,1,139,64,2,139,23,3,139,23,4,139,164,5,139,64,6,139,23,7,139,64,8,139,12,9,139,23,10,139,64,11,139,64,12,139,23,13,139,65,14,139,66,15,139,140,17,139,16
        db 0,140,23,1,140,64,2,140,23,3,140,23,4,140,164,5,140,64,6,140,23,7,140,23,8,140,164,9,140,23,10,140,64,11,140,23,12,140,64,13,140,65,14,140,66,15,140,140,17,140,16
        db 0,141,23,1,141,64,2,141,23,3,141,23,4,141,164,5,141,64,6,141,23,7,141,64,8,141,12,9,141,23,10,141,64,11,141,23,12,141,64,13,141,66,14,141,66,15,141,140,17,141,16
        db 0,142,23,1,142,64,2,142,23,3,142,23,4,142,164,5,142,64,6,142,23,7,142,64,8,142,12,9,142,23,10,142,64,11,142,23,12,142,64,13,142,66,14,142,66,15,142,139,17,142,16
        db 0,143,23,1,143,64,2,143,23,3,143,23,4,143,164,5,143,64,6,143,23,7,143,64,8,143,12,9,143,23,10,143,64,11,143,23,12,143,64,13,143,66,14,143,66,15,143,17,17,143,16
        db 0,144,23,1,144,64,2,144,23,3,144,23,4,144,164,5,144,64,6,144,23,7,144,64,8,144,12,9,144,23,10,144,64,11,144,23,12,144,64,13,144,66,14,144,66,15,144,18,17,144,16
        db 0,145,23,1,145,64,2,145,23,3,145,23,4,145,164,5,145,64,6,145,23,7,145,64,8,145,12,9,145,23,10,145,64,11,145,23,12,145,64,13,145,66,14,145,66,15,145,17,17,145,16
        db 0,146,23,1,146,64,2,146,23,3,146,23,4,146,164,5,146,64,6,146,23,7,146,64,8,146,12,9,146,23,10,146,64,11,146,23,12,146,65,13,146,66,14,146,66,15,146,17,17,146,16
        db 0,147,23,1,147,64,2,147,23,3,147,23,4,147,164,5,147,64,6,147,23,7,147,64,8,147,12,9,147,23,10,147,64,11,147,23,12,147,65,13,147,66,14,147,66,16,147,16
        db 0,148,23,1,148,64,2,148,23,3,148,23,4,148,164,5,148,64,6,148,23,7,148,64,8,148,12,9,148,23,10,148,64,11,148,23,12,148,65,13,148,66,14,148,140,16,148,16
        db 0,149,23,1,149,64,2,149,23,3,149,23,4,149,164,5,149,64,6,149,23,7,149,64,8,149,12,9,149,23,10,149,64,11,149,23,12,149,65,13,149,66,14,149,140,16,149,16
        db 0,150,23,1,150,64,2,150,23,3,150,23,4,150,164,5,150,64,6,150,23,7,150,64,8,150,12,9,150,23,10,150,23,11,150,64,12,150,65,13,150,66,14,150,140,16,150,16
        db 0,151,23,1,151,64,2,151,64,3,151,23,4,151,164,5,151,64,6,151,23,7,151,64,8,151,164,9,151,23,10,151,23,11,151,64,12,151,66,13,151,66,14,151,164,16,151,16
        db 0,152,23,1,152,64,2,152,64,3,152,23,4,152,164,5,152,64,6,152,23,7,152,64,8,152,12,9,152,64,10,152,23,11,152,64,12,152,66,13,152,66,14,152,236,16,152,16
        db 0,153,164,1,153,164,2,153,164,3,153,12,4,153,164,5,153,64,6,153,23,7,153,64,8,153,164,9,153,164,10,153,163,11,153,64,12,153,66,13,153,66,14,153,18,16,153,16
        db 0,154,23,1,154,23,2,154,64,3,154,23,4,154,164,5,154,64,6,154,23,7,154,64,8,154,164,9,154,23,10,154,23,11,154,64,12,154,66,13,154,66,14,154,18,16,154,16
        db 0,155,23,1,155,64,2,155,23,3,155,23,4,155,164,5,155,64,6,155,23,7,155,64,8,155,164,9,155,64,10,155,23,11,155,64,12,155,66,13,155,66,14,155,18,16,155,16
        db 0,156,23,1,156,64,2,156,23,3,156,23,4,156,164,5,156,64,6,156,23,7,156,64,8,156,164,9,156,64,10,156,23,11,156,65,12,156,66,13,156,66,14,156,18,16,156,16
        db 0,157,23,1,157,64,2,157,23,3,157,23,4,157,164,5,157,64,6,157,23,7,157,64,8,157,164,9,157,64,10,157,23,11,157,65,12,157,66,13,157,65,15,157,16
        db 0,158,23,1,158,64,2,158,23,3,158,23,4,158,164,5,158,64,6,158,23,7,158,64,8,158,164,9,158,64,10,158,23,11,158,65,12,158,66,13,158,140,15,158,16
        db 0,159,23,1,159,64,2,159,23,3,159,23,4,159,164,5,159,64,6,159,23,7,159,64,8,159,164,9,159,23,10,159,23,11,159,65,12,159,66,13,159,140,15,159,16
        db 0,160,23,1,160,64,2,160,23,3,160,23,4,160,164,5,160,64,6,160,23,7,160,64,8,160,164,9,160,23,10,160,64,11,160,65,12,160,66,13,160,140,15,160,16
        db 0,161,23,1,161,64,2,161,64,3,161,64,4,161,164,5,161,64,6,161,64,7,161,64,8,161,164,9,161,23,10,161,64,11,161,66,12,161,66,13,161,164,15,161,16
        db 0,162,164,1,162,164,2,162,164,3,162,164,4,162,163,5,162,164,6,162,164,7,162,164,8,162,163,9,162,163,10,162,64,11,162,66,12,162,66,13,162,8,15,162,16
        db 0,163,162,1,163,162,2,163,162,3,163,162,4,163,161,5,163,162,6,163,162,7,163,162,8,163,161,9,163,161,10,163,164,11,163,66,12,163,66,13,163,186,15,163,16
        db 0,164,162,1,164,162,2,164,162,3,164,162,4,164,162,5,164,162,6,164,162,7,164,162,8,164,162,9,164,161,10,164,12,11,164,66,12,164,66,13,164,18,15,164,16
        db 0,165,161,1,165,161,2,165,162,3,165,163,4,165,162,5,165,161,6,165,161,7,165,161,8,165,161,9,165,22,10,165,64,11,165,66,12,165,66,13,165,18,15,165,16
        db 0,166,12,1,166,64,2,166,65,3,166,65,4,166,65,5,166,64,6,166,64,7,166,64,8,166,65,9,166,65,10,166,65,11,166,66,12,166,66,14,166,16
        db 0,167,66,1,167,66,2,167,66,3,167,66,4,167,66,5,167,66,6,167,66,7,167,66,8,167,66,9,167,66,10,167,66,11,167,66,12,167,140,14,167,16
        db 0,168,12,1,168,12,2,168,12,3,168,12,4,168,164,5,168,164,6,168,164,7,168,164,8,168,164,9,168,12,10,168,140,11,168,65,12,168,139,14,168,16
        db 0,170,16,1,170,16,2,170,16,3,170,16,4,170,16,5,170,16,6,170,16,7,170,16,8,170,16,9,170,16,10,170,16,11,170,16,12,170,16
        shipLeftSize dw 171 
        shipLeftWidth dw 34
 
 
    shipRight db 21,0,16,22,0,16,23,0,16,24,0,16,25,0,16,26,0,16,27,0,16,28,0,16,29,0,16,30,0,16,31,0,16,32,0,16,33,0,16
        db 19,2,16,21,2,139,22,2,65,23,2,140,24,2,12,25,2,164,26,2,164,27,2,164,28,2,164,29,2,164,30,2,12,31,2,12,32,2,12,33,2,12
        db 19,3,16,21,3,140,22,3,66,23,3,66,24,3,66,25,3,66,26,3,66,27,3,66,28,3,66,29,3,66,30,3,66,31,3,66,32,3,66,33,3,66
        db 19,4,16,21,4,66,22,4,66,23,4,65,24,4,65,25,4,65,26,4,64,27,4,64,28,4,64,29,4,65,30,4,65,31,4,65,32,4,64,33,4,12
        db 18,5,16,20,5,18,21,5,66,22,5,66,23,5,64,24,5,22,25,5,161,26,5,161,27,5,161,28,5,161,29,5,162,30,5,163,31,5,162,32,5,161,33,5,161
        db 18,6,16,20,6,18,21,6,66,22,6,66,23,6,12,24,6,161,25,6,162,26,6,162,27,6,162,28,6,162,29,6,162,30,6,162,31,6,162,32,6,162,33,6,162
        db 18,7,16,20,7,186,21,7,66,22,7,66,23,7,164,24,7,161,25,7,161,26,7,162,27,7,162,28,7,162,29,7,161,30,7,162,31,7,162,32,7,162,33,7,162
        db 18,8,16,20,8,8,21,8,66,22,8,66,23,8,64,24,8,163,25,8,163,26,8,164,27,8,164,28,8,164,29,8,163,30,8,164,31,8,164,32,8,164,33,8,164
        db 18,9,16,20,9,164,21,9,66,22,9,66,23,9,64,24,9,23,25,9,164,26,9,64,27,9,64,28,9,64,29,9,164,30,9,64,31,9,64,32,9,64,33,9,23
        db 18,10,16,20,10,140,21,10,66,22,10,65,23,10,64,24,10,23,25,10,164,26,10,64,27,10,23,28,10,64,29,10,164,30,10,23,31,10,23,32,10,64,33,10,23
        db 18,11,16,20,11,140,21,11,66,22,11,65,23,11,23,24,11,23,25,11,164,26,11,64,27,11,23,28,11,64,29,11,164,30,11,23,31,11,23,32,11,64,33,11,23
        db 18,12,16,20,12,140,21,12,66,22,12,65,23,12,23,24,12,64,25,12,164,26,12,64,27,12,23,28,12,64,29,12,164,30,12,23,31,12,23,32,12,64,33,12,23
        db 18,13,16,20,13,65,21,13,66,22,13,65,23,13,23,24,13,64,25,13,164,26,13,64,27,13,23,28,13,64,29,13,164,30,13,23,31,13,23,32,13,64,33,13,23
        db 17,14,16,19,14,18,20,14,66,21,14,66,22,14,65,23,14,23,24,14,64,25,14,164,26,14,64,27,14,23,28,14,64,29,14,164,30,14,23,31,14,23,32,14,64,33,14,23
        db 17,15,16,19,15,18,20,15,66,21,15,66,22,15,64,23,15,23,24,15,64,25,15,164,26,15,64,27,15,23,28,15,64,29,15,164,30,15,23,31,15,23,32,15,64,33,15,23
        db 17,16,16,19,16,18,20,16,66,21,16,66,22,16,64,23,16,23,24,16,23,25,16,164,26,16,64,27,16,23,28,16,64,29,16,164,30,16,23,31,16,64,32,16,23,33,16,23
        db 17,17,16,19,17,18,20,17,66,21,17,66,22,17,64,23,17,163,24,17,164,25,17,164,26,17,64,27,17,23,28,17,64,29,17,164,30,17,12,31,17,164,32,17,164,33,17,164
        db 17,18,16,19,18,236,20,18,66,21,18,66,22,18,64,23,18,23,24,18,64,25,18,12,26,18,64,27,18,23,28,18,64,29,18,164,30,18,23,31,18,64,32,18,64,33,18,23
        db 17,19,16,19,19,164,20,19,66,21,19,66,22,19,64,23,19,23,24,19,23,25,19,164,26,19,64,27,19,23,28,19,64,29,19,164,30,19,23,31,19,64,32,19,64,33,19,23
        db 17,20,16,19,20,140,20,20,66,21,20,65,22,20,64,23,20,23,24,20,23,25,20,12,26,20,64,27,20,23,28,20,64,29,20,164,30,20,23,31,20,23,32,20,64,33,20,23
        db 17,21,16,19,21,140,20,21,66,21,21,65,22,21,23,23,21,64,24,21,23,25,21,12,26,21,64,27,21,23,28,21,64,29,21,164,30,21,23,31,21,23,32,21,64,33,21,23
        db 17,22,16,19,22,140,20,22,66,21,22,65,22,22,23,23,22,64,24,22,23,25,22,12,26,22,64,27,22,23,28,22,64,29,22,164,30,22,23,31,22,23,32,22,64,33,22,23
        db 17,23,16,19,23,66,20,23,66,21,23,65,22,23,23,23,23,64,24,23,23,25,23,12,26,23,64,27,23,23,28,23,64,29,23,164,30,23,23,31,23,23,32,23,64,33,23,23
        db 16,24,16,18,24,17,19,24,66,20,24,66,21,24,65,22,24,23,23,24,64,24,24,23,25,24,12,26,24,64,27,24,23,28,24,64,29,24,164,30,24,23,31,24,23,32,24,64,33,24,23
        db 16,25,16,18,25,17,19,25,66,20,25,66,21,25,64,22,25,23,23,25,64,24,25,23,25,25,12,26,25,64,27,25,23,28,25,64,29,25,164,30,25,23,31,25,23,32,25,64,33,25,23
        db 16,26,16,18,26,18,19,26,66,20,26,66,21,26,64,22,26,23,23,26,64,24,26,23,25,26,12,26,26,64,27,26,23,28,26,64,29,26,164,30,26,23,31,26,23,32,26,64,33,26,23
        db 16,27,16,18,27,17,19,27,66,20,27,66,21,27,64,22,27,23,23,27,64,24,27,23,25,27,12,26,27,64,27,27,23,28,27,64,29,27,164,30,27,23,31,27,23,32,27,64,33,27,23
        db 16,28,16,18,28,139,19,28,66,20,28,66,21,28,64,22,28,23,23,28,64,24,28,23,25,28,12,26,28,64,27,28,23,28,28,64,29,28,164,30,28,23,31,28,23,32,28,64,33,28,23
        db 16,29,16,18,29,140,19,29,66,20,29,66,21,29,64,22,29,23,23,29,64,24,29,23,25,29,12,26,29,64,27,29,23,28,29,64,29,29,164,30,29,23,31,29,23,32,29,64,33,29,23
        db 16,30,16,18,30,140,19,30,66,20,30,65,21,30,64,22,30,23,23,30,64,24,30,23,25,30,164,26,30,23,27,30,23,28,30,64,29,30,164,30,30,23,31,30,23,32,30,64,33,30,23
        db 16,31,16,18,31,140,19,31,66,20,31,65,21,31,23,22,31,64,23,31,64,24,31,23,25,31,12,26,31,64,27,31,23,28,31,64,29,31,164,30,31,23,31,31,23,32,31,64,33,31,23
        db 12,32,16,13,32,16,14,32,16,15,32,16,16,32,16,18,32,140,19,32,66,20,32,65,21,32,22,22,32,64,23,32,23,24,32,23,25,32,163,26,32,12,27,32,164,28,32,164,29,32,163,30,32,23,31,32,23,32,32,23,33,32,23
        db 16,33,16,18,33,66,19,33,66,20,33,65,21,33,23,22,33,64,23,33,64,24,33,64,25,33,23,26,33,64,27,33,64,28,33,64,29,33,164,30,33,64,31,33,64,32,33,64,33,33,64
        db 10,34,16,12,34,18,13,34,19,14,34,20,15,34,8,16,34,18,17,34,19,18,34,65,19,34,65,20,34,12,21,34,162,22,34,163,23,34,163,24,34,12,25,34,163,26,34,163,27,34,163,28,34,163,29,34,163,30,34,163,31,34,163,32,34,163,33,34,163
        db 10,35,16,12,35,137,13,35,137,14,35,137,15,35,137,16,35,137,17,35,137,18,35,136,19,35,136,20,35,136,21,35,136,22,35,137,23,35,137,24,35,137,25,35,137,26,35,6,27,35,6,28,35,137,29,35,137,30,35,137,31,35,137,32,35,137,33,35,137
        db 10,36,16,12,36,16,13,36,19,14,36,18,15,36,209,16,36,20,17,36,171,18,36,65,19,36,65,20,36,64,21,36,162,22,36,163,23,36,163,24,36,163,25,36,160,26,36,20,27,36,138,28,36,162,29,36,163,30,36,12,31,36,12,32,36,12,33,36,163
        db 13,37,16,15,37,17,16,37,243,17,37,232,18,37,236,19,37,163,20,37,163,21,37,163,22,37,64,23,37,64,24,37,64,25,37,64,26,37,161,27,37,243,28,37,20,29,37,20,30,37,160,31,37,162,32,37,163,33,37,164
        db 12,38,16,13,38,16,14,38,16,15,38,16,17,38,20,18,38,18,19,38,18,20,38,224,21,38,19,22,38,235,23,38,160,24,38,161,25,38,163,26,38,64,27,38,163,28,38,20,29,38,20,30,38,235,31,38,19,32,38,235,33,38,20
        db 15,39,16,17,39,163,18,39,164,19,39,18,20,39,19,21,39,19,22,39,19,23,39,232,24,39,224,25,39,19,26,39,230,27,39,137,28,39,20,29,39,20,30,39,20,31,39,20,32,39,20,33,39,20
        db 15,40,16,17,40,139,18,40,67,19,40,164,20,40,19,21,40,19,22,40,19,23,40,19,24,40,19,25,40,19,26,40,19,27,40,240,28,40,19,29,40,19,30,40,20,31,40,20,32,40,20,33,40,20
        db 15,41,16,17,41,139,18,41,66,19,41,66,20,41,163,21,41,19,22,41,19,23,41,19,24,41,19,25,41,19,26,41,19,27,41,19,28,41,19,29,41,19,30,41,19,31,41,235,32,41,20,33,41,20
        db 15,42,16,17,42,139,18,42,66,19,42,65,20,42,64,21,42,163,22,42,235,23,42,224,24,42,231,25,42,19,26,42,19,27,42,19,28,42,19,29,42,19,30,42,19,31,42,19,32,42,19,33,42,235
        db 15,43,16,17,43,139,18,43,66,19,43,65,20,43,22,21,43,64,22,43,23,23,43,20,24,43,224,25,43,233,26,43,19,27,43,19,28,43,19,29,43,19,30,43,19,31,43,19,32,43,19,33,43,19
        db 15,44,16,17,44,139,18,44,66,19,44,65,20,44,12,21,44,12,22,44,12,23,44,12,24,44,138,25,44,240,26,44,19,27,44,234,28,44,19,29,44,19,30,44,19,31,44,19,32,44,233,33,44,19
        db 15,45,16,17,45,164,18,45,66,19,45,65,20,45,6,21,45,6,22,45,6,23,45,6,24,45,6,25,45,137,26,45,19,27,45,224,28,45,224,29,45,19,30,45,19,31,45,19,32,45,19,33,45,19
        db 14,46,16,17,46,64,18,46,12,19,46,12,20,46,6,21,46,139,22,46,139,23,46,139,24,46,139,25,46,139,26,46,140,27,46,140,28,46,137,29,46,233,30,46,19,31,46,19,32,46,19,33,46,19
        db 14,47,16,16,47,16,17,47,12,18,47,12,19,47,12,20,47,6,21,47,6,22,47,6,23,47,6,24,47,139,25,47,6,26,47,139,27,47,65,28,47,12,29,47,137,30,47,137,31,47,137,32,47,234,33,47,234
        db 14,48,16,16,48,17,17,48,12,18,48,65,19,48,12,20,48,6,21,48,139,22,48,139,23,48,139,24,48,139,25,48,139,26,48,139,27,48,12,28,48,12,29,48,137,30,48,6,31,48,6,32,48,6,33,48,139
        db 14,49,16,16,49,17,17,49,42,18,49,65,19,49,140,20,49,6,21,49,139,22,49,6,23,49,6,24,49,139,25,49,6,26,49,139,27,49,12,28,49,12,29,49,137,30,49,138,31,49,137,32,49,137,33,49,140
        db 14,50,16,16,50,17,17,50,42,18,50,65,19,50,12,20,50,6,21,50,139,22,50,139,23,50,139,24,50,139,25,50,6,26,50,140,27,50,65,28,50,12,29,50,137,30,50,138,31,50,137,32,50,137,33,50,139
        db 14,51,16,16,51,17,17,51,12,18,51,65,19,51,140,20,51,6,21,51,6,22,51,6,23,51,6,24,51,6,25,51,6,26,51,139,27,51,12,28,51,12,29,51,137,30,51,138,31,51,138,32,51,137,33,51,161
        db 14,52,16,16,52,18,17,52,12,18,52,12,19,52,140,20,52,6,21,52,139,22,52,139,23,52,139,24,52,139,25,52,6,26,52,140,27,52,65,28,52,12,29,52,137,30,52,138,31,52,137,32,52,137,33,52,161
        db 14,53,16,16,53,138,17,53,65,18,53,12,19,53,139,20,53,6,21,53,6,22,53,6,23,53,6,24,53,6,25,53,6,26,53,139,27,53,12,28,53,12,29,53,137,30,53,137,31,53,137,32,53,137,33,53,161
        db 11,54,16,12,54,16,13,54,16,14,54,16,16,54,137,17,54,65,18,54,12,19,54,139,20,54,6,21,54,6,22,54,139,23,54,139,24,54,139,25,54,6,26,54,140,27,54,65,28,54,12,29,54,137,30,54,138,31,54,138,32,54,138,33,54,139
        db 14,55,16,16,55,137,17,55,65,18,55,12,19,55,12,20,55,12,21,55,12,22,55,12,23,55,12,24,55,12,25,55,12,26,55,12,27,55,12,28,55,12,29,55,161,30,55,162,31,55,162,32,55,162,33,55,162
        db 9,56,16,11,56,17,12,56,20,13,56,20,14,56,19,16,56,163,17,56,42,18,56,12,19,56,162,20,56,161,21,56,162,22,56,162,23,56,162,24,56,162,25,56,161,26,56,162,27,56,162,28,56,162,29,56,162,30,56,162,31,56,162,32,56,162,33,56,162
        db 9,57,16,11,57,23,12,57,7,13,57,25,14,57,24,15,57,173,16,57,164,17,57,12,18,57,140,19,57,162,20,57,162,21,57,162,22,57,162,23,57,162,24,57,162,25,57,161,26,57,162,27,57,162,28,57,162,29,57,162,30,57,162,31,57,162,32,57,162,33,57,162
        db 9,58,16,11,58,23,12,58,25,13,58,25,14,58,24,15,58,22,16,58,163,17,58,12,18,58,12,19,58,162,20,58,162,21,58,162,22,58,162,23,58,162,24,58,162,25,58,162,26,58,162,27,58,162,28,58,162,29,58,162,30,58,162,31,58,162,32,58,162,33,58,162
        db 9,59,16,11,59,23,12,59,7,13,59,7,14,59,25,15,59,23,16,59,163,17,59,12,18,59,12,19,59,162,20,59,162,21,59,162,22,59,162,23,59,162,24,59,162,25,59,162,26,59,162,27,59,162,28,59,162,29,59,162,30,59,162,31,59,162,32,59,162,33,59,162
        db 9,60,16,11,60,24,12,60,25,13,60,25,14,60,25,15,60,23,16,60,163,17,60,12,18,60,12,19,60,162,20,60,162,21,60,162,22,60,162,23,60,162,24,60,162,25,60,162,26,60,162,27,60,162,28,60,162,29,60,162,30,60,162,31,60,162,32,60,162,33,60,162
        db 9,61,16,11,61,23,12,61,27,13,61,28,14,61,25,15,61,174,16,61,164,17,61,12,18,61,12,19,61,162,20,61,162,21,61,162,22,61,162,23,61,162,24,61,162,25,61,162,26,61,162,27,61,162,28,61,162,29,61,162,30,61,162,31,61,162,32,61,162,33,61,162
        db 11,62,18,12,62,19,13,62,19,14,62,17,16,62,164,17,62,42,18,62,12,19,62,162,20,62,162,21,62,162,22,62,162,23,62,162,24,62,162,25,62,162,26,62,162,27,62,162,28,62,162,29,62,162,30,62,162,31,62,162,32,62,162,33,62,162
        db 11,63,16,14,63,16,16,63,164,17,63,12,18,63,140,19,63,162,20,63,162,21,63,162,22,63,162,23,63,162,24,63,162,25,63,162,26,63,162,27,63,162,28,63,162,29,63,162,30,63,162,31,63,162,32,63,162,33,63,162
        db 11,64,16,12,64,16,13,64,16,14,64,16,16,64,164,17,64,12,18,64,12,19,64,162,20,64,162,21,64,162,22,64,162,23,64,162,24,64,162,25,64,162,26,64,162,27,64,162,28,64,162,29,64,162,30,64,162,31,64,162,32,64,162,33,64,162
        db 14,65,16,16,65,164,17,65,12,18,65,12,19,65,162,20,65,162,21,65,162,22,65,162,23,65,162,24,65,162,25,65,162,26,65,162,27,65,162,28,65,162,29,65,162,30,65,162,31,65,162,32,65,162,33,65,162
        db 14,66,16,16,66,164,17,66,12,18,66,12,19,66,162,20,66,162,21,66,162,22,66,162,23,66,162,24,66,162,25,66,162,26,66,162,27,66,162,28,66,162,29,66,162,30,66,162,31,66,162,32,66,162,33,66,162
        db 11,67,16,12,67,16,13,67,16,14,67,16,16,67,164,17,67,12,18,67,12,19,67,162,20,67,162,21,67,162,22,67,162,23,67,162,24,67,162,25,67,162,26,67,162,27,67,162,28,67,162,29,67,162,30,67,162,31,67,162,32,67,162,33,67,162
        db 14,68,16,16,68,164,17,68,42,18,68,12,19,68,162,20,68,162,21,68,162,22,68,162,23,68,162,24,68,162,25,68,162,26,68,162,27,68,162,28,68,162,29,68,162,30,68,162,31,68,162,32,68,162,33,68,162
        db 9,69,16,11,69,18,12,69,20,13,69,20,14,69,19,16,69,24,17,69,12,18,69,12,19,69,162,20,69,162,21,69,162,22,69,162,23,69,162,24,69,162,25,69,162,26,69,162,27,69,162,28,69,162,29,69,162,30,69,162,31,69,162,32,69,162,33,69,162
        db 9,70,16,11,70,23,12,70,7,13,70,25,14,70,24,15,70,173,16,70,163,17,70,42,18,70,12,19,70,162,20,70,162,21,70,162,22,70,162,23,70,162,24,70,162,25,70,162,26,70,162,27,70,162,28,70,162,29,70,162,30,70,162,31,70,162,32,70,162,33,70,162
        db 3,71,16,4,71,16,5,71,16,6,71,16,7,71,16,8,71,16,9,71,16,11,71,23,12,71,25,13,71,25,14,71,24,15,71,22,16,71,163,17,71,12,18,71,12,19,71,162,20,71,162,21,71,162,22,71,162,23,71,162,24,71,162,25,71,162,26,71,162,27,71,162,28,71,162,29,71,162,30,71,162,31,71,162,32,71,162,33,71,162
        db 9,72,16,11,72,24,12,72,7,13,72,7,14,72,25,15,72,23,16,72,164,17,72,42,18,72,12,19,72,162,20,72,162,21,72,162,22,72,162,23,72,162,24,72,162,25,72,162,26,72,162,27,72,162,28,72,162,29,72,162,30,72,162,31,72,162,32,72,162,33,72,162
        db 1,73,16,3,73,208,4,73,208,5,73,209,6,73,209,7,73,208,8,73,208,9,73,113,10,73,113,11,73,138,12,73,162,13,73,161,14,73,161,15,73,161,16,73,138,17,73,6,18,73,6,19,73,138,20,73,138,21,73,138,22,73,138,23,73,138,24,73,138,25,73,138,26,73,138,27,73,138,28,73,138,29,73,138,30,73,138,31,73,138,32,73,138,33,73,138
        db 1,74,16,3,74,209,4,74,137,5,74,235,6,74,136,7,74,161,8,74,138,9,74,138,10,74,162,11,74,138,12,74,138,13,74,160,14,74,160,15,74,137,16,74,138,17,74,6,18,74,6,19,74,138,20,74,138,21,74,138,22,74,138,23,74,137,24,74,138,25,74,138,26,74,138,27,74,138,28,74,138,29,74,138,30,74,138,31,74,138,32,74,138,33,74,138
        db 3,75,16,5,75,17,6,75,245,7,75,20,8,75,244,9,75,196,11,75,16,13,75,18,15,75,125,16,75,235,17,75,138,18,75,139,19,75,162,20,75,162,21,75,162,22,75,162,23,75,162,24,75,162,25,75,162,26,75,162,27,75,162,28,75,162,29,75,162,30,75,162,31,75,162,32,75,162,33,75,162
        db 3,76,16,4,76,16,5,76,16,7,76,19,8,76,208,9,76,232,10,76,18,11,76,18,12,76,16,13,76,16,14,76,16,16,76,19,17,76,20,18,76,243,19,76,20,20,76,137,21,76,160,22,76,161,23,76,162,24,76,162,25,76,162,26,76,162,27,76,162,28,76,162,29,76,162,30,76,162,31,76,162,32,76,162,33,76,162
        db 4,77,16,5,77,16,6,77,16,8,77,18,9,77,19,10,77,233,11,77,234,12,77,235,13,77,19,14,77,19,15,77,223,16,77,8,17,77,140,18,77,20,19,77,20,20,77,20,21,77,237,22,77,20,23,77,20,24,77,137,25,77,160,26,77,161,27,77,161,28,77,162,29,77,162,30,77,162,31,77,163,32,77,162,33,77,162
        db 6,78,16,7,78,16,9,78,19,10,78,235,11,78,19,12,78,19,13,78,233,14,78,234,15,78,233,16,78,19,17,78,235,18,78,236,19,78,20,20,78,20,21,78,20,22,78,20,23,78,20,24,78,20,25,78,237,26,78,20,27,78,20,28,78,20,29,78,137,30,78,137,31,78,160,32,78,161,33,78,161
        db 8,79,16,10,79,215,11,79,209,12,79,19,13,79,19,14,79,233,15,79,233,16,79,233,17,79,19,18,79,19,19,79,19,20,79,20,21,79,20,22,79,20,23,79,20,24,79,20,25,79,20,26,79,20,27,79,20,28,79,20,29,79,20,30,79,20,31,79,237,32,79,237,33,79,20
        db 9,80,16,11,80,17,12,80,19,13,80,233,14,80,19,15,80,19,16,80,19,17,80,233,18,80,19,19,80,233,20,80,19,21,80,235,22,80,20,23,80,20,24,80,20,25,80,20,26,80,20,27,80,20,28,80,20,29,80,20,30,80,20,31,80,20,32,80,20,33,80,20
        db 10,81,16,12,81,17,13,81,19,14,81,209,15,81,19,16,81,19,17,81,19,18,81,19,19,81,19,20,81,19,21,81,19,22,81,235,23,81,20,24,81,20,25,81,20,26,81,20,27,81,20,28,81,20,29,81,20,30,81,20,31,81,20,32,81,20,33,81,20
        db 9,82,16,11,82,18,12,82,20,13,82,172,14,82,174,15,82,232,16,82,19,17,82,19,18,82,19,19,82,19,20,82,19,21,82,19,22,82,19,23,82,19,24,82,20,25,82,20,26,82,20,27,82,20,28,82,20,29,82,20,30,82,20,31,82,20,32,82,20,33,82,20
        db 9,83,16,11,83,23,12,83,7,13,83,25,14,83,24,15,83,20,16,83,19,17,83,19,18,83,19,19,83,19,20,83,19,21,83,19,22,83,19,23,83,19,24,83,19,25,83,20,26,83,20,27,83,20,28,83,20,29,83,20,30,83,20,31,83,20,32,83,20,33,83,20
        db 9,84,16,11,84,23,12,84,25,13,84,25,14,84,24,15,84,23,16,84,8,17,84,19,18,84,19,19,84,19,20,84,19,21,84,19,22,84,19,23,84,19,24,84,19,25,84,19,26,84,235,27,84,20,28,84,20,29,84,20,30,84,20,31,84,20,32,84,20,33,84,20
        db 9,85,16,11,85,24,12,85,7,13,85,7,14,85,25,15,85,23,16,85,22,17,85,161,18,85,233,19,85,19,20,85,19,21,85,19,22,85,19,23,85,19,24,85,19,25,85,19,26,85,19,27,85,19,28,85,19,29,85,235,30,85,20,31,85,20,32,85,20,33,85,20
        db 9,86,16,11,86,24,12,86,25,13,86,25,14,86,25,15,86,23,16,86,22,17,86,164,18,86,139,19,86,234,20,86,19,21,86,234,22,86,233,23,86,19,24,86,19,25,86,19,26,86,19,27,86,19,28,86,19,29,86,19,30,86,19,31,86,19,32,86,19,33,86,235
        db 9,87,16,11,87,23,12,87,27,13,87,28,14,87,25,15,87,8,16,87,8,17,87,23,18,87,12,19,87,140,20,87,235,21,87,224,22,87,19,23,87,19,24,87,233,25,87,233,26,87,19,27,87,19,28,87,19,29,87,19,30,87,19,31,87,19,32,87,19,33,87,19
        db 11,88,16,12,88,224,13,88,19,14,88,17,17,88,210,18,88,12,19,88,12,20,88,12,21,88,160,22,88,137,23,88,19,24,88,19,25,88,19,26,88,19,27,88,19,28,88,19,29,88,19,30,88,19,31,88,19,32,88,19,33,88,19
        db 14,89,16,15,89,16,16,89,16,18,89,140,19,89,12,20,89,12,21,89,162,22,89,163,23,89,162,24,89,138,25,89,137,26,89,234,27,89,19,28,89,240,29,89,19,30,89,19,31,89,19,32,89,19,33,89,19
        db 12,90,16,13,90,16,14,90,16,16,90,16,18,90,137,19,90,12,20,90,12,21,90,162,22,90,162,23,90,162,24,90,162,25,90,162,26,90,162,27,90,161,28,90,160,29,90,137,30,90,235,31,90,234,32,90,19,33,90,19
        db 16,91,16,18,91,138,19,91,12,20,91,12,21,91,163,22,91,162,23,91,162,24,91,162,25,91,161,26,91,162,27,91,162,28,91,163,29,91,162,30,91,162,31,91,162,32,91,161,33,91,138
        db 16,92,16,18,92,18,19,92,12,20,92,12,21,92,164,22,92,162,23,92,162,24,92,162,25,92,162,26,92,162,27,92,162,28,92,162,29,92,161,30,92,162,31,92,162,32,92,162,33,92,162
        db 16,93,16,18,93,18,19,93,12,20,93,12,21,93,12,22,93,162,23,93,162,24,93,162,25,93,162,26,93,162,27,93,162,28,93,162,29,93,162,30,93,162,31,93,162,32,93,162,33,93,162
        db 17,94,16,19,94,140,20,94,12,21,94,12,22,94,162,23,94,162,24,94,162,25,94,161,26,94,162,27,94,162,28,94,162,29,94,162,30,94,162,31,94,162,32,94,162,33,94,162
        db 17,95,16,19,95,139,20,95,65,21,95,12,22,95,12,23,95,12,24,95,12,25,95,12,26,95,12,27,95,12,28,95,12,29,95,12,30,95,12,31,95,162,32,95,162,33,95,162
        db 17,96,16,19,96,210,20,96,12,21,96,12,22,96,140,23,96,6,24,96,139,25,96,6,26,96,6,27,96,6,28,96,139,29,96,12,30,96,12,31,96,6,32,96,162,33,96,162
        db 17,97,16,19,97,17,20,97,12,21,97,12,22,97,140,23,97,6,24,97,139,25,97,6,26,97,139,27,97,6,28,97,6,29,97,12,30,97,12,31,97,6,32,97,162,33,97,162
        db 18,98,16,20,98,12,21,98,12,22,98,12,23,98,6,24,98,139,25,98,139,26,98,139,27,98,139,28,98,139,29,98,12,30,98,12,31,98,6,32,98,162,33,98,162
        db 18,99,16,20,99,139,21,99,65,22,99,12,23,99,6,24,99,6,25,99,6,26,99,6,27,99,6,28,99,6,29,99,12,30,99,12,31,99,6,32,99,162,33,99,162
        db 18,100,16,20,100,162,21,100,65,22,100,65,23,100,140,24,100,6,25,100,139,26,100,139,27,100,139,28,100,139,29,100,12,30,100,12,31,100,6,32,100,162,33,100,162
        db 18,101,16,20,101,210,21,101,66,22,101,66,23,101,12,24,101,6,25,101,6,26,101,6,27,101,6,28,101,6,29,101,12,30,101,12,31,101,138,32,101,138,33,101,138
        db 19,102,16,21,102,65,22,102,66,23,102,65,24,102,12,25,102,12,26,102,12,27,102,12,28,102,12,29,102,12,30,102,12,31,102,12,32,102,23,33,102,164
        db 19,103,16,21,103,24,22,103,66,23,103,66,24,103,64,25,103,22,26,103,23,27,103,23,28,103,23,29,103,164,30,103,23,31,103,64,32,103,64,33,103,23
        db 19,104,16,21,104,236,22,104,66,23,104,66,24,104,64,25,104,163,26,104,64,27,104,23,28,104,64,29,104,164,30,104,164,31,104,164,32,104,164,33,104,164
        db 20,105,16,22,105,65,23,105,66,24,105,65,25,105,12,26,105,64,27,105,23,28,105,64,29,105,12,30,105,23,31,105,23,32,105,64,33,105,23
        db 20,106,16,22,106,24,23,106,66,24,106,66,25,106,64,26,106,23,27,106,64,28,106,64,29,106,164,30,106,23,31,106,23,32,106,64,33,106,23
        db 20,107,16,22,107,236,23,107,66,24,107,66,25,107,65,26,107,23,27,107,64,28,107,64,29,107,164,30,107,23,31,107,23,32,107,64,33,107,23
        db 21,108,16,23,108,66,24,108,66,25,108,66,26,108,23,27,108,23,28,108,64,29,108,164,30,108,23,31,108,23,32,108,64,33,108,23
        db 21,109,16,23,109,139,24,109,66,25,109,66,26,109,64,27,109,23,28,109,64,29,109,164,30,109,23,31,109,23,32,109,64,33,109,23
        db 21,110,16,23,110,20,24,110,66,25,110,66,26,110,65,27,110,23,28,110,64,29,110,164,30,110,23,31,110,23,32,110,64,33,110,23
        db 22,111,16,24,111,7,25,111,66,26,111,66,27,111,64,28,111,23,29,111,164,30,111,23,31,111,23,32,111,64,33,111,23
        db 22,112,16,24,112,166,25,112,66,26,112,66,27,112,65,28,112,23,29,112,164,30,112,23,31,112,23,32,112,64,33,112,23
        db 23,113,16,25,113,65,26,113,66,27,113,66,28,113,164,29,113,163,30,113,23,31,113,23,32,113,23,33,113,23
        db 23,114,16,25,114,163,26,114,66,27,114,66,28,114,65,29,114,163,30,114,64,31,114,23,32,114,64,33,114,23
        db 19,115,23,24,115,16,26,115,66,27,115,66,28,115,66,29,115,164,30,115,23,31,115,64,32,115,64,33,115,23
        db 13,116,16,14,116,16,18,116,74,19,116,0,24,116,16,26,116,28,27,116,66,28,116,66,29,116,65,30,116,23,31,116,64,32,116,64,33,116,23
        db 10,117,16,12,117,209,13,117,136,14,117,136,15,117,136,16,117,136,17,117,113,18,117,138,19,117,138,20,117,138,21,117,114,22,117,136,23,117,136,24,117,136,25,117,162,26,117,161,27,117,6,28,117,137,29,117,137,30,117,137,31,117,137,32,117,138,33,117,137
        db 10,118,16,12,118,17,13,118,232,14,118,20,15,118,137,16,118,137,17,118,23,18,118,137,19,118,184,20,118,185,21,118,208,22,118,208,23,118,209,24,118,208,25,118,235,26,118,137,27,118,164,28,118,164,29,118,12,30,118,12,31,118,161,32,118,162,33,118,161
        db 13,119,16,15,119,18,16,119,240,17,119,20,18,119,19,19,119,17,21,119,16,23,119,16,25,119,18,26,119,8,27,119,20,28,119,161,29,119,164,30,119,25,31,119,23,32,119,64,33,119,64
        db 12,120,16,13,120,16,14,120,16,16,120,17,17,120,19,18,120,232,19,120,19,20,120,232,21,120,235,22,120,18,23,120,19,24,120,16,25,120,16,27,120,22,28,120,19,29,120,19,30,120,19,31,120,20,32,120,20,33,120,137
        db 15,121,16,17,121,18,18,121,245,19,121,18,20,121,19,21,121,232,22,121,234,23,121,19,24,121,232,25,121,8,26,121,17,27,121,22,28,121,22,29,121,235,30,121,20,31,121,20,32,121,20,33,121,20
        db 16,122,16,18,122,200,19,122,23,20,122,18,21,122,19,22,122,19,23,122,19,24,122,19,25,122,232,26,122,19,27,122,19,28,122,19,29,122,19,30,122,20,31,122,20,32,122,20,33,122,20
        db 17,123,16,19,123,30,20,123,24,21,123,18,22,123,19,23,123,19,24,123,19,25,123,19,26,123,19,27,123,19,28,123,233,29,123,233,30,123,19,31,123,20,32,123,20,33,123,20
        db 17,124,16,19,124,24,20,124,15,21,124,7,22,124,18,23,124,232,24,124,19,25,124,19,26,124,19,27,124,19,28,124,19,29,124,19,30,124,19,31,124,19,32,124,235,33,124,20
        db 17,125,16,19,125,224,20,125,0,21,125,15,22,125,28,23,125,232,24,125,209,25,125,19,26,125,19,27,125,19,28,125,19,29,125,19,30,125,19,31,125,19,32,125,19,33,125,19
        db 18,126,16,20,126,27,21,126,15,22,126,0,23,126,29,24,126,20,25,126,18,26,126,19,27,126,19,28,126,19,29,126,19,30,126,19,31,126,19,32,126,19,33,126,19
        db 18,127,16,20,127,19,21,127,30,22,127,0,23,127,0,24,127,30,25,127,8,26,127,18,27,127,18,28,127,19,29,127,19,30,127,19,31,127,19,32,127,19,33,127,19
        db 19,128,16,21,128,23,22,128,15,23,128,30,24,128,0,25,128,0,26,128,27,27,128,22,28,128,19,29,128,209,30,128,18,31,128,209,32,128,233,33,128,19
        db 20,129,16,22,129,25,23,129,15,24,129,30,25,129,0,26,129,0,27,129,0,29,129,24,30,129,23,31,129,8,32,129,233,33,129,18
        db 21,130,16,23,130,25,24,130,15,25,130,0,26,130,30,27,130,0,28,130,29,29,130,27,30,130,15,31,130,30,32,130,30,33,130,28
        db 21,131,16,22,131,16,24,131,24,25,131,0,26,131,0,27,131,0,28,131,27,29,131,29,30,131,30,31,131,30,32,131,0,33,131,15
        db 22,132,16,23,132,16,25,132,224,26,132,27,27,132,29,28,132,28,29,132,15,30,132,0,31,132,0,32,132,30,33,132,30
        db 24,133,16,25,133,16,27,133,24,28,133,29,29,133,0,30,133,0,31,133,15,32,133,15,33,133,15
        db 24,134,16,26,134,19,27,134,7,28,134,78,29,134,78,30,134,75,31,134,102,32,134,29,33,134,30
        db 24,135,16,26,135,25,27,135,78,28,135,78,29,135,78,30,135,27,31,135,27,32,135,27,33,135,78
        db 23,136,16,25,136,20,26,136,27,27,136,78,28,136,78,29,136,78,30,136,78,31,136,78,32,136,78,33,136,78
        db 22,137,16,24,137,195,25,137,27,26,137,78,27,137,78,28,137,78,29,137,78,30,137,78,31,137,78,32,137,78,33,137,78
        db 22,138,16,24,138,22,25,138,7,26,138,78,27,138,78,28,138,78,29,138,78,30,138,78,31,138,78,32,138,78,33,138,78
        db 22,139,16,24,139,22,25,139,20,26,139,8,27,139,24,28,139,27,29,139,78,30,139,78,31,139,78,32,139,78,33,139,78
        db 22,140,16,24,140,209,25,140,20,26,140,235,27,140,234,28,140,20,29,140,170,30,140,24,31,140,7,32,140,78,33,140,78
        db 22,141,16,24,141,233,25,141,20,26,141,20,27,141,20,28,141,20,29,141,235,30,141,234,31,141,235,32,141,20,33,141,170
        db 22,142,16,24,142,233,25,142,20,26,142,20,27,142,20,28,142,20,29,142,20,30,142,20,31,142,20,32,142,20,33,142,230
        db 22,143,16,24,143,233,25,143,20,26,143,20,27,143,20,28,143,20,29,143,20,30,143,20,31,143,20,32,143,20,33,143,20
        db 22,144,16,24,144,19,25,144,20,26,144,20,27,144,20,28,144,20,29,144,20,30,144,20,31,144,20,32,144,20,33,144,20
        db 22,145,16,24,145,19,25,145,20,26,145,20,27,145,20,28,145,20,29,145,20,30,145,20,31,145,20,32,145,20,33,145,20
        db 22,146,16,24,146,20,25,146,20,26,146,20,27,146,20,28,146,20,29,146,20,30,146,20,31,146,20,32,146,20,33,146,20
        db 22,147,16,24,147,18,25,147,20,26,147,20,27,147,20,28,147,20,29,147,20,30,147,20,31,147,20,32,147,20,33,147,20
        db 22,148,16,24,148,17,25,148,20,26,148,20,27,148,20,28,148,20,29,148,20,30,148,20,31,148,20,32,148,20,33,148,20
        db 22,149,16,24,149,17,25,149,20,26,149,20,27,149,20,28,149,20,29,149,20,30,149,20,31,149,20,32,149,20,33,149,20
        db 22,150,16,24,150,17,25,150,20,26,150,20,27,150,20,28,150,20,29,150,20,30,150,20,31,150,20,32,150,20,33,150,20
        db 22,151,16,24,151,18,25,151,20,26,151,20,27,151,20,28,151,20,29,151,20,30,151,20,31,151,20,32,151,20,33,151,20
        db 25,152,230,26,152,20,27,152,20,28,152,20,29,152,20,30,152,20,31,152,20,32,152,20,33,152,20
        db 23,153,16,25,153,231,26,153,20,27,153,20,28,153,20,29,153,20,30,153,20,31,153,20,32,153,20,33,153,20
        db 23,154,16,25,154,20,26,154,20,27,154,20,28,154,20,29,154,20,30,154,20,31,154,20,32,154,20,33,154,20
        db 23,155,16,25,155,18,26,155,20,27,155,20,28,155,20,29,155,20,30,155,20,31,155,20,32,155,20,33,155,20
        db 23,156,16,25,156,18,26,156,20,27,156,20,28,156,20,29,156,20,30,156,20,31,156,20,32,156,20,33,156,20
        db 25,157,16,26,157,235,27,157,20,28,157,20,29,157,20,30,157,20,31,157,20,32,157,20,33,157,20
        db 24,158,16,26,158,229,27,158,20,28,158,20,29,158,20,30,158,20,31,158,20,32,158,20,33,158,20
        db 24,159,16,26,159,224,27,159,20,28,159,20,29,159,20,30,159,20,31,159,20,32,159,20,33,159,20
        db 24,160,16,26,160,18,27,160,20,28,160,20,29,160,20,30,160,20,31,160,20,32,160,20,33,160,20
        db 24,161,16,26,161,16,27,161,235,28,161,20,29,161,20,30,161,20,31,161,20,32,161,20,33,161,20
        db 25,162,16,27,162,19,28,162,20,29,162,20,30,162,20,31,162,20,32,162,20,33,162,20
        db 25,163,16,27,163,18,28,163,20,29,163,20,30,163,20,31,163,20,32,163,20,33,163,20
        db 25,164,16,27,164,208,28,164,137,29,164,137,30,164,137,31,164,137,32,164,137,33,164,137
        db 25,165,16,27,165,18,28,165,209,29,165,208,30,165,209,31,165,209,32,165,209,33,165,208
        db 27,167,16,28,167,16,29,167,16,30,167,16,31,167,16,32,167,16,33,167,16
        shipRightSize dw 171 
        shipRightWidth dw 34
 
             logoFront db 43,3,15,212,3,86,39,4,15,40,4,103,41,4,103,42,4,78,43,4,103,212,4,64,213,4,64,214,4,64,215,4,64,216,4,87,35,5,102,36,5,103,37,5,103,38,5,103,39,5,78,40,5,78,41,5,78,42,5,78,43,5,103,44,5,15,45,5,103,46,5,78,47,5,103,208,5,87,209,5,64,210,5,64,211,5,88,212,5,64
    db 213,5,64,214,5,64,215,5,64,216,5,64,217,5,64,218,5,64,219,5,63,220,5,63,17,6,103,18,6,103,19,6,103,20,6,103,21,6,103,22,6,103,23,6,103,24,6,103,25,6,103,26,6,103,27,6,103,28,6,103,29,6,103,30,6,103,31,6,102,34,6,103,35,6,103,36,6,78,37,6,78,38,6,103,39,6,78,40,6,103
    db 41,6,103,42,6,103,43,6,78,44,6,78,45,6,78,46,6,78,47,6,103,208,6,87,209,6,64,210,6,12,211,6,12,212,6,12,213,6,64,214,6,64,215,6,63,216,6,64,217,6,64,218,6,64,219,6,12,220,6,64,221,6,63,224,6,87,225,6,63,226,6,64,227,6,64,228,6,64,229,6,64,230,6,64,231,6,64,232,6,64
    db 233,6,64,234,6,64,235,6,64,236,6,64,237,6,64,238,6,63,239,6,88,17,7,78,18,7,78,19,7,78,20,7,78,21,7,78,22,7,78,23,7,78,24,7,78,25,7,78,26,7,78,27,7,78,28,7,78,29,7,78,30,7,78,31,7,103,35,7,103,36,7,103,37,7,78,38,7,103,39,7,78,40,7,78,41,7,78,42,7,78
    db 43,7,78,44,7,78,45,7,78,46,7,103,47,7,103,208,7,86,209,7,64,210,7,64,211,7,12,212,7,12,213,7,12,214,7,12,215,7,12,216,7,12,217,7,64,218,7,64,219,7,64,220,7,64,221,7,88,224,7,88,225,7,64,226,7,12,227,7,12,228,7,12,229,7,12,230,7,12,231,7,12,232,7,12,233,7,12,234,7,12
    db 235,7,12,236,7,12,237,7,12,238,7,12,239,7,63,17,8,103,18,8,78,19,8,78,20,8,78,21,8,78,22,8,78,23,8,78,24,8,78,25,8,103,26,8,103,27,8,24,28,8,25,29,8,78,30,8,103,31,8,102,33,8,103,34,8,103,35,8,78,36,8,78,37,8,78,38,8,78,39,8,78,40,8,78,41,8,78,42,8,103
    db 43,8,103,212,8,63,213,8,64,214,8,64,215,8,12,216,8,12,217,8,12,218,8,12,219,8,64,220,8,64,221,8,64,222,8,64,224,8,88,225,8,64,226,8,12,227,8,12,228,8,157,229,8,64,230,8,64,231,8,64,232,8,64,233,8,12,234,8,12,235,8,12,236,8,12,237,8,12,238,8,64,239,8,87,27,9,103,28,9,78
    db 29,9,103,30,9,174,31,9,25,33,9,103,34,9,78,35,9,78,36,9,25,37,9,7,38,9,103,39,9,103,40,9,15,216,9,88,217,9,64,218,9,64,219,9,12,220,9,12,221,9,12,222,9,64,223,9,15,224,9,23,225,9,174,226,9,25,227,9,64,228,9,64,26,10,102,27,10,103,28,10,78,29,10,173,30,10,150,31,10,25
    db 33,10,102,34,10,103,35,10,27,36,10,25,37,10,78,39,10,15,40,10,102,215,10,88,216,10,86,218,10,64,219,10,12,220,10,23,221,10,64,222,10,64,224,10,64,225,10,134,226,10,8,227,10,12,228,10,12,229,10,88,26,11,78,27,11,78,28,11,172,29,11,151,30,11,79,31,11,78,35,11,15,36,11,78,37,11,78,38,11,103
    db 39,11,78,40,11,103,41,11,15,215,11,64,216,11,64,217,11,64,218,11,64,219,11,12,220,11,64,224,11,64,225,11,12,226,11,135,227,11,135,228,11,12,229,11,64,230,11,88,26,12,78,27,12,23,28,12,150,29,12,79,30,12,78,31,12,79,34,12,174,35,12,174,36,12,79,37,12,78,38,12,78,39,12,78,40,12,78,41,12,29
    db 215,12,12,216,12,12,217,12,12,218,12,12,219,12,12,220,12,158,221,12,175,222,12,7,224,12,23,225,12,12,226,12,12,227,12,135,228,12,135,229,12,12,230,12,30,26,13,175,27,13,150,28,13,79,29,13,79,30,13,173,31,13,174,32,13,27,34,13,174,35,13,24,36,13,78,37,13,78,38,13,78,39,13,79,40,13,173,41,13,151
    db 215,13,159,216,13,160,217,13,12,218,13,12,219,13,12,220,13,12,221,13,159,222,13,25,224,13,134,225,13,135,226,13,12,227,13,12,228,13,134,229,13,134,26,14,23,27,14,79,28,14,24,29,14,151,30,14,173,31,14,79,32,14,102,34,14,78,35,14,78,36,14,78,37,14,78,38,14,24,39,14,150,40,14,173,41,14,7,214,14,15
    db 215,14,157,216,14,135,217,14,134,218,14,12,219,14,12,220,14,12,221,14,12,222,14,7,224,14,64,225,14,160,226,14,228,227,14,134,228,14,12,229,14,23,26,15,102,27,15,172,28,15,151,29,15,24,30,15,78,31,15,79,32,15,25,34,15,78,35,15,78,36,15,78,37,15,172,38,15,150,39,15,172,40,15,173,41,15,24,214,15,25
    db 215,15,158,216,15,160,217,15,134,218,15,134,219,15,12,220,15,12,221,15,12,222,15,15,223,15,53,224,15,12,225,15,12,226,15,12,227,15,135,228,15,134,229,15,64,26,16,7,27,16,173,28,16,79,29,16,78,30,16,25,31,16,150,32,16,172,34,16,103,35,16,79,36,16,175,37,16,174,38,16,24,39,16,150,40,16,172,41,16,27
    db 214,16,64,215,16,159,216,16,135,217,16,160,218,16,134,219,16,135,220,16,160,221,16,64,223,16,25,224,16,8,225,16,134,226,16,12,227,16,12,228,16,160,229,16,8,26,17,91,27,17,78,28,17,78,29,17,24,30,17,150,31,17,24,32,17,78,34,17,24,35,17,150,36,17,172,37,17,24,38,17,150,39,17,24,40,17,78,41,17,78
    db 214,17,63,215,17,12,216,17,12,217,17,135,218,17,134,219,17,12,220,17,135,221,17,159,223,17,63,224,17,12,225,17,135,226,17,134,227,17,12,228,17,12,229,17,63,27,18,78,28,18,24,29,18,151,30,18,24,31,18,78,32,18,103,34,18,23,35,18,79,36,18,24,37,18,151,38,18,24,39,18,78,40,18,78,41,18,78,214,18,63
    db 215,18,12,216,18,12,217,18,12,218,18,135,219,18,134,220,18,12,221,18,23,223,18,64,224,18,12,225,18,12,226,18,135,227,18,134,228,18,12,229,18,88,27,19,174,28,19,151,29,19,24,30,19,78,31,19,79,32,19,172,34,19,15,35,19,23,36,19,151,37,19,24,38,19,78,39,19,78,40,19,78,41,19,78,107,19,102,108,19,102
    db 147,19,88,148,19,88,149,19,15,214,19,64,215,19,12,216,19,12,217,19,12,218,19,12,219,19,135,220,19,134,221,19,64,223,19,158,224,19,12,225,19,12,226,19,12,227,19,135,228,19,134,229,19,63,14,20,30,15,20,30,16,20,30,17,20,30,18,20,30,19,20,29,20,20,29,21,20,30,22,20,30,23,20,30,24,20,30,27,20,173
    db 28,20,25,29,20,78,30,20,24,31,20,150,32,20,172,33,20,15,35,20,172,36,20,25,37,20,78,38,20,78,39,20,78,40,20,79,41,20,23,104,20,15,105,20,103,106,20,78,107,20,78,108,20,78,147,20,88,148,20,64,149,20,12,150,20,64,151,20,88,214,20,159,215,20,12,216,20,12,217,20,12,218,20,12,219,20,12,220,20,134
    db 221,20,152,223,20,23,224,20,135,225,20,134,226,20,12,227,20,12,228,20,157,231,20,86,232,20,87,233,20,29,234,20,87,235,20,87,236,20,87,237,20,87,238,20,86,239,20,86,240,20,29,241,20,29,14,21,103,15,21,78,16,21,78,17,21,78,18,21,78,19,21,78,20,21,78,21,21,78,22,21,78,23,21,78,24,21,103,27,21,103
    db 28,21,78,29,21,173,30,21,151,31,21,24,32,21,78,33,21,78,35,21,78,36,21,78,37,21,78,38,21,78,39,21,24,40,21,151,41,21,174,42,21,15,102,21,0,103,21,103,104,21,78,105,21,78,106,21,78,107,21,78,108,21,103,147,21,87,148,21,64,149,21,12,150,21,12,151,21,12,152,21,64,153,21,88,208,21,15,214,21,157
    db 215,21,228,216,21,134,217,21,12,218,21,12,219,21,12,220,21,12,221,21,88,223,21,64,224,21,12,225,21,135,226,21,135,227,21,12,228,21,12,231,21,63,232,21,64,233,21,64,234,21,64,235,21,64,236,21,64,237,21,64,238,21,64,239,21,64,240,21,64,241,21,64,242,21,0,14,22,103,15,22,78,16,22,78,17,22,78,18,22,78
    db 19,22,78,20,22,78,21,22,78,22,22,78,23,22,78,24,22,103,27,22,24,28,22,150,29,22,150,30,22,79,31,22,78,32,22,172,33,22,23,35,22,103,36,22,78,37,22,79,38,22,172,39,22,150,40,22,24,41,22,78,42,22,28,44,22,15,45,22,103,46,22,25,47,22,172,48,22,25,100,22,102,101,22,103,102,22,78,103,22,78
    db 104,22,78,105,22,78,106,22,103,149,22,63,150,22,64,151,22,12,152,22,12,153,22,12,154,22,64,155,22,64,208,22,154,209,22,157,210,22,64,211,22,88,214,22,64,215,22,12,216,22,135,217,22,135,218,22,12,219,22,12,220,22,12,221,22,15,222,22,100,223,22,159,224,22,12,225,22,12,226,22,134,227,22,135,228,22,158,231,22,64
    db 232,22,64,233,22,12,234,22,64,235,22,64,236,22,64,237,22,12,238,22,12,239,22,12,240,22,12,241,22,12,242,22,15,21,23,102,22,23,78,23,23,24,24,23,174,27,23,173,28,23,24,29,23,78,30,23,79,31,23,174,32,23,174,33,23,7,35,23,78,36,23,25,37,23,175,38,23,174,39,23,79,40,23,79,41,23,174,42,23,25
    db 43,23,103,44,23,78,45,23,25,46,23,150,47,23,173,48,23,27,98,23,103,99,23,78,100,23,78,101,23,78,102,23,78,103,23,78,104,23,102,151,23,15,152,23,64,153,23,64,154,23,12,155,23,12,156,23,12,157,23,64,158,23,86,208,23,158,209,23,135,210,23,159,211,23,12,212,23,64,213,23,64,214,23,8,215,23,160,216,23,12
    db 217,23,160,218,23,135,219,23,160,220,23,12,222,23,64,223,23,159,224,23,135,225,23,12,226,23,12,227,23,12,228,23,23,231,23,151,232,23,159,233,23,12,234,23,64,20,24,78,21,24,78,22,24,23,23,24,150,24,24,24,27,24,15,28,24,78,29,24,79,30,24,150,31,24,173,32,24,78,33,24,78,35,24,172,36,24,150,37,24,23
    db 38,24,79,39,24,24,40,24,245,41,24,246,42,24,79,43,24,78,44,24,24,45,24,150,46,24,24,47,24,79,48,24,24,95,24,30,96,24,103,97,24,78,98,24,78,99,24,78,100,24,78,101,24,103,102,24,15,103,24,102,104,24,78,105,24,78,106,24,103,149,24,87,150,24,64,151,24,64,152,24,64,154,24,64,155,24,64,156,24,12
    db 157,24,12,158,24,12,159,24,64,160,24,63,207,24,172,208,24,12,209,24,12,210,24,135,211,24,134,212,24,12,213,24,12,214,24,134,215,24,223,216,24,134,217,24,12,218,24,12,219,24,134,220,24,156,222,24,64,223,24,12,224,24,160,225,24,135,226,24,12,227,24,12,228,24,64,231,24,64,232,24,134,233,24,134,234,24,12,235,24,64
    db 236,24,30,20,25,78,21,25,23,22,25,151,23,25,24,24,25,24,25,25,6,28,25,24,29,25,151,30,25,173,31,25,78,32,25,78,33,25,78,35,25,7,36,25,25,37,25,172,38,25,245,39,25,222,40,25,150,41,25,24,42,25,79,43,25,172,44,25,151,45,25,25,46,25,79,47,25,175,48,25,151,93,25,29,94,25,103,95,25,78
    db 96,25,78,97,25,78,98,25,78,99,25,103,101,25,103,102,25,78,103,25,78,104,25,78,105,25,78,106,25,103,149,25,87,150,25,64,151,25,12,152,25,12,153,25,12,154,25,64,156,25,87,157,25,64,158,25,12,159,25,12,160,25,12,161,25,64,162,25,63,207,25,24,208,25,20,209,25,12,210,25,12,211,25,135,212,25,135,213,25,12
    db 214,25,12,215,25,134,216,25,227,217,25,225,218,25,135,219,25,12,220,25,64,222,25,64,223,25,12,224,25,12,225,25,12,226,25,228,227,25,159,228,25,64,231,25,157,232,25,159,233,25,135,234,25,135,235,25,64,20,26,23,21,26,150,22,26,172,23,26,150,24,26,173,25,26,102,28,26,174,29,26,172,30,26,78,31,26,78,32,26,24
    db 33,26,172,34,26,27,35,26,103,36,26,175,37,26,223,38,26,151,39,26,24,40,26,78,41,26,79,42,26,174,43,26,150,44,26,79,45,26,79,46,26,150,47,26,174,48,26,78,84,26,30,85,26,29,86,26,30,91,26,103,92,26,78,93,26,78,94,26,78,95,26,78,96,26,78,97,26,103,98,26,30,99,26,103,100,26,78,101,26,78
    db 102,26,78,103,26,78,104,26,78,105,26,102,150,26,87,151,26,64,152,26,64,153,26,12,154,26,12,155,26,12,156,26,64,157,26,63,158,26,87,159,26,64,160,26,12,161,26,12,162,26,12,163,26,12,164,26,64,165,26,15,170,26,88,171,26,88,207,26,64,208,26,159,209,26,228,210,26,12,211,26,12,212,26,134,213,26,135,214,26,12
    db 215,26,12,216,26,12,217,26,134,218,26,223,219,26,228,220,26,157,221,26,15,222,26,158,223,26,160,224,26,12,225,26,12,226,26,12,227,26,158,228,26,27,231,26,157,232,26,135,233,26,134,234,26,134,235,26,8,20,27,24,21,27,174,22,27,150,23,27,24,24,27,78,25,27,103,28,27,78,29,27,78,30,27,79,31,27,173,32,27,222
    db 33,27,150,34,27,78,35,27,78,36,27,174,37,27,151,38,27,79,39,27,78,40,27,25,41,27,150,42,27,172,43,27,78,44,27,79,45,27,174,46,27,173,47,27,78,48,27,78,49,27,29,82,27,103,83,27,78,84,27,78,85,27,78,86,27,78,87,27,103,88,27,15,89,27,103,90,27,78,91,27,78,92,27,78,93,27,78,94,27,103
    db 95,27,30,96,27,103,97,27,78,98,27,78,99,27,78,100,27,78,101,27,78,102,27,103,153,27,63,154,27,64,155,27,12,156,27,12,157,27,12,158,27,64,159,27,64,160,27,0,161,27,64,162,27,64,163,27,12,164,27,12,165,27,12,166,27,64,167,27,88,168,27,64,169,27,12,170,27,12,171,27,12,172,27,12,173,27,64,207,27,64
    db 208,27,12,209,27,160,210,27,135,211,27,12,212,27,12,213,27,12,214,27,135,215,27,160,216,27,12,217,27,12,218,27,135,219,27,20,220,27,12,221,27,12,222,27,159,223,27,223,224,27,135,225,27,12,226,27,12,227,27,12,230,27,15,231,27,12,232,27,12,233,27,135,234,27,134,235,27,23,20,28,28,21,28,24,22,28,79,23,28,78
    db 24,28,78,25,28,78,28,28,78,29,28,24,30,28,151,31,28,223,32,28,151,33,28,24,34,28,79,35,28,174,36,28,150,37,28,79,38,28,78,39,28,23,40,28,151,41,28,24,42,28,78,43,28,78,44,28,174,45,28,174,46,28,78,47,28,78,48,28,24,49,28,23,81,28,103,82,28,78,83,28,78,84,28,78,85,28,78,86,28,78
    db 87,28,78,88,28,78,89,28,78,90,28,78,91,28,78,92,28,78,93,28,78,94,28,103,95,28,78,96,28,78,97,28,78,98,28,78,99,28,103,100,28,15,103,28,15,104,28,29,105,28,78,106,28,79,107,28,79,108,28,79,147,28,12,148,28,12,149,28,12,150,28,12,151,28,63,152,28,30,156,28,63,157,28,64,158,28,12,159,28,12
    db 160,28,12,161,28,64,162,28,12,163,28,12,164,28,64,165,28,12,166,28,12,167,28,12,168,28,12,169,28,12,170,28,12,171,28,12,172,28,12,173,28,12,174,28,64,207,28,158,208,28,12,209,28,12,210,28,160,211,28,135,212,28,12,213,28,12,214,28,12,215,28,135,216,28,135,217,28,12,218,28,12,219,28,134,220,28,135,221,28,12
    db 222,28,12,223,28,134,224,28,223,225,28,225,226,28,160,227,28,12,230,28,88,231,28,12,232,28,12,233,28,12,234,28,159,235,28,23,21,29,78,22,29,78,23,29,78,24,29,24,25,29,23,27,29,25,28,29,151,29,29,245,30,29,150,31,29,24,32,29,79,33,29,79,34,29,174,35,29,174,36,29,79,37,29,78,38,29,172,39,29,150
    db 40,29,24,41,29,78,42,29,78,43,29,173,44,29,150,45,29,79,46,29,78,47,29,172,48,29,222,49,29,151,56,29,15,57,29,25,58,29,152,59,29,175,60,29,27,81,29,103,82,29,78,83,29,78,84,29,78,85,29,78,86,29,78,87,29,78,88,29,78,89,29,78,90,29,103,91,29,78,92,29,78,93,29,79,94,29,25,95,29,79
    db 96,29,78,97,29,78,98,29,27,99,29,79,100,29,79,101,29,79,102,29,79,103,29,24,104,29,79,105,29,79,106,29,24,107,29,79,108,29,79,147,29,64,148,29,12,149,29,40,150,29,39,151,29,39,152,29,39,153,29,39,154,29,12,155,29,12,156,29,39,157,29,12,158,29,64,159,29,12,160,29,12,161,29,12,162,29,12,163,29,12
    db 164,29,12,165,29,88,166,29,64,167,29,12,168,29,12,169,29,12,170,29,12,171,29,12,172,29,12,173,29,12,174,29,12,175,29,29,195,29,15,196,29,23,197,29,151,198,29,23,199,29,65,200,29,15,206,29,25,207,29,247,208,29,135,209,29,12,210,29,12,211,29,134,212,29,135,213,29,12,214,29,12,215,29,12,216,29,135,217,29,135
    db 218,29,12,219,29,12,220,29,160,221,29,135,222,29,12,223,29,12,224,29,12,225,29,134,226,29,228,227,29,20,228,29,172,230,29,23,231,29,159,232,29,12,233,29,12,234,29,12,235,29,63,21,30,103,22,30,78,23,30,23,24,30,246,25,30,150,26,30,173,27,30,244,28,30,173,29,30,79,30,30,78,31,30,78,32,30,79,33,30,150
    db 34,30,173,35,30,78,36,30,79,37,30,175,38,30,174,39,30,79,40,30,78,41,30,78,42,30,172,43,30,150,44,30,79,45,30,78,46,30,173,47,30,246,48,30,246,49,30,23,51,30,7,52,30,152,53,30,7,54,30,78,55,30,78,56,30,79,57,30,151,58,30,222,59,30,23,60,30,102,81,30,78,82,30,78,83,30,78,84,30,78
    db 85,30,79,86,30,79,87,30,25,88,30,24,89,30,174,90,30,24,91,30,150,92,30,151,93,30,245,94,30,221,95,30,150,96,30,24,97,30,24,98,30,24,99,30,24,100,30,172,101,30,172,102,30,172,103,30,172,104,30,172,105,30,172,106,30,24,107,30,79,148,30,12,149,30,39,150,30,40,151,30,40,152,30,40,153,30,40,154,30,40
    db 155,30,40,156,30,40,157,30,39,158,30,40,159,30,40,160,30,136,161,30,228,162,30,228,163,30,228,164,30,134,165,30,159,166,30,157,167,30,159,168,30,12,169,30,12,170,30,12,171,30,12,172,30,12,173,30,12,174,30,12,175,30,64,195,30,90,196,30,12,197,30,228,198,30,224,199,30,159,200,30,12,201,30,12,202,30,64,203,30,22
    db 204,30,23,206,30,64,207,30,8,208,30,224,209,30,135,210,30,12,211,30,12,212,30,134,213,30,135,214,30,12,215,30,12,216,30,12,217,30,160,218,30,135,219,30,160,220,30,12,221,30,160,222,30,135,223,30,160,224,30,12,225,30,12,226,30,12,227,30,160,228,30,20,229,30,158,230,30,157,231,30,225,232,30,135,233,30,12,234,30,12
    db 235,30,15,21,31,24,22,31,174,23,31,222,24,31,222,25,31,222,26,31,151,27,31,23,28,31,78,29,31,78,30,31,78,31,31,24,32,31,151,33,31,172,34,31,78,35,31,24,36,31,151,37,31,172,38,31,78,39,31,78,40,31,78,41,31,172,42,31,175,43,31,79,44,31,78,45,31,173,46,31,222,47,31,222,48,31,222,49,31,173
    db 50,31,25,51,31,245,52,31,151,53,31,79,54,31,78,55,31,79,56,31,150,57,31,223,58,31,150,59,31,78,60,31,103,80,31,24,81,31,172,82,31,172,83,31,174,84,31,150,85,31,151,86,31,246,87,31,246,88,31,245,89,31,150,90,31,24,91,31,149,92,31,149,93,31,148,94,31,172,95,31,172,96,31,172,97,31,172,98,31,172
    db 99,31,172,100,31,172,101,31,172,102,31,172,103,31,172,104,31,172,105,31,24,106,31,79,149,31,12,150,31,39,151,31,40,152,31,40,153,31,40,154,31,40,155,31,40,156,31,40,157,31,40,158,31,40,159,31,40,160,31,40,161,31,40,162,31,4,163,31,4,164,31,4,165,31,39,166,31,136,167,31,205,168,31,227,169,31,225,170,31,227
    db 171,31,228,172,31,135,173,31,134,174,31,160,175,31,157,195,31,88,196,31,12,197,31,160,198,31,223,199,31,228,200,31,12,201,31,12,202,31,12,203,31,134,204,31,246,205,31,159,206,31,12,207,31,227,208,31,223,209,31,225,210,31,228,211,31,12,212,31,12,213,31,134,214,31,135,215,31,12,216,31,12,217,31,12,218,31,12,219,31,135
    db 220,31,134,221,31,12,222,31,12,223,31,135,224,31,134,225,31,12,226,31,12,227,31,12,228,31,12,229,31,134,230,31,226,231,31,224,232,31,223,233,31,135,234,31,157,20,32,25,21,32,245,22,32,151,23,32,174,24,32,151,25,32,150,26,32,24,27,32,78,28,32,78,29,32,78,30,32,24,31,32,151,32,32,24,33,32,78,34,32,172
    db 35,32,151,36,32,24,37,32,78,38,32,78,39,32,78,40,32,24,41,32,245,42,32,173,43,32,174,44,32,151,45,32,223,46,32,223,47,32,151,48,32,174,49,32,24,50,32,150,51,32,222,52,32,24,53,32,78,54,32,78,55,32,173,56,32,245,57,32,151,58,32,79,59,32,78,60,32,103,74,32,15,75,32,27,76,32,79,77,32,78
    db 78,32,79,79,32,79,80,32,172,81,32,245,82,32,245,83,32,151,84,32,150,85,32,149,86,32,149,87,32,172,88,32,172,89,32,172,90,32,172,91,32,172,92,32,172,93,32,172,94,32,172,95,32,172,96,32,172,97,32,172,98,32,172,99,32,172,100,32,172,101,32,172,102,32,172,103,32,172,104,32,172,105,32,79,106,32,103,150,32,12
    db 151,32,40,152,32,40,153,32,40,154,32,40,155,32,40,156,32,40,157,32,40,158,32,40,159,32,40,160,32,40,161,32,40,162,32,40,163,32,40,164,32,40,165,32,40,166,32,40,167,32,40,168,32,39,169,32,4,170,32,4,171,32,136,172,32,206,173,32,205,174,32,205,175,32,135,176,32,41,177,32,12,178,32,12,179,32,12,180,32,12
    db 181,32,88,195,32,88,196,32,12,197,32,12,198,32,135,199,32,226,200,32,135,201,32,12,202,32,12,203,32,12,204,32,228,205,32,227,206,32,159,207,32,134,208,32,135,209,32,225,210,32,223,211,32,227,212,32,135,213,32,134,214,32,228,215,32,134,216,32,12,217,32,12,218,32,12,219,32,12,220,32,135,221,32,135,222,32,12,223,32,12
    db 224,32,135,225,32,134,226,32,12,227,32,12,228,32,12,229,32,12,230,32,134,231,32,228,232,32,134,233,32,135,234,32,20,235,32,156,236,32,15,18,33,102,19,33,79,20,33,150,21,33,174,22,33,23,23,33,150,24,33,172,25,33,79,26,33,78,27,33,78,28,33,78,29,33,24,30,33,150,31,33,24,32,33,79,33,33,174,34,33,150
    db 35,33,25,36,33,79,37,33,24,38,33,173,39,33,150,40,33,222,41,33,246,42,33,245,43,33,223,44,33,150,45,33,151,46,33,173,47,33,78,48,33,79,49,33,151,50,33,223,51,33,23,52,33,78,53,33,78,54,33,173,55,33,150,56,33,151,57,33,24,58,33,78,59,33,25,60,33,25,67,33,30,68,33,103,69,33,79,70,33,79
    db 71,33,79,72,33,79,73,33,24,74,33,79,75,33,79,76,33,24,77,33,24,78,33,24,79,33,24,80,33,172,81,33,172,82,33,172,83,33,172,84,33,172,85,33,172,86,33,172,87,33,172,88,33,172,89,33,172,90,33,172,91,33,172,92,33,172,93,33,172,94,33,172,95,33,172,96,33,172,97,33,172,98,33,172,99,33,172,100,33,172
    db 101,33,172,102,33,172,103,33,172,104,33,24,105,33,79,150,33,63,151,33,39,152,33,40,153,33,40,154,33,40,155,33,40,156,33,40,157,33,40,158,33,40,159,33,40,160,33,40,161,33,40,162,33,40,163,33,40,164,33,40,165,33,40,166,33,40,167,33,40,168,33,40,169,33,40,170,33,40,171,33,40,172,33,40,173,33,40,174,33,40
    db 175,33,40,176,33,40,177,33,40,178,33,40,179,33,40,180,33,39,181,33,39,182,33,39,183,33,39,184,33,12,185,33,12,186,33,12,187,33,64,188,33,88,195,33,78,196,33,157,197,33,12,198,33,12,199,33,135,200,33,135,201,33,135,202,33,12,203,33,12,204,33,12,205,33,227,206,33,225,207,33,12,208,33,12,209,33,12,210,33,228
    db 211,33,134,212,33,223,213,33,225,214,33,227,215,33,201,216,33,228,217,33,135,218,33,160,219,33,12,220,33,12,221,33,134,222,33,135,223,33,12,224,33,12,225,33,135,226,33,134,227,33,12,228,33,12,229,33,12,230,33,12,231,33,160,232,33,135,233,33,134,234,33,160,235,33,20,236,33,12,237,33,64,18,34,102,19,34,174,20,34,150
    db 21,34,174,22,34,150,23,34,24,24,34,78,25,34,78,26,34,78,27,34,78,28,34,172,29,34,150,30,34,24,31,34,24,32,34,151,33,34,222,34,34,150,35,34,151,36,34,245,37,34,151,38,34,222,39,34,151,40,34,24,41,34,24,42,34,150,43,34,174,44,34,173,45,34,174,46,34,78,47,34,79,48,34,151,49,34,223,50,34,172
    db 51,34,78,52,34,79,53,34,174,54,34,175,55,34,174,56,34,173,57,34,79,58,34,24,59,34,151,60,34,173,61,34,78,62,34,78,63,34,79,64,34,79,65,34,79,66,34,79,67,34,24,68,34,79,69,34,24,70,34,24,71,34,24,72,34,24,73,34,172,74,34,172,75,34,172,76,34,172,77,34,172,78,34,172,79,34,172,80,34,172
    db 81,34,172,82,34,172,83,34,172,84,34,172,85,34,172,86,34,172,87,34,172,88,34,172,89,34,172,90,34,172,91,34,172,92,34,172,93,34,172,94,34,172,95,34,172,96,34,172,97,34,172,98,34,172,99,34,172,100,34,149,101,34,172,102,34,172,103,34,24,104,34,79,151,34,12,152,34,39,153,34,40,154,34,40,155,34,136,156,34,40
    db 157,34,40,158,34,40,159,34,40,160,34,40,161,34,40,162,34,40,163,34,40,164,34,40,165,34,40,166,34,40,167,34,40,168,34,40,169,34,40,170,34,40,171,34,40,172,34,40,173,34,40,174,34,40,175,34,40,176,34,40,177,34,40,178,34,40,179,34,40,180,34,40,181,34,40,182,34,40,183,34,40,184,34,40,185,34,40,186,34,40
    db 187,34,39,188,34,39,189,34,39,190,34,12,191,34,39,192,34,39,193,34,12,194,34,12,195,34,23,196,34,20,197,34,134,198,34,12,199,34,160,200,34,135,201,34,134,202,34,135,203,34,12,204,34,12,205,34,12,206,34,227,207,34,224,208,34,160,209,34,12,210,34,160,211,34,135,212,34,134,213,34,20,214,34,160,215,34,12,216,34,134
    db 217,34,223,218,34,228,219,34,227,220,34,228,221,34,135,222,34,227,223,34,224,224,34,160,225,34,12,226,34,135,227,34,135,228,34,12,229,34,12,230,34,12,231,34,12,232,34,12,233,34,134,234,34,135,235,34,134,236,34,134,237,34,23,19,35,174,20,35,151,21,35,173,22,35,79,23,35,78,24,35,78,25,35,78,26,35,79,27,35,173
    db 28,35,222,29,35,150,30,35,151,31,35,222,32,35,222,33,35,151,34,35,174,35,35,24,36,35,25,37,35,23,38,35,151,39,35,79,40,35,78,41,35,174,42,35,173,43,35,172,44,35,150,45,35,79,46,35,79,47,35,151,48,35,200,49,35,172,50,35,78,51,35,79,52,35,174,53,35,245,54,35,174,55,35,246,56,35,151,57,35,244
    db 58,35,222,59,35,223,60,35,149,61,35,24,62,35,24,63,35,24,64,35,172,65,35,172,66,35,172,67,35,172,68,35,172,69,35,172,70,35,172,71,35,172,72,35,172,73,35,172,74,35,172,75,35,172,76,35,172,77,35,172,78,35,172,79,35,172,80,35,172,81,35,172,82,35,172,83,35,172,84,35,172,85,35,172,86,35,172,87,35,172
    db 88,35,172,89,35,172,90,35,172,91,35,172,92,35,172,93,35,172,94,35,172,95,35,172,96,35,172,97,35,172,98,35,172,99,35,148,100,35,222,101,35,148,102,35,24,103,35,79,104,35,15,152,35,12,153,35,40,154,35,40,155,35,205,156,35,136,157,35,40,158,35,40,159,35,40,160,35,40,161,35,40,162,35,40,163,35,40,164,35,40
    db 165,35,40,166,35,40,167,35,40,168,35,40,169,35,40,170,35,40,171,35,40,172,35,40,173,35,40,174,35,40,175,35,40,176,35,40,177,35,40,178,35,40,179,35,40,180,35,40,181,35,40,182,35,40,183,35,40,184,35,40,185,35,40,186,35,40,187,35,40,188,35,40,189,35,40,190,35,40,191,35,40,192,35,40,193,35,39,194,35,40
    db 195,35,39,196,35,203,197,35,223,198,35,227,199,35,228,200,35,224,201,35,135,202,35,135,203,35,228,204,35,12,205,35,12,206,35,12,207,35,224,208,35,224,209,35,160,210,35,12,211,35,134,212,35,134,213,35,160,214,35,135,215,35,12,216,35,12,217,35,134,218,35,134,219,35,12,220,35,160,221,35,134,222,35,135,223,35,225,224,35,223
    db 225,35,228,226,35,135,227,35,226,228,35,20,229,35,12,230,35,12,231,35,12,232,35,12,233,35,12,234,35,160,235,35,228,236,35,134,237,35,23,19,36,172,20,36,172,21,36,79,22,36,79,23,36,25,24,36,172,25,36,174,26,36,151,27,36,222,28,36,222,29,36,200,30,36,151,31,36,24,32,36,25,33,36,79,34,36,78,35,36,78
    db 36,36,25,37,36,150,38,36,24,39,36,79,40,36,174,41,36,174,42,36,24,43,36,151,44,36,24,45,36,25,46,36,151,47,36,223,48,36,222,49,36,150,50,36,150,51,36,151,52,36,222,53,36,222,54,36,221,55,36,151,56,36,150,57,36,149,58,36,149,59,36,172,60,36,172,61,36,172,62,36,172,63,36,172,64,36,172,65,36,172
    db 66,36,172,67,36,172,68,36,172,69,36,172,70,36,172,71,36,172,72,36,172,73,36,172,74,36,172,75,36,172,76,36,172,77,36,172,78,36,172,79,36,172,80,36,172,81,36,172,82,36,172,83,36,172,84,36,172,85,36,172,86,36,172,87,36,172,88,36,172,89,36,172,90,36,172,91,36,172,92,36,172,93,36,172,94,36,172,95,36,172
    db 96,36,172,97,36,172,98,36,172,99,36,221,100,36,150,101,36,172,102,36,79,103,36,103,153,36,12,154,36,40,155,36,4,156,36,202,157,36,4,158,36,40,159,36,40,160,36,40,161,36,40,162,36,40,163,36,40,164,36,40,165,36,40,166,36,40,167,36,40,168,36,40,169,36,40,170,36,40,171,36,40,172,36,40,173,36,40,174,36,40
    db 175,36,40,176,36,40,177,36,40,178,36,40,179,36,40,180,36,40,181,36,40,182,36,40,183,36,40,184,36,40,185,36,40,186,36,40,187,36,40,188,36,40,189,36,40,190,36,40,191,36,40,192,36,40,193,36,40,194,36,40,195,36,40,196,36,40,197,36,4,198,36,136,199,36,136,200,36,206,201,36,205,202,36,205,203,36,201,204,36,227
    db 205,36,135,206,36,135,207,36,226,208,36,223,209,36,225,210,36,160,211,36,12,212,36,135,213,36,134,214,36,160,215,36,135,216,36,12,217,36,12,218,36,135,219,36,160,220,36,12,221,36,12,222,36,12,223,36,12,224,36,12,225,36,134,226,36,223,227,36,223,228,36,224,229,36,228,230,36,135,231,36,134,232,36,160,233,36,12,234,36,12
    db 235,36,12,236,36,159,237,36,29,19,37,7,20,37,172,21,37,150,22,37,151,23,37,245,24,37,245,25,37,223,26,37,174,27,37,172,28,37,151,29,37,173,30,37,79,31,37,78,32,37,78,33,37,78,34,37,78,35,37,24,36,37,151,37,37,23,38,37,79,39,37,150,40,37,245,41,37,173,42,37,245,43,37,222,44,37,151,45,37,245
    db 46,37,222,47,37,221,48,37,151,49,37,150,50,37,150,51,37,149,52,37,172,53,37,172,54,37,172,55,37,172,56,37,172,57,37,172,58,37,172,59,37,172,60,37,172,61,37,172,62,37,172,63,37,172,64,37,172,65,37,172,66,37,172,67,37,172,68,37,172,69,37,172,70,37,172,71,37,172,72,37,172,73,37,172,74,37,172,75,37,172
    db 76,37,172,77,37,172,78,37,172,79,37,172,80,37,172,81,37,172,82,37,172,83,37,172,84,37,172,85,37,172,86,37,172,87,37,172,88,37,172,89,37,172,90,37,172,91,37,172,92,37,172,93,37,172,94,37,172,95,37,172,96,37,172,97,37,172,98,37,150,99,37,221,100,37,172,101,37,79,102,37,79,153,37,63,154,37,39,155,37,40
    db 156,37,136,157,37,205,158,37,40,159,37,40,160,37,40,161,37,40,162,37,40,163,37,40,164,37,40,165,37,40,166,37,40,167,37,40,168,37,40,169,37,40,170,37,40,171,37,40,172,37,40,173,37,40,174,37,40,175,37,40,176,37,40,177,37,40,178,37,40,179,37,40,180,37,40,181,37,40,182,37,40,183,37,40,184,37,40,185,37,40
    db 186,37,40,187,37,40,188,37,40,189,37,40,190,37,40,191,37,40,192,37,40,193,37,40,194,37,40,195,37,40,196,37,40,197,37,40,198,37,40,199,37,40,200,37,40,201,37,40,202,37,40,203,37,4,204,37,4,205,37,136,206,37,136,207,37,136,208,37,205,209,37,203,210,37,226,211,37,228,212,37,227,213,37,223,214,37,134,215,37,135
    db 216,37,227,217,37,160,218,37,12,219,37,20,220,37,160,221,37,12,222,37,12,223,37,12,224,37,12,225,37,12,226,37,160,227,37,228,228,37,134,229,37,160,230,37,225,231,37,224,232,37,228,233,37,228,234,37,228,235,37,134,236,37,23,17,38,102,18,38,78,19,38,78,20,38,172,21,38,172,22,38,24,23,38,24,24,38,151,25,38,172
    db 26,38,24,27,38,150,28,38,24,29,38,78,30,38,78,31,38,79,32,38,25,33,38,24,34,38,172,35,38,245,36,38,222,37,38,151,38,38,222,39,38,223,40,38,221,41,38,151,42,38,150,43,38,150,44,38,149,45,38,172,46,38,172,47,38,172,48,38,172,49,38,172,50,38,172,51,38,172,52,38,172,53,38,172,54,38,172,55,38,172
    db 56,38,172,57,38,172,58,38,172,59,38,172,60,38,172,61,38,172,62,38,172,63,38,172,64,38,172,65,38,172,66,38,172,67,38,172,68,38,172,69,38,172,70,38,172,71,38,172,72,38,172,73,38,172,74,38,172,75,38,172,76,38,172,77,38,172,78,38,172,79,38,172,80,38,172,81,38,172,82,38,172,83,38,172,84,38,172,85,38,172
    db 86,38,172,87,38,172,88,38,172,89,38,172,90,38,172,91,38,172,92,38,172,93,38,172,94,38,172,95,38,172,96,38,172,97,38,148,98,38,222,99,38,172,100,38,24,101,38,79,154,38,12,155,38,39,156,38,40,157,38,205,158,38,136,159,38,40,160,38,40,161,38,40,162,38,40,163,38,40,164,38,40,165,38,40,166,38,40,167,38,40
    db 168,38,40,169,38,40,170,38,40,171,38,40,172,38,40,173,38,40,174,38,40,175,38,40,176,38,40,177,38,40,178,38,40,179,38,40,180,38,40,181,38,40,182,38,40,183,38,40,184,38,40,185,38,40,186,38,40,187,38,40,188,38,40,189,38,40,190,38,40,191,38,40,192,38,40,193,38,40,194,38,40,195,38,40,196,38,40,197,38,40
    db 198,38,40,199,38,40,200,38,40,201,38,40,202,38,40,203,38,40,204,38,40,205,38,40,206,38,40,207,38,40,208,38,40,209,38,40,210,38,4,211,38,4,212,38,136,213,38,136,214,38,206,215,38,205,216,38,202,217,38,224,218,38,228,219,38,226,220,38,223,221,38,134,222,38,160,223,38,12,224,38,12,225,38,12,226,38,12,227,38,12
    db 228,38,135,229,38,134,230,38,159,231,38,20,232,38,160,233,38,12,234,38,160,235,38,134,236,38,12,237,38,12,238,38,64,17,39,102,18,39,78,19,39,78,20,39,78,21,39,78,22,39,79,23,39,150,24,39,173,25,39,172,26,39,245,27,39,174,28,39,172,29,39,174,30,39,150,31,39,151,32,39,222,33,39,222,34,39,221,35,39,151
    db 36,39,151,37,39,150,38,39,149,39,39,172,40,39,172,41,39,172,42,39,172,43,39,172,44,39,172,45,39,172,46,39,172,47,39,172,48,39,172,49,39,172,50,39,172,51,39,172,52,39,172,53,39,172,54,39,172,55,39,172,56,39,172,57,39,172,58,39,172,59,39,172,60,39,172,61,39,172,62,39,172,63,39,172,64,39,172,65,39,172
    db 66,39,172,67,39,172,68,39,172,69,39,172,70,39,172,71,39,172,72,39,172,73,39,172,74,39,172,75,39,172,76,39,172,77,39,172,78,39,172,79,39,172,80,39,172,81,39,172,82,39,172,83,39,172,84,39,172,85,39,172,86,39,172,87,39,172,88,39,172,89,39,172,90,39,172,91,39,172,92,39,172,93,39,172,94,39,172,95,39,172
    db 96,39,172,97,39,245,98,39,150,99,39,172,100,39,79,101,39,15,155,39,12,156,39,40,157,39,4,158,39,203,159,39,4,160,39,40,161,39,40,162,39,40,163,39,40,164,39,40,165,39,40,166,39,40,167,39,40,168,39,40,169,39,40,170,39,40,171,39,40,172,39,40,173,39,40,174,39,40,175,39,40,176,39,40,177,39,40,178,39,40
    db 179,39,40,180,39,40,181,39,40,182,39,40,183,39,40,184,39,40,185,39,40,186,39,40,187,39,40,188,39,40,189,39,40,190,39,40,191,39,40,192,39,40,193,39,40,194,39,40,195,39,40,196,39,40,197,39,40,198,39,40,199,39,40,200,39,40,201,39,40,202,39,40,203,39,40,204,39,40,205,39,40,206,39,40,207,39,40,208,39,40
    db 209,39,40,210,39,40,211,39,40,212,39,40,213,39,40,214,39,40,215,39,40,216,39,39,217,39,4,218,39,136,219,39,136,220,39,206,221,39,205,222,39,203,223,39,202,224,39,227,225,39,135,226,39,135,227,39,134,228,39,134,229,39,226,230,39,134,231,39,160,232,39,20,233,39,12,234,39,12,235,39,12,236,39,12,237,39,12,238,39,64
    db 18,40,79,19,40,79,20,40,24,21,40,172,22,40,151,23,40,222,24,40,151,25,40,222,26,40,222,27,40,221,28,40,151,29,40,151,30,40,150,31,40,149,32,40,172,33,40,172,34,40,172,35,40,172,36,40,172,37,40,172,38,40,172,39,40,172,40,40,172,41,40,172,42,40,172,43,40,172,44,40,172,45,40,172,46,40,172,47,40,172
    db 48,40,172,49,40,172,50,40,172,51,40,172,52,40,172,53,40,172,54,40,172,55,40,172,56,40,172,57,40,172,58,40,172,59,40,172,60,40,172,61,40,172,62,40,172,63,40,172,64,40,172,65,40,172,66,40,172,67,40,172,68,40,172,69,40,172,70,40,172,71,40,172,72,40,172,73,40,172,74,40,172,75,40,172,76,40,172,77,40,172
    db 78,40,172,79,40,172,80,40,172,81,40,172,82,40,172,83,40,172,84,40,172,85,40,172,86,40,172,87,40,172,88,40,172,89,40,172,90,40,172,91,40,172,92,40,172,93,40,172,94,40,172,95,40,172,96,40,150,97,40,221,98,40,172,99,40,79,100,40,78,155,40,15,156,40,12,157,40,40,158,40,136,159,40,205,160,40,40,161,40,40
    db 162,40,40,163,40,40,164,40,40,165,40,40,166,40,40,167,40,40,168,40,40,169,40,40,170,40,40,171,40,40,172,40,40,173,40,40,174,40,40,175,40,40,176,40,40,177,40,40,178,40,40,179,40,40,180,40,40,181,40,40,182,40,40,183,40,40,184,40,40,185,40,40,186,40,40,187,40,40,188,40,40,189,40,40,190,40,40,191,40,40
    db 192,40,40,193,40,40,194,40,40,195,40,40,196,40,40,197,40,40,198,40,40,199,40,40,200,40,40,201,40,40,202,40,40,203,40,40,204,40,40,205,40,40,206,40,40,207,40,40,208,40,40,209,40,40,210,40,40,211,40,40,212,40,40,213,40,40,214,40,40,215,40,40,216,40,40,217,40,40,218,40,40,219,40,40,220,40,40,221,40,40
    db 222,40,40,223,40,4,224,40,4,225,40,136,226,40,136,227,40,206,228,40,205,229,40,203,230,40,201,231,40,228,232,40,225,233,40,224,234,40,134,235,40,160,236,40,12,237,40,12,238,40,88,14,41,79,15,41,27,16,41,79,17,41,79,18,41,150,19,41,245,20,41,245,21,41,151,22,41,151,23,41,150,24,41,149,25,41,148,26,41,172
    db 27,41,172,28,41,172,29,41,172,30,41,172,31,41,172,32,41,172,33,41,172,34,41,172,35,41,172,36,41,172,37,41,172,38,41,172,39,41,172,40,41,172,41,41,172,42,41,172,43,41,172,44,41,172,45,41,172,46,41,172,47,41,172,48,41,172,49,41,172,50,41,172,51,41,172,52,41,172,53,41,172,54,41,172,55,41,172,56,41,172
    db 57,41,172,58,41,172,59,41,172,60,41,172,61,41,172,62,41,172,63,41,172,64,41,172,65,41,172,66,41,172,67,41,172,68,41,172,69,41,172,70,41,172,71,41,172,72,41,172,73,41,172,74,41,172,75,41,172,76,41,172,77,41,172,78,41,172,79,41,172,80,41,172,81,41,172,82,41,172,83,41,172,84,41,172,85,41,172,86,41,172
    db 87,41,172,88,41,172,89,41,172,90,41,172,91,41,172,92,41,172,93,41,172,94,41,172,95,41,149,96,41,222,97,41,148,98,41,79,99,41,79,156,41,63,157,41,39,158,41,40,159,41,205,160,41,136,161,41,40,162,41,40,163,41,40,164,41,40,165,41,40,166,41,40,167,41,40,168,41,40,169,41,40,170,41,40,171,41,40,172,41,40
    db 173,41,40,174,41,40,175,41,40,176,41,40,177,41,40,178,41,40,179,41,40,180,41,40,181,41,40,182,41,40,183,41,40,184,41,40,185,41,40,186,41,40,187,41,40,188,41,40,189,41,40,190,41,40,191,41,40,192,41,40,193,41,40,194,41,40,195,41,40,196,41,40,197,41,40,198,41,40,199,41,40,200,41,40,201,41,40,202,41,40
    db 203,41,40,204,41,40,205,41,40,206,41,40,207,41,40,208,41,40,209,41,40,210,41,40,211,41,40,212,41,40,213,41,40,214,41,40,215,41,40,216,41,40,217,41,40,218,41,40,219,41,40,220,41,40,221,41,40,222,41,40,223,41,40,224,41,40,225,41,40,226,41,40,227,41,40,228,41,40,229,41,40,230,41,4,231,41,4,232,41,136
    db 233,41,136,234,41,205,235,41,205,236,41,229,237,41,228,238,41,12,239,41,12,240,41,64,241,41,12,242,41,64,13,42,29,14,42,79,15,42,24,16,42,24,17,42,172,18,42,172,19,42,172,20,42,172,21,42,172,22,42,172,23,42,172,24,42,172,25,42,172,26,42,172,27,42,172,28,42,172,29,42,172,30,42,172,31,42,172,32,42,172
    db 33,42,172,34,42,172,35,42,172,36,42,172,37,42,172,38,42,172,39,42,172,40,42,172,41,42,172,42,42,172,43,42,172,44,42,172,45,42,172,46,42,172,47,42,172,48,42,172,49,42,172,50,42,172,51,42,172,52,42,172,53,42,172,54,42,172,55,42,172,56,42,172,57,42,172,58,42,172,59,42,172,60,42,172,61,42,172,62,42,172
    db 63,42,172,64,42,172,65,42,172,66,42,172,67,42,172,68,42,172,69,42,172,70,42,172,71,42,172,72,42,172,73,42,172,74,42,172,75,42,172,76,42,172,77,42,172,78,42,172,79,42,172,80,42,172,81,42,172,82,42,172,83,42,172,84,42,172,85,42,172,86,42,172,87,42,172,88,42,172,89,42,172,90,42,172,91,42,172,92,42,172
    db 93,42,172,94,42,172,95,42,221,96,42,150,97,42,24,98,42,79,144,42,24,145,42,149,146,42,150,147,42,172,148,42,25,157,42,12,158,42,41,159,42,4,160,42,202,161,42,4,162,42,40,163,42,40,164,42,40,165,42,40,166,42,40,167,42,40,168,42,40,169,42,40,170,42,40,171,42,40,172,42,40,173,42,40,174,42,40,175,42,40
    db 176,42,40,177,42,40,178,42,40,179,42,40,180,42,40,181,42,40,182,42,40,183,42,40,184,42,40,185,42,40,186,42,40,187,42,40,188,42,40,189,42,40,190,42,40,191,42,40,192,42,40,193,42,40,194,42,40,195,42,40,196,42,40,197,42,40,198,42,40,199,42,40,200,42,40,201,42,40,202,42,40,203,42,40,204,42,40,205,42,40
    db 206,42,40,207,42,40,208,42,40,209,42,40,210,42,40,211,42,40,212,42,40,213,42,40,214,42,40,215,42,40,216,42,40,217,42,40,218,42,40,219,42,40,220,42,40,221,42,40,222,42,40,223,42,40,224,42,40,225,42,40,226,42,40,227,42,40,228,42,40,229,42,40,230,42,40,231,42,40,232,42,40,233,42,40,234,42,40,235,42,40
    db 236,42,40,237,42,40,238,42,40,239,42,40,240,42,39,241,42,39,242,42,12,14,43,79,15,43,172,16,43,172,17,43,172,18,43,172,19,43,172,20,43,172,21,43,172,22,43,172,23,43,172,24,43,172,25,43,172,26,43,172,27,43,172,28,43,172,29,43,172,30,43,172,31,43,172,32,43,172,33,43,172,34,43,172,35,43,172,36,43,172
    db 37,43,172,38,43,172,39,43,172,40,43,172,41,43,172,42,43,172,43,43,172,44,43,172,45,43,172,46,43,172,47,43,172,48,43,172,49,43,172,50,43,172,51,43,172,52,43,172,53,43,172,54,43,172,55,43,172,56,43,172,57,43,172,58,43,172,59,43,172,60,43,172,61,43,172,62,43,172,63,43,172,64,43,172,65,43,172,66,43,172
    db 67,43,172,68,43,172,69,43,172,70,43,172,71,43,172,72,43,172,73,43,172,74,43,172,75,43,172,76,43,172,77,43,172,78,43,172,79,43,172,80,43,172,81,43,172,82,43,172,83,43,172,84,43,172,85,43,172,86,43,172,87,43,172,88,43,172,89,43,172,90,43,172,91,43,172,92,43,172,93,43,172,94,43,150,95,43,245,96,43,172
    db 97,43,79,98,43,27,127,43,128,128,43,24,129,43,25,130,43,25,131,43,152,142,43,25,143,43,24,144,43,79,145,43,79,146,43,79,147,43,79,148,43,79,149,43,24,150,43,24,151,43,24,158,43,12,159,43,40,160,43,136,161,43,205,162,43,40,163,43,40,164,43,40,165,43,40,166,43,40,167,43,40,168,43,40,169,43,40,170,43,40
    db 171,43,40,172,43,40,173,43,40,174,43,40,175,43,40,176,43,40,177,43,40,178,43,40,179,43,40,180,43,40,181,43,40,182,43,40,183,43,40,184,43,40,185,43,40,186,43,40,187,43,40,188,43,40,189,43,40,190,43,40,191,43,40,192,43,40,193,43,40,194,43,40,195,43,40,196,43,40,197,43,40,198,43,40,199,43,40,200,43,40
    db 201,43,40,202,43,40,203,43,40,204,43,40,205,43,40,206,43,40,207,43,40,208,43,40,209,43,40,210,43,40,211,43,40,212,43,40,213,43,40,214,43,40,215,43,40,216,43,40,217,43,40,218,43,40,219,43,40,220,43,40,221,43,40,222,43,40,223,43,40,224,43,40,225,43,40,226,43,40,227,43,40,228,43,40,229,43,40,230,43,40
    db 231,43,40,232,43,40,233,43,40,234,43,40,235,43,40,236,43,40,237,43,40,238,43,40,239,43,40,240,43,40,241,43,39,242,43,64,14,44,79,15,44,24,16,44,172,17,44,172,18,44,172,19,44,172,20,44,172,21,44,172,22,44,172,23,44,172,24,44,172,25,44,172,26,44,172,27,44,172,28,44,172,29,44,172,30,44,172,31,44,172
    db 32,44,172,33,44,172,34,44,172,35,44,172,36,44,172,37,44,172,38,44,172,39,44,172,40,44,172,41,44,172,42,44,172,43,44,172,44,44,172,45,44,172,46,44,172,47,44,172,48,44,172,49,44,172,50,44,172,51,44,172,52,44,172,53,44,172,54,44,172,55,44,172,56,44,172,57,44,172,58,44,172,59,44,172,60,44,172,61,44,172
    db 62,44,172,63,44,172,64,44,172,65,44,172,66,44,172,67,44,172,68,44,172,69,44,172,70,44,172,71,44,172,72,44,172,73,44,172,74,44,172,75,44,172,76,44,172,77,44,172,78,44,172,79,44,172,80,44,172,81,44,172,82,44,172,83,44,172,84,44,172,85,44,172,86,44,172,87,44,172,88,44,172,89,44,172,90,44,172,91,44,172
    db 92,44,172,93,44,148,94,44,222,95,44,148,96,44,79,97,44,79,102,44,101,103,44,102,104,44,102,105,44,102,106,44,102,107,44,102,108,44,30,124,44,25,125,44,24,126,44,24,127,44,25,128,44,79,129,44,79,130,44,79,131,44,25,132,44,24,133,44,25,141,44,102,142,44,103,143,44,78,144,44,102,145,44,102,146,44,102,147,44,102
    db 148,44,103,149,44,78,150,44,78,151,44,25,152,44,24,158,44,63,159,44,41,160,44,40,161,44,205,162,44,136,163,44,40,164,44,40,165,44,40,166,44,40,167,44,40,168,44,40,169,44,40,170,44,40,171,44,40,172,44,40,173,44,40,174,44,40,175,44,40,176,44,40,177,44,40,178,44,40,179,44,40,180,44,40,181,44,40,182,44,40
    db 183,44,40,184,44,40,185,44,40,186,44,40,187,44,40,188,44,40,189,44,40,190,44,40,191,44,40,192,44,40,193,44,40,194,44,40,195,44,40,196,44,40,197,44,40,198,44,40,199,44,40,200,44,40,201,44,40,202,44,40,203,44,40,204,44,40,205,44,40,206,44,40,207,44,40,208,44,40,209,44,40,210,44,40,211,44,40,212,44,40
    db 213,44,40,214,44,40,215,44,40,216,44,40,217,44,40,218,44,40,219,44,40,220,44,40,221,44,40,222,44,40,223,44,40,224,44,40,225,44,40,226,44,40,227,44,40,228,44,40,229,44,40,230,44,40,231,44,40,232,44,40,233,44,40,234,44,40,235,44,40,236,44,40,237,44,40,238,44,40,239,44,40,240,44,40,241,44,12,14,45,15
    db 15,45,79,16,45,172,17,45,172,18,45,172,19,45,172,20,45,172,21,45,172,22,45,172,23,45,172,24,45,172,25,45,172,26,45,172,27,45,172,28,45,172,29,45,172,30,45,172,31,45,172,32,45,172,33,45,172,34,45,172,35,45,172,36,45,172,37,45,172,38,45,172,39,45,172,40,45,172,41,45,172,42,45,172,43,45,172,44,45,172
    db 45,45,172,46,45,172,47,45,172,48,45,172,49,45,172,50,45,172,51,45,172,52,45,172,53,45,172,54,45,172,55,45,172,56,45,172,57,45,172,58,45,172,59,45,172,60,45,172,61,45,172,62,45,172,63,45,172,64,45,172,65,45,172,66,45,172,67,45,172,68,45,172,69,45,172,70,45,172,71,45,172,72,45,172,73,45,172,74,45,172
    db 75,45,172,76,45,172,77,45,172,78,45,172,79,45,172,80,45,172,81,45,172,82,45,172,83,45,172,84,45,172,85,45,172,86,45,172,87,45,172,88,45,172,89,45,172,90,45,172,91,45,172,92,45,172,93,45,245,94,45,150,95,45,24,96,45,79,101,45,102,102,45,102,103,45,102,104,45,102,105,45,102,106,45,102,107,45,102,108,45,102
    db 109,45,101,123,45,24,124,45,24,125,45,79,126,45,78,127,45,103,128,45,102,129,45,102,130,45,102,131,45,103,132,45,78,133,45,103,134,45,101,140,45,102,141,45,102,142,45,102,143,45,102,144,45,102,145,45,102,146,45,102,147,45,102,148,45,102,149,45,102,150,45,102,151,45,78,152,45,79,153,45,24,159,45,12,160,45,41,161,45,4
    db 162,45,203,163,45,4,164,45,40,165,45,40,166,45,40,167,45,40,168,45,40,169,45,40,170,45,40,171,45,40,172,45,40,173,45,40,174,45,40,175,45,40,176,45,40,177,45,40,178,45,40,179,45,40,180,45,40,181,45,40,182,45,40,183,45,40,184,45,40,185,45,40,186,45,40,187,45,40,188,45,40,189,45,40,190,45,40,191,45,40
    db 192,45,40,193,45,40,194,45,40,195,45,40,196,45,40,197,45,40,198,45,40,199,45,40,200,45,40,201,45,40,202,45,40,203,45,40,204,45,40,205,45,40,206,45,40,207,45,40,208,45,40,209,45,40,210,45,40,211,45,40,212,45,40,213,45,40,214,45,40,215,45,40,216,45,40,217,45,40,218,45,40,219,45,40,220,45,40,221,45,40
    db 222,45,40,223,45,40,224,45,40,225,45,40,226,45,40,227,45,40,228,45,40,229,45,40,230,45,40,231,45,40,232,45,40,233,45,40,234,45,40,235,45,40,236,45,40,237,45,40,238,45,40,239,45,40,240,45,39,241,45,12,15,46,79,16,46,24,17,46,172,18,46,172,19,46,172,20,46,172,21,46,172,22,46,172,23,46,172,24,46,172
    db 25,46,172,26,46,172,27,46,172,28,46,172,29,46,172,30,46,172,31,46,172,32,46,172,33,46,172,34,46,172,35,46,172,36,46,172,37,46,172,38,46,172,39,46,172,40,46,172,41,46,172,42,46,172,43,46,172,44,46,172,45,46,172,46,46,172,47,46,172,48,46,172,49,46,172,50,46,172,51,46,172,52,46,172,53,46,172,54,46,172
    db 55,46,172,56,46,172,57,46,172,58,46,172,59,46,172,60,46,172,61,46,172,62,46,172,63,46,172,64,46,172,65,46,172,66,46,172,67,46,172,68,46,172,69,46,172,70,46,172,71,46,172,72,46,172,73,46,172,74,46,172,75,46,172,76,46,172,77,46,172,78,46,172,79,46,172,80,46,172,81,46,172,82,46,172,83,46,172,84,46,172
    db 85,46,172,86,46,172,87,46,172,88,46,172,89,46,172,90,46,172,91,46,172,92,46,150,93,46,221,94,46,172,95,46,79,100,46,102,101,46,102,102,46,102,103,46,102,104,46,102,105,46,102,106,46,102,107,46,102,108,46,102,109,46,102,122,46,24,123,46,25,124,46,78,125,46,102,126,46,102,127,46,102,128,46,102,129,46,102,130,46,102
    db 131,46,102,132,46,102,133,46,102,134,46,102,135,46,30,140,46,102,141,46,102,142,46,102,143,46,102,144,46,102,145,46,102,146,46,102,147,46,102,148,46,102,149,46,102,150,46,102,151,46,102,152,46,103,153,46,79,154,46,24,160,46,12,161,46,39,162,46,136,163,46,205,164,46,40,165,46,40,166,46,40,167,46,40,168,46,40,169,46,40
    db 170,46,40,171,46,40,172,46,40,173,46,40,174,46,40,175,46,40,176,46,40,177,46,40,178,46,40,179,46,40,180,46,40,181,46,40,182,46,40,183,46,40,184,46,40,185,46,40,186,46,40,187,46,40,188,46,40,189,46,40,190,46,40,191,46,40,192,46,40,193,46,40,194,46,40,195,46,40,196,46,40,197,46,40,198,46,40,199,46,40
    db 200,46,40,201,46,40,202,46,40,203,46,40,204,46,40,205,46,40,206,46,40,207,46,40,208,46,40,209,46,40,210,46,40,211,46,40,212,46,40,213,46,40,214,46,40,215,46,40,216,46,40,217,46,40,218,46,40,219,46,40,220,46,40,221,46,40,222,46,40,223,46,40,224,46,40,225,46,40,226,46,40,227,46,40,228,46,40,229,46,40
    db 230,46,40,231,46,40,232,46,40,233,46,40,234,46,40,235,46,40,236,46,40,237,46,40,238,46,40,239,46,40,240,46,12,15,47,103,16,47,79,17,47,172,18,47,172,19,47,172,20,47,172,21,47,172,22,47,172,23,47,172,24,47,172,25,47,172,26,47,172,27,47,172,28,47,172,29,47,172,30,47,172,31,47,172,32,47,172,33,47,172
    db 34,47,172,35,47,172,36,47,172,37,47,172,38,47,172,39,47,172,40,47,172,41,47,172,42,47,172,43,47,172,44,47,172,45,47,172,46,47,172,47,47,172,48,47,172,49,47,172,50,47,172,51,47,172,52,47,172,53,47,172,54,47,172,55,47,172,56,47,172,57,47,172,58,47,172,59,47,172,60,47,172,61,47,172,62,47,172,63,47,172
    db 64,47,172,65,47,172,66,47,172,67,47,172,68,47,172,69,47,172,70,47,172,71,47,172,72,47,172,73,47,172,74,47,172,75,47,172,76,47,172,77,47,172,78,47,172,79,47,172,80,47,172,81,47,172,82,47,172,83,47,172,84,47,172,85,47,172,86,47,172,87,47,172,88,47,172,89,47,172,90,47,172,91,47,148,92,47,222,93,47,149
    db 94,47,79,95,47,78,98,47,29,99,47,102,100,47,102,101,47,102,102,47,102,103,47,102,104,47,102,105,47,102,106,47,102,107,47,102,108,47,102,109,47,102,110,47,101,121,47,24,122,47,25,123,47,78,124,47,102,125,47,102,126,47,102,127,47,102,128,47,102,129,47,102,130,47,102,131,47,102,132,47,102,133,47,102,134,47,102,135,47,102
    db 140,47,102,141,47,102,142,47,102,143,47,102,144,47,102,145,47,102,146,47,102,147,47,102,148,47,102,149,47,102,150,47,102,151,47,102,152,47,102,153,47,78,154,47,24,161,47,12,162,47,39,163,47,205,164,47,136,165,47,40,166,47,40,167,47,40,168,47,40,169,47,40,170,47,40,171,47,40,172,47,40,173,47,40,174,47,40,175,47,40
    db 176,47,40,177,47,40,178,47,40,179,47,40,180,47,40,181,47,40,182,47,40,183,47,40,184,47,40,185,47,40,186,47,40,187,47,40,188,47,40,189,47,40,190,47,40,191,47,40,192,47,40,193,47,40,194,47,40,195,47,40,196,47,40,197,47,40,198,47,40,199,47,40,200,47,40,201,47,40,202,47,40,203,47,40,204,47,40,205,47,40
    db 206,47,40,207,47,40,208,47,40,209,47,40,210,47,40,211,47,40,212,47,40,213,47,40,214,47,40,215,47,40,216,47,40,217,47,40,218,47,40,219,47,40,220,47,40,221,47,40,222,47,40,223,47,40,224,47,40,225,47,40,226,47,40,227,47,40,228,47,40,229,47,40,230,47,40,231,47,40,232,47,40,233,47,40,234,47,40,235,47,40
    db 236,47,40,237,47,40,238,47,40,239,47,40,240,47,12,16,48,79,17,48,24,18,48,172,19,48,172,20,48,172,21,48,172,22,48,172,23,48,172,24,48,172,25,48,172,26,48,172,27,48,172,28,48,172,29,48,172,30,48,172,31,48,172,32,48,172,33,48,172,34,48,172,35,48,172,36,48,172,37,48,172,38,48,172,39,48,172,40,48,172
    db 41,48,172,42,48,172,43,48,172,44,48,172,45,48,172,46,48,172,47,48,172,48,48,172,49,48,172,50,48,172,51,48,172,52,48,172,53,48,172,54,48,172,55,48,172,56,48,172,57,48,172,58,48,172,59,48,172,60,48,172,61,48,172,62,48,172,63,48,172,64,48,172,65,48,172,66,48,172,67,48,172,68,48,172,69,48,172,70,48,172
    db 71,48,172,72,48,172,73,48,172,74,48,172,75,48,172,76,48,172,77,48,172,78,48,172,79,48,172,80,48,172,81,48,172,82,48,172,83,48,172,84,48,172,85,48,172,86,48,172,87,48,172,88,48,172,89,48,172,90,48,172,91,48,221,92,48,150,93,48,24,94,48,79,98,48,25,99,48,103,100,48,102,101,48,102,102,48,102,103,48,102
    db 104,48,102,105,48,102,106,48,102,107,48,102,108,48,102,109,48,102,110,48,102,121,48,24,122,48,78,123,48,102,124,48,102,125,48,102,126,48,102,127,48,102,128,48,102,129,48,102,130,48,102,131,48,102,132,48,102,133,48,102,134,48,102,135,48,102,140,48,102,141,48,102,142,48,102,143,48,102,144,48,102,145,48,102,146,48,102,147,48,102
    db 148,48,102,149,48,102,150,48,102,151,48,102,152,48,102,153,48,102,154,48,79,155,48,24,161,48,64,162,48,39,163,48,4,164,48,203,165,48,4,166,48,40,167,48,40,168,48,40,169,48,40,170,48,40,171,48,40,172,48,40,173,48,40,174,48,40,175,48,40,176,48,40,177,48,40,178,48,40,179,48,40,180,48,40,181,48,40,182,48,40
    db 183,48,40,184,48,40,185,48,40,186,48,40,187,48,40,188,48,40,189,48,40,190,48,40,191,48,40,192,48,40,193,48,40,194,48,40,195,48,40,196,48,40,197,48,40,198,48,40,199,48,40,200,48,40,201,48,40,202,48,40,203,48,40,204,48,40,205,48,40,206,48,40,207,48,40,208,48,40,209,48,40,210,48,40,211,48,40,212,48,40
    db 213,48,40,214,48,40,215,48,40,216,48,40,217,48,40,218,48,40,219,48,40,220,48,40,221,48,40,222,48,40,223,48,40,224,48,40,225,48,40,226,48,40,227,48,40,228,48,40,229,48,40,230,48,40,231,48,40,232,48,40,233,48,40,234,48,40,235,48,40,236,48,40,237,48,40,238,48,40,239,48,39,240,48,29,16,49,78,17,49,24
    db 18,49,172,19,49,172,20,49,172,21,49,172,22,49,172,23,49,172,24,49,172,25,49,172,26,49,172,27,49,172,28,49,172,29,49,172,30,49,172,31,49,172,32,49,172,33,49,172,34,49,172,35,49,172,36,49,172,37,49,172,38,49,172,39,49,172,40,49,172,41,49,172,42,49,172,43,49,172,44,49,172,45,49,172,46,49,172,47,49,172
    db 48,49,172,49,49,172,50,49,172,51,49,172,52,49,172,53,49,172,54,49,172,55,49,172,56,49,172,57,49,172,58,49,172,59,49,172,60,49,172,61,49,172,62,49,172,63,49,172,64,49,172,65,49,172,66,49,172,67,49,172,68,49,172,69,49,172,70,49,172,71,49,172,72,49,172,73,49,172,74,49,172,75,49,172,76,49,172,77,49,172
    db 78,49,172,79,49,172,80,49,172,81,49,172,82,49,172,83,49,172,84,49,172,85,49,172,86,49,172,87,49,172,88,49,172,89,49,172,90,49,150,91,49,221,92,49,172,93,49,79,97,49,24,98,49,79,99,49,102,100,49,102,101,49,102,102,49,102,103,49,102,104,49,102,105,49,102,106,49,102,107,49,102,108,49,102,109,49,102,110,49,102
    db 120,49,24,121,49,24,122,49,78,123,49,102,124,49,102,125,49,102,126,49,102,127,49,102,128,49,102,129,49,102,130,49,102,131,49,102,132,49,102,133,49,102,134,49,102,135,49,102,140,49,102,141,49,102,142,49,15,146,49,102,147,49,102,148,49,102,149,49,102,150,49,102,151,49,102,152,49,102,153,49,102,154,49,78,155,49,24,162,49,12
    db 163,49,39,164,49,136,165,49,205,166,49,40,167,49,40,168,49,40,169,49,40,170,49,40,171,49,40,172,49,40,173,49,40,174,49,40,175,49,40,176,49,40,177,49,40,178,49,40,179,49,40,180,49,40,181,49,40,182,49,40,183,49,40,184,49,40,185,49,40,186,49,40,187,49,40,188,49,40,189,49,40,190,49,40,191,49,40,192,49,40
    db 193,49,40,194,49,40,195,49,40,196,49,40,197,49,40,198,49,40,199,49,40,200,49,40,201,49,40,202,49,40,203,49,40,204,49,40,205,49,40,206,49,40,207,49,40,208,49,40,209,49,40,210,49,40,211,49,40,212,49,40,213,49,40,214,49,40,215,49,40,216,49,40,217,49,40,218,49,40,219,49,40,220,49,40,221,49,40,222,49,40
    db 223,49,40,224,49,40,225,49,40,226,49,40,227,49,40,228,49,40,229,49,40,230,49,40,231,49,40,232,49,40,233,49,40,234,49,40,235,49,40,236,49,40,237,49,40,238,49,40,239,49,12,17,50,24,18,50,150,19,50,221,20,50,221,21,50,151,22,50,172,23,50,172,24,50,172,25,50,172,26,50,172,27,50,172,28,50,172,29,50,172
    db 30,50,172,31,50,172,32,50,172,33,50,172,34,50,172,35,50,172,36,50,172,37,50,172,38,50,172,39,50,172,40,50,172,41,50,172,42,50,172,43,50,172,44,50,172,45,50,172,46,50,172,47,50,172,48,50,172,49,50,172,50,50,172,51,50,172,52,50,172,53,50,172,54,50,172,55,50,172,56,50,172,57,50,172,58,50,172,59,50,172
    db 60,50,172,61,50,172,62,50,172,63,50,172,64,50,172,65,50,172,66,50,172,67,50,172,68,50,172,69,50,172,70,50,172,71,50,172,72,50,172,73,50,172,74,50,172,75,50,172,76,50,172,77,50,172,78,50,172,79,50,172,80,50,172,81,50,172,82,50,172,83,50,172,84,50,172,85,50,172,86,50,172,87,50,172,88,50,172,89,50,172
    db 90,50,222,91,50,173,92,50,79,93,50,78,97,50,24,98,50,78,99,50,102,100,50,102,101,50,102,102,50,102,103,50,102,104,50,102,105,50,102,106,50,30,107,50,15,108,50,102,109,50,102,110,50,30,120,50,24,121,50,79,122,50,102,123,50,102,124,50,102,125,50,102,126,50,102,127,50,102,128,50,102,129,50,102,130,50,15,133,50,101
    db 134,50,102,135,50,101,146,50,30,147,50,102,148,50,102,149,50,102,150,50,102,151,50,102,152,50,102,153,50,102,154,50,78,155,50,24,163,50,12,164,50,39,165,50,205,166,50,136,167,50,40,168,50,40,169,50,40,170,50,40,171,50,40,172,50,40,173,50,40,174,50,40,175,50,40,176,50,40,177,50,40,178,50,40,179,50,40,180,50,40
    db 181,50,40,182,50,40,183,50,40,184,50,40,185,50,40,186,50,40,187,50,40,188,50,40,189,50,40,190,50,40,191,50,40,192,50,40,193,50,40,194,50,40,195,50,40,196,50,40,197,50,40,198,50,40,199,50,40,200,50,40,201,50,40,202,50,40,203,50,40,204,50,40,205,50,40,206,50,40,207,50,40,208,50,40,209,50,40,210,50,40
    db 211,50,40,212,50,40,213,50,40,214,50,40,215,50,40,216,50,40,217,50,40,218,50,40,219,50,40,220,50,40,221,50,40,222,50,40,223,50,40,224,50,40,225,50,40,226,50,40,227,50,40,228,50,40,229,50,40,230,50,40,231,50,40,232,50,40,233,50,40,234,50,136,235,50,205,236,50,205,237,50,205,238,50,136,239,50,12,17,51,25
    db 18,51,172,19,51,173,20,51,148,21,51,172,22,51,172,23,51,172,24,51,172,25,51,172,26,51,172,27,51,172,28,51,172,29,51,172,30,51,172,31,51,172,32,51,172,33,51,172,34,51,172,35,51,172,36,51,172,37,51,172,38,51,172,39,51,172,40,51,172,41,51,172,42,51,172,43,51,172,44,51,172,45,51,172,46,51,172,47,51,172
    db 48,51,172,49,51,172,50,51,172,51,51,172,52,51,172,53,51,172,54,51,172,55,51,172,56,51,172,57,51,172,58,51,172,59,51,172,60,51,172,61,51,172,62,51,172,63,51,172,64,51,172,65,51,172,66,51,172,67,51,172,68,51,172,69,51,172,70,51,172,71,51,172,72,51,172,73,51,172,74,51,172,75,51,172,76,51,172,77,51,172
    db 78,51,172,79,51,172,80,51,172,81,51,172,82,51,172,83,51,172,84,51,172,85,51,172,86,51,172,87,51,172,88,51,172,89,51,221,90,51,150,91,51,24,92,51,78,96,51,24,97,51,25,98,51,103,99,51,102,100,51,102,101,51,102,102,51,102,103,51,102,104,51,102,120,51,24,121,51,78,122,51,102,123,51,102,124,51,102,125,51,102
    db 126,51,102,127,51,102,128,51,102,129,51,15,147,51,102,148,51,102,149,51,102,150,51,102,151,51,102,152,51,102,153,51,102,154,51,103,155,51,25,156,51,24,163,51,30,164,51,41,165,51,4,166,51,202,167,51,4,168,51,40,169,51,40,170,51,40,171,51,40,172,51,40,173,51,40,174,51,40,175,51,40,176,51,40,177,51,40,178,51,40
    db 179,51,40,180,51,40,181,51,40,182,51,40,183,51,40,184,51,40,185,51,40,186,51,40,187,51,40,188,51,40,189,51,40,190,51,40,191,51,40,192,51,40,193,51,40,194,51,40,195,51,40,196,51,40,197,51,40,198,51,40,199,51,40,200,51,40,201,51,40,202,51,40,203,51,40,204,51,40,205,51,40,206,51,40,207,51,40,208,51,40
    db 209,51,40,210,51,40,211,51,40,212,51,40,213,51,40,214,51,40,215,51,40,216,51,40,217,51,40,218,51,40,219,51,40,220,51,40,221,51,40,222,51,40,223,51,40,224,51,40,225,51,40,226,51,40,227,51,40,228,51,40,229,51,40,230,51,40,231,51,40,232,51,40,233,51,40,234,51,40,235,51,4,236,51,4,237,51,4,238,51,12
    db 10,52,102,11,52,102,12,52,102,13,52,102,14,52,102,15,52,102,16,52,102,17,52,102,18,52,79,19,52,172,20,52,172,21,52,172,22,52,172,23,52,148,24,52,149,25,52,149,26,52,173,27,52,172,28,52,172,29,52,172,30,52,172,31,52,172,32,52,172,33,52,172,34,52,172,35,52,172,36,52,172,37,52,172,38,52,172,39,52,172
    db 40,52,172,41,52,172,42,52,172,43,52,172,44,52,172,45,52,172,46,52,172,47,52,172,48,52,172,49,52,172,50,52,172,51,52,172,52,52,172,53,52,172,54,52,172,55,52,172,56,52,172,57,52,172,58,52,172,59,52,172,60,52,172,61,52,172,62,52,172,63,52,172,64,52,172,65,52,172,66,52,172,67,52,172,68,52,172,69,52,172
    db 70,52,172,71,52,172,72,52,172,73,52,172,74,52,172,75,52,172,76,52,172,77,52,172,78,52,172,79,52,172,80,52,172,81,52,172,82,52,172,83,52,172,84,52,172,85,52,172,86,52,172,87,52,172,88,52,150,89,52,221,90,52,172,91,52,79,96,52,24,97,52,78,98,52,102,99,52,102,100,52,102,101,52,102,102,52,102,103,52,102
    db 104,52,102,119,52,15,120,52,25,121,52,78,122,52,102,123,52,102,124,52,102,125,52,102,126,52,102,127,52,102,128,52,102,147,52,102,148,52,102,149,52,102,150,52,102,151,52,102,152,52,102,153,52,102,154,52,102,155,52,79,156,52,7,164,52,12,165,52,39,166,52,136,167,52,205,168,52,40,169,52,40,170,52,40,171,52,40,172,52,40
    db 173,52,40,174,52,40,175,52,40,176,52,40,177,52,40,178,52,40,179,52,40,180,52,40,181,52,40,182,52,40,183,52,40,184,52,40,185,52,40,186,52,40,187,52,40,188,52,40,189,52,40,190,52,40,191,52,40,192,52,40,193,52,40,194,52,40,195,52,40,196,52,40,197,52,40,198,52,40,199,52,40,200,52,40,201,52,40,202,52,40
    db 203,52,40,204,52,40,205,52,40,206,52,40,207,52,40,208,52,40,209,52,40,210,52,40,211,52,40,212,52,40,213,52,40,214,52,40,215,52,40,216,52,40,217,52,40,218,52,40,219,52,40,220,52,40,221,52,40,222,52,40,223,52,40,224,52,40,225,52,40,226,52,40,227,52,40,228,52,40,229,52,4,230,52,136,231,52,4,232,52,4
    db 233,52,4,234,52,4,235,52,40,236,52,40,237,52,40,238,52,12,10,53,102,11,53,102,12,53,102,13,53,102,14,53,102,15,53,102,16,53,102,17,53,102,18,53,78,19,53,149,20,53,222,21,53,222,22,53,222,23,53,221,24,53,221,25,53,221,26,53,151,27,53,172,28,53,172,29,53,172,30,53,172,31,53,172,32,53,172,33,53,172
    db 34,53,172,35,53,172,36,53,172,37,53,172,38,53,172,39,53,172,40,53,172,41,53,172,42,53,172,43,53,172,44,53,172,45,53,172,46,53,172,47,53,172,48,53,172,49,53,172,50,53,172,51,53,172,52,53,172,53,53,172,54,53,172,55,53,172,56,53,172,57,53,172,58,53,172,59,53,172,60,53,172,61,53,172,62,53,172,63,53,172
    db 64,53,172,65,53,172,66,53,172,67,53,172,68,53,172,69,53,172,70,53,172,71,53,172,72,53,172,73,53,172,74,53,172,75,53,172,76,53,172,77,53,172,78,53,172,79,53,172,80,53,172,81,53,172,82,53,172,83,53,172,84,53,172,85,53,172,86,53,172,87,53,148,88,53,222,89,53,173,90,53,79,91,53,30,94,53,27,95,53,24
    db 96,53,79,97,53,77,98,53,102,99,53,102,100,53,102,101,53,102,102,53,102,103,53,102,104,53,102,119,53,27,120,53,78,121,53,103,122,53,102,123,53,102,124,53,102,125,53,102,126,53,102,127,53,102,128,53,102,144,53,23,145,53,25,146,53,27,147,53,102,148,53,102,149,53,102,150,53,102,151,53,102,152,53,102,153,53,102,154,53,102
    db 155,53,102,156,53,102,165,53,12,166,53,39,167,53,205,168,53,136,169,53,40,170,53,40,171,53,40,172,53,40,173,53,40,174,53,40,175,53,40,176,53,40,177,53,40,178,53,40,179,53,40,180,53,40,181,53,40,182,53,40,183,53,40,184,53,40,185,53,40,186,53,40,187,53,40,188,53,40,189,53,40,190,53,40,191,53,40,192,53,40
    db 193,53,40,194,53,40,195,53,40,196,53,40,197,53,40,198,53,40,199,53,40,200,53,40,201,53,40,202,53,40,203,53,40,204,53,40,205,53,40,206,53,40,207,53,40,208,53,40,209,53,40,210,53,40,211,53,40,212,53,40,213,53,40,214,53,40,215,53,40,216,53,40,217,53,40,218,53,40,219,53,40,220,53,40,221,53,40,222,53,40
    db 223,53,40,224,53,40,225,53,40,226,53,40,227,53,40,228,53,40,229,53,136,230,53,205,231,53,205,232,53,205,233,53,205,234,53,205,235,53,203,236,53,136,237,53,12,238,53,102,239,53,102,240,53,102,241,53,102,242,53,102,243,53,102,244,53,101,245,53,101,10,54,102,11,54,102,12,54,102,13,54,102,14,54,102,15,54,102,16,54,102
    db 17,54,102,18,54,77,19,54,25,20,54,172,21,54,172,22,54,172,23,54,172,24,54,172,25,54,172,26,54,172,27,54,172,28,54,172,29,54,172,30,54,172,31,54,172,32,54,172,33,54,172,34,54,172,35,54,172,36,54,172,37,54,172,38,54,172,39,54,172,40,54,172,41,54,172,42,54,172,43,54,172,44,54,172,45,54,172,46,54,172
    db 47,54,172,48,54,172,49,54,172,50,54,172,51,54,172,52,54,172,53,54,172,54,54,172,55,54,172,56,54,172,57,54,172,58,54,172,59,54,172,60,54,172,61,54,172,62,54,172,63,54,172,64,54,172,65,54,172,66,54,172,67,54,172,68,54,172,69,54,172,70,54,172,71,54,172,72,54,172,73,54,172,74,54,172,75,54,172,76,54,172
    db 77,54,172,78,54,172,79,54,172,80,54,172,81,54,172,82,54,172,83,54,172,84,54,172,85,54,172,86,54,172,87,54,245,88,54,150,89,54,24,90,54,78,92,54,87,93,54,24,94,54,24,95,54,78,96,54,102,97,54,102,98,54,102,99,54,102,100,54,102,101,54,102,102,54,102,103,54,102,104,54,102,105,54,30,119,54,30,120,54,102
    db 121,54,102,122,54,102,123,54,102,124,54,102,125,54,102,126,54,102,127,54,102,128,54,102,129,54,78,130,54,24,131,54,23,132,54,7,141,54,24,142,54,24,143,54,24,144,54,25,145,54,79,146,54,103,147,54,102,148,54,102,149,54,102,150,54,102,151,54,102,152,54,102,153,54,102,154,54,102,155,54,102,156,54,102,157,54,102,158,54,30
    db 165,54,88,166,54,41,167,54,4,168,54,203,169,54,4,170,54,40,171,54,40,172,54,40,173,54,40,174,54,40,175,54,40,176,54,40,177,54,40,178,54,40,179,54,40,180,54,40,181,54,40,182,54,40,183,54,40,184,54,40,185,54,40,186,54,40,187,54,40,188,54,40,189,54,40,190,54,40,191,54,40,192,54,40,193,54,40,194,54,40
    db 195,54,40,196,54,40,197,54,40,198,54,40,199,54,40,200,54,40,201,54,40,202,54,40,203,54,40,204,54,40,205,54,40,206,54,40,207,54,40,208,54,40,209,54,40,210,54,40,211,54,40,212,54,40,213,54,40,214,54,40,215,54,40,216,54,40,217,54,40,218,54,40,219,54,40,220,54,40,221,54,40,222,54,40,223,54,40,224,54,40
    db 225,54,40,226,54,40,227,54,40,228,54,40,229,54,40,230,54,40,231,54,40,232,54,40,233,54,40,234,54,40,235,54,4,236,54,39,237,54,27,238,54,102,239,54,102,240,54,102,241,54,102,242,54,102,243,54,102,244,54,102,245,54,102,10,55,102,11,55,102,12,55,102,13,55,102,14,55,102,15,55,102,16,55,102,17,55,102,18,55,102
    db 19,55,78,20,55,172,21,55,172,22,55,172,23,55,172,24,55,172,25,55,148,26,55,148,27,55,149,28,55,149,29,55,149,30,55,149,31,55,172,32,55,172,33,55,172,34,55,172,35,55,172,36,55,172,37,55,172,38,55,172,39,55,172,40,55,172,41,55,172,42,55,172,43,55,172,44,55,172,45,55,172,46,55,172,47,55,172,48,55,172
    db 49,55,172,50,55,172,51,55,172,52,55,172,53,55,172,54,55,172,55,55,172,56,55,172,57,55,172,58,55,172,59,55,172,60,55,172,61,55,172,62,55,172,63,55,172,64,55,172,65,55,172,66,55,172,67,55,172,68,55,172,69,55,172,70,55,172,71,55,172,72,55,172,73,55,172,74,55,172,75,55,172,76,55,172,77,55,172,78,55,172
    db 79,55,172,80,55,172,81,55,172,82,55,172,83,55,172,84,55,172,85,55,172,86,55,149,87,55,245,88,55,172,89,55,79,90,55,23,91,55,24,92,55,24,93,55,79,94,55,78,95,55,102,96,55,102,97,55,102,98,55,102,99,55,102,100,55,102,101,55,102,102,55,102,103,55,102,104,55,102,105,55,102,106,55,101,116,55,101,117,55,101
    db 118,55,102,119,55,102,120,55,102,121,55,102,122,55,102,123,55,102,124,55,102,125,55,102,126,55,102,127,55,102,128,55,102,129,55,103,130,55,78,131,55,79,132,55,25,133,55,24,134,55,24,139,55,24,140,55,24,141,55,25,142,55,79,143,55,78,144,55,103,145,55,102,146,55,102,147,55,102,148,55,102,149,55,102,150,55,102,151,55,102
    db 152,55,102,153,55,102,154,55,102,155,55,102,156,55,102,157,55,102,158,55,102,159,55,102,160,55,102,161,55,102,162,55,102,163,55,101,164,55,102,165,55,76,166,55,64,167,55,39,168,55,136,169,55,205,170,55,40,171,55,40,172,55,40,173,55,40,174,55,40,175,55,40,176,55,40,177,55,40,178,55,40,179,55,40,180,55,40,181,55,40
    db 182,55,40,183,55,40,184,55,40,185,55,40,186,55,40,187,55,40,188,55,40,189,55,40,190,55,40,191,55,40,192,55,40,193,55,40,194,55,40,195,55,40,196,55,40,197,55,40,198,55,40,199,55,40,200,55,40,201,55,40,202,55,40,203,55,40,204,55,40,205,55,40,206,55,40,207,55,40,208,55,40,209,55,40,210,55,40,211,55,40
    db 212,55,40,213,55,40,214,55,40,215,55,40,216,55,40,217,55,40,218,55,40,219,55,40,220,55,40,221,55,40,222,55,40,223,55,40,224,55,40,225,55,4,226,55,136,227,55,4,228,55,4,229,55,4,230,55,4,231,55,4,232,55,4,233,55,40,234,55,40,235,55,40,236,55,12,237,55,103,238,55,102,239,55,102,240,55,102,241,55,102
    db 242,55,102,243,55,102,244,55,102,245,55,102,10,56,102,11,56,102,12,56,102,13,56,102,14,56,102,15,56,102,16,56,102,17,56,102,18,56,102,19,56,77,20,56,172,21,56,222,22,56,222,23,56,222,24,56,222,25,56,223,26,56,223,27,56,222,28,56,222,29,56,222,30,56,245,31,56,172,32,56,172,33,56,172,34,56,172,35,56,172
    db 36,56,172,37,56,172,38,56,172,39,56,172,40,56,172,41,56,172,42,56,172,43,56,172,44,56,172,45,56,172,46,56,172,47,56,172,48,56,172,49,56,172,50,56,172,51,56,172,52,56,172,53,56,172,54,56,172,55,56,172,56,56,172,57,56,172,58,56,172,59,56,172,60,56,172,61,56,172,62,56,172,63,56,172,64,56,172,65,56,172
    db 66,56,172,67,56,172,68,56,172,69,56,172,70,56,172,71,56,172,72,56,172,73,56,172,74,56,172,75,56,172,76,56,172,77,56,172,78,56,172,79,56,172,80,56,172,81,56,172,82,56,172,83,56,172,84,56,172,85,56,172,86,56,148,87,56,172,88,56,24,89,56,24,90,56,79,91,56,78,92,56,78,93,56,102,94,56,102,95,56,102
    db 96,56,102,97,56,102,98,56,102,99,56,102,100,56,102,101,56,102,102,56,102,103,56,102,104,56,102,105,56,102,106,56,102,107,56,102,108,56,102,109,56,102,110,56,102,111,56,102,112,56,102,113,56,102,114,56,102,115,56,102,116,56,102,117,56,102,118,56,102,119,56,102,120,56,102,121,56,102,122,56,102,123,56,102,124,56,102,125,56,102
    db 126,56,102,127,56,102,128,56,102,129,56,102,130,56,102,131,56,102,132,56,103,133,56,78,134,56,25,135,56,24,136,56,24,137,56,24,138,56,24,139,56,24,140,56,78,141,56,103,142,56,102,143,56,102,144,56,102,145,56,102,146,56,102,147,56,102,148,56,102,149,56,102,150,56,102,151,56,102,152,56,102,153,56,102,154,56,102,155,56,102
    db 156,56,102,157,56,102,158,56,102,159,56,102,160,56,102,161,56,102,162,56,102,163,56,102,164,56,102,165,56,102,166,56,102,167,56,7,168,56,39,169,56,4,170,56,40,171,56,40,172,56,40,173,56,40,174,56,40,175,56,40,176,56,40,177,56,40,178,56,40,179,56,40,180,56,40,181,56,40,182,56,40,183,56,40,184,56,40,185,56,40
    db 186,56,40,187,56,40,188,56,40,189,56,40,190,56,40,191,56,40,192,56,40,193,56,40,194,56,40,195,56,40,196,56,40,197,56,40,198,56,40,199,56,40,200,56,40,201,56,40,202,56,40,203,56,40,204,56,40,205,56,40,206,56,40,207,56,40,208,56,40,209,56,40,210,56,40,211,56,40,212,56,40,213,56,40,214,56,40,215,56,40
    db 216,56,40,217,56,40,218,56,40,219,56,40,220,56,40,221,56,40,222,56,40,223,56,40,224,56,40,225,56,136,226,56,205,227,56,203,228,56,202,229,56,202,230,56,202,231,56,202,232,56,202,233,56,203,234,56,203,235,56,136,236,56,25,237,56,102,238,56,102,239,56,102,240,56,102,241,56,102,242,56,102,243,56,102,244,56,102,245,56,102
    db 10,57,102,11,57,102,12,57,102,13,57,102,14,57,102,15,57,102,16,57,102,17,57,102,18,57,102,19,57,102,20,57,79,21,57,172,22,57,172,23,57,172,24,57,172,25,57,172,26,57,172,27,57,172,28,57,172,29,57,172,30,57,172,31,57,24,32,57,24,33,57,24,34,57,24,35,57,24,36,57,24,37,57,24,38,57,24,39,57,24
    db 40,57,79,41,57,24,42,57,172,43,57,172,44,57,172,45,57,172,46,57,172,47,57,172,48,57,172,49,57,24,50,57,79,51,57,24,52,57,24,53,57,24,54,57,24,55,57,24,56,57,24,57,57,24,58,57,24,59,57,24,60,57,24,61,57,24,62,57,24,63,57,24,64,57,24,65,57,24,66,57,24,67,57,24,68,57,24,69,57,24
    db 70,57,24,71,57,24,72,57,24,73,57,24,74,57,24,75,57,24,76,57,24,77,57,24,78,57,24,79,57,24,80,57,24,81,57,24,82,57,24,83,57,24,84,57,24,85,57,24,86,57,24,87,57,79,88,57,78,89,57,77,90,57,102,91,57,102,92,57,102,93,57,102,94,57,102,95,57,102,96,57,102,97,57,102,98,57,102,99,57,102
    db 100,57,102,101,57,102,102,57,102,103,57,102,104,57,102,105,57,102,106,57,102,107,57,102,108,57,102,109,57,102,110,57,102,111,57,102,112,57,102,113,57,102,114,57,102,115,57,102,116,57,102,117,57,102,118,57,102,119,57,102,120,57,102,121,57,102,122,57,102,123,57,102,124,57,102,125,57,102,126,57,102,127,57,102,128,57,102,129,57,102
    db 130,57,102,131,57,102,132,57,102,133,57,102,134,57,77,135,57,78,136,57,79,137,57,25,138,57,78,139,57,78,140,57,102,141,57,102,142,57,102,143,57,102,144,57,102,145,57,102,146,57,102,147,57,102,148,57,102,149,57,102,150,57,102,151,57,102,152,57,102,153,57,102,154,57,102,155,57,102,156,57,102,157,57,102,158,57,102,159,57,102
    db 160,57,102,161,57,102,162,57,102,163,57,102,164,57,102,165,57,102,166,57,102,167,57,102,168,57,64,169,57,39,170,57,39,171,57,39,172,57,39,173,57,39,174,57,39,175,57,39,176,57,39,177,57,39,178,57,39,179,57,39,180,57,39,181,57,39,182,57,39,183,57,39,184,57,39,185,57,39,186,57,39,187,57,39,188,57,39,189,57,39
    db 190,57,39,191,57,39,192,57,39,193,57,39,194,57,39,195,57,39,196,57,39,197,57,39,198,57,39,199,57,39,200,57,39,201,57,39,202,57,39,203,57,39,204,57,39,205,57,39,206,57,39,207,57,39,208,57,39,209,57,39,210,57,39,211,57,39,212,57,39,213,57,39,214,57,39,215,57,39,216,57,39,217,57,39,218,57,39,219,57,39
    db 220,57,39,221,57,39,222,57,39,223,57,39,224,57,39,225,57,39,226,57,39,227,57,39,228,57,39,229,57,39,230,57,39,231,57,136,232,57,136,233,57,136,234,57,136,235,57,160,236,57,28,237,57,102,238,57,102,239,57,102,240,57,102,241,57,102,242,57,102,243,57,102,244,57,102,245,57,102,10,58,102,11,58,77,12,58,77,13,58,77
    db 14,58,78,15,58,78,16,58,77,17,58,77,18,58,77,19,58,102,20,58,77,21,58,78,22,58,78,23,58,78,24,58,78,25,58,78,26,58,78,27,58,78,28,58,78,29,58,78,30,58,78,31,58,78,32,58,78,33,58,78,34,58,78,35,58,78,36,58,78,37,58,78,38,58,78,39,58,78,40,58,79,41,58,25,42,58,24,43,58,79
    db 44,58,79,45,58,79,46,58,79,47,58,79,48,58,24,49,58,25,50,58,79,51,58,78,52,58,78,53,58,78,54,58,78,55,58,78,56,58,78,57,58,78,58,58,78,59,58,78,60,58,78,61,58,78,62,58,78,63,58,78,64,58,78,65,58,78,66,58,78,67,58,78,68,58,78,69,58,78,70,58,78,71,58,78,72,58,78,73,58,78
    db 74,58,78,75,58,78,76,58,78,77,58,78,78,58,78,79,58,78,80,58,78,81,58,78,82,58,78,83,58,78,84,58,78,85,58,78,86,58,78,87,58,77,88,58,102,89,58,102,90,58,102,91,58,102,92,58,102,93,58,102,94,58,102,95,58,102,96,58,102,97,58,102,98,58,102,99,58,102,100,58,102,101,58,102,102,58,102,103,58,102
    db 104,58,102,105,58,102,106,58,102,107,58,102,108,58,102,109,58,102,110,58,102,111,58,102,112,58,102,113,58,102,114,58,102,115,58,102,116,58,102,117,58,102,118,58,102,119,58,102,120,58,102,121,58,102,122,58,102,123,58,102,124,58,102,125,58,77,126,58,77,127,58,77,128,58,77,129,58,102,130,58,102,131,58,102,132,58,102,133,58,102
    db 134,58,102,135,58,102,136,58,103,137,58,103,138,58,102,139,58,102,140,58,102,141,58,102,142,58,102,143,58,102,144,58,102,145,58,77,146,58,78,147,58,78,148,58,78,149,58,78,150,58,78,151,58,77,152,58,77,153,58,102,154,58,102,155,58,102,156,58,102,157,58,102,158,58,102,159,58,102,160,58,102,161,58,102,162,58,102,163,58,102
    db 164,58,102,165,58,102,166,58,102,167,58,102,168,58,103,169,58,27,170,58,27,171,58,27,172,58,27,173,58,27,174,58,27,175,58,27,176,58,27,177,58,7,178,58,7,179,58,25,180,58,25,181,58,25,182,58,25,183,58,25,184,58,25,185,58,7,186,58,7,187,58,27,188,58,27,189,58,27,190,58,27,191,58,27,192,58,27,193,58,27
    db 194,58,27,195,58,27,196,58,27,197,58,27,198,58,27,199,58,27,200,58,27,201,58,27,202,58,27,203,58,27,204,58,27,205,58,27,206,58,27,207,58,27,208,58,7,209,58,7,210,58,7,211,58,7,212,58,7,213,58,27,214,58,27,215,58,27,216,58,27,217,58,27,218,58,27,219,58,27,220,58,27,221,58,27,222,58,27,223,58,27
    db 224,58,27,225,58,27,226,58,27,227,58,27,228,58,27,229,58,27,230,58,27,231,58,27,232,58,27,233,58,27,234,58,27,235,58,27,236,58,102,237,58,102,238,58,102,239,58,102,240,58,102,241,58,102,242,58,102,243,58,102,244,58,102,245,58,102,10,59,78,11,59,78,12,59,78,13,59,78,14,59,78,15,59,78,16,59,78,17,59,78
    db 18,59,78,19,59,78,20,59,77,21,59,102,22,59,102,23,59,102,24,59,102,25,59,102,26,59,102,27,59,102,28,59,102,29,59,102,30,59,102,31,59,102,32,59,102,33,59,102,34,59,102,35,59,102,36,59,102,37,59,78,38,59,79,39,59,79,40,59,79,41,59,78,42,59,78,43,59,78,44,59,78,45,59,78,46,59,78,47,59,78
    db 48,59,78,49,59,78,50,59,79,51,59,79,52,59,79,53,59,78,54,59,102,55,59,102,56,59,102,57,59,102,58,59,102,59,59,102,60,59,102,61,59,102,62,59,102,63,59,102,64,59,102,65,59,102,66,59,102,67,59,102,68,59,102,69,59,102,70,59,102,71,59,102,72,59,102,73,59,102,74,59,102,75,59,102,76,59,102,77,59,102
    db 78,59,102,79,59,102,80,59,102,81,59,102,82,59,102,83,59,102,84,59,102,85,59,102,86,59,102,87,59,102,88,59,102,89,59,102,90,59,102,91,59,102,92,59,102,93,59,102,94,59,102,95,59,102,96,59,102,97,59,102,98,59,102,99,59,102,100,59,102,101,59,102,102,59,102,103,59,102,104,59,102,105,59,102,106,59,102,107,59,102
    db 108,59,102,109,59,102,110,59,102,111,59,102,112,59,102,113,59,102,114,59,102,115,59,102,116,59,102,117,59,102,118,59,102,119,59,102,120,59,102,121,59,102,122,59,102,123,59,77,124,59,78,125,59,78,126,59,78,127,59,78,128,59,78,129,59,78,130,59,78,131,59,77,132,59,102,133,59,102,134,59,102,135,59,102,136,59,102,137,59,102
    db 138,59,102,139,59,102,140,59,102,141,59,102,142,59,102,143,59,77,144,59,78,145,59,78,146,59,78,147,59,78,148,59,78,149,59,78,150,59,78,151,59,78,152,59,78,153,59,78,154,59,77,155,59,102,156,59,102,157,59,102,158,59,102,159,59,102,160,59,102,161,59,102,162,59,102,163,59,102,164,59,102,165,59,102,166,59,102,167,59,102
    db 168,59,102,169,59,102,170,59,102,171,59,102,172,59,102,173,59,102,174,59,102,175,59,77,176,59,77,177,59,78,178,59,78,179,59,78,180,59,78,181,59,78,182,59,78,183,59,78,184,59,78,185,59,78,186,59,78,187,59,78,188,59,77,189,59,102,190,59,102,191,59,102,192,59,102,193,59,102,194,59,102,195,59,102,196,59,102,197,59,102
    db 198,59,102,199,59,102,200,59,102,201,59,102,202,59,102,203,59,102,204,59,77,205,59,78,206,59,79,207,59,79,208,59,79,209,59,79,210,59,79,211,59,79,212,59,79,213,59,79,214,59,79,215,59,78,216,59,77,217,59,102,218,59,102,219,59,102,220,59,102,221,59,102,222,59,102,223,59,102,224,59,102,225,59,102,226,59,102,227,59,102
    db 228,59,102,229,59,102,230,59,102,231,59,102,232,59,102,233,59,102,234,59,102,235,59,102,236,59,102,237,59,102,238,59,77,239,59,77,240,59,77,241,59,77,242,59,77,243,59,77,244,59,77,245,59,102,10,60,78,11,60,78,12,60,78,13,60,78,14,60,78,15,60,78,16,60,78,17,60,78,18,60,78,19,60,78,20,60,78,21,60,78
    db 22,60,77,23,60,102,24,60,102,25,60,102,26,60,102,27,60,102,28,60,102,29,60,102,30,60,102,31,60,102,32,60,102,33,60,102,34,60,102,35,60,78,36,60,79,37,60,79,38,60,79,39,60,78,40,60,78,41,60,78,42,60,78,43,60,78,44,60,78,45,60,78,46,60,78,47,60,78,48,60,78,49,60,78,50,60,78,51,60,78
    db 52,60,79,53,60,79,54,60,78,55,60,77,56,60,102,57,60,102,58,60,102,59,60,102,60,60,102,61,60,102,62,60,102,63,60,102,64,60,102,65,60,77,66,60,77,67,60,77,68,60,77,69,60,77,70,60,77,71,60,102,72,60,102,73,60,102,74,60,102,75,60,102,76,60,102,77,60,102,78,60,102,79,60,102,80,60,102,81,60,102
    db 82,60,102,83,60,102,84,60,102,85,60,102,86,60,102,87,60,102,88,60,102,89,60,102,90,60,102,91,60,102,92,60,102,93,60,103,94,60,78,95,60,78,96,60,79,97,60,79,98,60,79,99,60,79,100,60,79,101,60,79,102,60,78,103,60,78,104,60,103,105,60,102,106,60,102,107,60,102,108,60,102,109,60,102,110,60,102,111,60,102
    db 112,60,102,113,60,102,114,60,102,115,60,102,116,60,102,117,60,102,118,60,102,119,60,102,120,60,102,121,60,77,122,60,78,123,60,78,124,60,78,125,60,78,126,60,78,127,60,78,128,60,78,129,60,78,130,60,78,131,60,78,132,60,78,133,60,77,134,60,102,135,60,102,136,60,102,137,60,102,138,60,102,139,60,102,140,60,102,141,60,77
    db 142,60,78,143,60,78,144,60,78,145,60,78,146,60,78,147,60,78,148,60,78,149,60,78,150,60,78,151,60,78,152,60,78,153,60,78,154,60,78,155,60,77,156,60,102,157,60,102,158,60,102,159,60,102,160,60,102,161,60,102,162,60,102,163,60,102,164,60,102,165,60,102,166,60,102,167,60,102,168,60,102,169,60,102,170,60,102,171,60,102
    db 172,60,102,173,60,102,174,60,77,175,60,78,176,60,78,177,60,78,178,60,78,179,60,78,180,60,78,181,60,78,182,60,78,183,60,78,184,60,78,185,60,78,186,60,78,187,60,78,188,60,78,189,60,77,190,60,102,191,60,102,192,60,102,193,60,102,194,60,102,195,60,102,196,60,102,197,60,102,198,60,102,199,60,102,200,60,102,201,60,102
    db 202,60,103,203,60,78,204,60,79,205,60,79,206,60,79,207,60,78,208,60,78,209,60,78,210,60,78,211,60,78,212,60,78,213,60,78,214,60,79,215,60,79,216,60,79,217,60,78,218,60,78,219,60,102,220,60,102,221,60,102,222,60,102,223,60,102,224,60,102,225,60,102,226,60,102,227,60,102,228,60,102,229,60,102,230,60,102,231,60,102
    db 232,60,102,233,60,102,234,60,102,235,60,77,236,60,77,237,60,78,238,60,78,239,60,78,240,60,78,241,60,78,242,60,78,243,60,78,244,60,78,245,60,77,10,61,78,11,61,78,12,61,78,13,61,78,14,61,78,15,61,78,16,61,78,17,61,78,18,61,78,19,61,78,20,61,78,21,61,78,22,61,78,23,61,78,24,61,77,25,61,102
    db 26,61,102,27,61,102,28,61,102,29,61,102,30,61,102,31,61,102,32,61,102,33,61,102,34,61,78,35,61,79,36,61,78,37,61,78,38,61,78,39,61,78,40,61,78,41,61,78,42,61,78,43,61,78,44,61,78,45,61,78,46,61,78,47,61,78,48,61,78,49,61,78,50,61,78,51,61,78,52,61,78,53,61,78,54,61,79,55,61,78
    db 56,61,77,57,61,102,58,61,102,59,61,102,60,61,102,61,61,102,62,61,102,63,61,77,64,61,78,65,61,78,66,61,78,67,61,78,68,61,78,69,61,78,70,61,78,71,61,78,72,61,77,73,61,77,74,61,102,75,61,102,76,61,102,77,61,102,78,61,102,79,61,102,80,61,102,81,61,102,82,61,102,83,61,102,84,61,102,85,61,102
    db 86,61,102,87,61,102,88,61,102,89,61,102,90,61,102,91,61,78,92,61,79,93,61,79,94,61,79,95,61,78,96,61,78,97,61,78,98,61,78,99,61,78,100,61,78,101,61,78,102,61,79,103,61,79,104,61,79,105,61,78,106,61,103,107,61,102,108,61,102,109,61,102,110,61,102,111,61,102,112,61,102,113,61,102,114,61,102,115,61,102
    db 116,61,102,117,61,102,118,61,102,119,61,77,120,61,78,121,61,78,122,61,78,123,61,78,124,61,78,125,61,78,126,61,78,127,61,78,128,61,78,129,61,78,130,61,78,131,61,78,132,61,78,133,61,78,134,61,77,135,61,102,136,61,102,137,61,102,138,61,102,139,61,102,140,61,77,141,61,78,142,61,78,143,61,78,144,61,78,145,61,78
    db 146,61,78,147,61,78,148,61,78,149,61,78,150,61,78,151,61,78,152,61,78,153,61,78,154,61,78,155,61,78,156,61,78,157,61,77,158,61,102,159,61,102,160,61,102,161,61,102,162,61,102,163,61,102,164,61,102,165,61,102,166,61,102,167,61,102,168,61,102,169,61,78,170,61,78,171,61,103,172,61,102,173,61,78,174,61,78,175,61,78
    db 176,61,78,177,61,78,178,61,78,179,61,78,180,61,78,181,61,78,182,61,78,183,61,78,184,61,78,185,61,78,186,61,78,187,61,78,188,61,78,189,61,78,190,61,78,191,61,77,192,61,102,193,61,102,194,61,102,195,61,102,196,61,102,197,61,102,198,61,102,199,61,102,200,61,102,201,61,78,202,61,79,203,61,79,204,61,78,205,61,78
    db 206,61,78,207,61,78,208,61,78,209,61,78,210,61,78,211,61,78,212,61,78,213,61,78,214,61,78,215,61,78,216,61,78,217,61,79,218,61,79,219,61,79,220,61,78,221,61,102,222,61,102,223,61,102,224,61,102,225,61,102,226,61,102,227,61,102,228,61,102,229,61,102,230,61,102,231,61,102,232,61,102,233,61,77,234,61,78,235,61,78
    db 236,61,78,237,61,78,238,61,78,239,61,78,240,61,78,241,61,78,242,61,78,243,61,78,244,61,78,245,61,78,10,62,78,11,62,78,12,62,78,13,62,78,14,62,78,15,62,78,16,62,78,17,62,78,18,62,78,19,62,78,20,62,78,21,62,78,22,62,78,23,62,78,24,62,78,25,62,78,26,62,77,27,62,77,28,62,77,29,62,77
    db 30,62,77,31,62,77,32,62,78,33,62,78,34,62,78,35,62,78,36,62,78,37,62,78,38,62,78,39,62,78,40,62,78,41,62,78,42,62,78,43,62,78,44,62,78,45,62,78,46,62,78,47,62,78,48,62,78,49,62,78,50,62,78,51,62,78,52,62,78,53,62,78,54,62,78,55,62,78,56,62,78,57,62,77,58,62,77,59,62,77
    db 60,62,77,61,62,77,62,62,78,63,62,78,64,62,78,65,62,78,66,62,78,67,62,78,68,62,78,69,62,78,70,62,78,71,62,78,72,62,78,73,62,78,74,62,78,75,62,77,76,62,102,77,62,102,78,62,102,79,62,102,80,62,102,81,62,102,82,62,102,83,62,102,84,62,102,85,62,102,86,62,102,87,62,102,88,62,102,89,62,78
    db 90,62,79,91,62,79,92,62,78,93,62,78,94,62,78,95,62,78,96,62,78,97,62,78,98,62,78,99,62,78,100,62,78,101,62,78,102,62,78,103,62,78,104,62,78,105,62,79,106,62,79,107,62,78,108,62,103,109,62,102,110,62,102,111,62,102,112,62,102,113,62,102,114,62,102,115,62,102,116,62,102,117,62,102,118,62,77,119,62,78
    db 120,62,78,121,62,78,122,62,78,123,62,78,124,62,78,125,62,78,126,62,78,127,62,78,128,62,78,129,62,78,130,62,78,131,62,78,132,62,78,133,62,78,134,62,78,135,62,78,136,62,77,137,62,102,138,62,77,139,62,78,140,62,78,141,62,78,142,62,78,143,62,78,144,62,78,145,62,78,146,62,78,147,62,78,148,62,78,149,62,78
    db 150,62,78,151,62,78,152,62,78,153,62,78,154,62,78,155,62,78,156,62,78,157,62,78,158,62,77,159,62,102,160,62,102,161,62,102,162,62,102,163,62,102,164,62,102,165,62,102,166,62,102,167,62,102,168,62,78,169,62,79,170,62,78,171,62,77,172,62,78,173,62,78,174,62,78,175,62,78,176,62,78,177,62,78,178,62,78,179,62,78
    db 180,62,78,181,62,78,182,62,78,183,62,78,184,62,78,185,62,78,186,62,78,187,62,78,188,62,78,189,62,78,190,62,78,191,62,78,192,62,77,193,62,102,194,62,102,195,62,102,196,62,102,197,62,102,198,62,102,199,62,102,200,62,78,201,62,79,202,62,78,203,62,78,204,62,78,205,62,78,206,62,78,207,62,78,208,62,78,209,62,78
    db 210,62,78,211,62,78,212,62,78,213,62,78,214,62,78,215,62,78,216,62,78,217,62,78,218,62,78,219,62,78,220,62,79,221,62,78,222,62,102,223,62,102,224,62,102,225,62,102,226,62,102,227,62,102,228,62,102,229,62,102,230,62,102,231,62,77,232,62,78,233,62,78,234,62,78,235,62,78,236,62,78,237,62,78,238,62,78,239,62,78
    db 240,62,78,241,62,78,242,62,78,243,62,78,244,62,78,245,62,78,10,63,78,11,63,78,12,63,78,13,63,78,14,63,78,15,63,78,16,63,78,17,63,78,18,63,78,19,63,78,20,63,78,21,63,78,22,63,78,23,63,78,24,63,78,25,63,78,26,63,78,27,63,78,28,63,78,29,63,78,30,63,78,31,63,78,32,63,78,33,63,78
    db 34,63,78,35,63,78,36,63,78,37,63,78,38,63,78,39,63,78,40,63,78,41,63,78,42,63,78,43,63,78,44,63,78,45,63,78,46,63,78,47,63,78,48,63,78,49,63,78,50,63,78,51,63,78,52,63,78,53,63,78,54,63,78,55,63,78,56,63,78,57,63,78,58,63,78,59,63,78,60,63,78,61,63,78,62,63,78,63,63,78
    db 64,63,78,65,63,78,66,63,78,67,63,78,68,63,78,69,63,78,70,63,78,71,63,78,72,63,78,73,63,78,74,63,78,75,63,78,76,63,78,77,63,77,78,63,102,79,63,102,80,63,102,81,63,102,82,63,102,83,63,102,84,63,102,85,63,102,86,63,102,87,63,77,88,63,79,89,63,25,90,63,78,91,63,78,92,63,78,93,63,78
    db 94,63,78,95,63,78,96,63,78,97,63,78,98,63,78,99,63,78,100,63,78,101,63,78,102,63,78,103,63,78,104,63,78,105,63,78,106,63,78,107,63,79,108,63,78,109,63,102,110,63,102,111,63,102,112,63,102,113,63,102,114,63,102,115,63,102,116,63,102,117,63,77,118,63,78,119,63,78,120,63,78,121,63,78,122,63,78,123,63,78
    db 124,63,78,125,63,78,126,63,78,127,63,78,128,63,78,129,63,78,130,63,78,131,63,78,132,63,78,133,63,78,134,63,78,135,63,78,136,63,78,137,63,77,138,63,78,139,63,78,140,63,78,141,63,78,142,63,78,143,63,78,144,63,78,145,63,78,146,63,78,147,63,78,148,63,78,149,63,78,150,63,78,151,63,78,152,63,78,153,63,78
    db 154,63,78,155,63,78,156,63,78,157,63,78,158,63,78,159,63,77,160,63,102,161,63,102,162,63,102,163,63,102,164,63,102,165,63,102,166,63,102,167,63,78,168,63,78,169,63,78,170,63,78,171,63,78,172,63,78,173,63,78,174,63,78,175,63,78,176,63,78,177,63,78,178,63,78,179,63,78,180,63,78,181,63,78,182,63,79,183,63,79
    db 184,63,79,185,63,78,186,63,78,187,63,78,188,63,78,189,63,78,190,63,78,191,63,78,192,63,78,193,63,78,194,63,77,195,63,102,196,63,102,197,63,102,198,63,77,199,63,78,200,63,78,201,63,78,202,63,78,203,63,78,204,63,78,205,63,78,206,63,78,207,63,78,208,63,78,209,63,78,210,63,78,211,63,78,212,63,78,213,63,78
    db 214,63,78,215,63,78,216,63,78,217,63,78,218,63,78,219,63,78,220,63,78,221,63,78,222,63,78,223,63,77,224,63,77,225,63,102,226,63,102,227,63,102,228,63,102,229,63,77,230,63,77,231,63,78,232,63,78,233,63,78,234,63,78,235,63,78,236,63,78,237,63,78,238,63,78,239,63,78,240,63,78,241,63,78,242,63,78,243,63,78
    db 244,63,78,245,63,78,10,64,79,11,64,79,12,64,79,13,64,79,14,64,79,15,64,78,16,64,78,17,64,78,18,64,78,19,64,78,20,64,78,21,64,78,22,64,78,23,64,78,24,64,78,25,64,78,26,64,78,27,64,78,28,64,78,29,64,78,30,64,78,31,64,78,32,64,78,33,64,78,34,64,78,35,64,78,36,64,78,37,64,78
    db 38,64,78,39,64,78,40,64,79,41,64,79,42,64,79,43,64,79,44,64,79,45,64,79,46,64,79,47,64,79,48,64,79,49,64,79,50,64,79,51,64,78,52,64,78,53,64,78,54,64,78,55,64,78,56,64,78,57,64,78,58,64,78,59,64,78,60,64,78,61,64,78,62,64,78,63,64,78,64,64,78,65,64,78,66,64,78,67,64,78
    db 68,64,78,69,64,78,70,64,78,71,64,78,72,64,78,73,64,78,74,64,78,75,64,78,76,64,78,77,64,78,78,64,78,79,64,77,80,64,102,81,64,102,82,64,102,83,64,102,84,64,102,85,64,77,86,64,77,87,64,78,88,64,78,89,64,78,90,64,78,91,64,78,92,64,78,93,64,78,94,64,78,95,64,78,96,64,78,97,64,78
    db 98,64,78,99,64,78,100,64,78,101,64,78,102,64,78,103,64,78,104,64,78,105,64,78,106,64,78,107,64,78,108,64,78,109,64,78,110,64,77,111,64,77,112,64,102,113,64,102,114,64,77,115,64,77,116,64,78,117,64,78,118,64,78,119,64,78,120,64,78,121,64,78,122,64,78,123,64,78,124,64,78,125,64,79,126,64,79,127,64,78
    db 128,64,78,129,64,78,130,64,78,131,64,78,132,64,78,133,64,78,134,64,78,135,64,78,136,64,78,137,64,78,138,64,78,139,64,78,140,64,78,141,64,78,142,64,78,143,64,78,144,64,78,145,64,78,146,64,78,147,64,78,148,64,79,149,64,79,150,64,79,151,64,79,152,64,78,153,64,78,154,64,78,155,64,78,156,64,78,157,64,78
    db 158,64,78,159,64,78,160,64,78,161,64,77,162,64,77,163,64,77,164,64,77,165,64,78,166,64,78,167,64,78,168,64,78,169,64,78,170,64,78,171,64,78,172,64,78,173,64,78,174,64,78,175,64,78,176,64,78,177,64,78,178,64,78,179,64,77,180,64,102,181,64,77,182,64,78,183,64,78,184,64,78,185,64,79,186,64,79,187,64,78
    db 188,64,78,189,64,78,190,64,78,191,64,78,192,64,78,193,64,78,194,64,78,195,64,78,196,64,78,197,64,78,198,64,78,199,64,78,200,64,78,201,64,78,202,64,78,203,64,78,204,64,78,205,64,78,206,64,78,207,64,78,208,64,78,209,64,78,210,64,78,211,64,78,212,64,78,213,64,78,214,64,78,215,64,78,216,64,78,217,64,78
    db 218,64,78,219,64,78,220,64,78,221,64,78,222,64,78,223,64,78,224,64,78,225,64,78,226,64,78,227,64,78,228,64,78,229,64,78,230,64,78,231,64,78,232,64,78,233,64,78,234,64,78,235,64,78,236,64,78,237,64,78,238,64,78,239,64,78,240,64,78,241,64,78,242,64,78,243,64,78,244,64,78,245,64,77,10,65,25,11,65,78
    db 12,65,103,13,65,103,14,65,103,15,65,102,16,65,102,17,65,102,18,65,77,19,65,77,20,65,78,21,65,78,22,65,78,23,65,78,24,65,78,25,65,78,26,65,78,27,65,78,28,65,78,29,65,78,30,65,78,31,65,78,32,65,78,33,65,78,34,65,78,35,65,78,36,65,78,37,65,79,38,65,79,39,65,79,40,65,78,41,65,103
    db 42,65,102,43,65,102,44,65,102,45,65,102,46,65,102,47,65,102,48,65,102,49,65,78,50,65,78,51,65,79,52,65,79,53,65,78,54,65,78,55,65,78,56,65,78,57,65,78,58,65,78,59,65,78,60,65,78,61,65,78,62,65,78,63,65,78,64,65,78,65,65,78,66,65,78,67,65,78,68,65,78,69,65,78,70,65,78,71,65,78
    db 72,65,78,73,65,78,74,65,78,75,65,78,76,65,78,77,65,78,78,65,78,79,65,78,80,65,78,81,65,78,82,65,78,83,65,78,84,65,78,85,65,78,86,65,78,87,65,78,88,65,78,89,65,78,90,65,78,91,65,78,92,65,78,93,65,78,94,65,78,95,65,78,96,65,78,97,65,78,98,65,78,99,65,78,100,65,78,101,65,78
    db 102,65,78,103,65,78,104,65,78,105,65,78,106,65,78,107,65,78,108,65,78,109,65,78,110,65,78,111,65,78,112,65,78,113,65,78,114,65,78,115,65,78,116,65,78,117,65,78,118,65,78,119,65,78,120,65,78,121,65,78,122,65,79,123,65,79,124,65,79,125,65,78,126,65,78,127,65,78,128,65,102,129,65,77,130,65,77,131,65,78
    db 132,65,78,133,65,78,134,65,78,135,65,78,136,65,78,137,65,78,138,65,78,139,65,78,140,65,78,141,65,78,142,65,78,143,65,78,144,65,77,145,65,77,146,65,102,147,65,102,148,65,102,149,65,103,150,65,103,151,65,78,152,65,79,153,65,79,154,65,79,155,65,78,156,65,78,157,65,78,158,65,78,159,65,78,160,65,78,161,65,78
    db 162,65,78,163,65,78,164,65,78,165,65,78,166,65,78,167,65,78,168,65,78,169,65,78,170,65,78,171,65,78,172,65,78,173,65,78,174,65,78,175,65,78,176,65,77,177,65,102,178,65,102,179,65,102,180,65,102,181,65,102,182,65,102,183,65,102,184,65,102,185,65,102,186,65,78,187,65,79,188,65,79,189,65,78,190,65,78,191,65,78
    db 192,65,78,193,65,78,194,65,78,195,65,78,196,65,78,197,65,78,198,65,78,199,65,78,200,65,78,201,65,78,202,65,78,203,65,78,204,65,78,205,65,79,206,65,79,207,65,79,208,65,79,209,65,79,210,65,79,211,65,79,212,65,79,213,65,79,214,65,79,215,65,79,216,65,78,217,65,78,218,65,78,219,65,78,220,65,78,221,65,78
    db 222,65,78,223,65,78,224,65,78,225,65,78,226,65,78,227,65,78,228,65,78,229,65,78,230,65,78,231,65,78,232,65,78,233,65,78,234,65,78,235,65,78,236,65,78,237,65,78,238,65,78,239,65,78,240,65,78,241,65,79,242,65,79,243,65,79,244,65,79,245,65,79,10,66,79,11,66,78,12,66,102,13,66,102,14,66,102,15,66,102
    db 16,66,102,17,66,102,18,66,102,19,66,102,20,66,102,21,66,77,22,66,78,23,66,78,24,66,78,25,66,78,26,66,78,27,66,78,28,66,78,29,66,78,30,66,78,31,66,78,32,66,78,33,66,78,34,66,78,35,66,79,36,66,24,37,66,79,38,66,78,39,66,102,40,66,102,41,66,102,42,66,102,43,66,102,44,66,102,45,66,102
    db 46,66,102,47,66,102,48,66,102,49,66,102,50,66,102,51,66,102,52,66,78,53,66,79,54,66,79,55,66,78,56,66,78,57,66,78,58,66,78,59,66,78,60,66,78,61,66,78,62,66,78,63,66,78,64,66,79,65,66,79,66,66,25,67,66,25,68,66,79,69,66,78,70,66,78,71,66,78,72,66,78,73,66,78,74,66,78,75,66,78
    db 76,66,78,77,66,78,78,66,78,79,66,78,80,66,78,81,66,78,82,66,78,83,66,78,84,66,78,85,66,78,86,66,78,87,66,78,88,66,78,89,66,78,90,66,78,91,66,78,92,66,78,93,66,78,94,66,79,95,66,25,96,66,25,97,66,79,98,66,79,99,66,79,100,66,25,101,66,24,102,66,79,103,66,79,104,66,78,105,66,78
    db 106,66,78,107,66,78,108,66,78,109,66,78,110,66,78,111,66,78,112,66,78,113,66,78,114,66,78,115,66,78,116,66,78,117,66,78,118,66,78,119,66,78,120,66,78,121,66,25,122,66,79,123,66,78,124,66,102,125,66,102,126,66,102,127,66,102,128,66,102,129,66,102,130,66,102,131,66,102,132,66,77,133,66,78,134,66,78,135,66,78
    db 136,66,78,137,66,78,138,66,78,139,66,78,140,66,78,141,66,78,142,66,77,143,66,102,144,66,102,145,66,102,146,66,102,147,66,102,148,66,102,149,66,102,150,66,102,151,66,102,152,66,102,153,66,78,154,66,79,155,66,79,156,66,78,157,66,78,158,66,78,159,66,78,160,66,78,161,66,78,162,66,78,163,66,78,164,66,78,165,66,78
    db 166,66,78,167,66,78,168,66,78,169,66,78,170,66,78,171,66,78,172,66,78,173,66,78,174,66,78,175,66,77,176,66,102,177,66,102,178,66,102,179,66,102,180,66,102,181,66,102,182,66,102,183,66,102,184,66,102,185,66,102,186,66,102,187,66,102,188,66,78,189,66,25,190,66,78,191,66,78,192,66,78,193,66,78,194,66,78,195,66,78
    db 196,66,78,197,66,78,198,66,78,199,66,78,200,66,78,201,66,78,202,66,78,203,66,79,204,66,25,205,66,78,206,66,78,207,66,103,208,66,102,209,66,102,210,66,102,211,66,102,212,66,102,213,66,102,214,66,78,215,66,78,216,66,79,217,66,25,218,66,78,219,66,78,220,66,78,221,66,78,222,66,78,223,66,78,224,66,78,225,66,78
    db 226,66,78,227,66,78,228,66,78,229,66,78,230,66,78,231,66,78,232,66,78,233,66,78,234,66,78,235,66,78,236,66,78,237,66,77,238,66,77,239,66,102,240,66,102,241,66,103,242,66,103,243,66,78,244,66,78,245,66,24,10,67,79,11,67,78,12,67,102,13,67,102,14,67,102,15,67,102,16,67,102,17,67,102,18,67,102,19,67,102
    db 20,67,102,21,67,102,22,67,102,23,67,77,24,67,78,25,67,78,26,67,78,27,67,78,28,67,78,29,67,78,30,67,78,31,67,78,32,67,78,33,67,79,34,67,79,35,67,79,36,67,78,37,67,102,38,67,102,39,67,102,40,67,102,41,67,102,42,67,102,43,67,102,44,67,102,45,67,102,46,67,102,47,67,102,48,67,102,49,67,102
    db 50,67,102,51,67,102,52,67,102,53,67,102,54,67,78,55,67,79,56,67,79,57,67,78,58,67,78,59,67,78,60,67,78,61,67,78,62,67,78,63,67,24,64,67,25,65,67,78,66,67,78,67,67,78,68,67,78,69,67,77,70,67,77,71,67,77,72,67,78,73,67,78,74,67,78,75,67,78,76,67,78,77,67,78,78,67,78,79,67,78
    db 80,67,78,81,67,78,82,67,78,83,67,78,84,67,78,85,67,78,86,67,78,87,67,78,88,67,78,89,67,78,90,67,78,91,67,78,92,67,79,93,67,79,94,67,78,95,67,78,96,67,103,97,67,103,98,67,102,99,67,102,100,67,103,101,67,78,102,67,78,103,67,79,104,67,79,105,67,79,106,67,78,107,67,78,108,67,78,109,67,78
    db 110,67,78,111,67,78,112,67,78,113,67,78,114,67,78,115,67,78,116,67,78,117,67,78,118,67,78,119,67,79,120,67,79,121,67,78,122,67,102,123,67,102,124,67,102,125,67,102,126,67,102,127,67,102,128,67,102,129,67,102,130,67,102,131,67,102,132,67,102,133,67,77,134,67,78,135,67,78,136,67,78,137,67,78,138,67,78,139,67,78
    db 140,67,78,141,67,77,142,67,102,143,67,102,144,67,102,145,67,102,146,67,102,147,67,102,148,67,102,149,67,102,150,67,102,151,67,102,152,67,102,153,67,102,154,67,102,155,67,78,156,67,25,157,67,78,158,67,78,159,67,78,160,67,78,161,67,78,162,67,78,163,67,78,164,67,78,165,67,78,166,67,78,167,67,78,168,67,78,169,67,78
    db 170,67,79,171,67,78,172,67,78,173,67,78,174,67,77,175,67,102,176,67,102,177,67,102,178,67,102,179,67,102,180,67,102,181,67,102,182,67,102,183,67,102,184,67,102,185,67,102,186,67,102,187,67,102,188,67,102,189,67,78,190,67,79,191,67,79,192,67,78,193,67,78,194,67,78,195,67,78,196,67,78,197,67,78,198,67,78,199,67,78
    db 200,67,78,201,67,79,202,67,79,203,67,78,204,67,103,205,67,102,206,67,102,207,67,102,208,67,102,209,67,102,210,67,102,211,67,102,212,67,102,213,67,102,214,67,102,215,67,102,216,67,102,217,67,78,218,67,79,219,67,79,220,67,78,221,67,78,222,67,78,223,67,78,224,67,78,225,67,78,226,67,78,227,67,78,228,67,78,229,67,78
    db 230,67,78,231,67,78,232,67,78,233,67,78,234,67,78,235,67,77,236,67,102,237,67,102,238,67,102,239,67,102,240,67,102,241,67,102,242,67,102,243,67,102,244,67,103,245,67,25,246,67,16,10,68,79,11,68,78,12,68,102,13,68,102,14,68,102,15,68,102,16,68,102,17,68,102,18,68,102,19,68,102,20,68,102,21,68,102,22,68,102
    db 23,68,102,24,68,102,25,68,77,26,68,78,27,68,79,28,68,79,29,68,79,30,68,79,31,68,79,32,68,79,33,68,78,34,68,78,35,68,102,36,68,102,37,68,102,38,68,102,39,68,102,40,68,102,41,68,102,42,68,102,43,68,102,44,68,102,45,68,102,46,68,102,47,68,102,48,68,102,49,68,102,50,68,102,51,68,102,52,68,102
    db 53,68,102,54,68,102,55,68,103,56,68,78,57,68,79,58,68,79,59,68,79,60,68,79,61,68,79,62,68,79,63,68,79,64,68,78,65,68,102,66,68,102,67,68,102,68,68,102,69,68,102,70,68,102,71,68,102,72,68,102,73,68,77,74,68,77,75,68,78,76,68,78,77,68,78,78,68,78,79,68,78,80,68,78,81,68,78,82,68,78
    db 83,68,78,84,68,78,85,68,78,86,68,78,87,68,78,88,68,78,89,68,79,90,68,79,91,68,79,92,68,78,93,68,102,94,68,102,95,68,102,96,68,102,97,68,102,98,68,102,99,68,102,100,68,102,101,68,102,102,68,102,103,68,102,104,68,103,105,68,78,106,68,79,107,68,79,108,68,78,109,68,78,110,68,78,111,68,78,112,68,78
    db 113,68,78,114,68,78,115,68,78,116,68,78,117,68,78,118,68,79,119,68,79,120,68,103,121,68,102,122,68,102,123,68,102,124,68,102,125,68,102,126,68,102,127,68,102,128,68,102,129,68,102,130,68,102,131,68,102,132,68,102,133,68,102,134,68,102,135,68,77,136,68,78,137,68,78,138,68,78,139,68,78,140,68,102,141,68,102,142,68,102
    db 143,68,102,144,68,102,145,68,102,146,68,102,147,68,102,148,68,102,149,68,102,150,68,102,151,68,102,152,68,102,153,68,102,154,68,102,155,68,102,156,68,78,157,68,79,158,68,79,159,68,78,160,68,78,161,68,78,162,68,78,163,68,78,164,68,78,165,68,78,166,68,78,167,68,78,168,68,79,169,68,79,170,68,78,171,68,78,172,68,77
    db 173,68,102,174,68,102,175,68,102,176,68,102,177,68,102,178,68,102,179,68,102,180,68,102,181,68,102,182,68,102,183,68,102,184,68,102,185,68,102,186,68,102,187,68,102,188,68,102,189,68,102,190,68,103,191,68,78,192,68,79,193,68,78,194,68,78,195,68,78,196,68,78,197,68,78,198,68,78,199,68,78,200,68,79,201,68,79,202,68,78
    db 203,68,102,204,68,102,205,68,102,206,68,102,207,68,102,208,68,102,209,68,102,210,68,102,211,68,102,212,68,102,213,68,102,214,68,102,215,68,102,216,68,102,217,68,102,218,68,102,219,68,78,220,68,79,221,68,79,222,68,79,223,68,78,224,68,78,225,68,78,226,68,78,227,68,78,228,68,78,229,68,78,230,68,78,231,68,78,232,68,78
    db 233,68,77,234,68,102,235,68,102,236,68,102,237,68,102,238,68,102,239,68,102,240,68,102,241,68,102,242,68,102,243,68,102,244,68,103,245,68,25,10,69,79,11,69,78,12,69,102,13,69,102,14,69,102,15,69,102,16,69,102,17,69,102,18,69,102,19,69,102,20,69,102,21,69,102,22,69,102,23,69,102,24,69,102,25,69,102,26,69,102
    db 27,69,78,28,69,78,29,69,78,30,69,78,31,69,78,32,69,102,33,69,102,34,69,102,35,69,102,36,69,102,37,69,102,38,69,102,39,69,102,40,69,102,41,69,102,42,69,102,43,69,102,44,69,102,45,69,102,46,69,102,47,69,102,48,69,102,49,69,102,50,69,102,51,69,102,52,69,102,53,69,102,54,69,102,55,69,102,56,69,102
    db 57,69,103,58,69,78,59,69,78,60,69,78,61,69,78,62,69,102,63,69,78,64,69,78,65,69,102,66,69,102,67,69,102,68,69,102,69,69,102,70,69,102,71,69,102,72,69,102,73,69,102,74,69,102,75,69,102,76,69,77,77,69,78,78,69,78,79,69,78,80,69,78,81,69,78,82,69,78,83,69,78,84,69,78,85,69,78,86,69,78
    db 87,69,79,88,69,79,89,69,79,90,69,78,91,69,102,92,69,102,93,69,102,94,69,102,95,69,102,96,69,102,97,69,102,98,69,102,99,69,102,100,69,102,101,69,102,102,69,102,103,69,102,104,69,102,105,69,102,106,69,103,107,69,78,108,69,79,109,69,79,110,69,78,111,69,78,112,69,78,113,69,78,114,69,78,115,69,78,116,69,79
    db 117,69,25,118,69,78,119,69,102,120,69,102,121,69,102,122,69,102,123,69,102,124,69,102,125,69,102,126,69,102,127,69,102,128,69,102,129,69,102,130,69,102,131,69,102,132,69,102,133,69,102,134,69,102,135,69,102,136,69,77,137,69,78,138,69,77,139,69,102,140,69,102,141,69,102,142,69,102,143,69,102,144,69,102,145,69,102,146,69,102
    db 147,69,102,148,69,102,149,69,102,150,69,102,151,69,102,152,69,102,153,69,102,154,69,102,155,69,102,156,69,102,157,69,102,158,69,78,159,69,79,160,69,79,161,69,78,162,69,78,163,69,78,164,69,78,165,69,78,166,69,79,167,69,25,168,69,79,169,69,103,170,69,102,171,69,102,172,69,102,173,69,102,174,69,102,175,69,102,176,69,102
    db 177,69,102,178,69,102,179,69,102,180,69,102,181,69,102,182,69,102,183,69,102,184,69,102,185,69,102,186,69,102,187,69,102,188,69,102,189,69,102,190,69,102,191,69,102,192,69,78,193,69,79,194,69,25,195,69,79,196,69,79,197,69,79,198,69,79,199,69,79,200,69,78,201,69,102,202,69,102,203,69,102,204,69,102,205,69,102,206,69,102
    db 207,69,102,208,69,102,209,69,102,210,69,102,211,69,102,212,69,102,213,69,102,214,69,102,215,69,102,216,69,102,217,69,102,218,69,102,219,69,102,220,69,102,221,69,78,222,69,78,223,69,79,224,69,79,225,69,79,226,69,79,227,69,79,228,69,79,229,69,78,230,69,77,231,69,77,232,69,102,233,69,102,234,69,102,235,69,102,236,69,102
    db 237,69,102,238,69,102,239,69,102,240,69,102,241,69,102,242,69,102,243,69,102,244,69,103,245,69,25,10,70,25,11,70,78,12,70,78,13,70,79,14,70,79,15,70,79,16,70,79,17,70,78,18,70,103,19,70,102,20,70,102,21,70,102,22,70,102,23,70,102,24,70,102,25,70,102,26,70,102,27,70,102,28,70,102,29,70,102,30,70,102
    db 31,70,102,32,70,102,33,70,102,34,70,102,35,70,102,36,70,102,37,70,102,38,70,102,39,70,102,40,70,102,41,70,102,42,70,102,43,70,102,44,70,102,45,70,102,46,70,102,47,70,102,48,70,102,49,70,102,50,70,102,51,70,102,52,70,102,53,70,102,54,70,102,55,70,102,56,70,102,57,70,102,58,70,102,59,70,102,60,70,102
    db 61,70,102,62,70,102,63,70,78,64,70,78,65,70,102,66,70,102,67,70,102,68,70,102,69,70,102,70,70,102,71,70,102,72,70,102,73,70,102,74,70,102,75,70,102,76,70,102,77,70,77,78,70,77,79,70,78,80,70,78,81,70,78,82,70,78,83,70,78,84,70,79,85,70,79,86,70,79,87,70,79,88,70,103,89,70,102,90,70,102
    db 91,70,102,92,70,102,93,70,102,94,70,102,95,70,102,96,70,102,97,70,102,98,70,102,99,70,102,100,70,102,101,70,102,102,70,102,103,70,102,104,70,102,105,70,102,106,70,102,107,70,102,108,70,78,109,70,79,110,70,79,111,70,79,112,70,78,113,70,78,114,70,79,115,70,79,116,70,79,117,70,78,118,70,102,119,70,102,120,70,102
    db 121,70,102,122,70,102,123,70,102,124,70,102,125,70,102,126,70,102,127,70,102,128,70,102,129,70,102,130,70,102,131,70,102,132,70,102,133,70,102,134,70,102,135,70,102,136,70,102,137,70,102,138,70,102,139,70,102,140,70,102,141,70,102,142,70,102,143,70,102,144,70,102,145,70,102,146,70,102,147,70,102,148,70,102,149,70,102,150,70,102
    db 151,70,102,152,70,102,153,70,102,154,70,102,155,70,102,156,70,102,157,70,102,158,70,102,159,70,78,160,70,79,161,70,79,162,70,79,163,70,79,164,70,79,165,70,79,166,70,79,167,70,78,168,70,102,169,70,102,170,70,102,171,70,102,172,70,102,173,70,102,174,70,102,175,70,102,176,70,102,177,70,102,178,70,102,179,70,102,180,70,102
    db 181,70,102,182,70,102,183,70,102,184,70,102,185,70,102,186,70,102,187,70,102,188,70,102,189,70,102,190,70,102,191,70,102,192,70,102,193,70,102,194,70,78,195,70,78,196,70,79,197,70,78,198,70,78,199,70,102,200,70,102,201,70,102,202,70,102,203,70,102,204,70,102,205,70,102,206,70,102,207,70,102,208,70,102,209,70,102,210,70,102
    db 211,70,102,212,70,102,213,70,102,214,70,102,215,70,102,216,70,102,217,70,102,218,70,102,219,70,102,220,70,102,221,70,102,222,70,102,223,70,102,224,70,78,225,70,78,226,70,79,227,70,79,228,70,78,229,70,103,230,70,102,231,70,102,232,70,102,233,70,102,234,70,102,235,70,102,236,70,102,237,70,102,238,70,102,239,70,102,240,70,102
    db 241,70,102,242,70,102,243,70,102,244,70,103,245,70,25,10,71,24,11,71,24,12,71,23,13,71,25,14,71,7,15,71,7,16,71,23,17,71,24,18,71,25,19,71,78,20,71,103,21,71,102,22,71,102,23,71,102,24,71,102,25,71,102,26,71,102,27,71,102,28,71,102,29,71,102,30,71,102,31,71,102,32,71,102,33,71,102,34,71,102
    db 35,71,102,36,71,102,37,71,102,38,71,102,39,71,102,40,71,102,41,71,102,42,71,30,48,71,30,49,71,102,50,71,102,51,71,102,52,71,102,53,71,102,54,71,102,55,71,102,56,71,102,57,71,102,58,71,102,59,71,102,60,71,102,61,71,102,62,71,102,63,71,78,64,71,78,65,71,102,66,71,102,67,71,102,68,71,102,69,71,102
    db 70,71,102,71,71,102,72,71,102,73,71,102,74,71,102,75,71,102,76,71,102,77,71,102,78,71,102,79,71,102,80,71,78,81,71,79,82,71,79,83,71,79,84,71,78,85,71,78,86,71,103,87,71,102,88,71,102,89,71,102,90,71,102,91,71,102,92,71,102,93,71,102,94,71,102,95,71,102,96,71,102,97,71,102,98,71,102,99,71,102
    db 100,71,102,101,71,102,102,71,102,103,71,102,104,71,102,105,71,102,106,71,102,107,71,102,108,71,102,109,71,102,110,71,78,111,71,78,112,71,79,113,71,79,114,71,78,115,71,78,116,71,102,117,71,102,118,71,102,119,71,102,120,71,102,121,71,102,122,71,102,123,71,102,124,71,102,125,71,102,126,71,102,127,71,102,128,71,102,129,71,102
    db 130,71,102,131,71,102,132,71,102,133,71,102,134,71,102,135,71,102,136,71,102,137,71,102,138,71,102,139,71,102,140,71,102,141,71,102,142,71,102,143,71,102,144,71,102,145,71,102,146,71,102,147,71,101,148,71,0,149,71,101,150,71,102,151,71,102,152,71,102,153,71,102,154,71,102,155,71,102,156,71,102,157,71,102,158,71,102,159,71,102
    db 160,71,102,161,71,78,162,71,78,163,71,78,164,71,78,165,71,78,166,71,102,167,71,102,168,71,102,169,71,102,170,71,102,171,71,102,172,71,102,173,71,102,174,71,102,175,71,102,176,71,77,177,71,78,178,71,102,179,71,102,180,71,102,181,71,102,182,71,102,183,71,102,184,71,102,185,71,102,186,71,102,187,71,102,188,71,102,189,71,102
    db 190,71,102,191,71,102,192,71,102,193,71,102,194,71,102,195,71,102,196,71,102,197,71,102,198,71,102,199,71,102,200,71,102,201,71,102,202,71,102,203,71,102,204,71,102,205,71,102,206,71,102,207,71,102,208,71,102,209,71,102,210,71,102,211,71,102,212,71,102,213,71,102,214,71,103,215,71,102,216,71,102,217,71,102,218,71,102,219,71,102
    db 220,71,102,221,71,102,222,71,102,223,71,102,224,71,102,225,71,102,226,71,102,227,71,102,228,71,102,229,71,102,230,71,102,231,71,102,232,71,102,233,71,102,234,71,102,235,71,102,236,71,102,237,71,102,238,71,78,239,71,78,240,71,79,241,71,79,242,71,79,243,71,78,244,71,78,245,71,25,18,72,23,19,72,24,20,72,25,21,72,78
    db 22,72,103,23,72,102,24,72,102,25,72,102,26,72,102,27,72,102,28,72,102,29,72,102,30,72,102,31,72,102,32,72,102,33,72,102,34,72,102,35,72,102,36,72,102,37,72,102,38,72,102,39,72,102,50,72,0,51,72,102,52,72,102,53,72,102,54,72,102,55,72,102,56,72,102,57,72,102,58,72,102,59,72,102,60,72,102,61,72,102
    db 62,72,102,63,72,78,64,72,79,65,72,78,66,72,78,67,72,78,68,72,78,69,72,78,70,72,78,71,72,102,72,72,102,73,72,102,74,72,102,75,72,102,76,72,102,77,72,102,78,72,102,79,72,102,80,72,102,81,72,102,82,72,102,83,72,102,84,72,102,85,72,102,86,72,102,87,72,102,88,72,102,89,72,102,90,72,102,91,72,102
    db 92,72,102,93,72,102,94,72,102,95,72,102,96,72,102,97,72,102,98,72,102,99,72,102,100,72,102,101,72,102,102,72,102,103,72,102,104,72,102,105,72,102,106,72,102,107,72,102,108,72,102,109,72,102,110,72,102,111,72,102,112,72,102,113,72,102,114,72,102,115,72,102,116,72,102,117,72,102,118,72,102,119,72,102,120,72,102,121,72,102
    db 122,72,102,123,72,102,124,72,102,129,72,15,130,72,102,131,72,103,132,72,103,133,72,102,134,72,102,135,72,102,136,72,102,137,72,102,138,72,102,139,72,102,140,72,102,141,72,102,142,72,102,143,72,78,144,72,103,145,72,101,151,72,101,152,72,102,153,72,102,154,72,102,155,72,102,156,72,102,157,72,102,158,72,102,159,72,102,160,72,102
    db 161,72,102,162,72,102,163,72,102,164,72,102,165,72,102,166,72,102,167,72,102,168,72,102,169,72,102,170,72,102,171,72,102,172,72,102,173,72,102,174,72,102,175,72,78,176,72,79,177,72,24,178,72,103,179,72,102,180,72,102,181,72,102,182,72,102,183,72,102,184,72,102,185,72,102,186,72,102,187,72,102,188,72,102,189,72,102,190,72,102
    db 191,72,102,192,72,102,193,72,102,194,72,102,195,72,102,196,72,102,197,72,102,198,72,102,199,72,102,200,72,102,201,72,102,202,72,102,203,72,102,204,72,102,205,72,102,206,72,103,207,72,78,208,72,79,209,72,79,210,72,79,211,72,79,212,72,78,213,72,78,214,72,79,215,72,102,216,72,102,217,72,102,218,72,102,219,72,102,220,72,102
    db 221,72,102,222,72,102,223,72,102,224,72,102,225,72,102,226,72,102,227,72,102,228,72,102,229,72,102,230,72,102,231,72,102,232,72,102,233,72,102,234,72,102,235,72,102,236,72,78,237,72,79,238,72,24,239,72,24,240,72,173,241,72,150,242,72,173,243,72,24,244,72,24,245,72,24,20,73,24,21,73,172,22,73,24,23,73,78,24,73,78
    db 25,73,102,26,73,102,27,73,102,28,73,102,29,73,102,30,73,102,31,73,102,32,73,102,33,73,102,34,73,102,35,73,102,36,73,102,37,73,102,52,73,101,53,73,102,54,73,102,55,73,78,56,73,103,57,73,102,58,73,102,59,73,102,60,73,102,61,73,102,62,73,102,63,73,78,64,73,172,65,73,24,66,73,172,67,73,25,68,73,24
    db 69,73,172,70,73,24,71,73,79,72,73,78,73,73,102,74,73,102,75,73,102,76,73,102,77,73,102,78,73,102,79,73,102,80,73,102,81,73,102,82,73,102,83,73,102,84,73,102,85,73,102,86,73,102,87,73,102,88,73,102,89,73,102,90,73,102,91,73,102,92,73,102,93,73,102,94,73,102,95,73,102,96,73,30,101,73,101,102,73,102
    db 103,73,102,104,73,102,105,73,102,106,73,102,107,73,102,108,73,102,109,73,102,110,73,102,111,73,102,112,73,102,113,73,102,114,73,102,115,73,102,116,73,102,117,73,102,118,73,102,119,73,102,120,73,102,121,73,102,122,73,102,123,73,101,131,73,25,132,73,79,133,73,78,134,73,102,135,73,102,136,73,102,137,73,102,138,73,102,139,73,102
    db 140,73,102,141,73,102,142,73,78,143,73,24,144,73,25,153,73,102,154,73,102,155,73,102,156,73,102,157,73,102,158,73,102,159,73,102,160,73,102,161,73,102,162,73,102,163,73,102,164,73,102,165,73,102,166,73,102,167,73,102,168,73,102,169,73,102,170,73,102,171,73,102,172,73,102,173,73,77,174,73,78,175,73,25,176,73,24,181,73,101
    db 182,73,102,183,73,102,184,73,102,185,73,102,186,73,102,187,73,102,188,73,102,189,73,102,190,73,102,191,73,102,192,73,102,193,73,102,194,73,102,195,73,102,196,73,102,197,73,102,198,73,102,199,73,102,200,73,102,201,73,102,202,73,102,203,73,102,204,73,103,205,73,78,206,73,25,207,73,172,208,73,24,209,73,25,210,73,25,211,73,25
    db 212,73,172,213,73,172,214,73,172,216,73,102,217,73,102,218,73,102,219,73,102,220,73,102,221,73,102,222,73,102,223,73,102,224,73,102,225,73,102,226,73,102,227,73,102,228,73,102,229,73,102,230,73,102,231,73,102,232,73,102,233,73,102,234,73,78,235,73,79,236,73,24,237,73,24,238,73,30,22,74,24,23,74,24,24,74,25,25,74,79
    db 26,74,78,27,74,78,28,74,78,29,74,102,30,74,102,31,74,102,32,74,102,33,74,102,34,74,102,35,74,101,54,74,7,55,74,24,56,74,79,57,74,79,58,74,78,59,74,78,60,74,78,61,74,78,62,74,79,63,74,25,64,74,172,65,74,28,70,74,29,71,74,24,72,74,24,73,74,79,74,74,78,75,74,102,76,74,102,77,74,102
    db 78,74,102,79,74,102,80,74,102,81,74,102,82,74,102,83,74,102,84,74,102,85,74,102,86,74,102,87,74,102,88,74,102,89,74,102,90,74,102,91,74,102,92,74,102,93,74,102,103,74,101,104,74,102,105,74,102,106,74,102,107,74,102,108,74,102,109,74,102,110,74,102,111,74,102,112,74,102,113,74,102,114,74,102,115,74,102,116,74,102
    db 117,74,102,118,74,102,119,74,102,120,74,102,121,74,102,122,74,30,132,74,24,133,74,24,134,74,78,135,74,103,136,74,102,137,74,102,138,74,102,139,74,102,140,74,78,141,74,79,142,74,24,143,74,24,154,74,102,155,74,102,156,74,102,157,74,102,158,74,102,159,74,102,160,74,102,161,74,102,162,74,102,163,74,102,164,74,102,165,74,102
    db 166,74,102,167,74,102,168,74,102,169,74,102,170,74,102,171,74,78,172,74,78,173,74,79,174,74,24,175,74,24,183,74,101,184,74,102,185,74,102,186,74,102,187,74,102,188,74,102,189,74,102,190,74,102,191,74,78,192,74,103,193,74,102,194,74,102,195,74,102,196,74,102,197,74,102,198,74,102,199,74,102,200,74,103,201,74,77,202,74,103
    db 203,74,78,204,74,25,205,74,24,206,74,24,214,74,15,217,74,15,218,74,102,219,74,102,220,74,102,221,74,102,222,74,102,223,74,102,224,74,102,225,74,102,226,74,102,227,74,102,228,74,102,229,74,102,230,74,102,231,74,103,232,74,78,233,74,79,234,74,24,235,74,24,236,74,28,24,75,7,25,75,24,26,75,24,27,75,173,28,75,172
    db 29,75,103,30,75,101,31,75,101,32,75,30,56,75,23,57,75,25,58,75,24,59,75,172,60,75,172,61,75,24,62,75,24,63,75,23,73,75,24,74,75,24,75,75,79,76,75,78,77,75,103,78,75,102,79,75,102,80,75,102,81,75,102,82,75,102,83,75,102,84,75,102,85,75,102,86,75,102,87,75,102,88,75,102,89,75,102,90,75,102
    db 91,75,102,105,75,102,106,75,102,107,75,102,108,75,103,109,75,102,110,75,102,111,75,102,112,75,102,113,75,102,114,75,102,115,75,102,116,75,102,117,75,103,118,75,103,119,75,102,120,75,102,133,75,25,134,75,24,135,75,25,136,75,78,137,75,78,138,75,78,139,75,79,140,75,24,141,75,24,155,75,30,156,75,102,157,75,102,158,75,78
    db 159,75,103,160,75,102,161,75,102,162,75,102,163,75,102,164,75,102,165,75,102,166,75,102,167,75,77,168,75,103,169,75,102,170,75,78,171,75,25,172,75,24,173,75,24,185,75,30,186,75,102,187,75,102,188,75,102,189,75,102,190,75,102,191,75,78,192,75,79,193,75,79,194,75,78,195,75,78,196,75,78,197,75,78,198,75,78,199,75,79
    db 200,75,25,201,75,79,202,75,25,203,75,24,204,75,24,220,75,101,221,75,102,222,75,102,223,75,102,224,75,102,225,75,102,226,75,102,227,75,78,228,75,78,229,75,78,230,75,79,231,75,25,232,75,24,233,75,24,234,75,7,75,76,24,76,76,24,77,76,25,78,76,79,79,76,78,80,76,78,81,76,78,82,76,103,83,76,102,84,76,102
    db 85,76,102,86,76,102,87,76,102,88,76,102,89,76,101,107,76,102,108,76,79,109,76,79,110,76,78,111,76,78,112,76,78,113,76,78,114,76,78,115,76,78,116,76,79,117,76,25,118,76,7,135,76,24,136,76,24,137,76,24,138,76,24,139,76,24,140,76,15,157,76,103,158,76,25,159,76,79,160,76,79,161,76,78,162,76,78,163,76,78
    db 164,76,78,165,76,78,166,76,79,167,76,79,168,76,79,169,76,0,187,76,15,188,76,102,189,76,102,190,76,102,191,76,102,192,76,102,193,76,78,194,76,78,195,76,79,196,76,79,197,76,79,198,76,24,199,76,24,200,76,24,201,76,24,202,76,24,223,76,30,224,76,102,225,76,102,226,76,102,227,76,25,228,76,24,229,76,24,230,76,172
    db 231,76,24,77,77,24,78,77,23,79,77,172,80,77,24,81,77,24,82,77,78,83,77,102,84,77,102,85,77,102,86,77,101,108,77,25,109,77,24,110,77,172,111,77,24,112,77,24,113,77,24,114,77,24,115,77,172,116,77,23,117,77,25,137,77,15,138,77,15,159,77,23,160,77,172,161,77,172,162,77,24,163,77,24,164,77,24,165,77,172
    db 166,77,23,167,77,23,190,77,15,191,77,102,192,77,101,193,77,102,194,77,102,195,77,79,196,77,24,197,77,24,198,77,172,199,77,24,200,77,86,81,78,180,106,84,102,107,84,77,108,84,101,166,84,87,167,84,63,168,84,87,2,85,78,3,85,78,4,85,78,5,85,78,6,85,78,7,85,78,8,85,78,9,85,78,10,85,78,11,85,78
    db 12,85,78,13,85,78,14,85,78,15,85,78,20,85,15,21,85,78,22,85,78,23,85,78,24,85,78,25,85,78,30,85,78,31,85,78,32,85,78,33,85,78,34,85,78,35,85,78,36,85,78,37,85,78,38,85,78,39,85,78,40,85,78,41,85,78,42,85,78,43,85,77,53,85,101,54,85,78,55,85,78,56,85,78,57,85,78,69,85,78
    db 70,85,78,71,85,78,72,85,78,73,85,78,78,85,78,79,85,78,80,85,78,81,85,78,82,85,102,88,85,77,89,85,78,90,85,78,91,85,78,92,85,78,93,85,15,103,85,77,104,85,78,105,85,78,106,85,78,107,85,78,108,85,78,109,85,78,110,85,78,111,85,77,131,85,88,132,85,64,133,85,64,134,85,64,135,85,64,136,85,64
    db 137,85,12,138,85,64,139,85,64,140,85,15,150,85,63,151,85,64,152,85,64,153,85,64,154,85,64,163,85,87,164,85,64,165,85,64,166,85,64,167,85,12,168,85,12,169,85,64,170,85,64,171,85,63,180,85,64,181,85,64,182,85,64,183,85,64,184,85,64,185,85,64,186,85,64,187,85,12,188,85,64,189,85,88,197,85,64,198,85,64
    db 199,85,64,200,85,64,201,85,87,206,85,64,207,85,64,208,85,64,209,85,64,210,85,64,215,85,64,216,85,64,217,85,64,218,85,64,219,85,64,220,85,64,221,85,64,222,85,64,223,85,64,224,85,64,225,85,64,226,85,64,227,85,64,228,85,64,234,85,64,235,85,64,236,85,64,237,85,64,238,85,64,239,85,64,240,85,64,241,85,64
    db 242,85,64,243,85,64,2,86,78,3,86,78,4,86,53,5,86,53,6,86,53,7,86,53,8,86,53,9,86,53,10,86,53,11,86,53,12,86,53,13,86,53,14,86,53,15,86,53,20,86,15,21,86,78,22,86,53,23,86,53,24,86,53,25,86,78,30,86,78,31,86,53,32,86,53,33,86,53,34,86,53,35,86,53,36,86,53,37,86,53
    db 38,86,53,39,86,53,40,86,53,41,86,53,42,86,53,43,86,78,53,86,78,54,86,53,55,86,53,56,86,53,57,86,78,58,86,77,69,86,78,70,86,53,71,86,53,72,86,53,73,86,78,74,86,102,78,86,53,79,86,53,80,86,53,81,86,78,82,86,102,88,86,78,89,86,53,90,86,53,91,86,53,92,86,78,93,86,15,102,86,78
    db 103,86,78,104,86,53,105,86,53,106,86,53,107,86,53,108,86,53,109,86,53,110,86,53,111,86,78,112,86,78,131,86,63,132,86,12,133,86,12,134,86,12,135,86,12,136,86,12,137,86,12,138,86,12,139,86,12,140,86,64,141,86,64,150,86,63,151,86,12,152,86,12,153,86,12,154,86,12,162,86,64,163,86,12,164,86,12,165,86,12
    db 166,86,12,167,86,12,168,86,12,169,86,12,170,86,12,171,86,12,172,86,64,180,86,64,181,86,12,182,86,12,183,86,12,184,86,12,185,86,12,186,86,12,187,86,12,188,86,12,189,86,12,190,86,64,197,86,12,198,86,12,199,86,12,200,86,12,201,86,88,206,86,12,207,86,12,208,86,12,209,86,12,210,86,64,215,86,64,216,86,12
    db 217,86,12,218,86,12,219,86,12,220,86,12,221,86,12,222,86,12,223,86,12,224,86,12,225,86,12,226,86,12,227,86,12,228,86,12,234,86,12,235,86,12,236,86,12,237,86,12,238,86,12,239,86,12,240,86,12,241,86,12,242,86,12,243,86,64,2,87,78,3,87,78,4,87,53,5,87,53,6,87,53,7,87,53,8,87,53,9,87,53
    db 10,87,53,11,87,53,12,87,53,13,87,53,14,87,53,15,87,53,20,87,15,21,87,78,22,87,53,23,87,53,24,87,53,25,87,78,30,87,78,31,87,53,32,87,53,33,87,53,34,87,53,35,87,53,36,87,53,37,87,53,38,87,53,39,87,53,40,87,53,41,87,53,42,87,53,43,87,78,53,87,78,54,87,53,55,87,53,56,87,53
    db 57,87,53,58,87,78,69,87,78,70,87,53,71,87,53,72,87,53,73,87,53,74,87,78,78,87,53,79,87,53,80,87,53,81,87,78,82,87,102,88,87,78,89,87,53,90,87,53,91,87,53,92,87,78,93,87,15,101,87,78,102,87,53,103,87,53,104,87,53,105,87,53,106,87,53,107,87,53,108,87,53,109,87,53,110,87,53,111,87,53
    db 112,87,78,113,87,78,131,87,63,132,87,12,133,87,12,134,87,12,135,87,12,136,87,12,137,87,12,138,87,12,139,87,12,140,87,12,141,87,12,142,87,64,150,87,63,151,87,12,152,87,12,153,87,12,154,87,12,161,87,86,162,87,12,163,87,12,164,87,12,165,87,12,166,87,12,167,87,12,168,87,12,169,87,12,170,87,12,171,87,12
    db 172,87,12,173,87,63,180,87,64,181,87,12,182,87,12,183,87,12,184,87,12,185,87,12,186,87,12,187,87,12,188,87,12,189,87,12,190,87,64,191,87,15,197,87,12,198,87,12,199,87,12,200,87,12,201,87,88,206,87,12,207,87,12,208,87,12,209,87,12,210,87,64,215,87,64,216,87,12,217,87,12,218,87,12,219,87,12,220,87,12
    db 221,87,12,222,87,12,223,87,12,224,87,12,225,87,12,226,87,12,227,87,12,228,87,12,234,87,12,235,87,12,236,87,12,237,87,12,238,87,12,239,87,12,240,87,12,241,87,12,242,87,12,243,87,64,2,88,77,3,88,78,4,88,78,5,88,78,6,88,78,7,88,78,8,88,53,9,88,53,10,88,53,11,88,78,12,88,78,13,88,78
    db 14,88,78,15,88,78,20,88,15,21,88,78,22,88,53,23,88,53,24,88,53,25,88,78,30,88,78,31,88,78,32,88,78,33,88,78,34,88,78,35,88,78,36,88,53,37,88,53,38,88,53,39,88,78,40,88,78,41,88,78,42,88,78,43,88,77,52,88,77,53,88,78,54,88,53,55,88,53,56,88,53,57,88,53,58,88,78,69,88,78
    db 70,88,53,71,88,53,72,88,53,73,88,53,74,88,78,75,88,77,78,88,53,79,88,53,80,88,53,81,88,78,82,88,102,88,88,78,89,88,53,90,88,53,91,88,53,92,88,78,93,88,15,100,88,78,101,88,78,102,88,53,103,88,53,104,88,53,105,88,78,106,88,78,107,88,53,108,88,78,109,88,78,110,88,53,111,88,53,112,88,53
    db 113,88,78,114,88,78,131,88,63,132,88,12,133,88,12,134,88,12,135,88,12,136,88,64,137,88,12,138,88,12,139,88,12,140,88,12,141,88,12,142,88,12,143,88,63,150,88,63,151,88,12,152,88,12,153,88,12,154,88,12,161,88,64,162,88,12,163,88,12,164,88,12,165,88,12,166,88,64,167,88,64,168,88,64,169,88,12,170,88,12
    db 171,88,12,172,88,12,173,88,64,180,88,64,181,88,12,182,88,12,183,88,12,184,88,64,185,88,64,186,88,64,187,88,12,188,88,12,189,88,12,190,88,12,191,88,64,197,88,12,198,88,12,199,88,12,200,88,12,201,88,88,206,88,12,207,88,12,208,88,12,209,88,12,210,88,64,215,88,64,216,88,64,217,88,64,218,88,64,219,88,64
    db 220,88,12,221,88,12,222,88,12,223,88,12,224,88,64,225,88,64,226,88,64,227,88,64,228,88,64,234,88,12,235,88,12,236,88,12,237,88,12,238,88,64,239,88,64,240,88,64,241,88,64,242,88,64,243,88,64,3,89,15,4,89,15,5,89,15,7,89,53,8,89,53,9,89,53,10,89,78,11,89,101,13,89,15,14,89,15,20,89,15
    db 21,89,78,22,89,53,23,89,53,24,89,53,25,89,78,31,89,15,32,89,15,33,89,15,34,89,15,35,89,78,36,89,53,37,89,53,38,89,78,39,89,102,40,89,15,41,89,15,42,89,15,52,89,78,53,89,53,54,89,53,55,89,78,56,89,53,57,89,53,58,89,78,59,89,78,69,89,78,70,89,53,71,89,53,72,89,53,73,89,53
    db 74,89,53,75,89,78,78,89,53,79,89,53,80,89,53,81,89,78,82,89,102,88,89,78,89,89,53,90,89,53,91,89,53,92,89,78,93,89,15,99,89,15,100,89,78,101,89,53,102,89,53,103,89,53,104,89,78,105,89,78,108,89,15,109,89,78,110,89,78,111,89,53,112,89,53,113,89,53,114,89,78,115,89,101,131,89,63,132,89,12
    db 133,89,12,134,89,12,135,89,12,136,89,15,137,89,63,138,89,64,139,89,12,140,89,12,141,89,12,142,89,12,143,89,64,150,89,63,151,89,12,152,89,12,153,89,12,154,89,12,161,89,64,162,89,12,163,89,12,164,89,12,165,89,64,169,89,63,170,89,12,171,89,12,172,89,12,173,89,64,180,89,64,181,89,12,182,89,12,183,89,12
    db 184,89,64,187,89,64,188,89,12,189,89,12,190,89,12,191,89,64,197,89,12,198,89,12,199,89,12,200,89,12,201,89,88,206,89,12,207,89,12,208,89,12,209,89,12,210,89,64,216,89,15,217,89,15,218,89,15,220,89,12,221,89,12,222,89,12,223,89,12,224,89,88,226,89,15,227,89,15,234,89,12,235,89,12,236,89,12,237,89,12
    db 238,89,88,240,89,15,241,89,15,242,89,15,7,90,53,8,90,53,9,90,53,10,90,78,11,90,102,20,90,15,21,90,78,22,90,53,23,90,53,24,90,53,25,90,78,34,90,0,35,90,78,36,90,53,37,90,53,38,90,78,39,90,78,51,90,101,52,90,78,53,90,53,54,90,53,55,90,78,56,90,78,57,90,53,58,90,53,59,90,78
    db 69,90,78,70,90,53,71,90,53,72,90,53,73,90,53,74,90,53,75,90,78,76,90,78,78,90,53,79,90,53,80,90,53,81,90,78,82,90,102,88,90,78,89,90,53,90,90,53,91,90,53,92,90,78,93,90,15,99,90,78,100,90,53,101,90,53,102,90,53,103,90,78,104,90,77,110,90,78,111,90,78,112,90,78,113,90,78,114,90,78
    db 115,90,102,131,90,63,132,90,12,133,90,12,134,90,12,135,90,12,139,90,64,140,90,12,141,90,12,142,90,12,143,90,12,144,90,63,150,90,63,151,90,12,152,90,12,153,90,12,154,90,12,161,90,64,162,90,12,163,90,12,164,90,12,165,90,12,166,90,64,167,90,15,170,90,64,171,90,64,172,90,64,173,90,64,174,90,15,180,90,64
    db 181,90,12,182,90,12,183,90,12,184,90,64,187,90,86,188,90,12,189,90,12,190,90,12,191,90,12,197,90,12,198,90,12,199,90,12,200,90,12,201,90,88,206,90,12,207,90,12,208,90,12,209,90,12,210,90,64,220,90,12,221,90,12,222,90,12,223,90,12,224,90,63,234,90,12,235,90,12,236,90,12,237,90,12,238,90,88,7,91,53
    db 8,91,53,9,91,53,10,91,78,11,91,102,20,91,15,21,91,78,22,91,53,23,91,53,24,91,53,25,91,78,34,91,30,35,91,78,36,91,53,37,91,53,38,91,78,39,91,78,51,91,78,52,91,53,53,91,53,54,91,53,55,91,78,56,91,78,57,91,53,58,91,53,59,91,78,60,91,102,69,91,78,70,91,53,71,91,53,72,91,53
    db 73,91,78,74,91,53,75,91,53,76,91,78,78,91,53,79,91,53,80,91,53,81,91,78,82,91,102,88,91,78,89,91,53,90,91,53,91,91,53,92,91,78,93,91,15,99,91,78,100,91,53,101,91,53,102,91,53,103,91,78,111,91,15,112,91,30,113,91,30,114,91,101,115,91,101,131,91,63,132,91,12,133,91,12,134,91,12,135,91,12
    db 140,91,64,141,91,12,142,91,12,143,91,12,144,91,64,150,91,63,151,91,12,152,91,12,153,91,12,154,91,12,161,91,64,162,91,12,163,91,12,164,91,12,165,91,12,166,91,12,167,91,12,168,91,64,169,91,64,170,91,63,180,91,64,181,91,12,182,91,12,183,91,12,184,91,64,187,91,64,188,91,12,189,91,12,190,91,12,191,91,64
    db 197,91,12,198,91,12,199,91,12,200,91,12,201,91,88,206,91,12,207,91,12,208,91,12,209,91,12,210,91,64,220,91,12,221,91,12,222,91,12,223,91,12,224,91,63,234,91,12,235,91,12,236,91,12,237,91,12,238,91,64,239,91,64,240,91,64,241,91,64,242,91,64,243,91,64,7,92,53,8,92,53,9,92,53,10,92,78,11,92,102
    db 20,92,15,21,92,78,22,92,53,23,92,53,24,92,53,25,92,78,34,92,30,35,92,78,36,92,53,37,92,53,38,92,78,39,92,78,51,92,78,52,92,53,53,92,53,54,92,78,55,92,77,56,92,78,57,92,53,58,92,53,59,92,53,60,92,78,69,92,78,70,92,53,71,92,53,72,92,53,73,92,78,74,92,53,75,92,53,76,92,53
    db 77,92,78,78,92,53,79,92,53,80,92,53,81,92,78,82,92,102,88,92,78,89,92,53,90,92,53,91,92,53,92,92,78,93,92,15,99,92,78,100,92,53,101,92,53,102,92,78,103,92,77,131,92,63,132,92,12,133,92,12,134,92,12,135,92,12,140,92,64,141,92,12,142,92,12,143,92,12,144,92,64,150,92,63,151,92,12,152,92,12
    db 153,92,12,154,92,12,161,92,30,162,92,64,163,92,12,164,92,12,165,92,12,166,92,12,167,92,12,168,92,12,169,92,12,170,92,12,171,92,12,172,92,64,180,92,64,181,92,12,182,92,12,183,92,12,184,92,64,185,92,64,186,92,64,187,92,12,188,92,12,189,92,12,190,92,12,191,92,64,197,92,12,198,92,12,199,92,12,200,92,12
    db 201,92,88,206,92,12,207,92,12,208,92,12,209,92,12,210,92,64,220,92,12,221,92,12,222,92,12,223,92,12,224,92,63,234,92,12,235,92,12,236,92,12,237,92,12,238,92,12,239,92,12,240,92,12,241,92,12,242,92,12,243,92,12,7,93,53,8,93,53,9,93,53,10,93,78,11,93,102,20,93,15,21,93,78,22,93,53,23,93,53
    db 24,93,53,25,93,78,34,93,30,35,93,78,36,93,53,37,93,53,38,93,78,39,93,78,50,93,77,51,93,78,52,93,53,53,93,53,54,93,78,56,93,77,57,93,78,58,93,53,59,93,53,60,93,78,69,93,78,70,93,53,71,93,53,72,93,53,73,93,78,74,93,78,75,93,53,76,93,53,77,93,78,78,93,78,79,93,53,80,93,53
    db 81,93,78,82,93,102,88,93,78,89,93,53,90,93,53,91,93,53,92,93,78,93,93,15,99,93,78,100,93,53,101,93,53,102,93,53,103,93,77,131,93,63,132,93,12,133,93,12,134,93,12,135,93,12,140,93,12,141,93,12,142,93,12,143,93,12,144,93,64,150,93,63,151,93,12,152,93,12,153,93,12,154,93,12,162,93,88,163,93,64
    db 164,93,12,165,93,12,166,93,12,167,93,12,168,93,12,169,93,12,170,93,12,171,93,12,172,93,12,173,93,64,180,93,64,181,93,12,182,93,12,183,93,12,184,93,12,185,93,12,186,93,12,187,93,12,188,93,12,189,93,12,190,93,64,191,93,15,197,93,12,198,93,12,199,93,12,200,93,12,201,93,88,206,93,12,207,93,12,208,93,12
    db 209,93,12,210,93,64,220,93,12,221,93,12,222,93,12,223,93,12,224,93,63,234,93,12,235,93,12,236,93,12,237,93,12,238,93,12,239,93,12,240,93,12,241,93,12,242,93,12,243,93,12,7,94,53,8,94,53,9,94,53,10,94,78,11,94,102,20,94,15,21,94,78,22,94,53,23,94,53,24,94,53,25,94,78,34,94,30,35,94,78
    db 36,94,53,37,94,53,38,94,78,39,94,78,50,94,78,51,94,53,52,94,53,53,94,53,54,94,78,55,94,78,56,94,78,57,94,78,58,94,53,59,94,53,60,94,78,61,94,77,69,94,78,70,94,53,71,94,53,72,94,53,73,94,78,74,94,78,75,94,53,76,94,53,77,94,78,78,94,78,79,94,53,80,94,53,81,94,78,82,94,102
    db 88,94,78,89,94,53,90,94,53,91,94,53,92,94,78,93,94,15,99,94,78,100,94,53,101,94,53,102,94,78,103,94,77,131,94,63,132,94,12,133,94,12,134,94,12,135,94,12,140,94,64,141,94,12,142,94,12,143,94,12,144,94,64,150,94,63,151,94,12,152,94,12,153,94,12,154,94,12,164,94,63,165,94,64,166,94,12,167,94,12
    db 168,94,12,169,94,12,170,94,12,171,94,12,172,94,12,173,94,12,174,94,88,180,94,64,181,94,12,182,94,12,183,94,12,184,94,12,185,94,12,186,94,12,187,94,12,188,94,12,189,94,12,190,94,63,197,94,12,198,94,12,199,94,12,200,94,12,201,94,88,206,94,12,207,94,12,208,94,12,209,94,12,210,94,64,220,94,12,221,94,12
    db 222,94,12,223,94,12,224,94,63,234,94,12,235,94,12,236,94,12,237,94,12,238,94,12,239,94,12,240,94,12,241,94,12,242,94,12,243,94,12,7,95,53,8,95,53,9,95,53,10,95,78,11,95,102,20,95,15,21,95,78,22,95,53,23,95,53,24,95,53,25,95,78,34,95,0,35,95,78,36,95,53,37,95,53,38,95,78,39,95,78
    db 49,95,77,50,95,78,51,95,53,52,95,53,53,95,53,54,95,78,55,95,78,56,95,78,57,95,78,58,95,53,59,95,53,60,95,53,61,95,78,69,95,78,70,95,53,71,95,53,72,95,53,73,95,78,74,95,15,75,95,78,76,95,53,77,95,53,78,95,53,79,95,53,80,95,53,81,95,78,82,95,102,88,95,78,89,95,53,90,95,53
    db 91,95,53,92,95,78,93,95,15,99,95,78,100,95,53,101,95,53,102,95,53,103,95,78,110,95,101,111,95,78,112,95,78,113,95,78,114,95,78,115,95,102,131,95,63,132,95,12,133,95,12,134,95,12,135,95,12,139,95,88,140,95,12,141,95,12,142,95,12,143,95,12,144,95,64,150,95,63,151,95,12,152,95,12,153,95,12,154,95,12
    db 160,95,88,161,95,64,162,95,12,163,95,12,164,95,12,167,95,88,168,95,64,169,95,64,170,95,12,171,95,12,172,95,12,173,95,12,174,95,64,180,95,64,181,95,12,182,95,12,183,95,12,184,95,12,185,95,12,186,95,12,187,95,12,188,95,64,189,95,63,197,95,12,198,95,12,199,95,12,200,95,12,201,95,63,206,95,64,207,95,12
    db 208,95,12,209,95,12,210,95,64,220,95,12,221,95,12,222,95,12,223,95,12,224,95,63,234,95,12,235,95,12,236,95,12,237,95,12,238,95,63,239,95,88,240,95,88,241,95,88,242,95,88,243,95,88,7,96,53,8,96,53,9,96,53,10,96,78,11,96,102,20,96,15,21,96,78,22,96,53,23,96,53,24,96,53,25,96,78,34,96,0
    db 35,96,78,36,96,53,37,96,53,38,96,78,39,96,78,49,96,78,50,96,53,51,96,53,52,96,53,53,96,53,54,96,53,55,96,53,56,96,53,57,96,53,58,96,53,59,96,53,60,96,53,61,96,78,62,96,77,69,96,78,70,96,53,71,96,53,72,96,53,73,96,78,75,96,78,76,96,78,77,96,53,78,96,53,79,96,53,80,96,53
    db 81,96,78,82,96,102,88,96,78,89,96,53,90,96,53,91,96,53,92,96,78,93,96,15,99,96,77,100,96,78,101,96,53,102,96,53,103,96,53,104,96,78,109,96,15,110,96,78,111,96,53,112,96,53,113,96,53,114,96,78,115,96,77,131,96,63,132,96,12,133,96,12,134,96,12,135,96,12,138,96,87,139,96,64,140,96,12,141,96,12
    db 142,96,12,143,96,12,144,96,86,150,96,63,151,96,12,152,96,12,153,96,12,154,96,12,160,96,88,161,96,64,162,96,12,163,96,12,164,96,12,165,96,63,170,96,64,171,96,12,172,96,12,173,96,12,174,96,12,180,96,64,181,96,12,182,96,12,183,96,12,184,96,64,197,96,64,198,96,12,199,96,12,200,96,12,201,96,64,206,96,64
    db 207,96,12,208,96,12,209,96,12,210,96,64,220,96,12,221,96,12,222,96,12,223,96,12,224,96,63,234,96,12,235,96,12,236,96,12,237,96,12,238,96,63,7,97,53,8,97,53,9,97,53,10,97,78,11,97,102,20,97,15,21,97,78,22,97,53,23,97,53,24,97,53,25,97,78,34,97,0,35,97,78,36,97,53,37,97,53,38,97,78
    db 39,97,78,49,97,78,50,97,53,51,97,53,52,97,53,53,97,53,54,97,53,55,97,53,56,97,53,57,97,53,58,97,53,59,97,53,60,97,53,61,97,53,62,97,78,69,97,78,70,97,53,71,97,53,72,97,53,73,97,78,76,97,78,77,97,53,78,97,53,79,97,53,80,97,53,81,97,78,82,97,102,88,97,78,89,97,53,90,97,53
    db 91,97,53,92,97,78,93,97,15,100,97,78,101,97,53,102,97,53,103,97,53,104,97,53,105,97,78,106,97,78,107,97,77,108,97,78,109,97,78,110,97,53,111,97,53,112,97,53,113,97,53,114,97,78,131,97,63,132,97,12,133,97,12,134,97,12,135,97,12,136,97,64,137,97,64,138,97,12,139,97,12,140,97,12,141,97,12,142,97,12
    db 143,97,64,150,97,63,151,97,12,152,97,12,153,97,12,154,97,12,160,97,15,161,97,12,162,97,12,163,97,12,164,97,12,165,97,64,169,97,87,170,97,64,171,97,12,172,97,12,173,97,12,174,97,64,180,97,64,181,97,12,182,97,12,183,97,12,184,97,64,197,97,64,198,97,12,199,97,12,200,97,12,201,97,12,202,97,64,203,97,64
    db 204,97,64,205,97,12,206,97,12,207,97,12,208,97,12,209,97,12,210,97,64,220,97,12,221,97,12,222,97,12,223,97,12,224,97,63,234,97,12,235,97,12,236,97,12,237,97,12,238,97,64,239,97,12,240,97,12,241,97,12,242,97,12,243,97,64,7,98,53,8,98,53,9,98,53,10,98,78,11,98,102,20,98,15,21,98,78,22,98,53
    db 23,98,53,24,98,53,25,98,78,34,98,0,35,98,78,36,98,53,37,98,53,38,98,78,39,98,78,48,98,77,49,98,78,50,98,53,51,98,53,52,98,78,53,98,78,54,98,78,55,98,78,56,98,78,57,98,78,58,98,78,59,98,53,60,98,53,61,98,53,62,98,78,63,98,15,69,98,78,70,98,53,71,98,53,72,98,53,73,98,78
    db 76,98,78,77,98,78,78,98,53,79,98,53,80,98,53,81,98,78,82,98,102,88,98,78,89,98,53,90,98,53,91,98,53,92,98,78,93,98,15,100,98,77,101,98,78,102,98,53,103,98,53,104,98,53,105,98,53,106,98,78,107,98,78,108,98,53,109,98,53,110,98,53,111,98,53,112,98,53,113,98,78,114,98,101,131,98,63,132,98,12
    db 133,98,12,134,98,12,135,98,12,136,98,12,137,98,12,138,98,12,139,98,12,140,98,12,141,98,12,142,98,64,143,98,87,150,98,63,151,98,12,152,98,12,153,98,12,154,98,12,161,98,64,162,98,12,163,98,12,164,98,12,165,98,12,166,98,12,167,98,64,168,98,64,169,98,12,170,98,12,171,98,12,172,98,12,173,98,12,174,98,88
    db 180,98,64,181,98,12,182,98,12,183,98,12,184,98,64,197,98,63,198,98,12,199,98,12,200,98,12,201,98,12,202,98,12,203,98,12,204,98,12,205,98,12,206,98,12,207,98,12,208,98,12,209,98,12,210,98,15,220,98,12,221,98,12,222,98,12,223,98,12,224,98,63,234,98,12,235,98,12,236,98,12,237,98,12,238,98,12,239,98,12
    db 240,98,12,241,98,12,242,98,12,243,98,64,7,99,53,8,99,53,9,99,53,10,99,78,11,99,102,20,99,15,21,99,78,22,99,53,23,99,53,24,99,53,25,99,78,34,99,0,35,99,78,36,99,53,37,99,53,38,99,78,39,99,78,48,99,78,49,99,53,50,99,53,51,99,53,52,99,78,58,99,15,59,99,78,60,99,53,61,99,53
    db 62,99,53,63,99,78,69,99,78,70,99,53,71,99,53,72,99,53,73,99,78,77,99,78,78,99,53,79,99,53,80,99,53,81,99,53,82,99,102,88,99,78,89,99,53,90,99,53,91,99,53,92,99,78,93,99,15,101,99,77,102,99,78,103,99,53,104,99,53,105,99,53,106,99,53,107,99,53,108,99,53,109,99,53,110,99,53,111,99,53
    db 112,99,78,113,99,77,131,99,63,132,99,12,133,99,12,134,99,12,135,99,12,136,99,12,137,99,12,138,99,12,139,99,12,140,99,12,141,99,64,142,99,87,150,99,63,151,99,12,152,99,12,153,99,12,154,99,12,161,99,88,162,99,64,163,99,12,164,99,12,165,99,12,166,99,12,167,99,12,168,99,12,169,99,12,170,99,12,171,99,12
    db 172,99,12,173,99,64,180,99,64,181,99,12,182,99,12,183,99,12,184,99,64,198,99,64,199,99,12,200,99,12,201,99,12,202,99,12,203,99,12,204,99,12,205,99,12,206,99,12,207,99,12,208,99,12,209,99,64,220,99,12,221,99,12,222,99,12,223,99,12,224,99,63,234,99,12,235,99,12,236,99,12,237,99,12,238,99,12,239,99,12
    db 240,99,12,241,99,12,242,99,12,243,99,64,7,100,78,8,100,78,9,100,78,10,100,78,11,100,102,20,100,15,21,100,78,22,100,78,23,100,78,24,100,78,25,100,78,34,100,0,35,100,78,36,100,78,37,100,78,38,100,78,39,100,78,47,100,30,48,100,78,49,100,78,50,100,78,51,100,78,52,100,78,59,100,78,60,100,78,61,100,78
    db 62,100,78,63,100,78,69,100,78,70,100,78,71,100,78,72,100,78,73,100,78,77,100,77,78,100,78,79,100,78,80,100,78,81,100,78,82,100,102,88,100,78,89,100,78,90,100,78,91,100,78,92,100,78,93,100,15,102,100,102,103,100,78,104,100,78,105,100,53,106,100,53,107,100,53,108,100,53,109,100,53,110,100,78,111,100,78,112,100,30
    db 131,100,63,132,100,12,133,100,12,134,100,12,135,100,12,136,100,12,137,100,12,138,100,12,139,100,64,140,100,64,150,100,63,151,100,12,152,100,12,153,100,12,154,100,64,162,100,88,163,100,64,164,100,12,165,100,12,166,100,12,167,100,12,168,100,12,169,100,12,170,100,12,171,100,12,172,100,64,180,100,64,181,100,12,182,100,12,183,100,12
    db 184,100,64,199,100,64,200,100,12,201,100,12,202,100,12,203,100,12,204,100,12,205,100,12,206,100,12,207,100,64,208,100,63,220,100,12,221,100,12,222,100,12,223,100,12,224,100,63,234,100,64,235,100,12,236,100,12,237,100,12,238,100,12,239,100,12,240,100,12,241,100,12,242,100,12,243,100,64,7,101,77,8,101,77,9,101,77,10,101,77
    db 11,101,101,20,101,15,21,101,77,22,101,77,23,101,77,24,101,77,25,101,102,34,101,0,35,101,77,36,101,77,37,101,77,38,101,77,39,101,77,47,101,101,48,101,77,49,101,77,50,101,77,51,101,77,52,101,101,59,101,77,60,101,77,61,101,77,62,101,77,63,101,77,69,101,77,70,101,77,71,101,77,72,101,77,73,101,77,78,101,77
    db 79,101,77,80,101,77,81,101,77,82,101,101,88,101,77,89,101,77,90,101,77,91,101,77,92,101,77,93,101,15,104,101,101,105,101,78,106,101,78,107,101,78,108,101,78,109,101,78,110,101,30,131,101,88,132,101,63,133,101,63,134,101,63,135,101,63,136,101,63,137,101,63,138,101,63,150,101,88,151,101,63,152,101,63,153,101,63,154,101,63
    db 164,101,63,165,101,64,166,101,64,167,101,64,168,101,64,169,101,64,170,101,64,171,101,87,180,101,63,181,101,63,182,101,63,183,101,63,184,101,88,200,101,15,201,101,64,202,101,12,203,101,64,204,101,12,205,101,64,206,101,63,220,101,63,221,101,63,222,101,63,223,101,63,224,101,88,234,101,63,235,101,63,236,101,63,237,101,63,238,101,63
    db 239,101,63,240,101,63,241,101,63,242,101,63,243,101,88
    logoFrontSize dw 105 


    scoreLeft DB 100
    scoreRight DB 100
    destroyedBallsCountHealth db 255
    MINUTES Db 0
    RightLose db 'Right Player lost:( Left player Wins^_^','$'
    LeftLose db 'Left Player lost:( Right player Wins^_^','$'
    quitGame db 'Press any key to quit game','$'

.Code
    MAIN PROC FAR 
    MOV AX,@Data
    MOV DS,AX

    ElBdaya:
    videoMode 13h                 ;https://stanislavs.org/helppc/int_10.html click on set video modes for all modes
    blankScreen 0,0,4fh
    Print MSG
    blankScreen 0,0,0
    Logo 30,30
    readString UserName             ;get the player name
    mov al,0h
    cmp UserName+1,al               ;check if it is empty string
    jz tooShort
    mov al,0Fh
    cmp UserName+1,al               ; check if it is larger than 15 char
    jg tooLong
    ;;;;;;;;;;
    mov cl,UserName+1
    mov ch,00h
    mov SI,offset UserName+2
    LoopName:                       ;check if there is special char
    ;mov bx,[SI]
    mov al,30h
    cmp [SI],al
    jl special
    mov al,7Ah
    cmp [SI],al
    jg special

    mov al,40h
    cmp [SI],al
    je special

    mov al,5Ah
    cmp [SI],al
    jle NEXTTT
    mov al,61h
    cmp [SI],al
    jl special
   NEXTTT:
   inc SI
   loop LoopName
    ;;;;;;;;

    mov al,30h                ;check if the first char not a number
    cmp UserName+2,al
    jl okay
    mov al,39h
    cmp UserName+2,al
    jle Frist
    jmp okay

    special:
    Print MSGSpecial
    readKey                         ;get any key to continue
    jmp ElBdaya

    Frist:
    Print MSGFrist
    readKey                         ;get any key to continue
    jmp ElBdaya

    tooLong:
    Print MSGLong
    readKey                         ;get any key to continue
    jmp ElBdaya

    tooShort:
    Print MSGshort
    readKey                         ;get any key to continue
    jmp ElBdaya

    okay:                           ;Name is Valid
    Print Msg2                      ;show message of continue 
    blankScreen 0,0,0
    readKey                         ;get any key to continue
    videoMode 13h 
    Logo 30,30
    blankScreen 0,0,4fh
    Print MSG3
    blankScreen 0,0,7
    blankScreen2 07,15h,18h          ;draw notification bar
    resetMouse
    showMouse

    Getchar:                      ;get the player's decision
;drawPlatform  45, 55, 15, 10, 240
    checkMousePointer
      cmp bx,1
      jne checkOnceMore
      shr cx,1
    ;Checking if mouse click was on exit game.
    checkMouseRegion  65,305,85,95
      cmp ax,0
      Jne checkGame
      JMP ExitGame
      checkGame:
    checkMouseRegion 65,305,70,80
      cmp ax,0
      Jne checkChat
     JMP theGame
     checkChat:
    checkMouseRegion 65,305,55,65
      cmp ax,0
      Jne checkOnceMore
     jmp Chat
    checkOnceMore:
    getkeyboardStatus
    JZ getChar ;No key was pressed
    readKey
    cmp ah,3Bh                       ;scancode for F1
    JZ  Chat
    cmp ah,3Ch                       ;scanecode for F2
    JZ TheGame
    cmp al,1Bh                       ;asscii code for ESC
    Jz ExitGame
    jmp Getchar

    TheGame:                        ;start the game
    Print sendGame
    Print playerName2
    readKey
    Call GameProc
    return

    CHAT:
    Print sendChat
    Print playerName2
    readKey
    ExitGame:

 videoMode 03h ;Text mode.
return
MAIN ENDP 
    

;Procedures relating to graphics:
   GameProc proc near
    initialtime:
     mov ah,2ch
     int 21h ;gets the current time
     Mov MINUTES,cl
     
   blankScreen 104,0,4fh
    whileTime:                        ;while centisecond hasn't passed yet

        staticShipLeft 10,320
        staticShipRight 10,286 
        checkTimePassed Centiseconds
        
    
    JE whileTime                                   ;if a centisecond passes (won't be triggered for any less time)
        setTextCursor 10,2                       ;Set Cursor for position of leftscore
        displayNumber Minutes
        mov Centiseconds,dl                     ;centisecond(s) has passed update the time variable with the new time.
        call generateBallsWithTime
        blankScreen 104,4,35                    ;Color, from, to (on the x-axis)
        Waves                                   ;repeated calls to static waves
                                                ;repeated calls to staric waves
        dynamicBalls                            ;Responsible for drawing and maintaining ball movement
        shieldControlFirst Pr_y,4Dh,4Bh         ;control Pr_y up and down with right and left arrows.
        shieldControlSecond Pl_y,0fh,10h        ;control Pl_y up and down with Tab and Q.
        call drawShieldLeft                     ;Draw left shield
        call drawShieldRight                    ;Draw right shield
        call showHealth
        setTextCursor 2,1                       ;Set Cursor for position of destroyedCount
        print Username+2
        setTextCursor 2,2                       ;Set Cursor for position of leftscore
        displayNumber scoreLeft                  ;draw leftscore
        setTextCursor 33,1                       ;Set Cursor for position of rightscore
        print playerName2
        setTextCursor 33,2                       ;Set Cursor for position of rightscore
        displayNumber scoreRight                 ;draw rightscore

        cmp scoreRight,0                         ;check if right lost the game
        JNE LeftPlayerLoses
        RightPlayerLoses:
        blankScreen 104,0,4fh 
        setTextCursor 1,7
        Print RightLose                          ;give a message with loser
        setTextCursor 2,10
        Print quitGame
        ;leftWinsScreen 100,50          
        readKey                                    ;take any button to quit game
        jz quitGameNow

        LeftPlayerLoses:
        cmp scoreLeft,0                         ;check if left lost the game
        JNE kobry
        blankScreen 104,0,4fh  
        setTextCursor 1,7
        Print LeftLose
        setTextCursor 2,10
        Print quitGame
        ;rightWinsScreen 100,100
        readKey
        jz quitGameNow

    kobry:
    jmp whileTime

    quitGameNow:
        videoMode 03h ;Text mode. 
        return 
   ;return
   GameProc ENDP 
    
;description
 GenerateBallsWithtime PROC near
 ;; try to compare with big time to generate slowly
     mov ah,2ch
     int 21h ;gets the current time
     cmp MINUTES,cl
     je break
     MOV MINUTES,CL
     
     mov ax,8h
     cmp ballCount,ax
     jl changeballcount
     mov ax,0Ch
     mov ballCount,ax
     jmp break
     changeballcount: mov ax,8h
              mov ballCount,ax
      break:
      
      RET
    
  GenerateBallsWithtime ENDP 

   
   drawBall proc near
    mov ah,0ch
    mov bx,currentBallIndex
    cmp V_x+bx,0000h
    jz Notdrow
    mov SI, offset ball
    whilePixels:
       drawDynamicPixel [SI],[SI+1],colorBall, [bx+S_y],[bx+S_x]
       add SI,3
       cmp SI,offset ballSize
    JNE whilePixels
    Notdrow:
    ret
   drawBall endp
   
   showHealth proc near
        push bx
        mov bl, ScoreLeft
        mov bh,0
        cmp bx,50
        JL drawRed
        drawPlatform  40, 1, 49, 1, bx
        jmp checkNext
        drawRed:
        drawPlatform  40, 1, 41, 1, bx
        mov colorshieldleft,41
        mov colorShieldRight,0eh
        checkNext:
        mov bl, ScoreRight
        mov bh,0
        mov bp,280
        sub bp,bx
        cmp bx,50
        JL drawReds
        drawPlatform  bp, 1, 49, 1, bx
        jmp endit
        drawReds:
        mov colorshieldleft,0eh
        mov colorShieldRight,41
        drawPlatform  bp, 1, 41, 1, bx
        endit:
        pop bx
        ret
    showhealth endp
checkDestroyedCount proc near
 mov ah,2Ch               ;get Time
 int 21h
 mov al,dh                
 mov ah,00h
 mov dh,6h
 div dh
 mov al,ah               ;get random number between 1,6 to get random positon
 mov cl,2h
 mul cl
 displayNumber al
 mov ah,00h
 mov cx,ax 
   
 displayNumber bl                       
 mov ax,destroyedCount
 cmp ax,ballcount
 JNE Endd
    mov ax,2h
    sub destroyedCount,ax

    mov bx,cx
    mov ax,Sy+bx                 ;get random value from array Sy
    mov bx,currentBallIndex  
    mov S_y+bx,ax                 ;but it in our original array!

    mov bx,cx
    mov ax,Sx+bx
    mov bx,currentBallIndex  
    mov S_x+bx,ax

    mov bx,cx
    mov ax,Vy+bx
    mov bx,currentBallIndex  
    mov V_y+bx,ax
    
    mov bx,cx
    mov ax,Vx+bx
    mov bx,currentBallIndex  
    mov V_x+bx,ax
Endd:
ret
checkDestroyedCount endp
;Algorithm: 
    drawShieldLeft proc near
     mov ah,0ch
     mov BX, offset shield
     whileBeingDrawn:
       drawDynamicPixel [BX],[BX+1],colorShieldLeft, Pl_y, Pl_x
       add BX,3
       cmp BX,offset P_height
     JNE whileBeingDrawn
   ret
   drawShieldLeft endp



   drawShieldRight proc near
    mov ah,0ch
    mov BX, offset rightShield
    whileRightShieldBeingDrawn:
       drawDynamicPixel [BX],[BX+1],colorShieldRight, Pr_y, Pr_x
       add BX,3
       cmp BX,offset rightShieldSize
    JNE whileRightShieldBeingDrawn
   ret
   drawShieldRight endp

 ;Procedures relating to motion and collisions

  checkRightShipCollisions proc near  
        mov bx,currentBallIndex  
        mov ax, screenWidth                          
        sub ax,screenMarginx
        sub ax,ballSize
        cmp ax,[bx+S_x]
        JNE goOut1 ;first condition not satisified, no need to check anymore.
        JE goOutLast

        goOut1:
        mov ax, screenWidth                          
        sub ax,screenMarginx
        sub ax,ballSize
        sub ax,1
        cmp ax,[bx+S_x]
        JNE goOut2 ;first condition not satisified, no need to check anymore.
        JE goOutLast

        goOut2:
        mov ax, screenWidth                          
        sub ax,screenMarginx
        sub ax,ballSize
        sub ax,2
        cmp ax,[bx+S_x]
        JNE goOut3 ;first condition not satisified, no need to check anymore.
        JE goOutLast

        goOut3:
        mov ax, screenWidth                          
        sub ax,screenMarginx
        sub ax,ballSize
        sub ax,3
        cmp ax,[bx+S_x]
        JNE goOut ;first condition not satisified, no need to check anymore.

        goOutLast:
        cmp scoreRight,0
        JNG goOut
        mov ah,10
        sub scoreRight,ah
        ret
    goOut: ;Do nothing if none is satisfied
    ret
    checkRightShipCollisions endp

  checkLeftShipCollisions proc near

        mov bx,currentBallIndex                            
        mov ax,[bx+S_x]
        cmp ax, screenMarginx
        JNE goOutNow1 ;first condition not satisified, no need to check anymore.
        JE goOutNowLast

        goOutNow1:
        mov bx,currentBallIndex                            
        mov ax,[bx+S_x]
        sub ax, 1
        cmp ax, screenMarginx
        JNE goOutNow2 ;first condition not satisified, no need to check anymore.
        JE goOutNowLast

        goOutNow2:
        mov bx,currentBallIndex                            
        mov ax,[bx+S_x]
        sub ax, 2
        cmp ax, screenMarginx
        JNE goOutNow3 ;first condition not satisified, no need to check anymore.
        JE goOutNowLast

        goOutNow3:
        mov bx,currentBallIndex                            
        mov ax,[bx+S_x]
        sub ax, 3
        cmp ax, screenMarginx
        JNE goOutNow ;first condition not satisified, no need to check anymore.
        JE goOutNowLast

        ;Reaching this point indicates that the conditions are satisified.
        goOutNowLast:
        cmp scoreLeft,0
        JNG goOutNow 
        mov ah,10
        sub scoreLeft,ah
        ret   

    goOutNow: ;Do nothing if none is satisfied
    ret
    checkLeftShipCollisions endp

    checkLeftShieldCollisions proc near
        ;Check collisions with the left shield and do necessary action based on that
        ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
        ; M is the left shield and N is the ball     
        mov bx,currentBallIndex                            
        mov ax,Pl_x
        add ax,P_width
        cmp ax,[bx+S_x]
        JNG bye ;first condition not satisified, no need to check anymore.

        mov ax,[bx+S_x]
        add ax,ballSize
        cmp ax,Pl_X
        JNG bye       ;second condition

        mov ax,Pl_y
        add ax,P_height
        cmp ax,[bx+S_y]
        JNG bye

        mov ax,[bx+S_y]
        add ax,ballSize
        cmp ax,Pl_y
        JNG bye
        ;Reaching this point indicates that the conditions are satisified.
        NEG V_x+bx
        mov ax,positionThreshold
        add S_x+bx,ax
        ;And thus we reflect the ball about the horizontal axis.
        ;If V_y is zero, i.e. a fresh cannon, then the reflective power of the shield gives it some vertical velocity
        cmp V_y+bx,0 
        jnz checkUp
        inc V_y+bx ;some vertical velocity

        checkUp:
        ;If the ball touches the higher part of the shield, the ball is reflected such that (Vx, Vy) becomes (-Vx, -Vy)
        ;mov ax,Pl_Y
        ;cmp S_y,ax
        ;jg checkDown
        ;neg V_y
        ;If the ball touches the lower part of the shield, the ball is reflected such that (Vx, Vy) becomes (-Vx, -Vy)
        ;checkDown:
        ;mov ax,Pl_y
        ;add ax,P_height
        ;mov bx,ballsize
        ;add bx,S_y
        ;cmp bx,ax
        ;jng bye
        ;neg V_y
        bye:
        ret

    checkLeftShieldCollisions endp

    checkrightShieldCollisions proc near
        ;Check collisions with the right shield and do necessary action based on that
        ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
        ; M is the ball and N is the right shield
        mov bx,currentBallIndex                                  
        mov ax,[bx+S_x]
        add ax,ballSize
        cmp ax,Pr_x
        JNG exit ;first condition not satisified, no need to check anymore.

        mov ax,Pr_X
        add ax,P_width
        cmp ax,[bx+S_x]
        JNG exit ;second condition

        mov ax,[bx+S_y]
        add ax,ballSize
        cmp ax,Pr_y
        JNG exit

        mov ax,Pr_y
        add ax,P_height
        cmp ax, [bx+S_y]
        JNG exit
        ;Reaching this point indicates that the conditions are satisified.
        mov ax,positionThreshold
        sub S_x+bx,ax
        NEG V_x+bx
        ;And thus we reflect the ball about the horizontal axis.
        ;If V_y is zero, i.e. a fresh cannon, then the reflective power of the shield gives it some vertical velocity
        cmp V_y+bx,0 
        jnz skip
        inc V_y+bx ;some vertical velocity
        skip:
        ;If the ball touches the higher part of the shield, the ball is reflected such that (Vx, Vy) becomes (-Vx, -Vy)
        ;mov ax,Pr_Y
        ;cmp S_y,ax
        ;jg next
        ;neg V_y
        ;If the ball touches the lower part of the shield, the ball is reflected such that (Vx, Vy) becomes (-Vx, -Vy)
        ;next:
        ;mov ax,Pr_y
        ;add ax,P_height
        ;mov bx,ballsize
        ;add bx,S_y
        ;cmp bx,ax
        ;jng exit
        ;neg V_y
        exit:
        ret
    checkrightShieldCollisions endp

	moveBall PROC NEAR
     
		mov bx, currentBallIndex
		MOV AX,V_x+bx  
		ADD [bx+S_x],AX             ;move the ball horizontally
		
		MOV AX,screenMarginx
		CMP  [bx+S_x],AX                         
		JL Destroy         ;BALL_X < 0 + screenMargin (Y -> collided)
		
		MOV AX,screenWidth
		SUB AX,ballSize
		SUB AX,screenMarginx
		CMP [bx+S_x],AX	          ;BALL_X > screenWidth - ballSize  - screenMargin (Y -> collided)
		JG Destroy
		
		
		MOV AX,V_Y+bx
		ADD [bx+S_y],AX             ;move the ball vertically
		
		MOV AX,screenMarginy
		CMP [bx+S_y],AX   ;BALL_Y < 0 + screenMargin (Y -> collided)
		JL negateV_y                          
		
		MOV AX,screenHeight	
		SUB AX,ballSize
		SUB AX,screenMarginy
		CMP [bx+S_y],AX
		JG negateV_y		  ;BALL_Y > screenHeight - ballSize - screenMargin (Y -> collided)
		
		jmp goodBye
		
		negateV_y:
			NEG V_y+bx   ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			JMP goodBye

        Reset_Position: ;Don't think we'll need this
            resetPosition 0,0
            JMP goodBye

        Disappear:
            mov al,00h
            mov colorBall,al
        Destroy:
        mov ax,0
        cmp V_x+bx,ax
        JE goodBye
        mov ax,2
        add destroyedCount,ax
        mov ax,0
        mov V_x+bx,ax
        mov V_y+bx,ax
        mov S_x+bx,ax
        mov ax,100
        mov S_y+bx,ax
        goodBye:
call checkrightShieldCollisions
call checkleftShieldCollisions
call checkRightShipCollisions
call checkleftShipCollisions
ret
	moveBall ENDP

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