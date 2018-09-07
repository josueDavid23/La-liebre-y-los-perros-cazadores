;*******************************************************************************
; Tarea Programada en el que se implementa el juego de la liebre y el cazador  *
;------------------------------------------------------------------------------*
;Josue Rodriguez --------Alejandro Salas									   *
; La liebre puede movilizarse en cualquier direccion                           *
; en cambio los perros se les limita al movimiento de la izquierda             *
; a parte de ello dependiendo si se encuentra en una posicion par              *
; solo se podran mover izquierda derecha arriba o abajo                        *
; en cambio si fuese una posicion impar es posible cualquier movimiento        *
; Cada movimiento sera indicado mediante un numero del 1 al 8                  *
; al guardar se debe digitar el numero 9                                       *
; el juego es posible cargar si se tiene una partida guardada anteriormente    *
; en caso de que se elija cargar y no hay partida guardada , se muestra un     *
; mensaje indicando que no fue posible la carga								   *
;------------------------------------------------------------------------------*
;Formas de ganar:															   *
;------------------------------------------------------------------------------*
	;Mover perros 10 veces consecutivas hacia arriba o abajo				   *
	;Acorralar a la liebre 													   *
	;Liebre quede a la izquierda de todos los perros						   *
;*******************************************************************************

;*******************************************************************************************
;se utiliza para imprimir lo que se hace es colocar escribe (parametro1)(parametro2)       *
;en donde el primer parametro es el puntero al msj y el segundo la cantidad de caracteres  *
;que se quieren imprimir                                                                   *
;*******************************************************************************************

%macro escribe 2  ; funcionalidad imprimir
mov eax,4; syswrite
mov ebx,1; sera una salida en pantalla
mov ecx,%1; puntero al mensaje
mov edx,%2; cantidad de caracteres del puntero a mensaje
int 0x80
%endmacro

;~ #####################################################################
;~ Seccion de datos no inicializados                                  ##
;~ -------------------------------------------------------------------##
;~ -------------------------------------------------------------------##
;~ Los datos a utilizar son en la mayoria string tambien es utilizado ##
; datos definidos con dd mas que todo para utilizar en la pila, si se ##
; tiene que hacer alguna operacion como por ejemplo los movimientos   ##
; del perro y liebre atraves del arreglo.                             ##
;~ #####################################################################

section .data

espacioSalto db	0xA
lenEspacioSalto equ $ - espacioSalto

;;;;;;;;;;;;;;;;
verificador dd 00

dir: db "ranura.txt", 0 ; nombre del archivo en el que se guarda el arreglo una vez que se guarde la partida
dir2: db "ranura2.txt", 0 ;; nombre del archivo en el que se guarda las variables importantes como lo es
; las columnas nombres de perros turno contador movimientos ,esto es una vez que se guarde la partida


msgBienvenida db 0xA,0xA,"		´´´´´´´´´´´´¶¶¶¶¶¶$´´´´´´´´´´´ ",0xA  	; se utiliza para imprimirlo como estetica esa imagen en ascii
msgBienvenida0 db "		´´´´´´´´´´´´¶¶¶¶¶¶$´´´´´´´´´´´",0xA 
msgBienvenida1 db "		´´´´´¶¶¶¶´´´¶¶¶$$$¶¶¶´´´´´´´´´",0xA 
msgBienvenida2 db "		´´´o¶¶¶¶¶¢´´$¶¶$$$$¶¶´´´´´´´´´",0xA  
msgBienvenida3 db "		´´¶¶¶$$¶¶ø´´´¶¶¶¶¶¶¶¶¶´´´´´´´´",0xA 
msgBienvenida4 db "		´´¶¶¶¶¶¶¶o´´´¶¶¶¶øo¢¶´¶¶¶¶¶´´´",0xA  
msgBienvenida5 db "		´´´¶¶¶¶¶¶´´´´´´¶¢øø¶´¶¶¶¶¶¶¶´´",0xA 
msgBienvenida6 db "		´´´´´´´´´¶¶¶¶$´´´´´´ø¶$$$$¶¶o´",0xA 
msgBienvenida7 db "		´´´´ø¶¶¶¶¶¶$¶¶¶¶´´´¶¶¶¶¶$$¶¶¢´",0xA 
msgBienvenida8 db "		´´ø¶¶¶$$$S$$$$¶¶¶´´´¶¶¶¶¶¶¶¢ø´",0xA  
msgBienvenida9 db "		´ø¶¶$$$$$I$$$$$¶¶ø´´´¶¶¶¶¢o´´´",0xA 
msgBienvenidaA db "		´´¶¶¶$$$$$L$$$$$¶¶¶´´´´´´´´´´´",0xA 
msgBienvenidaB db "		´´´¶¶¶¶$$$$V$$$$¶$¶´´¶¶¶¶¶¶¶¶´",0xA 
msgBienvenidaC db "		´´´´´¶¶¶¶$$$A$$$¶¶o´´¶¶¶¶¶¶$¶´",0xA 
msgBienvenidaD db "		´´´´´´´¶¶¶¶¶¶$$¶¶ø´´¶¶¶¶¶$¢o´´",0xA 
msgBienvenidaE db "		´´´´´´´ ¶¶¶¶$$¶¶¶¶´´¶¶¶¶¶¶¶´´´",0xA,0xA
lenMsjBienvenida equ $ - msgBienvenida 

msgCargar db 0xA," * Estimado usuario que accion quiere realizar en el juego?  ",0xA,0xA; mensaje mostrado al inicio se le pregunta si quiere cargar o inicar una nueva partida
msgCargar0 db " 			1...Cargar  ",0xA
msgCargar1 db " 			2...Juego nuevo  ",0xA
msgCargar2 db 0xA," * Digite su opcion:  "
lenMsjCargar equ $ -msgCargar

msgCarga0 db 0xA,"	 	  ╔═════════════════════════╗",0xA 
msgCarga1 db "		  ║--- Carga Incorrecta  ---║",0xA 
msgCarga2 db "		  ╚═════════════════════════╝",0xA,0xA 
lenCarga0 equ $ - msgCarga0

msgGuardar0 db 0xA,"	 	  ╔═════════════════════════╗",0xA 
msgGuardar1 db "		  ║--- Archivo guardado  ---║",0xA 
msgGuardar2 db "		  ╚═════════════════════════╝",0xA,0xA 
lenGuardar0 equ $ - msgGuardar0


msgInicio0 db "	 	  ╔═════════════════════════╗",0xA 
msgInicio1 db "		  ║-- Bienvenido al juego --║",0xA 
msgInicio2 db "		  ╚═════════════════════════╝",0xA,0xA 
lenInicio0 equ $ - msgInicio0

msgFigura0 db "		╔═════════════════════════╗",0xA 
msgFigura1 db "		║-------CONTROLES!!-------║",0xA 
msgFigura2 db "		╚═════════════════════════╝",0xA 
lenFigura0 equ $ - msgFigura0


msgOpcion0 db 0xA,"		╔══════════════════════════════╗",0xA 
msgOpcion1 db "		║--Ingrese una opcion valida --║",0xA 
msgOpcion2 db "		╚══════════════════════════════╝",0xA 
lenOpcion0 equ $ - msgOpcion0

msjSuOpcion  db 0xA,0xA,"	** Su opcion es ....  "
lenMsjSuOpcion equ $ -msjSuOpcion

msgLiebre0 db 0xA,"			╔═════════════════════════╗",0xA 
msgLiebre1 db "			║     FIN DEL JUEGO !!    ║",0xA 
msgLiebre3 db "			║**** GANADOR: LIEBRE ****║",0xA 
msgLiebre2 db "			╚═════════════════════════╝",0xA 
lenLiebre0 equ $ - msgLiebre0



msgCazador0 db 0xA,"			╔═════════════════════════╗",0xA 
msgCazador1 db "			║     FIN DEL JUEGO !!    ║",0xA 
msgCazador3 db "			║**** GANADOR:CAZADOR ****║",0xA 
msgCazador2 db "			╚═════════════════════════╝",0xA 
lenCazador0 equ $ - msgCazador0


msgSalida0 db 0xA,"			╔═════════════════════════╗",0xA 
msgSalida1 db "			║   FIN DE LA PARTIDA !!  ║",0xA 
msgSalida3 db "			║*************************║",0xA 
msgSalida2 db "			╚═════════════════════════╝",0xA 
lenSalida0 equ $ - msgSalida0


msgEleccion0 db 0xA,0xA," Opciones, digite segun lo indicado:",0xA,0xA  ; se muestra al finalizar la partida
msgEleccion1 db "	1..........Jugar con los mismos jugadores",0xA		; son las opciones posibles a digitar cuando alguno gane
msgEleccion2 db "	2..........Reiniciar juego",0xA
msgEleccion3 db "	3..........Salir",0xA
lenMsgEleccion equ $ -msgEleccion0

msgControlesRaya db 0xA,"_____________________________________________________",0xA ;; mensaje que indica los posibles movimientos
msgControles db 0xA,     "+ Moverse hacia arriba.................Digite *** 1"		; aparte de ello coniene el 9 que significa guardar partida
msgControles1 db 0xA,    "+ Moverse hacia abajo..................Digite *** 2"
msgControles2 db 0xA,0xA,"+ Moverse hacia la derecha.............Digite *** 3"
msgControles3 db 0xA,    "+ Moverse hacia la izquierda...........Digite *** 4"
msgControles4 db 0xA,0xA,"+ Moverse diagonal derecha arriba......Digite *** 5"
msgControles5 db 0xA,    "+ Moverse diagonal izquierda arriba....Digite *** 6"
msgControles6 db 0xA,0xA,"+ Moverse diagonal derecha abajo.......Digite *** 7"
msgControles7 db 0xA,    "+ Moverse diagonal izquierda abajo.....Digite *** 8"
msgControles8 db 0xA,    "+ Guardar juego........................Digite *** 9"
msgControles9 db 0xA,    "+ Salir del juego......................Digite *** 0"
msgControlesRaya2 db 0xA,"_____________________________________________________"
lenMsgControles equ $ - msgControlesRaya
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
msgElegirControl db 0xA,0xA,"**Indique el movimiento que quiere hacer mediante el numero correcto:  " 
lenElegirControl equ $ - msgElegirControl

msg db 0xA,0xA,"**Ingrese el numero de columnas que necesita (*Impar*):  "
len equ $ - msg

;*******************************************************************************************
;se solicita al usuario que indique los nombres de los perros a utilizar en la partida     *
;*******************************************************************************************
msjRaya2 db 0xA,0xA,"~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~☼~"
lenRaya2 equ $ - msjRaya2
msgPerro1 db 0xA,0xA,"**Ingrese el nombre del perro numero uno (*Primera letra en mayuscula*):  "
lenPerro1 equ $ - msgPerro1

msgPerro2 db "**Ingrese el nombre del perro numero dos (*Primera letra en mayuscula*):  "
lenPerro2 equ $ - msgPerro2

msgPerro3 db "**Ingrese el nombre del perro numero tres (*Primera letra en mayuscula*):  "
lenPerro3 equ $ - msgPerro3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;mensajes de validacion por aquello de que el usario digite nombres de perros con la misma inicial
;o algun numero o caracter no correspondiente a una letra del abecedario espanol en mayuscula
;tambien se valida si la letra de algun perro es igual a la L ya que la *L* corresponde a la liebre 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lineaPerro db 0xA,"*********************************************************************",0xA
lenLineaPerro equ $ - lineaPerro
msgVerficaPerro db "---Existen perros con la misma inicial, volver a digitar nombres---"
lenVerificaPerro equ $ - msgVerficaPerro
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lineaPerroNumero db 0xA,"****************************************************************************",0xA
lenLineaPerroNumero equ $ - lineaPerroNumero
msgVerficaPerroNumero db "---Existen perros con nombres invalidos,contiene caracteres no permitidos---"
lenVerificaPerroNumero equ $ - msgVerficaPerroNumero

