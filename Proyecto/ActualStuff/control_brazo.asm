;*******************************************************************************
;    Filename:   codigoBrazo.asm
;    Autor: EDGAR ALEJANDRO RECANCOJ PAJAREZ Y JOSE IGNACIO RAMIREZ					
;    Description: CODIGO PARA BRAZO MECANICO                                    *
;*******************************************************************************
#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;*******************************************************************************
GPR_VAR        UDATA
	ESTADO		    RES		1	; ESTADO DEL BRAZO
	W_TEMP		    RES		1	; w register for context saving (ACCESS)
	STATUS_TEMP	    RES		1	; status used for context saving
	DELAY1		    RES		1	; VARIABLE PARA DELAY
	DELAY2		    RES		1	; VARIABLE PARA DELAY
	SERVO1		    RES		1	; VAR THAT PWM FOR SERVO 1 HAS TO REACH
	SERVO1_PREV	    RES		1	; VAR DE ADC1
	SERVO2		    RES		1	; VAR THAT PWM FOR SERVO 2 HAS TO REACH
	SERVO2_PREV	    RES		1	; VAR DE ADC2
	SERVO3		    RES		1	; VAR THAT PWM FOR SERVO 3 HAS TO REACH
	SERVO3_PREV	    RES		1	; VAR DE ADC3
	SERVO4		    RES		1	; VAR THAT PWM FOR SERVO 4 HAS TO REACH
	SERVO4_PREV	    RES		1	; VAR DE ADC4
	TMR0_DELAY	    RES		1	; VAR THAT COUNTS TMR0 INTS
	MANDAR?		    RES		1	; VAR PARA DECIDIR SI GRABAR RUTINA (VALOR RECIBIDO DE PC)
	MANDAR_DATOS	    RES		1	; VAR PARA DICIDIR SI GRABAR RUTINA (PARA PIC)
	RECIBIR_DATOS	    RES		1
	TERMINAR_GRABACION  RES		1
	SERVO1_RX	    RES		1
	SERVO2_RX	    RES		1
	SERVO3_RX	    RES		1
	SERVO4_RX	    RES		1
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000		    ; processor reset vector
    GOTO    START			    ; go to beginning of program

ISR_VECT CODE 0x004
 PUSH:					    ;MAKE BACKUP WHILE IN INTERRUPT
    MOVWF	    W_TEMP
    SWAPF	    STATUS,W
    MOVWF	    STATUS_TEMP
    
 ISR:
    BCF		    INTCON, GIE		    ;DISABLE GLOBAL INTERRUPTS
    BTFSC	    INTCON, T0IF	    ;IF TMR0 INTERRUPT
    CALL	    INT_TMR0
    BTFSC	    PIR1, TMR1IF	    ;IF TMR1 INTERRUPT
    CALL	    INT_TMR1
    BSF		    INTCON, GIE		    ;REENABLE GLOBAL INTERRUTPS
    
 POP:					    ;RESTORE BACKUP
    SWAPF	    STATUS_TEMP,W
    MOVWF	    STATUS
    SWAPF	    W_TEMP,F
    SWAPF	    W_TEMP,W
    RETFIE	
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE					; let linker place main program

START
;*******************************************************************************
    CALL	    CONFIG_RELOJ		; RELOJ INTERNO DE 8MHz
    CALL	    CONFIG_IO			; CONFIGURACION DE PUERTOS
    CALL	    CONFIG_TX_RX		; BAUD RATE: 9600
    CALL	    CONFIG_ADC			; FOSC/32, ACD on, justificado a la izquierda, Vref interno (0-5V)
    CALL	    TMR0_CONFIG			; TMR0 INT AT APROX 36 us
    CALL	    TMR1_CONFIG			; TMR1 INT AT 20 ms
    CALL	    INT_CONFIG			; INTERRUPTION CONFIG
    BANKSEL	    PORTA
    
    MOVLW	    .26				; SERVO1 A 90 GRADOS
    MOVWF	    SERVO1
    MOVLW	    .41				; SERVO2 A 90 GRADOS
    MOVWF	    SERVO2
    MOVLW	    .35				; SERVO3 A 90 GRADOS
    MOVWF	    SERVO3
    MOVLW	    .62				; SERVO4 A 90 GRADOS
    MOVWF	    SERVO4
    GOTO	    LOOP1			; SE INICIA POR DEFAULT EN UTILIZACION INDEPENDIENTE DE PC
