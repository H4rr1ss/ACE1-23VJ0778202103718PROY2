textosGenerales MACRO
    univ            db "Universidad de San Carlos de Guatemala",0
    facu            db "Facultad de Ingenieria",0
    escu            db "Escuela de Ciencias y Sistemas",0

    Iniciar_juego   db "INICIAR JUEGO",0
    cargar_nivel    db "CARGAR NIVEL",0
    config          db "CONFIGURACION",0
    puntajes        db "PUNTAJES ALTOS",0
    salir           db "SALIR",0
    datosEstudiante db "Harry Aaron Gomez Sanic - 202103718",0
    datos_resumen   db "HAGS - 202103718",0
    cadena_vacia    db " ",0

    msg_ganador     db "GANASTE!!!",0
    msg_continuar   db "CONTINUAR",0

ENDM

dataArchivosNivel MACRO
    txt_nivel1   db "NIV.00",0
    txt_nivel2   db "NIV.01",0
    txt_nivel3   db "NIV.10",0
    txt_nombreNivel   db 20h dup (0),0
    lvlA_kbIn   db 21h,20h,22h dup (0),0
    prompt_nivel   db "Ingrese el nombre de archivo:",0
    handle_nivel  dw 0000
    g_counter   dw 0000
    g_counter2  dw 0000
    g_buffer    db 20h dup(0),0
    g_buffer2   db 20h dup(0),0
ENDM