lineaLiebre db 0xA,"*******************************************************************",0xA
lenLineaLiebre equ $ - lineaLiebre
msgLiebre db "---La inicial de alguno de los perros coincide con la letra *L* ---"
lenLiebre equ $ - msgLiebre
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Mensajes para los movimientos ya sea del 1 al 8 o el 9 en caso de guardar; al realizar un movimiento satisfactoriamente
;un mensaje indica que lo realizo correcto, si no es posible un movimiento tambien se le hace saber al usuario

msgMuevePerro db 0xA,"**Indique la inicial del perro que quiere mover:  "
lenMuevePerro equ $ - msgMuevePerro


msgMueveLiebre db 0xA,"**Indique la inicial de la liebre para movilizarla:  "
lenMueveLiebre equ $ - msgMueveLiebre

msgRayaMsg db 	   "***********************************************************************",0xA
lenMsgRaya equ $ - msgRayaMsg

msgInvalido db "	El movimiento que ha efectuado ha sido invalido",0xA
msgInvalido2 db "	Por favor volver a indicar inicial y numero del movimiento",0xA
lenMsgInvalido equ $ -msgInvalido

msgValido db "	El movimiento que ha efectuado se realizo satisfactoriamente",0xA
lenMsgValido equ $ -msgValido
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


msgAsterisco0 db "	╔═══╗ ",0xA 
msgAsterisco1 db "	║ * ║= Representacion Cuadrados-Octagonos",0xA ; mensaje mostrado arriba de la matriz es para que el usuario
msgAsterisco2 db "	╚═══╝ ",0xA 								; pueda notar que los * representan tanto cuadros como octagonos 

lenAsterisco0 equ $ - msgAsterisco0

; se imprimen las reglas para un mejor entendimiento del usuario 
; 			*Se mencionan aspectos como las formas de ganar el guardar y que no siempre se puede mover diagonalmente
			;ademas de que los perros no se pueden movilizar hacia la izquierda

reglas0 db 0xA,"  +-------------------------------------------------------------------+"  
reglas1 db 0xA,"  | = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = |"
reglas2 db 0xA,"  |{>/-------------------------------------------------------------\<}|"
reglas3 db 0xA,"  |: | Reglas:                                                     | :|"
reglas4 db 0xA,"  | :|   1)En cada turno el jugador solo mueve una de sus fichas   |: |" 
reglas5 db 0xA,"  |: |   2)Dependiendo en la posicion en que se encuentre podra    | :|"
reglas6 db 0xA,"  | :|    movilizarse diagonalmente.                               |: |"
reglas7 db 0xA,"  |: |   3)El perro esta limitado al movimiento hacia la izquierda | :|" 
reglas8 db 0xA,"  | :|   4)Se puede cargar el juego, siempre y cuando haya una     |: |" 
reglas9 db 0xA,"  |: |     partida guardada anteriormente. En caso de que no se    | :|"
reglasA db 0xA,"  | :|     muestra un mensaje indicando carga incorrecta.          |: |" 
reglasB db 0xA,"  |: |   5)Al realizar un movimiento si se digita el numero 9 la   | :|" 
reglasC db 0xA,"  | :|     partida es guardada.                                    |: |"
reglasD db 0xA,"  |: |   6)Para ganar se debe acorrar la liebre, movilizar a los   | :|" 
reglasE db 0xA,"  | :|     perros 10 veces consecutivas hacia arriba o hacia abajo |: |" 
reglasF db 0xA,"  |: |     y la ultima opcion es tener la liebre a la izquierda de | :|"
reglasG db 0xA,"  | :|     los tres perros.                                        |: |" 
reglasH db 0xA,"  |{>\-------------------------------------------------------------/<}|"
reglasI db 0xA,"  | = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = : = |"
reglasJ db 0xA,"  +-------------------------------------------------------------------+",0xA
lenReglas equ $ -reglas0


raya db "_"
lenRaya equ $ -raya

espacioRaya db "_______"
lenEspacioRaya equ $ - espacioRaya
;arreglo db 00

indicativo dd 000  ; lleva una cuenta de los movimientos de los perros arriba y abajo cuando se hacen consecutivos



tres dd 3 ; represnta el numero de filas
diez dd 10 ; se utiliza cuando la matriz se quiere de un tamano superior a dos digitos; se multiplica el primer digito almacenado en res por diez ;luego se le suma el segundo digito
dos dd 2; indica que al ingresar la cantidad de columnas se les debe sumar dos ; por los extremos
uno dd 1; es usado para movilizarse mediante el arrego cuando el usuario digita algun tipo de movimiento ya que para desplazarse izq o der se le debe sumar o restar 1 a la posicion donde
indicador dd 00 ; tendra valores de 1 o 0 lo cual representa que si es un 0 es turno de la liebre y si es un 1 es turno de los perros
cero dd 0; es usado para inicalizar un contador, funcion de verifica si los perros estan a la derecha de la liebre
espacio1 db "	"
lenEspacio1 equ $ - espacio1

encuentraLiebreContador dd 000
resultadoLiebre dd 000


;; en la funcion de verficar si la liebre esta a la izquierda de los perros se utilizan las siguientes definiciones de variables
; cada uno representa un contador que almacenara la posicion en la fila donde se encuentre el perro 1 perro 2 perro 3 o la liebre
; luego se compara la liebre con las demas y si es menor indica que gano
liebre dd 000; se colocan 3 ceros ya que si se trabaja con  matriz mayor a 31 columnas la posicon de un perro o liebre puede significar un
perro1 dd 000 ; numero de tres digitos ejemplo 102
perro2 dd 000
perro3 dd 000

primeraVariable dd 000 ; se utiliza para almacenar contadores en la funcion de verificar si todos los perros estan a la izquierda de la liebre
segundaVariable dd 000; se utiliza para almacenar contadores en la funcion de verificar si todos los perros estan a la izquierda de la liebre


contador dd 0000  ; se utiliza en la funcion de buscar la letra cuando el usuario digita la inical del perro o  liebre
contador1 dd 000	; el contador contenra la posicon en la que se ubique
contador2 dd 000 ; es usado como un contador temporal ya que su valor cambia en cada turno mas que todo se usa para no modificar el valor de contador
reserva dd 000
reserva2 dd 000 ; contiene el numero de columnas mas dos por las filas
reserva3 dd 000
reserva4 dd 000
numeroIndicaImprime dd 0000;; contiene la cantidad de columnas mas el dos por filas que el usuario indique

numeroColumnas dd 000 ; contendra en total la cantidad de columnas sin hacer la multiplicacion por tres de las filas

columnaPila dd 000; se utiliza en la verificacion cuando el usuario ingresa las columnas se verifica si es par o impar o mas de dos digitos

;seccion de variables no inicializadas;;;;;;;;;;;;;;;;;;;;;;
section .bss
res1 resb 10 ; se hace de 10 ya que el usario puede ingresar varios caracteres
res resb 4
basura resb 8 ; almacena lo inncecesario que es sacado de la pila
arreglo resb	300 ; es donde sera almacenado la supuestamente matriz se hace de 300 porque la cantidad mazxima de columnas es 97 mas 2 por 3 es igual a 297 
res2 resb 4
eleccion resb 10 ; es utilizado al final ya que cuando se acabe la partida se dan tres opciones salir Reiniciar o revancha se usa para comparar que digita el usuario

resCarga resb 4; es almacenado un uno o un dos al inicio del juego luego se compara si es juego nuevo o carga
;res3 resb 10
arreglo2 resb 9 ; se utiliza para guardar el archivo ya que en el se encuentran variables como lo es la cantidad de columnas, nombres de perros , indicativo etc se hace de 9 porque se introducen 8 variables
perroNumero1 resb 20 ; contendra el nombre del perro numero uno 
perroNumero2 resb 20; contendra el nombre del perro numero dos
perroNumero3 resb 20; contendra el nombre del perro numero tres 
resIndica resb 2 ;es usado en la funcion de recorrer la matriz buscando la letra con la cual se quiere hacer el movimiento

resMueve resb 10 ; contendra la letra que ingreso el usario que quiere movilizar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;*******************************************************************************
;; seccion en la que inicia la logica seguida para realizar el juego          *
;*******************************************************************************
section .text



global _start ; etiqueta global

_start: ; indica el inicio
;*******************************************************************************
; se hace la limpieza de los registros utilizados asi como tambien de los 
; contadores y variables utilizadas en la tarea esto se hace por la razon de 
; que al usuario se le da la opcion de reiniciar el juego
;*******************************************************************************
	xor eax,eax
	xor ebx,ebx
	xor ecx,ecx
	xor edx,edx
	xor al,al,
	xor bl,bl
	xor cl,cl
	xor dl,dl
	xor esi,esi
	xor edi,edi
	mov al,0
	mov [indicador],al
	mov al,0
	mov [contador],al
	mov al,0
	mov [contador1],al
	mov al,0
	mov [contador2],al
	mov al,0
	mov [numeroIndicaImprime],al
	mov al,0
	mov [numeroColumnas],al
	mov al,0
	mov [columnaPila],al
	mov al,0
	mov[indicativo],al
	mov al,0
	mov[resCarga],al
	mov al,0
	mov [verificador],al
	xor al,al

;*******************************************************************************
; se le pregunta al usuario si quiere jugar un nuevo juego o cargar alguna partida
; el digito ingresado se almacena en la reserva llamada resCarga
;*******************************************************************************
escribe msgBienvenida,lenMsjBienvenida
escribe msgInicio0,lenInicio0
escribe reglas0,lenReglas
escribe msgCargar,lenMsjCargar
mov eax,3
mov ebx,0
mov ecx,resCarga
mov edx,4
int 0x80
mov al,[resCarga]
sub al,'0'
cmp al,1
jb _start; en caso de que se ingrese algo no adecuado se devuelve al inicio en donde le pregunta de nueve que accioon quiere realizar
cmp al,2
ja _start
cmp al,1		; se hace las validaciones por ejemplo si el numero ingresado es mayor que dos o menor que 1 ya que
je cargarArreglo; solo se tienen dos opciones 1 y 2
jmp nombreDePerros


;******************************************************************************************************
;si el usuario decide jugar un nuevo juego se le debe pedir el nombre de los tres Perros
; con la condicion que deben inicar con una letra en mayuscula y no pueden tener la misma letra incial
; ya que para movilizarse se complicaria con letras iguales por el algoritmo utilizado
;tambien se valido si la letra es igual a la de la liebre le vuelve a pedir un nombre valido
; en caso de que digite algun caracter distinto al abecedario se piden los nombres correctamente
;*****************************************************************************************************

;;;;;;;;;;;;;solicita el nombre de cada perro
nombreDePerros:
	escribe msjRaya2,lenRaya2
	escribe msgPerro1,lenPerro1
	mov eax,3	
	mov ebx,0
	mov ecx,perroNumero1 
	mov edx,10
	int 0x80

	escribe msgPerro2,lenPerro2
	mov eax,3	;  
	mov ebx,0
	mov ecx,perroNumero2  
	mov edx,10
	int 0x80

	escribe msgPerro3,lenPerro3
	mov eax,3	;  
	mov ebx,0
	mov ecx,perroNumero3  ;
	mov edx,10
	int 0x80
;***************************************************************************************************
;cada nombre de perro es guardado en reservas de 10 ;; perroNumero1 perroNumero2 y perroNumero3
;se hacen de 10 ya que el nombre digitado por el usuario puede ser un nombre largo y en una reserva no 
; se podria almacenar
;*************************************************************************************************
; cada nombre se guarda por separado ejemplo perro uno en perroNumero1 perro dos en perroNumero2
; y perro tres en perroNumero3, cada una de ellas son reservas
;*************************************************************************************************

