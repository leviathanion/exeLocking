;*******************************************************************
; Main.asm
;     PE 文件操作演示的主程序，提供对话框界面和文件打开功能
;*******************************************************************
	option casemap:none
	option win64:7
	option frame:auto
;*******************************************************************
; Include 文件定义
;*******************************************************************
include		windows.inc
include		richedit.inc

includelib	user32.lib
includelib	kernel32.lib
includelib	comdlg32.lib
;*******************************************************************
;组件等值定义
;*******************************************************************
ICO_MAIN	equ	1000
DLG_MAIN	equ	1000
IDC_INFO	equ	1001
IDM_MAIN	equ	2000
IDM_OPEN	equ	2001
IDM_EXIT	equ	2002
;*******************************************************************
; 数据段
;*******************************************************************
		.data?
hInstance	dq	?
hRichEdit	dq	?
hWinMain	dq	?
hWinEdit	dq	?
szFileName	db	MAX_PATH dup (?)

		.const
szDllEdit	db	'RichEd20.dll',0
szClassEdit	db	'RichEdit20A',0
szFont		db	'宋体',0
szExtPe		db	'PE Files',0,'*.exe;*.dll;*.scr;*.fon;*.drv',0
		db	'All Files(*.*)',0,'*.*',0,0
szErr		db	'文件格式错误!',0
szErrFormat	db	'这个文件不是PE格式的文件!',0
;*******************************************************************
; 代码段
;*******************************************************************
		.code
;*******************************************************************
_AppendInfo	proc	_lpsz
	local	@stCR:CHARRANGE

	invoke	GetWindowTextLength,hWinEdit
	mov	@stCR.cpMin,eax
	mov	@stCR.cpMax,eax
	invoke	SendMessage,hWinEdit,EM_EXSETSEL,0,addr @stCR
	invoke	SendMessage,hWinEdit,EM_REPLACESEL,FALSE,_lpsz
	ret

_AppendInfo	endp
;*******************************************************************
include         _PEFile.asm
;*******************************************************************
_Init		proc
	local	@stCf:CHARFORMAT

	invoke	GetDlgItem,hWinMain,IDC_INFO
	mov	hWinEdit,rax
	invoke	LoadIcon,hInstance,ICO_MAIN
	invoke	SendMessage,hWinMain,WM_SETICON,ICON_BIG,rax
	invoke	SendMessage,hWinEdit,EM_SETTEXTMODE,TM_PLAINTEXT,0
	invoke	RtlZeroMemory,addr @stCf,sizeof @stCf
	mov	@stCf.cbSize,sizeof @stCf
	mov	@stCf.yHeight,9 * 20
	mov	@stCf.dwMask,CFM_FACE or CFM_SIZE or CFM_BOLD
	invoke	lstrcpy,addr @stCf.szFaceName,addr szFont
	invoke	SendMessage,hWinEdit,EM_SETCHARFORMAT,0,addr @stCf
	invoke	SendMessage,hWinEdit,EM_EXLIMITTEXT,0,-1
	ret

_Init		endp
;*******************************************************************
; 错误 Handler
;*******************************************************************
_OpenFile_SEHHandler	proc frame uses rbx rsi rdi _lpExceptionRecord:qword, _lpFrame:qword, _lpContext:qword

	local	@szBuffer[256]:byte

	mov	rsi,_lpExceptionRecord
	mov	rdi,_lpContext
	assume	rsi:ptr EXCEPTION_RECORD,rdi:ptr CONTEXT
	lea	rax,_OpenFile_ErrFormat
	mov	[rdi].Rip_,rax
	assume	rsi:nothing,rdi:nothing

	mov	eax,ExceptionContinueExecution
	ret
	align 8

_OpenFile_SEHHandler	Endp
;*******************************************************************
_OpenFile	Proc   frame:_OpenFile_SEHHandler uses rbx rsi rdi
	local	@stOF:OPENFILENAME
	local	@hFile:qword
	local	@dwFileSize
	local	@hMapFile:qword
	local	@lpMemory:qword

	invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
	mov	@stOF.lStructSize,sizeof @stOF
	push	hWinMain
	pop	@stOF.hwndOwner
	lea	rax,szExtPe
	mov	@stOF.lpstrFilter,rax
	lea	rax,szFileName
	mov	@stOF.lpstrFile,rax
	mov	@stOF.nMaxFile,MAX_PATH
	mov	@stOF.Flags,OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
	invoke	GetOpenFileName,addr @stOF
	.if	! eax
		jmp	@F
	.endif
	invoke	CreateFile,addr szFileName,GENERIC_READ,FILE_SHARE_READ or \
		FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL
	.if	rax !=	INVALID_HANDLE_VALUE
		mov	@hFile,rax
		invoke	GetFileSize,rax,NULL
		mov	@dwFileSize,eax
		.if	eax
			invoke	CreateFileMapping,@hFile,NULL,PAGE_READONLY,0,0,NULL
			.if	rax
				mov	@hMapFile,rax
				invoke	MapViewOfFile,rax,FILE_MAP_READ,0,0,0
				.if	eax
					mov	@lpMemory,rax
					mov	rsi,@lpMemory
					assume	rsi:ptr IMAGE_DOS_HEADER
					.if	[rsi].e_magic != IMAGE_DOS_SIGNATURE
						jmp	_OpenFile_ErrFormat
					.Endif
					xor	rax,rax
					mov	eax,[rsi].e_lfanew
					add	rsi,rax
					assume	rsi:ptr IMAGE_NT_HEADERS
					.if	[rsi].Signature != IMAGE_NT_SIGNATURE
						jmp	_OpenFile_ErrFormat
					.endif
					invoke	_ProcessPeFile,@lpMemory,esi,@dwFileSize
					jmp	_ErrorExit
_OpenFile_ErrFormat::
					invoke	MessageBox,hWinMain,addr szErrFormat,NULL,MB_OK
_ErrorExit:
					invoke	UnmapViewOfFile,@lpMemory
				.endif
				invoke	CloseHandle,@hMapFile
			.endif
			invoke	CloseHandle,@hFile
		.endif
	.endif
@@:
	ret

_OpenFile	endp
;*******************************************************************
_ProcDlgMain	proc	uses rbx rdi rsi hWnd:qword,uMsg,wParam,lParam

	mov	eax,uMsg
	.if	eax == WM_CLOSE
		invoke	EndDialog,hWnd,NULL
	.elseif	eax == WM_INITDIALOG
		push	hWnd
		pop	hWinMain
		call	_Init
	.elseif	eax == WM_COMMAND
		mov	eax,wParam
		.if	ax ==	IDM_OPEN
			call	_OpenFile
		.elseif	ax ==	IDM_EXIT
			invoke	EndDialog,hWnd,NULL
		.endif
	.else
		mov	eax,FALSE
		ret
	.endif
	mov	eax,TRUE
	ret

_ProcDlgMain	endp
;*******************************************************************
Jmain	Proc
	invoke	LoadLibrary,offset szDllEdit
	mov	hRichEdit,rax
	invoke	GetModuleHandle,NULL
	mov	hInstance,rax
	invoke	DialogBoxParam,hInstance,DLG_MAIN,NULL,offset _ProcDlgMain,NULL
	invoke	FreeLibrary,hRichEdit
	invoke	ExitProcess,NULL
	ret
Jmain 	Endp
;*******************************************************************
	end	Jmain
