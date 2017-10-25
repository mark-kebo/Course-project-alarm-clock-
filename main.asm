;*******************************************************************************
;                                                                              *
;    Filename:  ALARM CLOCK                                                    *
;    Date:      19.10.17                                                       *
;    File Version:   1.6                                                    *
;    Author:         Dmitry Vorozhbicky                                        *
;    Company:        GrSU                                                      *
;                                                                              *
;*******************************************************************************  
;processor    PIC16F877
include  <P16F877.INC>
errorlevel   -302
	;  директивы  типа  контроллера,  под-
	;ключения  заголовочного  файла  и  вы-
	;вода сообщений об ошибках
#define   bank0  bcf STATUS,  RP0
#define   bank1  bsf STATUS,  RP0
; директивы, позволяющие заменять в
	;теле  ПО  команды,  указанные  после
	;этой  директивы  (bcf  ,  bsf)  –  метками
	;bank0, bank1. Обратную замену произ-
	;водит компилятор
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
Key9		    equ	    0x3F
Blink		    equ	    0x40
Cnt		    equ	    0x41
Blink_Alarm	    equ	    0x42
NumPressKey	    equ	    0x43
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
NumAlarmBit	    equ	    0x50
    
wait  macro     time
    movlw    (time/5)-1
    movwf    WAIT
    call    wait5u
    endm
	;макрос паузы с именем wait. Особен-
	;ность этого макроса состоит в том, что
	;у  него  имеется  параметр  –  time.  При
	;вызове  макроса  значение  параметра
	;указывается  после  имени  макроса  в
	;виде  целого  десятичного  числа  крат-
	;ного  5  (в  данном  примере).  В  теле
	;макроса  это  число  подставляется  в
	;«переменную» time и далее использу-
	;ется вычисленное значение (которое в
	;данном случае  выступает  в  роли  кон-
	;станты, записываемой в W). Вместе с
	;процедурой  wait5u  длительность  за-
	;держки,  обеспечиваемая  макросом
	;равна time микросекунд

    org 0x0000
    clrf STATUS
    movlw 0x00
    movwf PCLATH
    goto begin
	;выбор нулевой страницы памяти ко-
	;манд и размещение на ней откомпили-
	;рованного кода

begin
    bank1  ; выбор первого банка памяти. Для вы-
	;зова используется метка bank1, объяв-
	;ленная выше директивой #define
    movlw 0x8F
    movwf OPTION_REG
    clrwdt
	;установка  максимального  времени
	;срабатывания  сторожевого  таймера  и
	;его сброс
    clrf INTCON
    clrf PIE1
    clrf PIE2
	;отключение  прерываний  и  их  обработки
    movlw .0
    movwf TRISB
    movwf TRISC
    movwf TRISE
	; конфигурирование  портов  В, С, Е
    movlw b'11111000' 
    movwf TRISA 
    movlw b'00000000'
    movwf TRISD
    movlw b'00001111'
    movwf OPTION_REG
	;конфигурирование  RD0  как  входа
	;для  установки  на  нем  «1»  в  качестве
	;исходного  состояния  интерфейса  «1-Wire»
    clrf ADCON1 
    bsf ADCON1,0x01 
    bsf ADCON1,0x02 
    bank0
    clrf Key1	 
    clrf Key2	    
    clrf Key3	    
    clrf Key4	    	   
    clrf Key9	    	    
    clrf Cnt	    	    
    clrf PORTC
    clrf PORTD
; подготовка к передаче команд на контроллер
;HD путем установки RC0=0
    movlw 0x01
    call write
    movlw 0x0f
    call delay
; передача команды Clear  Display для очистки
;дисплея и установки счетчика адреса видеопа-
;мяти  на  нулевой  адрес  (первое  знакоместо  в
;верхней строке), с необходимой задержкой
    clrwdt
    movlw 0x38
    call write
    movlw 0x0f
    call delay

; передача команды Function Set для установки
;режима  2-х  строчного  индикатора,  размера
;знакоместа 5х7 и 8 разрядной шины данных
    movlw 0x06
    call write
    movlw 0x0f
    call delay
;передача  команды  Entry  Mode  Set  для  уста-
;новки режима увеличения счетчика адреса ви-
;деопамяти, после каждой записи символа в нее,
;при неподвижности видеопамяти относительно
;индикатора
    movlw 0x0c
    call write
    movlw 0x0f
    call delay
