;Ҫ���û��õ�������FAT32��NTFS���Ĵ�С��ʣ��ռ䡣
;���ߣ�MASMPlus
;���л�����Windows XP,Windows 7

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
	top db "��ȡ������Ϣ",0
	allInfo db 2048 dup(?),0;��¼���������������Ϣ
	crlf	 db	0DH,0AH,0
	numStringStyle db "%d",0
	MB db "MB",0
	styleMessg db "�̷�����:",0
	avalibleSpaceMessg db "ʣ��ռ�:",0
	totalSpaceMessg db "��С:",0
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
	
	call getDriveNum;��ȡϵͳ���߼������������������ŵ�driveNum�б���
	
	
	
;ѭ�����������뵽allInfo��ÿһ��ѭ����һ���̵����ݣ��ж�����Ϊecx
	mov ecx,driveNum
	lea eax,driveMessg
	sub eax,4
.repeat
		add eax,4
		push eax
		push ecx
		;��ȡһ��driveMessg�ַ����е��̷�
		lea edx,rootPathName
		mov bl,BYTE ptr [eax]
		mov BYTE ptr [edx],bl
		mov bl,BYTE ptr [eax+1]
		mov BYTE ptr [edx+1],bl
		mov bl,BYTE ptr [eax+2]
		mov BYTE ptr [edx+2],bl
		mov bl,BYTE ptr [eax+3]
		mov BYTE ptr [edx+3],bl
		
		;�����Ϣ
		invoke RtlZeroMemory,addr volName, 4
		invoke RtlZeroMemory,addr driveStyle, 4
		lea edx,totalNumberOfBytes
		mov [edx],DWORD ptr[0]
		lea edx,freeBytesAvailableToCaller
		mov [edx],DWORD ptr[0]
		
		
		;��ȡ�����������Ϣ
		invoke GetDriveType,addr rootPathName
		invoke GetVolumeInformation,addr	rootPathName,addr	volName,128,NULL,NULL,NULL,addr driveStyle,9
		invoke GetDiskFreeSpaceEx,addr rootPathName,addr freeBytesAvailableToCaller,addr totalNumberOfBytes,addr totalNumberOfFreeBytes
		
		;���̷���Ϣ���ӵ�allInfo�У���������Ĭ��ʱΪ�գ���ʽ��������   C:\Windows7
		invoke szMultiCat,3,addr allInfo,addr rootPathName,addr volName,addr crlf
		;���̷��������ӵ�allInfo�У���ʽ��������   �̷�����:NTFS
		invoke szMultiCat,3,addr allInfo,addr styleMessg,addr driveStyle,addr crlf
		
		;�����С����ʽ�� ��С��(��ֵ)MB
		;����totalNumberOfBytes���ص���ֵ����������Ҫ��һ������
		mov eax,DWORD ptr totalNumberOfBytes
		mov edx,DWORD ptr totalNumberOfBytes[4]
		;���ֽ�ת����
		mov ebx,1024*1024
		div ebx
		invoke wsprintf,addr numStrings,addr numStringStyle,eax;�û�����ת��numStringsΪ�ַ���
		invoke szMultiCat,4,addr allInfo,addr totalSpaceMessg,addr numStrings,addr MB,addr crlf
		
		;ͬ��
		;���ʣ��ռ䡣��ʽ�� ʣ��ռ䣺(��ֵ)MB
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
	;ѭ������
	
	
	;��ʾ����
	invoke	MessageBox,NULL,addr allInfo,addr top,MB_OK;��ʾ����
	invoke ExitProcess,0;�˳�����
	
	
	;��ȡϵͳ���߼�����������
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