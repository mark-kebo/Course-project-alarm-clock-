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
;директивы  типа  контроллера,  под-
;ключения  заголовочного  файла  и  вы-
;вода сообщений об ошибках
#define   bank0  bcf STATUS,  RP0
#define   bank1  bsf STATUS,  RP0
;директивы, позволяющие заменять в теле  ПО  команды,  указанные  после
;этой  директивы  (bcf  ,  bsf)  –  метками bank0, bank1. Обратную замену производит компилятор
WAIT		    equ	    0x20
Reg_1		    equ	    0x23    ;Регистры, используемые для задержек
Reg_2		    equ	    0x24
Reg_3		    equ	    0x25
fCOUNTER	    equ     0x26
fCOUNTER2	    equ     0x27
TIME_HH1	    equ	    0x30    ;Регистр, который хранит значение единиц часов
TIME_HH2	    equ	    0x31    ;Регистр, который хранит значение десятков часов
TIME_MM1	    equ	    0x32    ;Регистр, который хранит значение единиц минут
TIME_MM2	    equ	    0x33    ;Регистр, который хранит значение десятков минут
TIME_SS1	    equ	    0x34    ;Регистр, который хранит значение единиц секунд
TIME_SS2	    equ	    0x35    ;Регистр, который хранит значение десятков секунд
DAY		    equ	    0x36    ;Регистр, который хранит значение дня недели
ALARM_HH1	    equ	    0x37    ;Регистр, который хранит значение единиц часов для будильника
ALARM_HH2	    equ	    0x38    ;Регистр, который хранит значение десятков часов для будильника
ALARM_MM1	    equ	    0x39    ;Регистр, который хранит значение единиц минут для будильника
ALARM_MM2	    equ	    0x3A    ;Регистр, который хранит значение десятков минут для будильника
Key1		    equ	    0x3B    ;Регистры, которые хранят состояние клавиш в драйвере  
Key2		    equ	    0x3C    ;клавиатуры Keyboard
Key3		    equ	    0x3D
Key4		    equ	    0x3E
Key9		    equ	    0x3F
Blink		    equ	    0x40    ;Регистр, для управления морганием элементов экрана
Cnt		    equ	    0x41    ;Регистр, который хранит состояние клавиши в драйвере (нажата или нет)
Blink_Alarm	    equ	    0x42    ;Управляющий регистр, который выполняет функцию включения\выключения будильника
NumPressKey	    equ	    0x43    ;Управляющий регистр-метка, для посимвольного изменения значений и выбора моргающего элемента
fCOUNTER1	    equ     0x44    ;Регистр используемый для задержек    
TEMP_TIME_HH1	    equ	    0x45    ;Регистры, который хранит значения: часов, минут, секунд основного времени;
TEMP_TIME_HH2	    equ	    0x46    ;значение дня и минут, часов будильника. Нужены для сохранения текущих значений
TEMP_TIME_MM1	    equ	    0x47    ;перед изменением в соответствующих режимах
TEMP_TIME_MM2	    equ	    0x48
TEMP_TIME_SS1	    equ	    0x49
TEMP_TIME_SS2	    equ	    0x4A
TEMP_DAY	    equ	    0x4B
TEMP_ALARM_HH1	    equ	    0x4C
TEMP_ALARM_HH2	    equ	    0x4D
TEMP_ALARM_MM1	    equ	    0x4E
TEMP_ALARM_MM2	    equ	    0x4F
NumAlarmBit	    equ	    0x50    ;Так же, как Blink_Alarm, управляет корректным включением и выключением будильника
    
wait  macro     time
    movlw    (time/5)-1
    movwf    WAIT
    call    wait5u
    endm