;  передача  команды  Display  ON/OFF  control
;для включения дисплея с отключенным курсо-
;ром.  На  этом  этап инициализации дисплея за-
;кончен.
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
    movwf	Blink_Alarm
    movwf	NumAlarmBit
    movlw 	b'00000000'
    movwf	Blink

START
    movlw .0
    movwf Blink_Alarm
    movfw TIME_HH2		; записываем значения постоянныx переменных в  временныe 
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
    movwf NumPressKey		; NPK каждый раз устанавливаем в начальное значение
    movfw ALARM_HH1
    movwf TEMP_ALARM_HH1
    movfw ALARM_HH2
    movwf TEMP_ALARM_HH2
    movfw ALARM_MM1
    movwf TEMP_ALARM_MM1
    movfw ALARM_MM2
    movwf TEMP_ALARM_MM2
    
    call Keyboard		; читаем клавиатуру
    btfsc Key1,0		; проверка нажатия клавиши "1",  если нажата, то переходим 
    call time_plus_blink	; к изменению времени, нет - тогда проверяем клавишу 2
    btfsc Key2,0		; проверка нажатия клавиши "2",  если нажата, то переходим 
    call day_plus_blink		; к изменению дня недели, нет - тогда проверяем клавишу 3
    btfsc Key3,0		; проверка нажатия клавиши "3",  если нажата, то переходим 
    call alarm_plus_blink		; к изменению будильника, нет - тогда едем дальше
	
    call LCD_one		;Отрисовка первой строки		

	;Счет десятков секунд (0-6) - TIME_SS1
    incf TIME_SS1,1
    movlw 0x3A			; if !=10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    goto end_clock
	;обнуление TIME_MM1
    movlw 0x30
    movwf	TIME_SS1

	;Счет десятков секунд (0-6) - TIME_SS2
    incf TIME_SS2,1
    movlw 0x36			; if !=6
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto end_clock
	;обнуление TIME_MM2
    movlw 0x30
    movwf	TIME_SS2
	
	;Счет десятков минут (0-6) - TIME_MM1
    incf TIME_MM1,1
    movlw 0x3A			; if !=10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto end_clock
	;обнуление TIME_MM1
    movlw 0x30
    movwf	TIME_MM1

	;Счет десятков минут (0-6) - TIME_MM2
    incf TIME_MM2,1
    movlw 0x36			; if !=6
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto end_clock
	;обнуление TIME_MM2
    movlw 0x30
    movwf	TIME_MM2

	;Счет десятков единиц часов - TIME_НН2, TIME_НН1
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
    movlw 	.7			; inc переменной День
    xorwf DAY, w;
    btfss STATUS, 0x02			; Обнуление переменной при достижении воскресенья, 
    goto end_clock			; что бы при 00:00:00 перейти в понедельник
    movlw 	.0
    movwf	DAY

	
ten_clock
    movlw 0x3A 			; if !=10 
    xorwf TIME_HH1, w;		; подпрограмма для работы с форматом 24 часа
    btfss STATUS, 0x02		; т.к. 18 часов может быть, а 28 нет, то надо
    goto end_clock		; ограничить единицы при десятках = 2
    incf    TIME_HH2
    movlw 0x30
    movwf	TIME_HH1
	
end_clock
    clrwdt
    
    ;ОБРАБОТКА БУДИЛЬНИКА
    movfw TIME_HH2 		
    xorwf ALARM_HH2, w;		; подпрограмма для работы с форматом 24 часа
    btfsc STATUS, 0x02
    goto if_T_AT_H1
    goto if_A_ON
    
if_T_AT_H1    
    movfw TIME_HH1 		
    xorwf ALARM_HH1, w;		; подпрограмма для работы с форматом 24 часа
    btfsc STATUS, 0x02
    goto if_T_AT_M2
    goto if_A_ON
    
if_T_AT_M2    
    movfw TIME_MM2 		
    xorwf ALARM_MM2, w;		; подпрограмма для работы с форматом 24 часа
    btfsc STATUS, 0x02
    goto if_T_AT_M1
    goto if_A_ON
    
if_T_AT_M1    
    movfw TIME_MM1 		
    xorwf ALARM_MM1, w;		; подпрограмма для работы с форматом 24 часа
    btfsc STATUS, 0x02
    goto inc_BA
    goto if_A_ON
    
inc_BA
    movlw .1
    movwf Blink_Alarm
    goto blinkON
    
if_A_ON 
    movlw .1
    xorwf NumAlarmBit, w
    btfsc STATUS, 0x02
    goto blinkON
    goto end_ALARM
    
NULL_BA_NAB
    movlw .0
    movwf NumAlarmBit
    movwf Blink_Alarm
    goto end_ALARM
    
