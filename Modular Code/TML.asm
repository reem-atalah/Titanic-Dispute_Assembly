;Used Macros:   
    Print macro Stringo                                             ;Takes a string and prints it
        mov AH, 09h
        mov dx, offset Stringo
        int 21h
    endm Print

    displayCharacter macro Char                                     ;Takes a character and displays it
        mov dl,  Char
        add dl, 30h
        mov ah,  2h
        int 21h
    endm displayCharacter
    
    printCharacter macro Char                                     ;Takes a character and displays it
        mov dl,  Char
        mov ah,  2h
        int 21h
    endm printCharacter

    DisplayNumber macro number                                      ;Need comments here.
        pusha
        mov al, number
        mov ah, 0
        mov bl, 100
        div bl
        push ax
        displayCharacter al

        pop ax
        mov bl, 10
        mov al, ah
        mov ah, 0
        div bl
        push ax  
        displayCharacter al
        
        pop ax
        displayCharacter ah
        popa
    endm DisplayNumber


    ReadString macro Stringo                                        ;Stringo dw MaxSize,  Actual Size,  BufferData(initialize $)
        mov ah, 0Ah
        mov dx, offset Stringo
        int 21h
    endm ReadString


    setTextCursor macro Column, Row
        pusha
            mov  dl,  Column    
            mov  dh,  Row    
            mov  bh,  0                                              ;page no.
            mov  ah,  2     
            int  10h       
        popa
    endm setTextCursor


    checkPause macro
    local pLoop, tryLater, Accept
        ;check if p was pressed
        cmp ah, 19h
        JNE tryLater
        pLoop:
            getKeyboardStatus
            JZ Accept                       ;No key was pressed
            readkey                         ;key was pressed
            cmp ah, 19h
            jne pLoop                      ;if its not p then keep pausing
            sendByte 19h
            jmp tryLater
        Accept:
            receiveByte Ch
            cmp Ch, 19h
            Jne pLoop
        tryLater:
    endm checkPause
    
        checkPauseReceive macro
    local pLoop, tryLater, Accept
        ;check if p was pressed
        cmp ah, 19h
        JNE tryLater
        pLoop:
            getKeyboardStatus
            JZ Accept                       ;No key was pressed
            readkey                         ;key was pressed
            cmp ah, 19h
            jne pLoop                      ;if its not p then keep pausing
            sendByte 19h
            jmp tryLater
        Accept:
            receiveByte Ch
            cmp Ch, 19h
            Jne pLoop
        tryLater:
    endm checkPauseReceive

        checkPauseSend macro
    local pLoop, tryLater, Accept
        ;check if p was pressed
        cmp ah, 19h
        JNE tryLater
        pLoop:
            getKeyboardStatus
            JZ Accept                       ;No key was pressed
            readkey                         ;key was pressed
            cmp ah, 19h
            jne pLoop                      ;if its not p then keep pausing
            sendByte 19h
            jmp tryLater
        Accept:
            receiveByte Ch
            cmp Ch, 19h
            Jne pLoop
        tryLater:
    endm checkPauseSend
    


    videoMode macro Mode
        mov ah, 00h
        mov al, Mode
        int 10h
    endm videoMode

    drawHealthBar macro x,  y,  color,  height,  width              ;x,  y are the starting position (top left corner) 
       local whilePlatformBeingDrawn
        pusha
        mov cx, x                        
        mov dx, y                                
        whilePlatformBeingDrawn:
            drawPixel_implicit color
            inc cx                                                  ;the x-coordinate
            checkDifference cx,  x,  width                          ;Keep adding Pixels till Cx-P_x=widthPlatform (the first row is drawn)
         JNG whilePlatformBeingDrawn                                ;Once the first row is done start with the second row.
            mov cx,  x
            inc dx
            checkDifference dx,  y,  height
        JNG whilePlatformBeingDrawn
        popa
    endm drawHealthBar


    drawPixel macro color,  row,  column
        mov ah, 0ch
        mov bh, 00h ;Page no.
        mov al, color
        mov dx, row
        mov cx, column
        int 10h
    endm drawPixel
        
    drawDynamicPixel macro column,  row,  color,  Y_t,  X_t                 ;x,  y,  color...the last two parameters are the dynamic position of the pixel. Assumes that mov ah,  0ch was priorly done.
            xor ch, ch                                                      ;Because all of our images are db arrays.                                                                             
            xor dh, dh
            mov dl,  row
            mov cl,  column
            mov al,  color
            ;Dynamics:
            add dx,  Y_t                                                    ;X_t and Y_t correspond to the time changing position.
            add cx,  X_t
            int 10h
    endm drawDynamicPixel

    drawPixel_implicit macro color                                          ;Assumes that spatial (cx,  dx) parameters are already initialized.
        mov ah, 0ch
        mov bh, 00h                                                          ;Page no.
        mov al, color
        int 10h
    endm drawPixel_implicit

    return macro
    mov ah,04Ch
    int 21h
    endm return


    getkeyboardStatus macro                                                 ;zf = 0 if a key pressed,  ax = 0 if no scan code is available otherwise ax=[ScanCode][ASCII],  does not interrupt the program.
        push ax 
            mov ah, 1
            int 16h
        pop ax
    endm getKeyboardStatus

    readKey macro                                                           ;halts program until a key is present in the keyboard buffer to consume,  reads the scan code on Ah and the ASCII on AL.
        mov ah, 0
        int 16h
    endm readKey

    checkMousePointer macro                                                 ;cx,  dx has the position,  bx is 1 in case of a click. 
        mov ax, 3
        int 33h
    endm checkMousePointer


    blankScreen macro color,  from_x,  to_x                                     ;from,  to indicates the range on x-axis
        mov ah, 06                                                          ;Scroll (Zero lines anyway)
        mov al, 00h                                                         ;to blank the screen
        mov bh, color                                                       ;color to blank the screen with
        mov ch,  0h                                                         ;0 to 24 (text mode is 80x25)
        mov cl, from_x 
        mov dh,  24
        mov dl, to_x
                                                                            ;to the end of the screen
        int 10h
    endm blankScreen 

    notificationBar macro color,  from_y,  to_y                                 ;from,  to indicates the range on y-axis,  this uses the scroll interrupt as the previous macro
        mov ah, 06                                                          ;Scroll (Zero lines anyway)
        mov al, 0h                                                          ;to blank the screen
        mov bh, color                                                       ;color to blank the screen with
        mov ch, from_y                                                        ;Takes the who
        mov cl, 0h
        mov dh, to_y
        mov dl, 79                                                          ;(text mode is 80x25)
        int 10h
    endm notificationBar
    
    clearSection macro color,  from_x,  to_x, from_y, to_y, scroll   ;from,  to indicates the range on y-axis,  this uses the scroll interrupt as the previous macro
        mov ah, 06                                                          ;Scroll (Zero lines anyway)
        mov al, scroll                                                      ;to blank the screen
        mov bh, color                                                       ;color to blank the screen with
        mov ch, from_y                                                      ;Takes the who
        mov cl, from_x
        mov dh, to_y
        mov dl, to_X                                                        ;(text mode is 80x25)
        int 10h
    endm clearSection

    resetMouse macro
        mov  ax,  0000h                                                     ;reset mouse
        int  33h       
    endm resetMouse
    
    showMouse macro
        mov  ax,  0001h                                                     ;show mouse
        int  33h
    endm resetMouse

    checkDifference macro A, B, C                                           ;checks if A-B=C and yields 0 if that's true
    push ax
                mov ax, A
                sub ax, B
                cmp ax, C
    pop ax
    endm checkDifference
        
    getSystemTime macro
        mov ah, 2ch
        int 21h                                                             ;gets the current time.
    endm getSystemTime

    checkTimePassed macro previous_time                                     ;CH = hour CL = minute DH = second DL = 1/100 seconds
        getSystemTime
        cmp dl, previous_time                                               ;checks if a centisecond has passed and returns zero in that case
    endm checkTimePassed

    shieldControlFirst macro P_y,  upKey,  downKey                          ;Takes the dimension that we would like to control,  and the two keys using for controling that dimension
        local Read,  movesUp,  movesDown,  resetPositionHigh,  resetPositionLow,  None
        ;Check if any key is pressed,  if yes then check if it's the specified  upkay/down key for the former move up and for the latter move down,  check collisions with upper and lower boundaries for each.
                                                            ;else key was pressed
            cmp Ah, upKey                                                   ;Left
            JE movesUp
            cmp Ah, downKey                                                 ;Right
            JE movesDown
            JMP None                                                        ;Do nothing if any other key was pressed.


        movesUp:
            mov ax, P_Velocity_R
            sub P_y,  ax
            ;Check collisions with y=0
            cmp P_y, 0
            Jl resetPositionHigh
            JMP None

        movesDown:
            mov ax, P_velocity_R
            add P_y,  ax
            ;Check collisions with y=windowHeight-shieldHight
            cmp P_y, 150
            JG resetPositionLow
            JMP None

        resetPositionHigh:
            ;Attempt to surpass y=0: reset position to y=0
            mov ax, 0
            mov P_y, ax
            JMP None

        resetPositionLow:
            ;Attempt to surpass y=200 (the bottom pixel): reset position to y=200 
            mov ax, 150                                                     ;WindowHeight-ShieldHeight (Since we're dealing with the top left pixel of the shield)
            mov P_y, ax
            JMP None

        None:
        
    endm shieldControlFirst 


    shieldControlSecond macro P_y,  upKey,  downKey                         ;Replicates the function above but for the left shield
        local Reads,  movesUps,  movesDowns,  resetPositionHighs,  resetPositionLows,  Nones

            cmp Ah, upKey
            JE movesUps
            cmp Ah, downKey 
            JE movesDowns
            JMP Nones 


        movesUps:
            mov ax, P_Velocity_L
            sub P_y,  ax
            cmp P_y, 0
            Jl resetPositionHighs
            JMP Nones

        movesDowns:
            mov ax, P_velocity_L
            add P_y,  ax
            cmp P_y, 150
            JG resetPositionLows
            JMP Nones

        resetPositionHighs:
            mov ax, 0
            mov P_y, ax
            JMP Nones

        resetPositionLows:
            mov ax, 150 
            mov P_y, ax
            JMP Nones

        Nones:
        
    endm shieldControlSecond

    checkMouseRegion macro from_x, to_x, from_y, to_y                       ;Given a rectange, this tells you whether the mouse is on it or not using its cx, dx coordinates.
        local itsOver
            cmp cx, from_x
            jb itsOver
            cmp cx, to_x
            ja itsOver
            cmp dx, from_y
            jb itsOver
            cmp dx, to_y
            ja itsOver
            xor ax, ax
        itsOver:
    endm checkMouseRegion




    Logo macro y,  x 
    local whileLogo                                                        ;Loops on the logo and draws it pixel by pixel
        mov ah, 0ch
        mov bx,  offset logoFront
    whileLogo:
       drawDynamicPixel [bx], [bx+1], [bx+2],  y,  x
       add bx, 3
       cmp bx, offset logoFrontSize                                       ;Time to end the loop whenever the offset is outside the image.
    JNE whileLogo
    endm Logo
    

    staticShipLeft macro y,  x                                            ;Loops on the left ship and draws it
        local whileShipBeingDrawn
        mov ah, 0ch
        mov bx,  offset shipLeft
        whileShipBeingDrawn:
            drawDynamicPixel [bx], [bx+1], [bx+2],  y,  x
            add bx, 3
            cmp bx, offset shipLeftSize
        JNE whileShipBeingDrawn
    endm staticShipLeft
       
    staticShipRight macro y,  x                                          ;Loops on the right ship and draws it
        local whileShipisBeingDrawn
        mov ah, 0ch
        mov bx,  offset shipRight
        whileShipisBeingDrawn:
            drawDynamicPixel [bx], [bx+1], [bx+2],  y,  x
            add bx, 3
            cmp bx, offset shipRightSize
        JNE whileShipisBeingDrawn
    endm staticShipRight
    
    getCurrentMinute macro
        mov ah, 2ch
        int 21h                                                         ;gets the current time
        mov minutes, cl
    endm getCurrentMinute

    dynamicBalls macro                                                  ;Loops on each ball, draws it and then moves it.
            mov bx, 0h
            ballDynamics:       
                mov currentBallIndex, bx
                call moveBall
                call checkDestroyedCount
                call drawBall
                add bx, 2                                               ;counter
                cmp bx, ballCount                                       ;size of array              
            jl ballDynamics
    endm dynamicBalls

    Waves macro
    mov bx, 0
        waveInAction:
            call dynamicWave                                            ;Draws the wave
            moveWaves                                                   ;Moves the wave
            add bx,2
            cmp bx, waveCount
        jnz waveInAction
    endm Waves

    moveWaves macro
    local Reflect, Aurevior
		;move the wave by adding differential changes in position
        mov ax, Wv_x+bx 
		add [bx+W_x], ax
        ;if the wave is on the left shield border, then reflect it.             
		mov ax, Pl_x
        add ax, P_width
		CMP  [bx+W_x], ax                         
		JL Reflect  
        ;if the wave is on the right shield border, then reflect it
		mov ax, Pr_x               
		SUB ax, waveWidth
		CMP [bx+W_x], ax	         
		JG Reflect

        jmp AuRevior
        Reflect:
            Neg Wv_x+bx
        Aurevior:
        call checkRightShieldImpact
        call checkLeftShieldImpact
    ;ret
    endm Waves ;endp
    

    levelSelection macro
        videoMode 13h
        blankScreen 0h, 0, 4fh
        setTextCursor 10, 10                       ;Set Cursor for level one message
        print levelOneMessage
        setTextCursor 10, 12                       ;Set Cursor for level one message
        print levelTwoMessage
        resetMouse
        showMouse
        getUserChoice:                              ;get the player's choice of levels
            checkMousePointer
            cmp bx, 1
            jne checkOnceAgain
            shr cx, 1                                ;To accomodate to the 640x200 used by the mouse interrupt
            checkMouseRegion  45, 305, 80, 90        ;Checking if mouse click was on the first level
            cmp ax, 0
            Jne checkLevelTwo
            JMP LevelOne
            checkLevelTwo:
            checkMouseRegion 45, 305, 95, 105
            cmp ax, 0
            Jne checkOnceAgain
            JMP LevelTwo
        checkOnceAgain:
            getkeyboardStatus
            JZ getUserChoice                            ;No key was pressed
            readKey
            cmp ah, 02                                  ;scancode for 1
            JZ far ptr  LevelOne
            cmp ah, 03                                  ;scanecode for 2
            JZ far ptr LevelTwo
            jmp getUserChoice
    endm levelSelection 

    timeToSwap macro List1, List2, len ;Swaps two lists together (so we can choose the correct parameters depending on the level)
        local whileCx
        mov bx, 0
        whileCx:
            push list1+bx
            push list2+bx
            pop list1+bx
            pop list2+bx
        add bx,2
        cmp bx,len
        jnz whileCx
    endm timeToSwap
    
        timeToCopy macro List1, List2, len ;Copy from list1 to list 2
        local whileEx
        mov bx, 0
        whileEx:
            push list1+bx
            pop list2+bx
        add bx,2
        cmp bx,len
        jnz whileEx
        endm timeToCopy

    setBaudRate macro MSByte, LSByte
    ;Set Divisor Latch Access Bit
        mov dx, 3fbh                         ;Line Control Register
        mov al, 10000000b                    
        out dx, al                           ;Telling the Line Control Register its time to use 3f9h as an MSB to the divisor value that sets the baud rate.

    ;Set LSB byte of the Baud Rate Divisor Latch register.
        mov dx, 3f8h
        mov al, LSByte                       ;configuration of LSB line			
        out dx, al

    ;Set MSB byte of the Baud Rate Divisor Latch register.
        mov dx, 3f9h
        mov al, MSByte                      ;configuration of MSB line
        out dx, al       
    endm setBaudRate

    setProtocol macro protocol              ;e.g. 0:Access to Communication, 0:Set Break disabled, 011:Even Parity, 0:One Stop Bit, 11:8bits
        mov dx, 3fbh
        mov al, protocol
        out dx, al
    endm setProtocol

    sendByte macro happyByte                    ;The byte to be sent.
        local whileHolding
        mov dx , 3FDH                           ;Line Status Register
        whileHolding: 
            In al , dx                          ;Read Line Status , to guarantee that the holder register is empty
            test al , 00100000b                 ;If zero then it's not empty, otherwise:
            JZ whileHolding      
        mov dx , 3F8H                           ;Transmit data register
        mov al, happybyte
        out dx , al
    endm sendByte

    receiveByte macro freshByte         ;The byte to be received would be in freshByte, the Restart tells it where to go in case data isn't ready to be received.       
        local whileNotDataReady, Reset
        mov dx , 3FDH                           ;Line Status Register
        whileNotDataReady:
            in al, dx
            test al, 1                          ;In fact is 00000001b
            JZ  Reset                         ;Not ready, otherwise: 
            mov dx, 3F8H
            in al, dx
            mov freshByte, al
            Reset:
            Mov al, 0ffh                        ;In case not ready put 0ffh in al (flag)
    endm receiveByte
    
    receiveByteG macro freshByte         ;The byte to be received would be in freshByte, the Restart tells it where to go in case data isn't ready to be received.       
        local whileDataNotReady
        mov dx , 3FDH                           ;Line Status Register
        whileDataNotReady:
            in al, dx
            test al, 1                          ;In fact is 00000001b
            JZ  whileDataNotReady                ;Not ready, otherwise: 
            mov dx, 3F8H
            in al, dx
            mov freshByte, al
    endm receiveByteG
