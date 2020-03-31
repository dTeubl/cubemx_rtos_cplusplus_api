# wrapper Makefile to build different targets


#============================ Variables ========================================
#DEFAULT_GOAL := all
TPROG = arm_app
TDIR = ./target
BDIR = ./build
BTDIR = $(BDIR)/$(TPROG)
BTARGET = $(BTDIR)/$(TPROG)

# application specific compilers
TPP = $(PREFIX)g++
TAS = $(PREFIX)g++
THEX = $(TPP) -O ihex
TBIN = $(TPP) -O binary -S

# Just to make this one the main target
.PHONY: target
target: $(BTARGET).bin
	@mv $(BTARGET).bin ./$(TPROG).bin

.PHONY: $(BTDIR)
$(BTDIR):
	@mkdir -p $@

# Include generated makefile to have all the definitions
include $(TDIR)/Makefile


T_EXTRA = -Wall -fdata-sections -ffunction-sections -pedantic
T_OPT = -O2
T_CCVERSION = -std=c17

# Recreate CFLGAS
TCINCS = $(shell python ./scripts/inc_fix.py $(TDIR) $(C_INCLUDES))
T_CFLAGS = $(MCU) $(C_DEFS) $(TCINCS) $(T_OPT) $(T_EXTRA)
# Why do we need this extra dependency thing? better linking information?
T_CFLAGS +=# -MMD -MP #-MF"$(@:%.o=%.d)"

# Recreate ASM_FLGAS
TASINCS = $(shell python ./scripts/inc_fix.py $(TDIR) $(AS_INCLUDES))
ASFLAGS = $(MCU) $(AS_DEFS) $(TASINCS) $(T_OPT) 

# Linker configurations
TLDSCRIPT = $(shell python ./scripts/pt.py $(TDIR) $(LDSCRIPT))
TLIBS = -lc -lm -lnosys 
TLIBDIR = 
TLDFLAGS = $(MCU) -specs=nano.specs -T$(TLDSCRIPT) $(TLIBDIR) $(TLIBS) -Wl,-Map=$(BTDIR)/$(TPROG).map,--cref -Wl,--gc-sections


# list of C objects
TSRC = $(shell python ./scripts/pt.py $(TDIR) $(C_SOURCES))
TOBJECTS = $(addprefix $(BTDIR)/,$(notdir $(TSRC:.c=.o)))
vpath %.c $(sort $(dir $(TSRC)))

# list of ASM program objects
TASM = $(shell python ./scripts/pt.py $(TDIR) $(ASM_SOURCES))
TOBJECTS += $(addprefix $(BTDIR)/,$(notdir $(TASM:.s=.o)))
vpath %.s $(sort $(dir $(TASM)))

# I still not exactly know why we have to add the "Makefile | $(BDIR)" at the end, but it needs it
# It just fucking creates the build directory for you....
$(BTDIR)/%.o: %.c Makefile | $(BUILD_DIR) $(BTDIR)
	@echo $(CC) -c $(T_CFLAGS) -Wa,-a,-ad,-alms=$(BTDIR)/$(notdir $(<:.c=.lst)) $< -o $@
	@$(CC) -c $(T_CFLAGS) -Wa,-a,-ad,-alms=$(BTDIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BTDIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo $(AS) -c $(ASFLAGS) $< -o $@
	$(AS) -c $(ASFLAGS) $< -o $@

$(BTARGET).elf: $(TOBJECTS) Makefile
	@echo ======== Linking the target ==========
	@$(CC) $(TOBJECTS) $(TLDFLAGS) -o $@
	@$(SZ) $@

$(BTARGET).hex: $(BTARGET).elf | $(BTDIR)
	@$(HEX) $< $@
	
$(BTARGET).bin: $(BTARGET).elf | $(BTDIR)
	@$(BIN) $< $@




-include $(wildcard $(BTDIR)/*.d)
#============================ Print informations ==============================

.PHONY: info_target
info_target:
	@echo -e "Target Compiler:" $(CC)
	@echo -e "Target objects:\n" $(TOBJECTS)
	@echo -e "Target sources:\n" $(TSRC)
	@echo -e "Target ASM:\n" $(TASM)
	@echo -e "Target Included Libs: " $(TCINCS)
	@echo -e "Target Included Libs: " $(AS_INCLUDES)
	@echo -e "temp... " $(temp)

temp = $(BDIR)/$(notdir $(<:.c=.lst))



