# **MANUAL DE USUARIO** 🕹️

<br>

## **INTRODUCCIÓN** 📑

Con la finalidad de la implementación del lenguaje ensamblador, el curso arquitectura de computadores y ensambladores 1 se llevó a cabo el juego japonés Sokoban, en el cual el jugador tiene como principal objetivo empujar una serie de pescados hasta conseguir que éstos se ubiquen en ciertas posiciones. Cuando el jugador consigue lo anterior se le permite avanzar de nivel y acumular más puntos.

<br>

___

<br>

## **DESCRIPCION DEL JUEGO** 📄
Sokoban es un juego de rompecabezas que se centra en la lógica y la planificación estratégica. El objetivo principal es empujar cajas o bloques hacia ubicaciones específicas en un escenario de juego. El jugador controla un personaje que puede moverse en cuatro direcciones: arriba, abajo, izquierda y derecha.

El escenario del juego está compuesto por una cuadrícula en la que hay diferentes elementos, como paredes, espacios vacíos, cajas y ubicaciones objetivo. El jugador debe empujar las cajas una a la vez, sin tirarlas ni arrastrarlas, para colocarlas en las ubicaciones objetivo.

El desafío radica en que las cajas solo se pueden mover una posición a la vez y no se pueden empujar si hay un obstáculo, como una pared o otra caja, bloqueando su camino. Esto significa que el jugador necesita planificar cuidadosamente cada movimiento para evitar quedar atrapado o bloquear una caja en una posición inaccesible.

<br>

___

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