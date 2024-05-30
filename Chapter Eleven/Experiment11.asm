;名称：letterc
;功能：将以0结尾的字符串中的小写字母转变成大写字母
;参数：ds:si 指向字符串首地址
assume cs:codesg

datasg segment
	db "Beginner's All-purpose Symbolic Instruction Code.",0
datasg ends

codesg segment

start:
	mov ax,datasg
	mov ds,ax
	mov si,0
	call letterc
	
	mov ax,4c00h
	int 21h
letterc:
	push ax
	push si
	mov al,61h
	mov ah,7ah
	mov bl,0
s0:	
	cmp ds:[si],0
	jz ok
	cmp ds:[si],al
	jb next
	cmp ds:[si],ah
	ja next
	and byte ptr ds:[si],11011111b
next:    
	inc si
	loop s0
ok:
	pop si
	pop ax
	ret 
codesg ends
end start
