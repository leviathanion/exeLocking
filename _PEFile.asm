;*******************************************************************
; AddCode 例子的功能模块
;*******************************************************************
		.const

szErrCreate	db	'创建文件错误!',0dh,0ah,0
szErrNoRoom	db	'程序中没有多余的空间可供加入代码!',0dh,0ah,0
szMySection	db	'.adata',0
szExt		db	'_new.exe',0
szSuccess	db	'在文件后附加代码成功，新文件：',0dh,0ah
		db	'%s',0dh,0ah,0

		.code

include		_Injection.asm

;*******************************************************************
; 计算按照指定值对齐后的数值
;*******************************************************************
_Align		Proc	_dwSize,_dwAlign

	mov	eax,_dwSize
	xor	edx,edx
	div	_dwAlign
	.if	edx
		inc	eax
	.endif
	mul	_dwAlign
	ret

_Align		endp
;*******************************************************************
_ProcessPeFile	Proc uses rbx rsi rdi r11 r12 r13 _lpFile:qword,_lpPeHead:qword,_dwSize
	local	@szNewFile[MAX_PATH]:byte
	local	@hFile:qword
	local	@dwTemp,@dwEntry
	local	@lpMemory:qword
	local	@dwAddCodeBase,@dwAddCodeFile
	local	@szBuffer[256]:byte
	
;********************************************************************
;准备工作：建立新文件并打开文件
;********************************************************************
	invoke	lstrcpy,addr @szNewFile,addr szFileName
	invoke	lstrlen,addr @szNewFile
	lea	rcx,@szNewFile
	mov	byte ptr [rcx+rax-4],0
	invoke	lstrcat,addr @szNewFile,addr szExt
	invoke	CopyFile,addr szFileName,addr @szNewFile,FALSE

	invoke	CreateFile,addr @szNewFile,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ or \
		FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL
	.if	rax ==	INVALID_HANDLE_VALUE
		invoke	SetWindowText,hWinEdit,addr szErrCreate
		jmp	_Ret
	.endif
	mov	@hFile,rax
;********************************************************************
;进行一些准备工作和检测工作
; rsi：原PE文件头
; rdi：新的PE文件头
; r12：最后一个节表
; rbx：新加的节表
;********************************************************************
	mov	rsi,_lpPeHead
	assume	rsi:ptr IMAGE_NT_HEADERS,rdi:ptr IMAGE_NT_HEADERS
	invoke	GlobalAlloc,GPTR,[rsi].OptionalHeader.SizeOfHeaders
	mov	@lpMemory,rax
	mov	rdi,rax
	invoke	RtlMoveMemory,rdi,_lpFile,[rsi].OptionalHeader.SizeOfHeaders
	add	rdi,rsi
	sub	rdi,_lpFile
	movzx	rax,[rsi].FileHeader.NumberOfSections
	dec	rax
	mov	ecx,sizeof IMAGE_SECTION_HEADER
	mul	ecx

	mov	r12,rdi
	add	r12,rax
	add	r12,sizeof IMAGE_NT_HEADERS
	mov	rbx,r12
	add	rbx,sizeof IMAGE_SECTION_HEADER
	assume	rbx:ptr IMAGE_SECTION_HEADER,r12:ptr IMAGE_SECTION_HEADER
;********************************************************************
;检查是否有空闲的位置可供插入节表
;********************************************************************
	push	rdi
	mov	rdi,rbx
	xor	rax,rax
	mov	ecx,IMAGE_SECTION_HEADER
	repz	scasb
	pop	rdi
	.if	! ZERO?
;********************************************************************
; 如果没有新的节表空间的话，则查看现存代码节的最后是否存在足够的全零空间，如果存在则在此处加入代码
;********************************************************************
		xor	eax,eax
		mov	rbx,rdi
		add	rbx,sizeof IMAGE_NT_HEADERS
		.while	ax <=	[rsi].FileHeader.NumberOfSections
			mov	ecx,[rbx].SizeOfRawData
			.if	ecx && ([rbx].Characteristics & IMAGE_SCN_MEM_EXECUTE)
				sub	ecx,[rbx].Misc.VirtualSize
				.if	ecx > offset APPEND_CODE_END-offset APPEND_CODE
					or	[rbx].Characteristics,IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
					add	[rbx].Misc.VirtualSize,offset APPEND_CODE_END-offset APPEND_CODE
					jmp	@F
				.endif
			.endif
			add	rbx,IMAGE_SECTION_HEADER
			inc	ax
		.endw
		invoke	CloseHandle,@hFile
		invoke	DeleteFile,addr @szNewFile
		invoke	SetWindowText,hWinEdit,addr szErrNoRoom
		jmp	_Ret