;макрос паузы с именем wait. Особенность этого макроса состоит в том, что
;у  него  имеется  параметр  –  time.  При вызове  макроса  значение  параметра
;указывается  после  имени  макроса  в виде  целого  десятичного  числа  крат-
;ного  5  (в  данном  примере).  В  теле макроса  это  число  подставляется  в
;«переменную» time и далее используется вычисленное значение (которое в
;данном случае  выступает  в  роли  константы, записываемой в W). Вместе с
;процедурой  wait5u  длительность  задержки,  обеспечиваемая  макросом
;равна time микросекунд
    org 0x0000
    clrf STATUS
    movlw 0x00
    movwf PCLATH
    goto begin
;Выбор нулевой страницы памяти команд и размещение на ней откомпилированного кода

begin
    bank1			;Выбор первого банка памяти. Для вы-
				;зова используется метка bank1, объяв-
				;ленная выше директивой #define.
    movlw 0x8F			;Установка  максимального  времени
    movwf OPTION_REG		;срабатывания  сторожевого  таймера  и его сброс
    clrwdt
    clrf INTCON			;Отключение  прерываний  и  их  обработки
    clrf PIE1
    clrf PIE2
    movlw .0			;Конфигурирование  портов  А, В, С, Е, D
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
    bank0			;Подготовка к передаче команд на контроллер
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
;Передача команды Clear  Display для очистки дисплея и установки счетчика адреса видеопа-
;мяти  на  нулевой  адрес  (первое  знакоместо  в верхней строке), с необходимой задержкой
    clrwdt
    movlw 0x38
    call write
    movlw 0x0f
    call delay

;Передача команды Function Set для установки режима  2-х  строчного  индикатора,  размера
;знакоместа 5х7 и 8 разрядной шины данных
    movlw 0x06
    call write
    movlw 0x0f
    call delay
;Передача  команды  Entry  Mode  Set  для  установки режима увеличения счетчика адреса ви-
;деопамяти, после каждой записи символа в нее, при неподвижности видеопамяти относительно индикатора
    movlw 0x0c
    call write
    movlw 0x0f
    call delay
;Передача  команды  Display  ON/OFF  control для включения дисплея с отключенным курсо-
;ром.  На  этом  этап инициализации дисплея закончен.
    movlw 	0x31		;Присвоение начальных значений регистров времени и дня,
    movwf	ALARM_MM1	;а так же обнуление управляющих регистров до перехода 
    movlw 	0x30		;в основной цикл программы
    movwf	TIME_HH1
    movwf	TIME_HH2
    movwf	TIME_MM1
    movwf	TIME_MM2
    movwf	TIME_SS1
    movwf	TIME_SS2 
    movwf	ALARM_HH1
    movwf	ALARM_HH2
    movwf	ALARM_MM2
    movlw 	.0
    movwf	DAY
    movwf	Blink_Alarm
    movwf	NumAlarmBit
    movlw 	b'00000000'
    movwf	Blink

