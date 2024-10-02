	                      ;  PROGRAMA QUE GENERA NÚMEROS ALEATORIOS Y LOS ORDENA
	                      ;  VITALES ORTIZ ALFONSO EDUARDO

;-----------------------------------------------------------------------------------
;	                        MAIN PROGRAM
;-----------------------------------------------------------------------------------
	.org 0000h
	call disp_text
	ld hl,8000h           ;  Puntero al área de memoria para almacenar los números
	ld b,20               ;  Contador de 20 números
	LD de,1A2Bh           ;  Valor inicial de la semilla
	call rdm_numbers
	call show_numbers
	call ord_num
	ld hl,text2
	call ask_order
	call rd_user
	ld hl,8000h           ;  Puntero al inicio del área de memoria donde están los números
	call ord_num
	call show_ordered


;-----------------------------------------------------------------------------------
;	                        SUBROUTINES
;-----------------------------------------------------------------------------------
disp_text:
	ld hl,text1           ;  carga el texto en el registro HL.
	ld a,(hl)             ;  carga lo que hay en HL en A.
	out (LCD),a           ;  Muestra en pantalla lo que hay en A.
end1:
	ret

;----------------SUBRUTINAS A USAR PARA GENERAR NÚMEROS ALEATORIOS------------------
Multiply:
	ld l,0                ;  quita lo que haya en L
	ld h,0                ;  quita lo que haya en H
	ld b,a                ;  carga en B lo que haya en A

MultLoop:
	add hl,hl
	djnz SkipAdd          ;  Si A = 0, omitir la adición
	add hl,de             ;  Si B bit actual es 1, sumar el valor de DE

SkipAdd:
	srl a                 ;  Desplaza A un bit a la derecha
	jr NZ,MultLoop        ;  Si A no es 0, vuelve a "MultLoop"
	ret                   ;  Retorna al programa principal

	end
;---------------------SUBRUTINA PARA GENERAR NÚMEROS ALEATORIOS-------------------------------
rdm_numbers:
	                      ;  Fórmula para la semilla Xn+1 = (a * Xn + c) mod m
	ld a,e                ;  carga únicamente la parte baja de la semilla en A
	ld h,75               ;  Multiplicador a = 75
	ld l,e

	                      ;  Multiplicación de A * 75
	call Multiply         ;  llamo la subrutina definida arriba

	ld a,l                ;  Parte baja del resultado en A (Xn+1 = a*Xn mod 256)
	add a,74              ;  Sumar la constante c = 74
	ld e,a                ;  Guardar nuevo valor de la semilla en E

	ld (hl),a             ;  Almacenar número pseudo-aleatorio en memoria
	inc HL                ;  Avanzar al siguiente byte de memoria
	djnz rdm_numbers      ;  Se repite hasta generar los 20 números

	halt                  ;  Detener ejecución

show_numbers:
	ld a,(hl)             ;  Carga el número desde la memoria
	call show_num         ;  muestra el número en pantalla (en decimal)
	call newline          ;  Salta a la siguiente línea después de mostrar cada número
	inc hl
	djnz show_numbers     ;  Repite hasta mostrar los 20 números en memoria

	halt



;--------------SUBRUTINAS A USAR PARA MOSTRAR NÚMEROS GENERADOS------------------
show_num:
	ld a,e                ;  El número aleatorio está en A
	call Decimal2ASCII    ;  Convertir número a decimal (y a ASCII)
	ld c,01h              ;  Puerto de salida
	ld b,3                ;  Mostrar los 3 dígitos
show_loop:
	ld a,(hl)             ;  Cargar dígito ASCII
	out (c),a             ;  Enviar dígito al puerto
	inc hl                ;  Avanzar al siguiente dígito
	djnz show_loop        ;  Repetir hasta mostrar los 3 dígitos
	ret

;---------------SUBRUTINA PARA CONVERTIR UN NÚMERO A ASCII----------------
Decimal2ASCII:
	ld d,0
	ld b,100
	call Divide
	add a,'0'             ;  convierte el cociente a ASCII
	ld (hl),a             ;  Guarda dígito ASCII
	inc hl                ;  Avanza al siguiente byte de memoria

	ld a,d
	ld b,10
	call Divide
	add a,'0'             ;  convierte el cociente a ASCII
	ld (hl),a             ;  Guarda dígito ASCII
	inc hl                ;  Avanza al siguiente byte de memoria

	ld a,d                ;  Resto (unidades)
	add a,'0'             ;  Convierte a ASCII
	ld (hl),a             ;  Guarda dígito ASCII
	ret

Divide:
	ld d,0                ;  Limpiar resto