;*******************************************************************************
; ESTADOS
;-------------------------------------------------------------------------------
ESTADOS:    
    
    
ESTADO1:
    BTFSC	    ESTADO, 0			; ESTADO DE UTILIZACION INDEPENDIENTE DE PC
    GOTO	    LOOP1
ESTADO2:    
    BTFSC	    ESTADO, 1			; ESTADO DE GRABADO DE RUTINA
    GOTO	    LOOP1
ESTADO3:    
    BTFSC	    ESTADO, 2			; ESTADO DE REPRODUCCION DE RUTINA
    GOTO	    LOOP2
    GOTO	    ESTADOS
   
;*******************************************************************************
; LOOP1
;*******************************************************************************
LOOP1:
ADC1:   
    BSF		    ADCON0, CHS3		; CH10
    BCF		    ADCON0, CHS2
    BSF		    ADCON0, CHS1
    BCF		    ADCON0, CHS0
    BSF		    ADCON0, GO			; EMPIEZA LA CONVERSIÓN
CHECK_AD_SERVO1:
    BTFSC	    ADCON0, GO			; SE REVISA SI TERMINO CONVERSION
    GOTO	    $-1
    BCF		    PIR1, ADIF			; SE BORRA BANDERA DE ADC
    MOVF	    ADRESH, W
    MOVWF	    SERVO1_PREV
;-------------------------------------------------------------------------   
PROCESAMIENTO_SERVO1:
SUBIR_SERVO1:
    MOVLW	    .30				; VALOR MINIMO PARA QUE SERVO SE MUEVA A LA IZQUIEDA
    SUBWF	    SERVO1_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSC	    STATUS, C			; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO	    BAJAR_SERVO1
    
    MOVLW	    .18
    SUBWF	    SERVO1, W
    BTFSS	    STATUS, C
    GOTO	    BAJAR_SERVO1		; NO PERMITE BAJAR DE .18 EN SERVO1
    
    MOVLW	    .1
    SUBWF	    SERVO1, F			; SUMA 1 A SERVO1
    CALL	    DELAY_4.375MS
BAJAR_SERVO1:    
    MOVLW	    .200			; VALOR MINIMO PARA QUE SERVO SE MUEVA A LA DERECHA
    SUBWF	    SERVO1_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSS	    STATUS, C			; SI ES >200, SE MUEVE SERVO A DERECHA
    GOTO	    ADC2
    
    MOVLW	    .55				; BASEEEE
    SUBWF	    SERVO1, W
    BTFSC	    STATUS, C
    GOTO	    ADC2			; NO PERMITE SUBIR DE .59 EN SERVO1
    
    MOVLW	    .1
    ADDWF	    SERVO1, F
    CALL	    DELAY_4.375MS
 ;*******************************************************************************
    
ADC2:   
    BSF		    ADCON0, CHS3		; CH8
    BCF		    ADCON0, CHS2
    BCF		    ADCON0, CHS1
    BCF		    ADCON0, CHS0 
    CALL	    DELAY_125US
    BSF		    ADCON0, GO
CHECK_AD_SERVO2:
    BTFSC	    ADCON0, GO			; SE REVISA SI SE TERMINO LA CONVERSION
    GOTO	    $-1
    BCF		    PIR1, ADIF			; SE BORRA LA BANDERA DE ADC
    MOVF	    ADRESH, W
    MOVWF	    SERVO2_PREV
    
PROCESAMIENTO_SERVO2:
SUBIR_SERVO2:
    MOVLW	    .30				; VALOR MINIMO PARA QUE SERVO SE MUEVA A LA IZQUIEDA
    SUBWF	    SERVO2_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSC	    STATUS, C			; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO	    BAJAR_SERVO2
    
    MOVLW	    .45 ;.30
    SUBWF	    SERVO2, W
    BTFSS	    STATUS, C
    GOTO	    BAJAR_SERVO2		; NO PERMITE BAJAR DE .18 EN SERVO2
    
    MOVLW	    .1
    SUBWF	    SERVO2, F
    CALL	    DELAY_4.375MS
BAJAR_SERVO2:    
    MOVLW	    .200			; VALOR MINIMO PARA QUE SERVO SE MEUVA A LA DERECHA
    SUBWF	    SERVO2_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSS	    STATUS, C			; SI ES >200, SE MUEVE SERVO A DERECHA
    GOTO	    ADC3
    
    MOVLW	    .55;.41
    SUBWF	    SERVO2, W
    BTFSC	    STATUS, C
    GOTO	    ADC3			; NO PERMITE SUBIR DE .59 EN SERVO2
    
    MOVLW	    .1
    ADDWF	    SERVO2, F
    CALL	    DELAY_4.375MS