;la inicial de cada uno de los perros se mueve a registros como al bl cl y dl para luego comparar
; si son iguales o no
;********************************************************************************************************
; en la funcion verificaNombresPerroLiebre se valida si algun nombre de perro tiene la inicial igual que 
; la letra *L* en caso de que si vuelve a solicitar los nombres de perros

verificaNombrePerroLiebre:			;; valida si alguno de los nombres de perros es igual a la letra L que representa la liebre
	mov al,[perroNumero1]
	sub al,'0'
	mov bl,[perroNumero2]
	sub bl,'0'
	mov dl,[perroNumero3]
	sub dl,'0'
	cmp al,28
	je letraIgualLiebre
	cmp bl,28
	je letraIgualLiebre
	cmp dl,28
	je letraIgualLiebre
	jmp verificaNombreDePerros0

letraIgualLiebre:
	escribe lineaLiebre,lenLineaLiebre   ; si los nombres son iguales
	escribe msgLiebre,lenLiebre
	escribe lineaLiebre,lenLineaLiebre
	jmp nombreDePerros

;***************************************************************************************************
;es validado si la inical de cada perro es igual al del otro 
;primero se realiza una comparacion entre el perro1 y el perro2 luego del perro2 y el perro3 y 
; por ultimo la del perro1 con el perro3
;en caso de que alguno sea igual a otro vuelve a solicitar nombres validos de los perros
;***************************************************************************************************

verificaNombreDePerros0:
	mov al,[perroNumero1]
	mov bl,[perroNumero2]
	sub al,'0'
	sub bl,'0'
	cmp al,bl
	je imprimeMsgErrorPerros
	jmp verificaNombreDePerros1

verificaNombreDePerros1:
	mov al,[perroNumero2]
	mov bl,[perroNumero3]
	sub al,'0'
	sub bl,'0'
	cmp al,bl
	je imprimeMsgErrorPerros
	jmp verificaNombreDePerros2

verificaNombreDePerros2:
	mov al,[perroNumero1]
	mov bl,[perroNumero3]
	sub al,'0'
	sub bl,'0'
	cmp al,bl
	je imprimeMsgErrorPerros
	mov dl,[perroNumero1]
	sub dl,'0'
	jmp validarPrimeraInicialNumero

;***************************************************************************************************
; si existiese algun nombre con la misma inivial igual a otro se muestra un mensaje de error y luego
; se solicita nuevamente los nombreDePerros
;***************************************************************************************************
imprimeMsgErrorPerros:
	escribe lineaPerro,lenLineaPerro   ; si los nombres son iguales
	escribe msgVerficaPerro,lenVerificaPerro
	escribe lineaPerro,lenLineaPerro
	jmp nombreDePerros

;***************************************************************************************************
;luego es validado si la inicial de alguno de los perros es algun caracter distinto a las letras mayusculas
;del abecedario
; en caso de que si se imprime otro mensaje de error indicando que algun caracter no es valido luego se solicitan
; los respectivos nombres
;***************************************************************************************************
imprimeMsgErrorPerrosNumero:			; si contiene numeros al inicio
	escribe lineaPerroNumero,lenLineaPerroNumero
	escribe msgVerficaPerroNumero,lenVerificaPerroNumero
	escribe lineaPerroNumero,lenLineaPerroNumero
	jmp nombreDePerros
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;***************************************************************************************************
;se compara la letra de perro1 se hace una comparacion si es mayor a 42 o menor a 17 ya que entre
;ese rango se encuenttran las letras mayusculas del abecedario
;si la  letra ingresada no esta en ese rango se solicitan nombres nuevamente
;***************************************************************************************************
validarPrimeraInicialNumero:
	cmp dl,17
	jb imprimeMsgErrorPerrosNumero
	cmp dl,42
	ja imprimeMsgErrorPerrosNumero
	mov dl,[perroNumero2]
	sub dl,'0'
;***************************************************************************************************
;se compara la letra de perro2 se hace una comparacion si es mayor a 42 o menor a 17 ya que entre
;ese rango se encuenttran las letras mayusculas del abecedario
;si la  letra ingresada no esta en ese rango se solicitan nombres nuevamente
;***************************************************************************************************
validarPrimeraInicialNumero2:
	cmp dl,17
	jb imprimeMsgErrorPerrosNumero
	cmp dl,42
	ja imprimeMsgErrorPerrosNumero
	mov dl,[perroNumero3]
	sub dl,'0'
;***************************************************************************************************
;se compara la letra de perro3 se hace una comparacion si es mayor a 42 o menor a 17 ya que entre
;ese rango se encuenttran las letras mayusculas del abecedario
;si la  letra ingresada no esta en ese rango se solicitan nombres nuevamente
;***************************************************************************************************
validarPrimeraInicialNumero3:
	cmp dl,17
	jb imprimeMsgErrorPerrosNumero
	cmp dl,42
	ja imprimeMsgErrorPerrosNumero
	jmp solicitaNumeroColumnas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;solicitar columnas

;***************************************************************************************************
;en caso de que los nombres de los perros cumplan con todas las condiciones se procede
;a solicitar el numero de columnas, en estas funciones se realizan algunas
;validaciones por ejemplo que el numero sea impar mayor que uno y menor que 97
; ya que al numero ingresado se le debe sumar dos para agregar los extremos en doonde inicia la
;liebre y un perro2
;***************************************************************************************************

solicitaNumeroColumnas:
	escribe msjRaya2,lenRaya2
	escribe msg,len ; se pide el numero de columnas que quiere colocar el usuario 
	mov eax,3	; se guarda el numero indicado por el usuario 
	mov ebx,0
	mov ecx,res1  ; el resultado es guardado en res
	mov edx,10
	int 0x80

	mov al,[res1]
	sub al,'0'
	jmp verificaColumnasPrimerArgumento

;***************************************************************************************************
;se compara si el primer digito cumple estar entre el rango de 0 y 9 
;si es asi brinca a verficaColumnasSegundoArgumento
;si no fuese asi vuelve a solicitar el numero de columnas
;***************************************************************************************************
verificaColumnasPrimerArgumento:
	cmp al,0
	jb solicitaNumeroColumnas
	cmp al,9
	ja solicitaNumeroColumnas
	mov al,[res1+1]
	sub al,'0'
	jmp verificaColumnasSegundoArgumento
;;***************************************************************************************************
;se compara el elemento ubicado en res+1 si es 218 quiere decir que es solo un digito lo que ingreso el 
;usuario, si no es asi se compara ese segundo digito que este entre el rango de 0 y 9
; si no fuese asi vuelve a solicitaNumeroColumnas
;***************************************************************************************************
verificaColumnasSegundoArgumento:
	cmp al,218
	je solicitaNumeroColumnas2
	cmp al,0
	jb solicitaNumeroColumnas
	cmp al,9
	ja solicitaNumeroColumnas
	cmp al,9
	je verificadorNueveNueve
	cmp al,8
	je verificadorNueveNueve
	jmp verificaFin
;***************************************************************************************************
;en caso de que el numero no sea 98 ni 99 entonces brinca aqui q lo q se hace es comparar el tercer digito
;res+2 con 218 para saber si esta vacio o no 
; ya que si el usuario ingresa un numero de 3 digitos no es valido
; si esto ocurriese se le solicitaNumeroColumnas nuevamente
;***************************************************************************************************
verificaFin:
	mov al,[res1+2]
	sub al,'0'
	cmp al,218
	je solicitaNumeroColumnas2
	jmp solicitaNumeroColumnas
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;***************************************************************************************************
;esta verificacion se lleva a cabo ya que se compara el segundo digito y si es un 9 u 8 entonces se compara
;el primer digito con 9 por razones de que el numero maximo solicitado puede ser 97 no 98 ni 99
;***************************************************************************************************

verificadorNueveNueve:
	mov al,[res1]
	sub al,'0'
	cmp al,9
	je solicitaNumeroColumnas
	jmp verificaFin
;***************************************************************************************************
;;;;;
;; Proceso para imprimir la matriz  ****
; la cantidad de columnas es comparada si se ingreso dos digitos o un digito menor a diez
; se realiza procesos diferentes ya que si el usuario digita 20 al colocarlo en pila solo coloca el 2
; entonces se debe hacer comparacion y luego se multiplica por diez y se le suma en ese casso 0 .
;***************************************************************************************************
solicitaNumeroColumnas2:
	mov al,[res1+1]
	sub al,'0'	
	cmp al,218; se compara si el segundo digito  es vacio o no
	je procesoNormalMatriz; en caso de que si es que el numero contiene solo un digito por lo que el proceso sera normal

;***************************************************************************************************
;se verifica el segundo digito , se hace una comparacion en la que se compara con 1 3 5 7 o 9 si es
;alguno de esos numero quiere decir que el numero es un numero impar por que es correcto
; entonces se procedera a ingresarlo en pila sumarle dos y multiplicarlo por 3
;***************************************************************************************************	
procesoVerificaImpar: ;;; verifica el segundo digito
	mov bl,1
	mov al,[res1+1]
	sub al,'0'
;***************************************************************************************************
; se realiza el ciclo para saber si es numero impar el segundo digito
;***************************************************************************************************
procesoVerificaImpar0:
	cmp al,bl
	je procesoVerificaImpar1 ; cuando sea igual brincara a meter en pila sumar dos y multiplicar por 3
	add bl,2
	cmp bl,10
	jb procesoVerificaImpar0
	jmp solicitaNumeroColumnas; si no fuese par vuelve a solicitar el numero de columnas por no ser impar

;***************************************************************************************************
; se introduce el primer digito a la pila luego se introduce la variable definida en el .data
;llamada diez luego se hace una  multiplicacion, se le suma dos y finalmente se ingresa el segundo digito
; para la suma luego la multiplicacion por filas que es 3
;***************************************************************************************************
procesoVerificaImpar1:
	mov al,[res1]
	sub al,'0'
	mov[columnaPila],al
	fild dword [columnaPila]  ; meto el primer digito del res en caso de que fuera 12 meto el 1
	fild dword[diez]
	fmul st1
	mov al,[res1+1]
	sub al,'0'
	mov [columnaPila],al
	fild dword[columnaPila]
	fadd st1
	;; se guarda el resultado en reserva ;;;;; sin multiplicarlo por tres
	fistp dword [reserva] ; en este paso reserva contiene el resultado de la multiplicacion del primer digito por diez mas el segundo digito
	fistp dword[basura]
	fistp dword[basura] ;; ahora la pila se encuentra vacia y el resultado en reserva
	
;***************
	fild dword[reserva]  ; se le suma el dos a la reserva 
	fild dword[dos]
	fadd st1
	fistp dword[reserva]; el resultado vuelve a ser almacenado en reserva
	fistp dword[basura] ;se vacia la pila


	fild dword[reserva]; se ingresa reserva y se almacena en reserva 2 para que reserva no cambie ya que ese valor se ocupa luego
	fistp dword[reserva2]; es importane decir que reserva2 no tiene la multiplicacion por 3, solo contiene la cantidad de columnas por 10 y mas 2
	
;***********
	fild dword[reserva]
	fistp dword[numeroIndicaImprime]

;*****************

	fild dword[reserva]
	fild dword[tres]
	fmul st1		; se multiplica por tres para realizar la matriz que significa la cantidad de filas

	fistp dword[reserva]					
	fistp dword[basura]		; el resultado de la multiplicacion columnas por tres es guardado en reserva y la pila se vacia
	;fild dword[reserva]
	mov edi,0
	mov esi,[reserva]
	call cambio
	call cambio2
	call colocaLiebrePerros
	mov edi,0
	escribe espacioSalto,lenEspacioSalto  ; se procede a imprimir la matriz con la cantidad adecuada de elementos
	escribe espacioSalto,lenEspacioSalto
	jmp imprimeColumnas
