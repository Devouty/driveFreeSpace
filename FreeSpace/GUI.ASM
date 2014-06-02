;要求：用汇编得到分区（FAT32或NTFS）的大小和剩余空间。
;工具：MASMPlus
;运行环境：Windows XP,Windows 7

.386
.Model Flat, StdCall
Option Casemap :None

Include windows.inc
Include user32.inc
Include kernel32.inc
Include gdi32.inc
Include	masm32.inc

Includelib gdi32.lib
IncludeLib user32.lib
IncludeLib kernel32.lib
Includelib masm32.lib
Include macro.asm

.data
	top db "获取磁盘信息",0
	allInfo db 2048 dup(?),0;记录程序所需的所有信息
	crlf	 db	0DH,0AH,0
	numStringStyle db "%d",0
	MB db "MB",0
	styleMessg db "盘符类型:",0
	avalibleSpaceMessg db "剩余空间:",0
	totalSpaceMessg db "大小:",0
	nullMessg dq 0
.data?
	driveNum dd ?
	rootPathName dq ?
	freeBytesAvailableToCaller dq ?
	driveMessg db 1024 dup(?)
	totalNumberOfBytes dq ?
	totalNumberOfFreeBytes dq ?
	driveStyle dq ?
	volName	 dq ?
	numStrings dd ?
.CODE
START:
	invoke GetLogicalDriveStrings,1024,addr driveMessg
	
	call getDriveNum;获取系统中逻辑驱动器的数量，并放到driveNum中保存
	
	
	
;循环将数据输入到allInfo，每一次循环放一个盘的内容，判断条件为ecx
	mov ecx,driveNum
	lea eax,driveMessg
	sub eax,4
.repeat
		add eax,4
		push eax
		push ecx
		;获取一个driveMessg字符串中的盘符
		lea edx,rootPathName
		mov bl,BYTE ptr [eax]
		mov BYTE ptr [edx],bl
		mov bl,BYTE ptr [eax+1]
		mov BYTE ptr [edx+1],bl
		mov bl,BYTE ptr [eax+2]
		mov BYTE ptr [edx+2],bl
		mov bl,BYTE ptr [eax+3]
		mov BYTE ptr [edx+3],bl
		
		;清空信息
		invoke RtlZeroMemory,addr volName, 4
		invoke RtlZeroMemory,addr driveStyle, 4
		lea edx,totalNumberOfBytes
		mov [edx],DWORD ptr[0]
		lea edx,freeBytesAvailableToCaller
		mov [edx],DWORD ptr[0]
		
		
		;获取所需的所有信息
		invoke GetDriveType,addr rootPathName
		invoke GetVolumeInformation,addr	rootPathName,addr	volName,128,NULL,NULL,NULL,addr driveStyle,9
		invoke GetDiskFreeSpaceEx,addr rootPathName,addr freeBytesAvailableToCaller,addr totalNumberOfBytes,addr totalNumberOfFreeBytes
		
		;将盘符信息添加到allInfo中，其中名字默认时为空，格式（例）：   C:\Windows7
		invoke szMultiCat,3,addr allInfo,addr rootPathName,addr volName,addr crlf
		;将盘符类型添加到allInfo中，格式（例）：   盘符类型:NTFS
		invoke szMultiCat,3,addr allInfo,addr styleMessg,addr driveStyle,addr crlf
		
		;输出大小。格式： 大小：(数值)MB
		;由于totalNumberOfBytes返回的数值过大，这里需要做一个处理
		mov eax,DWORD ptr totalNumberOfBytes
		mov edx,DWORD ptr totalNumberOfBytes[4]
		;由字节转到兆
		mov ebx,1024*1024
		div ebx
		invoke wsprintf,addr numStrings,addr numStringStyle,eax;用缓冲区转化numStrings为字符串
		invoke szMultiCat,4,addr allInfo,addr totalSpaceMessg,addr numStrings,addr MB,addr crlf
		
		;同上
		;输出剩余空间。格式： 剩余空间：(数值)MB
		mov eax,DWORD ptr freeBytesAvailableToCaller
		mov edx,DWORD ptr freeBytesAvailableToCaller[4]
		mov ebx,1024*1024
		div ebx
		invoke wsprintf,addr numStrings,addr numStringStyle,eax
		invoke szMultiCat,5,addr allInfo,addr avalibleSpaceMessg,addr numStrings,addr MB,addr crlf,addr crlf
		
		pop ecx
		pop eax
		dec ecx
		
.until ecx==0
	;循环结束
	
	
	;显示窗口
	invoke	MessageBox,NULL,addr allInfo,addr top,MB_OK;显示界面
	invoke ExitProcess,0;退出进程
	
	
	;获取系统中逻辑驱动器数量
getDriveNum:
	lea eax,driveMessg
	xor ecx,ecx
	dec eax
getNum:
	inc eax
	cmp BYTE ptr [eax],0
	
	jne getNum
	cmp BYTE ptr [eax+1],0
	je endProg
	inc ecx
	jmp getNum
endProg:
	mov driveNum,ecx
	ret
	
	
	
	
END START