START				;Метка начала основного цикла программы
    movlw .0			;Записываем значения времени, дня и обнуление управляющего регистра 
    movwf Blink_Alarm		;в начале каждого прохода основного цикла
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
    movwf NumPressKey		; NumPressKey каждый раз устанавливаем в начальное значение
    movfw ALARM_HH1
    movwf TEMP_ALARM_HH1
    movfw ALARM_HH2
    movwf TEMP_ALARM_HH2
    movfw ALARM_MM1
    movwf TEMP_ALARM_MM1
    movfw ALARM_MM2
    movwf TEMP_ALARM_MM2
    
    call Keyboard		; Читаем клавиатуру
    btfsc Key1,0		; Проверка нажатия клавиши "1",  если нажата, то переходим 
    call time_plus_blink	; к изменению времени, нет - тогда проверяем клавишу 2
    btfsc Key2,0		; Проверка нажатия клавиши "2",  если нажата, то переходим 
    call day_plus_blink		; к изменению дня недели, нет - тогда проверяем клавишу 3
    btfsc Key3,0		; Проверка нажатия клавиши "3",  если нажата, то переходим 
    call alarm_plus_blink	; к изменению будильника, нет - тогда едем дальше
	
    call LCD_one		;Отрисовка первой строки на дисплее		

    ;Счет единиц секунд (0-9) - TIME_SS1
    incf TIME_SS1,1
    movlw 0x3A			; Выполняем инкремент значения единиц секунд и если
    xorwf TIME_SS1, w;		; это значение !=10, то переходим к метке конца обработки времени 
    btfss STATUS, 0x02		; Если же значение секунды = 10, то обнуляем его и переходим к обработке
    goto end_clock		; десятков секунд 
    movlw 0x30
    movwf	TIME_SS1

    ;Счет десятков секунд (0-5) - TIME_SS2
    incf TIME_SS2,1		; Выполняем инкремент значения десятков секунд и если
    movlw 0x36			; это значение !=6, то переходим к метке конца обработки времени
    xorwf TIME_SS2, w;		; Если же значение секунды = 6, то обнуляем его и переходим к обработке
    btfss STATUS, 0x02		; единиц минут
    goto end_clock
    movlw 0x30
    movwf	TIME_SS2
	
    ;Счет единиц минут (0-9) - TIME_MM1
    incf TIME_MM1,1		; Выполняем инкремент значения единиц минут и если
    movlw 0x3A			; это значение !=10, то переходим к метке конца обработки времени 
    xorwf TIME_MM1, w		; Если же значение минуты = 10, то обнуляем его и переходим к обработке
    btfss STATUS, 0x02		; десятков минут
    goto end_clock
    movlw 0x30
    movwf	TIME_MM1

    ;Счет десятков минут (0-5) - TIME_MM2
    incf TIME_MM2,1		; Выполняем инкремент значения десятков минут и если
    movlw 0x36			; это значение !=6, то переходим к метке конца обработки времени
    xorwf TIME_MM2, w		; Если же значение минуты = 6, то обнуляем его и переходим к обработке
    btfss STATUS, 0x02		; единиц часов
    goto end_clock
    movlw 0x30
    movwf	TIME_MM2

    ;Счет единиц и десятков часов - TIME_НН2, TIME_НН1
    incf TIME_HH1,1		; Выполняем инкремент значения единиц часов и если
    movlw 0x34 			; это значение !=4, то переходим к метке работы с единицами 
    xorwf TIME_HH1, w;		; часов до 10.
    btfss STATUS, 0x02
    goto ten_clock
    movlw 0x32			; Если значение десятков часов !=2, то тка же работаем
    xorwf TIME_HH2, w;		; с форматом до 10, пройдя по метке
    btfss STATUS, 0x02
    goto ten_clock
    movlw 0x30			; Обнуление десятков и единиц часов
    movwf	TIME_HH1
    movwf	TIME_HH2
    incf    DAY,1		; Инкремент переменной Деня, для перехода в новый день в 00:00
    movlw 	.7		; Обнуление переменной при достижении воскресенья,
    xorwf DAY, w;		; что бы при 00:00:00 перейти в понедельник
    btfss STATUS, 0x02			 
    goto end_clock			
    movlw 	.0
    movwf	DAY

	
ten_clock
    movlw 0x3A 			; Если значение единиц часов !=10, то 
    xorwf TIME_HH1, w;		; переходим в конец обработки времени.
    btfss STATUS, 0x02		; Если значение = 10, то инкрементируем десятки часов
    goto end_clock		; и обнуляем значение единиц
    incf    TIME_HH2
    movlw 0x30
    movwf	TIME_HH1
	
end_clock			; Метка конца работы со времинем
    clrwdt			; Чистим на всякий
    
;Обработка будильника
    movlw .1			; Проверяем, равен ли единице управляющий регистр
    xorwf NumAlarmBit, w
    btfsc STATUS, 0x02
    goto inc_BA			; Если равен переходим сразу в функцию опроса клавиши 9
    goto if_S_ONE_ZERO		; Если нет, то проверяем значение секунд
    
