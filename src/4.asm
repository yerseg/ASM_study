.686
.model flat, stdcall

.data
	string db "AA aa BccB c ", 0
	len db ?
	
.code
assume ds:@data, es:@data

main:
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
	
	ret

end main

	