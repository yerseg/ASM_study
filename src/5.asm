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
	fmt db "%u",10,0
	msg0 db "  Choose work mode: (1) keyboard, (2) file:  ", 0
	msg1 db " Enter a string to process:  ", 0
	msg2 db " Number of duplicate items:  ", 0
	msg3 db " Press any key to exit or '1' to continue:  ", 0
	msg4 db " Enter a path to write answer:  ", 0
	msg5 db " Enter a path to process:  ", 0
	msgbox2 db "Not found",0
	msg1310 db 13, 10
	
	hConsoleInput dd ?
	hConsoleOutput dd ?
	NumberOfCharsWritten dd ?
	NumberOfCharsRead dd ?	
	
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
	finish db 1 dup (0)
	
	string db 100 dup (0)
	len db ?
	result db ?
	restart db ?
	path db 100 dup (0)
	
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
	
	lea edi, string
	mov ebx, edi
	
string_len:	
	mov al, [edi]
	inc edi
	or al, 0h
	jnz string_len
	
	sub edi, ebx
	lea eax, len
	mov [eax], edi
	
	;Поиск a - z
	xor edx, edx
	mov bl, 26d

count_low:	
	push edx
	xor edx, edx
	
	dec bl
	cmp bl, -1d
	jz final_low
	
	xor ecx, ecx
	mov cl, len
	mov al, 61h
	add al, bl
	cbw
	cwde
	lea edi, string

search_low:
	repne scasb 
	or ecx, 0h
	jz count_low
	inc edx
	jmp search_low
	
final_low:
	mov ecx, 27d
	xor edx, edx
	
process_low:
	pop eax
	dec ecx
	cmp eax, 1d
	jz process_low
	add edx, eax
	or ecx, 0b
	jnz process_low
	
;Поиск A - Z
	push edx
	xor edx, edx
	mov bl, 26d
	
count_high:	
	push edx
	xor edx, edx
	
	dec bl
	cmp bl, -1d
	jz final_high
	
	xor ecx, ecx
	mov cl, len
	mov al, 41h
	add al, bl
	cbw
	cwde
	lea edi, string

search_high:
	repne scasb 
	or ecx, 0h
	jz count_high
	inc edx
	jmp search_high
	
final_high:
	mov ecx, 27d
	xor edx, edx
	
process_high:
	pop eax
	dec ecx
	cmp eax, 1d
	jz process_high
	add edx, eax
	or ecx, 0b
	jnz process_high
	
	pop eax
	add eax, edx
	
	lea ebx, result
	mov [ebx], eax
	
	invoke CharToOem, ADDR msg2, ADDR msg2
	invoke WriteConsoleA, hConsoleOutput, ADDR msg2, (SIZEOF msg2) - 1, ADDR NumberOfCharsWritten, 0
	
	lea ebx, result
	mov eax, [ebx]
	invoke crt_printf, addr fmt, eax

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

	lea edi, string
	mov ebx, edi
	
string_len_f:	
	mov al, [edi]
	inc edi
	or al, 0h
	jnz string_len_f
	
	sub edi, ebx
	lea eax, len
	mov [eax], edi
	
	;Поиск a - z
	xor edx, edx
	mov bl, 26d

count_low_f:	
	push edx
	xor edx, edx
	
	dec bl
	cmp bl, -1d
	jz final_low_f
	
	xor ecx, ecx
	mov cl, len
	mov al, 61h
	add al, bl
	cbw
	cwde
	lea edi, string

search_low_f:
	repne scasb 
	or ecx, 0h
	jz count_low_f
	inc edx
	jmp search_low_f
	
final_low_f:
	mov ecx, 27d
	xor edx, edx
	
process_low_f:
	pop eax
	dec ecx
	cmp eax, 1d
	jz process_low_f
	add edx, eax
	or ecx, 0b
	jnz process_low_f
	
;Поиск A - Z
	push edx
	xor edx, edx
	mov bl, 26d
	
count_high_f:	
	push edx
	xor edx, edx
	
	dec bl
	cmp bl, -1d
	jz final_high_f
	
	xor ecx, ecx
	mov cl, len
	mov al, 41h
	add al, bl
	cbw
	cwde
	lea edi, string

search_high_f:
	repne scasb 
	or ecx, 0h
	jz count_high_f
	inc edx
	jmp search_high_f
	
final_high_f:
	mov ecx, 27d
	xor edx, edx
	
process_high_f:
	pop eax
	dec ecx
	cmp eax, 1d
	jz process_high_f
	add edx, eax
	or ecx, 0b
	jnz process_high_f
	
	pop eax
	add eax, edx
	
	lea ebx, result
	mov [ebx], eax
	
	invoke CharToOem, ADDR msg2, ADDR msg2
	invoke WriteConsoleA, hConsoleOutput, ADDR msg2, (SIZEOF msg2) - 1, ADDR NumberOfCharsWritten, 0
	
	lea ebx, result
	mov eax, [ebx]
	invoke crt_printf, addr fmt, eax
	
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
	
	lea ebx, result
	mov eax, [ebx]
	invoke wsprintf, addr result, addr fmt, ax
	
	lea ebx, number
	mov [ebx], ax
	invoke WriteFile, hFileOut, addr result, number, addr number, NULL
   
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

	