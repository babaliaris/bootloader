[bits 16]
[org 0x7c00]

cli

;Initialize the stack.
mov bp, 0x7e00 ;This is the address where the 512 bootloader ends.
add bp, 50000  ;bp = 0x14150
mov sp, bp     ; Finally we have 50kb stack.


;Clear all the segment registers.
xor ax, ax
mov ds, ax
mov ss, ax

;Initialize the extra segment.
mov ax, 0x7e00
mov es, ax ; es*0x10 = 0x7E000, 135kb until it reaches the bios data area 0x9fc00

sti

;Print a static string.
mov si, hello_world
call print_static

jmp $


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
        mov al, [si] ;copy the current character to al.
        cmp al, 0 ;if its zero
        je print_static_end ;stop;
        int 0x10 ;else print al to the screen.
        add si, 1;go to the next character.
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
