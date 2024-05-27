assume cs:codesg,ds:data

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
	db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
	db '1993','1994','1995'
	
	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
	
	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
	dw 11542,14430,15257,17800
data ends

table segment
	db 21 dup ('year summ ne ?? ')
table ends

codesg segment

start:  mov ax,data
        mov ds,ax
		
	mov ax,table
	mov es,ax
		
	;写入年份及收入
	mov cx,21
	mov bx,0
	mov si,0
s:	push cx
	mov cx,4		
	mov di,0
s0:	mov al,ds:[si]
	mov es:[bx][di],al
	mov al,ds:84[si]
	mov es:5[bx][di],al
	inc si
	inc di
	loop s0
	add bx,16
	pop cx
	loop s
	
;写入雇员数
	mov cx,21
	mov bx,0
	mov si,0
s1:	push cx
	mov cx,2		
	mov di,0
s2:	mov al,ds:168[si]
	mov es:10[bx][di],al
	inc si
	inc di
	loop s2
	add bx,16
	pop cx
	loop s1
		
;写入人均收入
	mov cx,21
	mov bx,0
s3:	mov ax,word ptr es:5[bx]
	mov dx,word ptr es:7[bx]
	div word ptr es:10[bx]		
	mov word ptr es:13[bx],ax
	add bx,16
	loop s3
		
        mov ax,4c00h
        int 21h

codesg ends

end start
