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

consumeKey macro
    push ax
    mov ah, 0
    int 16h
    pop ax
ENDM checkPossibleKey

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

Velocity macro V_x, V_y
    mov ax,V_x
    add S_x,ax ;Add V_x to S_x (done every centisecond >> velocity)

    ;checkVerticalWalls
    cmp S_x,0h
    JL Reverse_Velocity_X
    cmp S_x,310;320 (from resolution)-Ball_size - some_margin
    JG Reverse_Velocity_X

    mov ax,V_y ;Moving the ball for 5 pixels along y=x whenever a centisecond passes (velocity = 5 px/cs)
    add S_y,ax

   ; checkHorizontalWalls
    cmp S_y,0h
    JL Reverse_Velocity_Y
    cmp S_y,190 ;200 (from resolution) - Ball_size - some_margin
    JG Reverse_Velocity_Y
    
    JMP Done ;If none of the above was satisfied, do nothing.
    ;But in case any was satisified:
        Reverse_Velocity_X:
        neg V_x ;Finding the 2's complementing (multiplying by -1)

        JMP Done

        Reverse_Velocity_Y:
        neg V_y

    Done:

    endm Velocity



;____________________________________________________________________________________________________________________
;Let the code beign.

.286
.MODEL SMALL
.STACK 64   
.DATA
    S_x dw 0AH ;x position of the ball
    S_y dw 0AH ;y position of the ball
    V_x dw 5H ;Horizontal Velocity
    V_y dw 5H ;Vertical Velocity
    Ball_Size dw 8h; height, width of the ball 
    Centiseconds db 0;To check if a centisecond has passed.
.Code
    MAIN PROC FAR 
    MOV AX,@Data
    MOV DS,AX 
;Think of game objects >>Paddles, Balls.
;Ball must reverse direction whenever it collides with a paddle or wall
;it it collides with boundaries then points should be given to the right player.
;Game over conditions
;Layout overview :Main Menu, Game it self, Game over menu
    graphicsMode 13h ;https://stanislavs.org/helppc/int_10.html click on set video modes for all modes
    setBackgroundColor 0bh
    ;Updating the objects' position with time is how we get to move them. Get system time, check if time has passed, erase screen and redraw.
    ;Check if the current 100ths of a second is different than the previous one.
    whileTime: ;while centisecond hasn't passed yet
        checkTimePassed Centiseconds
    JE whileTime 
    ;if time passes
    mov Centiseconds,dl ;centisecond(s) has passed update the time variable with the new time
    Velocity V_x, V_y
    graphicsMode 13h 
    setBackgroundColor 0bh
    call drawball
    jmp whileTime

    MAIN ENDP 
    









    ;New Proceducre
    drawBall proc near
    ;{
        ;drawPixel 0fh,S_x,S_y
        ;Setting up the initial pixel
        mov cx,s_x
        mov dx,s_y
        whileBallBeingDrawn:
            drawPixel_implicit 0fh
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
    
    


END MAIN 


