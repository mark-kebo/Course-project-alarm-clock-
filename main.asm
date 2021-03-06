;*******************************************************************************
;                                                                              *
;    Filename:  ALARM CLOCK                                                    *
;    Date:      19.10.17                                                       *
;    File Version:   1.7                                                    *
;    Author:         Dmitry Vorozhbicky                                        *
;    Company:        GrSU                                                      *
;                                                                              *
;*******************************************************************************  
;processor    PIC16F877
include  <P16F877.INC>
errorlevel   -302
;���������  ����  �����������,  ���-
;��������  �������������  �����  �  ��-
;���� ��������� �� �������
#define   bank0  bcf STATUS,  RP0
#define   bank1  bsf STATUS,  RP0
;���������, ����������� �������� � ����  ��  �������,  ���������  �����
;����  ���������  (bcf  ,  bsf)  �  ������� bank0, bank1. �������� ������ ���������� ����������
WAIT		    equ	    0x20
Reg_1		    equ	    0x23    ;��������, ������������ ��� ��������
Reg_2		    equ	    0x24
Reg_3		    equ	    0x25
fCOUNTER	    equ     0x26
fCOUNTER2	    equ     0x27
TIME_HH1	    equ	    0x30    ;�������, ������� ������ �������� ������ �����
TIME_HH2	    equ	    0x31    ;�������, ������� ������ �������� �������� �����
TIME_MM1	    equ	    0x32    ;�������, ������� ������ �������� ������ �����
TIME_MM2	    equ	    0x33    ;�������, ������� ������ �������� �������� �����
TIME_SS1	    equ	    0x34    ;�������, ������� ������ �������� ������ ������
TIME_SS2	    equ	    0x35    ;�������, ������� ������ �������� �������� ������
DAY		    equ	    0x36    ;�������, ������� ������ �������� ��� ������
ALARM_HH1	    equ	    0x37    ;�������, ������� ������ �������� ������ ����� ��� ����������
ALARM_HH2	    equ	    0x38    ;�������, ������� ������ �������� �������� ����� ��� ����������
ALARM_MM1	    equ	    0x39    ;�������, ������� ������ �������� ������ ����� ��� ����������
ALARM_MM2	    equ	    0x3A    ;�������, ������� ������ �������� �������� ����� ��� ����������
Key1		    equ	    0x3B    ;��������, ������� ������ ��������� ������ � ��������  
Key2		    equ	    0x3C    ;���������� Keyboard
Key3		    equ	    0x3D
Key4		    equ	    0x3E
Key9		    equ	    0x3F
Blink		    equ	    0x40    ;�������, ��� ���������� ��������� ��������� ������
Cnt		    equ	    0x41    ;�������, ������� ������ ��������� ������� � �������� (������ ��� ���)
Blink_Alarm	    equ	    0x42    ;����������� �������, ������� ��������� ������� ���������\���������� ����������
NumPressKey	    equ	    0x43    ;����������� �������-�����, ��� ������������� ��������� �������� � ������ ���������� ��������
fCOUNTER1	    equ     0x44    ;������� ������������ ��� ��������    
TEMP_TIME_HH1	    equ	    0x45    ;��������, ������� ������ ��������: �����, �����, ������ ��������� �������;
TEMP_TIME_HH2	    equ	    0x46    ;�������� ��� � �����, ����� ����������. ������ ��� ���������� ������� ��������
TEMP_TIME_MM1	    equ	    0x47    ;����� ���������� � ��������������� �������
TEMP_TIME_MM2	    equ	    0x48
TEMP_TIME_SS1	    equ	    0x49
TEMP_TIME_SS2	    equ	    0x4A
TEMP_DAY	    equ	    0x4B
TEMP_ALARM_HH1	    equ	    0x4C
TEMP_ALARM_HH2	    equ	    0x4D
TEMP_ALARM_MM1	    equ	    0x4E
TEMP_ALARM_MM2	    equ	    0x4F
NumAlarmBit	    equ	    0x50    ;��� ��, ��� Blink_Alarm, ��������� ���������� ���������� � ����������� ����������
    
wait  macro     time
    movlw    (time/5)-1
    movwf    WAIT
    call    wait5u
    endm
;������ ����� � ������ wait. ����������� ����� ������� ������� � ���, ���
;�  ����  �������  ��������  �  time.  ��� ������  �������  ��������  ���������
;�����������  �����  �����  �������  � ����  ������  �����������  �����  ����-
;����  5  (�  ������  �������).  �  ���� �������  ���  �����  �������������  �
;������������ time � ����� ������������ ����������� �������� (������� �
;������ ������  ���������  �  ����  ���������, ������������ � W). ������ �
;����������  wait5u  ������������  ��������,  ��������������  ��������
;����� time �����������
    org 0x0000
    clrf STATUS
    movlw 0x00
    movwf PCLATH
    goto begin
;����� ������� �������� ������ ������ � ���������� �� ��� ������������������ ����

begin
    bank1			;����� ������� ����� ������. ��� ��-
				;���� ������������ ����� bank1, �����-
				;������ ���� ���������� #define.
    movlw 0x8F			;���������  �������������  �������
    movwf OPTION_REG		;������������  �����������  �������  � ��� �����
    clrwdt
    clrf INTCON			;����������  ����������  �  ��  ���������
    clrf PIE1
    clrf PIE2
    movlw .0			;����������������  ������  �, �, �, �, D
    movwf TRISB
    movwf TRISC
    movwf TRISE
    movlw b'11111000' 
    movwf TRISA 
    movlw b'00000000'		
    movwf TRISD
    movlw b'00001111'
    movwf OPTION_REG
    clrf ADCON1 
    bsf ADCON1,0x01 
    bsf ADCON1,0x02 
    bank0			;���������� � �������� ������ �� ����������
    clrf Key1	 
    clrf Key2	    
    clrf Key3	    
    clrf Key4	    	   
    clrf Key9	    	    
    clrf Cnt	    	    
    clrf PORTC
    clrf PORTD
    movlw 0x01
    call write
    movlw 0x0f
    call delay
;�������� ������� Clear  Display ��� ������� ������� � ��������� �������� ������ �������-
;����  ��  �������  �����  (������  ����������  � ������� ������), � ����������� ���������
    clrwdt
    movlw 0x38
    call write
    movlw 0x0f
    call delay

;�������� ������� Function Set ��� ��������� ������  2-�  ���������  ����������,  �������
;���������� 5�7 � 8 ��������� ���� ������
    movlw 0x06
    call write
    movlw 0x0f
    call delay
;��������  �������  Entry  Mode  Set  ���  ��������� ������ ���������� �������� ������ ��-
;���������, ����� ������ ������ ������� � ���, ��� ������������� ����������� ������������ ����������
    movlw 0x0c
    call write
    movlw 0x0f
    call delay
