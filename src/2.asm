.586

.model flat, stdcall

.data
	my_byte db 01110111b
	one db 1b
.code
start:
	mov al, my_byte
	shl al, 1
	jnc final
	
	not al
	rcr al, 1
	ret
	
final:
	rcr al, 1
	ret
	
end start
	