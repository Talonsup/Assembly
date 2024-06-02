;编程，以“年/月/日 时：分：秒”的格式，显示当前的日期、时间。
assume cs:code

data segment
  db 9,'/',8,'/',7,' ',4,':',2,':',0,' '
data ends

code segment
start:
	mov ax,data
	mov ds,ax
	mov si,0
	
	mov ax,0b800h
	mov es,ax
	mov di,10*160+40
	
	mov cx,6
s:
	push cx
	
	mov al,[si]
	out 70h,al
	in al,71h
	
	mov ah,al
	mov cl,4
	shr ah,cl
	and al,00001111b
	
	add ah,30h
	add al,30h
	
	mov ch,00000010b
	mov byte ptr es:[di],ah		;十位
	mov byte ptr es:[di+1],ch
	mov byte ptr es:[di+2],al	;个位
	mov byte ptr es:[di+3],ch
	mov al,[si+1]				;/ ：空格样式
	mov byte ptr es:[di+4],al
	mov byte ptr es:[di+5],ch
	
	add si,2
	add di,6
	
	pop cx
	loop s
	
	mov ax,4c00h
	int 21h

code ends
end start