blinkON
    ; SOUND ON
    call Keyboard	    ; спрашиваем клавиатуру
    btfsc Key9,0
    goto NULL_BA_NAB	    ; если нажали кнопку 1 переходим в функцию, которая инкрементирует выбранное число (inc)
    movlw .1
    movwf NumAlarmBit
end_ALARM
    call LCD_two		;Отрисовка второй строки
    movlw 0xff
    call delay ;задержка крч
    movlw 0xff
    call delay ;задержка крч
    movlw 0xff
    call delay ;задержка крч
    goto START		; конец основного цикла (должен быть = 1сек)

    ;--------------------------------------------------------
    ;--------------------------------------------------------
    
     ; Процедура типа switch для выбора дня недели
DEC addwf PCL
    goto monday
    goto tuesday
    goto wednesday	
    goto thursday    
    goto friday		
    goto saturday		
    goto sunday		
    return
;Отрисовка дней недели
monday			    ;понедельник
    movlw 'M'
    call write
    movlw 'O'
    call write
    movlw 'N'
    call write
    goto exday
tuesday			    ;вторник
    movlw 'T'
    call write
    movlw 'U'
    call write
    movlw 'E'
    call write
    goto exday
wednesday		    ;среда
    movlw 'W'
    call write
    movlw 'E'
    call write
    movlw 'D'
    call write
    goto exday
thursday		    ;четверг
    movlw 'T'
    call write
    movlw 'H'
    call write
    movlw 'U'
    call write
    goto exday
friday			    ;пятница
    movlw 'F'
    call write
    movlw 'R'
    call write
    movlw 'I'
    call write
    goto exday
saturday		    ;суббота
    movlw 'S'
    call write
    movlw 'A'
    call write
    movlw 'T'
    call write
    goto exday
sunday			    ;воскресенье
    movlw 'S'
    call write
    movlw 'U'
    call write
    movlw 'N'
    call write
exday
    return

    ;--------------------------------------------------------
    
time_plus_blink			; инкремент переменной выбора и переход к изменению времени
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto time_plus_blink
    incf NumPressKey,1
    goto change_time
    return
    
day_plus_blink			; инкремент переменной выбора и переход к изменению времени
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto day_plus_blink
    movlw 0x8
    movwf NumPressKey
    goto change_day
    return
    
alarm_plus_blink			; инкремент переменной выбора и переход к изменению времени
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto alarm_plus_blink
    movlw 0x9
    movwf NumPressKey
    goto change_alarm
    return
    ;--------------------------------------------------------
    
write    ; процедура записи байта к контроллер HD
    bcf STATUS, RP1
    bcf STATUS, RP0
    movwf PORTB
    bsf PORTC, 2
    movlw 0x01
    call delay
    bcf PORTC, 2
    return
    
    	; перед вызовом этой процедуры в W помеща-
	;ется байт, который надо записать в HD. Далее
	;он передается в PORTB и формируется отрица-
	;тельный перепад на RC2, путем предваритель-
	;ной  его  установки  в  «1»,  удержания  этого
	;уровня в течение некоторого времени (опреде-
	;ляемого временем задержки delay  при  W=1) и
	;сброса его в «0».

	;  процедура  задержки,  время  которой  можно
	;регулировать, задавая число в W
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
    movlw b'10000000'	; установка адреса
    call write
    bsf PORTC,0
    ;Отрисовка первой строки
    ; Отрисовка Н2
    call paintH2
    ; Отрисовка Н1
    call paintH1
    movlw ':'
    call write
    ; Отрисовка М2
    call paintM2
    ; Отрисовка М1
    call paintM1
    movlw ':'
    call write
    ; Отрисовка S2
    call paintS2
    ; Отрисовка S1
    call paintS1
    movlw ' '
    call write
    movlw ' '
    call write
    call printDay

    return
    
    ;==========================================
    
    ; Собственно механизм последовательного моргания при настройке времени
paintH2
    movlw 0x1			; если NumPressKey = 0, то вызываем
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
    goto return_H2
blink_on_H2
    movfw TIME_HH2
    call write
return_H2    
    return
    ;-----------
paintH1
    movlw 0x2			; если NumPressKey = 0, то вызываем
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
    goto return_H1
blink_on_H1
    movfw TIME_HH1
    call write
return_H1
    return
    ;------------
paintM2
    movlw 0x3			; если NumPressKey = 0, то вызываем
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
    goto return_M2
blink_on_M2
    movfw TIME_MM2
    call write