if_S_ONE_ZERO			
    movlw 0x30 			; Если единицы секунд = 0, то
    xorwf TIME_SS1, w;		; переходим к проверке десятков секунд, аналогичную проверку
    btfsc STATUS, 0x02		; выполняем и там. Если не равно 0, то переходим по метке к
    goto if_S_TWO_ZERO		; концу обработки будильника
    goto end_ALARM    
if_S_TWO_ZERO    
    movlw 0x30 			
    xorwf TIME_SS2, w;
    btfsc STATUS, 0x02
    goto if_T_AT_H2		; Переход к проверке на равенство десятков часов и будильника
    goto end_ALARM     
	
if_T_AT_H2			; Если значения десятков будильника и реального времени равны, то
    movfw TIME_HH2 		; переходим к проверке единиц. Если нет, то оканчиваем проверку 
    xorwf ALARM_HH2, w;		; будильника.
    btfsc STATUS, 0x02		; Аналогичную проверку проводим и для минут.
    goto if_T_AT_H1
    goto end_ALARM
    
if_T_AT_H1			; Проверка единиц часа у часов и будильника
    movfw TIME_HH1 		
    xorwf ALARM_HH1, w;		
    btfsc STATUS, 0x02
    goto if_T_AT_M2
    goto end_ALARM
    
if_T_AT_M2			; Проверка десятков минут часов и будильника
    movfw TIME_MM2 		
    xorwf ALARM_MM2, w;		
    btfsc STATUS, 0x02
    goto if_T_AT_M1
    goto end_ALARM
    
if_T_AT_M1			; Проверка единиц минут часов и будильника
    movfw TIME_MM1 		
    xorwf ALARM_MM1, w;		
    btfsc STATUS, 0x02
    goto inc_BA			; Если все значения совпали, то переходим к метке,
    goto end_ALARM		; где присваиваем управляющему регистру Blink_Alarm 
				; единицу, после чего переходим в функцию
inc_BA				; опроса клавиатуры, для ожидания нажатия кнопки
    movlw .1			; 9, для обнуления управляющих регистров, что
    movwf Blink_Alarm		; отключает звуковой сигнал и моргание экрана
    goto blinkON
    
NULL_BA_NAB			; Обнуление управляющих регистров
    movlw .0
    movwf NumAlarmBit
    movwf Blink_Alarm
    goto end_ALARM
    
blinkON
    call Keyboard	    ; Спрашиваем клавиатуру
    btfsc Key9,0
    goto NULL_BA_NAB	    ; Если нажали кнопку 9 переходим в функцию, где обнуляем управляющие регистры
    movlw .1		    ; Если нет, то устанавливаем NumAlarmBit=1 для непрерывного моргания и звукового сигнала
    movwf NumAlarmBit	    ; пока не нажата 9.
end_ALARM		    ;Метка конца обработки будильника
    call LCD_two	    ;Отрисовка второй строки
    call delay_one_sec	    ;Задержка пока на 1сек
    goto START		    ; конец основного цикла (должен быть = 1сек)

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
    
time_plus_blink		    ; Функция обработки перед переходом в другой режим
    movlw 0x1		    ; Задержка, для защиты от дребезга
    call delay				
    call Keyboard	    ;Опрос клавиатуры что бы выяснить отжата клавиша или нет
    movf Cnt,1		    ;Если нет, то циклим
    btfss STATUS,Z			
    goto time_plus_blink
    incf NumPressKey,1	    ;Если клавиша отжата, то инкрементируем NumPressKey
    goto change_time	    ;для выбора ячейки, в которой будут изменяться значения.
    return		    ;После чего переходим к изменению времени
    