;*******************************************************************************

ADC3:   
    BSF		    ADCON0, CHS3		; CH9
    BCF		    ADCON0, CHS2
    BCF		    ADCON0, CHS1
    BSF		    ADCON0, CHS0 
    CALL	    DELAY_125US
    BSF		    ADCON0, GO
CHECK_AD_SERVO3:
    BTFSC	    ADCON0, GO			; SE REVISA SI SE TERMINO LA CONVERSION
    GOTO	    $-1
    BCF		    PIR1, ADIF			; SE BORRA LA BANDERA DE ADC
    MOVF	    ADRESH, W
    MOVWF	    SERVO3_PREV
PROCESAMIENTO_SERVO3:
SUBIR_SERVO3:
    MOVLW	    .30				; VALOR MINIMO PARA QUE SERVO SE MUEVA A LA IZQUIEDA
    SUBWF	    SERVO3_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSC	    STATUS, C			; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO	    BAJAR_SERVO3
    
    MOVLW	    .29
    SUBWF	    SERVO3, W
    BTFSS	    STATUS, C
    GOTO	    BAJAR_SERVO3		; NO PERMITE BAJAR DE .18 EN SERVO3
    
    MOVLW	    .1
    SUBWF	    SERVO3, F
    CALL	    DELAY_4.375MS
    
BAJAR_SERVO3:    
    MOVLW	    .200			; VALOR MINIMO PARA QUE SERVO SE MUEVA A LA DERECHA
    SUBWF	    SERVO3_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSS	    STATUS, C			; SI ES >200, SE MUEVE SERVO A DERECHA
    GOTO	    ADC4
    
    MOVLW	    .35;.33
    SUBWF	    SERVO3, W
    BTFSC	    STATUS, C
    GOTO	    ADC4			; NO PERMITE SUBIR DE .59 EN SERVO1
	
    MOVLW	    .1
    ADDWF	    SERVO3, F
    CALL	    DELAY_4.375MS
;********************************************************************************

ADC4:   
    BSF		    ADCON0, CHS3		; CH11
    BCF		    ADCON0, CHS2
    BSF		    ADCON0, CHS1
    BSF		    ADCON0, CHS0 
    CALL	    DELAY_125US
    BSF		    ADCON0, GO
CHECK_AD_SERVO4:
    BTFSC	    ADCON0, GO			; SE REVISA SI TERMINO CONVERSION
    GOTO	    $-1
    BCF		    PIR1, ADIF			; SE BORRA LA BANDERA
    MOVF	    ADRESH, W
    MOVWF	    SERVO4_PREV
PROCESAMIENTO_SERVO4:
SUBIR_SERVO4:
    MOVLW	    .30				; VALOR MINIMO PARA QUE SERVO SE MUEVA A LA IZQUIEDA
    SUBWF	    SERVO4_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSC	    STATUS, C			; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO	    BAJAR_SERVO4
    
    MOVLW	    .43				; GARRA
    SUBWF	    SERVO4, W
    BTFSS	    STATUS, C
    GOTO	    BAJAR_SERVO4		; NO PERMITE BAJAR DE .17 EN SERVO4
    
    MOVLW	    .1
    SUBWF	    SERVO4, F
    CALL	    DELAY_4.375MS
    
BAJAR_SERVO4:    
    MOVLW	    .200			; VALOR MAX PARA QUE SERVO SE MEVA A LA DERECHA
    SUBWF	    SERVO4_PREV, W		; VALOR RECIBIDO DE ADC
    BTFSS	    STATUS, C			; SI ES >200, SE MUEVE SERVO A DERECHA
    GOTO	    CHECK_RCIF
    
    MOVLW	    .64
    SUBWF	    SERVO4, W
    BTFSC	    STATUS, C
    GOTO	    CHECK_RCIF			; NO PERMITE BAJAR DE .59 EN SERVO1
    
    MOVLW	    .1
    ADDWF	    SERVO4, F
    CALL	    DELAY_4.375MS
    
;--------------------------------------------------------------------------------
CHECK_RCIF:					; RECIBE EN RX 
    BCF		    PORTD, 0
    BTFSS	    PIR1, RCIF
    GOTO	    CHECK_TXIF
    MOVF	    RCREG, W
    MOVWF	    MANDAR?
    
    
