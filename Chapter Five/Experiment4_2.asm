assume cs:codesg

codesg segment

	mov ax,0020h
	mov ds,ax
	
	mov bx,0
	mov cx,64
	
s:	mov [bx],bx
	inc bx
	loop s
	
	mov ax,4c00H
	int 21H
	
codesg ends

end
