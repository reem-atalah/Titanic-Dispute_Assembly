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
 .MODEL SMALL
    .STACK 64


.DATA 
	
	Time DB 0 
    ;Timeafter db 10
	WINDOW_WIDTH DW 140h   ;the width of the window (320 pixels)
	WINDOW_HEIGHT DW 0C8h  ;the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6     ;variable used to check collisions early
	BALLX dw 0AH,45H,65h ,13h,20h,70h
    BALLY dw 0AH,01H,03h,10h,15h,24h
	TIME_AUX DB 0 ;variable used when checking if the time has changed
	VecloictyX dw 01h,01h,01h,01h,01h,01H
    VecloictyY dw 02h,02h,02h,02h,02h,02h
	BALL_X DW 0Ah ;X position (column) of the ball
	BALL_Y DW 0Ah ;Y position (line) of the ball
	BALL_SIZE DW 04h ;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 05h ;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h ;Y (vertical) velocity of the ball
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
                        	CALL DRAW_BALL
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
  