return_M2
    return
    ;------------
paintM1
    movlw 0x4			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_M1
    incf Blink,1
    btfss Blink, 0
    goto blink_on_M1
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
paintS2
    movlw 0x5			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_S2
    incf Blink,1
    btfss Blink, 0
    goto blink_on_S2
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
paintS1
    movlw 0x6			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_S1
    incf Blink,1
    btfss Blink, 0
    goto blink_on_S1
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
printDay
    movlw 0x8			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_day
    incf Blink,1
    btfss Blink, 0
    goto blink_on_day
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
; Установка RC0=0, для последующей передачи
;команды  на  контроллер  HD.  Передается  ко-
;манда Set DDRAM address,  устанавливающая
;счетчик  адреса  видеопамяти  на  начало  2-ой
;строки:  ячейку  с  адресом  (0х40  =  0100  0000).
;Это  необходимо  для  вывода  фразы  «TEM-
;PERATURA =» на второй строке индикатора.

    bsf PORTC,0  ; установка RC0=1, для последующей передачи
;кодов символов второй строки на дисплей. Об-
;ратите внимание на то, что нигде не требуется
;изменения  банков  памяти: т.к. все регистры, с
;которыми работает ПО, находятся в 0-ом бан-
;ке.
    call paint_ALARM
    
    movlw ' '
    call write
    movlw ' '
    call write
    
    call paintH2_A
    call paintH1_A
    movlw ':'
    call write
    call paintM2_A
    call paintM1_A
    return
 
    ;------------------------------------------
paintH2_A
    movlw 0x9			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_H2_A
    incf Blink,1
    btfss Blink, 0
    goto blink_on_H2_A
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
paintH1_A
    movlw 0xa			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_H1_A
    incf Blink,1
    btfss Blink, 0
    goto blink_on_H1_A
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
paintM2_A
    movlw 0xb			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_M2_A
    incf Blink,1
    btfss Blink, 0
    goto blink_on_M2_A
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
paintM1_A
    movlw 0xc			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	
    btfss STATUS, 0x02		
    goto blink_on_M1_A
    incf Blink,1
    btfss Blink, 0
    goto blink_on_M1_A
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
paint_ALARM
    movlw .1			; если NumPressKey = 0, то вызываем
    xorwf Blink_Alarm, w;	
    btfss STATUS, 0x02		
    goto blink_on_ALARM
    incf Blink,1
    btfss Blink, 0
    goto blink_on_ALARM
    goto blink_off_ALARM
blink_off_ALARM
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
blink_on_ALARM
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
    ;-----------
    
    ;==========================================
     
    
Keyboard		    ; драйвер клавиатуры для клавиш 1-4, 9
    bank0		    ; переход в нулевой банк, для нормального вызова функции из тела программы
    bcf STATUS, RP1
    clrf Key1		    ; обнуление кодов клавиш
    clrf Key2 
    clrf Key3
    clrf Key4  
    clrf Key9  
    clrf Cnt  
col1			    ; сканируем первый столбец, где нам нужны клавиши 1, 4
    bsf PORTA,0		    ; подача питания
    bcf PORTA,1
    bcf PORTA,2 
    ;movlw .24
    ;call small_delay
    movf PORTA,W	    ; читаем порт А в W и выполняем поразрядное умножение битов порта на число 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; если Z=1 (т.е. не нажата ни одна из кнопок) переходим на метку col2
    goto col2		    ; для сканирования второго столбца клавиатуры. Если Z=0, то пропускаем строку
    ;movlw .250
    ;call small_delay  
    btfsc PORTA,3	    ; определяем нажатия клавиши "1", проводя опрос первой строки
    incf Key1,F
    btfsc PORTA,4	    ; определяем нажатия клавиши "4", проводя опрос второй строки
    incf Key4,F
    
col2			    ; сканируем второй столбец, где нам нужна клавиша 2
    bcf PORTA,0		    ; подача питания
    bsf PORTA,1
    bcf PORTA,2 
    ;movlw .24
    ;sd
    movf PORTA,W	    ; читаем порт А в W и выполняем поразрядное умножение битов порта на число 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; если Z=1 (т.е. не нажата ни одна из кнопок) переходим на метку col3
    goto col3		    ; для сканирования третьего столбца клавиатуры. Если Z=0, то пропускаем строку
    ;movlw .250
    ;sd
    btfsc PORTA,3	    ; определяем нажатия клавиши "2", проводя опрос первой строки
    incf Key2,F
