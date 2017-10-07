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
WAIT	    equ	    0x20
fCOUNTER    equ     0x26
fCOUNTER2   equ     0x27
TIME_HH1    equ	    0x30
TIME_HH2    equ	    0x31
TIME_MM1    equ	    0x32
TIME_MM2    equ	    0x33
TIME_SS1    equ	    0x34
TIME_SS2    equ	    0x35
DAY    	    equ	    0x36
ALARM_HH1   equ	    0x37
ALARM_HH2   equ	    0x38
ALARM_MM1   equ	    0x39
ALARM_MM2   equ	    0x40
BUT1	    equ	    0x41
BUT2	    equ	    0x42
BUT3	    equ	    0x43
BUT4	    equ	    0x44
BUT5	    equ	    0x45
BUT6	    equ	    0x46
BUT7	    equ	    0x47
BUT8	    equ	    0x48
BUT9	    equ	    0x49
NumPressKey equ	    0x50 
Control     equ	    0x51 
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
	;����������������  RD0  ���  �����
	;���  ���������  ��  ���  �1�  �  ��������
	;���������  ���������  ����������  �1-Wire�
    clrf ADCON1 
    bsf ADCON1,0x01 
    bsf ADCON1,0x02 
    bank0
    clrf BUT1	 
    clrf BUT2	    
    clrf BUT3	    
    clrf BUT4	    
    clrf BUT5	   
    clrf BUT6	    
    clrf BUT7	   
    clrf BUT8	   
    clrf BUT9	    
    clrf PORTC
    clrf Control 
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
 	movlw 	0x33
	movwf	TIME_HH1
	movlw 	0x32
	movwf	TIME_HH2
	movlw 	0x39
	movwf	TIME_MM1
	movlw 	0x35
	movwf	TIME_MM2
	movlw 	0x30
	movwf	TIME_SS1
	movwf	TIME_SS2
	movwf	ALARM_HH1
	movwf	ALARM_HH2
	movwf	ALARM_MM1
	movwf	ALARM_MM2
	movlw 	.0
	movwf	DAY

START
	bcf PORTC, 0
	movlw b'10000000'
	call write
	bsf PORTC,0

	;��������� ������ ������
	movfw TIME_HH2
	call write
	movfw TIME_HH1
	call write
	movlw ':'
	call write
	movfw TIME_MM2
	call write
	movfw TIME_MM1
	call write
	movlw ':'
	call write
	movfw TIME_SS2
	call write
	movfw TIME_SS1
	call write

	movlw ' '
	call write
	movlw ' '
	call write
	movfw	DAY				
	call	DEC				

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
	btfss STATUS, 0x02		; ��������� ���������� ��� ���������� �����������, 
	goto end_clock			; ��� �� ��� 00:00:00 ������� � �����������
	movlw 	.0
	movwf	DAY
	
	
	ten_clock
	movlw 0x3A 			; if !=10
	xorwf TIME_HH1, w;
	btfss STATUS, 0x02
	goto end_clock
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
    goto START

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

;==============================================
DEC		addwf	PCL
		goto monday
		goto tuesday
		goto wednesday	
		goto thursday    
		goto friday		
		goto saturday		
		goto sunday		
		return
		
;��������� ���� ������
monday		;�����������
    movlw 'M'
    call write
    movlw 'O'
    call write
    movlw 'N'
    call write
    goto exday
tuesday		;�������
    movlw 'T'
    call write
    movlw 'U'
    call write
    movlw 'E'
    call write
    goto exday
wednesday	;�����
    movlw 'W'
    call write
    movlw 'E'
    call write
    movlw 'D'
    call write
    goto exday
thursday	;�������
    movlw 'T'
    call write
    movlw 'H'
    call write
    movlw 'U'
    call write
    goto exday
friday		;�������
    movlw 'F'
    call write
    movlw 'R'
    call write
    movlw 'I'
    call write
    goto exday
saturday	;�������
    movlw 'S'
    call write
    movlw 'A'
    call write
    movlw 'T'
    call write
    goto exday
sunday		;�����������
    movlw 'S'
    call write
    movlw 'U'
    call write
    movlw 'N'
    call write
    exday
return
goto START
end  ; ����� ���������