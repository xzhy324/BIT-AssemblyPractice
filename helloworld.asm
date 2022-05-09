; asm文件注释格式为分号
; 定义程序模式
.386
.model            flat,stdcall
option            casemap    :none

; 包含必要头文件，基本每个win32 汇编程序都需要包含这几个
include            windows.inc
include            user32.inc
includelib    　　　user32.lib
include            kernel32.inc
includelib    　　　kernel32.lib

; 指定对话框ID，该ID要与rc文件中的ID值相同
; 理论上，asm文件与rc文件中的控件是通过ID值关联的，控件名并不需要与rc文件相同，不过为了易看一般取一样的
; 比如这里重点是equ 1，叫不叫DLG_HELLOWORLD无所谓，不过为了易看所以选择与rc文件保持一致
DLG_HELLOWORLD    equ    1

; 数据段
.data?
hInstance    dd    ?

; 代码段
.code
; 对话框处理过程
_ProcDlgHelloworld proc uses ebx edi esi hWnd,wMsg,wParam,lParam
    mov    eax,wMsg
    .if eax == WM_CLOSE
            invoke    EndDialog,hWnd,NULL
    .elseif eax == WM_INITDIALOG
            ;invoke    LoadIcon,hInstance,ICO_MAIN
            ;incoke    SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
    .elseif eax == WM_COMMAND
            mov    eax,wParam
            .if ax == IDOK
                    invoke    EndDialog,hWnd,NULL
            .endif
    .else
            mov    eax,FALSE
            ret
    .endif
    mov    eax,TRUE
    ret
_ProcDlgHelloworld    endp

start:
    invoke    GetModuleHandle,NULL
    mov       hInstance,eax
    ; 弹出对话框，对话框与及处理过程在这里绑定
    invoke    DialogBoxParam,hInstance,DLG_HELLOWORLD,NULL,offset _ProcDlgHelloworld,NULL
    invoke    ExitProcess,NULL
    ; 指定程序入口点为start标识处
    end       start