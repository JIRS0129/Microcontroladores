;*******************************************************************************
;                                                                              *
;    Filename:    Serial.asm
;    Autor: José Eduardo Morales					
;    Description: EJEMPLO de serial y ADC                                      *
;   El código convierte un valor del adc y lo guarda en el puerto b. A la vez
;   lo envía a través del TX. También recibe un dato y este lo muestra en el 
;   puerto d. Para ver funcionar ambos se puede colocar un jumper entre rx y tx
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
   W_TEMP         RES        1      ; w register for context saving (ACCESS)
   STATUS_TEMP    RES        1      ; status used for context saving
   DELAY1	  RES	    1
   DELAY2	  RES	    1
   VOLTAJE	  RES	    1
    SERVO1	    RES	    1	    ; VAR THAT PWM FOR SERVO 1 HAS TO REACH
    SERVO1_PREV	    RES	    1
    SERVO2	    RES	    1	    ; VAR THAT PWM FOR SERVO 2 HAS TO REACH
SERVO2_PREV	    RES	    1
    SERVO3	    RES	    1	    ; VAR THAT PWM FOR SERVO 3 HAS TO REACH
SERVO3_PREV	    RES	    1
    SERVO4	    RES	    1	    ; VAR THAT PWM FOR SERVO 4 HAS TO REACH
SERVO4_PREV	    RES	    1
    TMR0_DELAY	    RES	    1	    ; VAR THAT COUNTS TMR0 INTS
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

ISR_VECT CODE 0x004
 PUSH:				    ;MAKE BACKUP WHILE IN INTERRUPT
    MOVWF	W_TEMP
    SWAPF	STATUS,W
    MOVWF	STATUS_TEMP
    
 ISR:
    BCF		INTCON, GIE		    ;DISABLE GLOBAL INTERRUPTS
    BTFSC	INTCON, T0IF		    ;IF TMR0 INTERRUPT
    CALL	INT_TMR0
    BTFSC	PIR1, TMR1IF		    ;IF TMR1 INTERRUPT
    CALL	INT_TMR1
    BSF		INTCON, GIE		    ;REENABLE GLOBAL INTERRUTPS
    
 POP:				    ;RESTORE BACKUP
    SWAPF	STATUS_TEMP,W
    MOVWF	STATUS
    SWAPF	W_TEMP,F
    SWAPF	W_TEMP,W
    RETFIE	
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START
;*******************************************************************************
    CALL    CONFIG_RELOJ		; RELOJ INTERNO DE 500KHz
    CALL    CONFIG_IO
    CALL    CONFIG_TX_RX		; 10417hz
    CALL    CONFIG_ADC			; canal 0, fosc/8, adc on, justificado a la izquierda, Vref interno (0-5V)
    CALL    TMR0_CONFIG			; TMR0 INT AT 22 us
    CALL    TMR1_CONFIG			; TMR1 INT AT 20 ms
    CALL    INT_CONFIG
    BANKSEL PORTA
    
    MOVLW   .38				; valor min frecuencia de 660 us .17
    MOVWF   SERVO1
    MOVLW   .38				
    MOVWF   SERVO2
    MOVLW   .38
    MOVWF   SERVO3
    MOVLW   .38				; valor MAX frecuencia de 2.280 ms
    MOVWF   SERVO4
;*******************************************************************************
   
;*******************************************************************************
; CICLO INFINITO
;*******************************************************************************
LOOP:
ADC1:   
    
    BSF ADCON0, CHS3		    ; CH10
    BCF ADCON0, CHS2
    BSF ADCON0, CHS1
    BCF ADCON0, CHS0
    BSF	    ADCON0, GO		    ; EMPIEZA LA CONVERSIÓN
CHECK_AD_SERVO1:
    BTFSC   ADCON0, GO			; revisa que terminó la conversión
    GOTO    $-1
    BCF	    PIR1, ADIF			; borramos la bandera del adc
    MOVF    ADRESH, W
    MOVWF   SERVO1_PREV
