;NASM x86 asm

SECTION .data
inv_args db 'Invalid Parameters. Try ./base64 --help', 0Ah, 0h
inv_args_len dd 40
help_args db '-e to encode', 0Ah , '-d to decode' , 0Ah, '-f <path to file> to operate on file' , 0Ah, '-t <text> to operate on text', 0Ah, 0h
help_args_len dd 92
help_param db '--help', 0h
help_param_len dd 7
encod_param db '-e',0h
param_len dd 3
decod_param db '-d', 0h
text_param db '-t', 0h
file_param db '-f', 0h
b64_chars db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/', 0h
mem_start dd 0h

SECTION .text

global start

start:
	mov ebp, esp
	cmp dword [ebp], 4		; checking the number of arguements passed to the application
	je args_correct
	cmp dword [ebp], 2
	je help_func

invalid:				; executed if invalid arguements are passed to the application
	push dword [inv_args_len]	; length of data to print
	push inv_args			; base address of string to print
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
	push ebp			; strcmp like implementation in asm
	mov ebp, esp			; function accepts three arguements
	mov edi, ebp			; first is the address of string and 2nd is the length of this string
	add edi, 12			; third is the address of the string to be compared
	mov eax, dword [ebp + 16]
	mov ebx, dword [ebp + 8]		; If strings are equal eax contains 0 and 1 if they aren't
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

stringlen:
	mov ebx, [esp + 4]	; implementation like strlen function

stringlen_loop:
	cmp byte [ebx], 0	; traverses through the string byte 0 is encountered and subtracts the base from that address
	je len_found		; the returned length is in eax register
	inc ebx
	jmp stringlen_loop

len_found:
	sub ebx, [esp + 4]
	mov eax, ebx
	ret

allocate_mem:
	xor ebx, ebx
	mov eax, 45 		; syscall number for sys_brk
	int 0x80		; first syscall gets the address of break point
	mov [mem_start], eax
	mov ebx, [mem_start]
	add ebx, [esp + 4]
	mov eax, 45
	int 0x80		; second allocates the required amount memory after the first break point
	ret

args_correct:
	mov ebx, [ebp + 8]
	push encod_param		; base address of first string
	push dword [param_len]		; length of first string
	push ebx			; base address of 2nd string to be compared
	call stringcmp
	pop ecx			; pop args from stack
	pop ecx
	pop ecx
	cmp eax, 0			; checking wheather to encode here
	je enc_routine
	push decod_param
	push dword [param_len]
	push ebx
	call stringcmp
	pop ecx
	pop ecx
	pop ecx
	cmp eax, 0			; checking here to see if to decode
	je dec_routine
	jmp invalid

enc_routine:
	mov ebx, [ebp + 12]
	push text_param
	push dword [param_len]
	push ebx
	call stringcmp
	pop ecx
	pop ecx
	pop ecx
	cmp eax, 0			; checking if text param is provided
	je enc_text
	push file_param
	push dword [param_len]
	push ebx
	call stringcmp
	pop ecx
	pop ecx
	pop ecx
	cmp eax, 0			; checking for the file param
	je enc_file
	jmp invalid

enc_text:			; encoding routine if text is provided
	mov ebx, [ebp + 16]
	push ebx			; base address of string
	call stringlen
	pop ecx
	push dword [ebp + 16]
	push eax
	call encode_b64
	call exit

; base64 encoding algorithm
; acepts 2 parameters
; first address of string is pushed on stack
; secondly the length of string is pushed
; so that makes length the first arguement and address as second 
; because length will be on top as happens in cases of all library functions

encode_b64:
	push ebp
	mov ebp, esp
	sub esp, 8		; allocating space for two local vars on stack
	mov eax, [ebp + 8]	; moving length of string to eax
	xor edx, edx
	mov ecx, 3
	div ecx			; checking if length is a multiple of 3
	mov ebx, 3
	sub ebx, edx		; checking how many bytes to add to pad the string to make it a multiple of 3
	cmp ebx, 3
	jne there		; if length is 3 then no need to add
	xor ebx, ebx
there:
	mov [ebp - 4], ebx		; padding length
	mov eax, [ebp + 8]
	add eax, [ebp - 4]		; original length + padding
	xor edx, edx
	div ecx				; dividing the original + padding by 3 and multiplying by 4
	inc ecx				; this will give us the length os resulting encoded string
	mul ecx
	cmp edx, 0
	jne stop
	add eax, 1			; for the newline byte
	mov [ebp - 8], eax		; result buffer length
	push eax
	call allocate_mem		; address of allocated mem is in mem_start
	pop ecx
	mov esi, [ebp + 12]		; string to be encoded
	mov edi, [mem_start]		; result buffer
	mov edx, b64_chars
	call encode_loop

encode_loop:
	; To Implement 

enc_file:

dec_routine:

stop:

; Function related to --help param

help_func:
	mov ebx, [ebp + 8]
	push help_param
	push dword [help_param_len]
	push ebx
	call stringcmp
	pop ebx
	pop ebx
	pop ebx
	cmp eax, 0
	jne invalid
	push dword [help_args_len]
	push help_args
	call print
	pop ecx
	pop ecx
	call exit
