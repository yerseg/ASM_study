.686
.model flat, stdcall
option casemap :none

include D:\Dev\MASM\include\windows.inc
include D:\Dev\MASM\include\msvcrt.inc
include D:\Dev\MASM\include\kernel32.inc
include D:\Dev\MASM\include\user32.inc
include D:\Dev\MASM\include\gdi32.inc
include D:\Dev\MASM\include\masm32.inc

includelib D:\Dev\MASM\lib\kernel32.lib
includelib D:\Dev\MASM\lib\msvcrt.lib
includelib D:\Dev\MASM\lib\user32.lib
includelib D:\Dev\MASM\lib\gdi32.lib
includelib D:\Dev\MASM\lib\masm32.lib

.data
	fmt db "%c",2,0
	hConsoleInput dd ?
	hConsoleOutput dd ?
	
	string dd 100 dup (0)
	finish db 1 dup (0)
	
	NumberOfCharsWritten dd ?
	NumberOfCharsRead dd ?	
	msg0 db "  Choose work mode: (1) keyboard, (2) file:  ", 0
	msg1 db "  Enter a string to process:  ", 0
	msg2 db " Number of duplicate items:  ", 0
	msg3 db " Press any key to exit or '1' to continue:  ", 0
	msg4 db " Enter a path to write answer:  ", 0
	msg5 db " Enter a path to process:  ", 0
	msgbox2 db "Not found",0
	msg1310 db 13, 10
	
	nBytes dword ?
	fHandle dword ?
	cWritten dword ?
	hFile dword ?
	cRead DWORD ?
	stdout DWORD ?
	lpNumberOfBytesWritten dd ?
	buf dd 0
	hFileOut dd ?
	number dd 10
	
	flag dd ?
	path db 100 dup (0)
	
	alphabet db "BCDFGHJKLMNPQRSTVWXYZ", 0
	alphabet_low db "bcdfghjklmnpqrstvwxyz", 0
	len_str db ?
	len_alphabet db 21
	
	count db ?
	count_low db ?
	ans db 125 dup (0)
	
.code
assume ds:@data, es:@data

main:

	invoke AllocConsole

	invoke GetStdHandle, STD_INPUT_HANDLE
	mov hConsoleInput, eax
	
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov hConsoleOutput, eax
	
	invoke CharToOem, ADDR msg0, ADDR msg0
	invoke WriteConsoleA, hConsoleOutput, ADDR msg0, (SIZEOF msg0) - 1, ADDR NumberOfCharsWritten, 0
	
	invoke ReadConsoleA, hConsoleInput, ADDR flag, 1, ADDR NumberOfCharsRead, 0
	lea edi, flag
	mov bl, [edi]
	
	cmp bl, 31h
	jz console
	cmp bl, 32h
	jz file
	jmp main
	
console:	
	invoke CharToOem, ADDR msg1, ADDR msg1
	invoke WriteConsoleA, hConsoleOutput, ADDR msg1, (SIZEOF msg1) - 1, ADDR NumberOfCharsWritten, 0

	lea eax, string
	mov ecx, 100d
	xor ebx, ebx
clean:
	mov [eax], ebx
	inc eax
	loop clean
	
	invoke ReadConsoleA, hConsoleInput, ADDR string, 100, ADDR NumberOfCharsRead, 0
	invoke ReadConsoleA, hConsoleInput, ADDR string, 100, ADDR NumberOfCharsRead, 0

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	lea edi, string
	mov ebx, edi
	
string_len:	
	mov al, [edi]
	inc edi
	or al, 0h
	jnz string_len
	
	sub edi, ebx
	lea eax, len_str
	mov [eax], edi
	
	lea ebx, alphabet
	add ebx, 21d
	lea esi, len_str
	
scan_str:
	lea edi, string
	mov eax, [ebx]
	mov ecx, [esi]
	repne scasb
	or cl, 0h
	jz @
	push eax
	inc edx
	
@:
	dec ebx
	lea eax, alphabet
	sub eax, ebx
	cmp eax, 2h
	jnz scan_str
	
	lea eax, count
	mov [eax], dl
	
	xor edx, edx
	