;***************************************************************************************************
;procesoNormalMatriz se lleva a cabo si la cantidad de columnas introducida por el usuario es menor que 10
;tambien se hace un ciclo en que se compara si es impar o no 
; en caso de que no se solicitaNumeroColumnas de nuevo
;***************************************************************************************************
procesoNormalMatriz: ;;; 
	mov bl,1
	mov al,[res1]  ; se hace una validacion que si es menor a 3 la cantidad de columnas que no sea valido
	sub al,'0'		; ya que con solo una columna no se podria jugar
	cmp al,3
	jb solicitaNumeroColumnas

procesoNormalMatriz0:  ; ciclo que se lleva a cabo para saber si es impar  o no
	cmp al,bl
	je procesoNormalMatriz1
	add bl,2
	cmp bl,10
	jb procesoNormalMatriz0
	jmp solicitaNumeroColumnas

;***************************************************************************************************
; se introduce el primer digito a la pila luego se le suma dos y finalmente se multiplica por filas que es 3
;***************************************************************************************************
procesoNormalMatriz1:
	mov al,[res1]
	sub al,'0'
	mov [reserva],al;; en caso de que el usuario ingrese un numero menor a 10 el resultado se almacena aqui
	;***************
	fild dword[reserva]
	fild dword[dos]				; se le suma el dos
	fadd st1
	fistp dword[reserva] ; en este punto reserva contiene la cantidad de columnas ingresadas por el usuario mas el dos
	fistp dword[basura]	; que indica los extremos en donde al inicio se ubica el perro2 y la liebre

	fild dword[reserva] 
	fistp dword[reserva2] ; el resultado sera almacenado en reserva2 pero sin multiplicarlo por 3
		
;***********
	fild dword[reserva]
	fistp dword[numeroIndicaImprime]

;*********

	fild dword[reserva]  ; el resultado se guarda pero aun no ha sido multiplicado por tres
	fild dword[tres]
	fmul st1		; se multiplica por tres para realizar la matriz
	

	fistp dword[reserva]
	fistp dword[basura]; el resultado de la multiplicacion columnas por tres es guardado en reserva y la pila se vacea
	mov edi,0
	mov esi,[reserva]
	call cambio  ; *********************se cambian los 0 por asterisco que son igual a -6 esto para una mejor presentacion
	call cambio2  ;*** quita la posicion 0 ultima numeroIndicaImprime-1 y numeroIndicaImprime x 2
	call colocaLiebrePerros  ;; funcion en la que se coloca la inical de los perros y una L que corresponde al de la liebre
	mov edi,0;*************************************************************************;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	escribe espacioSalto,lenEspacioSalto
	escribe espacioSalto,lenEspacioSalto
	jmp imprimeColumnas ; se imprimen las letras del abecedario en espanol para indicar las columnas esto es con proposito estetico


;*********************************************************************************
;se hace un ciclo que termine donde edi llegue a  la cantidad de columnas mas dos 
;ingresada por el usuario
;se mueve a res2 el 17 en ascii que signigica la letra A, cada vez se le aumenta a ese contador
;para que imprima A B C D etc

;*********************************************************************************
imprimeColumnas:
	escribe msgAsterisco0,lenAsterisco0
	escribe espacioSalto,lenEspacioSalto
imprimeColumnas1:
	add edi,17
	add edi,'0'
	mov[res2],edi
	escribe espacio1,lenEspacio1  ;; hacer comparacion si edi es mayor que 9 que imprima ABCD etc
	escribe res2,2
	mov esi,[reserva2]
	sub edi,'0'
	sub edi,17
	add edi,1
	cmp edi,esi
	jb imprimeColumnas1
	escribe espacioSalto,lenEspacioSalto
	mov edi,1
	escribe espacio1,lenEspacio1
	jmp imprimeRaya
;;*********************************************************************************
;se imprime una raya para separar las letras de las columnas con la matriz utilizada 
;en el juego
;*********************************************************************************

imprimeRaya:
	escribe raya,lenRaya
	escribe espacioRaya,lenEspacioRaya
	
	mov esi,[reserva2]
	add edi,1
	cmp edi,esi
	jb imprimeRaya
	escribe espacioSalto,lenEspacioSalto
	;mov edi,0
	jmp imprimeMatriz

;;*********************************************************************************
;se inicia el proceso de imprimir el arreglo como matriz
;primero se inicializan alguno registros en 0 que serviran como contadores
;reserva contendra todos los elementos de la matriz por ejemplo si el usuario digito
; 3 columnas rerserva contiene 3+2  * 3 igual 15
;y el dd numeroIndicaImprime contiene el 5 en ese caso esto es sin multiplicarlo por
;la cantidad de filas
;*********************************************************************************

imprimeMatriz:  ; se inicializan algunos contadores

	mov  eax,0
	push eax
	mov edi,0;; funcionara como contador para imprimir la matriz
	mov esi,[reserva]
	escribe espacioSalto,lenEspacioSalto
	jmp imprimeMatriz1

;*********************************************************************************;*******************************
 ; se imprime la matriz de forma generica cada cierta cantidad de espacios se hace el salto de linea
 ;ejemplo si la matriz es de 4x3 cada 6 espacios se hace el salto; se le suman dos por los espacios a los lados
 ;*********************************************************************************;******************************
imprimeMatriz1:
	mov al,[arreglo+edi]
	add al,'0'
	mov [res],al
	;escribe msg,len
	escribe espacio1,lenEspacio1
	escribe res,2
	add edi,1
	pop eax
	add eax,1
	push eax
	mov ebx,[numeroIndicaImprime] ; ebx contendra la cantidad de columnas ingresada por el usuario mas el dos
	cmp eax,ebx ; cuando eax sea igual que ebx se hace un salto de linea ya que llego al final de la fila
	jb imprimeMatriz1; y se ocupa imprimir en forma de matriz
	escribe espacioSalto,lenEspacioSalto
	mov eax,0
	push eax
	cmp edi,esi
	jb imprimeMatriz1 ;cuando edi sea igual que esi significa que ya imprimio toda la cantidad de elementos

;;; random;;;;;;;;;;;;;;;;;;;;;;;;;

	mov al,[indicador]  ; el indicador indica que turno es ya sea el de la liebre o el de los perros
	cmp al,0 ; si es cero significa que se esta en el turno de la liebre y si es uno proccede al turno de los perros
	je mueveLiebre
	jmp muevePerros

;*********************************************************************************
;funcion en la que se le pregunta al usuario que letra quiere movilizar el caracter
;ingresaddo por el usuario es almacenado en resMueve luego es comparado con la inicial
;de cada uno de los perros si no corresponde a ninguna vuelve a preguntar que perro
;quiere mover hasta que indique un caracter valido
;*********************************************************************************
muevePerros:
	escribe espacioSalto,lenEspacioSalto
	escribe msgMuevePerro,lenMuevePerro
	mov ecx,[resMueve]
	xor ecx,ecx
	mov[resMueve],ecx
	mov eax,3
	mov ebx,0
	mov ecx,resMueve
	mov edx,10
	int 0x80
	
	mov al,[perroNumero1]
	sub al,'0'
	mov bl,[perroNumero2]
	sub bl,'0'
	mov dl,[perroNumero3]
	sub dl,'0'

	mov cl,[resMueve] ;; contiene la letra ingresada por el usuario
	sub cl,'0'

	cmp cl,al  ; se compara si la inicial indicada por el usuario corresponde a la de algun
	je busquedaInicial ; nombre de perro
	cmp cl,bl		; en caso de que no se vuelve a solicitar el ingreso de una inical valida
	je busquedaInicial
	cmp cl,dl
	je busquedaInicial   ; recorrer mattriz y buscar esa letra para saber que posicion tiene
	jmp muevePerros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;******************************************************************************************************
;funcion en la que se recorre el arreglo en busca de esa letra
;que representa la de algun perro o de la liebre , cuando la encuentre se guarda la posicion en un dd
; llamado contador
;******************************************************************************************************

busquedaInicial:
	mov edi,0  ; se utiliza edi como contador cada vez se le ira sumando uno hasta que encuentre la letra
	jmp busquedaInicial2

busquedaInicial2:
	mov [resIndica],cl
	mov al,[arreglo+edi]
	cmp al,cl
	je introducirEdi ; al encontrar la letra brinca a introducirEdi que se almacena en contador la posicion
	add edi,1		; en donde esta esa letra
	jmp busquedaInicial2 ;

introducirEdi:
	mov [contador],edi
	fild dword[contador]
	jmp muevePerros2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;funcion en que se solicita que digite la letra inicial de la liebre 
;en este caso seria la *L* se guarda en la reserva llamada resMueve
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mueveLiebre:
	escribe espacioSalto,lenEspacioSalto
	escribe msgMueveLiebre,lenMueveLiebre
	mov eax,3
	mov ebx,0
	mov ecx,resMueve ; lo que digite el usuario se almacena en resMueve 
	mov edx,10; se hace de 10porque el usuario puede digital algun nombre largo
	int 0x80
	
	mov cl,[resMueve]
	sub cl,'0'
	cmp cl,28
	je busquedaInicial;;;;;;;;;;;;;;; si digita la correcta brinca a la funcion llamada busquedaInicial que guarda la posicon en donde esta la letra
	jmp mueveLiebre  ; si se digita algo indebido se vuelve a solicitar la inicial de la liebre
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;************************************************************************************************************************************
;*Funcion en la que se imprimen todos los posibles movimientos 																		*
;*Luego se le pregunta al usauario que movimiento quiere hacer																		*
;*----------------------------------------------------------------------------------------------------------------------------------*
;*Aqui se muestra:																													*
;*----------------------------------------------------------------------------------------------------------------------------------*
;*		;"+ Moverse hacia arriba.................Digite *** 1"		; aparte de ello coniene el 9 que significa guardar partida		*
;*		;"+ Moverse hacia abajo..................Digite *** 2"																		*
;*		;"+ Moverse hacia la derecha.............Digite *** 3"																		*
;*		;"+ Moverse hacia la izquierda...........Digite *** 4"																		*
;*		;"+ Moverse diagonal derecha arriba......Digite *** 5"																		*
;*		;"+ Moverse diagonal izquierda arriba....Digite *** 6"																		*
;*		;"+ Moverse diagonal derecha abajo.......Digite *** 7"																		*
;*		;"+ Moverse diagonal izquierda abajo.....Digite *** 8"																		*
;*		;"+ Guardar juego........................Digite *** 9"																		*
;************************************************************************************************************************************

