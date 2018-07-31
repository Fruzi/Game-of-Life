        global scheduler
        extern resume, end_co
        extern WorldSize

%define no_of_generations dword [ebp+8]
%define print_frequency dword [ebp+12]

section .data
        print_counter: dd 0
        gen_counter: dd 0
        two_int_format: db "%d, %d", 10, 0

section .text

scheduler:
        push ebp
        mov ebp, esp
 
        mov ebx, 2
.next:
        mov eax, [WorldSize]
        add eax, 2
        cmp ebx, eax
        jl .check_print
        mov ebx, 2
        add dword [gen_counter], 1

        mov eax, no_of_generations
        add eax, no_of_generations
        cmp dword [gen_counter], eax
        jge .end

.check_print:
        mov eax, print_frequency
        cmp dword [print_counter], eax
        jl .resume

.print:
        push ebx
        mov ebx, 1
        call resume
        pop ebx
        mov dword [print_counter], 0

.resume:
        call resume

        inc ebx
        add dword [print_counter], 1
        loop .next

.end:
        mov ebx, 1
        call resume
        pop ebp
        call end_co             ; stop co-routines
