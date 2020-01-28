.586 ;обозначаем  систему команд
.model flat, stdcall ;определяем модель памяти и модель вызова функций

.data ;сегмент данных 
;===переменные функции====
	A db 100d
	B db 100d
	Cop db 100d
	D db 1d
	E db 100d
;===вспомогательные значения===
	z db 2d

.code
start:
;===== 1 действие: (A + B)^3 =====
	movzx ax, A
	movzx cx, B
	add ax, cx
	cwde
	mov ecx, eax ;EAX = ECX = (A + B)
	mul eax ;EAX = EAX * EAX
	mul ecx ;EAX = EAX * ECX = EAX * EAX * EAX = (A + B)^3
	push eax  ;stack[0] = (A + B)^3
;======================

;===== 2 действие: Cop*D =====
	movzx ax, Cop
	movzx cx, D
	mul cx ;AX = AX * CX
	cwde
	push eax ; stack[0] = Cop*D,
			 ; stack[1] = (A + B)^3
;======================

;===== 3 действие (A + B)^3 / Cop*D ====
	pop ecx ; stack[0] = (A + B)^3 , ECX = Cop * D
	pop eax ; stack[0] = ?
	cdq
	div ecx
	push eax ; stack[0] = [(A + B)^3 / Cop*D]
;===============================

;===== 4 действие (Cop - 2*D)^3 =========
	movzx ax, D
	movzx cx, Cop
	mul z
	sub cx, ax
	mov ax, cx ; AX = (Cop - 2 * D)
	cwde
	mov ecx, eax
	mul eax
	mul ecx
	push eax ; stack[0] = (Cop - 2*D)^3, 
			 ; stack[1] = [(A + B)^3 / Cop*D]
;======================

;===== 5 действие A*(Cop - 2*D)^3 =====
	pop eax  ;stack[0] = [(A + B)^3 / Cop*D]
	movzx ecx, A
	mul ecx
	push eax  ; stack[0] = A*(Cop - 2*D)^3
			  ; stack[1] = [(A + B)^3 / Cop*D],
			
;====== 6 действие 2*E===============
	movzx ax, E
	mul z
	cwde
	push eax  ; stack[0] = 2*E
			  ; stack[1] = A*(Cop - 2*D)^3
			  ; stack[2] = [(A + B)^3 / Cop*D]
			  
;======= 7 действие (A*(Cop - 2*D)^3) / 2*E =======
	pop ecx  ; stack[0] = A*(Cop - 2*D)^3
			 ; stack[1] = [(A + B)^3 / Cop*D] 
	pop eax  ; stack[0] = [(A + B)^3 / Cop*D] 
	cdq
	div ecx
	push eax  ; stack[0] = [(A*(Cop - 2*D)^3) / 2*E]
		      ; stack[1] = [(A + B)^3 / Cop*D] 
;==========final=========
	pop eax
	pop ecx
	add eax, ecx
	push eax
	 
	ret
end start