;��������  �������  Display  ON/OFF  control ��� ��������� ������� � ����������� �����-
;���.  ��  ����  ���� ������������� ������� ��������.
    movlw 	0x36		;� �������� ���� ���������
    movwf	ALARM_HH1
    movlw 	0x30
    movwf	TIME_SS2 
    movwf	TIME_SS1	;���������� ��������� �������� ��������� ������� � ���,
    movwf	ALARM_MM1	;� ��� �� ��������� ����������� ��������� �� �������� 
    movwf	TIME_SS2  	;� �������� ���� ���������
    movwf	TIME_HH1
    movwf	TIME_HH2
    movwf	TIME_MM1
    movwf	TIME_MM2
    movwf	ALARM_HH2
    movwf	ALARM_MM2
    movlw 	.0
    movwf	DAY
    movwf	Blink_Alarm
    movwf	NumAlarmBit
    movlw 	b'00000000'
    movwf	Blink

START				;����� ������ ��������� ����� ���������
    movlw .0			;���������� �������� �������, ��� � ��������� ������������ �������� 
    movwf Blink_Alarm		;� ������ ������� ������� ��������� �����
    movfw TIME_HH2		
    movwf TEMP_TIME_HH2		
    movfw TIME_HH1		
    movwf TEMP_TIME_HH1
    movfw TIME_MM2		
    movwf TEMP_TIME_MM2
    movfw TIME_MM1		
    movwf TEMP_TIME_MM1
    movfw TIME_SS2		
    movwf TEMP_TIME_SS2
    movfw TIME_SS1		
    movwf TEMP_TIME_SS1
    movfw DAY
    movwf TEMP_DAY
    movlw 0x00
    movwf NumPressKey		; NumPressKey ������ ��� ������������� � ��������� ��������
    movfw ALARM_HH1
    movwf TEMP_ALARM_HH1
    movfw ALARM_HH2
    movwf TEMP_ALARM_HH2
    movfw ALARM_MM1
    movwf TEMP_ALARM_MM1
    movfw ALARM_MM2
    movwf TEMP_ALARM_MM2
    
    call Keyboard		; ������ ����������
    btfsc Key1,0		; �������� ������� ������� "1",  ���� ������, �� ��������� 
    call time_plus_blink	; � ��������� �������, ��� - ����� ��������� ������� 2
    btfsc Key2,0		; �������� ������� ������� "2",  ���� ������, �� ��������� 
    call day_plus_blink		; � ��������� ��� ������, ��� - ����� ��������� ������� 3
    btfsc Key3,0		; �������� ������� ������� "3",  ���� ������, �� ��������� 
    call alarm_plus_blink	; � ��������� ����������, ��� - ����� ���� ������
	
    call LCD_one		;��������� ������ ������ �� �������		

    ;���� ������ ������ (0-9) - TIME_SS1 all-41
    incf TIME_SS1,1
    movlw 0x3A			; ��������� ��������� �������� ������ ������ � ����
    xorwf TIME_SS1, w;		; ��� �������� !=10, �� ��������� � ����� ����� ��������� ������� 
    btfss STATUS, 0x02		; ���� �� �������� ������� = 10, �� �������� ��� � ��������� � ���������
    goto v_nop			; �������� ������ 
    movlw 0x30			; (37)
    movwf TIME_SS1

    ;���� �������� ������ (0-5) - TIME_SS2
    incf TIME_SS2,1		; ��������� ��������� �������� �������� ������ � ����
    movlw 0x36			; ��� �������� !=6, �� ��������� � ����� ����� ��������� �������
    xorwf TIME_SS2, w;		; ���� �� �������� ������� = 6, �� �������� ��� � ��������� � ���������
    btfss STATUS, 0x02		; ������ �����
    goto c_nop			; (31)
    movlw 0x30
    movwf	TIME_SS2
	
    ;���� ������ ����� (0-9) - TIME_MM1
    incf TIME_MM1,1		; ��������� ��������� �������� ������ ����� � ����
    movlw 0x3A			; ��� �������� !=10, �� ��������� � ����� ����� ��������� ������� 
    xorwf TIME_MM1, w		; ���� �� �������� ������ = 10, �� �������� ��� � ��������� � ���������
    btfss STATUS, 0x02		; �������� �����
    goto x_nop			; (25)
    movlw 0x30
    movwf	TIME_MM1

    ;���� �������� ����� (0-5) - TIME_MM2(5)
    incf TIME_MM2,1		; ��������� ��������� �������� �������� ����� � ����
    movlw 0x36			; ��� �������� !=6, �� ��������� � ����� ����� ��������� �������
    xorwf TIME_MM2, w		; ���� �� �������� ������ = 6, �� �������� ��� � ��������� � ���������
    btfss STATUS, 0x02		; ������ �����
    goto z_nop			;(19)
    movlw 0x30
    movwf	TIME_MM2

    ;���� ������ � �������� ����� - TIME_��2, TIME_��1(17)
    incf TIME_HH1,1		; ��������� ��������� �������� ������ ����� � ����
    movlw 0x34 			; ��� �������� !=4, �� ��������� � ����� ������ � ��������� 
    xorwf TIME_HH1, w;		; ����� �� 10.
    btfss STATUS, 0x02
    goto ten_clock_five
    movlw 0x32			; ���� �������� �������� ����� !=2, �� ��� �� ��������
    xorwf TIME_HH2, w;		; � �������� �� 10, ������ �� �����
    btfss STATUS, 0x02
    goto ten_clock_one
    movlw 0x30			; ��������� �������� � ������ �����
    movwf	TIME_HH1
    movwf	TIME_HH2
    incf    DAY,1		; ��������� ���������� ����, ��� �������� � ����� ���� � 00:00
    movlw 	.7		; ��������� ���������� ��� ���������� �����������,
    xorwf DAY, w;		; ��� �� ��� 00:00:00 ������� � �����������
    btfss STATUS, 0x02			 
    goto two_nop			
    movlw 	.0
    movwf	DAY
    goto end_clock
        
ten_clock_five			;��� ��������������� ������
    nop nop nop
    goto ten_clock
ten_clock_one
    goto ten_clock		;��� ��������������� ������
	
ten_clock
    movlw 0x3A 			; ���� �������� ������ ����� !=10, �� 
    xorwf TIME_HH1, w;		; ��������� � ����� ��������� �������.
    btfss STATUS, 0x02		; ���� �������� = 10, �� �������������� ������� �����
    goto three_nop		; � �������� �������� ������
    incf    TIME_HH2
    movlw 0x30
    movwf	TIME_HH1
    goto end_clock
