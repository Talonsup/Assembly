;在屏幕中间分别显示绿色、绿底红色、白底蓝色的字符串'welcome to masm!'。
assume cs:codesg

datasg segment
	db 'welcome to masm!'
datasg ends

codesg segment

start:		mov ax,datasg
		mov ds,ax
		
		mov ax,0B872H	;控制显示在中间
		mov es,ax
		
		mov cx,16
		mov bx,0		;控制字符循环
		mov si,0		;控制字符写入
		mov di,1		;控制颜色写入
	s:	mov al,ds:[bx]
		mov es:[si],al
		mov es:0a0h[si],al	;换行写入
		mov es:140h[si],al	;换行写入	
		
		mov al,02h
		mov es:[di],al
		mov al,24h
		mov es:0a0h[di],al
		mov al,71h
		mov es:140h[di],al
		
		inc bx
		add si,2
		add di,2
		loop s
		
		
		mov ax,4c00h
		int 21h
		
codesg ends
end start