muevePerros2:  ;;; el usuario indica la posicion en que se quiere mover se imprimen los controles del juego 
	escribe espacioSalto,lenEspacioSalto
	escribe msgFigura0,lenFigura0
	escribe msgControlesRaya,lenMsgControles
	escribe espacioSalto,lenEspacioSalto

	escribe msgElegirControl,lenElegirControl ;; se solicita que indique el movimiento mediante el numero
	mov eax,3
	mov ebx,0
	mov ecx,resMueve 
	mov edx,10 ; se hace una reserva de 10 por que el usuario puede digitar un numero de varios digitos
	int 0x80
	mov al,[resMueve]
	sub al,'0'
	cmp al,0  ; si es menor que 1 solicita un movimiento valido
	jb muevePerros2
	cmp al,9  ; si es mayor que 9 vuelve a solicitar que indique un movimiento valido
	ja muevePerros2
	mov bl,[resMueve+1]
	sub bl,'0'
	cmp bl,218  ; verifica si el numero es de un digito
	je verificaMovimiento; 	si es de un digito procede a mover la ficha
	jmp muevePerros2 ; si no fuese asi se solicita un movimiento valido

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;****************************************************************************************
;funcion en la que se verifica cual es el movimiento que quiere realizar el juego
;los  numeros validos son del 1 al 8 ya que con el 9 se guardaba el juego
;****************************************************************************************
verificaMovimiento:
	mov al,[resMueve]
	sub al,'0'
	cmp al,1
	je muevePerros3Arriba	; si es 1 se moviliza hacia arriba
	cmp al,2
	je muevePerros3Abajo	; si es 2 se moviliza hacia abajo
	cmp al,3
	je muevePerros3Derecha ; si es 3 se moviliza hacia derecha
	cmp al,4     ;;;;;;;;;;; si es 4 se moviliza hacia izquierda
	je muevePerros3Izquierda
	cmp al,5				; si es 5 se moviliza hacia diagonal derecha arriba
	je mueverPerrros3DiagonalDerechaArriba
	cmp al,6			; si es 6 se moviliza hacia diagonal izquierda arriba
	je mueverPerrros3DiagonalIzquierdaArriba
	cmp al,7			; si es 7 se moviliza hacia diagonal derecha abajo
	je mueverPerrros3DiagonalDerechaAbajo
	cmp al,8       ; si es 8 se moviliza hacia diagonal izquierda abajo
	je mueverPerrros3DiagonalIzquierdaAbajo
	cmp al,9   ; procede a guardar el juego luego sale de la partida
	je guardarArreglo
	cmp al,0
	je salida
;***********************************************************************************************
; funcion en la que se mueve el perro o liebre hacia arriba
; para ello primero se le resta a la posicion en donde esta la lettra
; el numero de columnas luego se compara si es un * -6 si es asi;
;quiere decir que es un movimiento valido por lo tanto hace el movimiento
; si en la posicion que se fuera a mover no hay un -6 entonces es un movimiento invalido
;y vuelve a solicitar que indique un movimiento valido
;***********************************************************************************************
muevePerros3Arriba:
	;fild dword[contador]
	fistp dword[contador1]

	mov esi,[contador1]
	mov al,[arreglo+esi]
	cmp al,28  ; se compara si es la liebre que se va movilizar
	je msjMueveArribaLiebre  

	fild dword[reserva2]; se introduce la posicon en donde esta 
	fild dword[contador]	; y el numero de columnas
	fsub st1

	fistp dword[contador]
	fistp dword[basura]
	
	mov edi,[contador]
	mov al,[arreglo+edi]
	cmp al,-6  ; se compara si es un * en ascii
	je sumaIndicativo; funcion en la que se cuentan los movimientos de los perros cuando llegue al 10 si se 
	jmp msjHaceMovimiento2	; hacen consecutivos entonces la liebre gana

msjMueveArribaLiebre:
	fild dword[reserva2]; se introduce la posicion y el numero de columnas a la pila
	fild dword[contador]
	fsub st1
	call msjHaceMovimiento
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;***********************************************************************************************
; funcion en la que se mueve el perro o liebre hacia abajo
; para ello primero se le suma a la posicion en donde esta la lettra
; el numero de columnas luego se compara si es un * -6 si es asi;
;quiere decir que es un movimiento valido por lo tanto hace el movimiento
; si en la posicion que se fuera a mover no hay un -6 entonces es un movimiento invalido
;y vuelve a solicitar que indique un movimiento valido
;***********************************************************************************************	
muevePerros3Abajo:
	;fild dword[contador]
	fistp dword[contador1]

	mov esi,[contador1]
	mov al,[arreglo+esi]
	cmp al,28 ; se compara si es la liebre que se va movilizar
	je msjMueveAbajoLiebre

	fild dword[contador]; se introduce la posicon en donde esta
	fild dword[reserva2]; y el numero de columnas
	fadd st1
	
	fistp dword[contador]
	fistp dword[basura]
	
	mov edi,[contador]
	mov al,[arreglo+edi]
	cmp al,-6; se compara si es un *  en ascii
	je sumaIndicativo; funcion en la que se cuentan los movimientos de los perros cuando llegue al 10 si se 
	jmp msjHaceMovimiento2; hacen consecutivos entonces la liebre gana

sumaIndicativo: ; compara en caso de que cuando los perros se mueven arriba abjo 10 veces consecutivos
	mov al,[indicativo]	; la liebre gane
	add al,1
	mov[indicativo],al  ; en caso de que el perro se mueva en otra posicion que no sea abajo ni arriba el contador se resetea
	cmp al,10
	je ganaLiebre
	jmp haceMovimiento
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

msjMueveAbajoLiebre:
	fild dword[reserva2]; ; se introduce la posicion y el numero de columnas a la pila
	fild dword[contador]
	fadd st1  ; se realiza la suma
	call msjHaceMovimiento
	


;***********************************************************************************************
; funcion en la que se mueve el perro o liebre hacia la derecha
; para ello primero se le suma a la posicion en donde esta la letra
; el numero de uno luego se compara si es un * -6 si es asi;
;quiere decir que es un movimiento valido por lo tanto hace el movimiento
; si en la posicion que se fuera a mover no hay un -6 entonces es un movimiento invalido
;y vuelve a solicitar que indique un movimiento valido
;***********************************************************************************************	
muevePerros3Derecha:
	;fild dword[contador]
	fistp dword[contador1]
	
	fild dword[uno]; se ingresa el uno
	fild dword[contador] ; luego la posicion en donde este
	fadd st1  ; se hace la suma
	call msjHaceMovimiento ;se procede a hacer el movimiento

;***********************************************************************************************
; funcion en la que se mueve la liebre hacia la izquiedaa
; para ello primero se le resta a la posicion en donde esta la lettra
; el numero uno luego se compara si es un * -6 si es asi;
;quiere decir que es un movimiento valido por lo tanto hace el movimiento
; si en la posicion que se fuera a mover no hay un -6 entonces es un movimiento invalido
;y vuelve a solicitar que indique un movimiento valido
;***********************************************************************************************;
muevePerros3Izquierda:
	mov edi,[contador]
	mov al,[arreglo+edi]
	cmp al,28  ;; es validado si es una liebre ya que en este caso si se le permite el movimieno a la izquierda
	je muevePerros3Izquierda2; en cambio a los perros no
	jmp msjHaceMovimiento2 ; si no es liebre se dirige aimprimir un mensaje indicando que no fue posible el movimiento 


muevePerros3Izquierda2:
	;fild dword[contador]
	fistp dword[contador1]
	
	fild dword[uno]; si es liebre se ingresa uno
	fild dword[contador] ; luego se ingresa la posicion en donde este
	fsub st1 ; se hace la resta
	call msjHaceMovimiento;se procede a hacer el movimiento

;***********************************************************************************************;
; funcion en la que primero se verficia si arriba y abajo hay un espacio vacio ya que si fuese asi
; indica que esta en un extremo por lo que no es posile este movimiento
;***********************************************************************************************;
mueverPerrros3DiagonalDerechaArriba:
	;fistp dword[contador1]
	fild dword[reserva2]; es intoducido la cantidad de columnas
	fadd st1 ; se hace la suma de la cantidad de columnas con la posicion en donde este la letra
	fistp dword[contador1]
	fistp dword[basura]
	mov esi,[contador1]
	mov al,[arreglo+esi]
	cmp al,-16  ; se compara si arriba de la posicion existe un espacio vacio
	je compara2
	jmp siSePuedeMoverDiagonalDerecha

compara2:
	fild dword[reserva2]; es introducido la cantidad de columnas 
	fild dword[contador]
	fsub st1; se hace la resta de la cantidad de columnas con la posicion en donde este la letra
	fistp dword[contador1]
	fistp dword[basura]
	mov esi,[contador1]
	mov al,[arreglo+esi]
	cmp al,-16; se compara si abajo de la posicion existe un espacio vacio
	je msjHaceMovimiento2	; si arriba y abajo hay un espacio vacio imprime un mensaje que no puede ser posible el movimiento por lo tanto solicita
	jmp siSePuedeMoverDiagonalDerecha ; de nuevue el movimiento que se quiere

;**************************************************************************************************************
;al no existir arriba ni abajo un espacio vacio entonces se proce a verificar si se encuentra
; en una posicion impar si es asi entonces el movimiento se realiza adecuadaamente 
; tambien se debe verificar si a la poscion en que se va mover existe un -6 para que no sobreescribir una letra
;de un perro o liebre o no colocarla en unlugar incorrecto
;**************************************************************************************************************

siSePuedeMoverDiagonalDerecha:
	fild dword[contador]
	call diagonales
	sub al,1
	mov[reserva3],al
	fild dword[reserva3]; ; se introduce reserva3 que contiene la posicion en donde esta menos uno
	fild dword[contador]
	fsub st1
	call msjHaceMovimiento


;**************************************************************************************************************
;funcion en la que se verifica si la letra que se va mover es una L en caso de que si se procede a otra funcion
; en la que se verifica si al  campos en que se va mover existe un * representado con -6
; si fueese asi realiza el movimiento pero si no  , entonces se dirige de nuevo a la funcion en la que
;se solicita un numero valido de movimiento
;**************************************************************************************************************

mueverPerrros3DiagonalIzquierdaArriba:
	mov edi,[contador]
	mov al,[arreglo+edi]
	cmp al,28
	je mueverPerrros3DiagonalIzquierdaArriba2
	jmp msjHaceMovimiento2

;**************************************************************************************************************
; funcion a la que brinca la anterior en caso de lo que se fuese a mover sea la liebre ya que los perros tienen
; limittado el movimiento hacia la izquierda
;**************************************************************************************************************
mueverPerrros3DiagonalIzquierdaArriba2:
	call diagonales
	add al,1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cambio
	mov[reserva3],al
	fild dword[reserva3]; se introduce reserva3 que contiene la posicion en donde esta mas uno
	fild dword[contador]
	fsub st1
	call msjHaceMovimiento

;**************************************************************************************************************
;funcion en la que se verifica si el campos al que se va mover existe un * representado con -6
; si fueese asi realiza el movimiento pero si no  , entonces se dirige de nuevo a la funcion en la que
;se solicita un numero valido de movimiento
;**************************************************************************************************************

mueverPerrros3DiagonalDerechaAbajo:
	call diagonales
	add al,1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cambio
	mov[reserva3],al
	fild dword[reserva3];; se introduce reserva3 que contiene la posicion en donde esta menos uno
	fild dword[contador]
	fadd st1
	call msjHaceMovimiento

;**************************************************************************************************************
;funcion en la que se verifica si la letra que se va mover es una L en caso de que si se procede a otra funcion
; en la que se verifica si al  campos en que se va mover existe un * representado con -6
; si fueese asi realiza el movimiento pero si no  , entonces se dirige de nuevo a la funcion en la que
;se solicita un numero valido de movimiento
;**************************************************************************************************************

mueverPerrros3DiagonalIzquierdaAbajo:
	mov edi,[contador]
	mov al,[arreglo+edi]
	cmp al,28
	je mueverPerrros3DiagonalIzquierdaAbajo2
	jmp msjHaceMovimiento2


