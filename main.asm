
%include "macros.mac"

section .data

    ; Сообщения об ошибке
    rndGen      db      "-n",0
    fileGen     db      "-f",0
    errMessage1 db      "incorrect command line!", 10,"  Waited:",10
                db      "     command -f infile outfile01 outfile02",10,"  Or:",10
                db      "     command -n number outfile01 outfile02",10,0
    errMessage2 db      "incorrect qualifier value!", 10,"  Waited:",10
                db      "     command -f infile outfile01 outfile02",10,"  Or:",10
                db      "     command -n number outfile01 outfile02",10,0

    ; Количество элементов в массиве
    len         dq      0

section .bss
    num         resq    1       ; Сюда запишем количество фильмов
    mean        rest    1       ; А сюда - среднее значение
    start       resq    1       ; начало отсчета времени
    delta       resq    1       ; интервал отсчета времени
    startTime   resq    2       ; начало отсчета времени
    endTime     resq    2       ; конец отсчета времени
    deltaTime   resq    2       ; интервал отсчета времени
    ifst        resq    1       ; указатель на файл, открываемый файл для чтения фильмов
    ofst1       resq    1       ; указатель на файл, открываемый файл для записи считанных фильмов
    ofst2       resq    1       ; указатель на файл, открываемый файл для записи периметра
    cont        resb    1100000 ; Массив используемый для хранения данных

section .text
    global main
main:
push rbp
mov rbp,rsp

    mov     r12,    rdi             ; Количество аргуметов
    mov     r13,    rsi             ; Ссылка на начало аргументов

    cmp     r12,    5               ; Проверка количества аргументов
    je      .hasfiveargs
    PrintStrBuf errMessage1, [stdout]
    jmp     .return

.hasfiveargs:
    ; Проверка второго аргумента
    mov     rdi,    rndGen          ; Случай "-r"
    mov     rsi,    [r13+8]         ; Второй аргумент командной строки
    call    CmpString
    cmp     rax,    1
    je      .random
    
    mov     rdi,    fileGen         ; Случай "-f"
    mov     rsi,    [r13+8]         ; Второй аргумент командной строки
    call    CmpString
    cmp     rax,    1 
    je      .fromfile
    
    ; Если ни один не совпал - выводим сообщение об ошибке
    PrintStrBuf errMessage2, [stdout]
    jmp     .return

.random:
    ; Генерация случайных фигур
    mov     rdi,    [r13+16]        ; Получаем количество
    call    atoi
    mov     [num],  rax

    mov     rax,    [num]           ; Проверяем ограничения
    cmp     rax,    1
    jl      .incorrectnumber
    cmp     eax,    10000
    jg      .incorrectnumber

    ; Начальная установка генератора случайных чисел
    xor     rdi,    rdi
    xor     rax,    rax
    call    time
    mov     rdi,    rax
    xor     rax,    rax
    call    srand

    ; Заполнение контейнера случайными фигурами
    mov     rdi, cont               ; Передача адреса контейнера
    mov     rsi, len                ; Передача адреса для длины
    mov     rdx, [num]              ; Передача количества порождаемых фигур
    call    InRndContainer
    jmp     .maintask

.fromfile:
    ; Получение фигур из файла
    FileOpen [r13+16], "r", ifst

    ; Заполнение контейнера фигурами из файла
    mov     rdi, cont               ; Адрес контейнера
    mov     rsi, len                ; Адрес для установки числа элементов
    mov     rdx, [ifst]             ; Указатель на файл
    xor     rax, rax
    call    InContainer             ; Ввод данных в контейнер
    FileClose [ifst]

.maintask:

    ; Вывод содержимого контейнера в файл
    FileOpen [r13+24], "w", ofst1
    PrintStrLn "Filled container:", [ofst1]
    PrintContainer cont, [len], [ofst1]
    FileClose [ofst1]

    ; Вычисление времени старта
    mov     rax,    228
    xor     rdi,    rdi
    lea     rsi,    [startTime]
    syscall

    ContainerSort cont, [len]       ; Делаем сортировку контейнера
    GetMean cont,   [len]           ; Получаем среднее и сохраняем
    movsd   [mean], xmm0


    ; Вычисление времени завершения
    mov     rax,    228
    xor     edi,    edi 
    lea     rsi,    [endTime]
    syscall

    ; Получение времени работы
    mov     rax,    [endTime]
    sub     rax,    [startTime]
    mov     rbx,    [endTime+8]
    mov     rcx,    [startTime+8]
    cmp     rbx,    rcx
    jge     .subNanoOnly

    ; Если время конца меньше времени начала(в нанносекундах), то занимаем секунду
    dec     rax
    add     rbx,    1000000000

.subNanoOnly:
    sub     rbx,    [startTime+8]
    mov     [deltaTime], rax
    mov     [deltaTime+8], rbx
    
    ; Вывод времени рассчета в консоль
    PrintStr "Calculaton time = ", [stdout]
    PrintLLUns [deltaTime], [stdout]
    PrintStr " sec, ", [stdout]
    PrintLLUns [deltaTime+8], [stdout]
    PrintStr " nsec", [stdout]
    PrintStr 10, [stdout]
    
    ; Вывод среднего арифметического, времени рассчета и контейнера в файл
    ; То же самое в файл (+ контейнер)
    FileOpen [r13+32], "w", ofst2
    PrintContainer cont, [len], [ofst2]

    PrintStr "Arithmetic mean of all parameters = ", [ofst2]
    PrintDouble [mean], [ofst2]
    PrintStr 10, [ofst2]

    PrintStr "Calculaton time = ", [ofst2]
    PrintLLUns [deltaTime], [ofst2]
    PrintStr " sec, ", [ofst2]
    PrintLLUns [deltaTime+8], [ofst2]
    PrintStr " nsec", [ofst2]
    PrintStr 10, [ofst2]
    FileClose [ofst2]

    jmp .return

.incorrectnumber:
    PrintStr "incorrect numer of figures = ", [stdout]
    PrintInt [num], [stdout]
    PrintStrLn ". Set 0 < number <= 10000", [stdout]
.return:
leave
ret