@@:
;********************************************************************
; 将新增代码加入代码节的空隙中
;********************************************************************
		mov	eax,[rbx].VirtualAddress
		add	eax,[rbx].Misc.VirtualSize
		mov	@dwAddCodeBase,eax
		mov	eax,[rbx].PointerToRawData
		add	eax,[rbx].Misc.VirtualSize
		mov	@dwAddCodeFile,eax
		invoke	SetFilePointer,@hFile,@dwAddCodeFile,NULL,FILE_BEGIN
		mov	r11d,offset APPEND_CODE_END-offset APPEND_CODE
		invoke	WriteFile,@hFile,offset APPEND_CODE,r11d,addr @dwTemp,NULL
	.else
;********************************************************************
;如果有新的节表空间的，则加入一个新的节
;********************************************************************
		inc	[rdi].FileHeader.NumberOfSections
		mov	eax,[r12].PointerToRawData
		add	eax,[r12].SizeOfRawData
		mov	[rbx].PointerToRawData,eax
		mov	r13d,offset APPEND_CODE_END-offset APPEND_CODE
		invoke	_Align,r13d,[rsi].OptionalHeader.FileAlignment
		mov	[rbx].SizeOfRawData,eax
		invoke	_Align,r13d,[rsi].OptionalHeader.SectionAlignment
		add	[rdi].OptionalHeader.SizeOfCode,eax	
		add	[rdi].OptionalHeader.SizeOfImage,eax	
		invoke	_Align,[r12].Misc.VirtualSize,[rsi].OptionalHeader.SectionAlignment
		add	eax,[r12].VirtualAddress
		mov	[rbx].VirtualAddress,eax
		mov	[rbx].Misc.VirtualSize,offset APPEND_CODE_END-offset APPEND_CODE
		mov	[rbx].Characteristics,IMAGE_SCN_CNT_CODE\
			or IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE
		invoke	lstrcpy,addr [rbx].Name_,addr szMySection
;********************************************************************
; 将新增代码作为一个新的节写到文件尾部
;********************************************************************
		invoke	SetFilePointer,@hFile,[rbx].PointerToRawData,NULL,FILE_BEGIN
		invoke	WriteFile,@hFile,offset APPEND_CODE,[ebx].Misc.VirtualSize,\
			addr @dwTemp,NULL
		mov	eax,[rbx].PointerToRawData
		add	eax,[rbx].SizeOfRawData
		invoke	SetFilePointer,@hFile,eax,NULL,FILE_BEGIN
		invoke	SetEndOfFile,@hFile
		mov	eax,[rbx].VirtualAddress	
		mov	@dwAddCodeBase,eax
		mov	eax,[rbx].PointerToRawData
		mov	@dwAddCodeFile,eax
	.endif
;********************************************************************
;修正文件入口指针并写入新的文件头
;********************************************************************
	mov	eax,@dwAddCodeBase
	add	eax,(offset _NewEntry-offset APPEND_CODE)
	mov	[rdi].OptionalHeader.AddressOfEntryPoint,eax
	invoke	SetFilePointer,@hFile,0,NULL,FILE_BEGIN
	invoke	WriteFile,@hFile,@lpMemory,[rsi].OptionalHeader.SizeOfHeaders,\
		addr @dwTemp,NULL
	mov	eax,[rsi].OptionalHeader.AddressOfEntryPoint
	mov	@dwEntry,eax
	mov	eax,@dwAddCodeBase
	add	eax,(offset _ToOldEntry-offset APPEND_CODE+5)
	sub	@dwEntry,eax
	mov	eax,@dwAddCodeFile
	add	eax,(offset _dwOldEntry-offset APPEND_CODE)
	invoke	SetFilePointer,@hFile,eax,NULL,FILE_BEGIN
	invoke	WriteFile,@hFile,addr @dwEntry,4,addr @dwTemp,NULL
	invoke	GlobalFree,@lpMemory
	invoke	CloseHandle,@hFile
	invoke	wsprintf,addr @szBuffer,Addr szSuccess,addr @szNewFile
	invoke	SetWindowText,hWinEdit,addr @szBuffer
_Ret:
	assume	rsi:nothing
	ret

_ProcessPeFile	endp
;*******************************************************************
