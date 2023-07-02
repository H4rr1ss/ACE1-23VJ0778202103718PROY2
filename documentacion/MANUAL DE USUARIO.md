# **MANUAL DE USUARIO** 🕹️

<br>

## **Introducción** 📑

Con la finalidad de la implementación del lenguaje ensamblador, el curso arquitectura de computadores y ensambladores 1 se llevó a cabo el juego japonés Sokoban, en el cual el jugador tiene como principal objetivo empujar una serie de pescados hasta conseguir que éstos se ubiquen en ciertas posiciones. Cuando el jugador consigue lo anterior se le permite avanzar de nivel y acumular más puntos.

___

<br>

## **DESCRIPCION DEL SISTEMA** 📄

<br>

## *Acceso al sistema:*
Al iniciar el programa, será necesario verificar la presencia de los archivos `NIV.00`, `NIV.01` y `NIV.10` ya que tienen la configuración de los niveles base dentro del juego.

<br>

## *Ejecución*
1. Abrir DOSBox
2. Entrar al directorio `ACE1-23VJ0778202103718PROY2/src`
2. Compilar el archivo `main.asm` con el comando `ml main.asm`
3. Ejecutar el archivo `main.exe` con el comando `main.exe`

<br>

## *Mensaje Inicial🏛️*
Se muestra un encabezado y el nombre del programador

![Mensaje Inicial](./img/mensajeInicial.png)

<br>

## *Menú Principal🏛️*
En el menú principal se puede seleccionar entre las siguientes opciones:
- Iniciar Juego
- Cargar Nivel
- Configuración
- Puntajes Altos

![Menú Principal](./img/menuPrincipal.png)

<br>

___

<br>

* ## *Menú Pausa*
Se dará la opción, desde el menú principal a acceder a un menú de configuración. Este menú servirá principalmente para configurar los controles del juego. En la Figura 4 se ejemplifica el diseño de este menú.
![Menú Principal](./img/menuPausa.png)

<br>

* ## *Cargar Nivel*
Se podrá cargar un nivel aparte de los 3 niveles que trae el juego como base, ingresando de la siguiente forma: `NombreArchivo.TXT`

![Menú Principal](./img/cargarArchivo.png)

<br>

* ## *Jugabilidad*
Cada nivel contará con diferentes dificultadores y se maneja por medio de las flechas del teclado para mover los pescados.

![Menú Principal](./img/teclas.png)

<br>

___

<br>

~~~
Universidad de San Carlos de Guatemala 2023
Programador: Harry Aaron Gómez Sanic
Carné: 202103718
~~~

<br>

___