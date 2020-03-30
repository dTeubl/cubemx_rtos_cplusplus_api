# wrapper Makefile to build different targets


#============================ Variables ========================================
DEFAULT_GOAL := all
TDIR = ./target
BDIR = ./build
BTDIR = $(BDIR)/arm_app
BTARGET = $(BDIR)/arm_app

# application specific compilers
TPP = $(PREFIX)g++
TAS = $(PREFIX)g++

# Just to make this one the main target
.PHONY: target
target: $(BTARGET).bin
	@echo $< : $@, $^
	@echo "This should be the main rule!"

# Include generated makefile to have all the definitions
include $(TDIR)/Makefile



# list of C objects
TSRC = $(shell python pt.py $(TDIR) $(C_SOURCES))
TOBJECTS = $(addprefix $(BTDIR)/,$(notdir $(TSRC:.c=.o)))
vpath %.c $(sort $(dir $(TSRC)))

# list of ASM program objects
TASM = $(shell python pt.py $(TDIR) $(ASM_SOURCES))
TOBJECTS += $(addprefix $(BTDIR)/,$(notdir $(TASM:.s=.o)))
vpath %.s $(sort $(dir $(TASM)))


$(BTDIR)/%.o: %.c Makefile | $(BDIR) 
	@$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BDIR)/$(notdir $(<:.c=.lst)) $< -o $@
	@echo $(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BDIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BTDIR)/%.o: %.s Makefile | $(BDIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BTARGET).elf: $(TOBJECTS) Makefile
	@$(CC) $(TOBJECTS) $(LDFLAGS) -o $@
	@$(SZ) $@

$(BTARGET).hex: $(BTARGET).elf | $(BDIR)
	@$(HEX) $< $@
	@echo $<: $@
	
$(BDIR)/%.bin: $(BDIR)/%.elf | $(BDIR)
	$(BIN) $< $@	



#============================ Print informations ==============================

.PHONY: info_target
info_target:
	@echo -e "Target Compiler:" $(CC)
	@echo -e "Target objects:\n" $(TOBJECTS)
	@echo -e "Target sources:\n" $(TSRC)
	@echo -e "Target ASM:\n" $(TASM)
	@echo -e "temp: " $(temp)
	@echo -e "TSRC: " $(TSRC)


temp = $(BDIR)/$(notdir $(<:.c=.lst))
