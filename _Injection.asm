;*******************************************************************
; 要被添加到PE文件后面执行的代码
;*******************************************************************
;
;ID_BUTTON1         equ   1
;ID_BUTTON2         equ   2
;ID_LABEL1          equ   3
;ID_LABEL2          equ   4
;ID_EDIT1           equ   5
;ID_EDIT2           equ   6

;*******************************************************************
; 函数的原形定义
;*******************************************************************
_ProtoProcWinMain	typedef proto :qword,:qword,:qword,:qword

;user32.dll
_ProtoGetProcAddress	typedef	proto	:qword,:qword
_ProtoLoadLibraryA	typedef	proto	:qword
_ProtoCreateWindowExA typedef proto  :qword,:qword,:qword,:qword,:qword,:qword,:qword,:qword,:qword,:qword,:qword,:qword
_ProtoDefWindowProcA typedef proto   :qword,:qword,:qword,:qword
_ProtoDestroyWindow typedef proto   :qword
_ProtoDispatchMessageA typedef proto   :qword
_ProtoGetDlgItemTextA typedef proto   :qword,:qword,:qword,:qword
_ProtoGetMessageA  typedef proto :qword,:qword,:qword,:qword
_ProtoMessageBoxA    typedef	proto	:qword,:qword,:qword,:qword
_ProtoPostQuitMessage typedef proto   :qword
_ProtoRegisterClassExA typedef proto   :qword
_ProtoShowWindow typedef proto   :qword,:qword
_ProtoTranslateAcceleratorA typedef proto   :qword,:qword,:qword
_ProtoTranslateMessage typedef proto   :qword
_ProtoUpdateWindow typedef proto   :qword
;kernel32.dll
_ProtoExitProcess	typedef	proto	:qword
_ProtoGetModuleHandleA typedef proto   :qword
_ProtoRtlZeroMemory typedef proto   :qword,:qword
_ProtolstrcmpA typedef proto   :qword,:qword
;*******************************************************************

;*******************************************************************
; 函数的指针
;*******************************************************************
_ApiProcWinMain	typedef	ptr _ProtoProcWinMain

;user32.dll
_ApiGetProcAddress	typedef	ptr	_ProtoGetProcAddress
_ApiLoadLibraryA		typedef	ptr	_ProtoLoadLibraryA
_ApiCreateWindowExA   typedef ptr _ProtoCreateWindowExA
_ApiDefWindowProcA   typedef ptr _ProtoDefWindowProcA
_ApiDestroyWindow   typedef ptr _ProtoDestroyWindow
_ApiDispatchMessageA   typedef ptr _ProtoDispatchMessageA
_ApiGetDlgItemTextA   typedef ptr _ProtoGetDlgItemTextA
_ApiGetMessageA typedef ptr   _ProtoGetMessageA 
_ApiMessageBoxA   typedef ptr _ProtoMessageBoxA
_ApiPostQuitMessage   typedef ptr _ProtoPostQuitMessage
_ApiRegisterClassExA   typedef ptr _ProtoRegisterClassExA
_ApiShowWindow   typedef ptr _ProtoShowWindow
_ApiTranslateAcceleratorA   typedef ptr _ProtoTranslateAcceleratorA
_ApiTranslateMessage   typedef ptr _ProtoTranslateMessage
_ApiUpdateWindow   typedef ptr _ProtoUpdateWindow
;kernel32.dll
_ApiExitProcess        typedef ptr _ProtoExitProcess
_ApiGetModuleHandleA   typedef ptr _ProtoGetModuleHandleA
_ApiRtlZeroMemory   typedef ptr _ProtoRtlZeroMemory
_ApilstrcmpA   typedef ptr _ProtolstrcmpA
;*******************************************************************

APPEND_CODE:
;*******************************************************************
; 被添加到PE文件中的代码从这里开始
;*******************************************************************
include		_GetKernel.asm
;*******************************************************************
hDllKernel32	dq	?
hDllUser32	dq	?
_rsp_address	dq	?
;*******************************************************************

;*******************************************************************
; 声明函数引用
;*******************************************************************
_ProcWinMain1 _ApiProcWinMain ?


