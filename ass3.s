        global main
        global WorldLength, WorldWidth, WorldSize, no_of_generations, print_frequency, state, newline
        extern init_co, start_co
        extern scheduler, printer, cell, strlen, itoa, positive_atoi


        ;; /usr/include/asm/unistd_32.h
rdonly:         equ   0
stderr:         equ   2
sys_exit:       equ   1
sys_read:       equ   3
sys_write:      equ   4
sys_open:       equ   5
sys_brk:        equ   45

%macro print_str 2
        pushad
        push %2
        call strlen
        add esp, 4

        mov edx, eax
        mov eax, sys_write
        mov ebx, %1
        mov ecx, %2
        int 0x80
        popad
%endmacro

%macro print_int 2
        pushad
        push %2
        call itoa
        add esp, 4
        mov ebx, eax

        push eax
        call strlen
        add esp, 4

        mov ecx, ebx
        mov edx, eax
        mov eax, sys_write
        mov ebx, %1
        int 0x80
        popad
%endmacro


%macro print_char 2
        pushad
        mov eax, sys_write
        mov ebx, %1
        mov ecx, %2
        mov edx, 1
        int 0x80
        popad
%endmacro

%macro print_newline 1
        print_char %1, newline
%endmacro

%macro set_int_var 2
        pushad
        push %2
        call positive_atoi
        add esp, 4
        mov dword [%1], eax
        popad
%endmacro

%macro debug_print 0
        pushad
        print_str stderr, debug_length
        print_int stderr, dword [WorldLength]
        print_newline stderr
        print_str stderr, debug_width
        print_int stderr, dword [WorldWidth]
        print_newline stderr
        print_str stderr, debug_gens
        print_int stderr, dword [no_of_generations]
        print_newline stderr
        print_str stderr, debug_print_freq
        print_int stderr, dword [print_frequency]
        print_newline stderr
        
        mov esi, 0
        mov edi, 0
        mov eax, [WorldLength]
        imul dword [WorldWidth]
        mov [WorldSize], eax
%%print_loop:
        cmp esi, [WorldSize]
        jge %%end
        cmp edi, [WorldWidth]
        jl %%no_newline
        print_newline stderr
        mov edi, 0
%%no_newline:
        mov ecx, [state]
        mov ecx, [ecx+esi]
        mov byte [char_to_print], cl
        add byte [char_to_print], '0'
        print_char stderr, char_to_print

        inc esi
        inc edi
        jmp %%print_loop

%%end:
        print_newline stderr
        popad
%endmacro

section .bss
        filename: resd 1
        fd: resd 1
        WorldLength: resd 1
        WorldWidth: resd 1
        WorldSize: resd 1
        no_of_generations: resd 1
        print_frequency: resd 1
        state: resd 1
        initial_break_addr: resd 1
        temp: resb 1 
        
section .rodata
        newline: db 10, 0
        debug_length: db "length=", 0
        debug_width: db "width=", 0
        debug_gens: db "number of generations=", 0
        debug_print_freq: db "print frequency=", 0

section .data
        debug: db 0
        char_to_print: db 0

section .text

main:
        push ebp
	mov ebp, esp

.args:
        mov ecx, [ebp + 4 + 1*4]    ; ecx = argc
        mov esi, [ebp + 4 + 2*4]    ; eax = argv

        mov edx, 1
        cmp ecx, 6
        je .args_cont
        mov eax, dword [esi + 4*edx]
        cmp word [eax], "-d"
        jne .exit
        mov byte [debug], 1
        inc edx

.args_cont:
        mov eax, dword [esi + 4*edx]
        mov dword [filename], eax
        inc edx

        set_int_var WorldLength, dword [esi + 4*edx]
        inc edx

        set_int_var WorldWidth, dword [esi + 4*edx]
        inc edx

        pushad
        mov eax, [WorldLength]
        imul dword [WorldWidth]
        mov [WorldSize], eax
        popad

        set_int_var no_of_generations, dword [esi + 4*edx]
        inc edx

        set_int_var print_frequency, dword [esi + 4*edx]
        
.cont:
        ;; allocate memory for state array
        mov eax, sys_brk             
        mov ebx, 0
        int 0x80
        mov [initial_break_addr], eax
        mov [state], eax
        mov ebx, eax
        add ebx, [WorldSize]
        mov eax, sys_brk
        int 0x80

        mov eax, sys_open       
        mov ebx, dword [filename]
        mov ecx, rdonly
        mov edx, 0111
        int 0x80
        mov [fd], eax

        mov esi, -1

.init_state_loop:
        inc esi
        cmp esi, [WorldSize]
        jge .state_loop_done
        mov eax, sys_read
        mov ebx, [fd]
        mov ecx, temp
        mov edx, 1
        int 0x80
        cmp byte [temp], 10
        je .newline
        cmp byte [temp], ' '
        je .space
        mov eax, dword [state]
        mov byte [eax+esi], 1
        jmp .init_state_loop
.newline:
        dec esi
        jmp .init_state_loop
.space:
        mov eax, dword [state]
        mov byte [eax+esi], 0
        jmp .init_state_loop

.state_loop_done:
        cmp byte [debug], 1
        jne .init_cors
        debug_print   

.init_cors:     
        xor ebx, ebx            ; scheduler is co-routine 0
        mov edx, scheduler
        call init_co            ; initialize scheduler state

        inc ebx                 ; printer i co-routine 1
        mov edx, printer
        call init_co            ; initialize printer state

        mov edi, [WorldSize]
        add edi, 2

.init_cells_loop:
        inc ebx
        cmp ebx, edi
        jge .start
        mov edx, cell
        pushad
        call init_co
        popad
        jmp .init_cells_loop

.start:
        xor ebx, ebx            ; starting co-routine = scheduler
        call start_co           ; start co-routines

.exit:
       ;; free allocated memory
        mov eax, sys_brk
        mov ebx, dword [initial_break_addr]
        int 0x80

        ;; exit
        mov eax, sys_exit
        xor ebx, ebx
        int 80h