;-------------------------------------------------------------------------   
PROCESAMIENTO_SERVO1:
SUBIR_SERVO1:
    MOVLW   .30			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO1_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSC   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    BAJAR_SERVO1
    
    MOVLW   .18
    SUBWF   SERVO1, W
    BTFSS   STATUS, C
    GOTO    BAJAR_SERVO1		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    SUBWF    SERVO1, F
    CALL    DELAY_4.375MS
BAJAR_SERVO1:    
    MOVLW   .200			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO1_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSS   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    ADC2
    
    MOVLW   .59
    SUBWF   SERVO1, W
    BTFSC   STATUS, C
    GOTO    ADC2		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    ADDWF    SERVO1, F
    CALL    DELAY_4.375MS
 ;*******************************************************************************

ADC2:   
    BSF ADCON0, CHS3		    ; CH8
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BCF ADCON0, CHS0 
    CALL DELAY_125US
    BSF	    ADCON0, GO
CHECK_AD_SERVO2:
    BTFSC   ADCON0, GO			; revisa que terminó la conversión
    GOTO    $-1
    BCF	    PIR1, ADIF			; borramos la bandera del adc
    MOVF    ADRESH, W
    MOVWF   SERVO2_PREV
    
PROCESAMIENTO_SERVO2:
SUBIR_SERVO2:
    MOVLW   .30			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO2_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSC   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    BAJAR_SERVO2
    
    MOVLW   .18
    SUBWF   SERVO2, W
    BTFSS   STATUS, C
    GOTO    BAJAR_SERVO2		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    SUBWF    SERVO2, F
    CALL    DELAY_4.375MS
BAJAR_SERVO2:    
    MOVLW   .200			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO2_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSS   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    ADC3
    
    MOVLW   .59
    SUBWF   SERVO2, W
    BTFSC   STATUS, C
    GOTO    ADC3		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    ADDWF    SERVO2, F
    CALL    DELAY_4.375MS
;*******************************************************************************

ADC3:   
    BSF ADCON0, CHS3		    ; CH8
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BSF ADCON0, CHS0 
    CALL DELAY_125US
    BSF	    ADCON0, GO
CHECK_AD_SERVO3:
    BTFSC   ADCON0, GO			; revisa que terminó la conversión
    GOTO    $-1
    BCF	    PIR1, ADIF			; borramos la bandera del adc
    MOVF    ADRESH, W
    MOVWF   SERVO3_PREV
PROCESAMIENTO_SERVO3:
SUBIR_SERVO3:
    MOVLW   .30			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO3_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSC   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    BAJAR_SERVO3
    
    MOVLW   .18
    SUBWF   SERVO3, W
    BTFSS   STATUS, C
    GOTO    BAJAR_SERVO3		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    SUBWF    SERVO3, F
    CALL    DELAY_4.375MS
    
BAJAR_SERVO3:    
    MOVLW   .200			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO3_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSS   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    ADC4
    
    MOVLW   .59
    SUBWF   SERVO3, W
    BTFSC   STATUS, C
    GOTO    ADC4		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    ADDWF   SERVO3, F
    CALL    DELAY_4.375MS
;********************************************************************************

ADC4:   
    BSF ADCON0, CHS3		    ; CH8
    BCF ADCON0, CHS2
    BSF ADCON0, CHS1
    BSF ADCON0, CHS0 
    CALL DELAY_125US
    BSF	    ADCON0, GO
CHECK_AD_SERVO4:
    BTFSC   ADCON0, GO			; revisa que terminó la conversión
    GOTO    $-1
    BCF	    PIR1, ADIF			; borramos la bandera del adc
    MOVF    ADRESH, W
    MOVWF   SERVO4_PREV
PROCESAMIENTO_SERVO4:
SUBIR_SERVO4:
    
    MOVLW   .30			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO4_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSC   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    BAJAR_SERVO4
    
    MOVLW   .18
    SUBWF   SERVO4, W
    BTFSS   STATUS, C
    GOTO    BAJAR_SERVO4		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    SUBWF    SERVO4, F
    CALL    DELAY_4.375MS
    
