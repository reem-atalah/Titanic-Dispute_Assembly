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
         
         Check: mov ah,2ch
                     int 21h ; CH = hour CL = minute DH = second DL = 1/100 seconds
                     CMP DL,Time
                     je Check
                     mov Time,dl
		 			CALL CLEAR_SCREEN  
                     
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
  