_GetProcAddress	_ApiGetProcAddress	?
_LoadLibraryA	_ApiLoadLibraryA		?
_MessageBoxA	_ApiMessageBoxA		?
_CreateWindowExA   _ApiCreateWindowExA  ?
_DefWindowProcA   _ApiDefWindowProcA  ?
_DestroyWindow   _ApiDestroyWindow  ?
_DispatchMessageA   _ApiDispatchMessageA  ?
_GetDlgItemTextA   _ApiGetDlgItemTextA  ?
_GetMessageA   _ApiGetMessageA  ?
_PostQuitMessage   _ApiPostQuitMessage  ?
_RegisterClassExA   _ApiRegisterClassExA  ?
_ShowWindow   _ApiShowWindow  ?
_TranslateAcceleratorA   _ApiTranslateAcceleratorA  ?
_TranslateMessage   _ApiTranslateMessage  ?
_UpdateWindow   _ApiUpdateWindow  ?
;kernel32.dll
_ExitProcess	_ApiExitProcess		?
_GetModuleHandleA   _ApiGetModuleHandleA  ?
_RtlZeroMemory   _ApiRtlZeroMemory  ?
_lstrcmpA   _ApilstrcmpA  ?
;*******************************************************************


szUser32	db	'user32',0
szKernel32         db 'kernel32',0,0

;user32.dll
szLoadLibraryA	db	'LoadLibraryA',0
szGetProcAddress db	'GetProcAddress',0
szMessageBoxA	db	'MessageBoxA',0
szCreateWindowExA  db 'CreateWindowExA',0
szDefWindowProcA   db 'DefWindowProcA',0
szDestroyWindow    db 'DestroyWindow',0
szDispatchMessageA db 'DispatchMessageA',0
szGetDlgItemTextA  db 'GetDlgItemTextA',0
szGetMessageA      db 'GetMessageA',0
szPostQuitMessage  db 'PostQuitMessage',0
szRegisterClassExA db 'RegisterClassExA',0
szShowWindow       db 'ShowWindow',0
szTranslateAcceleratorA  db 'TranslateAcceleratorA',0
szTranslateMessage db 'TranslateMessage',0
szUpdateWindow     db 'UpdateWindow',0

;kernel32.dll
szGetModuleHandleA db 'GetModuleHandleA',0
szRtlZeroMemory    db 'RtlZeroMemory',0
szlstrcmpA         db 'lstrcmpA',0
szExitProcess	db	'ExitProcess',0



szCaption	db	'tip',0
szText		db	'wocao',0


szCaptionMain      db  'System load',0
szClassName        db  'Menu Example',0
szButtonClass      db  'button',0
szEditClass        db  'edit',0
szLabelClass       db  'static',0

szButtonText1      db  'loading',0
szButtonText2      db  'cancle',0
szLabel1           db  'ID：',0
szLabel2           db  'Password：',0
lpszUser           db  'os',0       
lpszPass           db  'se1704',0


szBuffer           db  256 dup(0)
szBuffer2          db  256 dup(0) 


hInstance2          dq  ?
hWinMain2           dq  ?


