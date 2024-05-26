;编程，将datasg段中每个单词的前4个字母改为大写字母。
assume cs:codesg,ss:stacksg,ds:datasg

stacksg segment
	dw 0,0,0,0,0,0,0,0
stacksg ends

datasg segment
	db '1. display      '
	db '2. brows        '
	db '3. replace      '
	db '4. modify       '
datasg ends

codesg segment

start:  mov ax,datasg
        mov ds,ax
		
		mov ax,stacksg
		mov ss,ax
		mov sp,10h
		
		mov bx,3
		mov cx,4
	s:	push cx		
		mov si,0
		mov cx,4
	s0:	mov al,[bx][si]
		and al,11011111b
		mov [bx][si],al
		inc si
		loop s0
		pop cx
		add bx,10h		
		loop s
	
        mov ax,4c00h
        int 21h

codesg ends

end start
