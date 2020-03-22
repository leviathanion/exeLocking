NAME = Main
OBJS = $(NAME).obj
RES  = $(NAME).res

LINK_FLAG = /debug /debugtype:cv /LARGEADDRESSAWARE:NO /FILEALIGN:0x1000 /subsystem:windows
ML_FLAG = -c -win64 -Zi

$(NAME).exe: $(OBJS) $(RES)
	Link $(LINK_FLAG) $(OBJS) $(RES)

$(NAME).obj: _PEFile.asm _Injection.asm
	uasm $(ML_FLAG) $(NAME).asm

.rc.res:
	rc $<

clean:
	del *.obj
	del *.res
