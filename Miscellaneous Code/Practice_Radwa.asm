
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
MOVEBALLS MACRO BALLX1,BALLVecloityX,BALLVecloityY,BALLY1,Window_height,Window_Width,Window_Boundries
  LOCAL NEG_VecloityX1,closeE, NEG_VecloityY1

  MOV AX,BALLVecloityX
       ADD BALLX1,AX
       mov ax,Window_Width
       sub ax,Window_Boundries
       CMP BALLX1,ax
       JG NEG_VecloityX1
       mov ax,Window_Boundries
       cMP BALLX1,AX
       JL NEG_VecloityX1
      MOV AX,BALLVecloityy
       ADD BALLy1,AX
       mov ax,Window_height
       sub ax,Window_Boundries
       CMP BALLy1,ax
       JG NEG_VecloityY1
       mov ax,Window_Boundries
       cMP BALLY1,AX
       JL NEG_Vecloityy1
     
       jmp closeE
     
    NEG_VecloityX1:NEG BALLVecloityX
        jmp closeE
    NEG_VecloityY1:NEG BALLVecloityY
        
   closeE:
    
ENDM
checkrightpaddel MACRO BALLX1,BALLY1,PADDLE_RIGHT_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
        LOCAL CLOSE1
          mov ax,BALLX1 
          ADD AX,BALLSize1
          CMP  AX,PADDLE_RIGHT_X
          JNG CLOSE1
          mov ax,PADDLE_RIGHT_X
          add ax,PADDLE_WIDTH
          cmp BALLX1,ax
          jnl CLOSE1
          MOV AX,BALLY1
          ADD AX,BALLSize1
          CMP AX,PADDLE_right_Y
          JNG CLOSE1
          MOv AX,PADDLE_right_Y
          ADD AX,PADDLE_HEIGHT
          CMp BALLY1,AX
          jnl CLOSE1
          CALL NEG_VecloityX
          
        CLOSE1:       
ENDM
checkleftpaddel MACRO  BALLX1,BALLY1,PADDLE_left_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
        LOCAL CLOSE3
        mov ax,BALLX1 
          ADD AX,BALLSize1
          CMP  AX,PADDLE_left_X
          JNG CLOSE3 ;;;;
          mov ax,PADDLE_LEFT_X
          add ax,PADDLE_WIDTH
          cmp BALLX1,ax
          jnl CLOSE3 ;;;;;;;;
          MOV AX,BALLY1
          ADD AX,BALLSize1
          CMP AX,PADDLE_LEFT_Y
          JNG CLOSE3 
          MOv AX,PADDLE_LEFT_Y
          ADD AX,PADDLE_HEIGHT
          CMp BALLY1,AX
         jnl CLOSE3;;;;
          CALL NEG_VecloityX
          
          
        CLOSE3: 
ENDM
gettime MACRO Time1
 Check: mov ah,0ch
        int 21h ; CH = hour CL = minute DH = second DL = 1/100 seconds
        CMP DL,Time1
        je Check
        mov Time1,DL
        jmp Check

    
ENDM
    .MODEL SMALL
    .STACK 64
.DATA
    Time DB 0 
    Timeafter db 10
    BALLX dw 0AH,05H 
    BALLY dw 0AH,05H
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
        
     
.code
MAIN PROC FAR
	           MOV         AX,@DATA
	           mov         ds,ax
               
            
	       
            ; Check: mov ah,2ch
            ;         int 21h ; CH = hour CL = minute DH = second DL = 1/100 seconds
            ;         CMP DL,Time
            ;         je Check
            ;         mov Time,dl
                     
                  
                    CALL vidomode
                ;     MoveBalls BALLX1,BALLVecloityX1,BALLVecloityY1,BALLY1,Window_height,Window_Width,Window_Boundries
                ;     checkrightpaddel BALLX1,BALLY1,PADDLE_RIGHT_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
                ;     checkleftpaddel BALLX1,BALLY1,PADDLE_left_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
                 
              
                ;     Drawpaddel BALLX1,BALLY1,BALLSize1,BALLSize1
                ;     CALL  MOve_Paddel
                ;     Drawpaddel PADDLE_LEFT_X,PADDLE_LEFT_Y,PADDLE_WIDTH,PADDLE_HEIGHT
                ;     Drawpaddel PADDLE_RIGHT_X,PADDLE_RIGHT_Y,PADDLE_WIDTH,PADDLE_HEIGHT
                ;     MOV AL ,Time
                ;    cmp Al,Timeafter
                ;    je Drawnewball
                    mov cx,0002h  
                    ; lea si,BALLX
                    ; lea di,BALLY
                ;    jmp skip
                        Drawnewball: 
                                
                                  lea si,BALLX
                                  lea di,BALLY
                             try:  Drawpaddel [si],[di],BALLSize1,BALLSize1 
                                ;   mov  cx,[si]
                                ;   mov bx ,[di]
                                ;  MoveBalls [si],BALLVecloityX1,BALLVecloityY1,[di],Window_height,Window_Width,Window_Boundries
                                   ;MoveBalls BALLX2,BALLVecloityX2,BALLVecloityY2,BALLY2,Window_height,Window_Width,Window_Boundries
                                  
                                  ;  checkrightpaddel BALLX1,BALLY1,PADDLE_RIGHT_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
                                    ;checkleftpaddel BALLX1,BALLY1,PADDLE_left_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
                               
                                    ;checkrightpaddel ax,bx,PADDLE_RIGHT_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
                                  ;  checkleftpaddel BALLX2,BALLX2,PADDLE_left_X,PADDLE_WIDTH,PADDLE_HEIGHT,BALLSize1
                                   ; Drawpaddel [si],[di],BALLSize1,BALLSize1
                                    ;Drawpaddel BALLX2,BALLY2,BALLSize1,BALLSize1
                                    ; CALL MOve_Paddel
                                    ; Drawpaddel PADDLE_LEFT_X,PADDLE_LEFT_Y,PADDLE_WIDTH,PADDLE_HEIGHT
                                    ; Drawpaddel PADDLE_RIGHT_X,PADDLE_RIGHT_Y,PADDLE_WIDTH,PADDLE_HEIGHT
                            ;   check2: mov ah,2ch
                            ;         int 21h ; CH = hour CL = minute DH = second DL = 1/100 seconds
                            ;         CMP DL,Time
                            ;         je check2
                            ;         mov Time,dl
                                     add si,2
                                     add di,2
                                    ;  dec cx
                                    ;  cmp cx,0h
                                    ;  je skip
                             
                             
                        
                                     

                     skip:                
                    
                           

                
              

                    ; jmp Check
   

	; HLT
