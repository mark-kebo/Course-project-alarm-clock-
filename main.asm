;*******************************************************************************
;                                                                              *
;    Filename:  ALARM CLOCK                                                    *
;    Date:      19.10.17                                                       *
;    File Version:   1.4.2                                                     *
;    Author:         Dmitry Vorozhbicky                                        *
;    Company:        GrSU                                                      *
;                                                                              *
;*******************************************************************************  
;processor    PIC16F877
include  <P16F877.INC>
errorlevel   -302
	;  ���������  ����  �����������,  ���-
	;��������  �������������  �����  �  ��-
	;���� ��������� �� �������
#define   bank0  bcf STATUS,  RP0
#define   bank1  bsf STATUS,  RP0
; ���������, ����������� �������� �
	;����  ��  �������,  ���������  �����
	;����  ���������  (bcf  ,  bsf)  �  �������
	;bank0, bank1. �������� ������ �����-
	;����� ����������
WAIT		    equ	    0x20
fCOUNTER	    equ     0x26
fCOUNTER2	    equ     0x27
TIME_HH1	    equ	    0x30
TIME_HH2	    equ	    0x31
TIME_MM1	    equ	    0x32
TIME_MM2	    equ	    0x33
TIME_SS1	    equ	    0x34
TIME_SS2	    equ	    0x35
DAY		    equ	    0x36
ALARM_HH1	    equ	    0x37
ALARM_HH2	    equ	    0x38
ALARM_MM1	    equ	    0x39
ALARM_MM2	    equ	    0x3A
Key1		    equ	    0x3B
Key2		    equ	    0x3C
Key3		    equ	    0x3D
Key4		    equ	    0x3E
Key5		    equ	    0x3F
Key6		    equ	    0x40
Key7		    equ	    0x41
Key8		    equ	    0x42
Key9		    equ	    0x43
fCOUNTER1	    equ     0x44
TEMP_TIME_HH1	    equ	    0x45
TEMP_TIME_HH2	    equ	    0x46
TEMP_TIME_MM1	    equ	    0x47
TEMP_TIME_MM2	    equ	    0x48
TEMP_TIME_SS1	    equ	    0x49
TEMP_TIME_SS2	    equ	    0x4A
TEMP_DAY	    equ	    0x4B
TEMP_ALARM_HH1	    equ	    0x4C
TEMP_ALARM_HH2	    equ	    0x4D
TEMP_ALARM_MM1	    equ	    0x4E
TEMP_ALARM_MM2	    equ	    0x4F
NumPressKey	    equ	    0x50
Blink		    equ	    0x51
    ;���������������  ��������,  �������-
	;��� ������� ��������� � ������������
    constant   DS = .2
    constant   RST = .2
	;  ���������,  �������� �  ������������
	;������ DS  �  RST  ��������  0.  �����-
	;��� �������� equ ��� ���� ���������.

wait  macro     time
    movlw    (time/5)-1
    movwf    WAIT
    call    wait5u
    endm
	;������ ����� � ������ wait. ������-
	;����� ����� ������� ������� � ���, ���
	;�  ����  �������  ��������  �  time.  ���
	;������  �������  ��������  ���������
	;�����������  �����  �����  �������  �
	;����  ������  �����������  �����  ����-
	;����  5  (�  ������  �������).  �  ����
	;�������  ���  �����  �������������  �
	;������������ time � ����� ��������-
	;���� ����������� �������� (������� �
	;������ ������  ���������  �  ����  ���-
	;������, ������������ � W). ������ �
	;����������  wait5u  ������������  ��-
	;������,  ��������������  ��������
	;����� time �����������

    org 0x0000
    clrf STATUS
    movlw 0x00
    movwf PCLATH
    goto begin
	;����� ������� �������� ������ ��-
	;���� � ���������� �� ��� ���������-
	;��������� ����

