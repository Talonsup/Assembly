;将实验7中的 Power idea 公司的数据按照图10.2 所示的格式在屏幕上显示出来。
assume cs:code,ds:data,ss:stack

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
	db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
	db '1993','1994','1995'
	;以上表示 21 年的 21 个字符串

	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
	;以上是表示 21 年公司总收入的 21 个 dword 型数据

	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
	dw 11542,11430,15257,17800
	;以上是表示 21 年公司雇员的 21 个 word 型数据
	
data ends

string segment
      dw 8 dup (0)
string ends

stack segment
      dw 16 dup (0)
stack ends

code segment

start:      
	mov ax,data                     
	mov ds,ax
	mov ax,stack
	mov ss,ax
	mov sp,32
	mov ax,0b800h
	mov es,ax
	
	mov bx,160*4	
	mov bp,0
	mov di,0	
	mov cx,21	

s1:      
	push cx		
	mov cx,4	
	mov si,0	

s2:      
	;年份显示
	mov al,ds:[di]
	mov ah,00000111b
	mov es:[bx+si],ax
	inc di
	add si,2
	loop s2
	
	;总收入显示
	mov ax,ds:[di].50h                 
	mov dx,ds:[di].52h               
	call dtoc
	push di 
	mov di,20
	call show_str
	pop di
	
	;雇员显示
	mov ax,ds:[bp].0a8h
	mov dx,0
	call dtoc
	push di
	mov di,40
	call show_str
	pop di
	
	;人均收入显示
	mov ax,ds:[di].50h
	mov dx,ds:[di].52h
	push bx
	mov bx,ds:[bp].0a8h
	div bx
	pop bx
	mov dx,0
	call dtoc
	push di
	mov di,60
	call show_str
	pop di
	
	;换行
	add bx,0a0h
	add bp,2
	pop cx
	loop s1
	
	mov ax,4c00h
	int 21h


;名称：dtoc
;功能：将 dword 型数转变为表示十进制数的字符串，字符串以 0 为结尾符
;参数：(ax)=dword 型数据的低 16 位
;      (dx)=dword 型数据的高 16 位
;      ds:si 指向字符串的首地址
;返回：无

dtoc:
	push dx
	push cx
	push bx
	push ax
	push di
	push si
	
	mov di,0
s3:       	
	mov cx,10
	call divdw
	add cx,30h
	push cx
	inc di
	
	mov cx,ax
	or cx,dx
	jcxz ok1
	inc cx
	loop s3
      
ok1:
	mov cx,di
	mov si,0e0h
      
s4:     
	pop ds:[si]
	inc si
	loop s4
	mov byte ptr ds:[si],0
	
	pop si
	pop di
	pop ax
	pop bx
	pop cx
	pop dx
	ret            

;名称：divdw
;功能：进行不会产生溢出的除法运算，被除数为 dword 型，除数为 word 型，结果为 dword 型
;参数：(ax)=dword 型数据的低 16 位
;      (dx)=dword 型数据的高 16 位
;      (cx)=除数
;返回：(dx)=结果的高 16 位，(ax)=结果的低 16 位
;      (cx)=余数

divdw:      
	push bx
	push ax
	mov ax,dx
	mov dx,0
	div cx   
	mov bx,ax
	
	pop ax  
	div cx  
	mov cx,dx
	
	mov dx,bx
	pop bx
	ret

;名称：show_str
;功能：在指定的位置，用指定的颜色(黑底白字)，显示一个用 0 结束的字符串
;参数：di 为行偏置，bx 为列偏置
;      ds:si 指向字符串的首地址
;返回：无

show_str:   
	push dx
	push cx
	push bx
	push ax
	push si
	push di
	
	mov si,0e0h
	mov ah,7
s5:   
	mov al,ds:[si]
	mov cl,al
	mov ch,0
	
	jcxz ok2
	mov es:[bx+di],ax
	add di,2
	inc si
	loop s5

ok2:   
	pop di
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret

code ends

end start