col3		    ; сканируем третий столбец, где нам нужна клавиша 3
    bcf PORTA,0		    ; подача питания
    bcf PORTA,1
    bsf PORTA,2
    ;movlw .24
    ;sd
    movf PORTA,W	    ; читаем порт А в W и выполняем поразрядное умножение битов порта на число 0011 1000.
    andlw 0x38
    btfsc STATUS,Z	    ; если Z=1 (т.е. не нажата ни одна из кнопок) выходим из функции
    goto end_keyb	    ; если Z=0, то пропускаем строку
    ;movlw .250
    ;sd
    btfsc PORTA,3	    ; определяем нажатия клавиши "3", проводя опрос первой строки
    incf Key3,F
    btfsc PORTA,5	    ; определяем нажатия клавиши "9", проводя опрос третей строки
    incf Key9,F
 
end_keyb 
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
    return		    ; выход из функции
    
;==============================================

change_time		    ; функция изменения времени
    call Keyboard	    ; спрашиваем клавиатуру
    btfsc Key1,0
    call correct_T_plus	    ; если нажали кнопку 1 переходим в функцию, которая инкрементирует выбранное число (inc)
    btfsc Key2,0
    call correct_T_minus    ; если нажали кнопку 2 переходим в функцию, которая декрементирует выбранное число (dec)
    btfsc Key3,0
    goto save_T		    ; переход к другой цифре путем инкремента NPK, при переполнения переменной происходит сохранение результата и выход в основной цикл
    btfsc Key4,0	    ; выход из настройки времени в основной цикл без сохранения результата
    goto change_HMS
    
    call LCD_one
    goto change_time
    
    ;----------------------------------------
correct_T_plus			; функция типа switch для ввода отдельных символов(инкремент или прибавление)
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto correct_T_plus		    
    movlw 0x1			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H2
    
    movlw 0x2			; если NumPressKey = 1, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H1

    movlw 0x3			; если NumPressKey = 2, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M2
    
    movlw 0x4			; если NumPressKey = 3, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M1
    
    movlw 0x5			; если NumPressKey = 4, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_S2
    
    movlw 0x6			; если NumPressKey = 5, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S1.
    btfsc STATUS, 0x02		; если нет, выходим из функции
    call correct_S1
    
    return
    
    ;----------------------------------------
    
correct_H2			; функцию коррекции переменной H2.
    incf TIME_HH2,1	; инкремент временной переменной для Н2
    movlw 0x33			; if !=3, переходим обратно в функцию
    xorwf TIME_HH2, w	; correct_T_plus и проверяем там следующее условие
    btfss STATUS, 0x02
    goto return_COR_H2
    movlw 	0x30		; Если переменная = 3, то обнуляем ее, т.к. в сутках 2 десятка часов
    movwf	TIME_HH2
return_COR_H2
    return			; и идем обратно в correct_T_plus и проверяем там следующее условие
    
correct_H1			; функцию коррекции переменной H1.
    incf TIME_HH1,1	; инкремент временной переменной для Н1
    movlw 0x32			; if = 2, переходим в функцию three_H1, которая служит для 
    xorwf TIME_HH2, w	; корректной задачи времени, т.к. 18 часов может быть, а 28 нет, то надо
	    			; ограничить единицы при десятках = 2	
    btfsc STATUS, 0x02
    goto three_H1			
    movlw 0x3a			; есди переменная = 0 или = 1, то максимальная единица для обноления - 9.
t1  xorwf TIME_HH1, w	
    btfss STATUS, 0x02
    goto return_COR_H1
    movlw 	0x30		; собственно обнуление переменной при достижении 10 или 4 по условию выше. 
    movwf	TIME_HH1
return_COR_H1
    return
    
three_H1
    movlw 0x34			; предел для обнуления при переменной = 2
    goto t1			; возврат к метке t1 для продолжения корректной работы
    
correct_M2			; функцию коррекции переменной M2.
    incf TIME_MM2,1
    movlw 0x36			; Работает так же, только обнуление происходит при достижении 6
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2
    movlw 	0x30
    movwf	TIME_MM2
return_COR_M2
    return
    
correct_M1			; функцию коррекции переменной M1.
    incf TIME_MM1,1
    movlw 0x3a			; Работает так же, только обнуление происходит при достижении 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1
    movlw 	0x30
    movwf	TIME_MM1
return_COR_M1
    return
    
correct_S2			; функцию коррекции переменной S2.
    incf TIME_SS2,1
    movlw 0x36			; Работает так же, только обнуление происходит при достижении 6
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto return_COR_S2
    movlw 	0x30
    movwf	TIME_SS2