begin
    bank1  ; ����� ������� ����� ������. ��� ��-
	;���� ������������ ����� bank1, �����-
	;������ ���� ���������� #define
    movlw 0x8F
    movwf OPTION_REG
    clrwdt
	;���������  �������������  �������
	;������������  �����������  �������  �
	;��� �����
    clrf INTCON
    clrf PIE1
    clrf PIE2
	;����������  ����������  �  ��  ���������
    movlw .0
    movwf TRISB
    movwf TRISC
    movwf TRISE
	; ����������������  ������  �, �, �
    movlw b'11111000' 
    movwf TRISA 
    movlw b'00000000'
    movwf TRISD
    movlw b'00001111'
    movwf OPTION_REG
	;����������������  RD0  ���  �����
	;���  ���������  ��  ���  �1�  �  ��������
	;���������  ���������  ����������  �1-Wire�
    clrf ADCON1 
    bsf ADCON1,0x01 
    bsf ADCON1,0x02 
    bank0
    clrf Key1	 
    clrf Key2	    
    clrf Key3	    
    clrf Key4	    	   
    clrf Key9	    	    
    clrf PORTC
    clrf PORTD
; ���������� � �������� ������ �� ����������
;HD ����� ��������� RC0=0
    movlw 0x01
    call write
    movlw 0x0f
    call delay
; �������� ������� Clear  Display ��� �������
;������� � ��������� �������� ������ �������-
;����  ��  �������  �����  (������  ����������  �
;������� ������), � ����������� ���������
    clrwdt
    movlw 0x38
    call write
    movlw 0x0f
    call delay

; �������� ������� Function Set ��� ���������
;������  2-�  ���������  ����������,  �������
;���������� 5�7 � 8 ��������� ���� ������
    movlw 0x06
    call write
    movlw 0x0f
    call delay
;��������  �������  Entry  Mode  Set  ���  ����-
;����� ������ ���������� �������� ������ ��-
;���������, ����� ������ ������ ������� � ���,
;��� ������������� ����������� ������������
;����������
    movlw 0x0c
    call write
    movlw 0x0f
    call delay
;  ��������  �������  Display  ON/OFF  control
;��� ��������� ������� � ����������� �����-
;���.  ��  ����  ���� ������������� ������� ��-
;������.
    movlw 	0x30
    movwf	TIME_HH1
    movwf	TIME_HH2
    movwf	TIME_MM1
    movwf	TIME_MM2
    movwf	TIME_SS1
    movwf	TIME_SS2
    movwf	ALARM_HH1
    movwf	ALARM_HH2
    movwf	ALARM_MM1
    movwf	ALARM_MM2
    movlw 	.0
    movwf	DAY
    movlw 	b'00000000'
    movwf	Blink

START
    movfw TIME_HH2		; ���������� �������� ���������x ���������� �  ��������e 
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
    movwf NumPressKey		; NPK ������ ��� ������������� � ��������� ��������
    
    call Keyboard		; ������ ����������
    btfsc Key1,0		; �������� ������� ������� "1",  ���� ������, �� ��������� 
    goto change_time		; � ��������� �������, ��� - ����� ��������� ������� 2
    btfsc Key2,0		; �������� ������� ������� "2",  ���� ������, �� ��������� 
    goto change_day		; � ��������� ��� ������, ��� - ����� ��������� ������� 3
	
    call LCD_one		;��������� ������ ������		

	;���� �������� ������ (0-6) - TIME_SS1
    incf TIME_SS1,1
    movlw 0x3A			; if !=10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    goto end_clock
	;��������� TIME_MM1
    movlw 0x30
    movwf	TIME_SS1

	;���� �������� ������ (0-6) - TIME_SS2
    incf TIME_SS2,1
    movlw 0x36			; if !=6
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto end_clock
	;��������� TIME_MM2
    movlw 0x30
    movwf	TIME_SS2
	
	;���� �������� ����� (0-6) - TIME_MM1
    incf TIME_MM1,1
    movlw 0x3A			; if !=10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto end_clock
	;��������� TIME_MM1
    movlw 0x30
    movwf	TIME_MM1

	;���� �������� ����� (0-6) - TIME_MM2
    incf TIME_MM2,1
    movlw 0x36			; if !=6
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto end_clock
	;��������� TIME_MM2
    movlw 0x30
    movwf	TIME_MM2

	;���� �������� ������ ����� - TIME_��2, TIME_��1
    incf TIME_HH1,1
    movlw 0x34 			; if !=4
    xorwf TIME_HH1, w;
    btfss STATUS, 0x02
    goto ten_clock
    movlw 0x32			; if !=2
    xorwf TIME_HH2, w;
    btfss STATUS, 0x02
    goto ten_clock
    movlw 0x30
    movwf	TIME_HH1
    movwf	TIME_HH2
    incf    DAY,1
    movlw 	.7			; inc ���������� ����
    xorwf DAY, w;
    btfss STATUS, 0x02			; ��������� ���������� ��� ���������� �����������, 
    goto end_clock			; ��� �� ��� 00:00:00 ������� � �����������
    movlw 	.0
    movwf	DAY

	
