;   [MACROS GENERALES]
include macros.asm
;   [CADENAS]
include textos.asm
;   [VARIABLES TEMPORALES]
include tempo.asm


.MODEL SMALL
.RADIX 16
.STACK
.DATA
    ;textos generales de menú, etc
    textosGenerales
    JugarPos    EQU 08h
    CargarPos    EQU 0Ah
    ConfPos    EQU 0Ch
    POS_HSCR    EQU 0Eh
    SalirPos    EQU 10h

    BOTTOM_LINE EQU 18h

    POS_CONT    EQU 0Ah
    POS_LEAV    EQU 0Eh

    ; teclas del menú
    F_1         EQU 3Bh
    UP_KEY      EQU 48h
    DOWN_KEY    EQU 50h
    F_2         EQU 3Ch

    ;
    DESP_U  EQU 01h
    DESP_D  EQU 02h 
    DESP_L  EQU 03h
    DESP_R  EQU 04h
    V_DESP  db 0

    arrow       db 10h,0

    ;controles por defecto: flechas (arriba,izquierda,derecha,abajo)
    joy_arriba      db 48h
    joy_abajo    db 50h
    joy_derecha   db 4Dh
    joy_izquierda    db 4Bh

    ; archivos de nivel
    dataArchivosNivel

    ; varibles temporales para la asiganción de coordenadas
    variablesTemporales

    ; 30 cajas - 30 objetivos (coordenadas en columnas y lineas)
    box_xpos    db 1Eh  dup (0FFh),0FFh
    box_ypos    db 1Eh  dup (0FFh),0FFh
    obj_xpos    db 1Eh  dup (0FFh),0FFh
    obj_ypos    db 1Eh  dup (0FFh),0FFh
    ; Suelo y paredes, ¿hasta 255 de cada?
    wal_xpos    db 0FFh dup (0FFh),0FFh
    wal_ypos    db 0FFh dup (0FFh),0FFh
    flo_xpos    db 0FFh dup (0FFh),0FFh
    flo_ypos    db 0FFh dup (0FFh),0FFh

    ; contador del número de objetos existentes de cada tipo
    n_box       db 0,0
    n_obj       db 0,0
    n_wal       db 0,0
    n_flo       db 0,0
    
    ; Posición del jugador
    ply_xpos    db 0
    ply_ypos    db 0
    ; guarda en que cosa se está parando el jugador, para redibujarla en caso de movimiento
    ply_over    db 0,0 ; 00h -> piso  01h -> objetivo
    
.CODE
.STARTUP

Start:
    mov AX, @DATA
    mov DS,AX
    mov ES,AX

    mov AH,00h
    call iniciarVideo
    jmp Intro

Intro:
    mPrint 01h,08h,univ,21h
    mPrint 01h,08h+2,facu,21h
    mPrint 01h,08h+4,escu,21h
    mPrint 00h,BOTTOM_LINE,datosEstudiante,08h
    ; se utiliza como delay
    mov AH,86h      
    mov CX, 64h
    mov DX, 1E84h  
    int 15h 

    call iniciarVideo  
    jmp MainMenu

MainMenu:
    mPrint 0Ch,JugarPos,Iniciar_juego,0Fh
    mPrint 0Ch,CargarPos,cargar_nivel,0Fh
    mPrint 0Ch,ConfPos,config,0Fh
    mPrint 0Ch,POS_HSCR,puntajes,0Fh
    mPrint 0Ch,SalirPos,salir,0Ch
    mPrint 00h,BOTTOM_LINE,datosEstudiante,08h           ;imprimir datosEstudiante en la última linea
    mPrint 0Ah,JugarPos,arrow,03h
MenuLoop:
    jmp GetKeyMenu

; leer los teclazos
GetKeyMenu:
    mov AH,12h 
    int 16h
    mov BX,AX 

    mov AH,10h 
    int 16h

CheckMenuKey:
    cmp AH,UP_KEY  
    je CheckArrowUpMenu
    cmp AH,DOWN_KEY  
    je CheckArrowDownMenu
    cmp AH,F_1
    je MenuSelected
    jmp MenuLoop

CheckArrowUpMenu:
    getCursorPos
    mPrint 0Ah,DH,cadena_vacia,03h
    cmp DH,JugarPos
    je MoveToPos5
    sub DH,02h
    mPrint 0Ah,DH,arrow,03h
    jmp FinalCheckArrowUp
    MoveToPos5:
        mPrint 0Ah,DH,cadena_vacia,03h
        mPrint 0Ah,SalirPos,arrow,03h
        jmp FinalCheckArrowUp
    FinalCheckArrowUp:
        jmp MenuLoop

