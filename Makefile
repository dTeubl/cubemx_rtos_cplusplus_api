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

# Configuration for Embedded C++ object
CPP_SOURCES = $(wildcard ./app/src/*cpp)
CPP_INC = $(patsubst %,-I%,app/inc/) 

#============================ Reconfifuration of flags

T_EXTRA = -Wall -fdata-sections -ffunction-sections -pedantic
T_OPT = -O2
T_CCVERSION = -std=c17
CPP_EXTRA = -std=c++17 -Weffc++

# Recreate CFLGAS
TCINCS = $(shell python ./scripts/inc_fix.py $(TDIR) $(C_INCLUDES))
T_CFLAGS = $(MCU) $(C_DEFS) $(TCINCS) $(T_OPT) $(T_EXTRA)
# Why do we need this extra dependency thing? better linking information?
# Look up the flags, but it seems to work without it...
T_CFLAGS +=# -MMD -MP #-MF"$(@:%.o=%.d)"

# Recreate ASM_FLGAS
TASINCS = $(shell python ./scripts/inc_fix.py $(TDIR) $(AS_INCLUDES))
ASFLAGS = $(MCU) $(AS_DEFS) $(TASINCS) $(T_OPT) 

# Creating C++ flags
CPPFLAGS = $(MCU) $(C_DEFS) $(CPP_INC) $(TCINCS) $(T_OPT) $(T_EXTRA) $(CPP_EXTRA)


# Linker configurations
TLDSCRIPT = $(shell python ./scripts/pt.py $(TDIR) $(LDSCRIPT))
LD_SYS_LIBS = -lstdc++ -lsupc++ -lgcc
TLIBS = -lc -lm -lnosys $(LD_SYS_LIBS)
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

# list of C++ objects
TOBJECTS += $(addprefix $(BTDIR)/,$(notdir $(CPP_SOURCES:.cpp=.o)))
vpath %.cpp $(sort $(dir $(CPP_SOURCES)))

#============================ Compiling the objects ===========================
# I still not exactly know why we have to add the "Makefile | $(BDIR)" at the end, but it needs it
# It just fucking creates the build directory for you....
$(BTDIR)/%.o: %.c Makefile | $(BUILD_DIR) $(BTDIR)
	@echo $(CC) $< "-->" $@
	@$(CC) -c $(T_CFLAGS) -Wa,-a,-ad,-alms=$(BTDIR)/$(notdir $(<:.c=.lst)) $< -o $@

# Rules for the pure assembly files
$(BTDIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo $(AS) $< "-->" $@
	@$(AS) -c $(ASFLAGS) $< -o $@

# Rules for the c++ files
$(BTDIR)/%.o: %.cpp Makefile | $(BDIR)
	@echo $(TPP) -c $(CPPFLAGS) -Wa,-a,-ad,-alms=$(BTDIR)/$(notdir $(<:.cpp=.lst)) $< -o $@
	@$(TPP) -c $(CPPFLAGS) -Wa,-a,-ad,-alms=$(BTDIR)/$(notdir $(<:.cpp=.lst)) $< -o $@

#============================ Linking ==========================================
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
	@echo -e "Target c++ src... " $(CPP_SOURCES)
	@echo -e "Target c++ INC... " $(CPP_INC)
	@echo -e "temp2: " $(temp2)
	@echo -e "ldflags: " $(TLDFLAGS)


temp2 =$(BTDIR)/$(notdir $(<:.cpp=.lst))