v_nop	    nop	nop nop nop nop nop nop		;���������� ������ ��������� 
c_nop	    nop nop nop nop nop nop nop		;� ����������� �� �������
x_nop	    nop	nop nop nop nop nop nop 
z_nop	    nop nop nop nop nop nop nop nop nop   		
	    nop nop nop nop nop nop nop nop nop
three_nop   nop			;��� ��������������� ������
two_nop	    nop nop
end_clock			; ����� ����� ������ �� ��������
    clrwdt			; ������ �� ������
    
;��������� ����������
    movlw .1			; ���������, ����� �� ������� ����������� �������
    xorwf NumAlarmBit, w
    btfsc STATUS, 0x02
    goto delay_seven			; ���� ����� ��������� ����� � ������� ������ ������� 9		
    movlw 0x30 			; ���� ������� ������ = 0, ��
    xorwf TIME_SS1, w;		; ��������� � �������� �������� ������, ����������� ��������
    btfsc STATUS, 0x02		; ��������� � ���. ���� �� ����� 0, �� ��������� �� ����� �
    goto if_S_TWO_ZERO		; ����� ��������� ����������
    goto delay_six   
if_S_TWO_ZERO    
    movlw 0x30 			
    xorwf TIME_SS2, w;
    btfsc STATUS, 0x02
    goto if_T_AT_H2		; ������� � �������� �� ��������� �������� ����� � ����������
    goto delay_five    
	
if_T_AT_H2			; ���� �������� �������� ���������� � ��������� ������� �����, ��
    movfw TIME_HH2 		; ��������� � �������� ������. ���� ���, �� ���������� �������� 
    xorwf ALARM_HH2, w;		; ����������.
    btfsc STATUS, 0x02		; ����������� �������� �������� � ��� �����.
    goto if_T_AT_H1
    goto delay_four
    
if_T_AT_H1			; �������� ������ ���� � ����� � ����������
    movfw TIME_HH1 		
    xorwf ALARM_HH1, w;		
    btfsc STATUS, 0x02
    goto if_T_AT_M2
    goto delay_three
    
if_T_AT_M2			; �������� �������� ����� ����� � ����������
    movfw TIME_MM2 		
    xorwf ALARM_MM2, w;		
    btfsc STATUS, 0x02
    goto if_T_AT_M1
    goto delay_two
    
if_T_AT_M1			; �������� ������ ����� ����� � ����������
    movfw TIME_MM1 		
    xorwf ALARM_MM1, w;		
    btfsc STATUS, 0x02
    goto inc_BA			; ���� ��� �������� �������, �� ��������� � �����,
    goto delay_one		; ��� ����������� ������������ �������� Blink_Alarm 
				; �������, ����� ���� ��������� � �������
inc_BA				; ������ ����������, ��� �������� ������� ������
    movlw .1			; 9, ��� ��������� ����������� ���������, ���
    movwf Blink_Alarm		; ��������� �������� ������ � �������� ������
    goto blinkON
    
NULL_BA_NAB			; ��������� ����������� ���������
    movlw .0
    movwf NumAlarmBit
    movwf Blink_Alarm
    goto end_ALARM
    
blinkON
    call Keyboard	    ; ���������� ����������
    btfsc Key9,0
    goto NULL_BA_NAB	    ; ���� ������ ������ 9 ��������� � �������, ��� �������� ����������� ��������
    movlw .1		    ; ���� ���, �� ������������� NumAlarmBit=1 ��� ������������ �������� � ��������� �������
    movwf NumAlarmBit	    ; ���� �� ������ 9.
    nop nop nop
end_ALARM		    ;����� ����� ��������� ����������
    call LCD_two	    ;��������� ������ ������
    call delay_one_sec	    ;�������� ���� �� 1���
    goto START		    ; ����� ��������� ����� (������ ���� = 1���)

    ;--------------------------------------------------------
    ;--------------------------------------------------------
    
; ��������� ���� switch ��� ������ � ��������� ��� ������
DEC addwf PCL		;� ����������� �� ����������� ��������
    goto monday
    goto tuesday
    goto wednesday	
    goto thursday    
    goto friday		
    goto saturday		
    goto sunday		
    return
;��������� ���� ������
monday			    ;�����������
    movlw 'M'
    call write
    movlw 'O'
    call write
    movlw 'N'
    call write
    goto exday
tuesday			    ;�������
    movlw 'T'
    call write
    movlw 'U'
    call write
    movlw 'E'
    call write
    goto exday
wednesday		    ;�����
    movlw 'W'
    call write
    movlw 'E'
    call write
    movlw 'D'
    call write
    goto exday
thursday		    ;�������
    movlw 'T'
    call write
    movlw 'H'
    call write
    movlw 'U'
    call write
    goto exday
friday			    ;�������
    movlw 'F'
    call write
    movlw 'R'
    call write
    movlw 'I'
    call write
    goto exday
saturday		    ;�������
    movlw 'S'
    call write
    movlw 'A'
    call write
    movlw 'T'
    call write
    goto exday
sunday			    ;�����������
    movlw 'S'
    call write
    movlw 'U'
    call write
    movlw 'N'
    call write
exday			    
    return

    ;--------------------------------------------------------
    
time_plus_blink		    ; ������� ��������� ����� ��������� � ������ �����
    movlw 0x1		    ; ��������, ��� ������ �� ��������
    call delay				
    call Keyboard	    ;����� ���������� ��� �� �������� ������ ������� ��� ���
    movf Cnt,1		    ;���� ���, �� ������
    btfss STATUS,Z			
    goto time_plus_blink
    incf NumPressKey,1	    ;���� ������� ������, �� �������������� NumPressKey
    goto change_time	    ;��� ������ ������, � ������� ����� ���������� ��������.
    return		    ;����� ���� ��������� � ��������� �������
    
day_plus_blink		    ; ������� ��������� ����� ��������� � ������ �����
    movlw 0x1		    ; ��������, ��� ������ �� ��������		
    call delay				
    call Keyboard	    ;����� ���������� ��� �� �������� ������ ������� ��� ���
    movf Cnt,1		    ;���� ���, �� ������
    btfss STATUS,Z			
    goto day_plus_blink
    movlw 0x8		    ;���� ������� ������, �� ��������� NumPressKey = 8
    movwf NumPressKey	    ;��� ������ ������, � ������� ����� ���������� ��������.
    goto change_day	    ;����� ���� ��������� � ��������� ��� ������
    return
    