BAJAR_SERVO4:    
    MOVLW   .200			    ; VALOR MINIMO PARA QUE SERVO SE MEVA A LA IZQUIEDA
    SUBWF   SERVO4_PREV, W	    ; VALOR RECIBIDO DE ADC
    BTFSS   STATUS, C		    ; SI ES <30, SE MUEVE SERVO A IZQUIERDA
    GOTO    CHECK_RCIF
    
    MOVLW   .59
    SUBWF   SERVO4, W
    BTFSC   STATUS, C
    GOTO    CHECK_RCIF		    ; NO PERMITE BAJAR DE .17 EN SERVO1
    
    MOVLW   .1
    ADDWF   SERVO4, F
    CALL    DELAY_4.375MS
    
;--------------------------------------------------------------------------------
CHECK_RCIF:			    ; RECIBE EN RX y lo muestra en PORTD
    BTFSS   PIR1, RCIF
    GOTO    CHECK_TXIF
    MOVF    RCREG, W
    MOVWF   PORTD
    
CHECK_TXIF: 
    MOVF   SERVO1_PREV, W		    ; ENVÍA PORTB POR EL TX
    MOVWF   TXREG
   
    BTFSS   PIR1, TXIF
    GOTO    $-1
    
    GOTO LOOP
;*******************************************************************************
    CONFIG_RELOJ
    
    
    BANKSEL	OSCCON
    BSF		OSCCON, IRCF2
    BSF		OSCCON, IRCF1
    BsF		OSCCON, IRCF0
   
    RETURN
 
 ;--------------------------------------------------------
    CONFIG_TX_RX
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC		    ; ASINCRÓNO
    BSF	    TXSTA, BRGH		    ; LOW SPEED
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16	    ; 8 BITS BAURD RATE GENERATOR
    BANKSEL SPBRG
    MOVLW   .207	    
    MOVWF   SPBRG		    ; CARGAMOS EL VALOR DE BAUDRATE CALCULADO
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN		    ; HABILITAR SERIAL PORT
    BCF	    RCSTA, RX9		    ; SOLO MANEJAREMOS 8BITS DE DATOS
    BSF	    RCSTA, CREN		    ; HABILITAMOS LA RECEPCIÓN 
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN		    ; HABILITO LA TRANSMISION
    
    BANKSEL PORTD
    CLRF    PORTD
    RETURN
;--------------------------------------
CONFIG_IO
    BANKSEL TRISA
    CLRF    TRISA
    CLRF    TRISB
    CLRF    TRISC
    CLRF    TRISD
    CLRF    TRISE
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    BANKSEL PORTA
    CLRF    PORTA
    CLRF    PORTB
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTE
     CLRF    TMR0_DELAY
    RETURN    
;-----------------------------------------------
    CONFIG_ADC
    BANKSEL PORTA
    BsF ADCON0, ADCS1
    BcF ADCON0, ADCS0		; FOSC/32 RELOJ TAD
    
    BSF ADCON0, CHS3		; CH0
    BCF ADCON0, CHS2
    BSF ADCON0, CHS1
    BCF ADCON0, CHS0	
    BANKSEL TRISA
    BCF ADCON1, ADFM		; JUSTIFICACIÓN A LA IZQUIERDA
    BCF ADCON1, VCFG1		; VSS COMO REFERENCIA VREF-
    BCF ADCON1, VCFG0		; VDD COMO REFERENCIA VREF+
    BANKSEL PORTA
    BSF ADCON0, ADON		; ENCIENDO EL MÓDULO ADC
    
    BANKSEL TRISB
    BSF	    TRISB, RB1		; Rb0
    BSF	    TRISB, RB2
    BSF	    TRISB, RB3
    BSF	    TRISB, RB4
    BANKSEL ANSELH
    BSF	    ANSELH, 1		; ANS0 COMO ENTRADA ANALÓGICA
    BSF	    ANSELH, 2
    BSF	    ANSELH, 3
    BSF	    ANSELH, 4
    
    RETURN