CheckArrowDownMenu:
    getCursorPos
    mPrint 0Ah,DH,cadena_vacia,03h
    cmp DH,SalirPos
    je MoveToPos1
    add DH,02h
    mPrint 0Ah,DH,arrow,03h
    jmp FinalCheckArrowDown
    MoveToPos1:
        mPrint 0Ah,DH,cadena_vacia,03h
        mPrint 0Ah,JugarPos,arrow,03h
        jmp FinalCheckArrowUp
    FinalCheckArrowDown:
        jmp MenuLoop
        
MenuSelected:
    getCursorPos
    cmp DH,JugarPos
    je StartGame
    cmp DH,CargarPos
    je StartArbitraryGame
    cmp DH,SalirPos
    je Final
    jmp MenuLoop

StartGame:
    mov AH,00h  ; nivel 1
    mov actualNivel,AH
    call ParseLevel 
    jmp GameLoop

StartArbitraryGame:
    call iniciarVideo
    limpiarKBuffer lvlA_kbIn,20h
    mPrint 3h,8h,prompt_nivel,07h
    moverCursor 3h,0Ah
    mov AH,0Ah
    mov DX,offset lvlA_kbIn
    int 21h

    lea SI, lvlA_kbIn
    add SI,02h
    lea DI, txt_nombreNivel
    ; Remover retorno de carro/línea nueva del nombre del archivo
    RemoveCarriage:
        lodsb
        cmp AL,0d
        je ContinueArbi
        cmp AL,0a
        je ContinueArbi
        cmp AL,0h
        je ContinueArbi
        stosb
        jmp RemoveCarriage
    ContinueArbi:
    mov AH,03h  ; opción arbitraria
    call ParseLevel 
    jmp GameLoop

GameLoop:
    call GetTime
    mov ah,11h
    int 16h
    jz GameLoop 
    ;call RenderTiles
    mov V_DESP,00h
    call PlayerSteppingOn
    mov AH,10h
    int 16h
    cmp AH,F_2
    je MenuPausa
    cmp AH,joy_arriba
    jnz NotUP
    dec ply_ypos
    mov V_DESP,DESP_U
    jmp FinalPosition 
    NotUp: ; abajo?
        cmp AH,joy_abajo
        jnz NotDown
        inc ply_ypos
        mov V_DESP,DESP_D
    NotDown:; izquierda?
        cmp AH,joy_izquierda
        jnz NotLeft
        dec ply_xpos
        mov V_DESP,DESP_L
    NotLeft:; derecha?
        cmp AH,joy_derecha
        jnz FinalPosition
        inc ply_xpos
        mov V_DESP,DESP_R
    FinalPosition:    
        call CheckCollision 
        call actualizar_score
        call RenderPlayer

    jmp GameLoop

; Renderiza el sprite en una posición Columna,Fila (40x25)
RenderSprite:		
    push ES
    push DS
	mov AX,0A000h
	mov ES,AX
	mov AX,@CODE
	mov DS,AX
	
	push DX	
    mov AX,08h
    mul DH
    mov DI,AX
        
    mov AX,0A00h
    mov BX,00h
    add BL,DL
    mul BX
    add DI,AX
	pop DX
	mov CL,08h			;Altura 8px
DrawY:
	push DI
    mov CH,08h		    ;Longitud 8px
DrawX:				
    mov AL,DS:[SI]
    ;xor AL,ES:[DI]	;Si se imprime el mismo sprite en el mismo lugar, se "borra"
    mov ES:[DI],AL
    inc SI
    inc DI
    dec CH
    jnz DrawX ; Siguiente pixel horizontal 
	pop DI
	add DI,0140h			; Ir una línea hacia abajo (320px)
	inc BL
	dec CL
	jnz DrawY
    pop ES
    pop DS
	ret		