ten_clock
    movlw 0x3A 			; if !=10 
    xorwf TIME_HH1, w;		; ������������ ��� ������ � �������� 24 ����
    btfss STATUS, 0x02		; �.�. 18 ����� ����� ����, � 28 ���, �� ����
    goto end_clock		; ���������� ������� ��� �������� = 2
    incf    TIME_HH2
    movlw 0x30
    movwf	TIME_HH1
	
end_clock
    clrwdt

    movlw 0xff
    call delay ;�������� ���
    movlw 0xff
    call delay ;�������� ���
    movlw 0xff
    call delay ;�������� ���

    call LCD_two		;��������� ������ ������
    
    ; ��� ��������� ���������� �����
    
    goto START		; ����� ��������� ����� (������ ���� = 1���)

    ;--------------------------------------------------------
    ;--------------------------------------------------------
    ;--------------------------------------------------------
    
write    ; ��������� ������ ����� � ���������� HD
    bcf STATUS, RP1
    bcf STATUS, RP0
    movwf PORTB
    bsf PORTC, 2
    movlw 0x01
    call delay
    bcf PORTC, 2
    return
    
    	; ����� ������� ���� ��������� � W ������-
	;���� ����, ������� ���� �������� � HD. �����
	;�� ���������� � PORTB � ����������� ������-
	;������� ������� �� RC2, ����� ������������-
	;���  ���  ���������  �  �1�,  ���������  �����
	;������ � ������� ���������� ������� (������-
	;������� �������� �������� delay  ���  W=1) �
	;������ ��� � �0�.

	;  ���������  ��������,  �����  �������  �����
	;������������, ������� ����� � W
delay
    bcf   STATUS, RP1
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

    ;==========================================
    
LCD_one
    bcf PORTC, 0
    movlw b'10000000'	; ��������� ������
    call write
    bsf PORTC,0
    ;��������� ������ ������
    ; ��������� �2
    movlw 0x0			; ���� NumPressKey = 0, �� ��������
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_H2
    incf Blink,1
    btfss Blink, 0
    goto blink_on_H2
    goto blink_off_H2
blink_off_H2
    movlw ' '
    call write
    goto l1
blink_on_H2
    movfw TIME_HH2
    call write
    goto l1
    ; ��������� �1
l1  movlw 0x1			; ���� NumPressKey = 0, �� ��������
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_H1
    incf Blink,1
    btfss Blink, 0
    goto blink_on_H1
    goto blink_off_H1
blink_off_H1
    movlw ' '
    call write
    goto l2
blink_on_H1
    movfw TIME_HH1
    call write
    goto l2
    
l2  movlw ':'
    call write
    
    ; ��������� �2
    movlw 0x2			; ���� NumPressKey = 0, �� ��������
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_M2
    incf Blink,1
    btfss Blink, 0
    goto blink_on_M2
    goto blink_off_M2
blink_off_M2
    movlw ' '
    call write
    goto l3
blink_on_M2
    movfw TIME_MM2
    call write
    goto l3
    
    ; ��������� �1
