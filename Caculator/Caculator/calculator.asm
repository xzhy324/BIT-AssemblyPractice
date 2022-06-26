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

memset proto c :ptr sbyte, :byte, :dword
printf PROTO C:ptr sbyte,:vararg  
atof PROTO C:ptr sbyte  
sprintf proto c :ptr sbyte, :ptr sbyte, :vararg
strlen PROTO C:ptr sbyte  

.const
szClassName		db		'MyCalculatorClass',0
szCaptionMain	db		'Calculator',0
ButtonClassName db      'button',0
EditClassName	db		'edit',0

ButtonText1      BYTE "1", 0
ButtonText2      BYTE "2", 0
ButtonText3      BYTE "3", 0
ButtonText4      BYTE "4", 0
ButtonText5      BYTE "5", 0
ButtonText6      BYTE "6", 0
ButtonText7      BYTE "7", 0
ButtonText8      BYTE "8", 0
ButtonText9      BYTE "9", 0
ButtonText0      BYTE "0", 0
ButtonTextAdd    BYTE "+", 0
ButtonTextSub    BYTE "-", 0
ButtonTextMul    BYTE "*", 0
ButtonTextDiv    BYTE "/", 0
ButtonTextEqu    BYTE "=", 0
ButtonTextClr    BYTE "AC", 0
ButtonTextDot	 BYTE ".", 0
ButtonTextSin	 BYTE "sin", 0
ButtonTextSqrt	 BYTE "sqrt", 0
ButtonTextSgn	 BYTE "+/-",0

idEdit			 equ 10
idButtonAdd      equ 11
idButtonSub      equ 12
idButtonMul      equ 13
idButtonDiv      equ 14
idButtonEqu      equ 15
idButtonClr      equ 16
idButtonDot		 equ 17
idButtonSin		 equ 18
idButtonSqrt	 equ 19
idButtonSgn		 equ 20



.data
szBuffer		db		1024	 dup(?)		;输入的字符串
szFmt			db		'%f', 0

nBuffer			dd		0					;输入字符串的当前长度
number1			real8	0.0					
number2			real8	0.0			
op				db		0					;记录运算符

hInstance		HWND	?
hWinMain		HWND	?
hEdit			HWND	?



.code

