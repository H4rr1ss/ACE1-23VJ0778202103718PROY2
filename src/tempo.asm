variablesTemporales MACRO
    tmp_x           db 0,0
    tmp_y           db 0,0
    tmp_xp          db 0
    tmp_yp          db 0

    tmp_xb          db 0
    tmp_yb          db 0
    
    tmp_char        db 0a dup (0),0

    actualNivel     db 0 ; primer nivel
    scoreActual     dw 0000
    
    temporizador    db 0
    segs            db 0
    mins            db 0
    hrs             db 0
    secs2b          dw 0000
    mins2b          dw 0000
    hrs2b           dw 0000
    zeropad         db "0",0
    pad2            db "00",0
    pad3            db "000",0
    colon           db ":",0
ENDM