.586
.model flat, stdcall
.stack 100h

.data
	m db 4
	n db 3
	K db ?
	matr db  0, 1, 2,   
			 6, 7, 9,   
			12,13,15,   
			18,19,21

.code 

main:
	lea eax, m
	lea ebx, n
	xor ecx, ecx
	xor edx, edx
	mov cl, [eax]
	mov dl, [ebx]
	cmp cl, dl
	
	js @
	jns @1
@:
	mov cl, [eax]
	lea ebx, K
	mov [ebx], cl
	jmp elem
@1: 
	mov cl, [ebx]
	lea ebx, K
	mov [ebx], cl
	
elem:
	xor ebx, ebx
	mov bl, cl
	sub bl, 1h
	
	lea eax, matr
	
	push ecx
	
	push eax
	xor eax, eax
	mov eax, ecx
	sub eax, 1h
	mul dl
	mov ecx, eax
	pop eax
	
	add cl, bl
	add eax, ecx
	mov bl, [eax]
	pop ecx
	
	push ebx 
	loop elem
	
	xor ecx, ecx
	lea eax, K
	mov cl, [eax]
	sub cl, 1h
	pop eax
	
summ:
	pop ebx
	add eax, ebx
	loop summ

	ret

end main