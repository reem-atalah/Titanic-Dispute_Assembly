;Dependencies
    include TML.asm                 ;Includ the Titanic Macro Library
        extrn ball: byte    
        extrn ballSize: word 
        extrn shield: byte 
        extrn P_height: word
        extrn P_Width: word
        extrn rightShield: byte
        extrn rightShieldSize: word 
        extrn wave: byte
        extrn waveWidth: word 
        extrn waveHeight: word 
        extrn shipLeft: byte 
        extrn shipLeftSize: word
        extrn shipLeftWidth: word
        extrn shipRight:byte
        extrn shipRightSize : word
        extrn shipRightWidth: word
        extrn logoFront: byte
        extrn logoFrontSize: word 
        extrn drawBall: far
        extrn drawShieldLeft: far
        extrn drawShieldRight: far
        extrn dynamicWave: far
        extrn MAINChAT:far
        public V_x, colorBall, colorShieldLeft, colorShieldRight, S_y, S_x, Pl_y, Pr_x, Pl_x, Pr_y, currentBallindex, W_y, W_x,UserName,playerName2
;____________________________________________________________________________________________________________________
;Let the code beign.

.286
.MODEL HUGE
.STACK 64   
.DATA
    ;Miscellaneous data variables
        screenMarginx DW 32                                         ;variable used to check collisions early
        screenMarginy DW 6                                          ;variable used to check collisions early
        destroyedCount DW 0                                         ;The double count 
        positionThreshold dw 7h                                     ;Used to free the ball from sticky collisions

    ;Ball Dynamics
        S_x dw 70, 240, 70, 240, 70, 240                            ;x position of the ball
        S_y dw 50, 150, 150, 50, 50, 150                            ;y position of the ball
        V_x dw 7H, 0fff9H, 7h, 0fff9h, 7h, 0fff9h                   ;Horizontal Velocity
        V_y dw 0H, 0H, 0h, 0h, 0h, 0h                               ;Vertical Velocity
        ;To keep track of multiple different balls
        colorBall db 0h
        currentBallIndex dw ? 
        ballCount dw 4h
        destroyedBallsCountHealth db 255
        ;Refresher Quantities (when any of the above is reset)
        Sx dw 70, 240, 70, 240, 70, 240                             ;x position of the ball
        Sy dw 160, 40, 40, 160, 150, 50                             ;y position of the ball
        Vx dw 7H, 0fff9H, 7h, 0fff9h, 7h, 0fff9h                    ;Horizontal Velocity
        Vy dw 0H, 0H, 0h, 0h, 0h, 0h                                ;Vertical Velocity

    ;LevelOne Temporary Variables:
        positionLowerBound dw 5
        Ve_x dw 5H, 0fffcH, 5h, 0fffch, 5h, 0fffch

    ;Data variables relating to the Shield (Pl (Left),  Pr(Right)):
        colorShieldLeft db 41
        colorShieldRight db  41
        Pl_x dw 40
        Pl_y dw 50
        Pr_x dw 250
        Pr_y dw 50
        P_Velocity_L dw 18                                           ;Velocities of the left and right shields respectively
        P_Velocity_R dw 18

    ;Relating to score
        scoreLeft DB 100
        scoreRight DB 100
    ;Relating to time
        minutes Db 0                                                  ;To check if a minute has passed
        Centiseconds db 0                                             ;To check if a centisecond has passed.

    ;Data Variables related to waves:
        W_x dw 80, 160, 100, 160, 100, 90, 170
        W_y dw 0, 25, 50, 75, 100, 125, 150
        waveCount dw 14
        ;Velocity parameters
        Wv_x dw 1, 0ffffh, 1, 0ffffh, 1, 0ffffh, 1
        Wv_y dw 0, 0, 0, 0, 0, 0, 0
;Graphics:
   

