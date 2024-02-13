default: build

build:
	nasm -f elf64 httpServer.asm
	ld httpServer.o -o httpServer

clean:
	rm -f *.o server