.586
.model flat, stdcall

.data
;===переменные функции====
	A db 50d
	B db -100d
	M db 5d
	D db -2d
	E db -100d
;===вспомогательные значения===
	z db 2d
	
	res1 dd ?
	res dd ?
	
.code
start:
;===== 1 действие: (m*d)^2 =====
	movsx ax, M
	movsx cx, D
	imul cx
	cwde
	imul eax, eax
	push eax  ;stack[0] = (m*d)^2
;======================

;===== 2 действие: 2(a + b) =====
	movsx ax, A
	movsx cx, B
	add ax, cx
	movsx cx, z
	imul cx
	cwde
	push eax    	;stack[0] = 2(a + b),
					;stack[1] = (m*d)^2
;======================

;===== 3 действие 2(a + b) / (m*d)^2 =====
	finit
	fild dword ptr [esp]  	;st[0] = 2(a + b)
	pop ecx               	;stack[0] = (m*d)^2
	fidiv dword ptr [esp] 	;st[0] = 2(a + b) / (m*d)^2
	pop eax               	;stack[0] = ?
	fstp res1 				;st[0] = ?
	push res1				;stack[0] = 2(a + b) / (m*d)^2
;===============================

;===== 4 действие 2*e =========
	movsx eax, E
	movsx ecx, z
	imul ecx
	push eax 		;stack[0] = 2*e, 
					;stack[1] = 2(a + b) / (m*d)^2
;======================

;===== 5 действие (ad^2) =====
	movsx eax, A
	movsx ecx, D
	imul ecx
	cwde
	imul ecx
	push eax  	;stack[0] = ad^2
				;stack[1] = 2*e, 
				;stack[2] = 2(a + b) / (m*d)^2
			
;====== 6 действие ===============
	fild dword ptr [esp] 	;st[0] = ad^2
	pop eax 				;stack[0] = 2*e, 
							;stack[1] = 2(a + b) / (m*d)^2
	fidiv dword ptr [esp] 	;st[0] = st[0] / 2*e
	pop eax  				;stack[0] = 2(a + b) / (m*d)^2
	
	fadd dword ptr [esp]
	pop eax  				;stack[0] = ?
	fstp res 				;st[0] = ?
	push res 				;stack[0] = RESULT
	
	ret
end start