; 窗口消息处理子程序
_ProcWinMain proc uses rbx rdi rsi,hWnd:qword,uMsg:qword,wParam:qword,lParam:qword
      local @stPos:POINT
      local hLabel1:qword
      local hLabel2:qword
      local hEdit1:qword
      local hEdit2:qword
      local hButton1:qword
      local hButton2:qword
	  local buffer1 :qword
	  local buffer2 :qword
	  local address :qword
      call @F   
   @@:
      pop rbx
	  push rbx
	  pop address
      mov	rax,offset @b
	  sub	rbx,rax   
      mov rax,uMsg


	  .if hWnd==10086
		.if uMsg==10086
			.if wParam==10086
				.if lParam==10086
					mov rcx,address
					sub rcx,27h
					mov [rbx+_ProcWinMain1],rcx
				.endif
			.endif
		.endif
	.endif
      
      .if rax==WM_CREATE
          mov rax,hWnd
          mov [rbx+offset hWinMain2],rax

          ;label
		  lea rsi,[rbx+offset szLabelClass]
		  lea rdi,[rbx+offset szLabel1]

          invoke [rbx+_CreateWindowExA],NULL,\
                 rsi,rdi,WS_CHILD or WS_VISIBLE, \
                 10,20,100,30,hWnd,3,[rbx+offset hInstance2],NULL
          mov hLabel1,rax

		  lea rsi,[rbx+offset szLabelClass]
		  lea rdi,[rbx+offset szLabel2]

          invoke [rbx+_CreateWindowExA],NULL,\
                 rsi,rdi,WS_CHILD or WS_VISIBLE, \
                 10,50,100,30,hWnd,4,[rbx+offset hInstance2],NULL
          mov hLabel2,rax

          ;文本框
		  lea rsi,[rbx+offset szEditClass]

          invoke [rbx+_CreateWindowExA],WS_EX_TOPMOST,\
                 rsi,NULL,WS_CHILD or WS_VISIBLE \
                 or WS_BORDER,\
                 105,19,175,22,hWnd,5,[rbx+offset hInstance2],NULL
          mov hEdit1,rax
		  lea rsi,[rbx+offset szEditClass]     
          invoke [rbx+_CreateWindowExA],WS_EX_TOPMOST,\
                 rsi,NULL,WS_CHILD or WS_VISIBLE \
                 or WS_BORDER or ES_PASSWORD,\
                 105,49,175,22,hWnd,6,[rbx+offset hInstance2],NULL
          mov hEdit2,rax
          ;按钮
		  lea rsi,[rbx+offset szButtonClass]
		  lea rdi,[rbx+offset szButtonText1]
          invoke [rbx+_CreateWindowExA],NULL,\
                 rsi,rdi,WS_CHILD or WS_VISIBLE, \
                 120,100,60,30,hWnd,1,[rbx+offset hInstance2],NULL
          mov hButton1,rax
		  lea rsi,[rbx+offset szButtonClass]
		  lea rdi,[rbx+offset szButtonText2]

          invoke [rbx+_CreateWindowExA],NULL,\
                 rsi,rdi,WS_CHILD or WS_VISIBLE, \
                 200,100,60,30,hWnd,2,[rbx+offset hInstance2],NULL
          mov hButton2,rax

      .elseif rax==WM_COMMAND  
          mov rax,wParam
          movzx rax,ax
          .if rax==1
			 mov rax,wParam
			 lea rsi,[rbx+offset szBuffer]
             invoke [rbx+_GetDlgItemTextA],hWnd,5,\
                    rsi,sizeof szBuffer
			 lea rsi,[rbx+offset szBuffer2]
             invoke [rbx+_GetDlgItemTextA],hWnd,6,\
                    rsi,sizeof szBuffer2
           

             
			 lea rdx,[rbx+offset szBuffer]

             
			 lea rax,[rbx+offset lpszUser]
             invoke [rbx+_lstrcmpA],rdx,rax
             .if rax
                jmp _ret
             .endif
             
			 lea rdx,[rbx+offset szBuffer2]
             
			 lea rax,[rbx+offset lpszPass]
             
             invoke [rbx+_lstrcmpA],rdx,rax
             
             .if rax
                jmp _ret
             .endif
			 
             jmp _ret1
          .elseif rax==2
_ret:        invoke [rbx+_ExitProcess],NULL
_ret1:       invoke [rbx+_DestroyWindow],hWnd
			 invoke [rbx+_PostQuitMessage],NULL
          .endif
      .elseif rax==WM_CLOSE
      .else
          invoke [rbx+_DefWindowProcA],hWnd,uMsg,wParam,lParam
          ret
      .endif
      xor rax,rax
	ret
_ProcWinMain endp




; 主窗口程序
_WinMain  proc uses rbx rsi rdi _lParam

       local @stWndClass:WNDCLASSEX
       local @stMsg:MSG
       local @hAccelerator
	   local buffer1 :qword
	   local buffer2 :qword
	   local buffer3 :qword
	   local number :qword
       call @F   
   @@:
       pop	rbx
       mov	rax,offset @b
	   sub	rbx,rax   

;********************************************************************
; x64要做堆栈对齐,不然调用函数会出问题
;********************************************************************
	mov	rdi,rsp
	and	rdi,0fh
	and	rsp,0fffffffffffffff0h
	and rbp,0fffffffffffffff0h


       push rbx
       invoke [rbx+_GetModuleHandleA],NULL
       pop rbx
       mov [rbx+offset hInstance2],rax

       push rbx
       ;注册窗口类
       invoke [rbx+_RtlZeroMemory],addr @stWndClass,sizeof @stWndClass
       mov @stWndClass.hIcon,NULL
       mov @stWndClass.hIconSm,NULL

       mov @stWndClass.hCursor,NULL

       pop rbx

	   invoke _ProcWinMain,10086,10086,10086,10086
	   mov rdx,[rbx+_ProcWinMain1]



      
	   lea rcx,[rbx + offset szClassName]

       push [rbx+offset hInstance2]
       pop @stWndClass.hInstance
       mov @stWndClass.cbSize,sizeof WNDCLASSEX
       mov @stWndClass.style,CS_HREDRAW or CS_VREDRAW
       mov @stWndClass.lpfnWndProc,rdx
       mov @stWndClass.hbrBackground,COLOR_WINDOW
       mov @stWndClass.lpszClassName,rcx
	   sub rsp,10h
	   lea rax,@stWndClass
       invoke [rbx+_RegisterClassExA],rax
	   add rsp,10h

      
	   lea rsi,[rbx+offset szClassName]

       
	   lea rdi,[rbx+offset szCaptionMain]

       

       ;建立并显示窗口
       invoke [rbx+_CreateWindowExA],WS_EX_CLIENTEDGE,\
              rsi,rdi,\
              WS_OVERLAPPED or WS_CAPTION or \
              WS_MINIMIZEBOX,\
              350,280,300,180,\
              NULL,NULL,[rbx+offset hInstance2],NULL
       mov  [rbx+offset hWinMain2],rax
       

       invoke [rbx+_ShowWindow],[rbx+hWinMain2],SW_SHOWNORMAL
       
       invoke [rbx+_UpdateWindow],rdx 
      
   
       ;消息循环
       .while TRUE
          
		  lea rax,@stMsg
          invoke [rbx+_GetMessageA],rax,NULL,0,0
         
          .break .if rax==0
          
		  lea rdx,[rbx + offset hWinMain2]
          
          invoke [rbx+_TranslateAcceleratorA],rdx,\
                 addr @hAccelerator,addr @stMsg
          
          .if rax==0
			 lea rax,@stMsg
             invoke [rbx+_TranslateMessage],rax
			 lea rax,@stMsg
             invoke [rbx+_DispatchMessageA],rax
          .endif
       .endw
       ret
