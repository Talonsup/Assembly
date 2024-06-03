;安装一个新的 int 7ch 中断例程，实现通过逻辑扇区号对软盘进行读写。
;用ah寄存器传递功能号：0表示读，1表示写；
;用dx寄存器传递要读写的扇区的逻辑扇区号；
;用es:bx指向存储读出数据或写入数据的内存区。
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
	push ax
	push cx
	push dx
	
	;功能号存储
	push ax
	
	;计算面号
	mov ax,dx
	mov dx,0
	mov cx,144
	div cx
	push ax
	
	;计算磁道号
	mov ax,dx
	mov dx,0
	mov cx,18
	div cx
	push ax
	
	;计算扇区号
	inc dx
	push dx
	
	;计算完毕入口参数赋值
	pop ax
	mov cl,al
	pop ax
	mov ch,al
	pop ax
	mov dh,al
	mov dl,0
	pop ax
	add ah,2
	mov al,1
	int 13h

	pop dx
	pop cx
	pop ax
	iret

int7end:
	nop
	
code ends
end start
