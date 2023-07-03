# **MANUAL TÉCNICO** 💻

<br>

## **Descripción de la solución** ⚙️ 
Para esta practica se realizó un juego llamado sokoban el cual esta programado en lenguaje ensamblador, tiene movimientos tanto como izquierda, derecha, arriba y abajo se realizaron algunos archivos asm aparte para tener mayor orden al momento de declarar algunas macros y variables asi es más legible.

<br>

___

## **Requerimientos del Entorno de Desarrollo** 🔧
* Lenguaje ensamblador a utilizar: MASM 6.11

* Presentación de la practica: DosBox

* IDE utilizada para realización: Visual Studio Code 1.56.0 u otro editor

* Memoria RAM: 512 MB o más.

* Espacio en disco: Al menos 2 GB de espacio libre.

* Sistema operativo: Windows 7 o posterior/cualquier distribución Linux.

* Procesador: Intel Core i3 o equivalente, con una velocidad de al menos 2 GHz.

___

<br>

## **Tecnologías utilizadas**💻

### *DosBox:*
Es un programa de emulación que permite ejecutar aplicaciones y juegos diseñados originalmente para MS-DOS (Sistema Operativo de Disco Magnético), un sistema operativo utilizado en las computadoras personales antes de la popularización de Windows.

La principal ventaja de DosBox es su capacidad para emular el hardware y el entorno de software de los equipos antiguos. Esto significa que puede simular la CPU, la memoria, los gráficos, el sonido y otros componentes que eran comunes en los sistemas de la época. Esto permite que las aplicaciones y juegos de DOS se ejecuten de manera fiel y sin problemas en sistemas modernos.

<br>

### *MASM:*
También conocido como Microsoft Macro Assembler 6.11, es un ensamblador de lenguaje de programación desarrollado por Microsoft. Se utiliza principalmente para escribir y ensamblar programas en lenguaje ensamblador para la arquitectura x86 de los procesadores de Intel.

MASM611 permite a los programadores escribir código en lenguaje ensamblador, un lenguaje de bajo nivel que se acerca más al lenguaje de máquina del procesador. Proporciona un conjunto de instrucciones específicas del procesador, permitiendo un control granular y directo sobre el hardware de la computadora.

<br>

___

## **Diccionario de módulos**🏛️

- ### Base necesaria para iniciar

```asm
.model small
.stack
.radix 16
.data
.code
.startup

inicio:


fin:

.exit
end
```

- ### Macros
son bloques de código reutilizables que se definen una vez y se pueden invocar múltiples veces en un programa. Son una forma de abstraer y simplificar secciones de código comunes y repetitivas.
```asm
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
```


### Importación de archivos .asm

~~~asm
;   [MACROS GENERALES]
include macros.asm
;   [CADENAS]
include textos.asm
;   [VARIABLES TEMPORALES]
include tempo.asm
~~~

### Inicio de juego

~~~asm
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
~~~

### Sprites

~~~asm

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
~~~

___

<br>


## **Compilación y ejecución**🔮
Dentro del sistema para el ingreso del mismo es necesario tener los archivos llamados `NIV.00`, `NIV.01` y `NIV.10` para tener cargados los primeros 3 mapas.

<br>

Se deben seguir lo siguientes pasos para la compilación y ejecución del sistema de ventas:

1. Abrir DosBox y dirigirse al directorio donde se encuentra el archivo .asm
2. Colocar en consola de DosBox `ml main.asm` para realizar su compilación
3. Para su ejecución colocar en consola de DosBox `main.exe`


<br>

___

<br>

~~~
Universidad San Carlos de Guatemala 2023
Programador: Harry Aaron Gómez Sanic
Carné: 202103718
~~~

<br>

___