day_plus_blink		    ; Функция обработки перед переходом в другой режим
    movlw 0x1		    ; Задержка, для защиты от дребезга		
    call delay				
    call Keyboard	    ;Опрос клавиатуры что бы выяснить отжата клавиша или нет
    movf Cnt,1		    ;Если нет, то циклим
    btfss STATUS,Z			
    goto day_plus_blink
    movlw 0x8		    ;Если клавиша отжата, то установим NumPressKey = 8
    movwf NumPressKey	    ;для выбора ячейки, в которой будут изменяться значения.
    goto change_day	    ;После чего переходим к изменению дня недели
    return
    
alarm_plus_blink	    ; Функция обработки перед переходом в другой режим
    movlw 0x1		    ; Задержка, для защиты от дребезга		
    call delay				
    call Keyboard	    ;Опрос клавиатуры что бы выяснить отжата клавиша или нет
    movf Cnt,1		    ;Если нет, то циклим
    btfss STATUS,Z			
    goto alarm_plus_blink
    movlw 0x9		    ;Если клавиша отжата, то установим NumPressKey = 9
    movwf NumPressKey	    ;для выбора ячейки, в которой будут изменяться значения.
    goto change_alarm	    ;После чего переходим к изменению будильника
    return
    ;--------------------------------------------------------
    
write			    ;Процедура записи байта к контроллер HD
    bcf STATUS, RP1
    bcf STATUS, RP0
    movwf PORTB
    bsf PORTC, 2
    movlw 0x01
    call delay
    bcf PORTC, 2
    return
; перед вызовом этой процедуры в W помещается байт, который надо записать в HD. Далее
;он передается в PORTB и формируется отрицательный перепад на RC2, путем предваритель-
;ной  его  установки  в  «1»,  удержания  этого уровня в течение некоторого времени (опреде-
;ляемого временем задержки delay  при  W=1) и сброса его в «0».
	
delay			    ;Процедура  задержки,  время  которой  можно
    bcf   STATUS, RP1	    ;регулировать, задавая число в W
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

delay_one_sec
 ; Задержка 1 000 000 машинных циклов
    movlw       .254
    movwf       Reg_1
    movlw       .17
    movwf       Reg_2
    movlw       .6
    movwf       Reg_3
    decfsz      Reg_1,F
    goto        $-1
    clrwdt
    decfsz      Reg_2,F
    goto        $-4
    decfsz      Reg_3,F
    goto        $-6
    nop
    nop
    return
    ;==========================================
    
LCD_one
;Установка RC0=0, для последующей передачи команды  на  контроллер  HD.  Передается  ко-
;манда Set DDRAM address,  устанавливающая счетчик  адреса  видеопамяти  на  начало  1-ой 
;строки:  ячейку  с  адресом  (10000000). Это  необходимо  для  вывода  
;времени и дня недели на первой строке индикатора.
    bcf PORTC, 0
    movlw b'10000000'	
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
;Отрисовка дня недели
    call printDay

    return
    
    ;==========================================
    
