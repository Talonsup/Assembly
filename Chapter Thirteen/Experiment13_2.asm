assume cs:code

code segment
start:
	mov ax,0
	mov es,ax
	mov di,200h
	
	mov ax,cs
	mov ds,ax
	mov si,offset do7ch
	
	mov cx,offset do7chend - offset do7ch
	cld 
	rep movsb
	
	mov ax,0
	mov es,ax
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0h
	mov ax,4c00h
	int 21h

do7ch:
	dec cx
	jcxz ok
	push bp
	mov bp,sp
	add [bp+2],bx
ok:	
	pop bp
	iret	
do7chend:
	nop

code ends
end start
