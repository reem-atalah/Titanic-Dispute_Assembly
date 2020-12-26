
    .MODEL SMALL
    .STACK 64
.DATA
    Time DB 0 
    Timeafter db 10
    BALLX dw 0AH,45H,65h 
    BALLY dw 0AH,45H,65h
	BALLX1 Dw 0AH
	BALLY1 Dw 0AH
    BALLX2 Dw 0AH
	BALLY2 Dw 0AH
    BALLSize1 dw 04h
    BALL_INtial_X DW 00
    BALL_INtial_Y DW 00
    BALLVecloityX1 dw 05H
    BALLVecloityY1 dw 02h
    BALLVecloityX2 dw 05H
    BALLVecloityY2 dw 02h
    Window_Width dw 140h   ;320pixel
    Window_height dw 0c8h ;200pixel
    Window_Boundries dw 04h
    ;;;;
    PADDLE_LEFT_X DW 0Ah
	PADDLE_LEFT_Y DW 0Ah
	
	PADDLE_RIGHT_X DW 130h
	PADDLE_RIGHT_Y DW 0Ah
	
	PADDLE_WIDTH DW 05h
	PADDLE_HEIGHT DW 1Fh
    PADDEL_VECLOITY DW 05H
    Ball_size DW 08h 
        
     
.code

DRAW_BALL   PROC
    MOV CX,[si] ;set the column (X)
	MOV DX,[di] ;set the line (Y)
    
    Drow_horizntal:
        MOV AH,0Ch ;set the configuration to writing a pixel
		MOV AL,01h ;choose  color
		MOV BH,00h ;set the page number 	
		INT 10h    ;execute the configuration
        Inc CX
        Mov aX,CX
        sub AX,[si]
        CMP AX,Ball_size
        jnG Drow_horizntal

        inc DX
        mov CX,[si]
        Mov aX,DX
        sub AX,[di]
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

MAIN PROC FAR
	           MOV         AX,@DATA
	           mov         ds,ax

               MOV AH,00h ;set the configuration to video mode
		       MOV AL,13h 
		       INT 10h     
               CALL CLEAR  
                
                    mov cx,3h  
                        Drawnewball: 
                                
                                  lea si,BALLX
                                  lea di,BALLY
                             try: 
                             push cx
                            CALL DRAW_BALL 
                            pop cx
                             
                                     add si,2h
                                     add di,2h
                                    ;  dec cx
                                    ;  cmp cx,0h
                                    ;  je skip
                             LOOP try
                                     

                     skip:                
MAIN ENDP


END MAIN   