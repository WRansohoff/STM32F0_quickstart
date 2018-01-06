# Makefile for compiling ARM Cortex-M assembly projects.
TARGET = asm-firmware

# Default to M0 TSSOP20 4KB SRAM, 16KB Flash.
MCU ?= STM32F030F4
# ...or M0 TSSOP20 4KB SRAM, 32KB Flash.
#MCU ?= STM32F031F6

# Linker scripts for memory allocation.
ifeq ($(MCU), STM32F030F4)
	CHIP_FILE = STM32F030F4T6
	MCU_CLASS = F0
	MCU_PERIPH_CLASS = STM32F030
else ifeq ($(MCU), STM32F031F6)
	CHIP_FILE = STM32F031F6T6
	MCU_CLASS = F0
	MCU_PERIPH_CLASS = STM32F031
else ifeq ($(MCU), STM32F031K6)
	CHIP_FILE = STM32F031K6T6
	MCU_CLASS = F0
	MCU_PERIPH_CLASS = STM32F031
endif

LD_SCRIPT = ${CHIP_FILE}.ld
VECT_TBL  = ./vector_tables/${CHIP_FILE}_vt.S
BOOT_FILE = ./boot/${CHIP_FILE}_boot.S

ifeq ($(MCU_CLASS), F0)
	MCU_SPEC = cortex-m0
else ifeq ($(MCU_CLASS), F3)
	MCU_SPEC = cortex-m4
endif

# Toolchain definition (ARM bare metal)
TOOLCHAIN = /usr
CC = $(TOOLCHAIN)/bin/arm-none-eabi-gcc
AS = $(TOOLCHAIN)/bin/arm-none-eabi-as
LD = $(TOOLCHAIN)/bin/arm-none-eabi-ld
OC = $(TOOLCHAIN)/bin/arm-none-eabi-objcopy
OD = $(TOOLCHAIN)/bin/arm-none-eabi-objdump
OS = $(TOOLCHAIN)/bin/arm-none-eabi-size

# Assembly directives.
ASFLAGS += -mcpu=$(MCU_SPEC)
ASFLAGS += -mthumb
ASFLAGS += -Wall
#ASFLAGS += -c
# (Set error messages to appear on a single line.)
ASFLAGS += -fmessage-length=0
# Custom flags for preprocessor definitions:
ASFLAGS += -D$(MCU)
ASFLAGS += -DVVC_$(MCU_CLASS)
ASFLAGS += -DVVC_$(CHIP_FILE)

# C compilation directives
CFLAGS += -mcpu=$(MCU_SPEC)
CFLAGS += -mthumb
CFLAGS += -Wall
CFLAGS += -g
# (Set error messages to appear on a single line.)
CFLAGS += -fmessage-length=0
# (Set system to ignore semihosted junk)
CFLAGS += --specs=nosys.specs
# Custom flags for preprocessor definitions:
CFLAGS += -D$(MCU)
CFLAGS += -DVVC_$(MCU_CLASS)
CFLAGS += -DUSE_STDPERIPH_DRIVER
CFLAGS += -D$(MCU_PERIPH_CLASS)

# Linker directives.
LSCRIPT = ./ld/$(LD_SCRIPT)
LFLAGS += -mcpu=$(MCU_SPEC)
LFLAGS += -mthumb
LFLAGS += -Wall
LFLAGS += --specs=nosys.specs
LFLAGS += -nostdlib
LFLAGS += ./lib/libgcc.a
#LFLAGS += -nostartfiles
LFLAGS += -static
LFLAGS += -T$(LSCRIPT)

AS_SRC += ./src/core.S
AS_SRC += ./src/util.S
AS_SRC += $(VECT_TBL)
AS_SRC += $(BOOT_FILE)

C_SRC  += ./src/main.c
C_SRC  += ./src/interrupts_c.c
C_SRC  += ./src/std_periph/stm32f0xx_exti.c
C_SRC  += ./src/std_periph/stm32f0xx_gpio.c
C_SRC  += ./src/std_periph/stm32f0xx_misc.c
C_SRC  += ./src/std_periph/stm32f0xx_rcc.c
C_SRC  += ./src/std_periph/stm32f0xx_syscfg.c

# (other header file directories, if any)
INCLUDE =  -I./src
INCLUDE += -I./src/arm_include
INCLUDE += -I./src/std_periph

OBJS =  $(AS_SRC:.S=.o)
OBJS += $(C_SRC:.c=.o)

.PHONY: all
all: $(TARGET).bin

%.o: %.S
	$(CC) -x assembler-with-cpp -c -O0 $(ASFLAGS) $< -o $@

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $^ $(LFLAGS) -o $@

$(TARGET).bin: $(TARGET).elf
	$(OC) -S -O binary $< $@
	$(OS) $<

.PHONY: clean
clean:
	rm -f $(OBJS)
	rm -f ./vector_tables/*.o
	rm -f ./boot/*.o
	rm -f $(TARGET).elf $(TARGET).bin