l3  movfw TIME_MM1
    call write
    
    movlw ':'
    call write
    
    ; ��������� S2
    movfw TIME_SS2
    call write
    
    ; ��������� S1
    movfw TIME_SS1
    call write

    movlw ' '
    call write
    movlw ' '
    call write
    movfw	DAY				
    call	DEC
    return
    
    ;==========================================   
    
LCD_two
    bcf PORTC, 0
    movlw b'11000100'
    call write
; ��������� RC0=0, ��� ����������� ��������
;�������  ��  ����������  HD.  ����������  ��-
;����� Set DDRAM address,  ���������������
;�������  ������  �����������  ��  ������  2-��
;������:  ������  �  �������  (0�40  =  0100  0000).
;���  ����������  ���  ������  �����  �TEM-
;PERATURA =� �� ������ ������ ����������.

    bsf PORTC,0  ; ��������� RC0=1, ��� ����������� ��������
;����� �������� ������ ������ �� �������. ��-
;������ �������� �� ��, ��� ����� �� ���������
;���������  ������  ������: �.�. ��� ��������, �
;�������� �������� ��, ��������� � 0-�� ���-
;��.
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
    movlw ' '
    call write
    movlw ' '
    call write
    movfw ALARM_HH2
    call write
    movfw ALARM_HH1
    call write
    movlw ':'
    call write
    movfw ALARM_MM2
    call write
    movfw ALARM_MM1
    call write
    return
 
     ;==========================================
     
     ; ��������� ���� switch ��� ������ ��� ������
DEC addwf PCL
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
    ;==========================================
    
Keyboard		    ; ������� ���������� ��� ������ 1-4, 9
    bcf STATUS, RP0	    ; ������� � ������� ����, ��� ����������� ������ ������� �� ���� ���������
    bcf STATUS, RP1
    clrf Key1		    ; ��������� ����� ������
    clrf Key2 
    clrf Key3
    clrf Key4  
    clrf Key9  
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
    col2		    ; ��������� ������ �������, ��� ��� ����� ������� 2
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
col3		    ; ��������� ������ �������, ��� ��� ����� ������� 3
    bcf PORTA,0		    ; ������ �������
    bcf PORTA,1
    bsf PORTA,2
    ;movlw .24
    ;sd
    movf PORTA,W	    ; ������ ���� � � W � ��������� ����������� ��������� ����� ����� �� ����� 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; ���� Z=1 (�.�. �� ������ �� ���� �� ������) ������� �� �������
    return		    ; ���� Z=0, �� ���������� ������
    ;movlw .250
    ;sd
    btfsc PORTA,3	    ; ���������� ������� ������� "3", ������� ����� ������ ������
    incf Key3,F
    btfsc PORTA,5	    ; ���������� ������� ������� "9", ������� ����� ������ ������
    incf Key9,F
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
    
    call LCD_one
    goto change_time
    
    ;----------------------------------------
    
correct_T_plus			; ������� ���� switch ��� ����� ��������� ��������(��������� ��� �����������)
    movlw 0xff
    call delay		    ; �������� ���
    movlw 0xff
    call delay		    ; �������� ���			    
    movlw 0x0			; ���� NumPressKey = 0, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H2
    
    movlw 0x1			; ���� NumPressKey = 1, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H1

    movlw 0x2			; ���� NumPressKey = 2, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M2
    
    movlw 0x3			; ���� NumPressKey = 3, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M1
    
    movlw 0x4			; ���� NumPressKey = 4, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_S2
    
    movlw 0x5			; ���� NumPressKey = 5, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S1.
    btfsc STATUS, 0x02		; ���� ���, ������� �� �������
    call correct_S1
    
    return
    
    ;----------------------------------------
    
correct_H2			; ������� ��������� ���������� H2.
    incf TIME_HH2,1	; ��������� ��������� ���������� ��� �2
    movlw 0x33			; if !=3, ��������� ������� � �������
    xorwf TIME_HH2, w	; correct_T_plus � ��������� ��� ��������� �������
    btfss STATUS, 0x02
    return
    movlw 	0x30		; ���� ���������� = 3, �� �������� ��, �.�. � ������ 2 ������� �����
    movwf	TIME_HH2
    return			; � ���� ������� � correct_T_plus � ��������� ��� ��������� �������
    