alarm_plus_blink	    ; ������� ��������� ����� ��������� � ������ �����
    movlw 0x1		    ; ��������, ��� ������ �� ��������		
    call delay				
    call Keyboard	    ;����� ���������� ��� �� �������� ������ ������� ��� ���
    movf Cnt,1		    ;���� ���, �� ������
    btfss STATUS,Z			
    goto alarm_plus_blink
    movlw 0x9		    ;���� ������� ������, �� ��������� NumPressKey = 9
    movwf NumPressKey	    ;��� ������ ������, � ������� ����� ���������� ��������.
    goto change_alarm	    ;����� ���� ��������� � ��������� ����������
    return
    ;--------------------------------------------------------
    
write			    ;��������� ������ ����� � ���������� HD
    bcf STATUS, RP1
    bcf STATUS, RP0
    movwf PORTB
    bsf PORTC, 2
    movlw 0x01
    call delay
    bcf PORTC, 2
    return
; ����� ������� ���� ��������� � W ���������� ����, ������� ���� �������� � HD. �����
;�� ���������� � PORTB � ����������� ������������� ������� �� RC2, ����� ������������-
;���  ���  ���������  �  �1�,  ���������  ����� ������ � ������� ���������� ������� (������-
;������� �������� �������� delay  ���  W=1) � ������ ��� � �0�.
	
delay			    ;���������  ��������,  �����  �������  �����
    bcf   STATUS, RP1	    ;������������, ������� ����� � W
    bcf   STATUS, RP0
    movwf   fCOUNTER2
    clrf    fCOUNTER
    
BD_Loop
    clrwdt
    decfsz  fCOUNTER, f
    goto    BD_Loop
    decfsz  fCOUNTER2, f
    goto    BD_Loop
    return

delay_one_sec			;������������� ��������
;��� ����������� ������� ������
;��������� � ����������� �� ������ �������
;���������� ������������ ������, �.�. � 
;����� ������ �������� ���� ������ ����������� 
;�� 1 ���
; �������� 775 567 �������� ������
; �������� 772 567 �������� ������
            movlw       .3
            movwf       Reg_1
            movlw       .235
            movwf       Reg_2
            movlw       .4
            movwf       Reg_3
            decfsz      Reg_1,F
            goto        $-1
            clrwdt
            decfsz      Reg_2,F
            goto        $-4
            decfsz      Reg_3,F
            goto        $-6
    return   
delay_one
    movlw       .20
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto end_ALARM
	    
delay_two
    movlw       .22
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto end_ALARM
	    
delay_three
    movlw       .24
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto end_ALARM
	    
delay_four
    movlw       .26
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto end_ALARM
	    
delay_five
    movlw       .28
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto end_ALARM
	    
delay_six
    movlw       .30
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto end_ALARM
	    
delay_seven
    movlw       .33
    movwf       Reg_1
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    nop
    goto inc_BA	
    ;==========================================

LCD_one
;��������� RC0=0, ��� ����������� �������� �������  ��  ����������  HD.  ����������  ��-
;����� Set DDRAM address,  ��������������� �������  ������  �����������  ��  ������  1-�� 
;������:  ������  �  �������  (10000000). ���  ����������  ���  ������  
;������� � ��� ������ �� ������ ������ ����������.
    bcf PORTC, 0
    movlw b'10000000'	
    call write
    bsf PORTC,0
;��������� ������ ������
; ��������� �2
    call paintH2
; ��������� �1
    call paintH1
    movlw ':'
    call write
; ��������� �2
    call paintM2
; ��������� �1
    call paintM1
    movlw ':'
    call write
; ��������� S2
    call paintS2
; ��������� S1
    call paintS1
    movlw ' '
    call write
    movlw ' '
    call write
;��������� ��� ������
    call printDay

    return
    
    ;==========================================
    
; ���������� �������� ����������������� �������� ��� ��������� �������
paintH2				;�������� �������� �����
    movlw 0x1			;���� NumPressKey = 1, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_H2		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 1, �� ��������� ��������� �������
    goto blink_on_H2		;� ������������ ��������� ��������
    goto blink_off_H2
blink_off_H2
    movlw ' '
    call write
    goto return_H2
blink_on_H2
    movfw TIME_HH2
    call write
return_H2    
    return
    ;-----------
paintH1				;�������� ������ �����
    movlw 0x2			;���� NumPressKey = 2, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_H1		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 2, �� ��������� ��������� �������
    goto blink_on_H1		;� ������������ ��������� ��������
    goto blink_off_H1
blink_off_H1
    movlw ' '
    call write
    goto return_H1
blink_on_H1
    movfw TIME_HH1
    call write
return_H1
    return
    ;------------
paintM2				;�������� �������� �����
    movlw 0x3			;���� NumPressKey = 3, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_M2		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 3, �� ��������� ��������� �������
    goto blink_on_M2		;� ������������ ��������� ��������
    goto blink_off_M2
blink_off_M2
    movlw ' '
    call write
    goto return_M2
blink_on_M2
    movfw TIME_MM2
    call write
return_M2
    return
    ;------------
paintM1				;�������� ������ �����
    movlw 0x4			;���� NumPressKey = 4, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_M1		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 4, �� ��������� ��������� �������
    goto blink_on_M1		;� ������������ ��������� ��������
    goto blink_off_M1
blink_off_M1
    movlw ' '
    call write
    goto return_M1
blink_on_M1
    movfw TIME_MM1
    call write
return_M1
    return
    ;------------
paintS2				;�������� �������� ������
    movlw 0x5			;���� NumPressKey = 5, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_S2		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 5, �� ��������� ��������� �������
    goto blink_on_S2		;� ������������ ��������� ��������
    goto blink_off_S2
blink_off_S2
    movlw ' '
    call write
    goto return_S2
blink_on_S2
    movfw TIME_SS2
    call write
return_S2
    return
    ;------------
paintS1				;�������� ������ ������
    movlw 0x6			;���� NumPressKey = 6, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_S1		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 6, �� ��������� ��������� �������
    goto blink_on_S1		;� ������������ ��������� ��������
    goto blink_off_S1
blink_off_S1
    movlw ' '
    call write
    goto return_S1
blink_on_S1
    movfw TIME_SS1
    call write
return_S1
    return
    ;-----------
printDay			;�������� ��� ������
    movlw 0x8			;���� NumPressKey = 8, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_day		;�� ���������. ���� ������������ �������� ���,
    incf Blink,1		;� ������ ������� �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 8, �� ��������� ��������� �������
    goto blink_on_day		;� ������������ ��������� ��������
    goto blink_off_day
blink_off_day
    movlw ' '
    call write
    movlw ' '
    call write
    movlw ' '
    call write
    goto return_DAY
blink_on_day
    movfw DAY				
    call DEC
return_DAY
    return
    ;==========================================   
    
LCD_two
    bcf PORTC, 0
    movlw b'11000100'
    call write