; Собственно механизм последовательного моргания при настройке времени
paintH2				;Моргание десятков часов
    movlw 0x1			;Если NumPressKey = 1, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_H2		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 1, то проверяем следующую функцию
    goto blink_on_H2		;и отрисовываем постоянно значение
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
paintH1				;Моргание единиц часов
    movlw 0x2			;Если NumPressKey = 2, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_H1		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 2, то проверяем следующую функцию
    goto blink_on_H1		;и отрисовываем постоянно значение
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
paintM2				;Моргание десятков минут
    movlw 0x3			;Если NumPressKey = 3, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_M2		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 3, то проверяем следующую функцию
    goto blink_on_M2		;и отрисовываем постоянно значение
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
paintM1				;Моргание единиц минут
    movlw 0x4			;Если NumPressKey = 4, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_M1		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 4, то проверяем следующую функцию
    goto blink_on_M1		;и отрисовываем постоянно значение
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
paintS2				;Моргание десятков секунд
    movlw 0x5			;Если NumPressKey = 5, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_S2		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 5, то проверяем следующую функцию
    goto blink_on_S2		;и отрисовываем постоянно значение
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
paintS1				;Моргание единиц секунд
    movlw 0x6			;Если NumPressKey = 6, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_S1		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 6, то проверяем следующую функцию
    goto blink_on_S1		;и отрисовываем постоянно значение
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
printDay			;Моргание дня недели
    movlw 0x8			;Если NumPressKey = 8, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_day		;за отрисовку. Один отрисовывает значение дня,
    incf Blink,1		;а другой символы пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 8, то проверяем следующую функцию
    goto blink_on_day		;и отрисовываем постоянно значение
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
;Установка RC0=0, для последующей передачи команды  на  контроллер  HD.  Передается  ко-
;манда Set DDRAM address,  устанавливающая счетчик  адреса  видеопамяти  на  начало  2-ой
;строки:  ячейку  с  адресом  (11000100). Это  необходимо  для  вывода  фразы  «ALARM» и будильника на второй строке индикатора.
    bsf PORTC,0			; установка RC0=1, для последующей передачи
				;кодов символов второй строки на дисплей. Об-
				;ратите внимание на то, что нигде не требуется
				;изменения  банков  памяти: т.к. все регистры, с
				;которыми работает ПО, находятся в 0-ом банке.
    call paint_ALARM		;Вызов метода отрисовки
    
    movlw ' '
    call write
    movlw ' '
    call write
    
    call paintH2_A		;Вызов метода отрисовки
    call paintH1_A		;Вызов метода отрисовки
    movlw ':'
    call write
    call paintM2_A		;Вызов метода отрисовки
    call paintM1_A		;Вызов метода отрисовки
    return
    ;------------------------------------------
paintH2_A			;Моргание десятков часов будильника
    movlw 0x9			;Если NumPressKey = 9, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_H2_A		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 9, то проверяем следующую функцию
    goto blink_on_H2_A		;и отрисовываем постоянно значение
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
paintH1_A			;Моргание единиц часов будильника
    movlw 0xa			;Если NumPressKey = 10, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_H1_A		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 10, то проверяем следующую функцию
    goto blink_on_H1_A		;и отрисовываем постоянно значение
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
paintM2_A			;Моргание десятков минут будильника
    movlw 0xb			;Если NumPressKey = 11, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_M2_A		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 11, то проверяем следующую функцию
    goto blink_on_M2_A		;и отрисовываем постоянно значение
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
paintM1_A			;Моргание единиц минут будильника
    movlw 0xc			;Если NumPressKey = 12, то включаем моргание
    xorwf NumPressKey, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_M1_A		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если NumPressKey != 12, то проверяем следующую функцию
    goto blink_on_M1_A		;и отрисовываем постоянно значение
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
paint_ALARM			;Моргание надписи будильника
    movlw .1			;Если Blink_Alarm = 1, то включаем моргание
    xorwf Blink_Alarm, w;	;В зависимости от регистра Blink поочередно
    btfss STATUS, 0x02		;включае один из методов, отвечающих
    goto blink_on_ALARM		;за отрисовку. Один отрисовывает значение времени,
    incf Blink,1		;а другой символ пробела. Так создается эффект моргания.
    btfss Blink, 0		;Если Blink_Alarm != 1, то проверяем следующую функцию
    goto blink_on_ALARM		;и отрисовываем постоянно значение
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
col3			    ; сканируем третий столбец, где нам нужна клавиша 3
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
 
end_keyb		    ;Метод, для записи в Cnt = 1, если нажата клавиша (нужен для преверки, отпущена ли клавиша)
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
    
    call LCD_one	    ; Отрисовка первой строки
    call delay_one_sec		; задержка пока на 1сек
    goto change_time
    
    ;----------------------------------------
