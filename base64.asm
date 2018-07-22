;NASM x86 asm

SECTION .data
inv_args db 'Invalid Number of Parameters. Try ./base64 --help', 0Ah, 0h
inv_args_len dd 51
help_args db '-e to encode', 0Ah , '-d to decode' , 0Ah, '-f <path to file> to operate on file' , 0Ah, '-t <text> to operate on text', 0Ah, 0h
help_args_len dd 92
help_param db '--help', 0h
help_param_len dd 7

SECTION .text

global start

start:
	mov ebp, esp
	cmp dword [ebp], 4
	je args_correct
	cmp dword [ebp], 2
	je help_func

invalid:
	push dword [inv_args_len]
	push inv_args
	call print
	pop ecx
	pop ecx
	call exit

print:
	mov edx, dword [esp + 8]	; implementation of print function which uses write syscall (eax = 4)
	mov ecx, dword [esp + 4]	; function accepts two params, 1st is the base address of string to be printed
	mov ebx, 1			; and 2nd param is the length of the string
	mov eax, 4			; save values in registers before calling this if those values are needed
	int 80h         ; write syscall
	ret

exit:
	mov ebx, 0
	mov eax, 1
	int 80h		; exit syscall
	ret

stringcmp:
	push ebp			; strcmp implementation in asm
	mov ebp, esp			; function accepts three arguements
	mov edi, ebp			; first is the address of string and 2nd is the length of this string
	add edi, 12			; third is the address of the string to be compared
	mov eax, [ebp + 16]
	mov ebx, [ebp + 8]
	xor ecx, ecx
	xor edx, edx

stringcmp_loop:
	mov cl, byte [eax]
	mov dl, byte [ebx]
	dec dword [edi]
	inc eax
	inc ebx
	cmp cl, dl
	jne string_not_eq
	cmp dword [edi], 0
	je string_eq
	jmp stringcmp_loop

string_eq:
	mov eax, 0
	pop ebp
	ret

string_not_eq:
	mov eax, 1
	pop ebp
	ret

args_correct:
	; To implement encoding and decoding here


; Functions related to --help param

help_func:
	mov ebx, [ebp + 8]
	push help_param
	push 7
	push ebx
	call stringcmp
	cmp eax, 0
	jne invalid
	push dword [help_args_len]
	push help_args
	call print
	pop ecx
	pop ecx
	call exit