get:
	lea eax, count
	mov ebx, [eax]
	cmp bl, 0h
	jz next
	
	pop eax
	cbw
	cwde
	
	lea ecx, ans
	add ecx, edx
	
	mov [ecx], al
	
	inc edx
	cmp dl, bl
	jnz get
	
;=======================
next:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	lea ebx, alphabet_low
	add ebx, 21d
scan_str_low:
	lea edi, string
	mov eax, [ebx]
	xor ecx, ecx
	mov cl, [esi]
	cbw
	cwde
	repne scasb
	or cl, 0h
	jz @@@
	push eax
	inc edx
	
@@@:
	dec ebx
	lea eax, alphabet_low
	sub eax, ebx
	cmp eax, 2h
	jnz scan_str_low
	
	lea eax, count_low
	mov [eax], dl
	
	xor edx, edx
	
get_low:
	lea eax, count_low
	mov bl, [eax]
	
	cmp bl, 0h
	jz final
	
	pop eax
	cbw
	cwde
	
	lea ecx, count
	mov bl, [ecx]
	
	lea ecx, ans
	add cl, dl
	add cl, bl
	
	mov [ecx], al
	
	lea eax, count_low
	mov ebx, [eax]
	
	inc edx
	cmp dl, bl
	jnz get_low

final:	
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	lea ebx, count
	mov dl, [ebx]
	lea ebx, count_low
	add al, [ebx]
	add al, dl
	push eax
	
	lea ecx, ans
	pop eax
	cbw
	cwde
	add ecx, eax
	
	mov bl, 0h
	mov [ecx], bl
	
	invoke CharToOem, ADDR ans, ADDR ans
	invoke WriteConsoleA, hConsoleOutput, ADDR ans, (SIZEOF ans) - 1, ADDR NumberOfCharsWritten, 0

	invoke CharToOem, ADDR msg3, ADDR msg3
	invoke WriteConsoleA, hConsoleOutput, ADDR msg3,(SIZEOF msg3) - 1, ADDR NumberOfCharsWritten, 0

	invoke ReadConsoleA, hConsoleInput, ADDR finish, 3, ADDR NumberOfCharsRead, 0
	
	lea edi, finish
	mov bl, [edi]
	
	cmp bl, 31h
	
	jz main
	jmp ifn
	
	invoke ExitProcess, 0

file:
	invoke CharToOem, ADDR msg5, ADDR msg5
	invoke WriteConsoleA, hConsoleOutput, ADDR msg5, (SIZEOF msg5) - 1, ADDR NumberOfCharsWritten, 0
	
	lea eax, string
	mov ecx, 100d
	xor ebx, ebx
clean_f:
	mov [eax], ebx
	inc eax
	loop clean_f
	
	invoke ReadConsoleA, hConsoleInput, ADDR path, 100, ADDR NumberOfCharsRead, 0
	invoke ReadConsoleA, hConsoleInput, ADDR path, 100, ADDR NumberOfCharsRead, 0
	
	push eax
	push ebx
	push edx
	
	lea eax, NumberOfCharsRead
	mov ebx, [eax]
	sub ebx, 2h
	lea eax, path
	add eax, ebx
	xor edx, edx
	mov [eax], edx
	
	pop edx
	pop ebx
	pop eax
	
	mov stdout, eax
	invoke CreateFile,
		addr path,
		GENERIC_READ,
		0,
		NULL,
		OPEN_ALWAYS,
		FILE_ATTRIBUTE_NORMAL,
		NULL
		
    mov fHandle, eax
    invoke GetFileSize, hFile, NULL
    mov nBytes, eax
    invoke ReadFile,fHandle,addr string,100,addr cRead,NULL
    invoke MessageBox,0,addr string,addr msgbox2,0
	
	invoke CloseHandle, fHandle
	
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	lea edi, string
	mov ebx, edi
	