_WinMain endp








; 新的入口地址
_NewEntry:
; 重定位并获取一些 API 的入口地址
	call	@F
@@:
	pop	rbx
	mov	rax,offset @b
	sub	rbx,rax
	mov 	rax,[rsp]
	mov	[rbx+_rsp_address],rax
	invoke	_GetKernelBase,[rsp]	
	.if	! eax
		jmp	_ToOldEntry
	.endif
	mov	[rbx+hDllKernel32],rax	
	lea	rax,[rbx+szGetProcAddress]
	invoke	_GetApi,[rbx+hDllKernel32],rax
	.if	! eax
		jmp	_ToOldEntry
	.endif
	mov	[rbx+_GetProcAddress],rax
; x64要做堆栈对齐,不然调用函数会出问题
	mov	rdi,rsp
	and	rdi,0fh
	and	rsp,0fffffffffffffff0h
	lea	rax,[rbx+szLoadLibraryA]	
	mov	rsi,[rbx+hDllKernel32]
	invoke	[rbx+_GetProcAddress],rsi,rax
	mov	[rbx+_LoadLibraryA],rax
	
	lea	rax,[rbx+szUser32]	
	invoke	[rbx+_LoadLibraryA],rax
	mov	[rbx+hDllUser32],rax


	lea	rax,[rbx+szMessageBoxA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_MessageBoxA],rax

	lea	rax,[rbx+szCreateWindowExA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_CreateWindowExA],rax

	lea	rax,[rbx+szDefWindowProcA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_DefWindowProcA],rax

	lea	rax,[rbx+szDestroyWindow]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_DestroyWindow],rax

	lea	rax,[rbx+szGetDlgItemTextA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_GetDlgItemTextA],rax

	lea	rax,[rbx+szGetMessageA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_GetMessageA],rax

	lea	rax,[rbx+szDispatchMessageA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_DispatchMessageA],rax

	lea	rax,[rbx+szPostQuitMessage]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_PostQuitMessage],rax

	lea	rax,[rbx+szRegisterClassExA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_RegisterClassExA],rax

	lea	rax,[rbx+szShowWindow]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_ShowWindow],rax

	lea	rax,[rbx+szTranslateAcceleratorA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_TranslateAcceleratorA],rax

	lea	rax,[rbx+szTranslateMessage]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_TranslateMessage],rax

	lea	rax,[rbx+szUpdateWindow]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllUser32],rax
	mov	[rbx+_UpdateWindow],rax




	
	lea	rax,[rbx+szExitProcess]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllKernel32],rax
	mov	[rbx+_ExitProcess],rax

	lea	rax,[rbx+szGetModuleHandleA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllKernel32],rax
	mov	[rbx+_GetModuleHandleA],rax

	lea	rax,[rbx+szlstrcmpA]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllKernel32],rax
	mov	[rbx+_lstrcmpA],rax

	lea	rax,[rbx+szRtlZeroMemory]	
	invoke	[rbx+_GetProcAddress],[rbx+hDllKernel32],rax
	mov	[rbx+_RtlZeroMemory],rax


	
	call _WinMain
	lea rsi,[rbx+szCaptionMain]
	invoke [rbx+_MessageBoxA],NULL,rsi,NULL,MB_OK
; 执行原来的文件
_ToOldEntry:
		db	0e9h	
_dwOldEntry:
		dd	?	
APPEND_CODE_END:
