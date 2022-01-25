# Copyright (c) 2018 SiFive, Inc
# SPDX-License-Identifier: Apache-2.0
# SPDX-License-Identifier: GPL-2.0-or-later
# See the file LICENSE for further information

CROSSCOMPILE?=riscv64-unknown-elf-
CC=${CROSSCOMPILE}gcc
LD=${CROSSCOMPILE}ld
OBJCOPY=${CROSSCOMPILE}objcopy
OBJDUMP=${CROSSCOMPILE}objdump
CFLAGS=-I. -O2 -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -fno-tree-loop-distribute-patterns
CCASFLAGS=-I. -mcmodel=medany -mexplicit-relocs
LDFLAGS=-nostdlib -nostartfiles

LIB_FS1_O= \
	fsbl/start.o
LIB_FS2_O= \
	spi/spi.o \
	uart/uart.o \
	lib/version.o \
	fsbl/ux00boot.o \
	clkutils/clkutils.o \
	gpt/gpt.o \
	sd/sd.o \
	lib/memcpy.o \
	lib/memset.o \
	lib/strcmp.o \
	lib/strlen.o \

H=$(wildcard *.h */*.h)

BIN=fsbl.bin
ELF=fsbl.elf
ASM=fsbl.asm

all: $(BIN)

elf: $(ELF)

asm: $(ASM)

lib/version.c: .git/HEAD .git/index
	echo "const char *gitid = \"$(shell git describe --always --dirty)\";" > lib/version.c
	echo "const char *gitdate = \"$(shell git log -n 1 --date=short --format=format:"%ad.%h" HEAD)\";" >> lib/version.c
	echo "const char *gitversion = \"$(shell git rev-parse HEAD)\";" >> lib/version.c

fsbl/ux00boot.o: ux00boot/ux00boot.c
	$(CC) $(CFLAGS) -DUX00BOOT_BOOT_STAGE=1 -c -o $@ $^

fsbl.elf: $(LIB_FS1_O) fsbl/main.o $(LIB_FS2_O) ux00_fsbl.lds
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(filter %.o,$^) -T$(filter %.lds,$^)

%.bin: %.elf
	$(OBJCOPY) -S -R .comment -R .note.gnu.build-id -O binary $^ $@

%.asm: %.elf
	$(OBJDUMP) -S $^ > $@

%.o: %.S
	$(CC) $(CFLAGS) $(CCASFLAGS) -c $< -o $@

%.o: %.c $(H)
	$(CC) $(CFLAGS) -o $@ -c $<

clean::
	rm -f */*.o $(BIN) $(ELF) $(ASM) lib/version.c
