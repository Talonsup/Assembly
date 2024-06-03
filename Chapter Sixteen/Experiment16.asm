;安装一个新的 int 7ch 中断例程，为显示输出提供如下功能子程序。
;(1)清屏；
;(2)设置前景色；
;(3)设置背景色；
;(4)向上滚动一行。
assume cs:code

code segment
start:
	mov ax,cs
  	mov ds,ax
	mov si,offset int7                       
	mov ax,0
	mov es,ax
	mov di,0200h                             
	mov cx,offset int7end-offset int7       
	
	cld                                       
	rep movsb                             

	cli
	mov word ptr es:[7ch*4],200h
	mov word ptr es:[7ch*4+2],0             
	sti

	mov ax,4c00h
	int 21h

int7:
	jmp set
	dw offset sub1 - offset int7 + 200h
	dw offset sub2 - offset int7 + 200h
	dw offset sub3 - offset int7 + 200h
	dw offset sub4 - offset int7 + 200h

set:
	push bx
	cmp ah,3
	ja sret
	mov bl,ah
	mov bh,0
	add bx,bx
	call word ptr cs:[bx+202h]

sret:
	pop bx
	iret

;清屏：将显存中当前屏幕中的字符设为空格符；
sub1:
	push bx
	push cx
	push es
	mov bx,0b800h
	mov es,bx
	mov bx,0
	mov cx,2000	
sub1s:
	mov byte ptr es:[bx],' '
	add bx,2
	loop sub1s
	pop es
	pop cx
	pop bx
	ret

;设置前景色：设置显存中当前屏幕中处于奇地址的属性字节的第0、1、2位；
sub2:
	push bx
	push cx
	push es
	mov bx,0b800h
	mov es,bx
	mov bx,1
	mov cx,2000	
sub2s:
	and byte ptr es:[bx],11111000b
	or es:[bx],al
	add bx,2
	loop sub2s
	pop es
	pop cx
	pop bx
	ret

;设置背景色：设置显存中当前屏幕中处于奇地址的属性字节的第4、5、6位；
sub3:
	push bx
	push cx
	push es
	mov cl,4
	shl al,cl
	mov bx,0b800h
	mov es,bx
	mov bx,1
	mov cx,2000	
sub3s:
	and byte ptr es:[bx],10001111b
	or es:[bx],al
	add bx,2
	loop sub3s
	pop es
	pop cx
	pop bx
	ret
	
sub4:
	push cx
	push si
	push di
	push es
	push ds
	
	mov si,0b800h
	mov es,si
	mov ds,si
	mov si,160
	mov di,0
	cld
	mov cx,24
sub4s:
	push cx
	mov cx,160
	rep movsb
	pop cx
	loop sub4s
	mov cx,80
	mov si,0
sub4s1:
	mov byte ptr [160*24+si],' '
	add si,2
	loop sub4s1
	
	pop ds
	pop es
	pop di
	pop si
	pop cx
	ret

int7end:
	nop
code ends
end start
