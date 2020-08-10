[bits 16]
[org 0x7c00]

;Initialize the stack at 0x8000 above the bootloader memory.
;this is where the free space between the bios extended area
;and the bootloader area exists.
mov bp, 0x8000
mov sp, bp


mov bx, hello_world
call print_static

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


;Data
hello_world: db "Hello World!", 0


;Padding the remaining space with 0s and the magic number.
times 510-($-$$) db 0x0000
dw 0xaa55