;-----------------------------------------------
DELAY_4.375MS:
    MOVLW   .35			    ; 1250 US
    MOVWF   DELAY2
    CALL    DELAY_125US
    DECFSZ  DELAY2		    ;DECREMENTA CONT1
    GOTO    $-2			    ; IR A LA POSICION DEL PC - 1
    RETURN
    
DELAY_125US:
    MOVLW   .250		    ; 0.5US *250=125 US
    MOVWF   DELAY1	    
    DECFSZ  DELAY1		    ;DECREMENTA CONT1
    GOTO    $-1			    ; IR A LA POSICION DEL PC - 1
    RETURN
    
TMR0_CONFIG:				;TMR0'S CONFIGURATION (680us)
    BANKSEL	OPTION_REG	    ; CAMBIAMOS AL BANCO 1
    BCF		OPTION_REG, T0CS    ; SELECCIONAMOS TMR0 COMO TEMPORIZADOR
    BCF		OPTION_REG, PSA	    ; ASIGNAMOS PRESCALER A TMR0
    BCF		OPTION_REG, PS2
    BCF		OPTION_REG, PS1
    BCF		OPTION_REG, PS0	    ; PRESCALER DE 4
    clrwdt
    BANKSEL	TMR0
    MOVLW	.225		    ; DESBORDE DE CADA 8 US
    MOVWF	TMR0		    ; CARGAMOS EL N CALCULADO PARA UN DESBORDE DE 5mS
	
    BCF		INTCON, T0IF

    BSF		INTCON, T0IE
    
    RETURN
    
TMR1_CONFIG:				;TMR1'S CONFIGURATION (20ms)
    
    BANKSEL PORTA
    BSF	    T1CON, TMR1ON
    BCF	    T1CON, TMR1CS
    BCF		T1CON, TMR1GE	    ; TIMER UNO SIEMPRE VA CONTAR
    
    BCF	    T1CON, T1CKPS0
    BCF	    T1CON, T1CKPS1
    
    MOVLW   b'01100011'
    MOVWF   TMR1H
    MOVLW   b'11000000'
    MOVWF   TMR1L
    
    RETURN
    
    
INT_CONFIG:				;INTERRUPTS' INITIALIZATION
    ;BANKSEL	IOCB
    ;MOVLW	B'00000001'
    ;MOVWF	INTCON
    
    BANKSEL	PIE1
    BSF		PIE1, TMR1IE
    ;BSF		PIE1, TMR2IE
    
    BANKSEL	INTCON
    BSF		INTCON, GIE
    BSF		INTCON, PEIE
    RETURN
    
    
INT_TMR0:
    
    ; TOGGLE RB0 TO SEE FREQUENCY
    ;MOVLW   .1
    ;COMF   PORTB, F
    
    ; RESET TMR0
    BCF	    INTCON, T0IF
    MOVLW	.225
    MOVWF	TMR0
    
    ; INCREASE TMR0 COUNTER
    INCF    TMR0_DELAY, F
    
    ; COMPARE FIRST PWM
    MOVF    SERVO1, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, C
    BCF	    PORTA, RA0
    
    ; COMPARE SECOND PWM
    MOVF    SERVO2, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, C
    BCF	    PORTA, RA1
    
    ; COMPARE THIRD PWM
    MOVF    SERVO3, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, C
    BCF	    PORTA, RA2
    
    ; COMPARE FOURTH PWM
    MOVF    SERVO4, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, C
    BCF	    PORTA, RA3
    
    RETURN
    
INT_TMR1:
    
    ; TOGGLE RB1 TO SEE FREQUENCY
    ;MOVLW   .2
    ;XORWF   PORTB, F
    
    BSF	    PORTA, RA0
    BSF	    PORTA, RA1
    BSF	    PORTA, RA2
    BSF	    PORTA, RA3
    
    ; RESET TIMER
    BCF		PIR1, TMR1IF
    
    MOVLW   b'01100011'
    MOVWF   TMR1H
    MOVLW   b'11000000'
    MOVWF   TMR1L
    
    ; ENABLE AND RESET TMR0
    
    
    
    CLRF	TMR0_DELAY
    MOVLW	.225
    MOVWF	TMR0
    
    RETURN
        
    END