; -> AH  00 -> LV.00  01 -> LV.01 02 -> LV.10 03 -> Arbitrario (?)
ParseLevel:
    call ClearLevelAssets 
    cmp AH,00h
    je LvlOne
    cmp AH,01h
    je LvlTwo
    cmp AH,02h
    je LvlThree
    cmp AH,03h
    je LvlArb
 
    LvlOne:    
        mov DX, offset txt_nivel1
        jmp LoadFile

    LvlTwo:
        mov DX, offset txt_nivel2
        jmp LoadFile

    LvlThree:
        mov DX, offset txt_nivel3
        jmp LoadFile

    LvlArb:
        lea DX, txt_nombreNivel
        jmp LoadFile

    LoadFile:
        mov AL, 2
        mov AH, 3Dh
        int 21h
        mov [handle_nivel], AX
        mov BX,[handle_nivel]
        jc MainMenu ; el archivo a abrir no fue encontrado
        call iniciarVideo
    ReadChar:
        limpiarBuffer tmp_char,0a
        mov AH,3Fh
        mov CX,01h
        mov DX,offset tmp_char
        int 21h
        jc FinishedReading  ; carry flag si hay error, no parece funcionar como yo esperaba xd
        cmp AX,0000h      ; si no lee nada
        je FinishedReading

        call SkipSpace
        cmp tmp_char,'c' ; c aja
        je ReadBox
        cmp tmp_char,'j' ; j ugador
        je ReadPlayer
        cmp tmp_char,'p' ; p ared
        je ReadWall
        cmp tmp_char,'o' ; o bjetivo
        je ReadObjective
        cmp tmp_char,'s' ; s uelo
        je ReadFloor
        ret
    ;; Suponiendo que el archivo no contendrá errores sintácticos/léxicos
    ReadBox:
        mov AH,42h
        mov AL,01h
        mov DX,0003h ; saltarse la palabra (c) aja
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_box,1Eh 
        je ObjError
        
        push SI
        push DI

        lea SI,box_xpos
        lea DI, tmp_x
        call ingresarArray

        lea SI,box_ypos
        lea DI, tmp_y
        call ingresarArray

        inc n_box

        pop SI
        pop DI
        jmp ReadChar
    ReadPlayer:
        mov AH,42h
        mov AL,01h
        mov DX,0006h ; saltarse la palabra (j) ugador
        mov CX,0000h 
        int 21h

        call ReadXY

        mov AL,[tmp_x] 
        mov AH,[tmp_y] 
        mov [ply_xpos],AL
        mov [ply_ypos],AH
        jmp ReadChar
    ReadWall:
        mov AH,42h
        mov AL,01h
        mov DX,0004h ; saltarse la palabra (p) ared
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_wal,0FFh 
        je ObjError
        
        push SI
        push DI

        lea SI,wal_xpos
        lea DI, tmp_x
        call ingresarArray

        lea SI,wal_ypos
        lea DI, tmp_y
        call ingresarArray

        pop SI
        pop DI
        jmp ReadChar
    ReadObjective:
        mov AH,42h
        mov AL,01h
        mov DX,0007h ; saltarse la palabra (o) bjetivo
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_obj,1Eh 
        je ObjError
        
        push SI
        push DI

        lea SI,obj_xpos
        lea DI, tmp_x
        call ingresarArray

        lea SI,obj_ypos
        lea DI, tmp_y
        call ingresarArray

        pop SI
        pop DI
        jmp ReadChar
    ReadFloor:
        mov AH,42h
        mov AL,01h
        mov DX,0004h ; saltarse la palabra (s) uelo
        mov CX,0000h 
        int 21h

        call ReadXY

        cmp n_flo,0FFh 
        je ObjError
        
        push SI
        push DI

        lea SI,flo_xpos
        lea DI, tmp_x
        call ingresarArray

        lea SI,flo_ypos
        lea DI, tmp_y
        call ingresarArray

        pop SI
        pop DI
        jmp ReadChar

    ObjError:
        ret

    FinishedReading:
        call RenderTiles
        ret

RenderTiles:
    call iniciarVideo  ; usandolo como clearsecreen
    call RenderWalls
    call RenderFloor
    call RenderObjectives
    call RenderBoxes
    call RenderPlayer
    mPrint 00h,BOTTOM_LINE,datos_resumen,08h 
    ret

RenderFloor:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderFloorTile:
    ; flo_xpos , flo_ypos

    RenderPos flo_xpos,flo_ypos,g_counter

    xor AX,AX
    xor SI,SI
    lea SI,suelo
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    inc g_counter
    jmp RenderFloorTile
    FinishFloor:
        mov g_counter,0000h
        ret

RenderWalls:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderWallTile:
    ; wal_xpos , wal_ypos

    RenderPos wal_xpos,wal_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,pared
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderWallTile
    FinishWalls:
        mov g_counter,0000h
        ret

