    extern fscanf
    extern StrLength
    extern CmpString
    extern CopyStr


; Функция ввода игрового фильма
global InScreenplay
InScreenplay:
section .data
    .fmt    db      "%s", 0
section .bss

    .file   resq    1
    .addr   resq    1
    .line   resb    256

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.file], rsi
    mov     byte[.line], 0

    mov     rdi,    [.file]         ; Считываем
    mov     rsi,    .fmt
    mov     rdx,    .line
    mov     rax,    0
    call    fscanf

    mov     rdi,    .line           ; Проверяем, входит ли строка в диапазон (0, 50]
    call    StrLength
    cmp     rax,    0
    je      .returnfalse
    cmp     rax,    50
    ja      .returnfalse

    mov     rdi,    [.addr]         ; Записываем
    mov     rsi,    .line
    call    CopyStr
    mov     rax,    1
    jmp     .return
.returnfalse:
    mov     rax,    0
.return:

leave
ret


; Функция ввода документального фильма
global InDocumentary
InDocumentary:
section .data

    .fmt    db      "%d", 0

section .bss

    .file   resq    1
    .addr   resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.file], rsi

    mov     rdi,    [.file]         ; Записываем длительность
    mov     rsi,    .fmt
    mov     rdx,    [.addr]
    mov     rax,    0
    call    fscanf

    mov     rax,    1
.return:

leave
ret



; Функция ввода мультфильма
global InCartoon
InCartoon:
section .data

    .fmt    db      "%s", 0
    .drawn  db      "drawn", 0
    .pupped db      "pupped", 0
    .plasticine db  "plasticine", 0
    .anime  db      "anime", 0

section .bss

    .file   resq    1
    .addr   resq    1
    .str    resb    256

section .text
push    rbp
mov     rbp,    rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.file], rsi

    mov     rdi,    [.file]         ; Считываем тип
    mov     rsi,    .fmt
    mov     rdx,    .str
    mov     rax,    0
    call    fscanf

    mov     rdi,    .str            ; Сравниваем с шаблонами
    mov     rsi,    .drawn
    call    CmpString
    cmp     rax,    1
    je      .drawncase
    mov     rdi,    .str
    mov     rsi,    .pupped
    call    CmpString
    cmp     rax,    1
    je      .puppedcase
    mov     rdi,    .str
    mov     rsi,    .plasticine
    call    CmpString
    cmp     rax,    1
    je      .plasticinecase
    mov     rdi,    .str
    mov     rsi,    .anime
    call    CmpString
    cmp     rax,    1
    je      .animecase
    jmp     .falsecase              ; Если не нашли, возвращаем ноль

.drawncase:                         ; В зависимости от совпавшего шаблона записываем тип
    mov     rax,    [.addr]
    mov     dword[rax], 1
    jmp     .return1
.puppedcase:
    mov     rax,    [.addr]
    mov     dword[rax], 2
    jmp     .return1
.plasticinecase:
    mov     rax,    [.addr]
    mov     dword[rax], 3
    jmp     .return1
.animecase:
    mov     rax,    [.addr]
    mov     dword[rax], 4
    jmp     .return1
.falsecase:
    mov     rax,    0
    jmp     .return0
.return1:
    mov     rax,    1
.return0:

leave
ret



; Общая функция ввода фильма
global InMovie
InMovie:
section .data

    .fmt db "%d%s%s", 0
    .screenplay db "screenplay", 0
    .cartoon db "cartoon", 0
    .documentary db "documentary", 0

section .bss

    .file   resq    1
    .addr   resq    1
    .type   resb    256
    .name   resb    256

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.file], rsi
    mov     byte[.name], 0

    mov     rdi,    [.file]         ; Считываем год, тип и имя
    mov     rsi,    .fmt
    mov     rdx,    [.addr]
    mov     rcx,    .name
    mov     r8,     .type
    xor     rax,    rax
    call    fscanf
    
    mov    rdi, [.addr]             ; Проверяем год на корректность
    cmp    dword[rdi], 1800
    jb     .return0
    cmp    dword[rdi], 2021
    ja     .return0

    mov     rdi,    .name           ; Проверяем длину строки на корректность
    call    StrLength
    cmp     rax,    0
    je      .return0
    cmp     rax,    50
    ja      .return0
    mov     rdi,    [.addr]
    add     rdi,    8
    mov     rsi,    .name           ; И записываем имя
    call    CopyStr

    mov     rdi,    .type           ; Сравниваем тип с шаблонами
    mov     rsi,    .screenplay
    call    CmpString
    cmp     rax,    1
    je      .screenplaycase

    mov     rdi,    .type
    mov     rsi,    .cartoon
    call    CmpString
    cmp     rax,    1
    je      .cartooncase

    mov     rdi,    .type
    mov     rsi,    .documentary
    call    CmpString
    cmp     rax,    1
    je      .documentarycase
    jmp     .return0                ; Не нашли нужный тип? Возвращаем ноль!

.screenplaycase:                    ; В зависимости от типа записываем его код
    mov     rax,    [.addr]
    add     rax,    4
    mov     dword[rax], 1
    mov     rdi,    [.addr]
    add     rdi,    59
    mov     rsi,    [.file]
    call    InScreenplay
    jmp     .returnresult

.cartooncase:
    mov     rax,    [.addr]
    add     rax,    4
    mov     dword[rax], 2
    mov     rdi,    [.addr]
    add     rdi,    59
    mov     rsi,    [.file]
    call    InCartoon
    jmp     .returnresult

.documentarycase:
    mov     rax,    [.addr]
    add     rax,    4
    mov     dword[rax], 2
    mov     rdi,    [.addr]
    add     rdi,    59
    mov     rsi,    [.file]
    call    InDocumentary
    jmp     .returnresult

.return0:
    mov     rax,    0
.returnresult:

leave
ret


; Функция ввода контейнера
global InContainer
InContainer:
section .bss

    .file   resq    1
    .addr   resq    1
    .len    resq    1

section .text
push rbp
mov rbp, rsp

    mov     [.addr], rdi            ; Сохраняем данные
    mov     [.len], rsi
    mov     [.file], rdx

.cycle:
    mov     rdi,    [.addr]         ; Считываем, пока данные корректны
    mov     rsi,    [.file]
    call    InMovie
    cmp     rax,    0
    je      .break
    add     qword[.addr], 110
    mov     rax,    [.len]
    inc     qword[rax]
    jmp     .cycle
.break:

leave
ret