correct_T_plus			; функция типа switch для ввода отдельных символов(инкремент или прибавление)
    movlw 0x1			;Задержка для борьбы с дребезгом контактов
    call delay				
    call Keyboard		;опрос клавиатуры что бы выяснить
    movf Cnt,1			;отжата клавиша или нет
    btfss STATUS,Z		;если нет, то циклим
    goto correct_T_plus		    
    movlw 0x1			; если NumPressKey = 1, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H2
    
    movlw 0x2			; если NumPressKey = 2, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H1

    movlw 0x3			; если NumPressKey = 3, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M2
    
    movlw 0x4			; если NumPressKey = 4, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M1
    
    movlw 0x5			; если NumPressKey = 5, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_S2
    
    movlw 0x6			; если NumPressKey = 6, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S1.
    btfsc STATUS, 0x02		; если нет, выходим из функции
    call correct_S1
    
    return
    
    ;----------------------------------------
    
correct_H2			; функцию коррекции переменной H2.
    incf TIME_HH2,1		; инкремент переменной Н2
    movlw 0x33			; Если !=3, переходим обратно в функцию
    xorwf TIME_HH2, w		; correct_T_plus и проверяем там следующее условие
    btfss STATUS, 0x02
    goto return_COR_H2
    movlw 	0x30		; Если переменная = 3, то обнуляем ее, т.к. в сутках 2 десятка часов
    movwf	TIME_HH2
return_COR_H2
    return			; и идем обратно в correct_T_plus и проверяем там следующее условие
    
correct_H1			; функцию коррекции переменной H1.
    incf TIME_HH1,1		; инкремент переменной Н1
    movlw 0x32			; Если = 2, переходим в функцию three_H1, которая служит для 
    xorwf TIME_HH2, w		; корректной задачи времени, т.к. 18 часов может быть, а 28 нет, то надо
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
    movlw 0x1			;Задержка для борьбы с дребезгом контактов	
    call delay				
    call Keyboard		;опрос клавиатуры что бы выяснить
    movf Cnt,1			;отжата клавиша или нет
    btfss STATUS,Z		;если нет, то циклим
    goto correct_T_minus		  
    movlw 0x1			; если NumPressKey = 1, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H2_minus
    
    movlw 0x2			; если NumPressKey = 2, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной Н1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_H1_minus

    movlw 0x3			; если NumPressKey = 3, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M2_minus
    
    movlw 0x4			; если NumPressKey = 4, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной M1.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_M1_minus
    
    movlw 0x5			; если NumPressKey = 5, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S2.
    btfsc STATUS, 0x02		; если нет, проверяем следующее условие
    call correct_S2_minus
    
    movlw 0x6			; если NumPressKey = 6, то вызываем
    xorwf NumPressKey, w;	; функцию коррекции переменной S1.
    btfsc STATUS, 0x02		; если нет, выходим из функции
    call correct_S1_minus
    
    return
    ;----------------------------------------
    
correct_H2_minus		; функцию коррекции переменной H2.
    decf TIME_HH2,1		; декремент переменной Н2
    movlw 0x2f			; Если !=2f, переходим обратно в функцию
    xorwf TIME_HH2, w		; correct_T_ и проверяем там следующее условие
    btfss STATUS, 0x02
    goto return_COR_H2_MIN
    movlw 	0x32		; Если переменная = 2f, то присваиваем ей значение 2, т.к. в сутках 2 десятка часов
    movwf	TIME_HH2
return_COR_H2_MIN
    return			; и идем обратно в correct_T_ и проверяем там следующее условие
    
correct_H1_minus		; функцию коррекции переменной H1.
    decf TIME_HH1,1		; декремент переменной Н1
    movlw 0x2f			; Если != 2f, переходим обратно в функцию 
    xorwf TIME_HH1, w		; correct_T_ и проверяем там следующее условие
	    				
    btfss STATUS, 0x02
    goto return_COR_H1_MIN		
    movlw 0x32			; если переменная = 2, то при достижении 2f будем присваивать Н1 = 3.
    xorwf TIME_HH2, w	
    btfsc STATUS, 0x02
    goto three_H1_minus
    movlw 	0x39		; если переменная != 2, то при достижении 2f будем присваивать Н1 = 9. 
