;***************************
;										*
;    Filename: Servo.asm							*
;    Autor: El Recan								*
;    Description: PWM code without CCP module					*
;    Creates a PWM of 7% o 9% duty cycle at 20ms depending o RB0's state
;   
;***************************
#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;***************************
    GPR_VAR        UDATA
    SERVO_DELAY	    RES	    1
    TMR2_DELAY	    RES	    1
    W_TEMP	    RES	    1	    ;TEMP W FOR INTERRUPTS
    STATUS_TEMP	    RES	    1	    ;TEMP STATUS FOR INTERRUPTS
;***************************
; Reset Vector
;***************************

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
    BTFSC	PIR1, TMR1IF		    ;IF PORTB INTERRUPT
    CALL	INT_TMR1
;    BTFSC	PIR1, TMR2IF		    ;IF PORTB INTERRUPT
;    CALL	INT_TMR2
    BSF		INTCON, GIE		    ;REENABLE GLOBAL INTERRUTPS
    
 POP:				    ;RESTORE BACKUP
    SWAPF	STATUS_TEMP,W
    MOVWF	STATUS
    SWAPF	W_TEMP,F
    SWAPF	W_TEMP,W
    RETFIE			    ;RETURN FROM INTERRUPTS
    
;***************************
; MAIN PROGRAM
;***************************

MAIN_PROG CODE                      ; let linker place main program

START
;***************************
    CALL    CLOCK_CONFIG		; RELOJ INTERNO DE 250KHz
    CALL    CONFIG_IO
    CALL    TMR0_CONFIG
    CALL    TMR1_CONFIG
;    CALL    TMR2_CONFIG
    CALL    INT_CONFIG
    
    
    BANKSEL PORTA
    
   
    
    MOVLW   .100
    MOVWF   SERVO_DELAY
;***************************
   
;***************************
; CICLO INFINITO
;***************************
LOOP:
    
    NOP
    nop
    nop 
    nop
    nop
    nop
    
    GOTO LOOP
 
 ;------------------------INTS--------------------------------

 
INT_TMR0:
    
    MOVLW   .1
    XORWF   PORTA, F
    
    ;DESPUES DE 1ms, ACTIVAR TMR2 Y DESACTIVARSE
    BCF	    INTCON, T0IF
;    BSF	    T2CON, TMR2ON
;    
;    BCF	    INTCON, T0IE
    
    MOVLW	.225
    MOVWF	TMR0
    
    RETURN
    
INT_TMR1:
    
    MOVLW   .2
    XORWF   PORTA, F
    
    BCF		PIR1, TMR1IF
    ;ACTIVAR TMR2
;    BSF	    PORTC, 0
;    BSF	    INTCON, T0IE
    
    MOVLW   b'01100011'
    MOVWF   TMR1H
    MOVLW   b'11000000'
    MOVWF   TMR1L
    
    RETURN
    
INT_TMR2:
    
    ;DESPUES DE 'SERVO_DELAY' VECES, DESACTIVAR PIN Y A SI MISMO
    BANKSEL PIR1
    BCF	PIR1, TMR2IF
    
    MOVLW   .171
    MOVWF   TMR2
    
    MOVLW   .4
    XORWF   PORTA, F
    
    INCF    TMR2_DELAY, F
    
    MOVF    TMR2_DELAY, W
    SUBWF   SERVO_DELAY, W
    BTFSS   STATUS, Z
    RETURN
    
    MOVLW   .8
    XORWF   PORTA, F
    ;BCF	    PORTC, 0
;    BANKSEL	PIE1
;    BCF	    PIE1, TMR2IE
;    BANKSEL	PORTA
    CLRF    TMR2_DELAY
    
    RETURN
    
 ;--------------------------------------------------------
 
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
 
CLOCK_CONFIG:				;CLOCK AT 1MHz
   BANKSEL	OSCCON
   BSF		OSCCON, IRCF2
   BSF		OSCCON, IRCF1
   BsF		OSCCON, IRCF0
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
    CLRF    TMR2_DELAY
    RETURN    
    
TMR0_CONFIG:				;TMR0'S CONFIGURATION (680us)
    BANKSEL	OPTION_REG	    ; CAMBIAMOS AL BANCO 1
    BCF		OPTION_REG, T0CS    ; SELECCIONAMOS TMR0 COMO TEMPORIZADOR
    BsF		OPTION_REG, PSA	    ; ASIGNAMOS PRESCALER A TMR0
    ;BCF		OPTION_REG, PS2
    ;BCF		OPTION_REG, PS1
    ;BSF		OPTION_REG, PS0	    ; PRESCALER DE 4
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
    
TMR2_CONFIG:				;TMR2'S CONFIGURATION (4us)
    
    BANKSEL TMR2
    MOVLW   .171
    MOVWF   TMR2
    
    BANKSEL PORTA
    MOVLW   b'00000110'
    MOVWF   T2CON
    BANKSEL	PIE1
    BSF	    PIE1, TMR2IE
;    BANKSEL PR2
;    CLRF    PR2
    BANKSEL PORTA
    RETURN
    
    END
    