correct_H1			; ������� ��������� ���������� H1.
    incf TIME_HH1,1	; ��������� ��������� ���������� ��� �1
    movlw 0x32			; if = 2, ��������� � ������� three_H1, ������� ������ ��� 
    xorwf TIME_HH2, w	; ���������� ������ �������, �.�. 18 ����� ����� ����, � 28 ���, �� ����
	    			; ���������� ������� ��� �������� = 2	
    btfsc STATUS, 0x02
    goto three_H1			
    movlw 0x3a			; ���� ���������� = 0 ��� = 1, �� ������������ ������� ��� ��������� - 9.
t1  xorwf TIME_HH1, w	
    btfss STATUS, 0x02
    return
    movlw 	0x30		; ���������� ��������� ���������� ��� ���������� 10 ��� 4 �� ������� ����. 
    movwf	TIME_HH1
    return
    
three_H1
    movlw 0x34			; ������ ��� ��������� ��� ���������� = 2
    goto t1			; ������� � ����� t1 ��� ����������� ���������� ������
    
correct_M2			; ������� ��������� ���������� M2.
    incf TIME_MM2,1
    movlw 0x36			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 6
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    return
    movlw 	0x30
    movwf	TIME_MM2
    return
    
correct_M1			; ������� ��������� ���������� M1.
    incf TIME_MM1,1
    movlw 0x3a			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    return
    movlw 	0x30
    movwf	TIME_MM1
    return
    
correct_S2			; ������� ��������� ���������� S2.
    incf TIME_SS2,1
    movlw 0x36			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 6
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    return
    movlw 	0x30
    movwf	TIME_SS2
    return
    
correct_S1			; ������� ��������� ���������� S1.
    incf TIME_SS1,1
    movlw 0x3a			; �������� ��� ��, ������ ��������� ���������� ��� ���������� 10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    return
    movlw 	0x30
    movwf	TIME_SS1
    return
    
    ;----------------------------------------
    
correct_T_minus			; ������� ���� switch ��� ����� ��������� ��������(���������)
    movlw 0xff
    call delay		    ; �������� ���
    movlw 0xff
    call delay		    ; �������� ���
    movlw 0x0			; ���� NumPressKey = 0, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H2_minus
    
    movlw 0x1			; ���� NumPressKey = 1, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� �1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_H1_minus

    movlw 0x2			; ���� NumPressKey = 2, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M2_minus
    
    movlw 0x3			; ���� NumPressKey = 3, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� M1.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_M1_minus
    
    movlw 0x4			; ���� NumPressKey = 4, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S2.
    btfsc STATUS, 0x02		; ���� ���, ��������� ��������� �������
    call correct_S2_minus
    
    movlw 0x5			; ���� NumPressKey = 5, �� ��������
    xorwf NumPressKey, w;	; ������� ��������� ���������� S1.
    btfsc STATUS, 0x02		; ���� ���, ������� �� �������
    call correct_S1_minus
    
    return
    
    ;----------------------------------------
    
correct_H2_minus		; ������� ��������� ���������� H2.
    decf TIME_HH2,1	; ��������� ��������� ���������� ��� �2
    movlw 0x2f			; if !=2f, ��������� ������� � �������
    xorwf TIME_HH2, w	; correct_T_ � ��������� ��� ��������� �������
    btfss STATUS, 0x02
    return
    movlw 	0x32		; ���� ���������� = 2f, �� ����������� �� �������� 2, �.�. � ������ 2 ������� �����
    movwf	TIME_HH2
    return			; � ���� ������� � correct_T_ � ��������� ��� ��������� �������
    
