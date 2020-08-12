;Get a 2 byte maximum hex number and print it to the screen.
;[in] : ax (hex number to be print to the screen)
;[out]: void
print_hex:

    ;Jump to the code.
    jmp print_hex_start

    ;Data Section AREA;

    ;An array to help with building the hex string.
    print_hex_array: db 0, '0', 1, '1', 2, '2', 3, '3', 4, '4', 5, '5',
    db  6, '6', 7, '7', 8, '8', 9, '9', 10, 'a', 11, 'b', 12, 'c', 13, 'd', 14, 'e', 15, 'f'

    ;Data Section AREA;


    ;Start print_hex execution.
    print_hex_start:
        pusha

        xor cx, cx ;cx = 0
        print_hex_loop:
            cmp     cx, 16                  ;If cx == 16
            je      print_hex_conclusion    ;then finish.
            mov     dx, 0x000f              ;dx= 00000000 00001111
            shl     dx, cl                  ;dx shifted left cl amount.
            and     dx, ax                  ;dx = dx & ax
            shr     dx, cl                  ;dx shifted right cl amount.
            add     cx, 4                   ;Increment cx by 4.

            mov si, print_hex_array         ;si points to the beginning of the array.
            print_hex_while:
                xor     bx, bx
                mov     bl, [ds:si]         ;Get the first number from the array.
                cmp     bx, dx              ;If bx == dx
                je      print_hex_store     ;If bx == dx then go to print_hex_store
                add     si, 2               ;Else increment si by 2.
                jmp     print_hex_while     ;and loop again.

                 print_hex_store:
                    mov     dl, [ds:si+1]   ;Move to dl the ascii representation of that number.
                    mov     dh, 0x0e        ;Move to dh the bios print char operation for int 0x10
                    push    dx              ;Push dx to the stack.
                    jmp     print_hex_loop  ;Go to the next digit of the hex number.


        
        ;Conlcusion.
        print_hex_conclusion:
        xor bx, bx ;clear bx

            ;Print 0 tp the screen.
            mov ah, 0x0e
            mov al, '0'
            int 0x10

            ;Print x to the screen.
            mov al, 'x'
            int 0x10

            ;Loop 4 times.
            print_hex_conclusion_while:
                cmp     bx, 4           ;If bx == 4
                je      print_hex_end   ;then return
                pop     ax              ;else pop to ax
                int     0x10            ;int 0x10 for video card operations.
                inc     bx              ;increment bx
                jmp     print_hex_conclusion_while


    ;Return.
    print_hex_end:

        ;Change line.
        mov al, 0x0a
        int 0x10

        ;Resset cursor to the left.
        mov al, 0x0d
        int 0x10

        popa
        ret
