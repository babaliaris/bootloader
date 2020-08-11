[bits 16]
[org 0x7c00]

;Start the execution of the code.
start: jmp main

;*************************************************;
;	OEM Parameter block / BIOS Parameter Block
;*************************************************;
 
TIMES 0Bh-$+start DB 0
 
bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	DB 2
bpbRootEntries: 	DW 224
bpbTotalSectors: 	DW 2880
bpbMedia: 	        DB 0xF0
bpbSectorsPerFAT: 	DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors:       DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	        DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "MOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "


;Main
main:

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
    mov ax, 0x1000
    mov es, ax ; es*0x10 = 0x10000

    sti

    ;Try 10 times to resset the disk.
    xor bx, bx
    disk_resset_while:
        inc     bx
        cmp     bx, 10
        je      disk_resset_error
        mov     ah, 0x0000
        int     0x13
        jc      disk_resset_while


    ;Try 10 times to read the disk.
    xor     bx, bx
    disk_read_while:
        inc     bx
        cmp     bx, 10
        je      disk_read_error
        mov     ah, 0x02    ;Read disk operation.
        mov     al, 1       ;Sector Read Count = 1
        mov     ch, 0       ;Select cylinder 0
        mov     cl, 2       ;Start from sector 2
        mov     dh, 0       ;Select head 0
        int     0x13        ;Interrupt for disk operations.
        jc      disk_read_while


    ;Clear bx and jump the end.
    xor bx, bx
    mov si, success_msg
    jmp end

    ;Resset Error.
    disk_resset_error:
        mov si, resset_error
        jmp end

    ;Read Error.
    disk_read_error:
        mov si, read_error
    

    ;Success.
    end:
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
resset_error: db "Disk Resset Error! ", 0
read_error  : db "Disk Read Error ", 0
success_msg : db "Successfully read the disk ", 0


;Padding the remaining space with 0s and the magic number.
times 510-($-$$) db 0x0000
dw 0xaa55
