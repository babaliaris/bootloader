[bits 16]
[org 0x7c00]

;Initialize the stack.
cli
mov bp, 0x7e00 ;This is the address where the 512 bootloader ends.
add bp, 50000  ;Set the bp and sp 50kb above the bootloader.
mov sp, bp     ; Finally we have 50kb stack.
sti

;Clear all the segment registers.
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax

;Print a static string.
mov bx, hello_world
call print_static

;Push a string into the stack and print it.
push 'd'   ;Push the first character.
mov si, sp ;Store the beggining of the string.
push 'y'
push 'n'
push 'a'
push 'm'
push 'i'
push 'c'
push 0     ;End the string.
call print_dynamic
add sp, 16 ;Deallocate the string.

jmp $


;Get a null terminated character stored in the data segment and print it.
;[in] : bx (Pointer at the beggining of the string)
;[out]: void
print_static:

    ;Save all general purpose registers.
    pusha
    
    ;Bios function for int 0x10 to print a char to the screen.
    mov ah, 0x0e
    
    ;Print while loop.
    print_static_while:
        mov al, [bx] ;copy the current character to al.
        cmp al, 0 ;if its zero
        je print_static_end ;stop;
        int 0x10 ;else print al to the screen.
        add bx, 1;go to the next character.
        jmp print_static_while ;start again.


    ;exit print_static
    print_static_end:

        ;Retrieve all general purpose registers.
        popa
        ret


;Get a null terminated character stored in the stack and print it.
;[in] : si (the beggining of the string)
;[out]: void
print_dynamic:
    
    pusha

    print_dynamic_while:
        mov ax, [si] ;copy the current character to al.
        mov ah, 0x0e ;bios print char
        cmp al, 0 ;if its zero
        je print_dynamic_end ;stop;
        int 0x10 ;else print al to the screen.
        sub si, 2;go to the next character.
        jmp print_dynamic_while ;start again.       

    print_dynamic_end:
        popa
        ret


;Data
hello_world: db "Hello World!", 0


;Padding the remaining space with 0s and the magic number.
times 510-($-$$) db 0x0000
dw 0xaa55