RenderBoxes:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderBoxTile:
    ; wal_xpos , wal_ypos

    RenderPos box_xpos,box_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,pescado
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderBoxTile
    FinishBoxes:
        mov g_counter,0000h
        ret

RenderObjectives:
    mov g_counter,0000h ; contador para imprimir SI 
    RenderObjTile:
    ; wal_xpos , wal_ypos

    RenderPos obj_xpos,obj_ypos,g_counter
    
    xor AX,AX
    xor SI,SI
    lea SI,pinguinito
    mov DH,[tmp_x]
    mov DL,[tmp_y]
    call RenderSprite

    add g_counter,0001h
    jmp RenderObjTile
    FinishObjs:
        mov g_counter,0000h
        ret

RenderPlayer:
    lea SI,pinguino
    mov DH,[ply_xpos]
    mov DL,[ply_ypos]
    mov tmp_xp,DH
    mov tmp_yp,DL
    call RenderSprite
    ret
 

CheckCollision: 
    call FindWall
    call BoxHitbox
    call CheckWinState
    ret

; Verifica si hay una pared, impidiendo el moviento o no dado el caso
FindWall:
    mov g_counter,0000h
    lea SI,wal_xpos
    FindXWall:
        lodsb
        cmp AL,ply_xpos
        je FindYWall
        cmp AL,0FFh
        je AbleMoveWall
        inc g_counter
        jmp FindXWall
    FindYWall:
        push SI
        xor SI,SI
        lea SI,wal_ypos
        add SI,g_counter
        lodsb
        cmp AL,ply_ypos
        je CantMoveToWall
        pop SI
        inc g_counter
        jmp FindXWall
    CantMoveToWall:
        pop SI
        xor AX,AX
        mov AH,tmp_xp
        mov AL,tmp_yp
        mov ply_xpos,AH
        mov ply_ypos,AL
    AbleMoveWall:
        ret
        
    ret

; revisar los movimientos de la caja
BoxHitbox: 
    ; verificar si el jugador toca una caja con un potencial movimiento
    ; ply_xpos , ply_ypos
    FindBox:
    mov g_counter,0000h
    lea SI,box_xpos
    FindXBox:
        lodsb
        cmp AL,ply_xpos
        je FindYBox
        cmp AL,0FFh
        je NotFoundBox
        inc g_counter
        jmp FindXBox
    FindYBox:
        push SI
        xor SI,SI
        lea SI,box_ypos
        add SI,g_counter
        lodsb
        cmp AL,ply_ypos
        je FoundBox
        pop SI
        inc g_counter
        jmp FindXBox
    NotFoundBox:
        ret
    FoundBox:
        pop SI
        lea SI,box_xpos
        add SI,g_counter
        lodsb
        mov tmp_xb,AL
        lea SI,box_ypos
        add SI,g_counter
        lodsb

        ; verificar la dirección del movimiento
        mov tmp_yb,AL
        cmp V_DESP,DESP_U
        je CheckMoveUp
        cmp V_DESP,DESP_D
        je CheckMoveDown
        cmp V_DESP,DESP_L
        je CheckMoveLeft
        cmp V_DESP,DESP_R
        je CheckMoveRight
        ret
    ; suma o resta respectiva de acuerdo a la dirección del movimiento
    CheckMoveUp: ; movimiento hacia arriba
        dec tmp_yb
        jmp CheckBoxMoves
    CheckMoveDown: ; movimiento hacia abajo
        inc tmp_yb
        jmp CheckBoxMoves
    CheckMoveLeft: ; movimiento hacia la izquierda
        dec tmp_xb
        jmp CheckBoxMoves
    CheckMoveRight: ; movimiento hacia la derecha
        inc tmp_xb
        jmp CheckBoxMoves
    ; verificación de la validez de los movimientos
    CheckBoxMoves:
        call buscandoCajaSig
        cmp AH,01h
        je DoNotMoveBox
        call FindWallNextAt
        cmp AH,01h
        je DoNotMoveBox

        ; el movimiento es válido

        ;modificar el valor de la posición X de la caja
        lea BX,box_xpos
        add BX,g_counter
        mov AH,tmp_xb
        mov [BX],AH

        ;modificar el valor de la posición Y de la caja
        lea BX,box_ypos
        add BX,g_counter
        mov AH,tmp_yb
        mov [BX],AH
        
        ; renderiza caja en su nueva posición
        mov DH,tmp_xb
        mov DL,tmp_yb
        lea SI,pescado
        call RenderSprite

        ret
    DoNotMoveBox:
        ; el movimiento no es válido, resetear la posición del jugador
        pop SI
        xor AX,AX
        mov AH,tmp_xp
        mov AL,tmp_yp
        mov ply_xpos,AH
        mov ply_ypos,AL
        ret

