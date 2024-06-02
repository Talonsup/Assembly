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
	push ax
	push es
	push dx
	push di
	push si
	push cx
		
	mov ax,0b800h
	mov es,ax
	mov al,160
	mul dh
	add al,dl
	adc ah,0
	mov di,ax
show_str:
	cmp byte ptr [si],0
	je ok
	mov al,[si]
	mov es:[di],al
	mov es:[di+1],cl
	inc si
	add di,2
	jmp show_str
ok:
	pop cx
	pop si
	pop di
	pop dx
	pop es
	pop ax
	iret	
	mov ax,4c00h
	int 21h
do7chend:
	nop

code ends
end start
