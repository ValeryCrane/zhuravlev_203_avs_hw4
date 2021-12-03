    extern fprintf
    extern ParameterMovie


; Функция вывода игрового фильма
global OutScreenplay
OutScreenplay:
section .data

    .fmt    db      " is screenplay, directed by %s", 10, 0

section .bss

    .addr   resq    1
    .file   resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем параметры
    mov     [.file], rsi

    mov     rdi,    [.file]         ; Записываем аргументы и выводим
    mov     rsi,    .fmt
    mov     rdx,    [.addr]
    mov     rax,    0
    call    fprintf

leave
ret



; Функция вывода мультфильма
global OutCartoon
OutCartoon:
section .data

    .fmt    db      " is cartoon, nature: %s", 10, 0
    .drawn  db      "drawn", 0
    .pupped db      "pupped", 0
    .plasticine db  "plasticine", 0
    .anime  db      "anime", 0

section .bss

    .addr   resq    1
    .file   resq    1
    .type   resd    1

section .text
push rbp
mov rbp, rsp

    mov     [.file], rsi            ; Сохраняем параметры
    mov     rax,    [rdi]
    mov     [.type], rax

    cmp     dword[.type], 1         ; Определяем тип мультфильма
    je      .drawncase
    cmp     dword[.type], 2
    je      .puppedcase
    cmp     dword[.type], 3
    je      .plasticinecase
    cmp     dword[.type], 4
    je      .aminecase

.drawncase:                         ; В зависимости от типа - выводим нужную строку
    mov     rdx,    .drawn
    jmp     .break
.puppedcase:
    mov     rdx,    .pupped
    jmp     .break
.plasticinecase:
    mov     rdx,    .plasticine
    jmp     .break
.aminecase:
    mov     rdx,    .anime
    jmp     .break
.break:
    mov     rdi,    [.file]
    mov     rsi,    .fmt
    mov     rax,    0
    call    fprintf

leave
ret



; Функция вывода документального фильма
global OutDocumentary
OutDocumentary:
section .data

    .fmt    db      " is documentary with duration %d min", 10, 0

section .bss

    .file   resq    1
    .time   resd    1

section .text
push rbp
mov rbp, rsp

    mov     eax,    dword[rdi]      ; Сохраняем параметры
    mov     [.time], eax
    mov     [.file], rsi

    mov     rdi,    [.file]               ; Записываем аргументы и выводим
    mov     rsi,    .fmt
    xor     rdx,    rdx
    mov     edx,    [.time]
    mov     rax,    0
    call fprintf

leave
ret



; Функция вывода любого фильма
global OutMovie
OutMovie:
section .data

    .fmt    db      "Parameter: %g; %d movie, named %s", 0

section .bss

    .addr   resq    1
    .file   resq    1
    .type   resd    1
    .tmpsd  rest    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем параметры
    mov     [.file], rsi
    mov     eax,    dword[rdi + 4]
    mov     [.type], eax

    call    ParameterMovie          ; Узнаем параметр фильма и сохраняем
    movsd   [.tmpsd], xmm0

    mov     rdi,    [.file]         ; Выводим общие для всех фильмов параметры
    mov     rsi,    .fmt
    mov     rax,    [.addr]
    xor     rdx,    rdx
    mov     edx,    dword[rax]
    mov     rcx,    [.addr]
    add     rcx,    8
    movsd   xmm0,   [.tmpsd]
    mov     rax,    1
    call    fprintf

    mov     rdi,    [.addr]         ; Определяем тип фильма
    add     rdi,    59
    mov     rsi,    [.file]
    cmp     dword[.type], 1
    je      .screenplaycase
    cmp     dword[.type], 2
    je      .cartooncase
    cmp     dword[.type], 3
    je      .documentarycase

.screenplaycase:                    ; В зависимости от типа вызываем нужную функцию
        call    OutScreenplay
        jmp     .break
.cartooncase:
        call    OutCartoon
        jmp     .break
.documentarycase:
        call    OutDocumentary
        jmp     .break
.break:

leave
ret





global OutContainer
OutContainer:
section .data

    .fmt    db      "Container contains %d elements.", 10, 0
    .sfmt   db      "%d: ", 0

section .bss

    .addr   resq    1
    .file   resq    1
    .len    resq    1
    .i      resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.file], rdx
    mov     [.len], rsi

    mov rdi, [.file]                ; Выводим данные о контейнере
    mov rsi, .fmt
    mov rdx, [.len]
    mov rax, 0
    call fprintf

    mov qword[.i], 0                ; for i = 0
.cycle:
    mov rax, [.i]                   ; if i == len then break
    cmp rax, [.len]
    je .break

    mov rdi, [.file]                ; Выводим номер фильма
    mov rsi, .sfmt
    mov rdx, [.i]
    mov rax, 0
    call fprintf
    

    mov rax, [.i]                   ; Выводим сам фильм
    imul rax, 110
    mov rdi, [.addr]
    add rdi, rax
    mov rsi, [.file]
    call OutMovie
    inc qword[.i]
    jmp .cycle
.break:

leave
ret

