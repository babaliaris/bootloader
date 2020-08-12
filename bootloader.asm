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

    ;********************Initialization Of Segments********************;
    cli

    ;Initialize the stack.
    mov bp, 0x8000
    mov sp, bp


    ;Clear all the segment registers.
    xor ax, ax
    mov ds, ax
    mov ss, ax

    ;Initialize the extra segment.
    mov ax, 0x1000
    mov es, ax ; es*0x10 = 0x10000

    sti

    ;********************Initialization Of Segments********************;



    ;***************Try to read 1 sector from the disk*****************;
    ;I'M NOT CHANGING dl SINCE BIOS ALREADY SET IT TO THE BOOT DRIVE

    ;Try 10 times to resset the disk.
    xor bx, bx
    disk_resset_while:
        inc     bx                  ;Increament the while counter (bx)
        cmp     bx, 10              ;Compare if bx==10
        je      disk_resset_error   ;Jump to reset error if bx==10
        mov     ah, 0x0000          ;int 0x13 reset disk operation.
        int     0x13                ;int 0x13 disk operations.
        jc      disk_resset_while   ;if disk error, try again.


    ;Try 10 times to read the disk.
    xor     bx, bx
    push    bx
    disk_read_while:
        pop     bx                  ;Pop bx from the stack.
        inc     bx                  ;Increament the while counter (bx)
        cmp     bx, 10              ;Compare if bx==10
        je      disk_read_error     ;Jump to disk error if bx==10
        mov     ah, 0x02            ;int 0x13 read disk operation.
        mov     al, 1               ;Sector Read Count = 1
        mov     ch, 0               ;Select cylinder 0
        mov     cl, 2               ;Start from sector 2
        mov     dh, 0               ;Select head 0
        push    bx                  ;save the current value of bx.
        xor     bx, bx              ;Clear bx before the read
        int     0x13                ;Interrupt for disk operations.
        jc      disk_read_while     ;if disk error, try again.
    
    ;Don't forget to clear the last push!
    pop ax 

    ;Successfully read the disk!
    mov si, success_msg
    jmp end

    ;Resset Error.
    disk_resset_error:
        mov si, resset_error
        jmp end

    ;Read Error.
    disk_read_error:
        mov si, read_error
        xor bx, bx
        mov bl, ah
        mov ax, bx
    

    ;Success.
    end:
        call print_static
        call print_hex
        
    ;Stay here forever!!!
    jmp $
    ;***************Try to read 1 sector from the disk*****************;


%include "include/print_static.asm"
%include "include/print_hex.asm"


;Data
resset_error: db "Disk Resset Error! ", 0
read_error  : db "Disk Read Error ", 0
success_msg : db "Successfully read the disk ", 0


;Padding the remaining space with 0s and the magic number.
times 510-($-$$) db 0x0000
dw 0xaa55