DivLoop:
	cp b                  ;  Compara A con B
	jr c,DivEnd           ;  Si A < B, termina
	sub b                 ;  Resta B de A
	inc D                 ;  Incrementar el cociente
	jr DivLoop            ;  Repite

DivEnd:
	ld a,d                ;  Guardar el cociente en A
	ret

;-------------------SUBRUTINA PARA HACER SALTO DE LINEA A LA PANTALLA-----------------
newline:
	ld a,0Ah              ;  Código ASCII para nueva línea
	out (c),a             ;  Enviar nueva línea
	ld a,0Dh              ;  Código ASCII para retorno de carro
	out (c),a             ;  Enviar retorno de carro
	ret

	end

;-------------------SUBRUTINA PARA MOSTRAR ASCENDENTE O DESCENDENTE----------------------
ask_order:
	ld c,01h
	ld a,(hl)             ;  Carga el carácter del mensaje
	or a                  ;  Verifica si es el final del mensaje (código ASCII 0)
	jr z,endtext          ;  Si es 0, termina
	out (c),a             ;  Envía carácter al puerto
	inc hl                ;  Avanza al siguiente carácter
	jr ask_order     ;  Repite hasta mostrar todo el mensaje
endtext:
	ret

ord_num:
	ld a,(hl)             ;  Carga el número ordenado desde la memoria
	call show_num         ;  Muestra el número en pantalla en decimal
	call newline          ;  Salta a la siguiente línea después de mostrar cada número
	inc hl                ;  Avanza al siguiente número en memoria
	djnz ord_num          ;  Repite hasta mostrar los 20 números

	halt

	                      ;  -------------------SUBRUTINA PARA LEER LA RESPUESTA DEL USUARIO--------------------------
rd_user:
	ld HL,resp            ;  Cargar dirección para guardar la respuesta
	ld c,01h              ;  Puerto de entrada (supuesto puerto 01h)
	ld b,20               ;  Número máximo de caracteres a leer (20)
rd_loop:
	in a,(c)              ;  Lee un carácter
	cp 0Dh                ;  Compara con el retorno de carro
	jr z,end_read         ;  Si es retorno de carro, finalizar
	ld (hl),A             ;  Guarda el carácter en memoria
	inc hl                ;
	djnz rd_loop          ;  Continúa leyendo
end_read:
	ld (hl),0             ;  Termina la cadena con 0
	ret

;  -------------------SUBRUTINA PARA ORDENAR LOS NÚMEROS----------------------------------
ord_num:
	ld bc,20              ;  Número de elementos
	ld hl,8000h           ;  Puntero a la memoria de los números

ord_loop:
	ld a,(hl)             ;  Carga el primer número
	ld d,(hl + 1)         ;  Carga el siguiente número
	ld e,a                ;  Guarda el primer número en E
	ld a,(hl + 1)         ;  Carga el segundo número en A

	cp e                  ;  Comparar los números
	jr z,NoSwap           ;  Si son iguales, no hay que intercambiar

	                      ;  Verificar si se desea ordenar de manera ascendente o descendente
	ld a,(resp)           ;  Carga la respuesta
	cp 'a'                ;  Comparar con 'a' (ascendente)
	jr z,Ascendente

	                      ;  Si es descendente
	cp d                  ;  Comparar si el segundo número es mayor
	jr c,NoSwap           ;  Si D es mayor, no intercambiar

	                      ;  Intercambiar si se necesita
	ld (hl),d             ;  Guardar D en el primer número
	ld (hl + 1),e         ;  Guardar E en el segundo número
	jr FinSwap

Ascendente:
	                      ;  Ordenar de manera ascendente
	cp d                  ;  Comparar si D es menor
	jr c,NoSwap           ;  Si D es menor, no intercambiar

	                      ;  Intercambiar si se necesita
	ld (hl),d             ;  Guardar D en el primer número
	ld (hl + 1),e         ;  Guardar E en el segundo número

FinSwap:
NoSwap:
	inc hl                ;  Avanzar al siguiente par
	djnz ord_loop         ;  Continuar con el próximo número

	ret

show_ordered:
        ld a, (hl)         ; Cargar el número ordenado desde la memoria
        call show_num  ; Mostrar el número en pantalla en decimal
        call newline     ; Saltar a la siguiente línea después de mostrar cada número
        inc hl             ; Avanzar al siguiente número en memoria
        djnz show_ordered ; Repetir hasta mostrar los 20 números

        halt               ; Detener ejecución

;-----------------------------------------------------------------------------------
;	                        DATA SEGMENT
;-----------------------------------------------------------------------------------
	.org 2000h
LCD	.equ 01h
KEYB	.equ 02h
text1	.db "Generando números aleatorios"
text2	.db "¿ascendente o descendente?"
resp	.db "              "