MAIN ENDP
;description
vidomode PROC
    
    mov ah,0
    mov al,13h
   int 10h
    RET
    
vidomode ENDP
;description
;description

; Move_Ball PROC
;       MOV AX,BALLVecloityX
;        ADD BALLX1,AX
;        mov ax,Window_Width
;        sub ax,Window_Boundries
;        CMP BALLX1,ax
;        JG NEG_VecloityX1
;        mov ax,Window_Boundries
;        cMP BALLX1,AX
;        JL NEG_VecloityX1
;       MOV AX,BALLVecloityy
;        ADD BALLy1,AX
;        mov ax,Window_height
;        sub ax,Window_Boundries
;        CMP BALLy1,ax
;        JG NEG_VecloityY1
;        mov ax,Window_Boundries
;        cMP BALLY1,AX
;        JL NEG_Vecloityy1
     
;        jmp closeE
     
;     NEG_VecloityX1:NEG BALLVecloityX
;         RET
;     NEG_VecloityY1:NEG BALLVecloityY
;         RET
;    closeE:
;    RET
       


; Move_Ball ENDP


;description
; CHECK_PADDEL_RIGHT PROC
  
;           mov ax,BALLX1 
;           ADD AX,BALLSize1
;           CMP  AX,PADDLE_RIGHT_X
;           JNG CLOSE1
;           mov ax,PADDLE_RIGHT_X
;           add ax,PADDLE_WIDTH
;           cmp BALLX1,ax
;           jnl CLOSE1
;           MOV AX,BALLY1
;           ADD AX,BALLSize1
;           CMP AX,PADDLE_right_Y
;           JNG CLOSE1
;           MOv AX,PADDLE_right_Y
;           ADD AX,PADDLE_HEIGHT
;           CMp BALLY1,AX
;           jnl CLOSE1
;           CALL NEG_VecloityX
          
;         CLOSE1:  
;           RET
    
; CHECK_PADDEL_RIGHT ENDP
;description
; CHECK_PADDEL_LEFT PROC
    
;         mov ax,BALLX1 
;           ADD AX,BALLSize1
;           CMP  AX,PADDLE_left_X
;           JNG CLOSE3 ;;;;
;           mov ax,PADDLE_LEFT_X
;           add ax,PADDLE_WIDTH
;           cmp BALLX1,ax
;           jnl CLOSE3 ;;;;;;;;
;           MOV AX,BALLY1
;           ADD AX,BALLSize1
;           CMP AX,PADDLE_LEFT_Y
;           JNG CLOSE3 
;           MOv AX,PADDLE_LEFT_Y
;           ADD AX,PADDLE_HEIGHT
;           CMp BALLY1,AX
;          jnl CLOSE3;;;;
;           CALL NEG_VecloityX
          
;         CLOSE3:  
;           RET
    
; CHECK_PADDEL_LEFT ENDP
NEG_VecloityX PROC
    NEG BALLVecloityX1
        RET
NEG_VecloityX ENDP
NEG_VecloityY PROC
    NEG BALLVecloityY1
        RET
NEG_VecloityY ENDP


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
        MOV AX,Window_Boundries
        CMP PADDLE_LEFT_Y,AX
        JL FIX_PADDEL
        jmp CHECK_RIGHT
          
      
   MOVE_DOWN:
        MOV AX,PADDEL_VECLOITY
        add PADDLE_LEFT_Y,AX
        
        mov ax,Window_height
        sub ax,Window_Boundries
        sub ax,PADDLE_HEIGHT
        cmp PADDLE_LEFT_Y,ax
        jg FIX_PADDEL2
        jmp CHECK_RIGHT
          

   
    
   FIX_PADDEL: mov ax,Window_Boundries
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
        MOV AX,Window_Boundries
        CMP PADDLE_RIGHT_Y,AX
        JL FIX_PADDEL1
          RET
      
   MOVE_DOWN1:
        MOV AX,PADDEL_VECLOITY
        add PADDLE_RIGHT_Y,AX
        
        mov ax,Window_height
        sub ax,Window_Boundries
        sub ax,PADDLE_HEIGHT
        cmp PADDLE_RIGHT_Y,ax
        jg FIX_PADDEL22
        RET
    FIX_PADDEL1: mov ax,Window_Boundries
               mov PADDLE_right_Y,ax
                RET
   
    FIX_PADDEL22: MOV PADDLE_right_Y,AX

    close:     
       RET
                
    
MOve_Paddel ENDP
;description
Restart PROC
    mov ax,BALL_INtial_X
    mov BALLX1,AX
    MOV AX,BALL_INtial_Y
    MOV BALLY1,AX
    RET
    
Restart ENDP  

         END MAIN   