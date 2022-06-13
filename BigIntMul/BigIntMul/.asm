.386	
.model flat, stdcall
option	casemap:none

include		windows.inc
include		user32.inc
include		kernel32.inc
include		msvcrt.inc
includelib	user32.lib
includelib	kernel32.lib
includelib  msvcrt.lib

sprintf PROTO C :ptr sbyte, :ptr sbyte, :VARARG



.const
szClassName		db		'MyTextCmpClass',0
szCaptionMain	db		'Text Aligner',0
szButtonClass   db      'button',0
szEditClass		db		'edit',0
szButtonText	db		'Compare',0
szMsgBoxCap		db		'Result',0
szFmt			db		'Diff Line:%d',0AH,0
szMsgNoDiff		db		'The contents of input files are duplicated',0

idEdit1			equ		1
idEdit2			equ		2
idButton		equ		3



.data
szBuffer		db		1024	 dup(?)		;用于打印的内容
szBufLine1		db		1024	 dup(?)		;存储文件1读入的当前行
szBufLine2		db		1024	 dup(?)		;存储文件2读入的当前行
szFile1			db		MAX_PATH dup(?)		;文件1路径
szFile2			db		MAX_PATH dup(?)		;文件2路径
nDiff			dd		?					;不同行的个数

hInstance		HWND	?
hWinMain		HWND	?
hEdit1			HWND	?
hEdit2			HWND	?
hButton			HWND	?
hFile1			HWND	?
hFile2			HWND	?


.code


_ReadLine		proc	uses ebx, _hFile:HANDLE, _lpBuffer:ptr byte	;lpBuffer：存放读入一行的指针
				local	@dwBytesRead:dword		;保存每次调用readfile函数读入的字符数
				local	@ch:byte				;保存每次读入的字符
				mov		ebx,_lpBuffer			
				.while	TRUE
					;每次读入一个字符
					invoke ReadFile,_hFile,addr @ch,1,addr @dwBytesRead,NULL
					;读到空或者换行符都结束这一行的读入
					.break .if @dwBytesRead == 0
					.break .if @ch == 10		
					;将字符赋给ebx所指的内存区域
					mov al,@ch
					mov [ebx],al
					inc	ebx
				.endw

				;为读入的一行添加0结尾
				mov al,0
				mov [ebx],al
				;将本行长度保存在eax中
				invoke lstrlen,_lpBuffer
				ret
_ReadLine		endp

_Compare		proc
				local @nLineSize1:dword
				local @nLineSize2:dword	
				local @line:dword
				local @pdiff[1000]:byte

				invoke CreateFile, offset szFile1,GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
				mov	hFile1,eax
				invoke CreateFile, offset szFile2,GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
				mov hFile2,eax
			
				mov @line,0
				mov nDiff,0

readline:		inc @line
				invoke  RtlZeroMemory,offset szBufLine1,sizeof szBufLine1
				invoke	_ReadLine	,hFile1,offset szBufLine1
				mov @nLineSize1,eax
				invoke  RtlZeroMemory,offset szBufLine2,sizeof szBufLine2
				invoke	_ReadLine	,hFile2,offset szBufLine2
				mov @nLineSize2,eax


cmp1:			cmp @nLineSize1,0
				jne cmp2			;行1长度不为0再看行二是否不为0
				cmp @nLineSize2,0
				je	Finish			;若文件1，2读入的当前行长度都为0，说明文件已读完，转打印处理
				;此时nline1为0，nline2不为0，转行号记录


WriteBuffer:	invoke sprintf,addr @pdiff,offset szFmt,@line	;构造一行提示信息
				invoke lstrcat,offset szBuffer,addr @pdiff		;将该提示信息附加到全局打印缓冲区
				inc	nDiff
				jmp	readline


cmp2:			;此时nline1 > 0 ，nline2未知
				cmp @nLineSize2,0
				je	WriteBuffer		;此时nline1 >0 ,nline2 ==0 ，转行号记录
				;此时两行长度都不为0
				invoke lstrcmp,offset szBufLine1,offset szBufLine2
				cmp eax,0
				je	readline		;相同则不做操作
				jmp	WriteBuffer		;否则转行号记录程序