; revisa si hay una caja bloqueando o no algún movimiento (sólo se puede mover una caja, no múltiples en fila)
; tmp_xb , tmp_yb posiciones potenciales de la caja
; -> AH : 01h no puede moverse,  00h puede moverse
buscandoCajaSig:
    mov g_counter2,0000h
    lea SI,box_xpos
    buscarCajaX:
        lodsb
        cmp AL,tmp_xb
        je buscarCajaY
        cmp AL,0FFh
        je NotFoundBoxAt
        inc g_counter2
        jmp buscarCajaX
    buscarCajaY:
        push SI
        xor SI,SI
        lea SI,box_ypos
        add SI,g_counter2
        lodsb
        cmp AL,tmp_yb
        je FoundBoxAt
        pop SI
        inc g_counter2
        jmp buscarCajaX
    NotFoundBoxAt:
        mov AH,00h
        ret
    FoundBoxAt:
        pop SI
        mov AH,01h
        ret

; Se asegura de que una caja no pueda atravesar una pared
; tmp_xb , tmp_yb posiciones potenciales de la caja
; -> AH : 01h no puede moverse,  00h puede moverse
FindWallNextAt:
    mov g_counter2,0000h
    lea SI,wal_xpos
    FindXWallAt:
        lodsb
        cmp AL,tmp_xb
        je FindYWallAt
        cmp AL,0FFh
        je AbleMoveWallAt
        inc g_counter2
        jmp FindXWallAt
    FindYWallAt:
        push SI
        xor SI,SI
        lea SI,wal_ypos
        add SI,g_counter2
        lodsb
        cmp AL,tmp_yb
        je CantMoveToWallAt
        pop SI
        inc g_counter2
        jmp FindXWallAt
    CantMoveToWallAt:
        pop SI
        mov AH,01h
        ret
    AbleMoveWallAt:
        mov AH,00h
        ret

; compara las posiciones de las cajas con la de los objetivos, para determinar la victoria
CheckWinState:
    mov g_counter,0000h
    WinStateLoop:
        lea SI,box_xpos
        add SI,g_counter
        lodsb
        mov tmp_xb,AL

        cmp tmp_xb,0FFh ; si llega al final del arreglo, ganó
        je Won

        lea SI,box_ypos
        add SI,g_counter
        lodsb
        mov tmp_yb,AL

        mov g_counter2,0000h
        FindXWinState:
            lea SI,obj_xpos
            add SI,g_counter2
            lodsb
            cmp tmp_xb,AL
            je FindYWinState
            cmp AL,0FFh
            je NotWinYet
            inc g_counter2
            jmp FindXWinState
        FindYWinState:
            lea SI,obj_ypos
            add SI,g_counter2
            lodsb
            cmp tmp_yb,AL
            je FoundOne
            inc g_counter2
            jmp FindXWinState
        FoundOne:
            inc g_counter
            jmp WinStateLoop

    NotWinYet:
        ret

    Won:
        jmp msg_nivelGanado

msg_nivelGanado:
    call iniciarVideo
    mPrint 10h,0Bh,msg_ganador,22h     
    mov AH,86h      
    mov CX, 09h
    mov DX, 080h   
    int 15h  
    cmp actualNivel,02h
    jb irSiguienteNivel
    mov actualNivel,00h
    call iniciarVideo
    jmp MainMenu
    irSiguienteNivel:
        inc actualNivel
        mov AH,actualNivel
        call ParseLevel
        ret

actualizar_score:
    mov AH,tmp_xp
    cmp AH,ply_xpos
    je CompareY
    inc scoreActual 
    jmp RenderScore
    CompareY:
        mov AL,tmp_yp
        cmp AL,ply_ypos
        je RenderScore
        inc scoreActual
    RenderScore:
        cmp scoreActual,0064h
        jb TriplePad
        cmp scoreActual,03E8h
        jb DoublePad
        cmp scoreActual,2710h
        jb SinglePad
        ;no pad
        _itoaBuffer scoreActual,g_buffer2
        mPrint 22h,00h,g_buffer2,0Fh
        ret
        TriplePad:
            mPrint 22h,00h,pad3,0Fh
            _itoaBuffer scoreActual,g_buffer2
            mPrint 25h,00h,g_buffer2,0Fh
            ret
        DoublePad:
            mPrint 22h,00h,pad2,0Fh
            _itoaBuffer scoreActual,g_buffer2
            mPrint 24h,00h,g_buffer2,0Fh
            mPrint 27h,00h,cadena_vacia,0Fh
            ret
        SinglePad:
            mPrint 22h,00h,zeropad,0Fh
            _itoaBuffer scoreActual,g_buffer2
            mPrint 23h,00h,g_buffer2,0Fh
            ret
    ret

