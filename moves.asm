 .MODEL SMALL
    .STACK 64


.DATA 
	
	WINDOW_WIDTH DW 140h   ;the width of the window (320 pixels)
	WINDOW_HEIGHT DW 0C8h  ;the height of the window (200 pixels)
	WINDOW_BOUNDS DW 6     ;variable used to check collisions early
	BALLX dw 0AH,45H,65h 
    BALLY dw 0AH,45H,65h
	TIME_AUX DB 0 ;variable used when checking if the time has changed
	
	BALL_X DW 0Ah ;X position (column) of the ball
	BALL_Y DW 0Ah ;Y position (line) of the ball
	BALL_SIZE DW 04h ;size of the ball (how many pixels does the ball have in width and height)
	BALL_VELOCITY_X DW 05h ;X (horizontal) velocity of the ball
	BALL_VELOCITY_Y DW 02h ;Y (vertical) velocity of the ball
   VAR1 DW ?
   VAR2 DW ?


.CODE 

	MAIN PROC FAR
      MOV         AX,@DATA
	 mov         ds,ax
	   
		
		CALL CLEAR_SCREEN
         
      
          mov cx,3h  
          mov bp,0h
                        Drawnewball: 
                                
                            lea si,BALLX
                            lea di,BALLY
                        try: 
                         mov VAR1,si
                         mov var2,di
                         CALL MOVE_BALL 
                          cmp bp,0
						  je firstindex
						  cmp bp,1
						  je secondindex
						  cmp bp,2
						  je thridindex
						 firstindex:mov BALLX[0],si
						            MOV BALLY[0],di
									JMP EXCHNAGE
						 secondindex:MOV BALLX[1],si
						           	 MOV BALLY[1],di
									 JMP EXCHNAGE
						 thridindex: MOV BALLX[2],si
						            MOV BALLY[2],di
									JMP EXCHNAGE					  
                         EXCHNAGE:mov si,var1
                                 mov di,var2
                                 add si,2h
                                 add di,2h
                             inc bp
                             cmp bp,3h               
                             jl try
                         CALL CLEAR_SCREEN    
                         mov bp,0           
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
                            inc bp
                            cmp bp,3h          
                            jL try1
                            mov bp,0h
                            lea si,BALLX
                            lea di,BALLY
                            Jmp try
		
		; CHECK_TIME:
		
		; 	MOV AH,2Ch ;get the system time
		; 	INT 21h    ;CH = hour CL = minute DH = second DL = 1/100 seconds
			
		; 	CMP DL,TIME_AUX  ;is the current time equal to the previous one(TIME_AUX)?
		; 	JE CHECK_TIME    ;if it is the same, check again
		; 	;if it's different, then draw, move, etc.
			
		; 	MOV TIME_AUX,DL ;update time
			
		; 	;CALL CLEAR_SCREEN
			
		; 	CALL MOVE_BALL
		; 	CALL DRAW_BALL 
			
		; 	JMP CHECK_TIME ;after everything checks time again
		
		; RET
	MAIN ENDP
	
	MOVE_BALL PROC NEAR
     
		
		MOV AX,BALL_VELOCITY_X    
		ADD [si],AX             ;move the ball horizontally
		
		MOV AX,WINDOW_BOUNDS
		CMP  [si],AX                         
		JL NEG_VELOCITY_X         ;BALL_X < 0 + WINDOW_BOUNDS (Y -> collided)
		
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP [si],AX	          ;BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS (Y -> collided)
		JG NEG_VELOCITY_X
		
		
		MOV AX,BALL_VELOCITY_Y
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
			NEG BALL_VELOCITY_X   ;BALL_VELOCITY_X = - BALL_VELOCITY_X
			RET
			
		NEG_VELOCITY_Y:
			NEG BALL_VELOCITY_Y   ;BALL_VELOCITY_Y = - BALL_VELOCITY_Y
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


END MAIN
  