;**************************************************************************************************************
; funcion a la que brinca la anterior en caso de lo que se fuese a mover sea la liebre ya que los perros tienen
; limittado el movimiento hacia la izquierda
;**************************************************************************************************************
mueverPerrros3DiagonalIzquierdaAbajo2:
	call diagonales
	sub al,1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cambio
	mov[reserva3],al
	fild dword[reserva3]; ; se introduce reserva3 que contiene la posicion en donde esta mas uno
	fild dword[contador]
	fadd st1
	call msjHaceMovimiento
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**************************************************************************************************************
;funcion en que se realize el movimiento en la posicion que se quiere mover se coloca la letra
;y en la posicon en donde se encontraba le letra es colocado un -6 que representa un *
;**************************************************************************************************************
haceMovimiento:
	mov esi,[contador1]
	mov cl,[arreglo+esi]
	mov bl,-6
	mov[arreglo+esi],bl
	mov[arreglo+edi],cl

	mov edi,0;*************************************************************************;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	escribe espacioSalto,lenEspacioSalto
	escribe espacioSalto,lenEspacioSalto    ; en este mensaje se muesra al usuario que el movimiento fue realizado satisfactoriamente
	escribe espacioSalto,lenEspacioSalto
	escribe msgRayaMsg,lenMsgRaya
	escribe msgValido,lenMsgValido
	escribe msgRayaMsg,lenMsgRaya
	escribe espacioSalto,lenEspacioSalto
	escribe espacioSalto,lenEspacioSalto
	
	mov al,[indicador]   ; el indicador va cambiar cuando la liebre o perro realizen el movimiento correctamente 
	cmp al,0		; si el indicador fuese un cero entonces es cambiado por un 1 indicando que va el perro 
	je cambiarUno	; y si fuese cero se cambia por uno indicando que va la liebre
	mov al,0
	mov[indicador],al
	jmp verificaGane ; luego de realizar el movimiento se brinca a verificaGane que evalua si se ha cumplido alguna de las
	;3 distintas formas de ganar
	; ya sea:

;	*;*********************************************************
;	*;acorralar a la liebre									  *
;   *;moverse los perros 10 veces consecutivas arriba o abajo *
;	*;si la liebre queda al a izquierda de todos los perros   *
;	*;*********************************************************

;**************************************************************************************************************
;funcion en la que el indicador es cambiado por uno ya que era el turno de la liebre
;**************************************************************************************************************
cambiarUno:
	mov al,1
	mov[indicador],al
	jmp verificaGane ; luego de realizar el movimiento se brinca a verificaGane que evalua si se ha cumplido alguna de las
	;3 distintas formas de ganar
	; ya sea:

;	*;*********************************************************
;	*;acorralar a la liebre									  *
;   *;moverse los perros 10 veces consecutivas arriba o abajo *
;	*;si la liebre queda al a izquierda de todos los perros   *
;	*;*********************************************************


;**************************************************************************************************************
;funcion de salida en donde se finaliza la partida 
;se utiliza el servio uno ya que indica que es el sysexit
;**************************************************************************************************************

salida:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	escribe espacioSalto,lenEspacioSalto
	escribe espacioSalto,lenEspacioSalto
	escribe espacioSalto,lenEspacioSalto
	escribe msgSalida0,lenSalida0
	mov eax,1
	int 0x80


;****************************************
; funciones que se llaman;;;;;;;;;;;;;;;;
;****************************************
;Son:
;------------------------------------------
	;cambio 
	;cambio2
	;colocaLebrePerros
;------------------------------------------

;***********************************************************************************************
;Funcion en la que se recorre la matriz y convierte todo en puntos que es representado con un -6
;***********************************************************************************************

cambio:
	mov al,-6
	mov [arreglo+edi],al
	add edi,1
	cmp edi,esi 
	jb cambio
	ret


;*********************************************************************************
; funcion que lo que hace es quitar los espacios que no son necesarios para dejar
; los dos campos a los lados con espacios vacios que es representado con un -16
;*********************************************************************************

cambio2:

	mov al,-16
	mov [arreglo],al  ;; posicion  cero  ; quita el -6 y lo cambia por un -16 
	
	fild dword[numeroIndicaImprime]
	fild dword [dos]
	fmul st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	mov edi,[numeroColumnas]
	mov [arreglo+edi],al ; quita el que se encuentre en la esquina izquierda de abajo y lo cambia por un -16
	

	fild dword[numeroIndicaImprime]
	fild dword[tres]
	fmul st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	fild dword[uno]
	fild dword[numeroColumnas]
	fsub st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	mov edi,[numeroColumnas]
	mov [arreglo+edi],al; el ultimo elemento es cambiado por un -16 para ello se le resta menos uno y se multiplica por tres filas

	fild dword[uno]
	fild dword[numeroIndicaImprime]
	fsub st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	mov edi,[numeroColumnas]
	mov [arreglo+edi],al ; el elemeto ubicado en la esquina superior derecha es cambiado por un -16 par ello se ingresa el numero de columnas luego un uno y se restan 
	ret


;***************************************************************************************************************
;Funcion que se llama solo una vez ya que es la que se encarga de colocar a la letra L y a las iniciales de los 
; perros al inicio del juego
;***************************************************************************************************************

colocaLiebrePerros:
	mov al,[perroNumero1]  ;; se utiliza para colocar las letras
	sub al,'0'
	mov bl,28  ;; significa la L de la liebre con ello sera representado

	mov [arreglo+1],al; primer perrro colocado el primer perro se coloca en la posicon uno 
	
	mov al,[perroNumero2]
	sub al,'0'
	mov edi,[numeroIndicaImprime]
	mov [arreglo+edi],al	; segundo perro colocado
	; es colocado en la posicion de la cantidad de columnas mas el 2 esto indica que queda al inicio de la segunda fila

	fild dword[numeroIndicaImprime]
	fild dword[dos]
	fmul st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	fild dword[uno]		
	fild dword[numeroColumnas]
	fsub st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	mov edi,[numeroColumnas]
	mov [arreglo+edi],bl ; liebre colocada en posicion inicial es colocada al final de la segunda fila

	mov al,[perroNumero3]
	sub al,'0'
	fild dword[numeroIndicaImprime]
	fild dword[dos]
	fmul st1
	fild dword[uno]
	fadd st1
	fistp dword[numeroColumnas]
	fistp dword[basura]
	fistp dword[basura]		; tercer perro colocado en posicion inicial significa que se coloca en la posicion uno de la tercer fila
	mov edi,[numeroColumnas]
	mov [arreglo+edi],al 	
	ret

;*****************************************************************************************************
;funcion en que se verifica si la posicion en donde se va ser el movimiento contiene
; un -6 esto significa que sera un * y es posible colocaar una letra que represente un perro liebre ahi
;;*****************************************************************************************************
msjHaceMovimiento:
	fistp dword[contador]
	fistp dword[basura]
	

	mov edi,[contador]
	mov al,[arreglo+edi]
	cmp al,-6
	je haceMovimiento11
	jmp msjHaceMovimiento2 ; en caso de que no hubiese un  * se muestra un mensaje haciendole saber al usuario que el 
						; el movimiento no fue posible realizarlo y luego se envia a que indique nuevamente un numero valido

;***************************************************************************************************************
;funcion en la que si la liebre se va mover no se hace el reseteo del conador que va llevando la cuenta de los movimientos
;de arriba o abajo que hacen los perros consecutivamente
;***************************************************************************************************************
;en cambio si un perro es el que se va movilizar el contador se coloca en 0 ya que indica que el perro se va mover
; diagonal o hacia la derecha
;***************************************************************************************************************
haceMovimiento11:
	mov esi,[contador1]
	mov al,[arreglo+esi]
	cmp al,28  ; es comparado si es la liebre quien se va mover
	je noReseteo ; por lo tanto no se vuelve a inicializar el contador 
	mov al,0  ; en cambio si es un perro se procede a resetear el contador 
	mov [indicativo],al
	jmp haceMovimiento 

noReseteo:  ; es donde se brinca si es la liebre que se va mover ; aqui no es reseteado el contador
	jmp haceMovimiento

;***************************************************************************************************************
;funcion que indica al usuario que el movimiento efectuado no se ha llevao a cabo
;ya que es invalido
;luego de indicar ese mensaje se imprime la matriz y se solicita un movimiento valido
;***************************************************************************************************************
msjHaceMovimiento2:
	escribe espacioSalto,lenEspacioSalto
	escribe msgRayaMsg,lenMsgRaya
	escribe msgInvalido,lenMsgInvalido
	escribe msgRayaMsg,lenMsgRaya
	escribe espacioSalto,lenEspacioSalto
	mov al,[resIndica]
	mov edi,0
	jmp imprimeColumnas
	;muevePerros
;********************************************************************************************************************
;funcion en la que se introduce la poscion en que esta luego se introduce un dos ahi se divide y el resultado
;es guardado luego se mete un dos y el resultado se multiplican y se compara con la posicion si son iguales
;quiere decir que es una posicion par por lo que no es posible mover diagonalmente
;en camvio si es posicon impar nso damos cuenta si el resultado dado no es igual a la posicion , entonces si se hace
;el movimiento en diagonal
;********************************************************************************************************************

diagonales:
	fistp dword[contador2]
	fild dword[dos]
	fild dword[contador2]
	fdiv st1
	fistp dword[contador2]
	fistp dword[basura]
	fild dword[contador2]
	fild dword[dos]
	fmul st1
	fistp dword[contador2]
	fistp dword[basura]
	
	mov al,[contador]
	mov bl,[contador2]
	cmp al,bl  ; se compara con la posicion en donde se encontraba la letra si son iguales entonces se indica al usuario que el movimiento no puede realizarse
	je msjHaceMovimiento2  ;;;;;;;;;; no se puede mover
	fild dword[contador]
	fistp dword[contador1] ; si fuese una posicion impar se procede a devolvese donde fue llamada la funcion
	mov al,[reserva2]
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;************************************************************************************************************************
;funcion en la que se introducen los nombres de los perros para tomar la inicial y restarles los '0'. luego se recorre
; el arrego y cuando la posicion del arreglo corresponda a la letra inicial de alguno de los peros o liebre sera guardado
;es importante mencionar que cada vez que se salta a una fila nueva el contador se inicializa
; el ciclo termina cuando haya recorrido todo el arreglo
;**************************************************************************************************************************
	verificaGane:
		mov edi,0
		mov al,[verificador]
		mov al,0
		mov[verificador],al


		mov al,[reserva2]
		mov bl,[cero]
		mov[primeraVariable],bl
		mov[segundaVariable],al
	

	ciclo:
		mov bl,[primeraVariable]
		mov al,[segundaVariable]
		mov esi,0
;		add edi,1

	ciclo1:
		mov cl,[perroNumero1]  
		sub cl,'0'
		mov dl,[arreglo+edi]  ; se realiza la comparacion del perro 1 con el contenido de la posicion del arreglo
		cmp cl,dl
		je metoPrimerNombre ; si son iguales entonces la posicion se guarda en una reserva llamada perro1
		
		mov cl,[perroNumero2]
		sub cl,'0'
		mov dl,[arreglo+edi]
		cmp cl,dl  ; se realiza la comparacion del perro 2 con el contenido de la posicion del arreglo
		je metoSegundoNombre; si son iguales entonces la posicion se guarda en una reserva llamada perro2
		
		mov cl,[perroNumero3]
		sub cl,'0'
		mov dl,[arreglo+edi]
		cmp cl,dl ; se realiza la comparacion del perro 3 con el contenido de la posicion del arreglo
		je metoTercerNombre; si son iguales entonces la posicion se guarda en una reserva llamada perro3
		
		mov dl,[arreglo+edi]
		cmp dl,28 ; se realiza la comparacion de la liebre con el contenido de la posicion del arreglo
		je metoLiebreNombre; si son iguales entonces la posicion se guarda en una reserva llamada liebre
		
		add bl,1
		add edi,1   ; al contiene la cantidad de columnas
		add esi,1
		cmp bl,al ; se verifica que no se haya recorrido toda la filas
		jb ciclo1 ; si no se ha recorrido entonces se vuelve al ciclo1
		jmp verificarTresCiclos  ; en caso de que si se recorriera entonces brinca a la funcioon en donde se verificara si ya se recorrieron las 3 filas

