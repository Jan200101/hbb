#---------------------------------------------------------------------------------
# Clear the implicit built in rules
#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITPPC)),)
$(error "Please set DEVKITPPC in your environment. export DEVKITPPC=<path to>devkitPPC)
endif

include $(DEVKITPPC)/wii_rules

#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# INCLUDES is a list of directories containing extra header files
#---------------------------------------------------------------------------------
TARGET		:=	$(notdir $(CURDIR))
BUILD		:=	build
SOURCES		:=	source source/gfx source/GRRLIB source/GRRLIB/fonts source/libpng source/unzip
DATA		:=	data
INCLUDES	:=	$(CURDIR)/source/ $(PORTLIBS_PATH)/ppc/include/ $(PORTLIBS_PATH)/ppc/include/freetype2/

MAIN_DOMAIN 	:=	hbb1.oscwii.org
FALLBACK_DOMAIN	:=	hbb2.oscwii.org

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------

CFLAGS		= -g -O -mrvl -Wall -DMAIN_DOMAIN=\"$(MAIN_DOMAIN)\" -DFALLBACK_DOMAIN=\"$(FALLBACK_DOMAIN)\" $(MACHDEP) $(INCLUDE)
CXXFLAGS	=	$(CFLAGS)

LDFLAGS		=	-g $(MACHDEP) -mrvl -Wl,-Map,$(notdir $@).map

#---------------------------------------------------------------------------------
# any extra libraries we wish to link with the project
#---------------------------------------------------------------------------------
LIBS	:=	-lz -lfat -lmxml -lwiiuse -lbte -lvorbisidec -lasnd -logg -lmad -lgrrlib -ljpeg -lpngu -lpng -lm -logc -lfreetype -lbz2
#LIBS	:=	-lpng -lz -lfat -lmxml -lwiiuse -lbte -lvorbisidec -lasnd -logc -lmodplay -lm -lmad -lfreetype


#---------------------------------------------------------------------------------
# list of directories containing libraries, this must be the top level containing
# include and lib
#---------------------------------------------------------------------------------
LIBDIRS	:= $(CURDIR) $(PORTLIBS_PATH)/ppc

#---------------------------------------------------------------------------------
# no real need to edit anything past this point unless you need to add additional
# rules for different file extensions
#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))
#---------------------------------------------------------------------------------

export OUTPUT	:=	$(CURDIR)/$(TARGET)

export VPATH	:=	$(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) \
					$(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR	:=	$(CURDIR)/$(BUILD)

#---------------------------------------------------------------------------------
# automatically build a list of object files for our project
#---------------------------------------------------------------------------------
PNGFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.png)))
TTFFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.ttf)))
CFILES		:=	$(patsubst %.png,%.c,$(PNGFILES)) $(patsubst %.ttf,%.c,$(TTFFILES)) \
				$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
sFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.S)))
BINFILES	:=	$(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
	export LD	:=	$(CC)
else
	export LD	:=	$(CXX)
endif

export OFILES	:=	$(addsuffix .o,$(BINFILES)) \
					$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) \
					$(sFILES:.s=.o) $(SFILES:.S=.o)

#---------------------------------------------------------------------------------
# build a list of include paths
#---------------------------------------------------------------------------------
export INCLUDE	:=	$(foreach dir,$(INCLUDES), -I$(dir)) \
					$(foreach dir,$(LIBDIRS),-I$(dir)/include) \
					-I$(CURDIR)/$(BUILD) \
					-I$(LIBOGC_INC)

#---------------------------------------------------------------------------------
# build a list of library paths
#---------------------------------------------------------------------------------
export LIBPATHS	:=	$(foreach dir,$(LIBDIRS),-L$(dir)/lib) -L$(LIBOGC_LIB) 
					

export OUTPUT	:=	$(CURDIR)/$(TARGET)
.PHONY: $(BUILD) clean run reload

#---------------------------------------------------------------------------------
$(BUILD):
	@[ -d $@ ] || mkdir -p $@
	@+make --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

#---------------------------------------------------------------------------------
clean:
	@echo clean ...
	@rm -fr $(BUILD) $(OUTPUT).elf $(OUTPUT).dol

#---------------------------------------------------------------------------------
run:
	wiiload $(TARGET).dol

#---------------------------------------------------------------------------------
else

DEPENDS	:=	$(OFILES:.o=.d)

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
$(OUTPUT).dol: $(OUTPUT).elf
$(OUTPUT).elf: $(OFILES)

%.mod.o	:	%.mod
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)

%.mp3.o	:	%.mp3
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)

#---------------------------------------------------------------------------------
# This rule links in binary data with the .jpg extension
#---------------------------------------------------------------------------------
%.jpg.o	:	%.jpg
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	$(bin2o)

%.c : %.png
	@echo $(notdir $<) 
	@raw2c $< ||:

%.c : %.ttf
	@echo $(notdir $<) 
	@raw2c $< ||:

-include $(DEPENDS)

#---------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------