CHECK_TXIF: 
    
    MOVF	    MANDAR?, W
    SUBLW	    .1
    BTFSS	    STATUS, Z
    GOTO	    RECIBIR_DATOS_DE_PC
    
    GOTO	    TX_DATOS
    
    
RECIBIR_DATOS_DE_PC:
    MOVF	    MANDAR?, W
    SUBLW	    .2
    BTFSS	    STATUS, Z
    GOTO	    NO_MANDAR
    MOVLW	    B'00000100'
    MOVWF	    ESTADO
    
    MOVF	    SERVO1, W
    MOVWF	    SERVO1_RX
    MOVF	    SERVO2, W
    MOVWF	    SERVO2_RX
    MOVF	    SERVO3, W
    MOVWF	    SERVO3_RX
    MOVF	    SERVO4, W
    MOVWF	    SERVO4_RX
    
    GOTO	    ESTADOS
    
TX_DATOS:
    
    BSF		    PORTD, 1
    
    MOVLW	    .1
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    call	    DELAY_125US

    MOVLW	    B'00000010'
    MOVWF	    ESTADO
    
    MOVF	    SERVO1, W		; ENVÍA SERVO1_PREV POR TX
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    call	    DELAY_125US
    
    
    
    MOVF	    SERVO2, W		; ENVÍA SERVO1_PREV POR TX
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    call	    DELAY_125US
    
    
    
    MOVF	    SERVO3, W		; ENVÍA SERVO1_PREV POR TX
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    call	    DELAY_125US
    
    
    MOVF	    SERVO4, W		; ENVÍA SERVO1_PREV POR TX
    MOVWF	    TXREG
    BTFSS	    PIR1, TXIF
    GOTO	    $-1
    call	    DELAY_125US
    
    
    GOTO	    ESTADOS
NO_MANDAR:
    
    MOVLW	    B'00000001'
    MOVWF	    ESTADO
    GOTO	    ESTADOS
    
 
;*******************************************************************************
    LOOP2:
    
    					; RECIBE EN RX 
   
    
    RECEPCION_SERVO1:
    BTFSS	    PIR1, RCIF
    GOTO	    $-1
    MOVF	    RCREG, W
    MOVWF	    SERVO1_RX
    
    RECEPCION_SERVO2:
    BTFSS	    PIR1, RCIF
    GOTO	    $-1
    MOVF	    RCREG, W
    MOVWF	    SERVO2_RX
    
    RECEPCION_SERVO3:
    BTFSS	    PIR1, RCIF
    GOTO	    $-1
    MOVF	    RCREG, W
    MOVWF	    SERVO3_RX
    
    RECEPCION_SERVO4:
    BSF		    PORTD, 0
    BTFSS	    PIR1, RCIF
    GOTO	    $-1
    MOVF	    RCREG, W
    MOVWF	    SERVO4_RX
    
PROCESAMIENTO_RX:

    MOVLW	    .17
    SUBWF	    SERVO1_RX, W
    BTFSS	    STATUS, C
    GOTO	    NO_RECIBIR		; NO PERMITE BAJAR DE .17 EN SERVO4
    
    MOVLW	    .60
    SUBWF	    SERVO1_RX, W
    BTFSC	    STATUS, C
    GOTO	    NO_RECIBIR			; NO PERMITE SUBIR DE .59 EN SERVO1
    
    MOVF	    SERVO1_RX, W
    MOVWF	    SERVO1
    
    
    
    MOVLW	    .17
    SUBWF	    SERVO2_RX, W
    BTFSS	    STATUS, C
    GOTO	    NO_RECIBIR		; NO PERMITE BAJAR DE .17 EN SERVO4
    
    MOVLW	    .60
    SUBWF	    SERVO2_RX, W
    BTFSC	    STATUS, C
    GOTO	    NO_RECIBIR			; NO PERMITE SUBIR DE .59 EN SERVO1
    
    MOVF	    SERVO2_RX, W
    MOVWF	    SERVO2
    
    
    MOVLW	    .17
    SUBWF	    SERVO3_RX, W
    BTFSS	    STATUS, C
    GOTO	    NO_RECIBIR		; NO PERMITE BAJAR DE .17 EN SERVO4
    
    MOVLW	    .60
    SUBWF	    SERVO3_RX, W
    BTFSC	    STATUS, C
    GOTO	    NO_RECIBIR			; NO PERMITE SUBIR DE .59 EN SERVO1
    
    MOVF	    SERVO3_RX, W
    MOVWF	    SERVO3
    
    
    MOVLW	    .17
    SUBWF	    SERVO4_RX, W
    BTFSS	    STATUS, C
    GOTO	    NO_RECIBIR		; NO PERMITE BAJAR DE .17 EN SERVO4
    
    MOVLW	    .65
    SUBWF	    SERVO4_RX, W
    BTFSC	    STATUS, C
    GOTO	    NO_RECIBIR			; NO PERMITE SUBIR DE .59 EN SERVO1
    
    MOVF	    SERVO4_RX, W
    MOVWF	    SERVO4
    
    GOTO	    ESTADOS
	    
    