return_COR_S2
    return
    
correct_S1			; функцию коррекции переменной S1.
    incf TIME_SS1,1
    movlw 0x3a			; Работает так же, только обнуление происходит при достижении 10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    goto return_COR_S1
    movlw 	0x30
    movwf	TIME_SS1
return_COR_S1
    return
    
    ;----------------------------------------
    
correct_T_minus			; функция типа switch для ввода отдельных символов(декремент)
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto correct_T_minus		  
    movlw 0x1			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H2_minus
    
    movlw 0x2			; если NumPressKey = 1, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H1_minus

    movlw 0x3			; если NumPressKey = 2, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M2_minus
    
    movlw 0x4			; если NumPressKey = 3, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M1_minus
    
    movlw 0x5			; если NumPressKey = 4, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_S2_minus
    
    movlw 0x6			; если NumPressKey = 5, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S1.
    btfsc STATUS, 0x02		; если нет, выходим из функции
    call correct_S1_minus
    
    return
    
    ;----------------------------------------
    
correct_H2_minus		; функцию коррекции переменной H2.
    decf TIME_HH2,1	; декремент временной переменной для Н2
    movlw 0x2f			; if !=2f, переходим обратно в функцию
    xorwf TIME_HH2, w	; correct_T_ и проверяем там следующее условие
    btfss STATUS, 0x02
    goto return_COR_H2_MIN
    movlw 	0x32		; Если переменная = 2f, то присваиваем ей значение 2, т.к. в сутках 2 десятка часов
    movwf	TIME_HH2
return_COR_H2_MIN
    return			; и идем обратно в correct_T_ и проверяем там следующее условие
    
correct_H1_minus		; функцию коррекции переменной H1.
    decf TIME_HH1,1	; декремент временной переменной для Н1
    movlw 0x2f			; if != 2f, переходим обратно в функцию 
    xorwf TIME_HH1, w	; correct_T_ и проверяем там следующее условие
	    				
    btfss STATUS, 0x02
    goto return_COR_H1_MIN		
    movlw 0x32			; есди переменная = 2, то при достижении 2f будем присваивать Н1 = 3.
    xorwf TIME_HH2, w	
    btfsc STATUS, 0x02
    goto three_H1_minus
    movlw 	0x39		; есди переменная != 2, то при достижении 2f будем присваивать Н1 = 9. 
t2  movwf	TIME_HH1
return_COR_H1_MIN
    return
    
three_H1_minus
    movlw 0x33			; значение для присваивания при Н2 = 2.
    goto t2			; возврат к метке t2 для продолжения корректной работы
    
correct_M2_minus			; функцию коррекции переменной M2.
    decf TIME_MM2,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 5
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_MIN
    movlw 	0x35
    movwf	TIME_MM2
return_COR_M2_MIN
    return
    
correct_M1_minus			; функцию коррекции переменной M1.
    decf TIME_MM1,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_MIN
    movlw 	0x39
    movwf	TIME_MM1
return_COR_M1_MIN
    return
    
correct_S2_minus			; функцию коррекции переменной S2.
    decf TIME_SS2,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 5
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto return_COR_S2_MIN
    movlw 	0x35
    movwf	TIME_SS2
return_COR_S2_MIN
    return
    
correct_S1_minus			; функцию коррекции переменной S1.
    decf TIME_SS1,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 10
    xorwf TIME_SS1, w;
    btfss STATUS, 0x02
    goto return_COR_S1_MIN
    movlw 	0x39
    movwf	TIME_SS1
return_COR_S1_MIN
    return
    
    ;==============================================
    
save_T				; функция проверки и сохранения времени
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto save_T
    movlw 0x6			; если происходит переполнение NumPressKey
    xorwf NumPressKey, w	; значит время заданно корректно во всех ячейках
    btfsc STATUS, 0x02		; и мы переходим в функцию записи переменных значений
    goto START			; в постоянные
    incf NumPressKey,1		; Если NumPressKey не переполнен, то инкрементируем
    goto change_time		; его и возвращаемся в функцию изменения времени
    
change_HMS
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto change_HMS
    movfw TEMP_TIME_HH2		; записываем значения временных переменных в постоянные (NPK 
    movwf TIME_HH2		; необходим для определения ячейки, в которую записываем
    movfw TEMP_TIME_HH1		; значение)
    movwf TIME_HH1
    movfw TEMP_TIME_MM2		
    movwf TIME_MM2
    movfw TEMP_TIME_MM1		
    movwf TIME_MM1
    movfw TEMP_TIME_SS2		
    movwf TIME_SS2
    movfw TEMP_TIME_SS1		
    movwf TIME_SS1
    goto START			; возврат в основной цикл
    
    ;==============================================
    ;==============================================
    ;==============================================
    
