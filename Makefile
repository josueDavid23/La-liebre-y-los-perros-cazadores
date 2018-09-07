all:
	nasm -f elf -g -F stabs tarea2.asm -l tarea2.lst
	ld -m elf_i386 -o tarea2 tarea2.o

linker:
	ld -m elf_i386 -o tarea2 tarea2.o
	
  # ld ~ GNU Linker
  # -m ~ emulador
  # elf_i386 ~ arquitectura (32 bits)
  # -o ~ nombrar salida

compilador:
	nasm -f elf -g -F stabs tarea2.asm -l tarea2.lst
	
  # nasm ~ compilador
  # -f ~ formato del archivo de salida
  # elf ~ arquitectura (64)
  # -g ~ símbolos para debugger
  # -F ~ formato de los símbolos
  # -l ~ crea un archivo .lst
  
clean:
	rm tarea2 tarea2.lst tarea2.o

