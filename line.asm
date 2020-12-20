;---------------------------
        .MODEL SMALL
        .STACK 64
        .DATA
     
        .code
MAIN    PROC FAR               
        MOV AX,@DATA
         ; change video mode
         CALL videomode
         
            ;;; set background color
            CALL back
           
                
            ;; start drawing fisrt line
            CALL Ship1
            
           

            ;; start drawing second line
            CALL Ship2
          
            ;; first slope line for first line
            CALL Slope1Ship1
           
            ;; second slope line for first line
            CALL Slope2Ship1
            

            ;; first slope line for second line 
            CALL Slope1Ship2
             
         ;; second slope line for second line
           CALL Slope2Ship2 
         ;;; genetrting power for ship1
          CALL Power1
           ;;; genetrting power for ship2
         CALL Power2


           


            ; HLT                  
MAIN    ENDP
        
Ship1                PROC 
            mov cx,0
            mov dx,80
            mov al,5
            mov ah,0ch
      line1: Int 10h
            inc dx
            cmp dx,120  
            jnz line1 ; line1
            inc cx     ; repeating line
            mov dx,80
            cmp cx,5
            jnz line1
            RET   
Ship1                ENDP   
Ship2                PROC 
            mov cx,320
            mov dx,80
            mov al,5
            mov ah,0ch
        line2: Int 10h
            inc dx
            cmp dx,120
            jnz line2
            dec cx
            mov dx,80
            cmp cx,314
            jnz line2
            RET   
Ship2                ENDP  
Slope1Ship1               PROC 
          mov bx,75
            mov cx,0
            mov dx, 75
            mov al,5
            mov ah,0ch
        line3:INT 10h
               inc cx
               inc dx
               cmp cx,5
               jnz line3
               inc bx
               mov cx,0
               mov dx, bx
               cmp bx,80
               jnz line3
           
            RET   
Slope1Ship1              ENDP
Slope2Ship1              PROC 
          mov bx,125
            mov cx,0
            mov dx, 125
            mov al,5
            mov ah,0ch
        line4:INT 10h
               inc cx
               dec dx
               cmp cx,5
               jnz line4
               dec bx
               mov cx,0
               mov dx, bx
               cmp bx,120
               jnz line4
                     
           
            RET   
Slope2Ship1              ENDP
Slope1Ship2              PROC
     mov bx,75
              mov cx,320
              mov dx ,75
              mov al,5
              mov ah,0ch
        line5: INT 10h
                dec cx
                inc dx
                cmp cx,314
                jnz line5
                inc bx
                mov dx,bx
                mov cx,320
                cmp bx,80
                jnz line5  
         
                     
           
            RET   
Slope1Ship2              ENDP 
Slope2Ship2              PROC
      mov bx,125 
               mov cx,320
               mov dx,125
               mov al,5
               mov ah,0ch
        line6:int 10h
              dec cx
              dec dx
              cmp cx,314
              jnz line6
              dec BX
              mov cx,320
              mov dx,bx
              cmp bx,120
              jnz line6 
    
                     
           
            RET   
Slope2Ship2              ENDP       
       

Power1              PROC
         mov cx,5
            mov dx,5
            mov al,5
            mov ah,0ch
        line7: int 10h
            inc dx
            cmp dx,15
            jnz line7
           
            ;; genetering power
            mov cx,5
            mov dx,5
            mov al,5
            mov ah,0ch
        line9: int 10h
            inc cx
            cmp cx,30
            jnz line9
            ;; genetering power
            mov cx,5
            mov dx,15
            mov al,5
            mov ah,0ch
        line10: int 10h
            inc cx
            cmp cx,30
            jnz line10
            ;;; generting power
            mov cx,30
            mov dx,5
            mov al,5
            mov ah,0ch
        line11: int 10h
            inc dx
            cmp dx,16
            jnz line11
            ;;filling with colors
            mov bx,6
            mov cx,6
            mov dx,6
            mov al,7
            mov ah,0ch
        line13: int 10h
            inc dx
            cmp dx,15
            jnz line13
            mov dx,6
            inc bx
            mov cx,bx
            cmp bx,30
            jnz line13
            RET   
Power1              ENDP    
Power2              PROC  
        ;; genetering power
         mov cx,290
            mov dx,15
            mov al,5
            mov ah,0ch
        line16:int 10h
            dec dx
            cmp dx,4
            jnz line16
        ;; genetering power
            mov cx,315
            mov dx,5
            mov al,5
            mov ah,0ch
        line8: int 10h
            inc dx
            cmp dx,15
            jnz line8
            ;  ;; genetering power
            mov cx,315
            mov dx,5
            mov al,5
            mov ah,0ch
        line12: int 10h
            dec cx
            cmp cx,290
            jnz line12
            ;; generting power
            mov cx,315
            mov dx,15
            mov al,5
            mov ah,0ch
        line15: int 10h 
            dec cx 
            cmp cx,290
            jnz line15
         
            
       
         ;;filling with colors
            mov bx,314
            mov cx,314
            mov dx,6
            mov al,7
            mov ah,0ch
        line20: int 10h
            inc dx
            cmp dx,15
            jnz line20
            mov dx,6
            dec bx
            mov cx,bx
            cmp bx,290
            jnz line20

                RET   
Power2              ENDP 
back             PROC  
         mov cx,0
            mov dx,0
            mov al,9h
            mov ah,0ch
        background: INT 10h
              inc cx
              cmp cx,320
              jnz background
              inc dx
              mov cx,0
              cmp dx,200
              jnz background
                             RET   
back              ENDP
videomode           PROC 
          mov ah,0
            mov al,13H
            int 10H
                                         RET   
videomode              ENDP
         END MAIN   