;Messages
    Msg db 20 dup(10, 13), 09h, "Please Enter Your Name:", 2 dup(10, 13), 09h, '$'
    UserName db 30, ?,  30 dup('$')
    playerName2 db 30, ?,  30 dup('$')
    sendChatMSG db 11 dup(10, 13), "you sent a chat invitation to ", '$'
    sendGameMSG db 11 dup(10, 13), "you sent a game invitation to ", '$'
    requestKeyMSG db 2 dup(10, 13), 09h, "PLease Enter Any Key To continue", '$'
    MSGFrist db 2 dup(10, 13), 09h, "PLease Try Again with Letter in Frist,  Press any Key To continue", '$'
    MSGLong db 2 dup(10, 13), 09h, "PLease Try Again with shoter name,  Press any Key To continue", '$'
    MSGshort db 2 dup(10, 13), 09h, "PLease Try Again with your name,  Press any Key To continue", '$'
    MSGSpecial db 2 dup(10, 13), 09h, "PLease Try Again Don't use Spcial char,  Press any Key To continue", '$'
    Msg3 db 7 dup(10, 13), 09h, "*To start chatting press F1", 2 dup(10, 13), 09h, "*To start game press F2", 2 dup(10, 13), 09h, "*To end the program press ESC", '$'
    levelOneMessage db "Level I - Calm Day", '$'
    levelTwoMessage db "Level II - Sea Storm", '$'
    Loses db ' lost:( ', '$'   
    Wins db ' has earned victory ^_^', '$'
    quitGame db 'Press any key to go the main menu', '$'
   sentinvitation db ?
   recevieinvition db 1h
   level db ?
   myflag db 1h
   


.Code
    MAIN PROC FAR 
    mov ax, @Data
    mov DS, ax
    TheBeginning:                               ;The screen at the very start of the game.
        setBaudRate 00h, 0ch
        setProtocol 00011011b
        videoMode 13h                           ;https://stanislavs.org/helppc/int_10.html click on set video modes for all modes
        blankScreen 0h, 0, 4fh
        Print MSG
        blankScreen 0h, 0, 0
        Logo 30, 30
        call inputValidation
        CALL sendandreceivename
        Print requestKeyMSG                     ;show message of continue 
        blankScreen 0h, 0, 0 
        readKey             ;get any key to continue
        videoMode 13h 
        Logo 30, 30
        Start:
        blankScreen 0h, 0, 4fh
        Print MSG3
        blankScreen 0h, 0, 7
        notificationBar 07, 15h, 18h 
       
        ;draw notification bar
        call menuNavigation                   ;The main menu
 videoMode 03h ;Text mode.
return
MAIN ENDP 
    