;��������� RC0=0, ��� ����������� �������� �������  ��  ����������  HD.  ����������  ��-
;����� Set DDRAM address,  ��������������� �������  ������  �����������  ��  ������  2-��
;������:  ������  �  �������  (11000100). ���  ����������  ���  ������  �����  �ALARM� � ���������� �� ������ ������ ����������.
    bsf PORTC,0			; ��������� RC0=1, ��� ����������� ��������
				;����� �������� ������ ������ �� �������. ��-
				;������ �������� �� ��, ��� ����� �� ���������
				;���������  ������  ������: �.�. ��� ��������, �
				;�������� �������� ��, ��������� � 0-�� �����.
    call paint_ALARM		;����� ������ ���������
    
    movlw ' '
    call write
    movlw ' '
    call write
    
    call paintH2_A		;����� ������ ���������
    call paintH1_A		;����� ������ ���������
    movlw ':'
    call write
    call paintM2_A		;����� ������ ���������
    call paintM1_A		;����� ������ ���������
    return
    ;------------------------------------------
paintH2_A			;�������� �������� ����� ����������
    movlw 0x9			;���� NumPressKey = 9, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_H2_A		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 9, �� ��������� ��������� �������
    goto blink_on_H2_A		;� ������������ ��������� ��������
    goto blink_off_H2_A
blink_off_H2_A
    movlw ' '
    call write
    goto return_A_H2
blink_on_H2_A
    movfw ALARM_HH2
    call write
return_A_H2
    return
    ;-----------
paintH1_A			;�������� ������ ����� ����������
    movlw 0xa			;���� NumPressKey = 10, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_H1_A		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 10, �� ��������� ��������� �������
    goto blink_on_H1_A		;� ������������ ��������� ��������
    goto blink_off_H1_A
blink_off_H1_A
    movlw ' '
    call write
    goto return_A_H1
blink_on_H1_A
    movfw ALARM_HH1
    call write
return_A_H1
    return
    ;------------
paintM2_A			;�������� �������� ����� ����������
    movlw 0xb			;���� NumPressKey = 11, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_M2_A		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 11, �� ��������� ��������� �������
    goto blink_on_M2_A		;� ������������ ��������� ��������
    goto blink_off_M2_A
blink_off_M2_A
    movlw ' '
    call write
    goto return_A_M2
blink_on_M2_A
    movfw ALARM_MM2
    call write
return_A_M2
    return
    ;------------
paintM1_A			;�������� ������ ����� ����������
    movlw 0xc			;���� NumPressKey = 12, �� �������� ��������
    xorwf NumPressKey, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_M1_A		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� NumPressKey != 12, �� ��������� ��������� �������
    goto blink_on_M1_A		;� ������������ ��������� ��������
    goto blink_off_M1_A
blink_off_M1_A
    movlw ' '
    call write
    goto return_A_M1
blink_on_M1_A
    movfw ALARM_MM1
    call write
return_A_M1
    return
    ;----------
paint_ALARM			;�������� ������� ����������
    movlw .1			;���� Blink_Alarm = 1, �� �������� ��������
    xorwf Blink_Alarm, w;	;� ����������� �� �������� Blink ����������
    btfss STATUS, 0x02		;������� ���� �� �������, ����������
    goto blink_on_ALARM_nop		;�� ���������. ���� ������������ �������� �������,
    incf Blink,1		;� ������ ������ �������. ��� ��������� ������ ��������.
    btfss Blink, 0		;���� Blink_Alarm != 1, �� ��������� ��������� �������
    goto blink_on_ALARM		;� ������������ ��������� ��������
	goto blink_off_ALARM
blink_off_ALARM
    bcf PORTD,0x01
    movlw ' '
    call write
    movlw ' '
    call write
    movlw ' '
    call write
    movlw ' '
    call write
    movlw ' '
    call write
    goto return_ALARM
blink_on_ALARM_nop nop nop nop
blink_on_ALARM
    bsf PORTD,0x01
    movlw 'A'
    call write
    movlw 'L'
    call write
    movlw 'A'
    call write
    movlw 'R'
    call write
    movlw 'M'
    call write
return_ALARM
    return
    ;==========================================
    
Keyboard		    ; ������� ���������� ��� ������ 1-4, 9
    bank0		    ; ������� � ������� ����, ��� ����������� ������ ������� �� ���� ���������
    bcf STATUS, RP1
    clrf Key1		    ; ��������� ����� ������
    clrf Key2 
    clrf Key3
    clrf Key4  
    clrf Key9  
    clrf Cnt  
col1			    ; ��������� ������ �������, ��� ��� ����� ������� 1, 4
    bsf PORTA,0		    ; ������ �������
    bcf PORTA,1
    bcf PORTA,2 
    ;movlw .24
    ;call small_delay
    movf PORTA,W	    ; ������ ���� � � W � ��������� ����������� ��������� ����� ����� �� ����� 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; ���� Z=1 (�.�. �� ������ �� ���� �� ������) ��������� �� ����� col2
    goto col2		    ; ��� ������������ ������� ������� ����������. ���� Z=0, �� ���������� ������
    ;movlw .250
    ;call small_delay  
    btfsc PORTA,3	    ; ���������� ������� ������� "1", ������� ����� ������ ������
    incf Key1,F
    btfsc PORTA,4	    ; ���������� ������� ������� "4", ������� ����� ������ ������
    incf Key4,F
    
col2			    ; ��������� ������ �������, ��� ��� ����� ������� 2
    bcf PORTA,0		    ; ������ �������
    bsf PORTA,1
    bcf PORTA,2 
    ;movlw .24
    ;sd
    movf PORTA,W	    ; ������ ���� � � W � ��������� ����������� ��������� ����� ����� �� ����� 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; ���� Z=1 (�.�. �� ������ �� ���� �� ������) ��������� �� ����� col3
    goto col3		    ; ��� ������������ �������� ������� ����������. ���� Z=0, �� ���������� ������
    ;movlw .250
    ;sd
    btfsc PORTA,3	    ; ���������� ������� ������� "2", ������� ����� ������ ������
    incf Key2,F
col3			    ; ��������� ������ �������, ��� ��� ����� ������� 3
    bcf PORTA,0		    ; ������ �������
    bcf PORTA,1
    bsf PORTA,2
    ;movlw .24
    ;sd
    movf PORTA,W	    ; ������ ���� � � W � ��������� ����������� ��������� ����� ����� �� ����� 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; ���� Z=1 (�.�. �� ������ �� ���� �� ������) ������� �� �������
    goto nop_end_key	    ; ���� Z=0, �� ���������� ������
    ;movlw .250
    ;sd
    btfsc PORTA,3	    ; ���������� ������� ������� "3", ������� ����� ������ ������
    incf Key3,F
    btfsc PORTA,5	    ; ���������� ������� ������� "9", ������� ����� ������ ������
    incf Key9,F
    goto end_keyb
 