;**************************************************************************
;funcion en la que se guara la poscion que ubica al primer perro en la fila
;es introducido en la reserva llamada perro1
;**************************************************************************
	metoPrimerNombre:
		mov[perro1],esi
		add esi,1
		add edi,1
		add bl,1
		jmp ciclo1
;**************************************************************************
;funcion en la que se guara la poscion que ubica al segundo perro en la fila
;es introducido en la reserva llamada perro2
;**************************************************************************
	metoSegundoNombre:
		mov[perro2],esi
		add esi,1
		add edi,1
		add bl,1
		jmp ciclo1

;**************************************************************************
;funcion en la que se guara la poscion que ubica al tercer perro en la fila
;es introducido en la reserva llamada perro3
;**************************************************************************
	metoTercerNombre:
		mov[perro3],esi
		add esi,1
		add edi,1
		add bl,1
		jmp ciclo1

;**************************************************************************
;funcion en la que se guara la poscion que ubica a la liebre en la fila
;es introducido en la reserva llamada liebre
;**************************************************************************
	metoLiebreNombre:
		mov[liebre],esi
		add esi,1
		add edi,1
		add bl,1
		jmp ciclo1

;**************************************************************************
;funcion en la que se verifica si a se han recorrido las 3 filas
; en caso de que si se procedera a comparaar las posiciones del 
;		perro1
;		perro2
;		perro3
;		liebre
;**************************************************************************
	verificarTresCiclos:
		fild dword[primeraVariable]
		fild dword[reserva2]
		fadd st1
		fistp dword[primeraVariable]
		fistp dword[basura]

		fild dword[segundaVariable]
		fild dword[reserva2]
		fadd st1
		fistp dword[segundaVariable]
		fistp dword[basura]
		
		mov al,[verificador]
		add al,1
		mov[verificador],al
		cmp al,3
		jb ciclo  ; si el verificador es menor a 3 que indica la cantidad de filas entonces brinca al ciclo en donde se sigue comparando 
		; si la posicioon del arreglo es igual a alguna incial del perro o liebre

;**************************************************************************
;indica que ya se recorrieron
;las 3 filas
;**************************************************************************
		mov al,[liebre]
		mov bl,[perro1]
		mov cl,[perro2]
		mov dl,[perro3]
		cmp al,bl  ; se compara la posicion de la liebre con la del perro 1 si es menor brinca a la siguiente comparacion 
		jb comparaPerro2
		;mov edi,0
		jmp verificaGanePerros	; si no fuese menor entonces brinca a la segunda forma posible de ganar llamada verficaGanePerros


comparaPerro2:
	cmp al,cl
	jb comparaPerro3 ; se compara la posicion de la liebre con la del perro 1 si es menor brinca a la siguiente comparacion
	mov edi,0
	jmp verificaGanePerros; si no fuese menor entonces brinca a la segunda forma posible de ganar llamada verficaGanePerros


comparaPerro3:
	cmp al,dl
	jb ganaLiebre ; si compara la poscion de la liebre con la posicon del  perro 3 y es menor esto indica que gano la liebre ya 
					; que logro estar a la izquierda de todos  los perros
	jmp verificaGanePerros; si no fuese menor entonces brinca a la segunda forma posible de ganar llamada verficaGanePerros

;*********************************************************************************************
;Al ganar liebre se dirige a esta funcion en donde se muetra un mensaje indicando que gano 
; y luego se le solicita la opcion de que si quiere:
;---------------------------------------------------------------------------------------------
			;reiniciar el juego
			;jugar con los mismos jugaadores
			;salir de la partida
;*********************************************************************************************
ganaLiebre:
	escribe msgLiebre0,lenLiebre0
	escribe msgEleccion0,lenMsgEleccion
	jmp solicitaOpcion ; funcion en donde se muestran las 3 opciones mencionadas anteriormente
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;******************************************************************************************************
;funcion en donde se recorre el arreglo y una vez que se encuentre la letra L se brinca a otra funcion
;encargada de verificar si la posicion en donde se encuentra es par o no
; en caso de que no fuese par entonces solo se verifica arriba abajo izquierda derecha para saber si 
; se encuentra acorralada o no
; como son 4 lados entonces un lado debe ser vacio ya que se encuentra en un extremo ;
;si eso pasara entonces la liebre pierde por no tener movimiento alguno
;*******************************************************************************************************
verificaGanePerros:
	mov edi,0
	mov al,[arreglo+edi]
	mov bl,28
	jmp verificaGanePerros2

verificaGanePerros2:
	mov al,[arreglo+edi]
	cmp al,bl 
	je encuentraLiebre
	add edi,1
	mov esi,[reserva]
	cmp edi,esi
	jb verificaGanePerros2
; ;***************************************************************************************************************************
;funcion en donde se verifica si la poscion en donde la liebre se encuentra es par o no 
; para ello se realiza el procedimiento parecido que se utiliza para lo de las diagonales
;de dividir por 2 y luego multiplicar, al final se compara el resultado con la posicion si son iguales quiere decir que es par
; por lo que no es neceasario verificar diagnoles a ver si perdio o gano
; en cambio si fuese impar si se verifican diagonales
;******************************************************************************************************************************
encuentraLiebre:
	mov[encuentraLiebreContador],edi
	mov[encuentraLiebreContador],edi
	fild dword[dos]
	fild dword[encuentraLiebreContador]
	fdiv st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	fild dword[resultadoLiebre]
	fild dword[dos]
	fmul st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	mov al,[resultadoLiebre]
	mov bl,[encuentraLiebreContador]
	cmp al,bl ; se realiza la comparacion del resultado con la poscion en donde se encuentre la liebre
	je noNecesitaDiagonales ; quiere decir que la posicion es par
	jmp necesitaDiagonales; posicion impar

noNecesitaDiagonales:
	call comparaciones ;funcion que llama a comparaciones en donde se verfica si la liebre esta rodeada por perros
	jmp ganaCazador

necesitaDiagonales:
	call comparaciones;funcion que llama a comparaciones en donde se verfica si la liebre esta rodeada por perros
	call comparaciones2;funcion que llama a comparaciones2 en donde se verfica si la liebre esta rodeada por perros en sus diagonales
	jmp ganaCazador  ;;agregar diagonales;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


noGana:
	;jmp salida
	mov edi,0
	jmp imprimeColumnas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;**************************************************************************
;funcion que se lleva a cabo si la liebre es acorraladoa por los perros
; y se queda sin movimiento alguno

;*********************************************************************************************
;Al ganar cazador se dirige a esta funcion en donde se muetra un mensaje indicando que gano 
; y luego se le solicita la opcion de que si quiere:
;---------------------------------------------------------------------------------------------
			;reiniciar el juego
			;jugar con los mismos jugaadores
			;salir de la partida
;*********************************************************************************************
ganaCazador:
	escribe msgCazador0,lenCazador0
	escribe msgEleccion0,lenMsgEleccion
	jmp solicitaOpcion
;****************************************************************************************************

;Funcion que se lleva a cabo cuando el cazador o liebre ganan la partida 
; se indican las opciones de reiniciar el juego jugar con los mismos jugadores o salir de la partida
;*****************************************************************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
solicitaOpcion:
	escribe msjSuOpcion,lenMsjSuOpcion
	mov eax,3
	mov ebx,0
	mov ecx,eleccion
	mov edx,10
	int 0x80

	mov al,[eleccion]
	sub al,'0'
	cmp al,1
	jb numeroInvalido  ;se valida si es menor que uno
	cmp al,3
	ja numeroInvalido  ; se valida si es mayor que 3 ya que solo se tienen 3 opciones
	mov al,[eleccion+1]
	sub al,'0'
	cmp al,218 ; se compara el segundo digito con 218 si es asi entonces quiere decir que el usuario lo digito bien
	je comparaOpcionSolicitada
	jmp numeroInvalido; si el usuario digita un numero de dos o mas digitos se vuelve a solicitar la opcion

;**********************************************************************
;muestra un mensaje indicando que se digito algun caracter incorrecto
;por lo que se vuelve a solicitar la opcion
;*******************************************************************
numeroInvalido:
	escribe msgOpcion0,lenOpcion0
	jmp solicitaOpcion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;*********************************************************************************
;funcion en la que la opcion  indicada por el usuario se compara con 1 2 o 3 para 
;determinar que es lo que se debe realizar
;---------------------------------------------------------------------------------
;si fuese 1 entonces se dirige a la funcion de revancha
;si es 2 reinicia el juego
;si es 3 se sale de la partida
;---------------------------------------------------------------------------------

comparaOpcionSolicitada:
	mov al,[eleccion]
	sub al,'0'
	cmp al,1
	je revancha
	cmp al,2
	je _start
	cmp al,3
	je salida
	jmp salida

;***********************************************************************************************************************
;Funcion en la que se reinicia el indicativo que es el que cuenta la cantidad de veces que se mueven los 
;perros arriba abajo consecutivamente;tambien el indicador que es el que dice cual turno se lleva a cabo
;Se hacen unas llamadas a cambio que coloca todas las posiciones del arreglo con -6 que significan *
; tambien se llama a coloccaLiebrePerros que coloca a los perros y a la liebre en sus posiciones iniciales, por ultimo 
;se llama a cambio en la cual a las esquinas de la matriz se les coloca un -16 indicando un espacio vacio

;************************************************************************************************************************
revancha:
	mov al,0
	mov[indicativo],al
	mov al,0
	mov [indicador],al
	mov edi,0
	mov esi,[reserva]
	call cambio  ; funcion en la que se coloca en cada espacio del arreglo un -6 de acuerdo al tamano indicado por el usuario
	call cambio2; funcion en la que las esquinas de la matriz es colocado un -16 espacio vacio
	call colocaLiebrePerros; funcion en la que se colocan los perros y liebre en sus poscioines iniciales
	mov edi,0
	escribe espacioSalto,lenEspacioSalto
	escribe espacioSalto,lenEspacioSalto
	jmp imprimeColumnas ; luego se imprme las columnas y luego la matriz continuando con el proceso normal

;***********************************************************************************************************************
;Funcion en la que se verifica si arriba abajo izquierda y derecha de la posicion en donde se encuentra la liebre
;existe un caracter distinto a un -6 esto quiere decir que la liebre a quedado acorrala por lo tanto gana el cazador
;***********************************************************************************************************************


comparaciones:
	fild dword[encuentraLiebreContador] ; para esta comparacion a la posicion de la liebre se le suma uno ya que es a  la dereca
	fild dword[uno]
	fadd st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	mov esi,[resultadoLiebre]
	mov al,[arreglo+esi]  ; se compara si a la derecha de la liebre existe un caracter distinto a -6 
	cmp al,-6  ; derecha ;; si existiera un -6 quiere decir que no ha ganado porque la liebre aun tendria escapatoria
	je noGana
	
	fild dword[uno]
	fild dword[encuentraLiebreContador]; para esta comparacion a la posicion de la liebre se le resta uno ya que es a  la izquierda
	fsub st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	mov esi,[resultadoLiebre]
	mov al,[arreglo+esi]  ; se compara si a la izquierda de la liebre existe un caracter distinto a -6 
	cmp al,-6 	;izquierda
	je noGana ; si existiera un -6 quiere decir que no ha ganado porque la liebre aun tendria escapatoria

	fild dword[reserva2]   ;para ello a la posicion de la liebre se le suma la cantidad de columnas
	fild dword[encuentraLiebreContador] ;; abajo
	fadd st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	mov esi,[resultadoLiebre]; se compara si abajo de la liebre existe un caracter distinto a -6 
	mov al,[arreglo+esi]
	cmp al,-6 	;izquierda
	je noGana ; si existiera un -6 quiere decir que no ha ganado porque la liebre aun tendria escapatoria

	fild dword[reserva2]
	fild dword[encuentraLiebreContador] ;; a la posicion de la liebre se le resta la cantidad de columnas asi se verifica
	fsub st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	mov esi,[resultadoLiebre]
	mov al,[arreglo+esi] ; se compara si a arriba de la liebre existe un caracter distinto a -6 
	cmp al,-6 	;izquierda
	je noGana; si existiera un -6 quiere decir que no ha ganado porque la liebre aun tendria escapatoria
	ret ; si se llama en la funcion de que no necesita diagonales entonces ganara la liebre pero si necesita diagonales es decir
	;se encuentra en una posicion impar entonces se procede a llamar a comparaciones2 que se encarga de determinar
	;si en las diagonales de donde se encuentra la liebre hay un -6 o no
	;en caso de que no quiere decir que la liebre aun tiene escapatoria



