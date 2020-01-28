.586

.model flat, stdcall

.data
	my_word dw 0110011000001111b
.code
start:
	mov ax, my_word
	xor cx, cx
	mov cx, 16d
	xor dx, dx

begin0:
	test cx, 0FFFFh
	jz end_this
	
	shl ax, 1
	dec cx
	
	jc begin0
	
	shl ax, 1
	dec cx
	
	jnc begin1
	
	shl ax, 1
	dec cx
	
	jnc begin1
	
	shl ax, 1
	dec cx
	
	jc begin0
	
	inc dx
	
	jmp begin1
	
begin1:
	test cx, 0FFFFh
	jz end_this
	
	shl ax, 1
	dec cx
	
	jnc begin1
	
	shl ax, 1
	dec cx
	
	jnc begin1
	
	shl ax, 1
	dec cx
	
	jc begin0
	
	inc dx
	
	jmp begin1

end_this:
	mov ax, dx
	ret

end start