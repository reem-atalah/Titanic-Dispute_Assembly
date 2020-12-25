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

ReadString macro Stringo ;Stringo db MaxSize, Actual Size, BufferData(initialize $)
    mov ah,0Ah
    mov dx,offset Stringo
    int 21h
ENDM ReadString

DisplayAx macro ;We might need this once we integrate an HP system
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
    pusha
    mov ax,0600h
    mov dx,2479h
    mov cx,0
    mov bh,07
    int 10h
    popa
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
        
drawDynamicPixel macro column, row, color
        mov al, color
        mov dx, row
        mov cx, column
        ;Dynamics:
        add dx, S_y
        add cx, S_x
        add cx,100 
        add dx,50
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

clearScreen macro color
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,00  ;color to blank the screen with
	mov cx,0000h  ;start from row 0, column 0
	mov dx,184fh ;to the end of the screen
	int 10h
ENDM clearScreen

checkDifference macro A,B,C ;checks if A-B=C and yields 0 if that's true
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
        local whileShieldBeingDrawn
        ;Setting up the initial pixel
        mov cx,P_x
        mov dx,P_y
        whileShieldBeingDrawn:
            drawPixel_implicit colorShield
            inc cx ;the x-coordinate
            checkDifference cx, P_x, P_width
         JNG whileShieldBeingDrawn ;Keep adding Pixels till Cx-S_x=ball_size
            mov cx, P_x
            inc dx
            checkDifference dx, P_y, P_Height
        JNG whileShieldBeingDrawn
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
;____________________________________________________________________________________________________________________
;Let the code beign.

.286
.MODEL MEDIUM
.STACK 64   
.DATA
    ;Data variables relating to the ball
    S_x dw 100 ;x position of the ball
    S_y dw 30 ;y position of the ball
    V_x dw 3H ;Horizontal Velocity
    V_y dw 3H ;Vertical Velocity
    colorBall db 0eh
    Ball_Size dw 10h; height, width of the ball 
    Centiseconds db 0;To check if a centisecond has passed.
    ;Data variables relating to the Shield (Pl (Left), Pr(Right))
    colorShield db 0bh
    Pl_x dw 45
    Pl_y dw 50
    Pr_x dw 275
    Pr_y dw 50
    P_width dw 02
    P_height dw 50
    P_Velocity dw 20
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
    ;call drawBall
    ;Updating the objects' position with time is how we get to move them. Get system time, check if time has passed, erase screen and redraw.
    ;Check if the current 100ths of a second is different than the previous one.
    whileTime: ;while centisecond hasn't passed yet
        checkTimePassed Centiseconds
    JE whileTime 
    ;if a centisecond passes (won't be triggered for any less time)
    mov Centiseconds,dl ;centisecond(s) has passed update the time variable with the new time.
    Motion V_x, V_y ;Call the velocity macro, note that it deals with collisions inside.
    clearScreen
    call plotImage
    call drawBall
    shieldControl Pr_y,4Dh,4Bh ;control Pr_y up and down with right and left arrows.
    shieldControl Pl_y,0fh,10h ;control Pl_y up and down with Tab and Q.
     drawShield Pl_x,Pl_y
     drawShield Pr_x,Pr_y
    jmp whileTime
    return
    MAIN ENDP 
    


    ;New Proceducre
    drawBall proc near
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
    drawBall endp
    

  
    plotImage proc near
mov ah,0ch
drawDynamicPixel 11, 0, 15 
drawDynamicPixel 18, 29, 15 
ret
    plotImage endp
    
    
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