

; Функция получения параметра фильма
global ParameterMovie
ParameterMovie:
section .bss
    
    .year   resq    1
    
section .text
push rbp
mov rbp, rsp

    cvtsi2sd xmm0,  [rdi]           ; Считываем и сохраняем год
    movsd   [.year], xmm0
    add     rdi,    8
    call    StrLength               ; Получаем длину названия
    cvtsi2sd xmm1,  rax
    movsd   xmm0,   [.year]
    divsd   xmm0,   xmm1            ; Получаем результат в xmm0

leave
ret



; Функция получения длины строки
global StrLength
StrLength:
section .text
push rbp
mov rbp, rsp

    mov     rax,    0               ; rax = 0
.cycle:                             ; while
    cmp     byte[rdi], 0            ; [rdi] != \0
    je      .break
    inc     rax                     ; rax++, [rdi++]
    inc     rdi
    jmp     .cycle
.break:                             ; Результат в rax

leave
ret



; Функция копирования строки
global CopyStr
CopyStr:
section .text
push rbp
mov rbp, rsp

.cycle:
    mov     al,     [rsi]           ; Копируем символ
    mov     [rdi],   al
    cmp     byte[rsi], 0            ; Если скопировали 0 - выходим
    je      .break
    inc     rsi                     ; rsi++, rdi++
    inc     rdi
    jmp     .cycle
.break:

leave
ret



; Функция сравнения строк
global CmpString
CmpString:
section .bss

    .addr1  resq    1               ;  Адреса строк
    .addr2  resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr1], rdi           ; Сохраняем адреса строк
    mov     [.addr2], rsi

.cycle:
    mov     rax,    [.addr1]        ; Проверяем, закончилась ли одна из строк
    cmp     byte[rax], 0
    je      .break

    mov     rax,    [.addr2]
    cmp     byte[rax], 0
    je      .break                  ; Если да - выходим из цикла

    mov     rax,    [.addr1]        ; Проверяем, равны ли символы
    mov     rbx,    [.addr2]
    mov     cl,     byte[rax]
    cmp     cl,     byte[rbx]
    jne     .return0                ; Если нет - возвращаем false

    inc     qword[.addr1]           ; Переходим к следующей паре
    inc     qword[.addr2]
    jmp     .cycle

.break:
    mov     rax,    [.addr1]        ; Сравниваем последние два символа на равенство
    mov     rbx,    [.addr2]
    mov     cl,     byte[rax]
    jne     .return0                ; Если не равны - возвращаем false
    mov     rax,    1
    jmp     .return
.return0:
    mov     rax,    0
.return:

leave
ret



; Фунция копирования фильма
global CopyMovie
CopyMovie:
section .bss

    .addr1 resq    1
    .addr2 resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr1], rsi             ; Сохраняем адреса
    mov     [.addr2], rdi

    xor     rax,    rax
    mov     eax,    [rsi]             ; Переносим год и тип
    mov     [rdi],  eax
    mov     eax,    [rsi+4]
    mov     [rdi+4], eax

    add     rsi,    8                 ; Переносим название
    add     rdi,    8
    call    CopyStr
    

    mov     rsi,    [.addr1]          ; Восстанавливаем адреса
    mov     rdi,    [.addr2]
    xor     rax,    rax
    mov     eax,    [rsi + 4]         ; Сохраняем в rax номер типа
    add     rsi,    59                ; Переходим к информации о фильме
    add     rdi,    59
    

    cmp     rax,    1                 ; Если тип - игровой, то копируем строку, а иначе - число
    jne     .intcopy
    call    CopyStr
    jmp     .return

.intcopy:
    mov     rax,    [rsi]
    mov     [rdi],  rax

.return:

leave
ret



; Функция получения среднего значения параметра
global GetArithmeticMean
GetArithmeticMean:
section .bss
    .sum    rest    1
    .addr   resq    1
    .len    resq    1
    .i      resq    1
section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.len], rsi
    
    mov     qword[.i], 0            ; for i = 0
.cycle:                             ; i != len
    mov     rax,    [.i]
    cmp     rax,    [.len]
    je      .break
    
    mov     rdi,    [.addr]         ; Переходим по адресу очередного фильма
    mov     rax,    [.i]
    imul    rax,    110
    add     rdi,    rax
    
    call ParameterMovie             ; Получаем параметр, приписываем к сумме
    addsd xmm0, [.sum]
    movsd [.sum], xmm0
    inc qword[.i]
    jmp .cycle