Finish:			invoke CloseHandle,hFile1
				invoke CloseHandle,hFile2
				ret
_Compare		endp

_ProcWinMain	proc	uses ebx edi esi,handle:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM


				; 根据消息的类型分发到不同的分支
				mov		eax,uMsg
				.if	uMsg == WM_CLOSE
				;关闭窗口
					invoke DestroyWindow,hWinMain
					invoke PostQuitMessage, NULL

				.elseif uMsg == WM_CREATE
				
				;窗口初始化之后生成控件
				    ;放置输入栏
                    invoke CreateWindowEx,WS_EX_CLIENTEDGE, offset szEditClass, NULL, \
                      WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL, \
                      90, 30, 300, 30, handle, idEdit1, hInstance, NULL
                    mov hEdit1, eax
                    invoke SetFocus, hEdit1

					invoke CreateWindowEx,WS_EX_CLIENTEDGE, offset szEditClass, NULL, \
                      WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or ES_AUTOHSCROLL, \
                      90, 90, 300, 30, handle, idEdit2, hInstance, NULL
                    mov hEdit2, eax
                    ;放置按钮
                    invoke CreateWindowEx, NULL, OFFSET szButtonClass, ADDR szButtonText, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      200, 210, 80, 30, handle, idButton, hInstance, NULL
                    mov hButton, eax  ;此时eax中存的是创建按钮的句柄
                    
				.elseif uMsg == WM_COMMAND
				;各种事件的分发函数
					.if wParam == idButton
						;获取文件名
						invoke	GetDlgItemText,handle,idEdit1,offset szFile1,sizeof szFile1
						invoke	GetDlgItemText,handle,idEdit2,offset szFile2,sizeof	szFile2
                        ;invoke	SetDlgItemText,handle,idEdit2,offset szFile1
						invoke _Compare	;比对两个文本，将需要打印的内容保存在szBuffer中
						.if nDiff == 0
							invoke MessageBox, NULL, offset szMsgNoDiff,offset szMsgBoxCap,MB_OK
						.else
							invoke MessageBox, NULL, offset szBuffer,offset szMsgBoxCap,MB_OK
						.endif
						
					.endif	
				.else
				;其余事件
					invoke DefWindowProc, handle,uMsg,wParam,lParam
					ret
				.endif
				xor eax,eax	
				ret
_ProcWinMain	endp

_WinMain		proc
				local	@stWndClass:WNDCLASSEX
				local	@stMsg:MSG

				invoke	GetModuleHandle,NULL
				mov		hInstance,eax
				invoke	RtlZeroMemory,addr @stWndClass, sizeof @stWndClass

				;注册窗口类
				invoke	LoadCursor,0,IDC_ARROW
				mov		@stWndClass.hCursor,eax
				push	hInstance
				pop		@stWndClass.hInstance
				mov		@stWndClass.cbSize, sizeof WNDCLASSEX
				mov		@stWndClass.style,CS_HREDRAW or CS_VREDRAW
				mov		@stWndClass.lpfnWndProc,offset _ProcWinMain
				mov		@stWndClass.hbrBackground,COLOR_BTNFACE+1
				mov		@stWndClass.lpszClassName,offset szClassName
				invoke	RegisterClassEx, addr @stWndClass

				;建立并显示窗口
				invoke	CreateWindowEx,WS_EX_CLIENTEDGE,\
						offset szClassName, offset szCaptionMain,\
						WS_OVERLAPPEDWINDOW,\
						CW_USEDEFAULT,CW_USEDEFAULT,\
						480,320,\
						NULL,NULL,hInstance,NULL
				mov		hWinMain,eax
				invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
				invoke	UpdateWindow,hWinMain

				;消息循环
				.while TRUE
					invoke	GetMessage,addr @stMsg,NULL,0,0
					.break	.if eax == 0
					invoke	TranslateMessage, addr @stMsg
					invoke	DispatchMessage, addr @stMsg
				.endw
				ret

_WinMain		endp

start:
				
				call	_WinMain	
				invoke	ExitProcess,NULL

end start