; re-renderizar el bloque de suelo u objetivo sobre el que se estaba parando el jugador
PlayerSteppingOn:
    mov g_counter,0000h
    lea SI,obj_xpos
    FindXStepping:
        lodsb
        cmp AL,tmp_xp
        je FindYStepping
        cmp AL,0FFh
        je SteppingFloor
        inc g_counter
        jmp FindXStepping
    FindYStepping:
        push SI
        xor SI,SI
        lea SI,obj_ypos
        add SI,g_counter
        lodsb
        cmp AL,tmp_yp
        je SteppingObj
        pop SI
        inc g_counter
        jmp FindXStepping

    SteppingObj:
        pop SI
        xor AX,AX
        lea SI, pinguinito
        mov DH,tmp_xp
        mov DL,tmp_yp
        call RenderSprite
        ret
    SteppingFloor:
        lea SI, suelo
        mov DH,tmp_xp
        mov DL,tmp_yp
        call RenderSprite
        ret
        
    ret

MenuPausa:
    call iniciarVideo
    mPrint 0Ch,POS_CONT,msg_continuar,0Fh
    mPrint 0Ch,POS_LEAV,salir,0Ch
    mPrint 0Ah,POS_CONT,arrow,03h
    jmp GetPauseKey

GetPauseKey:
    mov AH,12h ;test Control/Shift (resultado en AX)
    int 16h
    mov BX,AX ; guardar AX

    mov AH,10h ; Leer teclado (espera input) en AX -> AH : Scan Code , AL : ASCII
    int 16h

CheckPauseKey:
    cmp AH,UP_KEY  ; flecha arriba
    je verificar_flechaPausa
    cmp AH,DOWN_KEY  ; flecha abajo
    je verificar_flechaPausa
    cmp AH,F_1
    je PauseSelected
    jmp GetPauseKey

verificar_flechaPausa:
    getCursorPos
    mPrint 0Ah,DH,cadena_vacia,03h
    cmp DH,CargarPos
    je MoveToLeave
    mPrint 0Ah,POS_LEAV,cadena_vacia,03h
    mPrint 0Ah,POS_CONT,arrow,03h
    jmp FinalCheckArrowPause
    MoveToLeave:
        mPrint 0Ah,POS_CONT,cadena_vacia,03h
        mPrint 0Ah,POS_LEAV,arrow,03h
        jmp FinalCheckArrowPause
    FinalCheckArrowPause:
        jmp GetPauseKey
 
PauseSelected:
    getCursorPos
    cmp DH,POS_CONT
    je RenderAndContinue
    cmp DH,POS_LEAV
    je ClearAndLeave
    jmp CheckPauseKey
    RenderAndContinue:
        call RenderTiles
        jmp GameLoop
    ClearAndLeave:
        call iniciarVideo
        jmp MainMenu

; tmp_char : caracter a comparar
SkipSpace:
    CompareSpace:
        cmp tmp_char, 0a
        je DoSkip
        cmp tmp_char,' '
        jne FinishSkipSpace
    DoSkip:
        mov AH,3Fh
        mov CX,01h
        mov DX,offset tmp_char
        int 21h

        jc FinishedReading  ; carry flag si hay error, no parece funcionar como yo esperaba xd
        cmp AX,0000h      ; si no lee nada
        je FinishedReading

        jmp CompareSpace
    FinishSkipSpace:
        ret

; BX : handle del archivo
; -> tmp_x : X tmp_y : Y
; Leer coordenadas X,Y del archivo
ReadXY:
    limpiarBuffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h
    
    call SkipSpace

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    inc DX  ; el último caracter es un número
    int 21h
    
    _AtoiBuffer tmp_char,tmp_x


    limpiarBuffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h
    
    call SkipSpace
    ; saltar la coma
    mov AH,42h
    mov AL,01h
    mov DX,0001h
    mov CX,0000h 
    int 21h

    limpiarBuffer tmp_char,0a
    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    int 21h

    call SkipSpace

    mov AH,3Fh
    mov CX,01h 
    mov DX, offset tmp_char
    inc DX  ; el último caracter es un número
    int 21h
    _AtoiBuffer tmp_char,tmp_y
    inc tmp_y
    limpiarBuffer tmp_char,0a
    ret

; SI: información a adjuntar
; DI: buffer al que se adjunta
; Agrega la información de SI en desde el primer 255 que encuentre
ingresarArray:
    push DI 
    push SI

    mov DI,SI   ; lodsb usa SI para cargar el caracter...
    mov AH,00h  ;contador de posiciones
    FindZero:   ; encontrar la posición del 255
        lodsb
        cmp AL,0FFh      ;  comparar si el caracter cargado en AL es FF (255)
        je FoundZero
        inc AH          ; incrementa condator
        jmp FindZero
    FoundZero:
        pop DI
        pop SI
        mov AL,AH   ; mover parta alta a parte baja 
        mov AH,00h  ; limpiar parte alta

        add DI,AX   ; 00NNh
        movsb       ; no se usa rep porque los datosEstudiante que se agregan son de un byte, es innecesario
        ret


; SI : cadena de texto a imprimir
; BL : color del texto
; Imprime la cadena de texto en la posición del cursor
PrintStr:
    getChar: 
        lodsb       ; carga un caracter en AL
        cmp AL,0    
        je finishedPrint ; si llega a un caracter NUL, termina
        
        mov AH,0Eh  ; imprime el caracter en AL en la posición del cursor
        mov BH,00h  ; página 0
        int 10h

        jmp getChar
    finishedPrint:
        ret

; cadena de texto a número
; SI: Cadena de texto 
; -> BX: número 
atoi:
    xor BX,BX
    atoi_1:
        lodsb   

        cmp AL,'0'
        jb noascii
        cmp AL,'9'
        ja noascii

        sub AL,30h
        cbw
        push AX
        mov AX,BX
        jc of
        mov CX,0Ah
        mul CX
        jc of
        mov BX,AX
        pop AX
        add BX,AX
        jc of
        jmp atoi_1
    noascii:
        ret 
    of:
        pop AX      ; NO hacer pop a esto hace que el programa se haga popó xd
        mov AH,01h
        ret

; Número a cadena de texto
; AX: Número BX: Offset de donde se colocará la cadena 
itoa: 
    xor CX,CX  ;CX = 0
    itoa_1:
        cmp AX,0
        je itoa_2            
        xor DX,DX
        push BX
        mov BX,0Ah
        div BX
        pop BX
        push DX
        inc CX
        jmp itoa_1

    itoa_2:
        cmp CX,0
        ja itoa_3
        mov AX,'0'
        mov [BX],AX
        inc BX
        jmp itoa_4

    itoa_3:
        pop AX
        add AX,30h
        mov [BX],AX
        inc BX
        loop itoa_3
    itoa_4:
        mov AX,0
        mov [BX],AX
        ret

; Modo de vídeo 13h 320x200
iniciarVideo:
    mov AH, 00h
    mov AL, 13h
    int 10h
    ret

; Regresar al modo de texto 03h
RestoreVideo:
    mov AH,00h
    mov AL,03h
    int 10h
    ret

; limpia todaa las posiciones de cajas, objetivos, paredes y del jugador
ClearLevelAssets:
    limpiarBufferJuego box_xpos,1Eh
    limpiarBufferJuego box_ypos,1Eh
    limpiarBufferJuego obj_xpos,1Eh
    limpiarBufferJuego obj_ypos,1Eh
    limpiarBufferJuego wal_xpos,0FFh
    limpiarBufferJuego wal_ypos,0FFh
    limpiarBufferJuego flo_xpos,0FFh
    limpiarBufferJuego flo_ypos,0FFh
    mov ply_xpos,00h
    mov ply_ypos,00h
    mov n_obj,00h
    mov n_box,00h
    mov n_wal,00h
    mov n_flo,00h
    mov segs,00h
    mov mins,00h
    mov hrs,00h
    mov temporizador,00h
    mov scoreActual,0000h
    ret