correct_H1_minus		; ������� ��������� ���������� H1.
    decf TIME_HH1,1	; ��������� ��������� ���������� ��� �1
    movlw 0x2f			; if != 2f, ��������� ������� � ������� 
    xorwf TIME_HH1, w	; correct_T_ � ��������� ��� ��������� �������
	    				
    btfss STATUS, 0x02
    return		
    movlw 0x32			; ���� ���������� = 2, �� ��� ���������� 2f ����� ����������� �1 = 3.
    xorwf TIME_HH2, w	
    btfsc STATUS, 0x02
    goto three_H1_minus
    movlw 	0x39		; ���� ���������� != 2, �� ��� ���������� 2f ����� ����������� �1 = 9. 
t2  movwf	TIME_HH1
    return
    
three_H1_minus
    movlw 0x33			; �������� ��� ������������ ��� �2 = 2.
    goto t2			; ������� � ����� t2 ��� ����������� ���������� ������
    
correct_M2_minus			; ������� ��������� ���������� M2.
    decf TIME_MM2,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 5
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    return
    movlw 	0x35
    movwf	TIME_MM2
    return
    
correct_M1_minus			; ������� ��������� ���������� M1.
    decf TIME_MM1,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    return
    movlw 	0x39
    movwf	TIME_MM1
    return
    
correct_S2_minus			; ������� ��������� ���������� S2.
    decf TIME_SS2,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 5
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    return
    movlw 	0x35
    movwf	TIME_SS2
    return
    
correct_S1_minus			; ������� ��������� ���������� S1.
    decf TIME_SS1,1
    movlw 0x2f			; �������� ��� ��, ������ ��� ���������� 2f ������������� 10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    return
    movlw 	0x39
    movwf	TIME_SS1
    return
    
    ;==============================================
    
save_T				; ������� �������� � ���������� �������
    movlw 0xff
    call delay			; �������� ���
    movlw 0xff
    call delay			; �������� ���
    movlw 0x6			; ���� ���������� ������������ NumPressKey
    xorwf NumPressKey, w	; ������ ����� ������� ��������� �� ���� �������
    btfsc STATUS, 0x02		; � �� ��������� � ������� ������ ���������� ��������
    goto START			; � ����������
    incf NumPressKey,1		; ���� NumPressKey �� ����������, �� ��������������
    goto change_time		; ��� � ������������ � ������� ��������� �������
    
change_HMS
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
    ;==============================================
    
    change_day		    ; ������� ��������� ��� ������
    call Keyboard
    btfsc Key1,0
    goto plus_day_ch	    ; ���� ������ ������ 1 ��������� � �������, ������� �������������� ��������� ����� (inc)
    btfsc Key2,0
    goto minus_day_ch	    ; ���� ������ ������ 2 ��������� � �������, ������� �������������� ��������� ����� (dec)
    btfsc Key4,0	    ; ����� �� ��������� ������� � �������� ���� ��� ���������� ����������
    goto START
    
    bcf PORTC, 0
    movlw b'10001010'	; ��������� ������
    call write
    bsf PORTC,0

	;��������� ������ ������
    movfw	TEMP_DAY				
    call	DEC
    
    goto change_day
    
plus_day_ch
    movlw 0xff
    call delay		    ; �������� ���
    movlw 0xff
    call delay		    ; �������� ���
    incf    TEMP_DAY,1
    movlw 	.7			; inc ���������� ����
    xorwf TEMP_DAY, w;
    btfss STATUS, 0x02		; is not working 
    goto change_day			; 
    movlw 	.0
    movwf	TEMP_DAY
    goto change_day
    
minus_day_ch
    movlw 0xff
    call delay		    ; �������� ���
    movlw 0xff
    call delay		    ; �������� ���
    incf    TEMP_DAY,1
    movlw 	.0			; inc ���������� ����
    xorwf TEMP_DAY, w;
    btfss STATUS, 0x02		; is not working 
    goto change_day			
    movlw 	.6
    movwf	TEMP_DAY
    goto change_day
    
    ;==============================================
    ;==============================================
    ;==============================================
			    
;small_delay:			; �������� ��� ��������
;    movwf fCOUNTER1
;    clrwdt
;    decfsz fCOUNTER1,F
;    goto $-2
;    return
    
end  ; ����� ���������