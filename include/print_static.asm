;Get a null terminated character stored in the data segment and print it.
;[in] : si (Pointer at the beggining of the string)
;[out]: void
print_static:

    ;Save all general purpose registers.
    pusha
    
    ;Bios function for int 0x10 to print a char to the screen.
    mov ah, 0x0e
    
    ;Print while loop.
    print_static_while:
        mov al, [ds:si] ;copy the current character to al.
        cmp al, 0 ;if its zero
        je print_static_end ;stop;
        int 0x10 ;else print al to the screen.
        add si, 1;go to the next character.
        jmp print_static_while ;start again.


    ;exit print_static
    print_static_end:

        ;Change line.
        mov al, 0x0a
        int 0x10

        ;Resset cursor.
        mov al, 0x0d
        int 0x10

        ;Retrieve all general purpose registers.
        popa
        ret