;**************************************************************************************
;funcion en donde se compara si en las diagonales de la posicion en que se encuentra
;la liebre hay un -6 si fuese asi quiere decir que no ha ganado aun
;esto se realiza por que la liebre se encuentra en una posicion impar
;en caso de que en ambas diagonales se encuentre algun caracter distinto a -6 seria que 
;el cazador ha ganado la partida
;en caso de que no se procede a imprimir la matriz y solicitar de nuevo los movimientos
;**************************************************************************************

comparaciones2:
;** en este caso se compara la diagonal izquierda arriba
	;jmp salida
	fild dword[reserva2]  ; se inroduce la cantidad de columnas
	fild dword[uno] ;; se introduce el uno
	fadd st1  ; se hace la suma de la cantidad de columnas y  el uno 
	fistp dword[reserva4]; el resultado es almacenado en reserva4
	fistp dword[basura]; se vacia la pila
	fild dword[reserva4]
	fild dword[encuentraLiebreContador] ;;a la posicion de la liebre se le resta el resultado que dio reserva2 mas el uno 
	fsub st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	;fild dword[resultadoLiebre]
	mov esi,[resultadoLiebre]
	mov al,[arreglo+esi]
	cmp al,-6 	;izquierda ; se compara si existe un -6 que representa un asterisco
	je noGana ; si fuese un -6 quiere  decir que aun no ha ganado

;** en este caso se compara la diagonal izquierda abajo


	fild dword[uno];; se introduce el uno
	fild dword[reserva2]; se inroduce la cantidad de columnas
	fsub st1; se hace la resta de la cantidad de columnas y el uno
	fistp dword[reserva4]; se almacena en reserva5
	fistp dword[basura] ; se vacia la pila
	fild dword[reserva4]
	fild dword[encuentraLiebreContador] ;;a la posicion de la liebre se le suma el resultado que dio reserva2 mas el uno 
	fadd st1
	fistp dword[resultadoLiebre]
	fistp dword[basura]
	mov esi,[resultadoLiebre]
	mov al,[arreglo+esi]
	cmp al,-6 	;; se compara si existe un -6 que representa un asterisco
	je noGana ; si fuese un -6 quiere  decir que aun no ha ganado

	ret ; al llegar aqui quiere decir que gano el cazador ya que la liebre queda acorralada


;**********************************************************************************************
;funcion en donde se carga un archivo se utiliza el servico 5 la direccion que lo contiene el ebx
; en caso de que no hubiera un archivo creado se muestra un error al usuario y se devuelve al inicio
;**********************************************************************************************		
cargarArreglo:
		mov eax, 5 ;~ bandera para abrir un archivo
		mov ebx, dir ;~ pasa como parametro la ruta del archivo
		mov ecx, 0 ;~ modo para editar 0_RDWR
		int 80h
		test eax,eax  ; se hace un test de eax ya que contiene la cantidad de bytes
		js .error2 ; si resultase mal la carga se dirige a .error2

		mov ebx,eax  ; se lee lo que contiene el archivo
		mov eax,3  ; servicio de lectura
		mov ecx,arreglo ; es almacennado en la reserva llamada arreglo
		mov edx,300; se hace de un tamano de 300 ya que la  cantidad maxima de columnas es 99 y por 3 da 297 esta es la razon
		int 0x80
		mov edi,0
		jmp cargarArreglo2 ; se procede a cargar el otro archivo en el cual estan contenidos variables como lo es el indicativo indicador nombreDePerros

	.error2:
		escribe msgCarga0,lenCarga0
		mov ebx, eax ;el modo salida es el resultado de la llamada de systema fallida
		jmp _start ;~ se devuelve al inicio par indicando al usuario que no fue posible cargar
		
;**********************************************************************************************
;funcion en donde se carga un archivo se utiliza el servico 5 la direccion que lo contiene el ebx
; en caso de que no hubiera un archivo creado se muestra un error al usuario y se devuelve al inicio
;**********************************************************************************************		
cargarArreglo2:
		mov eax, 5 ;~ bandera para abrir un archivo
		mov ebx, dir2 ;~ pasa como parametro la ruta del archivo
		mov ecx, 0 ;~ modo para editar 0_RDWR
		int 80h
		test eax,eax ; se hace un test de eax ya que contiene la cantidad de bytes
		js .error4; si resultase mal la carga se dirige a .error4

		mov ebx,eax; se lee lo que contiene el archivo
		mov eax,3; servicio de lectura
		mov ecx,arreglo2; es almacennado en la reserva llamada arreglo2
		mov edx,300
		int 0x80
		mov al,[arreglo2]
		mov[reserva],al ; lo que se lee en la poscion 0 del archivo es la cantidad de columnas
		mov al,[arreglo2+1]
		mov[reserva2],al; lo que se lee en la poscion 1 del archivo es el tamano total del tablero
		mov al,[arreglo2+2]
		mov[numeroIndicaImprime],al; lo que se lee en la poscion 2 del archivo es la cantidad de columnas
		mov al,[arreglo2+3]
		mov[perroNumero1],al; lo que se lee en la poscion 3 del archivo es el nombre del primer perro
		mov al,[arreglo2+4]
		mov[perroNumero2],al; lo que se lee en la poscion 4 del archivo es el nombre del segundo perro
		mov al,[arreglo2+5]
		mov[perroNumero3],al; lo que se lee en la poscion 5 del archivo es el nombre del tercer perro
		mov al,[arreglo2+6]
		mov[indicativo],al; lo que se lee en la poscion 6 del archivo es el indicativo que contiene la cantidad de movimientos consecutivos hacia arriba o abajo que realicen los perros
		mov al,[arreglo2+7]
		mov[indicador],al; lo que se lee en la poscion 3 del archivo es el indicador que contiene el turno en que se esta ya sea 1 de perro o 0 de conejo
		mov edi,0
		jmp imprimeColumnas; luego se procede a imprimir las columnas imprimir matriz solicitar movimientos

	.error4:
		escribe msgCarga0,lenCarga0
		mov ebx, eax ;el modo salida es el resultado de la llamada de systema fallida
		jmp _start
		

;***********************************************************************************
;FUncion en la que se guarda primero el arreglo ; y luego se guarda en otro archivo
;las variables necesarias:
;como lo es:
	;*cantidad columnas
	;*tamano tablero
	;*nombres de perros
	;*indicativo
	;*indicador
;***********************************************************************************
;los archivos guardados se guardna en la carpeta en donde se encuentra el .asm 
;sus nombres son ranura.txt y ranura2.txt
;***********************************************************************************
guardarArreglo:
	 mov ebx, dir ;~ ruta del archivo
	mov eax, 8 ;~ bandera para crear el archivo
	mov ecx, 511 ;~ permisos
	int 80h

	cmp eax, 0 ;~ revisa que ha sido creado
	jbe .error ;~ si ocurre un error
	
	.abre_archivo:
		mov eax, 5 ;~ bandera para abrir un archivo
		mov ebx, dir ;~ pasa como parametro la ruta del archivo
		mov ecx, 1 ;~ modo para editar 0_RDWR
		int 80h

		cmp eax, 0 ;~ valida el Fd del archivo
		jbe .error ;~ si no es un Fd valido

		mov ebx, eax ;~ guarda el Fd
	
	.escribe_archivo:
		mov eax, 4 ;~ bandera para escribir
		mov edx, 300;~ cantidad de caracteres a imprimir
		mov ecx, arreglo ;~ buffer a imprimir
		int 80h

	.sync:
		mov eax, 36 ;~ bandera para sincronizar
		int 80h

	.close:
		mov eax, 6 ;~ bandera para cerrar un archivo
		int 80h

		jmp guardarArreglo2 ;~ brinca a espera ret y hacer call mae

	.error:
		escribe msgGuardar0,lenGuardar0
		mov ebx, eax ;el modo salida es el resultado de la llamada de systema fallida
		mov eax, 1 ;~ bandera para salir
		int 80h

guardarArreglo2:
	mov ebx, dir2 ;~ ruta del archivo
	mov eax, 8 ;~ bandera para crear el archivo
	mov ecx, 511 ;~ permisos
	int 80h

	cmp eax, 0 ;~ revisa que ha sido creado
	jbe .error3 ;~ si ocurre un error
	
	.abre_archivo1:
		mov eax, 5 ;~ bandera para abrir un archivo
		mov ebx, dir2 ;~ pasa como parametro la ruta del archivo
		mov ecx, 1 ;~ modo para editar 0_RDWR
		int 80h

		cmp eax, 0 ;~ valida el Fd del archivo
		jbe .error3 ;~ si no es un Fd valido

		mov ebx, eax ;~ guarda el Fd
	
	.escribe_archivo1:
		mov al,[reserva]; lo que se almacena en la poscion 0 del arreglo2 es la cantidad de columnas
		mov[arreglo2],al
		
		mov al,[reserva2]; lo que se almacena en la poscion 1 del arreglo2 es el tamano total del tablero
		mov [arreglo2+1],al

		mov al,[numeroIndicaImprime]; lo que se almacena en la poscion 2 del arreglo2 es la cantidad de columnas
		mov [arreglo2+2],al
		
		mov al,[perroNumero1]; lo que se almacena en la poscion 3 del arreglo2 es el nombre del primer perro
		mov [arreglo2+3],al

		mov al,[perroNumero2]; lo que se almacena en la poscion 4 del arreglo2 es el nombre del segundo perro
		mov [arreglo2+4],al

		mov al,[perroNumero3]; lo que se almacena en la poscion 5 del arreglo2 es el nombre del tercer perro
		mov [arreglo2+5],al

		mov al,[indicativo]; lo que se almacena en la poscion 6 del arreglo2 es el indicativo que contiene la cantidad de movimientos consecutivos hacia arriba o abajo que realicen los perros
		mov [arreglo2+6],al

		mov al,[indicador]; lo que se almacena en la poscion 3 del arreglo2 es el indicador que contiene el turno en que se esta ya sea 1 de perro o 0 de conejo
		mov [arreglo2+7],al
	
		mov eax, 4 ;~ bandera para escribir
		mov edx, 9;~ cantidad de caracteres a imprimir
		mov ecx, arreglo2 ;~ buffer a imprimir ; se escribe el arreglo2
		int 80h

	.sync1:
		mov eax, 36 ;~ bandera para sincronizar
		int 80h

	.close1:
		mov eax, 6 ;~ bandera para cerrar un archivo
		int 80h

		jmp .error3 ;~ brinca a espera ret y hacer call mae

	.error3:
		escribe msgGuardar0,lenGuardar0
		mov ebx, eax ;el modo salida es el resultado de la llamada de systema fallida
		mov eax, 1 ;~ bandera para salir
		int 80h