GetTime:
    mov AH,2Ch
    int 21h
    cmp DH,temporizador
    jne UpdateTimer
    ret
    UpdateTimer:
        mov temporizador,DH
        inc segs
        cmp segs,3Ch ; comparar con 60
        jge actualizar_mins
        jmp print_nuevaHora
    actualizar_mins:
        mov segs,00h
        inc mins
        cmp mins,3Ch
        jge UpdateHrs
        jmp print_nuevaHora
    UpdateHrs:
        mov mins,00h
        inc hrs     ; ya mucho engase si esto se pasa de 24 xd
    print_nuevaHora:
        mov AL,segs
        cbw
        mov secs2b,AX
        mov AL,mins
        cbw
        mov mins2b,AX
        mov AL,hrs
        cbw
        mov hrs2b,AX
        mPrint 24h,BOTTOM_LINE,colon,0Fh

        _itoaBuffer secs2b,g_buffer2
        mPrint 25h,BOTTOM_LINE,g_buffer2,0Fh

        mPrint 21h,BOTTOM_LINE,colon,0Fh

        _itoaBuffer mins2b,g_buffer2
        mPrint 22h,BOTTOM_LINE,g_buffer2,0Fh
        

        _itoaBuffer hrs2b,g_buffer2
        mPrint 1Fh,BOTTOM_LINE,g_buffer2,0Fh
        ret

; numero AX; padding con un 0 si el numero es menor a 10
zeroPadding:
    cmp AX,0Ah
    jb addZeroPadding
    limpiarBuffer g_buffer,20h
    lea DI,g_buffer 
    ret
addZeroPadding: 
    limpiarBuffer g_buffer,20h
    lea DI,g_buffer 
    agregarTMPBuffer zeropad,01h,0 
    ret

TextModePrintstr:
    TMgetchar:
        lodsb
        cmp AL,0a
        je nline 
        cmp AL,0
        je TMfinished
        mov AH, 0Eh
        int 10h
        jmp TMgetchar
    
    nline:              ;convertir un \n en \r\n
        mov AL, 0d
        mov AH, 0Eh
        int 10h
        mov AL, 0a
        mov AH, 0Eh
        int 10h
        jmp TMgetchar

    TMfinished:
        ret

Final:
;    call RestoreVideo
.EXIT

;;;;;;; Sprites 8x8 ;;;;;;;;;

pared:    
    db   4d, 4d, 4d, 4d, 4d, 4d, 4d, 4d
    db   4d, 0B, 0B, 0B, 0f, 0B, 0B, 4d
    db   4d, 0B, 0B, 0f, 0B, 0B, 0f, 4d
    db   4d, 0B, 0f, 0B, 0B, 0f, 0B, 4d
    db   4d, 0f, 0B, 0B, 0f, 0f, 0B, 4d
    db   4d, 0B, 0B, 0f, 0f, 0B, 0B, 4d
    db   4d, 0B, 0f, 0B, 0B, 0B, 0B, 4d
    db   4d, 4d, 4d, 4d, 4d, 4d, 4d, 4d

pescado:
    db  66,66,66,66,66,1a,66,66
    db  66,66,1a,66,36,1a,16,16
    db  66,1a,1a,36,36,36,03,66
    db  66,36,36,36,16,0b,03,66
    db  36,36,36,16,0b,03,66,66
    db  36,00,36,0b,03,66,66,66
    db  03,36,36,03,66,66,66,66
    db  66,03,03,66,66,66,66,66

suelo:
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66
    db   66, 66, 66, 66, 66, 66, 66, 66

pinguinito:
    db  66,66,66,66,66,66,66,66
    db  66,66,66,66,66,66,66,66
    db  66,12,19,19,19,66,66,66
    db  12,19,0f,0f,0f,0f,66,66
    db  12,19,0f,00,0f,00,66,66
    db  12,19,0f,0f,2a,2a,66,66
    db  12,12,0f,0f,0f,0f,12,66
    db  12,19,2a,0f,0f,2a,66,66

pinguino:
    db   66, 66, 66, 36, 36, 66, 66, 66
    db   66, 66, 36, 36, 36, 36, 66, 66
    db   66, 13, 00, 1f, 1f, 00, 13, 66
    db   66, 13, 1f, 2a, 2a, 1f, 13, 66
    db   66, 36, 36, 36, 36, 36, 36, 66
    db   13, 13, 1f, 1f, 1f, 1f, 13, 13
    db   66, 13, 13, 13, 13, 13, 13, 66
    db   2a, 2a, 66, 66, 66, 66, 2a, 2a
;;;;;;;;;;;;;;;;;;;;;;;;
END