nop_end_key nop nop nop nop nop nop
end_keyb		    ;�����, ��� ������ � Cnt = 1, ���� ������ ������� (����� ��� ��������, �������� �� �������)
    btfsc Key1,0
    incf Cnt,F
    btfsc Key2,0
    incf Cnt,F
    btfsc Key3,0
    incf Cnt,F
    btfsc Key4,0
    incf Cnt,F
    btfsc Key9,0
    incf Cnt,F
    return		    ; ����� �� �������
    
;==============================================

change_time		    ; ������� ��������� �������
    call Keyboard	    ; ���������� ����������
    btfsc Key1,0
    call correct_T_plus	    ; ���� ������ ������ 1 ��������� � �������, ������� �������������� ��������� ����� (inc)
    btfsc Key2,0
    call correct_T_minus    ; ���� ������ ������ 2 ��������� � �������, ������� �������������� ��������� ����� (dec)
    btfsc Key3,0
    goto save_T		    ; ������� � ������ ����� ����� ���������� NPK, ��� ������������ ���������� ���������� ���������� ���������� � ����� � �������� ����
    btfsc Key4,0	    ; ����� �� ��������� ������� � �������� ���� ��� ���������� ����������
    goto change_HMS
    
    call LCD_one	    ; ��������� ������ ������
    call delay_one_sec		; �������� ���� �� 1���
    goto change_time
    
    ;----------------------------------------
correct_T_plus			; ������� ���� switch ��� ����� ��������� ��������(��������� ��� �����������)
    movlw 0x1			;�������� ��� ������ � ��������� ���������
    call delay				
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto correct_T_plus		    
    movlw 0x1			; ���� NumPressKey = 1, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H2
    
    movlw 0x2			; ���� NumPressKey = 2, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H1

    movlw 0x3			; ���� NumPressKey = 3, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M2
    
    movlw 0x4			; ���� NumPressKey = 4, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M1
    
    movlw 0x5			; ���� NumPressKey = 5, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_S2
    
    movlw 0x6			; ���� NumPressKey = 6, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S1.
    btfsc STATUS, 0x02		; ���� ���, ������� �� �������
    call correct_S1
    
    return
    
    ;----------------------------------------
    
correct_H2			; ������� ��������� ���������� H2.
    incf TIME_HH2,1		; ��������� ���������� �2
    movlw 0x33			; ���� !=3, ��������� ������� � �������
    xorwf TIME_HH2, w		; correct_T_plus � ��������� ��� ��������� �������
    btfss STATUS, 0x02
    goto return_COR_H2
    movlw 	0x30		; ���� ���������� = 3, �� �������� ��, �.�. � ������ 2 ������� �����
    movwf	TIME_HH2
return_COR_H2
    return			; � ���� ������� � correct_T_plus � ��������� ��� ��������� �������
    
correct_H1			; ������� ��������� ���������� H1.
    incf TIME_HH1,1		; ��������� ���������� �1
    movlw 0x32			; ���� = 2, ��������� � ������� three_H1, ������� ������ ��� 
    xorwf TIME_HH2, w		; ���������� ������ �������, �.�. 18 ����� ����� ����, � 28 ���, �� ����
	    			; ���������� ������� ��� �������� = 2	
    btfsc STATUS, 0x02
    goto three_H1			
    movlw 0x3a			; ���� ���������� = 0 ��� = 1, �� ������������ ������� ��� ��������� - 9.
t1  xorwf TIME_HH1, w	
    btfss STATUS, 0x02
    goto return_COR_H1
    movlw 	0x30		; ���������� ��������� ���������� ��� ���������� 10 ��� 4 �� ������� ����. 
    movwf	TIME_HH1
return_COR_H1
    return
    
three_H1
    movlw 0x34			; ������ ��� ��������� ��� ���������� = 2
    goto t1			; ������� � ����� t1 ��� ����������� ���������� ������
    
correct_M2			; ������� ��������� ���������� M2.
    incf TIME_MM2,1
    movlw 0x36			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 6
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2
    movlw 	0x30
    movwf	TIME_MM2
return_COR_M2
    return
    
correct_M1			; ������� ��������� ���������� M1.
    incf TIME_MM1,1
    movlw 0x3a			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1
    movlw 	0x30
    movwf	TIME_MM1
return_COR_M1
    return
    
correct_S2			; ������� ��������� ���������� S2.
    incf TIME_SS2,1
    movlw 0x36			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 6
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto return_COR_S2
    movlw 	0x30
    movwf	TIME_SS2
return_COR_S2
    return
    
correct_S1			; ������� ��������� ���������� S1.
    incf TIME_SS1,1
    movlw 0x3a			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    goto return_COR_S1
    movlw 	0x30
    movwf	TIME_SS1
return_COR_S1
    return
    
    ;----------------------------------------
    
correct_T_minus			; ������� ���� switch ��� ����� ��������� ��������(���������)
    movlw 0x1			;�������� ��� ������ � ��������� ���������	
    call delay				
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto correct_T_minus		  
    movlw 0x1			; ���� NumPressKey = 1, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H2_minus
    
    movlw 0x2			; ���� NumPressKey = 2, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H1_minus

    movlw 0x3			; ���� NumPressKey = 3, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M2_minus
    
    movlw 0x4			; ���� NumPressKey = 4, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M1_minus
    
    movlw 0x5			; ���� NumPressKey = 5, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_S2_minus
    
    movlw 0x6			; ���� NumPressKey = 6, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S1.
    btfsc STATUS, 0x02		; ���� ���, ������� �� �������
    call correct_S1_minus
    
    return
    ;----------------------------------------
    
correct_H2_minus		; ������� ��������� ���������� H2.
    decf TIME_HH2,1		; ��������� ���������� �2
    movlw 0x2f			; ���� !=2f, ��������� ������� � �������
    xorwf TIME_HH2, w		; correct_T_ � ��������� ��� ��������� �������
    btfss STATUS, 0x02
    goto return_COR_H2_MIN
    movlw 	0x32		; ���� ���������� = 2f, �� ����������� �� �������� 2, �.�. � ������ 2 ������� �����
    movwf	TIME_HH2
return_COR_H2_MIN
    return			; � ���� ������� � correct_T_ � ��������� ��� ��������� �������
    