t2  movwf	TIME_HH1
return_COR_H1_MIN
    return
    
three_H1_minus
    movlw 0x33			; значение для присваивания при Н2 = 2.
    goto t2			; возврат к метке t2 для продолжения корректной работы
    
correct_M2_minus		; функцию коррекции переменной M2.
    decf TIME_MM2,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 5
    xorwf TIME_MM2, w;
    btfss STATUS, 0x02
    goto return_COR_M2_MIN
    movlw 	0x35
    movwf	TIME_MM2
return_COR_M2_MIN
    return
    
correct_M1_minus		; функцию коррекции переменной M1.
    decf TIME_MM1,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 10
    xorwf TIME_MM1, w;
    btfss STATUS, 0x02
    goto return_COR_M1_MIN
    movlw 	0x39
    movwf	TIME_MM1
return_COR_M1_MIN
    return
    
correct_S2_minus		; функцию коррекции переменной S2.
    decf TIME_SS2,1
    movlw 0x2f			; Работает так же, только при достижении 2f присваивается 5
    xorwf TIME_SS2, w;
    btfss STATUS, 0x02
    goto return_COR_S2_MIN
    movlw 	0x35
    movwf	TIME_SS2
return_COR_S2_MIN
    return
    
correct_S1_minus		; функцию коррекции переменной S1.
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
    movlw 0x1			;Задержка для борьбы с дребезгом контактов
    call delay			
    call Keyboard		;опрос клавиатуры что бы выяснить
    movf Cnt,1			;отжата клавиша или нет
    btfss STATUS,Z		;если нет, то циклим
    goto save_T
    movlw 0x6			; если происходит переполнение NumPressKey
    xorwf NumPressKey, w	; значит время заданно корректно во всех ячейках
    btfsc STATUS, 0x02		; и мы переходим в функцию записи переменных значений
    goto START			; в постоянные
    incf NumPressKey,1		; Если NumPressKey не переполнен, то инкрементируем
    goto change_time		; его и возвращаемся в функцию изменения времени
    
change_HMS
    movlw 0x1				
    call delay			;Задержка для борьбы с дребезгом контактов
    call Keyboard		;опрос клавиатуры что бы выяснить
    movf Cnt,1			;отжата клавиша или нет
    btfss STATUS,Z		;если нет, то циклим
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
    
change_day			; функция изменения дня недели
    call Keyboard
    btfsc Key1,0
    goto plus_day_ch		; если нажали кнопку 1 переходим в функцию, которая инкрементирует выбранное число (inc)
    btfsc Key2,0
    goto minus_day_ch		; если нажали кнопку 2 переходим в функцию, которая декрементирует выбранное число (dec)
    btfsc Key3,0		; если нажали кнопку 3 переходим в функцию, которая сохраняет результат
    goto save_end_day
    btfsc Key4,0		; если нажали кнопку 4 переходим в функцию, которая отменяет все изменения
    goto save_day_ch
    
    call LCD_one		; Отрисовка первой строки на дисплее
    call delay_one_sec		; задержка пока на 1сек
    goto change_day
    
plus_day_ch
    movlw 0x1				
    call delay			;Задержка для борьбы с дребезгом контактов
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
    movlw 0x1				
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
    movlw 0x1				
    call delay				;задержка крч
    call Keyboard			;опрос клавиатуры что бы выяснить
    movf Cnt,1				;отжата клавиша или нет
    btfss STATUS,Z			;если нет, то циклим
    goto save_day_ch
    movfw TEMP_DAY
    movwf DAY
    goto START
    
save_end_day
    movlw 0x1				
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
    
    call delay_one_sec		; задержка пока на 1сек
    goto change_alarm
    
    ;----------------------------------------
    
correct_A_plus			; функция типа switch для ввода отдельных символов(инкремент или прибавление)
    movlw 0x1				
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
    movlw 0x1				
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
    movlw 0x1				
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
    movlw 0x1				
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