.break:

    movsd xmm0, [.sum]              ; Вычисляем частное в xmm0
    cvtsi2sd xmm1, [.len]
    divsd xmm0, xmm1

leave
ret



; Функция сортировки контейнера с фильмами
global SortContainer
SortContainer:
section .bss

    .buff   resb    110
    .cont   resq    1
    .len    resq    1
    .i      resq    1
    .j      resq    1
    .l      resq    1
    .r      resq    1
    .m      resq    1
    .tmpsd  rest    1

section .text
push rbp
mov rbp, rsp


    mov     [.cont], rdi             ; Переносим аргументы в память
    mov     [.len], rsi


    mov     qword[.i], 0             ; int i = 0
.maincycle:                          ; for

    mov     rax,     [.i]
    cmp     rax,     [.len]          ; if i == len
    jae .mainbreak                   ; break

    mov qword[.l], 0                 ; l = 0
    mov rax, [.i]
    mov [.r], rax                    ; r = i

.internalcycle:                      ; while
    mov     rax,    [.r]
    cmp     rax,    [.l]             ; if r <= l
    jbe     .internalbreak           ; break

    mov     rax,    [.l]
    add     rax,    [.r]
    sar     rax,    1
    mov     [.m],   rax              ; m = (l + r) / 2

    mov     rdi,    [.cont]          ; Обновляем rdi
    mov     rax,    [.i]
    imul    rax,    110
    add     rdi,    rax              ; rdi = cont[i]
    call    ParameterMovie
    movsd   [.tmpsd], xmm0           ; Сохраняем параметр

    mov     rdi,    [.cont]          ; Обновляем rdi
    mov     rax,    [.m]
    imul    rax,    110
    add     rdi,    rax              ; rdi = cont[m]
    call    ParameterMovie           ; xmm0 = ParameterMovie(cont[m])
    movsd   xmm1,   [.tmpsd]         ; xmm1 = ParameterMovie(cont[i])

    comisd  xmm1,   xmm0             ; if ParameterMovie(cont[i]) < ParameterMovie(cont[m])
    jb      .isless
    mov     rax,    [.m]
    inc     rax
    mov     [.l],   rax              ; l = m + 1
    jmp     .internalcycle
.isless:
    mov     rax,    [.m]
    mov     [.r],   rax              ; r = m
    jmp     .internalcycle           ; Возвращаемся в начало цикла

.internalbreak:
    
    mov     rdi,    .buff            ; Передаем первый аргумент
    mov     rsi,    [.cont]          ; Передаем второй аргумент
    mov     rax,    [.i]             ; rax = i
    imul    rax,    110              ; rax = i * movie_size
    add     rsi,    rax              ; rsi = c + i * movie_size
    call    CopyMovie                ; Сохраняем фильм в буфер


    mov     rax,    [.i]
    dec     rax
    mov     [.j],   rax              ; j = i - 1
    
.additionalcycle:                    ; for
    mov     rax,    [.j]
    cmp     rax,    [.l]             ; if j < l
    jl      .additionalbreak         ; break
    
    mov     rax,    [.j]             ; rax = j
    imul    rax,    110              ; rax = j * movie_size
    
    mov     rdi,    [.cont]          ; Передаем первый аргумент
    mov     rsi,    [.cont]          ; Передаем второй аргумент
    add     rdi,    rax              ; rdi = c + j * movie_size
    add     rsi,    rax              ; rsi = c + j * movie_size
    add     rdi,    110              ; rdi = c + (j + 1) * movie_size
    
    call    CopyMovie                ; Копируем фильм

    dec     qword[.j]                ; j--
    jmp     .additionalcycle

.additionalbreak:
    mov     rdi,    [.cont]          ; Передаем первый аргумент
    mov     rax,    [.l]             ; rax = l
    imul    rax,    110              ; rdx = l * movie_size
    add     rdi,    rax
    mov     rsi,    .buff            ; Передаем второй аргумент
    call    CopyMovie                ; Копируем фильм из буфера
    inc     qword[.i]                ; i++
    jmp     .maincycle


.mainbreak:
leave
ret

