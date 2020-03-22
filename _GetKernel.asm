;*******************************************************************
; 公用模块：_GetKernel.asm
; 根据程序被调用的时候堆栈中有个用于 Ret 的地址指向 Kernel32.dll
; 而从内存中扫描并获取 Kernel32.dll 的基址
;*******************************************************************

;*******************************************************************
; 错误处理
;*******************************************************************
_SEHHandler	proc frame uses rbx rsi rdi _lpExceptionRecord:qword, _lpFrame:qword, _lpContext:qword

	local	@szBuffer[256]:byte

	mov	rsi,_lpExceptionRecord
	mov	rdi,_lpContext
	assume	rsi:ptr EXCEPTION_RECORD,rdi:ptr CONTEXT
	lea	rax,_GetKernelBase_PageError
	mov	[rdi].Rip_,rax
	assume	rsi:nothing,rdi:nothing

	mov	eax,ExceptionContinueExecution
	ret
	align 8

_SEHHandler	Endp
;*******************************************************************
; 在内存中扫描 Kernel32.dll 的基址
;*******************************************************************
_GetKernelBase	proc	frame:_SEHHandler uses rbx rsi rdi _lpKernelRet:qword
	local	@dqReturn:qword

	mov	@dqReturn,0
;********************************************************************
; 重定位
;********************************************************************
	call	@F
@@:
	pop	rbx
	mov	rax,offset @b
	sub	rbx,rax
;********************************************************************
; 查找 Kernel32.dll 的基地址
;********************************************************************
	mov	rdi,_lpKernelRet
	and	rdi,0ffff0000h
	.while	TRUE
		.if	word ptr [rdi] == IMAGE_DOS_SIGNATURE
			mov	rsi,rdi
			xor	rax,rax
			mov	eax,dword ptr [rsi+003ch]
			add	rsi,rax
			.if word ptr [rsi] == IMAGE_NT_SIGNATURE
				mov	@dqReturn,rdi
				.break
			.endif
		.endif
_GetKernelBase_PageError::
		sub	rdi,010000h
		.break	.if rdi < 070000000h
	.endw
	mov	rax,@dqReturn
	ret

_GetKernelBase	Endp
;*******************************************************************
; 错误处理
;*******************************************************************
_SEHHandler2	proc frame uses rbx rsi rdi _lpExceptionRecord:qword, _lpFrame:qword, _lpContext:qword

	local	@szBuffer[256]:byte

	mov	rsi,_lpExceptionRecord
	mov	rdi,_lpContext
	assume	rsi:ptr EXCEPTION_RECORD,rdi:ptr CONTEXT
	lea	rax,_GetApi_Error
	mov	[rdi].Rip_,rax
	assume	rsi:nothing,rdi:nothing

	mov	eax,ExceptionContinueExecution
	ret
	align 8

_SEHHandler2	Endp
;*******************************************************************
; 从内存中模块的导出表中获取某个 API 的入口地址
;*******************************************************************
_GetApi		Proc frame:_SEHHandler2	uses rbx rsi rdi _hModule:qword,_lpszApi:qword
	local	@dqReturn:qword
	local	@dwStringLength

	
	mov	@dqReturn,0
;********************************************************************
; 重定位
;********************************************************************
	call	@F
@@:
	pop	rbx
	mov	rax,offset @b
	sub	rbx,rax
	mov	rdi,_lpszApi
	mov	rcx,-1
	xor	al,al
	cld
	repnz	scasb
	mov	rcx,rdi
	sub	rcx,_lpszApi
	mov	@dwStringLength,ecx
	mov	rsi,_hModule
	xor	rax,rax
	mov	eax,dword ptr [rsi + 3ch]
	add	rsi,rax
	assume	rsi:ptr IMAGE_NT_HEADERS
	mov	eax,[rsi].OptionalHeader.DataDirectory.VirtualAddress
	mov	rsi,_hModule
	add	rsi,rax
	assume	rsi:ptr IMAGE_EXPORT_DIRECTORY
	mov	ebx,[rsi].AddressOfNames
	add	rbx,_hModule
	xor	edx,edx
	.repeat
		push	rsi
		xor	rdi,rdi
		mov	edi,dword ptr [rbx]
		add	rdi,_hModule
		mov	rsi,_lpszApi
		mov	ecx,@dwStringLength
		repz	cmpsb
		.if	ZERO?
			pop	rsi
			jmp	@F
		.endif
		pop	rsi
		add	rbx,4
		inc	edx
	.until	edx >=	[rsi].NumberOfNames
	jmp	_GetApi_Error
@@:
	mov	eax,[rsi].AddressOfNames
	sub	rbx,rax
	sub	rbx,_hModule
	shr	rbx,1
	mov	eax,[rsi].AddressOfNameOrdinals
	add	rbx,rax
	add	rbx,_hModule
	movzx	rax,word ptr [rbx]
	shl	rax,2
	xor	rcx,rcx
	mov	ecx,[rsi].AddressOfFunctions
	add	rax,rcx
	add	rax,_hModule
	mov	eax,dword ptr [rax]
	add	rax,_hModule
	mov	@dqReturn,rax
_GetApi_Error::
	assume	rsi:nothing
	mov	rax,@dqReturn
	ret

_GetApi		endp