;Procedures relating to graphics:
   GameProc proc near
   
   cmp sentinvitation,3ch
   jnz x
   jmp y
   x:mov sentinvitation,0
   Jmp notchoice
   y:levelSelection
   jmp done
    notchoice:
    receiveByte level
    cmp level,02
    Jz LevelTwo1
    cmp level,01
    jnz notchoice
    LevelOne1:
        timeToSwap Wv_y, Wv_x, 14
        timeToSwap Ve_x,V_x, 12
        timeToCopy V_x, Vx, 12
        timeToSwap positionThreshold, PositionLowerBound, 2
     LevelTwo1: 
   done:                                              ;Default is level two, for level one we do necessary swapping first
   videoMode 13h
   initialtime:
    getCurrentMinute                                        ;Will be used to periodically shoot cannons, current minute is put in cl
    blankScreen 104, 0, 4fh
    whileTime:                                              ;while centisecond hasn't passed yet
        staticShipLeft 10, 320
        staticShipRight 10, 286 
        checkTimePassed Centiseconds
    JE whileTime                                             ;if a centisecond passes (won't be triggered for any less time)
        setTextCursor 10, 2                                  ;Set Cursor for position of leftscore
        ;displayNumber Minutes
        mov Centiseconds, dl                                ;centisecond(s) has passed update the time variable with the new time.
        call generateBallsWithTime
        blankScreen 104, 4, 35                              ;Color,  from,  to (on the x-axis)
        Waves
                                                       ;repeated calls to static waves
        call drawShieldLeft                                 ;Draw left shield
        call drawShieldRight                                ;Draw right shield
        call showHealth
        call scoreControl                                   ;Control the score
        dynamicBalls                                        ;Responsible for drawing and maintaining ball movement
       ;Controlling objects in the game. 
        cmp  sentinvitation,3ch
        jz rightrecevie   
        getKeyboardStatus
        JZ noKeyPressed                                     ;No key was pressed, check if any
            readKey
            cmp al,1Bh
            Jz closegame
            sendByte ah
            call leftShieldControl                          
            noKeyPressed:
                receiveByte ah
                cmp ah, 0ffh
                je ItsAFK
                cmp ah,1bh
                jz ExitmyGame
                call RightShieldControl
                ItsAFK:
                call gameOverScreen 
                jmp whileTime
                closegame:sendByte al
                 JMP ExitmyGame
        rightrecevie:        
        getKeyboardStatus
        JZ noKeyPressed1                                     ;No key was pressed, check if any
            readKey
           cmp al,1Bh
            Jz closegame2
            sendByte ah
            call rightShieldControl                          
            noKeyPressed1:
                receiveByte ah
                cmp ah, 0ffh
                je ItsAFK2
                cmp ah,1bh
                jz ExitmyGame
                call leftShieldControl
                ItsAFK2:
                call gameOverScreen                                             
            jmp whileTime
            closegame2:sendByte al
                   JMP ExitmyGame
    videoMode 03h ;Text mode. 
    return
    exitmygame:
       videoMode 03h ;Text mode.
      mov AH,4CH  ;end programm
       INT 21H
      ret
   GameProc ENDP 

rightShieldControl proc near
        shieldControlSecond Pl_y, 4Dh,4Bh                   ;33h,34h        ;control Pl_y up and down with a, s ;< >
ret
endp rightShieldControl

leftShieldControl proc near
        shieldControlFirst Pr_y, 4Dh, 4Bh                   ;control Pr_y up and down with right and left arrows.
        ret
endp leftShieldControl  
;description
; menuNavigation proc near
;         resetMouse
;         showMouse
;         getDecision:                      ;get the player's decision
;             checkMousePointer
;             cmp bx, 1
;             jne checkOnceMore
;             shr cx, 1                        ;The shift right here is so that we divide whatever cx we get from the mouse interrupt by two since it works with 640x200 instead of 320x200
;             ;Checking if mouse click was on exit game, then checking for chat then the game it self
;             checkMouseRegion  65, 305, 85, 95
;             cmp ax, 0
;             Jne checkGame
;             JMP ExitGame
;             checkGame:
;             checkMouseRegion 65, 305, 70, 80
;             cmp ax, 0
;             Jne checkChat
;             JMP theGame
;             checkChat:   
;             checkMouseRegion 65, 305, 55, 65
;             cmp ax, 0
;             Jne checkOnceMore
;             jmp Chat
;     checkOnceMore:

;             getkeyboardStatus
;             JZ getDecision ;No key was pressed
;             readKey
;             cmp ah, 3Bh                       ;scancode for F1
;             JZ  Chat
;             cmp ah, 3Ch                       ;scanecode for F2
;             JZ TheGame
;             cmp al, 1Bh                       ;asscii code for ESC
;             Jz ExitGame
;         jmp getDecision
;     TheGame:                        ;start the game
;         Print sendGameMSG
;         Print playerName2
;         readKey
;         Call GameProc
;         return
;     CHAT:
;         Print sendChatMSG
;         Print playerName2
;         readKey
;         Call MAINChAT
;         return
;     ExitGame: 
;     ret 
;     menuNavigation endp
    menuNavigation proc near             

       beginagain: getkeyboardStatus
        jnz send
        jmp recevie
         
       send:readKey
           cmp ah,3ch
           jz gosend
           cmp ah,3bh
           jz gosend
           cmp ah,01h
           jz gosend
           jmp recevie
         gosend:sendByte ah
               mov sentinvitation,ah
               cmp ah,3ch
                jz TheGame
                cmp ah,3bh
                jz chat
                jmp outofgame
             
      recevie: receiveByte  recevieinvition 
             cmp recevieinvition,0ffh
             je  beginagain
        readtani:   readKey
             cmp ah,recevieinvition
             je start1
             jmp readtani

     start1: cmp recevieinvition,3ch
        jz TheGame
         cmp recevieinvition,3bh
          jz chat
          jmp outofgame
   
     
    outofgame:
     videoMode 03h ;Text mode.
      mov AH,4CH  ;end programm
       INT 21H
    ret
    ;     receiveByte  recevieinvition    
    ;  compare: cmp recevieinvition,ah
    ;     je excute
       
    ;   readagian:  readKey   
    ;    cmp recevieinvition,1h
    ;     jnz compare
    ;   label12:  mov sentinvitation,ah
    ;             sendByte ah
    ;            jz excute

    ;   excute:
    ;       cmp ah, 3Bh                       ;scancode for F1
    ;         JZ  Chat
    ;         cmp ah, 3Ch                       ;scanecode for F2
    ;         JZ TheGame
    ;         cmp al, 1Bh                       ;asscii code for ESC
    ;         Jz ExitGame
    ;         jmp  readagian
           

    ;  readagain  :readKey 
    ;     receiveByte  recevieinvition    
    ;     cmp recevieinvition,ah
    ;     jz excute
    ;     mov sentinvitation,ah
    ;     sendByte ah
    ;     jmp checkmykey
    ;     hgbrab:receiveByte  recevieinvition   ;; receive 
    ;     cmp recevieinvition,3ch ;  recevie f2
    ;     jnz readagain
    ;     readtani:readKey
    ;     cmp ah,recevieinvition
    ;     jnz readtani
    ;     jmp  checkmykey
      
    ;     bra: 
    ;     jmp thegame 
    ;     bra2:
    ;     jmp Chat
  
            
    TheGame:                        ;start the game
        Print sendGameMSG
        Print playerName2+2
        readKey
        Call GameProc
        return
    CHAT:
        Print sendChatMSG
        Print playerName2+2
        readKey
        Call MAINChAT
        return
    ExitGame: 
    ret 
    menuNavigation endp



 GenerateBallsWithtime PROC near                ;Need comments
    ;try to compare with big time to generate slowly
    getSystemTime
        cmp minutes, cl                        ;cl has the current minute
        je break
        mov minutes, CL
        mov ax, 8h
        cmp ballCount, ax
     jl changeballcount
     mov ax, 0Ch
     mov ballCount, ax
     jmp break  

     changeballcount: 
        mov ax, 8h
        mov ballCount, ax
      break:
      
      RET
    
  GenerateBallsWithtime ENDP 


checkDestroyedCount proc near
    mov ah, 2Ch               ;get Time
    int 21h
    mov al, dh                
    mov ah, 00h
    mov dh, 6h
    div dh
    mov al, ah               ;get random number between 1, 6 to get random positon
    mov cl, 2h
    mul cl
    ;  displayNumber al
    mov ah, 00h
    mov cx, ax 
    
    ;displayNumber bl                       
    mov ax, destroyedCount
    cmp ax, ballcount
    JNE Endd
        mov ax, 2h
        sub destroyedCount, ax

        mov bx, 0h
        mov ax, Sy+bx                 ;get random value from array Sy
        mov bx, currentBallIndex  
        mov S_y+bx, ax                 ;but it in our original array!

        mov bx, cx
        mov ax, Sx+bx
        mov bx, currentBallIndex  
        mov S_x+bx, ax

        mov bx, cx
        mov ax, Vy+bx
        mov bx, currentBallIndex  
        mov V_y+bx, ax
        
        mov bx, cx
        mov ax, Vx+bx
        mov bx, currentBallIndex  
        mov V_x+bx, ax
    Endd:
    ret
checkDestroyedCount endp
; sendmyname proc near
;   mov cl,UserName+1
;   mov ch,0
;   mov si,offset UserName+2

;   sendstring:
;     mov al,[si]
;      sendByte al
;      inc si
;      dec cx
;      cmp cx,0
;      jnz sendstring
;      sendByte 2ah
;      ret

; sendmyname endp
; receviemyname proc near
;   mov si,offset playerName2+2
;   receviestring:
;      receiveByte al
;      cmp al,0ffh
;      jz receviestring
;       cmp al,2ah
;       jz outofrec
;       mov [si],al
;      inc si
;      jmp  receviestring
;       outofrec:
;      ret
     
; receviemyname endp
;description
sendandreceivename PROC near
      mov si,offset UserName+2
      mov di,offset playerName2+2
      mov cl, userName+1
      mov ch,0
     AGAIN1: 
        In al , dx ;Read Line Status , A byte is input into AL from the port addressed by DX
        test al , 00100000b  ;test: AND without changing values
        JZ Recivestring ;Not empty (This line may need to change)
       cmp cx,0 ;If empty put the VALUE in Transmit data register
        jz flagstring
        mov dx , 3F8H ; Transmit data register
        mov al,[si]
        out dx , al
        inc si
        dec cx
    
        jmp Recivestring

    ;Receiving a value
    ;Check that Data is Ready
    flagstring:
       mov dx,3f8h
       mov al,2ah
      out dx , al
      mov myflag,0h

    Recivestring:
  
    mov dx , 3FDH ; Line Status Register
    CHK1: in al , dx
        test al , 1
        JZ  AGAIN1
        mov dx , 03F8H
        in al , dx
        cmp al,2ah
        jz checkmyflag
        mov [di],al
        inc di
        JMP AGAIN1

    checkmyflag:  cmp myflag,0H
             jnz    AGAIN1   
        ret
    
sendandreceivename ENDP
;Algorithm: 



 ;Procedures relating to motion and collisions
    inputValidation proc near
        readString UserName             ;get the player name
        mov al, 0h
        cmp UserName+1, al               ;check if it is empty string
        jz tooShort
        mov al, 0Fh
        cmp UserName+1, al               ; check if it is larger than 15 char
        jg tooLong
        ;;;;;;;;;;
        mov cl, UserName+1
        mov ch, 00h
        mov SI, offset UserName+2
        LoopName:                       ;check if there is special char
        ;mov bx, [SI]
        mov al, 30h
        cmp [SI], al
        jl special
        mov al, 7Ah
        cmp [SI], al
        jg special

        mov al, 40h
        cmp [SI], al
        je special

        mov al, 5Ah
        cmp [SI], al
        jle checkNext
        mov al, 61h
        cmp [SI], al
        jl special
    checkNext:
    inc SI
    loop LoopName
        mov al, 30h                ;check if the first char not a number
        cmp UserName+2, al
        jl okay
        mov al, 39h
        cmp UserName+2, al
        jle Frist
        jmp okay

        special:
        Print MSGSpecial
        readKey                         ;get any key to continue
        jmp TheBeginning

        Frist:
        Print MSGFrist
        readKey                         ;get any key to continue
        jmp TheBeginning

        tooLong:
        Print MSGLong
        readKey                         ;get any key to continue
        jmp TheBeginning

        tooShort:
        Print MSGshort
        readKey                         ;get any key to continue
        jmp TheBeginning

        okay:                           ;Name is Valid
        ret 
    inputValidation endp

  checkRightShipCollisions proc near
        ;This basicaly implements if(ball.isWithin(rightScreenMargin, rightScreenMargin-Threshold))
        cmp scoreRight, 0
        JNG goOut                               ;Do nothing if he's already dead

        mov bx, currentBallIndex  
        mov ax,  320                          
        sub ax, screenMarginx
        sub ax, ballSize
        cmp ax, [bx+S_x]
        JG checktheOtherBoundary
        JMP goOut

        checkTheOtherBoundary:
        mov ax,  320                          
        sub ax, screenMarginx
        sub ax, ballSize
        sub ax, [positionthreshold]
        cmp ax, [bx+S_x]
        JG goOut 

        mov ah, 10                              ;Take 10 down from the ships HP
        sub scoreRight, ah
        ret
    goOut:                                      ;Do nothing if none is satisfied
    ret
    checkRightShipCollisions endp

  checkLeftShipCollisions proc near
    ;This basicaly implements if(ball.isWithin(leftScreenMargin, leftScreenMargin+Threshold))

        cmp scoreLeft, 0
        JNG timeToLeave                     ;Do nothing if its already sunken

        mov bx, currentBallIndex
        mov ax, screenMarginx
        cmp  [bx+S_x], ax
        JG checktheOtherSide
        JMP timeToLeave

        checkTheOtherSide:
        mov ax, screenMarginx
        add ax, positionThreshold
        cmp  [bx+S_x], ax
        JG timeToLeave
        
        mov al, 10                      ;Take 10 down from the ships HP
        sub scoreLeft, al
    timeToLeave:                        ;Do nothing if none is satisfied
    ret
    checkLeftShipCollisions endp

    checkLeftShieldCollisions proc near
        ;Check collisions with the left shield and do necessary action based on that
        ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
        ; M is the left shield and N is the ball     
        mov bx, currentBallIndex                            
        mov ax, Pl_x
        add ax, P_width
        cmp ax, [bx+S_x]
        JNG bye ;first condition not satisified,  no need to check anymore.

        mov ax, [bx+S_x]
        add ax, ballSize
        cmp ax, Pl_X
        JNG bye       ;second condition

        mov ax, Pl_y
        add ax, P_height
        cmp ax, [bx+S_y]
        JNG bye

        mov ax, [bx+S_y]
        add ax, ballSize
        cmp ax, Pl_y
        JNG bye
        ;Reaching this point indicates that the conditions are satisified.
        NEG V_x+bx
        mov ax, positionThreshold
        add S_x+bx, ax
        ;And thus we reflect the ball about the horizontal axis.
        ;If V_y is zero,  i.e. a fresh cannon,  then the reflective power of the shield gives it some vertical velocity
        cmp V_y+bx, 0 
        jnz checkUp
        inc V_y+bx ;some vertical velocity

        checkUp:
        ;If the ball touches the higher part of the shield,  the ball is reflected such that (Vx,  Vy) becomes (-Vx,  -Vy)
        ;mov ax, Pl_Y
        ;cmp S_y, ax
        ;jg checkDown
        ;neg V_y
        ;If the ball touches the lower part of the shield,  the ball is reflected such that (Vx,  Vy) becomes (-Vx,  -Vy)
        ;checkDown:
        ;mov ax, Pl_y
        ;add ax, P_height
        ;mov bx, ballsize
        ;add bx, S_y
        ;cmp bx, ax
        ;jng bye
        ;neg V_y
        bye:
        ret

    checkLeftShieldCollisions endp

    checkrightShieldCollisions proc near
        ;Check collisions with the right shield and do necessary action based on that
        ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
        ; M is the ball and N is the right shield
        mov bx, currentBallIndex                                  
        mov ax, [bx+S_x]
        add ax, ballSize
        cmp ax, Pr_x
        JNG exit ;first condition not satisified,  no need to check anymore.

        mov ax, Pr_X
        add ax, P_width
        cmp ax, [bx+S_x]
        JNG exit ;second condition

        mov ax, [bx+S_y]
        add ax, ballSize
        cmp ax, Pr_y
        JNG exit

        mov ax, Pr_y
        add ax, P_height
        cmp ax,  [bx+S_y]
        JNG exit
        ;Reaching this point indicates that the conditions are satisified.
        mov ax, positionThreshold
        sub S_x+bx, ax
        NEG V_x+bx
        ;And thus we reflect the ball about the horizontal axis.
        ;If V_y is zero,  i.e. a fresh cannon,  then the reflective power of the shield gives it some vertical velocity
        cmp V_y+bx, 0 
        jnz skip
        inc V_y+bx ;some vertical velocity
        skip:
        ;If the ball touches the higher part of the shield,  the ball is reflected such that (Vx,  Vy) becomes (-Vx,  -Vy)
        ;mov ax, Pr_Y
        ;cmp S_y, ax
        ;jg next
        ;neg V_y
        ;If the ball touches the lower part of the shield,  the ball is reflected such that (Vx,  Vy) becomes (-Vx,  -Vy)
        ;next:
        ;mov ax, Pr_y
        ;add ax, P_height
        ;mov bx, ballsize
        ;add bx, S_y
        ;cmp bx, ax
        ;jng exit
        ;neg V_y
        exit:
        ret
    checkrightShieldCollisions endp

checkLeftShieldImpact proc near ;deals with wave collisions
        ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
        ; M is the left shield and N is the wave   
        mov ax, Pl_x
        add ax, P_width
        cmp ax, [bx+W_x]
        JNG bypass ;first condition not satisified,  no need to check anymore.

        mov ax, [bx+W_x]
        add ax, waveWidth
        cmp ax, Pl_X
        JNG bypass      ;second condition

        mov ax, Pl_y
        add ax, P_height
        cmp ax, [bx+W_y]
        JNG bypass

        mov ax, [bx+W_y]
        add ax, waveHeight
        cmp ax, Pl_y
        JNG bypass
        ;Reaching this point indicates that the conditions are satisified.
        mov ax, positionThreshold ;reflect the wave back with force
        add W_x+bx, ax
        ;now someone's score must go down
        dec scoreLeft
        dec scoreLeft
        ;Besides losing health, the wave slows down the shield, a slow shield is blue in color.
        cmp colorshieldleft, 53
        JE speedbackup
        ;If it's already slowed down, speed it back up upon hitting the wave.
        slowDown:
            mov ah, 53
            mov colorShieldLeft, ah
            mov ax,9
            sub P_Velocity_L, ax
            JMP Bypass
        speedBackUp:
            mov ah, 41
            mov colorShieldLeft, ah
            mov ax,9
            add P_Velocity_L, ax
        bypass:
        ret

    checkLeftShieldImpact endp

    checkrightShieldImpact proc near
        ;(M.x+M.width>=N.x && M.x<=N.x+N.width && M.y+M.height>=N.y && M.y<=N.y+N.height) indicates a collision as we've demonstrated below (if any isn't satisified we escape)
        ; M is the ball and N is the right shield
        mov ax, [bx+W_x]
        add ax, waveWidth
        cmp ax, Pr_x
        JNG bounce ;first condition not satisified,  no need to check anymore.

        mov ax, Pr_X
        add ax, P_width
        cmp ax, [bx+W_x]
        JNG bounce ;second condition

        mov ax, [bx+W_y]
        add ax, waveHeight
        cmp ax, Pr_y
        JNG bounce

        mov ax, Pr_y
        add ax, P_height
        cmp ax, [bx+W_y]
        JNG bounce
        ;Reaching this point indicates that the conditions are satisified.
        mov ax, positionThreshold ;Since it's negated anyway from the main function, we just reflect the wave back with force
        sub W_x+bx, ax
        ;Now someone's score must go down
        dec scoreRight
        dec scoreRight
        cmp colorShieldRight, 53
        JZ speedItBackUp
        slowItDown:
            mov ah, 53
            mov colorShieldRight, ah
            mov ax,9
            sub P_Velocity_R, ax
            JMP Bounce
        speedItBackUp:
            mov ah, 41
            mov colorShieldRight, ah
            mov ax,9
            add P_Velocity_R, ax
        bounce:
        ret

    checkrightShieldImpact endp

	moveBall PROC NEAR
     
		mov bx,  currentBallIndex
		mov ax, V_x+bx
        ;Add V_x to S_x (done every centisecond >> velocity)  
		add [bx+S_x], ax             ;move the ball horizontally

        ;Check vertical walls and do necessary action if colliding with any
		mov ax, screenMarginx
		CMP  [bx+S_x], ax                         
		JL Destroy                  ;S_x < 0 + screenMargin indicates a collision

		mov ax, 320                 ;Horizontal resolution
		SUB ax, ballSize
		SUB ax, screenMarginx
		CMP [bx+S_x], ax	        ;S_x > 320 - ballSize  - screenMargin indicates a collision
		JG Destroy
		
		
		mov ax, V_Y+bx
		add [bx+S_y], ax             ;move the ball vertically,  and reverse velocity on impact with walls.
		
		mov ax, screenMarginy
		CMP [bx+S_y], ax   
		JL negateV_y                          
		
		mov ax, 200	                ;Vertical Resolution
		SUB ax, ballSize
		SUB ax, screenMarginy
		CMP [bx+S_y], ax
		JG negateV_y		  
		
		jmp goodBye
		
		negateV_y:
			NEG V_y+bx              ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
			JMP goodBye

        Destroy:
            mov ax, 0
            cmp V_x+bx, ax
            JE goodBye ;if the ball has zero velocity then its already destroyed.
            ;otherwise destroy it by zeroing its position and velocity,  and the drawBall procedure will take care of not drawing it.
            mov ax, 2
            add destroyedCount, ax  ;Increase the drestroyed count.
            mov ax, 0
            mov V_x+bx, ax
            mov V_y+bx, ax
            mov S_x+bx, ax
            mov S_y+bx, ax
        goodBye:
    call checkrightShieldCollisions
    call checkleftShieldCollisions
    call checkleftShipCollisions
    call checkRightShipCollisions
    ret
	moveBall ENDP

    scoreControl proc near
        setTextCursor 2, 1                       ;Set Cursor for position of destroyedCount
        print Username+2
        setTextCursor 2, 2                       ;Set Cursor for position of leftscore
        displayNumber scoreLeft                  ;draw leftscore
        setTextCursor 33, 1                       ;Set Cursor for position of rightscore
        print playerName2+2
        setTextCursor 33, 2                       ;Set Cursor for position of rightscore
        displayNumber scoreRight                 ;draw rightscore
    endp scoreControl

      showHealth proc near
        push bx
        mov bl,  ScoreLeft
        mov bh, 0
        cmp bx, 50
        JL drawRed                                  ;in case less than 50, draw make the hp bar red.
        drawHealthBar  40,  1,  49,  1,  bx         ;Takes x, y, color, height, width
        jmp checkTheOtherPlayer
        drawRed:
            drawHealthBar  40,  1,  41,  1,  bx
            ;mov colorshieldleft, 41                 ;change the shield color for the winning player.
            ;mov colorShieldRight, 0eh
        checkTheOtherPlayer:                                  ;Otherwise do the same check for the other health bar, note that bx has the actual score and bp has the starting position
            mov bl,  ScoreRight
            mov bh, 0
            mov bp, 280
            sub bp, bx
            cmp bx, 50
        jl drawReds
            drawHealthBar  bp,  1,  49,  1,  bx
        jmp endit
        drawReds:
            ;mov colorshieldleft, 0eh
            ;mov colorShieldRight, 41
            drawHealthBar  bp,  1,  41,  1,  bx
        endit:
            pop bx
        ret
    showhealth endp