correct_H1_minus		; ������� ��������� ���������� H1.
    decf TIME_HH1,1		; ��������� ���������� �1
    movlw 0x2f			; ���� != 2f, ��������� ������� � ������� 
    xorwf TIME_HH1, w		; correct_T_ � ��������� ��� ��������� �������
	    				
    btfss STATUS, 0x02
    goto return_COR_H1_MIN		
    movlw 0x32			; ���� ���������� = 2, �� ��� ���������� 2f ����� ����������� �1 = 3.
    xorwf TIME_HH2, w	
    btfsc STATUS, 0x02
    goto three_H1_minus
    movlw 	0x39		; ���� ���������� != 2, �� ��� ���������� 2f ����� ����������� �1 = 9. 
t2  movwf	TIME_HH1
return_COR_H1_MIN
    return
    
three_H1_minus
    movlw 0x33			; �������� ��� ������������ ��� �2 = 2.
    goto t2			; ������� � ����� t2 ��� ����������� ���������� ������
    
correct_M2_minus		; ������� ��������� ���������� M2.
    decf TIME_MM2,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 5
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_MIN
    movlw 	0x35
    movwf	TIME_MM2
return_COR_M2_MIN
    return
    
correct_M1_minus		; ������� ��������� ���������� M1.
    decf TIME_MM1,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_MIN
    movlw 	0x39
    movwf	TIME_MM1
return_COR_M1_MIN
    return
    
correct_S2_minus		; ������� ��������� ���������� S2.
    decf TIME_SS2,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 5
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto return_COR_S2_MIN
    movlw 	0x35
    movwf	TIME_SS2
return_COR_S2_MIN
    return
    
correct_S1_minus		; ������� ��������� ���������� S1.
    decf TIME_SS1,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    goto return_COR_S1_MIN
    movlw 	0x39
    movwf	TIME_SS1
return_COR_S1_MIN
    return
    
    ;==============================================
    
save_T				; ������� �������� � ���������� �������
    movlw 0x1			;�������� ��� ������ � ��������� ���������
    call delay			
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto save_T
    movlw 0x6			; ���� ���������� ������������ NumPressKey
    xorwf NumPressKey, w	; ������ ����� ������� ��������� �� ���� �������
    btfsc STATUS, 0x02		; � �� ��������� � ������� ������ ���������� ��������
    goto START			; � ����������
    incf NumPressKey,1		; ���� NumPressKey �� ����������, �� ��������������
    goto change_time		; ��� � ������������ � ������� ��������� �������
    
change_HMS
    movlw 0x1				
    call delay			;�������� ��� ������ � ��������� ���������
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto change_HMS
    movfw TEMP_TIME_HH2		; ���������� �������� ��������� ���������� � ���������� (NPK 
    movwf TIME_HH2		; ��������� ��� ����������� ������, � ������� ����������
    movfw TEMP_TIME_HH1		; ��������)
    movwf TIME_HH1
    movfw TEMP_TIME_MM2		
    movwf TIME_MM2
    movfw TEMP_TIME_MM1		
    movwf TIME_MM1
    movfw TEMP_TIME_SS2		
    movwf TIME_SS2
    movfw TEMP_TIME_SS1		
    movwf TIME_SS1
    goto START			; ������� � �������� ����
    
    ;==============================================
    ;==============================================
    
change_day			; ������� ��������� ��� ������
    call Keyboard
    btfsc Key1,0
    goto plus_day_ch		; ���� ������ ������ 1 ��������� � �������, ������� �������������� ��������� ����� (inc)
    btfsc Key2,0
    goto minus_day_ch		; ���� ������ ������ 2 ��������� � �������, ������� �������������� ��������� ����� (dec)
    btfsc Key3,0		; ���� ������ ������ 3 ��������� � �������, ������� ��������� ���������
    goto save_end_day
    btfsc Key4,0		; ���� ������ ������ 4 ��������� � �������, ������� �������� ��� ���������
    goto save_day_ch
    
    call LCD_one		; ��������� ������ ������ �� �������
    call delay_one_sec		; �������� ���� �� 1���
    goto change_day
    
plus_day_ch
    movlw 0x1				
    call delay			;�������� ��� ������ � ��������� ���������
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto plus_day_ch
    incf DAY,1			;��������� �������� ����
    movlw .7			;���� ���� ����� 7, �� ��������
    xorwf DAY, w;		;����� ���� ������������ � ������� ��������� ���
    btfss STATUS, 0x02		;���� �� ����� 7, �� ������ ������������ � �������
    goto change_day			
    movlw .0
    movwf DAY
    goto change_day
    
minus_day_ch
    movlw 0x1				
    call delay			;�������� ��� ������ � ��������� ���������
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto minus_day_ch
    decf DAY,1
    movlw .255			;��������� �������� ����
    xorwf DAY, w;		;���� ���� ����� 255, �� ����������� �������� 6
    btfss STATUS, 0x02		;����� ���� ������������ � ������� ��������� ���
    goto change_day		;���� �� ����� 255, �� ������ ������������ � �������
    movlw .6
    movwf DAY
    goto change_day
    
save_day_ch
    movlw 0x1				
    call delay			;�������� ��� ������ � ��������� ���������
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto save_day_ch
    movfw TEMP_DAY		;����������� �������� ���������� �������� �����������
    movwf DAY			;��� �� �������� ��������� � ������� � �������� ����
    goto START
    
save_end_day
    movlw 0x1				
    call delay			;�������� ��� ������ � ��������� ���������
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto save_end_day
    goto START			;������������ � �������� ����
    ;==============================================
    ;==============================================
change_alarm			; ������� ��������� ������� ����������
    call Keyboard		; ���������� ����������
    btfsc Key1,0
    call correct_A_plus		; ���� ������ ������ 1 ��������� � �������, ������� �������������� ��������� ����� (inc)
    btfsc Key2,0
    call correct_A_minus	; ���� ������ ������ 2 ��������� � �������, ������� �������������� ��������� ����� (dec)
    btfsc Key3,0
    goto save_A			; ������� � ������ ����� ����� ���������� NPK, ��� ������������ ���������� ���������� ���������� ���������� � ����� � �������� ����
    btfsc Key4,0		; ����� �� ��������� ������� � �������� ���� ��� ���������� ����������
    goto change_AHMS
    
    call LCD_two		; ��������� ������ ������
    
    call delay_one_sec		; �������� ���� �� 1���
    goto change_alarm
    
    ;----------------------------------------
    
correct_A_plus			; ������� ���� switch ��� ����� ��������� ��������(��������� ��� �����������)
    movlw 0x1			;�������� ��� ������ � ��������� ���������	
    call delay			
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto correct_A_plus			    
    movlw 0x9			; ���� NumPressKey = 9, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H2_A
    
    movlw 0xa			; ���� NumPressKey = �, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H1_A

    movlw 0xb			; ���� NumPressKey = b, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M2_A
    
    movlw 0xc			; ���� NumPressKey = c, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M1_A
    
    return
    
    ;----------------------------------------
    
