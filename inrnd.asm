    extern rand


; Функция генерации случайного мультфильма
global InRndCartoon
InRndCartoon:
section .data

    .four   dq  4

section .bss

    .addr   resq    1

section     .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем адрес

    xor     rax,    rax
    call    rand
    xor     rdx,    rdx
    idiv    qword[.four]
    inc     rdx                     ; rdx = [1, 4]

    mov     rax,    [.addr]         ; Записываем
    mov     [rax],  edx

leave
ret



; Функция генерации случайного докуметального фильма
global InRndDocumentary
InRndDocumentary:
section .data

    .fivehundred dq 500

section .bss

    .addr   resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr],    rdi         ; Сохраняем адрес

    xor     rax,    rax
    call    rand
    xor     rdx,    rdx
    idiv    qword[.fivehundred]
    inc     rdx                     ; rdx = [1, 500]

    mov     rax,    [.addr]         ; Записываем
    mov     [rax],  edx

leave
ret



; Функция генерации случайного игрового фильма
global InRndScreenplay
InRndScreenplay:
section .data

    .maxlen dq      50
    .alphsize dq    26

section .bss

    .addr   resq    1
    .i      resq    1
    .len    resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем адрес
    mov     rax, [.maxlen]
    mov     [.len], rax
    dec     qword[.len]

    xor     rax,    rax
    call    rand
    xor     rdx,    rdx
    idiv    qword[.len]
    mov     [.i],   rdx             ; i = [0, 48]
    inc     rdx                     ; rdx = [1, 50]

    mov     rax,    [.addr]
    add     rax,    rdx
    mov     byte[rax], 0            ; Обозначаем конец строки

.cycle:                             ; Генерация имени режиссера
    cmp     qword[.i], 0            ; if i < 0
    jl      .break                  ; break

    xor     rax,    rax
    call rand
    xor     rdx,    rdx
    idiv    qword[.alphsize]
    mov     rax,    97
    add     rax,    rdx               ; rax = ['a', 'z']

    mov     rbx,    [.addr]
    add     rbx,    [.i]              ; rbx указывает на букву
    mov     byte[rbx], al             ; [rbx] = ['a', 'z']
    dec     qword[.i]                 ; i--
    jmp     .cycle
.break:

leave
ret



; Общая генерации случайного фильма
global InRndMovie
InRndMovie:
section .data
    .maxlen dq      50
    .maxyear dq     2021
    .minyear dq     1800
    .typen  dq      3
    .alphsize dq    26
section .bss

    .addr   resq    1
    .i      resq    1
    .type   resq    1
    .len    resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi                ; Сохраняем адрес
    mov     rax,    [.maxlen]
    mov     [.len], rax                 ; Уменьшаем случайную длину на 1 для удобства
    dec     qword[.len]

; Устанавливаем год
    xor     rax,    rax                 ; Выполняем rand, результат в rax
    call    rand
    mov     rbx,    [.maxyear]          ; Считаем диапазон годов
    sub     rbx,    [.minyear]
    xor     rdx,    rdx                 ; Получаем случайный параметр в rdx
    idiv    rbx
    add     rdx,    [.minyear]          ; Вычисляем и записываем год
    mov     rax,    [.addr]
    mov     [rax],  edx

; Устанавливаем тип
    xor     rax,    rax                 ; Выполняем rand, результат в rax
    call    rand
    xor     rdx,    rdx                 ; Получаем случайный параметр в rdx
    idiv    qword[.typen]
    inc     rdx                         ; Вычисляем, запоминаем и записываем тип
    mov     [.type], rdx
    mov     rax,    [.addr]
    add     rax,    4
    mov     [rax],  edx

; Устанавливаем имя

    xor     rax,    rax                 ; Выполняем rand, результат в rax
    call    rand
    xor     rdx,    rdx                 ; Получаем случайный параметр в rdx
    idiv    qword[.len]                 ; rdx = [0, 49]
    mov     [.i],   rdx                 ; i = rdx
    inc     rdx                         ; rdx = [1, 50]
    mov     rax,    [.addr]             ; Обозначаем конец строки
    add     rax,    8
    add     rax,    rdx
    mov     byte[rax], 0
.cycle:                                 ; Цикл записывающий имя
    cmp     qword[.i], 0                ; if i < 0
    jl      .break                      ; break
    xor     rax,    rax                 ; Выполняем rand, результат в rax
    call    rand
    xor     rdx,    rdx
    idiv    qword[.alphsize]            ; rdx = [0, 25]
    mov     rax,    97                  ; rax = 'a'
    add     rax,    rdx                 ; rax = ['a', 'z']
    mov     rbx,    [.addr]
    add     rbx,    8
    add     rbx,    [.i]                ; rbx указывает на букву
    mov     byte[rbx], al               ; [rbx] = ['a', 'z']
    dec     qword[.i]                   ; i--
    jmp     .cycle
.break:

; В зависимости от типа записываем данные
    mov     rdi,    [.addr]
    add     rdi,    59
    cmp     qword[.type], 1
    je      .screenplay
    cmp     qword[.type], 2
    je      .cartoon
    cmp     qword[.type], 3
    je      .documentary

.screenplay:
    call    InRndScreenplay
    jmp     .return
.cartoon:
    call    InRndCartoon
    jmp     .return
.documentary:
    call    InRndDocumentary
    jmp     .return
.return:
leave
ret



; Функция случайной генерации всего контейнера
global InRndContainer
InRndContainer:
section .bss

    .addr   resq    1
    .len    resq    1
    .size   resq    1
    .i      resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi                ; Сохраняем данные
    mov     [rsi],  rdx                 ; Сразу записываем len
    mov     [.size], rdx
    mov     qword[.i], 0                ; for i = 0
.cycle:
    mov     rax,    [.i]
    cmp     rax,    [.size]             ; i != size
    je      .break

    mov     rax,    [.i]                ; Генерируем очередной фильм
    imul    rax,    110
    mov     rdi,    [.addr]
    add     rdi,    rax
    call    InRndMovie
    inc     qword[.i]                   ; i++
    jmp     .cycle

.break:
leave
ret