NO_RECIBIR:
    
    MOVLW	    B'00000001'
    MOVWF	    ESTADO
    CLRF	    TERMINAR_GRABACION
    CLRF	    MANDAR?
    GOTO	    ESTADOS
    
    
    
    
    
;********************************************************************************
CONFIG_RELOJ:
    BANKSEL	    OSCCON			; OSCILADOR A 8 MHz
    BSF		    OSCCON, IRCF2
    BSF		    OSCCON, IRCF1
    BsF		    OSCCON, IRCF0
    RETURN
 
 ;--------------------------------------------------------
CONFIG_TX_RX:
    BANKSEL	    TXSTA
    BCF		    TXSTA, SYNC			; ASINCRÓNO
    BSF		    TXSTA, BRGH			; LOW SPEED
    BANKSEL	    BAUDCTL
    BSF		    BAUDCTL, BRG16		; 8 BITS BAURD RATE GENERATOR
    BANKSEL	    SPBRG   
    MOVLW	    .207	    
    MOVWF	    SPBRG			; CARGAMOS EL VALOR DE BAUDRATE CALCULADO (9600)
    CLRF	    SPBRGH
    BANKSEL	    RCSTA
    BSF		    RCSTA, SPEN			; HABILITAR SERIAL PORT
    BCF		    RCSTA, RX9			; SOLO MANEJAREMOS 8BITS DE DATOS
    BSF		    RCSTA, CREN			; HABILITAMOS LA RECEPCIÓN 
    BANKSEL	    TXSTA
    BSF		    TXSTA, TXEN			; HABILITO LA TRANSMISION
    
    BANKSEL PORTD
    CLRF    PORTD
    RETURN
;--------------------------------------
CONFIG_IO:
    BANKSEL	    TRISA
    CLRF	    TRISA
    CLRF	    TRISB
    CLRF	    TRISC
    CLRF	    TRISD
    CLRF	    TRISE
    BANKSEL	    ANSEL
    CLRF	    ANSEL
    CLRF	    ANSELH
    BANKSEL	    PORTA
    CLRF	    PORTA
    CLRF	    PORTB
    CLRF	    PORTC
    CLRF	    PORTD
    CLRF	    PORTE
    CLRF	    TMR0_DELAY
    CLRF	    ESTADO
    INCF	    ESTADO
    CLRF	    MANDAR_DATOS
    INCF	    MANDAR_DATOS
    CLRF	    MANDAR?
    CLRF	    RECIBIR_DATOS
    MOVLW	    .2
    MOVWF	    RECIBIR_DATOS
    CLRF	    TERMINAR_GRABACION
    
    RETURN    
;-----------------------------------------------
CONFIG_ADC:
    BANKSEL	    PORTA
    BSF		    ADCON0, ADCS1
    BCF		    ADCON0, ADCS0		; FOSC/32 RELOJ TAD
    
    BSF		    ADCON0, CHS3		; CH0
    BCF		    ADCON0, CHS2
    BSF		    ADCON0, CHS1
    BCF		    ADCON0, CHS0	
    BANKSEL	    TRISA
    BCF		    ADCON1, ADFM		; JUSTIFICACIÓN A LA IZQUIERDA
    BCF		    ADCON1, VCFG1		; VSS COMO REFERENCIA VREF-
    BCF		    ADCON1, VCFG0		; VDD COMO REFERENCIA VREF+
    BANKSEL	    PORTA
    BSF		    ADCON0, ADON		; ENCIENDO EL MÓDULO ADC
    
    BANKSEL	    TRISB
    BSF		    TRISB, RB1			
    BSF		    TRISB, RB2
    BSF		    TRISB, RB3
    BSF		    TRISB, RB4
    BANKSEL	    ANSELH
    BSF		    ANSELH, 1			; ANS1 , ANS2, ANS3 Y ANS4 SCOMO ENTRADA ANALÓGICA
    BSF		    ANSELH, 2
    BSF		    ANSELH, 3
    BSF		    ANSELH, 4
    
    RETURN
