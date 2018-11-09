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
    SERVO1	    RES	    1	    ; VAR THAT PWM FOR SERVO 1 HAS TO REACH
    SERVO2	    RES	    1	    ; VAR THAT PWM FOR SERVO 2 HAS TO REACH
    SERVO3	    RES	    1	    ; VAR THAT PWM FOR SERVO 3 HAS TO REACH
    SERVO4	    RES	    1	    ; VAR THAT PWM FOR SERVO 4 HAS TO REACH
    TMR0_DELAY	    RES	    1	    ; VAR THAT COUNTS TMR0 INTS
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
    BTFSC	PIR1, TMR1IF		    ;IF TMR1 INTERRUPT
    CALL	INT_TMR1
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
    CALL    CLOCK_CONFIG		; INTERNAL CLOCK AT 8 MHz
    CALL    CONFIG_IO			; ALL PINS AS OUTPUT
    CALL    TMR0_CONFIG			; TMR0 INT AT 22 us
    CALL    TMR1_CONFIG			; TMR1 INT AT 20 ms
    CALL    INT_CONFIG			; ENABLE GLOBAL AND TMR INTS
    
    BANKSEL PORTA
    
    MOVLW   .33
    MOVWF   SERVO1
    MOVLW   .50
    MOVWF   SERVO2
    MOVLW   .75
    MOVWF   SERVO3
    MOVLW   .105
    MOVWF   SERVO4
    
;***************************
   
;***************************
; CICLO INFINITO
;***************************
LOOP:
    
    NOP
    
    GOTO LOOP
    
;-----------------------MISC FUNC-----------------------------
    
 ;------------------------INTS--------------------------------

 
INT_TMR0:
    
    ; TOGGLE RB0 TO SEE FREQUENCY
    MOVLW   .1
    XORWF   PORTB, F
    
    ; RESET TMR0
    BCF	    INTCON, T0IF
    
    MOVLW	.225
    MOVWF	TMR0
    
    ; INCREASE TMR0 COUNTER
    INCF    TMR0_DELAY, F
    
    ; COMPARE FIRST PWM
    MOVF    SERVO1, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, Z
    BCF	    PORTA, RA0
    
    ; COMPARE SECOND PWM
    MOVF    SERVO2, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, Z
    BCF	    PORTA, RA1
    
    ; COMPARE THIRD PWM
    MOVF    SERVO3, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, Z
    BCF	    PORTA, RA2
    
    ; COMPARE FOURTH PWM
    MOVF    SERVO4, W
    SUBWF   TMR0_DELAY, W
    BTFSC   STATUS, Z
    BCF	    PORTA, RA3
    
    RETURN
    
INT_TMR1:
    
    ; TOGGLE RB1 TO SEE FREQUENCY
    MOVLW   .2
    XORWF   PORTB, F
    
    ; RESET TIMER
    BCF		PIR1, TMR1IF
    
    MOVLW   b'01100011'
    MOVWF   TMR1H
    MOVLW   b'11000000'
    MOVWF   TMR1L
    
    ; ENABLE AND RESET TMR0
    BSF	    INTCON, T0IE
    BCF	    INTCON, T0IF
    
    CLRF	TMR0_DELAY
    MOVLW	.225
    MOVWF	TMR0
    
    RETURN
    
 ;---------------------------CONFIGS-----------------------------
 
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
    
    END
    