gameOverScreen proc near

        cmp scoreRight, 0                         ;check if right lost the game
        JG LeftPlayerLoses
        RightPlayerLoses:
            blankScreen 104, 0, 4fh 
            setTextCursor 4, 6
            print Username+2
            setTextCursor 4, 8
            print Wins
            setTextCursor 4, 10
            print PlayerName2+2
            setTextCursor 4, 12
            print Loses        
            setTextCursor 4, 14
            Print quitGame
        readKey                                    ;take any button to quit game
        jz quitGameNow

        LeftPlayerLoses:
            cmp scoreLeft, 0                       ;check if left lost the game
            JG Bridge
            blankScreen 104, 0, 4fh
            setTextCursor 4, 6
            print playerName2+2
            setTextCursor 4, 8
            print Wins
            setTextCursor 4, 10
            print Username+2
            setTextCursor 4, 12
            print Loses
            setTextCursor 4, 14
            Print quitGame
        readKey
        jz quitGameNow

    Bridge:
    jmp whileTime
    
    quitGameNow:
    mov al, 100
    mov scoreLeft, al
    mov scoreRight, al
    mov bx,0
    mov [currentballindex],bx
    mov destroyedCount,bx
    ;Reseting the game to the default (level two)
        timeToSwap Wv_x, Wv_y, 14
        timeToSwap V_x,Ve_x, 12
        timeToCopy V_x, Vx, 12
        timeToSwap positionThreshold, PositionLowerBound, 2
    videoMode 13h
    jmp near ptr Start
    ret
    gameOverScreen endp
   
   

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
;           |________|              if M and N are the top-left local origin of the boxes,  we can write the above as:
;                                   1)M.x+M.width>=N.x
;                                   2)M.x<=N.x+N.width
;                                   3)M.y+M.height>=N.y
;                                   4)M.y<=N.y+N.height
;  