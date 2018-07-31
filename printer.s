        global printer
        extern resume
        extern WorldLength, WorldWidth, WorldSize, state, newline

        ;; /usr/include/asm/unistd_32.h
sys_write:      equ   4
stdout:         equ   1

%macro print_char 2
        pushad
        mov eax, sys_write
        mov ebx, %1
        mov ecx, %2
        mov edx, 1
        int 0x80
        popad
%endmacro

%macro print_newline 0
        print_char stdout, newline
%endmacro

section .data
        char_to_print: db 0
section .bss

section .text

printer:
        mov esi, 0
        mov edi, 0
        mov eax, [WorldLength]
        imul dword [WorldWidth]
        mov [WorldSize], eax
.print_loop:
        cmp esi, [WorldSize]
        jge .end
        cmp edi, [WorldWidth]
        jl .no_newline
        print_newline
        mov edi, 0
.no_newline:
        mov ecx, [state]                ; convert state byte to char
        mov ecx, [ecx+esi]
        mov byte [char_to_print], cl
        add byte [char_to_print], '0'
        print_char stdout, char_to_print

        inc esi
        inc edi
        jmp .print_loop

.end:
        print_newline

        xor ebx, ebx
        call resume             ; resume scheduler

        jmp printer