change_day		    ; функция изменения дня недели
    call Keyboard
    btfsc Key1,0
    goto plus_day_ch	    ; если нажали кнопку 1 переходим в функцию, которая инкрементирует выбранное число (inc)
    btfsc Key2,0
    goto minus_day_ch	    ; если нажали кнопку 2 переходим в функцию, которая декрементирует выбранное число (dec)
    btfsc Key3,0	    ; выход из настройки времени в основной цикл без сохранения результата
    goto save_end_day
    btfsc Key4,0	    ; выход из настройки времени в основной цикл без сохранения результата
    goto save_day_ch
    
    call LCD_one
    
    goto change_day
    
plus_day_ch
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto plus_day_ch
    incf DAY,1
    movlw .7			; inc переменной День
    xorwf DAY, w;
    btfss STATUS, 0x02		; is not working 
    goto change_day			; 
    movlw .0
    movwf DAY
    goto change_day
    
minus_day_ch
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto minus_day_ch
    decf DAY,1
    movlw .255			; inc переменной День
    xorwf DAY, w;
    btfss STATUS, 0x02		; is not working 
    goto change_day			
    movlw .6
    movwf DAY
    goto change_day
    
save_day_ch
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto save_day_ch
    movfw TEMP_DAY
    movwf DAY
    goto START
    
save_end_day
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto save_end_day
    goto START
    ;==============================================
    ;==============================================
    ;==============================================
    
    ;==============================================
change_alarm		    
    call Keyboard	    ; спрашиваем клавиатуру
    btfsc Key1,0
    call correct_A_plus	    ; если нажали кнопку 1 переходим в функцию, которая инкрементирует выбранное число (inc)
    btfsc Key2,0
    call correct_A_minus    ; если нажали кнопку 2 переходим в функцию, которая декрементирует выбранное число (dec)
    btfsc Key3,0
    goto save_A		    ; переход к другой цифре путем инкремента NPK, при переполнения переменной происходит сохранение результата и выход в основной цикл
    btfsc Key4,0	    ; выход из настройки времени в основной цикл без сохранения результата
    goto change_AHMS
    
    call LCD_two
    goto change_alarm
    
    ;----------------------------------------
    
correct_A_plus			; функция типа switch для ввода отдельных символов(инкремент или прибавление)
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto correct_A_plus			    
    movlw 0x9			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H2_A
    
    movlw 0xa		; если NumPressKey = 1, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H1_A

    movlw 0xb			; если NumPressKey = 2, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M2_A
    
    movlw 0xc			; если NumPressKey = 3, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M1_A
    
    return
    
    ;----------------------------------------
    
correct_H2_A			; функцию коррекции переменной H2.
    incf ALARM_HH2,1	; инкремент временной переменной для Н2
    movlw 0x33			; if !=3, переходим обратно в функцию
    xorwf ALARM_HH2, w	; correct_T_plus и проверяем там следующее условие
    btfss STATUS, 0x02
    goto return_COR_H2_A
    movlw 	0x30		; Если переменная = 3, то обнуляем ее, т.к. в сутках 2 десятка часов
    movwf	ALARM_HH2
return_COR_H2_A
    return			; и идем обратно в correct_T_plus и проверяем там следующее условие
    
correct_H1_A			; функцию коррекции переменной H1.
    incf ALARM_HH1,1	; инкремент временной переменной для Н1
    movlw 0x32			; if = 2, переходим в функцию three_H1, которая служит для 
    xorwf ALARM_HH2, w	; корректной задачи времени, т.к. 18 часов может быть, а 28 нет, то надо
	    			; ограничить единицы при десятках = 2	
    btfsc STATUS, 0x02
    goto three_H1_A			
    movlw 0x3a			; есди переменная = 0 или = 1, то максимальная единица для обноления - 9.
ta1 xorwf ALARM_HH1, w	
    btfss STATUS, 0x02
    goto return_COR_H1_A
    movlw 	0x30		; собственно обнуление переменной при достижении 10 или 4 по условию выше. 
    movwf	ALARM_HH1
return_COR_H1_A
    return
    
three_H1_A
    movlw 0x34			; предел для обнуления при переменной = 2
    goto ta1			; возврат к метке t1 для продолжения корректной работы
    
