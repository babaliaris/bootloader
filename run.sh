#Use the assembler to create the raw binary 512 bytes file.
nasm -f bin bootloader.asm -o bootloader.bin

#Run the binary file with qemu.
qemu-system-x86_64 -drive file=bootloader.bin,format=raw
