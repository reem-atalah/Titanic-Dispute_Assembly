
.model small
  stack 64

.Data
TIME_AUX DB 0 ;variable used when checking if the time has changed
Ball_x Dw 0Ah
Ball_y DW 0Ah
Ball_size DW 08h 
V_X DW 02h   ;velocity in X
V_y DW 01h   ;velocity in Y
WINDOW_WIDTH DW 140h   ;the width of the window (320 pixels)
WINDOW_HEIGHT DW 0C8h  ;the height of the window (200 pixels)
WINDOW_BOUNDS DW 6     ;variable used to check collisions early
BALL_ORIGINAL_X DW 0A0h              ;X position of the ball on the beginning of a game
BALL_ORIGINAL_Y DW 64h               ;Y position of the ball on the beginning of a game

PADDLE_LEFT_X DW 0Ah
	PADDLE_LEFT_Y DW 0Ah
	
	PADDLE_RIGHT_X DW 130h
	PADDLE_RIGHT_Y DW 0Ah
	
	PADDLE_WIDTH DW 05h
	PADDLE_HEIGHT DW 1Fh
	PADDLE_VELOCITY DW 05h
.Code

DRAW_PADDLES PROC 
		
		MOV CX,PADDLE_LEFT_X ;set the initial column (X)
		MOV DX,PADDLE_LEFT_Y ;set the initial line (Y)
		
		DRAW_PADDLE_LEFT_HORIZONTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     ;CX = CX + 1
			MOV AX,CX          ;CX - PADDLE_LEFT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_LEFT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			MOV CX,PADDLE_LEFT_X ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			
			MOV AX,DX              ;DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_LEFT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_LEFT_HORIZONTAL
			
			
		MOV CX,PADDLE_RIGHT_X ;set the initial column (X)
		MOV DX,PADDLE_RIGHT_Y ;set the initial line (Y)
		
		DRAW_PADDLE_RIGHT_HORIZONTAL:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     ;CX = CX + 1
			MOV AX,CX          ;CX - PADDLE_RIGHT_X > PADDLE_WIDTH (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,PADDLE_RIGHT_X
			CMP AX,PADDLE_WIDTH
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
			MOV CX,PADDLE_RIGHT_X ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			
			MOV AX,DX              ;DX - PADDLE_RIGHT_Y > PADDLE_HEIGHT (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,PADDLE_RIGHT_Y
			CMP AX,PADDLE_HEIGHT
			JNG DRAW_PADDLE_RIGHT_HORIZONTAL
			
		RET
DRAW_PADDLES ENDP

DRAW_BALL   PROC
    MOV CX,Ball_x ;set the column (X)
	MOV DX,Ball_y ;set the line (Y)
    
    Drow_horizntal:
        MOV AH,0Ch ;set the configuration to writing a pixel
		MOV AL,01h ;choose  color
		MOV BH,00h ;set the page number 	
		INT 10h    ;execute the configuration
        Inc CX
        Mov aX,CX
        sub AX,Ball_x
        CMP AX,Ball_size
        jnG Drow_horizntal

        inc DX
        mov CX,Ball_x
        Mov aX,DX
        sub AX,ball_y
        CMP AX,Ball_size
        jnG Drow_horizntal       
    RET
            
DRAW_BALL   ENDP    

CLEAR PROC

        mov ax,0600h
        mov bh, 03h  ;set the color for the background
        mov cx,0
        mov dx,184fh
        int 10h
RET
CLEAR   ENDP
;;;;;;;;;;;;;;;;;;;;;


	MOVE_PADDLES PROC NEAR
		
		;left paddle movement
		
		;check if any key is being pressed (if not check the other paddle)
		MOV AH,01h
		INT 16h
		JZ CHECK_RIGHT_PADDLE_MOVEMENT ;ZF = 1, JZ -> Jump If Zero
		;JZ goOUT
		;check which key is being pressed (AL = ASCII character)
		MOV AH,00h
		INT 16h
		
		;if it is 'w' or 'W' move up
		CMP AL,77h ;'w'
		JE MOVE_LEFT_PADDLE_UP
		CMP AL,57h ;'W'
		JE MOVE_LEFT_PADDLE_UP
		
		;if it is 's' or 'S' move down
		CMP AL,73h ;'s'
		JE MOVE_LEFT_PADDLE_DOWN
		CMP AL,53h ;'S'
		JE MOVE_LEFT_PADDLE_DOWN
		JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		MOVE_LEFT_PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_LEFT_Y,AX
			
			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_LEFT_Y,AX
			JL FIX_PADDLE_LEFT_TOP_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_TOP_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
		MOVE_LEFT_PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_LEFT_Y,AX
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_LEFT_Y,AX
			JG FIX_PADDLE_LEFT_BOTTOM_POSITION
			JMP CHECK_RIGHT_PADDLE_MOVEMENT
			
			FIX_PADDLE_LEFT_BOTTOM_POSITION:
				MOV PADDLE_LEFT_Y,AX
				JMP CHECK_RIGHT_PADDLE_MOVEMENT
		
		
		;right paddle movement
		CHECK_RIGHT_PADDLE_MOVEMENT:
		;check if any key is being pressed (if not exit procedure)
		;MOV AH,01h
		;INT 16h
		;jz goOUT
		;check which key is being pressed
		;MOV AH,00h
		;INT 16h
		
		;if it is 'o' or 'O' move up
		CMP AL,6Fh ;'o'
		JE MOVE_Right_PADDLE_UP
		CMP AL,4Fh ;'O'
		JE MOVE_Right_PADDLE_UP
		
		;if it is 'l' or 'L' move down
		CMP AL,49h ;'l'
		JE MOVE_Right_PADDLE_DOWN
		CMP AL,6Ch ;'L'
		JE MOVE_Right_PADDLE_DOWN
		JMP goOUT
		
		MOVE_Right_PADDLE_UP:
			MOV AX,PADDLE_VELOCITY
			SUB PADDLE_Right_Y,AX
			
			MOV AX,WINDOW_BOUNDS
			CMP PADDLE_Right_Y,AX
			JL FIX_PADDLE_Right_TOP_POSITION
			JMP goOUT
			
			FIX_PADDLE_Right_TOP_POSITION:
				MOV PADDLE_Right_Y,AX
				JMP goOUT


		MOVE_Right_PADDLE_DOWN:
			MOV AX,PADDLE_VELOCITY
			ADD PADDLE_Right_Y,AX
			MOV AX,WINDOW_HEIGHT
			SUB AX,WINDOW_BOUNDS
			SUB AX,PADDLE_HEIGHT
			CMP PADDLE_Right_Y,AX
			JG FIX_PADDLE_Right_BOTTOM_POSITION
			JMP goOUT
			
			FIX_PADDLE_Right_BOTTOM_POSITION:
				MOV PADDLE_Right_Y,AX
				
		
		
		goOUT:
		RET
		
	MOVE_PADDLES ENDP



;;;;;;;;;;;;;;;;;;;;;
MOVE_BALL PROC NEAR
		
		;       Move the ball horizontally
		MOV AX,V_X    
		ADD BALL_X,AX                   
		
;       Check if the ball has passed the left boundarie (BALL_X < 0 + WINDOW_BOUNDS)
;       If is colliding, restart its position		
		MOV AX,WINDOW_BOUNDS
		CMP BALL_X,AX                    ;BALL_X is compared with the left boundarie of the screen (0 + WINDOW_BOUNDS)          
		JL RESET_POSITION                ;if is less, reset position
		
;       Check if the ball has passed the right boundarie (BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS)
;       If is colliding, restart its position		
		MOV AX,WINDOW_WIDTH
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_X,AX	                ;BALL_X is compared with the right boundarie of the screen (BALL_X > WINDOW_WIDTH - BALL_SIZE  - WINDOW_BOUNDS)  
		JG RESET_POSITION               ;if is greater, reset position
		
;       Move the ball vertically		
		MOV AX,V_Y
		ADD BALL_Y,AX             
		
;       Check if the ball has passed the top boundarie (BALL_Y < 0 + WINDOW_BOUNDS)
;       If is colliding, reverse the velocity in Y
		MOV AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y is compared with the top boundarie of the screen (0 + WINDOW_BOUNDS)
		JL NEG_VELOCITY_Y                ;if is less reverve the velocity in Y

;       Check if the ball has passed the bottom boundarie (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
;       If is colliding, reverse the velocity in Y		
		MOV AX,WINDOW_HEIGHT	
		SUB AX,BALL_SIZE
		SUB AX,WINDOW_BOUNDS
		CMP BALL_Y,AX                    ;BALL_Y is compared with the bottom boundarie of the screen (BALL_Y > WINDOW_HEIGHT - BALL_SIZE - WINDOW_BOUNDS)
		JG NEG_VELOCITY_Y		         ;if is greater reverve the velocity in Y
		
		
;       Check if the ball is colliding with the right paddle
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT
		
		MOV AX,BALL_X
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_X
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
		MOV AX,PADDLE_RIGHT_X
		ADD AX,PADDLE_WIDTH
		CMP BALL_X,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
		MOV AX,BALL_Y
		ADD AX,BALL_SIZE
		CMP AX,PADDLE_RIGHT_Y
		JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
		MOV AX,PADDLE_RIGHT_Y
		ADD AX,PADDLE_HEIGHT
		CMP BALL_Y,AX
		JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ;if there's no collision check for the left paddle collisions
		
;       If it reaches this point, the ball is colliding with the right paddle

		NEG V_X              ;reverses the horizontal velocity of the ball
		RET                              
			

;       Check if the ball is colliding with the left paddle
		CHECK_COLLISION_WITH_LEFT_PADDLE:
		; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
		; BALL_X + BALL_SIZE > PADDLE_LEFT_X && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH 
		; && BALL_Y + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT
		
		RET
		
		RESET_POSITION:                  
			CALL RESET_BALL_POSITION     ;reset ball position to the center of the screen
			RET
			
		NEG_VELOCITY_Y:
			NEG V_Y   ;reverse the velocity in Y of the ball (BALL_VELOCITY_Y = - BALL_VELOCITY_Y)
			RET
	MOVE_BALL ENDP

	RESET_BALL_POSITION PROC NEAR        ;restart ball position to the original position
		
		MOV AX,BALL_ORIGINAL_X
		MOV BALL_X,AX
		
		MOV AX,BALL_ORIGINAL_Y
		MOV BALL_Y,AX
		
		RET
	RESET_BALL_POSITION ENDP


	MAIN PROC FAR
    mov ax,@data
    mov ds,ax
		
		MOV AH,00h ;set the configuration to video mode
		MOV AL,13h 
		INT 10h     
		
		CALL CLEAR
		
		
           CHECK_TIME:
		
		  	MOV AH,2Ch ;get the system time
		  	INT 21h    ;CH = hour CL = minute DH = second DL = 1/100 seconds
			
		    CMP DL,TIME_AUX  ;is the current time equal to the previous one(TIME_AUX)?
		    JE CHECK_TIME    ;if it is the same, check again
			;if it's different, then draw, move, etc.
			
			MOV TIME_AUX,DL ;update time
       
             CALL CLEAR
            CALL MOVE_BALL
			CALL DRAW_BALL 

			CALL MOVE_PADDLES
			CALL DRAW_PADDLES
           
			
           
			
			JMP CHECK_TIME ;after everything checks time again
		;RET
	MAIN ENDP

END MAIN
