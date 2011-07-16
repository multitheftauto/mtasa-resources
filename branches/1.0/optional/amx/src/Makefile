#### Start of system configuration section ####

ASM = nasm
CC = gcc
LD = gcc
PROG = king.so
CXX = gcc
CPP = gcc

# Compiler flags
# NOTE: add -g for debug, remove for release!
ASMFLAGS = -O1 -f elf -I./amx/
CPPFLAGS = -MD -O2 -Wall -I./ -I/usr/local/include/boost-1_35 -I./amx -I./include -I./linux -DAMX_DONT_RELOCATE -DFLOATPOINT -DASM32
LDFLAGS = -fPIC -s -shared -Wl,-soname,$(PROG).1,-R./
LIBS = -lpthread -lstdc++ -llua5.1 -lsqlite3 -lboost_filesystem-gcc41-mt-s -lboost_system-gcc41-mt-s

#### End of system configuration section ####

#### Source and object files

SRC_AMXASM = ./amx/amxexecn.asm
OBJ_AMXASM = $(patsubst %.asm,%.o,$(SRC_AMXASM))

SRC_AMX = ./amx/amx.c ./amx/amxaux.c ./amx/amxcons.c ./amx/amxcore.c ./amx/amxfile.c ./amx/amxstring.c ./amx/amxtime.c ./amx/float.c
OBJ_AMX = $(patsubst %.c,%.o,$(SRC_AMX))

SRC_LOCAL =	$(wildcard ./*.cpp) $(wildcard ./linux/*.c)
OBJ_LOCAL =	$(patsubst %.cpp,%.o,$(patsubst %.c,%.o,$(SRC_LOCAL)))

CPPSRCS	= $(SRC_LOCAL) $(SRC_AMX)
CPPOBJS	= $(OBJ_AMX) $(OBJ_LOCAL)
ASMSRCS = $(SRC_AMXASM)
ASMOBJS = $(OBJ_AMXASM)
DEPS	= $(patsubst %.o,%.d,$(OBJS))

#### Make rules

all : kingasm king

kingasm :
	$(ASM) $(ASMFLAGS) $(ASMSRCS)

king : $(CPPOBJS)
	$(CC) $(CPPFLAGS) $(LDFLAGS) -o $(PROG) $(CPPOBJS) $(ASMOBJS) $(LIBS)

clean :
	-rm *.d
	-rm *.o
	-rm ./amx/*.o
	-rm ./amx/*.d
	-rm ./linux/*.o
	-rm ./linux/*.d
	-rm $(PROG)

-include $(DEPS)
