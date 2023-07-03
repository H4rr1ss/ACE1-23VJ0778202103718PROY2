; hace un movimiento en el cursor
moverCursor MACRO xpos,ypos
    mov AH,02h  
    mov BH,00h  
    mov DH,ypos 
    mov DL,xpos 
    int 10h
ENDM

getCursorPos MACRO
    mov AH,03h 
    mov BH,0h   
    int 10h
ENDM

; Imprime una cadena en la posicion que se le coloque
mPrint MACRO xpos, ypos, stringbuffer, color
    push SI
    moverCursor xpos,ypos
    lea SI,stringbuffer 
    mov BL,color
    call PrintStr 
    pop SI
ENDM

ponerSprite MACRO sprite,col,row
    lea SI, sprite
    mov DH,col
    mov DL,row
    call RenderSprite
    
ENDM

limpiarBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

limpiarBufferJuego MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    mov AL,0FFh
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

limpiarKBuffer MACRO buffer,len_buff
    push DI
    mov DI, offset buffer
    add DI,02h
    mov AL,0
    mov CX,len_buff
    rep stosb
    pop DI 
ENDM

_AtoiBuffer MACRO buffer_str, buffer_num
    push BX
    xor SI,SI
    xor AH,AH
    lea SI, buffer_str
    call atoi
    mov BH,00h
    mov [buffer_num],BL
    pop BX
ENDM

_itoaBuffer MACRO buffer1,buffer2
    xor AX,AX
    mov AX,[buffer1]
    mov BX,offset buffer2
    call itoa
    mov AX,[buffer1]
    call zeroPadding
    agregarTMPBuffer buffer2,20h,0
    limpiarBuffer buffer2,20h
    lea DI,buffer2
    agregarTMPBuffer g_buffer,20h,0 
ENDM

agregarTMPBuffer MACRO inp,len_inp,skip_inp
    xor CX,CX
    xor SI,SI
    mov SI,offset inp
    mov CX,len_inp
    add SI,skip_inp
    rep movsb 
ENDM

PrintString MACRO buffer
    mov SI, offset buffer
    call printstr
ENDM

RenderPos MACRO thingX,thingY,skip
    xor SI,SI
    mov tmp_x,00h
    mov tmp_y,00h

    lea SI,thingX
    add SI,skip
    lodsb
    mov [tmp_x],AL
    cmp tmp_x,0FFh
    je FinishFloor

    xor SI,SI
    lea SI,thingY
    add SI,skip
    lodsb
    mov [tmp_y],AL
ENDM