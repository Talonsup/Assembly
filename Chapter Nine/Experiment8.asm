assume cs:codesg

codesg segment

	mov ax,4c00h
	int 21h
		
start: 	mov ax,0
s: 	nop
	nop
		
	mov di,offset s
	mov si,offset s2
	mov ax,cs:[si]
	mov cs:[di],ax
		
s0: 	jmp short s
	
s1: 	mov ax,0
	int 21h
	mov ax,0
		
s2: 	jmp short s1
	nop
		
codesg ends
end start
;代码是顺序结构进行从start标号开始执行，一直到s0都没有进行任何的转移，执行到jmp short s时，cs:ip会指向标号s处的指令，为jmp指令数据为EBF6，其中F6代表要偏移的位置，转为有符号数是-10，即往前位移10个字节（包含本身所占字节数）刚好指向code段开始mov ax,4c00h，所以程序可以正确的返回。