correct_M2_A			; функцию коррекции переменной M2.
    incf ALARM_MM2,1
    movlw 0x36			; Работает так же, только обнуление происходит при достижении 6
    xorwf ALARM_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_A
    movlw 	0x30
    movwf	ALARM_MM2
return_COR_M2_A
    return
    
correct_M1_A			; функцию коррекции переменной M1.
    incf ALARM_MM1,1
    movlw 0x3a			; Работает так же, только обнуление происходит при достижении 10
    xorwf ALARM_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_A
    movlw 	0x30
    movwf	ALARM_MM1
return_COR_M1_A
    return
    
    ;----------------------------------------
    
correct_A_minus			; функция типа switch для ввода отдельных символов(декремент)
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto correct_A_minus
    movlw 0x9			; если NumPressKey = 0, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H2_minus_A
    
    movlw 0xa			; если NumPressKey = 1, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H1_minus_A

    movlw 0xb			; если NumPressKey = 2, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M2_minus_A
    
    movlw 0xc			; если NumPressKey = 3, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M1_minus_A
    
    return
    
    ;----------------------------------------
    
correct_H2_minus_A		; функцию коррекции переменной H2.
    decf ALARM_HH2,1	; декремент временной переменной для Н2
    movlw 0x2f			; if !=2f, переходим обратно в функцию
    xorwf ALARM_HH2, w	; correct_T_ и проверяем там следующее условие
    btfss STATUS, 0x02
    goto return_COR_H2_A_minus
    movlw 	0x32		; Если переменная = 2f, то присваиваем ей значение 2, т.к. в сутках 2 десятка часов
    movwf	ALARM_HH2
return_COR_H2_A_minus
    return			; и идем обратно в correct_T_ и проверяем там следующее условие
    
correct_H1_minus_A		; функцию коррекции переменной H1.
    decf ALARM_HH1,1	; декремент временной переменной для Н1
    movlw 0x2f			; if != 2f, переходим обратно в функцию 
    xorwf ALARM_HH1, w	; correct_T_ и проверяем там следующее условие
	    				
    btfss STATUS, 0x02
    goto return_COR_H1_A_minus		
    movlw 0x32			; есди переменная = 2, то при достижении 2f будем присваивать Н1 = 3.
    xorwf ALARM_HH2, w	
    btfsc STATUS, 0x02
    goto three_H1_minus_A
    movlw 	0x39		; есди переменная != 2, то при достижении 2f будем присваивать Н1 = 9. 
ta2 movwf	ALARM_HH1
return_COR_H1_A_minus
    return
    
three_H1_minus_A
    movlw 0x33			; значение для присваивания при Н2 = 2.
    goto ta2			; возврат к метке t2 для продолжения корректной работы
    
correct_M2_minus_A			; функцию коррекции переменной M2.
    decf ALARM_MM2,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 5
    xorwf ALARM_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_A_minus
    movlw 	0x35
    movwf	ALARM_MM2
return_COR_M2_A_minus
    return
    
correct_M1_minus_A			; функцию коррекции переменной M1.
    decf ALARM_MM1,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 10
    xorwf ALARM_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_A_minus
    movlw 	0x39
    movwf	ALARM_MM1
return_COR_M1_A_minus
    return
    
    ;==============================================
    
save_A				; функция проверки и сохранения времени
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto save_A
    movlw 0xd			; если происходит переполнение NumPressKey
    xorwf NumPressKey, w	; значит время заданно корректно во всех ячейках
    btfsc STATUS, 0x02		; и мы переходим в функцию записи переменных значений
    goto START			; в постоянные
    incf NumPressKey,1		; Если NumPressKey не переполнен, то инкрементируем
    goto change_alarm		; его и возвращаемся в функцию изменения времени
    
change_AHMS
    movlw 0xff				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto change_AHMS
    movfw TEMP_ALARM_HH2		; записываем значения временных переменных в постоянные (NPK 
    movwf ALARM_HH2		; необходим для определения ячейки, в которую записываем
    movfw TEMP_ALARM_HH1		; значение)
    movwf ALARM_HH1
    movfw TEMP_ALARM_MM2		
    movwf ALARM_MM2
    movfw TEMP_ALARM_MM1		
    movwf ALARM_MM1
    goto START			; возврат в основной цикл
    
    ;==============================================
    ;==============================================
    ;==============================================
			    
;small_delay:			; задержка для драйвера
;    movwf fCOUNTER1
;    clrwdt
;    decfsz fCOUNTER1,F
;    goto $-2
;    return
    
end  ; конец программы