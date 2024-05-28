;功能：进行不会产生溢出的除法运算，被除数为 dword型，除数为word型，结果为dword型。
;参数：
;(ax)=dword型数据的低16位
;(dx)=dword型数据的高16位
;(cx)=除数
;返回：
;(dx)=结果的高16位
;(ax)=结果的低16位
;(cx)=余数
assume cs:code

code segment
start:  
		mov ax,4240H
		mov dx,000FH
		mov cx,0AH
		call divdw
		
		mov ax,4c00h
        int 21h
		
divdw:
		mov si,ax	;si存放低位L
				
		mov ax,dx	;计算(H/N)	
		mov dx,0
		div cx				
		mov di,ax	;di存放(H/N)商

		mov ax,0	;计算(rem(H/N)*65536+L)/N
		add ax,si	
		div cx		
		
		mov cx,dx	
		mov dx,di		
		ret
        
code ends
end start