_ProcWinMain	proc	uses ebx edi esi,hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM


				; 根据消息的类型分发到不同的分支
				mov		eax,uMsg
				.if	uMsg == WM_CLOSE
				;关闭窗口
					invoke DestroyWindow,hWinMain
					invoke PostQuitMessage, NULL

				.elseif uMsg == WM_CREATE
                    
				    ; Add text input
                    invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR EditClassName, NULL, \
                      WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or \
                      ES_AUTOHSCROLL, \
                      30, 30, 165, 30, hWnd, idEdit, hInstance, NULL
                    mov hEdit, eax
                    invoke SetFocus, hEdit
                    ; Buttons
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText1, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      30, 210, 30, 30, hWnd, 1, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText2, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      75, 210, 30, 30, hWnd, 2, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText3, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      120, 210, 30, 30, hWnd, 3, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText4, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      30, 165, 30, 30, hWnd, 4, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText5, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      75, 165, 30, 30, hWnd, 5, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText6, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      120, 165, 30, 30, hWnd, 6, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText7, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      30, 120, 30, 30, hWnd, 7, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText8, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      75, 120, 30, 30, hWnd, 8, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText9, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      120, 120, 30, 30, hWnd, 9, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText0, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      75, 255, 30, 30, hWnd, 0, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextAdd, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      165, 165, 30, 30, hWnd, idButtonAdd, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextSub, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      165, 120, 30, 30, hWnd, idButtonSub, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextMul, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      165, 75, 30, 30, hWnd, idButtonMul, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextDiv, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                      120, 75, 30, 30, hWnd, idButtonDiv, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextEqu, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      165, 210, 30, 30, hWnd, idButtonEqu, hInstance, NULL
                    invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextClr, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      30, 75, 30, 30, hWnd, idButtonClr, hInstance, NULL
					invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextDot, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      120, 255, 30, 30, hWnd, idButtonDot, hInstance, NULL
					invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextSin, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      75, 75, 30, 30, hWnd, idButtonSin, hInstance, NULL
					invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextSqrt, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      165, 255, 30, 30, hWnd, idButtonSqrt, hInstance, NULL
					invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonTextSgn, \
                      WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                      30, 255, 30, 30, hWnd, idButtonSgn, hInstance, NULL
                    
				.elseif uMsg == WM_COMMAND
				;各种事件的分发函数
					mov eax,wParam
					.if  eax >= 0 && eax <= 9 
						mov edx,eax
						add edx,'0'

						mov eax,nBuffer
						mov szBuffer[eax],dl
						inc nBuffer
						mov eax,nBuffer			;在结尾添中止0
						mov szBuffer[eax],0
						invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer


					.elseif eax == idButtonDot
						mov edx,'.'

						mov eax,nBuffer
						mov szBuffer[eax],dl
						inc nBuffer
						mov eax,nBuffer
						mov szBuffer[eax],0
						invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer


					.elseif eax == idButtonClr
						mov nBuffer,0
						mov szBuffer[0],0
						invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer


					.elseif eax == idButtonSin || eax == idButtonSqrt ;单目算符
						;num1 = atof(buf)
						fclex			;clear exception
						finit			
						invoke atof,offset szBuffer
						fst	number1
						fld number1
						;num1 = op(num1)
						.if wParam == idButtonSin
						fsin
						.elseif wParam == idButtonSqrt
						fsqrt
						.endif
						;edit <- buf
						fst number1
						invoke sprintf,offset szBuffer,offset szFmt,number1
						invoke strlen,offset szBuffer
						mov nBuffer,eax
						invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer


					.elseif wParam == idButtonAdd || wParam == idButtonSub \
							|| wParam == idButtonMul || wParam == idButtonDiv;双目算符
						;num1 = atof(num1)
						fclex			;clear exception
						finit			
						invoke atof,offset szBuffer
						fst	number1
						;op <- button
						.if wParam == idButtonAdd
						mov op,'+'
						.elseif wParam == idButtonSub
						mov op,'-'
						.elseif wParam == idButtonMul
						mov op,'*'
						.elseif wParam == idButtonDiv
						mov op,'/'
						.endif	
						;clear buf
						mov nBuffer,0
						mov szBuffer[0],0
						invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer


					.elseif eax == idButtonEqu
						;num2 = atof(buf)
						fclex			;clear exception
						finit			
						invoke atof,offset szBuffer
						fst	number2
						;num1 = num1 op num2
						fld number2
						fld number1
						.if op == '+'
							fadd
						.elseif op == '-'
							fsub
						.elseif op == '*'
							fmul
						.elseif op == '/'
							fdiv st(0),st(1)
						.endif
						;edit <- buf
						fst number1
						invoke sprintf,offset szBuffer,offset szFmt,number1
						invoke strlen,offset szBuffer
						mov nBuffer,eax
						invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer


					.elseif eax == idButtonSgn
						;判断首字符是否是减号
						xor eax,eax
						mov al,szBuffer[0]
						.if eax == '-'
							;负数，将数字位前移一格转为正数
							mov eax,1
							.while eax < nBuffer
								mov dl,szBuffer[eax]
								mov szBuffer[eax-1],dl
								inc eax
							.endw
							mov eax,nBuffer
							dec eax
							mov szBuffer[eax],0
							mov nBuffer,eax
							invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer
						.else
							;正数，将数字后移,添加负号
							mov eax,nBuffer
							.while eax > 0
								mov dl,szBuffer[eax-1]
								mov szBuffer[eax],dl
								dec eax
							.endw
							mov szBuffer[0],'-'
							inc nBuffer
							mov eax,nBuffer
							mov szBuffer[eax],0
							invoke	SetDlgItemText,hWnd,idEdit,offset szBuffer 
						.endif

					.endif	
				.else
				;其余事件
					invoke DefWindowProc, hWnd,uMsg,wParam,lParam
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
						250,340,\
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

main:
				
				call	_WinMain	
				invoke	ExitProcess,NULL

end main

