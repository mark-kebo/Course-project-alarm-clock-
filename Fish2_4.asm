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
    ;вспомогательные  регистры,  назначе-
	;ние которых приведено в комментариях
    constant   DS = .2
    constant   RST = .2
	;  директивы,  ставящие в  соответствие
	;меткам DS  и  RST  значение  0.  Анало-
	;гия директив equ для имен регистров.

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
	;конфигурирование  RD0  как  входа
	;для  установки  на  нем  «1»  в  качестве
	;исходного  состояния  интерфейса  «1-Wire»
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

	;Отрисовка первой строки
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
	btfss STATUS, 0x02		; Обнуление переменной при достижении воскресенья, 
	goto end_clock			; что бы при 00:00:00 перейти в понедельник
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
	call delay ;задержка крч
	movlw 0xff
	call delay ;задержка крч
	movlw 0xff
	call delay ;задержка крч

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
		
;Отрисовка дней недели
monday		;понедельник
    movlw 'M'
    call write
    movlw 'O'
    call write
    movlw 'N'
    call write
    goto exday
tuesday		;вторник
    movlw 'T'
    call write
    movlw 'U'
    call write
    movlw 'E'
    call write
    goto exday
wednesday	;среда
    movlw 'W'
    call write
    movlw 'E'
    call write
    movlw 'D'
    call write
    goto exday
thursday	;четверг
    movlw 'T'
    call write
    movlw 'H'
    call write
    movlw 'U'
    call write
    goto exday
friday		;пятница
    movlw 'F'
    call write
    movlw 'R'
    call write
    movlw 'I'
    call write
    goto exday
saturday	;суббота
    movlw 'S'
    call write
    movlw 'A'
    call write
    movlw 'T'
    call write
    goto exday
sunday		;воскресенье
    movlw 'S'
    call write
    movlw 'U'
    call write
    movlw 'N'
    call write
    exday
return
goto START
end  ; конец программы