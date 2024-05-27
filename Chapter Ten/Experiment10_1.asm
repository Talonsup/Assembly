;显示字符串
;名称：show str
;功能：在指定的位置，用指定的颜色，显示一个用0结束的字符串。
;参数：(dh)=行号(取值范围0~24),(dl)=列号(取值范围0~79),(cl)=颜色，ds:si指向字符串的首地址
assume cs:code

data segment
  db 'Welcome to masm!',0
data ends

code segment
start:  
	mov dh,8
        mov dl,3
        mov cl,2
	mov ax,data
	mov ds,ax
	mov si,0
	call show_str
		
	mov ax,4c00h
        int 21h
		
show_str:
	push dx
	push cx
	push ax
	push si
		
	mov ax,0B800h		;首行地址
	mov es,ax
		
	mov ax,160		;每行长度
	mul dh
	mov bx,ax
	mov ax,2		;寻找首地址
	mul dl
	add bx,ax		;bx存放最后找到的存放首地址
	mov al,cl		;al存放颜色
	mov cl,0
change:	
	mov ch,[si]		;si控制循环字符
	jcxz ok			;到0结束循环
	mov es:[bx],ch	;字符传递
	mov es:1[bx],al	;颜色传递
	inc si
	add bx,2
	jmp change	
	
ok:	
	pop si
	pop ax
	pop cx
	pop dx
	ret
        
code ends

end start