correct_H2_A			; ������� ��������� ���������� H2.
    incf ALARM_HH2,1		; ��������� ���������� �2
    movlw 0x33			; ���� !=3, ��������� ������� � �������
    xorwf ALARM_HH2, w		; correct_A_plus � ��������� ��� ��������� �������
    btfss STATUS, 0x02
    goto return_COR_H2_A
    movlw 	0x30		; ���� ���������� = 3, �� �������� ��, �.�. � ������ 2 ������� �����
    movwf	ALARM_HH2
return_COR_H2_A
    return			; � ���� ������� � correct_A_plus � ��������� ��� ��������� �������
    
correct_H1_A			; ������� ��������� ���������� H1.
    incf ALARM_HH1,1		; ��������� ���������� �1
    movlw 0x32			; ���� = 2, ��������� � ������� three_H1_A, ������� ������ ��� 
    xorwf ALARM_HH2, w		; ���������� ������ �������, �.�. 18 ����� ����� ����, � 28 ���, �� ����
	    			; ���������� ������� ��� �������� = 2	
    btfsc STATUS, 0x02
    goto three_H1_A			
    movlw 0x3a			; ���� ���������� = 0 ��� = 1, �� ������������ ������� ��� ���y����� - 9.
ta1 xorwf ALARM_HH1, w	
    btfss STATUS, 0x02
    goto return_COR_H1_A
    movlw 	0x30		; ���������� ��������� ���������� ��� ���������� 10 ��� 4 �� ������� ����. 
    movwf	ALARM_HH1
return_COR_H1_A
    return
    
three_H1_A
    movlw 0x34			; ������ ��� ��������� ��� ���������� = 2
    goto ta1			; ������� � ����� ta1 ��� ����������� ���������� ������
    
correct_M2_A			; ������� ��������� ���������� M2.
    incf ALARM_MM2,1
    movlw 0x36			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 6
    xorwf ALARM_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_A
    movlw 	0x30
    movwf	ALARM_MM2
return_COR_M2_A
    return
    
correct_M1_A			; ������� ��������� ���������� M1.
    incf ALARM_MM1,1
    movlw 0x3a			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 10
    xorwf ALARM_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_A
    movlw 	0x30
    movwf	ALARM_MM1
return_COR_M1_A
    return
    
    ;----------------------------------------
    
correct_A_minus			; ������� ���� switch ��� ����� ��������� ��������(���������)
    movlw 0x1			;�������� ��� ������ � ��������� ���������
    call delay				
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto correct_A_minus
    movlw 0x9			; ���� NumPressKey = 9, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H2_minus_A
    
    movlw 0xa			; ���� NumPressKey = a, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H1_minus_A

    movlw 0xb			; ���� NumPressKey = b, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M2_minus_A
    
    movlw 0xc			; ���� NumPressKey = c, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M1_minus_A
    
    return
    
    ;----------------------------------------
    
correct_H2_minus_A		; ������� ��������� ���������� H2.
    decf ALARM_HH2,1		; ��������� ���������� �2
    movlw 0x2f			; ���� !=2f, ��������� ������� � �������
    xorwf ALARM_HH2, w		; correct_�_minus � ��������� ��� ��������� �������
    btfss STATUS, 0x02
    goto return_COR_H2_A_minus
    movlw 	0x32		; ���� ���������� = 2f, �� ����������� �� �������� 2, �.�. � ������ 2 ������� �����
    movwf	ALARM_HH2
return_COR_H2_A_minus
    return			; � ���� ������� � correct_�_minus � ��������� ��� ��������� �������
    
correct_H1_minus_A		; ������� ��������� ���������� H1.
    decf ALARM_HH1,1		; ��������� ���������� �1
    movlw 0x2f			; ���� != 2f, ��������� ������� � ������� 
    xorwf ALARM_HH1, w		; correct_�_minus � ��������� ��� ��������� �������
	    				
    btfss STATUS, 0x02
    goto return_COR_H1_A_minus		
    movlw 0x32			; ���� ���������� = 2, �� ��� ���������� 2f ����� ����������� �1 = 3.
    xorwf ALARM_HH2, w	
    btfsc STATUS, 0x02
    goto three_H1_minus_A
    movlw 	0x39		; ���� ���������� != 2, �� ��� ���������� 2f ����� ����������� �1 = 9. 
ta2 movwf	ALARM_HH1
return_COR_H1_A_minus
    return
    
three_H1_minus_A
    movlw 0x33			; �������� ��� ������������ ��� �2 = 2.
    goto ta2			; ������� � ����� t�2 ��� ����������� ���������� ������
    
correct_M2_minus_A		; ������� ��������� ���������� M2.
    decf ALARM_MM2,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 5
    xorwf ALARM_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_A_minus
    movlw 	0x35
    movwf	ALARM_MM2
return_COR_M2_A_minus
    return
    
correct_M1_minus_A		; ������� ��������� ���������� M1.
    decf ALARM_MM1,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 10
    xorwf ALARM_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_A_minus
    movlw 	0x39
    movwf	ALARM_MM1
return_COR_M1_A_minus
    return
    
    ;==============================================
    
save_A				; ������� �������� � ���������� �������
    movlw 0x1			;�������� ��� ������ � ��������� ���������	
    call delay				
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto save_A
    movlw 0xd			; ���� ���������� ������������ NumPressKey
    xorwf NumPressKey, w	; ������ ����� ������� ��������� �� ���� �������
    btfsc STATUS, 0x02		; � �� ������� �� ���� ���������
    goto START			
    incf NumPressKey,1		; ���� NumPressKey �� ����������, �� ��������������
    goto change_alarm		; ��� � ������������ � ������� ��������� �������
    
change_AHMS
    movlw 0x1				
    call delay			;�������� ��� ������ � ��������� ���������
    call Keyboard		;����� ���������� ��� �� ��������
    movf Cnt,1			;������ ������� ��� ���
    btfss STATUS,Z		;���� ���, �� ������
    goto change_AHMS
    movfw TEMP_ALARM_HH2	; ���������� �������� ��������� ���������� � ���������� (NPK 
    movwf ALARM_HH2		; ��������� ��� ����������� ������, � ������� ����������
    movfw TEMP_ALARM_HH1	; ��������)
    movwf ALARM_HH1
    movfw TEMP_ALARM_MM2		
    movwf ALARM_MM2
    movfw TEMP_ALARM_MM1		
    movwf ALARM_MM1
    goto START			; ������� � �������� ����
    
    ;==============================================
    ;==============================================
			    
;small_delay:			; �������� ��� ��������
;    movwf fCOUNTER1
;    clrwdt
;    decfsz fCOUNTER1,F
;    goto $-2
;    return
    
end  ; ����� ���������