;-----------------------------------------------
DELAY_4.375MS:
    MOVLW	    .35				; 1250 US
    MOVWF	    DELAY2
    CALL	    DELAY_125US
    DECFSZ	    DELAY2			; DECREMENTA CONT1
    GOTO	    $-2				; IR A LA POSICION DEL PC - 1
    RETURN
    
DELAY_125US:
    MOVLW	    .250			; 0.5US *250=125 US
    MOVWF	    DELAY1	    
    DECFSZ	    DELAY1			;DECREMENTA CONT1
    GOTO	    $-1				; IR A LA POSICION DEL PC - 1
    RETURN
    
TMR0_CONFIG:					;TMR0'S CONFIGURATION 
    BANKSEL	    OPTION_REG			; CAMBIAMOS AL BANCO 1
    BCF		    OPTION_REG, T0CS		; SELECCIONAMOS TMR0 COMO TEMPORIZADOR
    BCF		    OPTION_REG, PSA		; ASIGNAMOS PRESCALER A TMR0
    BCF		    OPTION_REG, PS2
    BCF		    OPTION_REG, PS1
    BCF		    OPTION_REG, PS0		; PRESCALER DE 2
    clrwdt
    BANKSEL	    TMR0
    MOVLW	    .225			; DESBORDE DE CADA 8US
    MOVWF	    TMR0			; CARGAMOS EL N CALCULADO 
    BCF		    INTCON, T0IF
    BSF		    INTCON, T0IE
    RETURN
    
TMR1_CONFIG:					;TMR1'S CONFIGURATION (20ms)
    BANKSEL	    PORTA
    BSF		    T1CON, TMR1ON
    BCF		    T1CON, TMR1CS
    BCF		    T1CON, TMR1GE		; TIMER UNO SIEMPRE VA CONTAR
    
    BCF		    T1CON, T1CKPS0
    BCF		    T1CON, T1CKPS1
    
    MOVLW	    b'01100011'
    MOVWF	    TMR1H
    MOVLW	    b'11000000'
    MOVWF	    TMR1L
    
    RETURN
    
    
INT_CONFIG:					;INTERRUPTS' INITIALIZATION    
    BANKSEL	    PIE1
    BSF		    PIE1, TMR1IE
    
    BANKSEL	    INTCON
    BSF		    INTCON, GIE
    BSF		    INTCON, PEIE
    RETURN
    
    
INT_TMR0:
    ; RESET TMR0
    BCF		    INTCON, T0IF
    MOVLW	    .225
    MOVWF	    TMR0
    
    ; INCREASE TMR0 COUNTER
    INCF	    TMR0_DELAY, F
    
    ; COMPARE FIRST PWM
    MOVF	    SERVO1, W
    SUBWF	    TMR0_DELAY, W
    BTFSC	    STATUS, C
    BCF		    PORTA, RA0
    
    ; COMPARE SECOND PWM
    MOVF	    SERVO2, W
    SUBWF	    TMR0_DELAY, W
    BTFSC	    STATUS, C
    BCF		    PORTA, RA1
    
    ; COMPARE THIRD PWM
    MOVF	    SERVO3, W
    SUBWF	    TMR0_DELAY, W
    BTFSC	    STATUS, C
    BCF		    PORTA, RA2
    
    ; COMPARE FOURTH PWM
    MOVF	    SERVO4, W
    SUBWF	    TMR0_DELAY, W
    BTFSC	    STATUS, C
    BCF		    PORTA, RA3
    
    RETURN
    
INT_TMR1:
    ; SE ACTIVAN RA0 - RA3 DE PORTA
    BSF		    PORTA, RA0
    BSF		    PORTA, RA1
    BSF		    PORTA, RA2
    BSF		    PORTA, RA3
    
    ; RESET TIMER
    BCF		    PIR1, TMR1IF
    MOVLW	    b'01100011'
    MOVWF	    TMR1H
    MOVLW	    b'11000000'
    MOVWF	    TMR1L
    
    ; ENABLE AND RESET TMR0
    CLRF	    TMR0_DELAY
    MOVLW	    .225
    MOVWF	    TMR0
    
    RETURN
        
    END