string_len_f:	
	mov al, [edi]
	inc edi
	or al, 0h
	jnz string_len_f
	
	sub edi, ebx
	lea eax, len_str
	mov [eax], edi
	
	lea ebx, alphabet
	add ebx, 21d
	lea esi, len_str
	
scan_str_f:
	lea edi, string
	mov eax, [ebx]
	mov ecx, [esi]
	repne scasb
	or cl, 0h
	jz @_f
	push eax
	inc edx
	
@_f:
	dec ebx
	lea eax, alphabet
	sub eax, ebx
	cmp eax, 2h
	jnz scan_str_f
	
	lea eax, count
	mov [eax], dl
	
	xor edx, edx
	
get_f:
	lea eax, count
	mov ebx, [eax]
	cmp bl, 0h
	jz next_f
	
	pop eax
	cbw
	cwde
	
	lea ecx, ans
	add ecx, edx
	
	mov [ecx], al
	
	inc edx
	cmp dl, bl
	jnz get_f
	
;=======================
next_f:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	lea ebx, alphabet_low
	add ebx, 21d
scan_str_low_f:
	lea edi, string
	mov eax, [ebx]
	xor ecx, ecx
	mov cl, [esi]
	cbw
	cwde
	repne scasb
	or cl, 0h
	jz @@@_f
	push eax
	inc edx
	
@@@_f:
	dec ebx
	lea eax, alphabet_low
	sub eax, ebx
	cmp eax, 2h
	jnz scan_str_low_f
	
	lea eax, count_low
	mov [eax], dl
	
	xor edx, edx
	
get_low_f:
	lea eax, count_low
	mov bl, [eax]
	
	cmp bl, 0h
	jz final_f
	
	pop eax
	cbw
	cwde
	
	lea ecx, count
	mov bl, [ecx]
	
	lea ecx, ans
	add cl, dl
	add cl, bl
	
	mov [ecx], al
	
	lea eax, count_low
	mov ebx, [eax]
	
	inc edx
	cmp dl, bl
	jnz get_low_f

final_f:	
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	
	lea ebx, count
	mov dl, [ebx]
	lea ebx, count_low
	add al, [ebx]
	add al, dl
	push eax
	
	lea ecx, ans
	pop eax
	cbw
	cwde
	add ecx, eax
	
	mov bl, 0h
	mov [ecx], bl
	
	invoke CharToOem, ADDR ans, ADDR ans
	invoke WriteConsoleA, hConsoleOutput, ADDR ans, (SIZEOF ans) - 1, ADDR NumberOfCharsWritten, 0

invoke CharToOem, ADDR msg4, ADDR msg4
	invoke WriteConsoleA, hConsoleOutput, ADDR msg4, (SIZEOF msg4) - 1, ADDR NumberOfCharsWritten, 0
	invoke ReadConsoleA, hConsoleInput, ADDR path, 100, ADDR NumberOfCharsRead, 0
	
	push eax
	push ebx
	push edx
	
	lea eax, NumberOfCharsRead
	mov ebx, [eax]
	sub ebx, 2h
	lea eax, path
	add eax, ebx
	xor edx, edx
	mov [eax], edx
	
	pop edx
	pop ebx
	pop eax
	
	invoke CreateFile,addr path,    ;Открываем файл
            GENERIC_WRITE,
            0,
            NULL,
            CREATE_ALWAYS,
            FILE_ATTRIBUTE_NORMAL,
            NULL
    mov hFileOut,eax
	
	invoke WriteFile, hFileOut, addr ans, number, addr number, NULL
   
	invoke CloseHandle, hFileOut

	invoke CharToOem, ADDR msg3, ADDR msg3
	invoke WriteConsoleA, hConsoleOutput, ADDR msg3,(SIZEOF msg3) - 1, ADDR NumberOfCharsWritten, 0

	invoke ReadConsoleA, hConsoleInput, ADDR finish, 3, ADDR NumberOfCharsRead, 0
	
	lea edi, finish
	mov bl, [edi]
	
	cmp bl, 31h
	
	jz main
	jmp ifn
	
	invoke ExitProcess, 0
	
	
	
ifn:	
	ret
	
end main