;功能：将word型数据转变为表示十进制数的字符串，字符串以0为结尾符。
;参数：
;(ax)=word型数据
;ds:si指向字符串的首地址
;返回：无
assume cs:code

data segment
	db 10 dup (0)
data ends

code segment
start:  
		mov ax,12666
		mov bx,data
		mov ds,bx
		mov si,0
		call dtoc
		
		mov dh,8
		mov dl,3
		mov cl,2
		call show_str
		mov ax,4c00h
        int 21h
		
dtoc:
		mov bx,0ah
		mov dx,0
		div bx
		
		add dx,30h
		inc si
		mov ds:[si],dl	;逆序存入
		
		mov cx,ax		;判断商是否为0，为0跳出，不为0继续
		jcxz ok
		jmp dtoc

ok:		ret
		
show_str:			
		mov ax,0B800h	
		mov es,ax			
		mov ax,160		
		mul dh
		mov bx,ax
		mov ax,2		
		mul dl
		add bx,ax		
		mov al,cl		
		mov cl,0
change:	
		mov ch,[si]		
		jcxz ook			
		mov es:[bx],ch		
		mov es:1[bx],al		
		dec si				;逆序显示
		add bx,2
		jmp change	
	
ook:	
		ret
        
code ends
end start
