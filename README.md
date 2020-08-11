# bootloader
Just learning how to build a bootloader :)


# Depedencies
### qemu (including adding qemu-system-x86_64 to the PATH env variable)
### nasm assembler (including adding it to the PATH env variable)

#Run
Just run the run script `./run.sh`
this will build the raw binary file with nasm and execute it with 
```qemu-system-x86_64 -drive file=bootloader.bin,format=raw```
