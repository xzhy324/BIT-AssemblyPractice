.486
.model flat, stdcall
.stack 4096
option casemap:none

includelib  msvcrt.lib
include		msvcrt.inc

printf	proto C, :ptr sbyte,:vararg
scanf	proto C, :dword,	:vararg

ExitProcess PROTO, dwExitCode:dword


.data
	szOutFmt	byte	'%d',0
	szInFmt		byte	'%s',0
	szMsg		byte	'Testing!',0ah,0	;0ah代表换行符
		
	x			dd	128 dup(?)
	y			dd	128 dup(?)
	tmpinput	db	128 dup(?)	;字节数组供输入，需要扩展
	ans			dd	256 dup(0)
	xlen		dd	?
	ylen		dd	?
	pr			dd	?
	numBase		dd	10


.code

char2int		proc	stdcall	s:ptr byte,\
								numptr:ptr dword,\
								slen:dword
				push edi
				push esi
				push ecx
				push eax
				mov esi,s
				mov edi,numptr
				mov ecx,slen
convertLoop:
				movzx eax, byte ptr[esi]
				sub eax,'0'
				mov [edi], eax
				add edi,4
				add esi,1
				loop convertLoop

				pop eax
				pop ecx
				pop esi
				pop edi

				ret
char2int		endp

invertNum		proc stdcall a:ptr dword, alen:dword
				push ecx
				push ebx
				push eax
				push esi
				
				mov esi,a		;保存首地址

				mov eax,0
				mov ebx,alen
				sub ebx,1		;初始化需要维护的对称下标

				mov ecx,alen
				shr ecx,1
				add ecx,1		;计算循环次数
				
invertLoop:
				push dword ptr[esi+eax*4]	
				push dword ptr[esi+ebx*4]
				pop  dword ptr[esi+eax*4]
				pop  dword ptr[esi+ebx*4]			;利用堆栈交换
				add eax,1
				sub ebx,1
				loop invertLoop


				pop esi
				pop eax
				pop ebx
				pop ecx
				ret
invertNum		endp
				

mulAndAdd		proc stdcall num1:ptr dword,\
							 num2:ptr dword,\
							 result:ptr dword
				local i,j:dword

				push eax
				push ebx
				push ecx
				push edx
				mov i,0
outerLoop:
				mov j,0
innerLoop:
				mov ebx,i
				add ebx,j						
				shl ebx,2					;乘4是为了正确的间隔
				add ebx,result				;此时ebx中存放了ans[i+j]的偏移量

				mov ecx,i
				shl ecx,2
				add ecx,num1				;取出x[i]的偏移，带有内存变量的寻址最好把各种偏移量都放在寄存器里再使用比例寻址
				mov eax,[ecx]
				
				mov ecx,j
				shl ecx,2
				add ecx,num2				;取出y[j]的偏移
				
				mul dword ptr[ecx]			;计算x[i]*y[j]
				
				add [ebx],eax				;eax中存放乘完的结果
				add j,1						;j++
				mov ecx,j
				cmp ecx,ylen
				jb	innerLoop				;回到内层循环

				add i,1
				mov ecx,i
				cmp ecx,xlen				;i++
				jb	outerLoop				;回到外层循坏

				pop edx
				pop ecx
				pop ebx
				pop eax
				ret
mulAndAdd		endp
				


start:
	invoke	printf,	offset szMsg

	invoke	scanf, offset szInFmt, offset tmpinput
	invoke	crt_strlen, offset tmpinput					;统计输入字符串长度,结果放在eax中
	mov xlen , eax
	invoke  char2int, offset tmpinput, offset x, xlen	;将单字节字符减去'0'后再扩充为4字节数字
	invoke invertNum, offset x, xlen					;将数字按中轴对称翻转

	invoke	scanf, offset szInFmt, offset tmpinput
	invoke	crt_strlen, offset tmpinput					;统计输入字符串长度,结果放在eax中
	mov ylen , eax
	invoke  char2int, offset tmpinput, offset y, ylen	;将单字节字符减去'0'后再扩充为4字节数字
	invoke invertNum, offset y, ylen					;将数字按中轴对称翻转
	
	invoke mulAndAdd, offset x,offset y,offset ans		;不带进位的计算结果

	
	mov pr,0											;从最低位开始传播进位
whileStart:
	mov ecx,pr
	shl ecx,2
	add ecx,offset ans
	mov eax,[ecx]
	mov edx,0					;一定要记得先扩展到edx或者清零edx再除
	div numBase					;remainder=>edx  ,  quotient=>eax

	mov [ecx],edx
	cmp eax,0
	je nocarry
	add [ecx+4],eax
nocarry:
	add pr,1
	cmp pr,256
	jb whileStart
	
	
	
	;找到首非零位
	mov pr,255
	mov edx,pr
	shl edx,2
	mov esi,offset ans
loop1:
	sub edx,4
	mov eax,[edx+esi]
	cmp eax,0
	je loop1

	add edx,4
	mov ebx,edx
loop2:
	sub ebx,4
	mov eax,[esi+ebx]
	invoke printf, offset szOutFmt,eax			;这函数还能自己改edx的？改了还不帮我恢复，你的堆栈平衡做到哪去了？，为什么变量不能直接用变址寻址啊？
	cmp ebx,0
	ja loop2

	invoke ExitProcess,0
end start