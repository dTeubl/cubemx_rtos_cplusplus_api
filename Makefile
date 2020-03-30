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
TOBJECTS = $(addprefix $(BTDIR)/,$(notdir $(C_SOURCES:.c=.o)))
temp1 = $(sort $(dir $(C_SOURCES)))
vpath $(TDIR)/%.c $(shell python pt.py $(TDIR) $(temp1))



# list of ASM program objects
TOBJECTS += $(addprefix $(BTDIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
temp2 = $(sort $(dir $(ASM_SOURCES)))
vpath $(TDIR)/%.s $(shell python pt.py $(TDIR) $(temp2))


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
	@echo -e "Target sources:\n" $(C_SOURCES)
	@echo -e "Target ASM:\n" $(ASM_SOURCES)
	@echo -e "temp: " $(temp)
	@echo -e "temp2: " $(temp2)


temp = $(sort $(dir $(C_SOURCES))) | tr " " "\n" 


