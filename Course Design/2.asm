assume cs:code
code segment
start:
	;引导程序安装到软盘a，占1个扇区
	call install_boot
	
	;主程序安装到软盘a，占2个扇区
	call install_main
	
	mov ax,4c00h
	int 21h

install_boot:
	;es:bx指向boot
	mov bx,cs
	mov es,bx
	mov bx,offset boot
	
	;内容写入软盘A_0面_0道_1扇区
	mov dl,0
	mov dh,0
	mov ch,0
	mov cl,1
	mov al,1
	mov ah,3
	int 13h
	
	ret

install_main:
	;es:bx指向main
	mov bx,cs
	mov es,bx
	mov bx,offset main
	
	mov dl,0
	mov dh,0
	mov ch,0
	mov cl,2
	mov al,2
	mov ah,3
	int 13h
	
	ret
boot:
	;栈空间设置
	cli
	mov ax,0
	mov ss,ax
	mov sp,7c00h
	sti
	
	;装载新int9中断例程
	call loadint9
	
	;主程序写入7e00h
	mov bx,0
	mov es,bx
	mov bx,7e00h
	
	;读取软盘A_0面_0道_2扇区开始的2个扇区到0:7e00h
	mov dl,0
	mov dh,0
	mov ch,0
	mov cl,2
	mov al,2
	mov ah,2
	
	mov bx,0
	push bx
	mov bx,7e00h
	push bx
	retf

loadint9:
	push ds
	push si
	push es
	push di
	push cx
	
	;引导程序执行时，cs:ip=0:7c00h
	push cx
	pop ds
	
	mov cx,0
	mov es,cx
	
	;ds:si指向新int9例程,es:di指向新int9例程装载位置
	mov si,newint9-boot+7c00h
	mov di,204h
	mov cx,newint9end-newint9
	cld
	rep movsb
	
	;保存旧的int9中断向量
	push es:[9*4]
	pop es:[200h]
	push es:[9*4+2]
	pop es:[200h]
	
	pop cx
	pop di
	pop es
	pop si
	pop ds
	ret

newint9:
	push ax
	push bx
	push cx
	push es
	
	in al,60h
	
	pushf
	call word ptr cs:[200h]
	
	;f1
	cmp al,3bh
	je color
	;esc
	cmp al,01h
	je int9ret
	jmp newint9ret

backmain:
	pop es
	pop cx
	pop bx
	pop ax
	
	;跳过cs:ip
	add sp,4
	popf
	
	mov bx,0
	push bx
	mov bx,7e00h
	push bx
	retf
	
int9ret:
	;恢复原int9中断向量，原中断向量保存在0:200h,0:202h
	mov ax,0
	mov es,ax
	
	cli
	push es:[200h]
	pop es:[9*4]
	push es:[202h]
	pop es:[9*4+2]
	sti
	
	jmp backmain

color:
	mov ax,0b800h
	mov es,ax
	mov bx,1
	mov cx,17
color_s1:
	inc byte ptr es:[bx]
	add bx,2
	loop color_s1
	
newint9ret:
	pop es
	pop cx
	pop bx
	pop ax
	iret
newint9end:
	nop
; 因为引导程序占512字节，这里填充512字节0，作为扇区结束，
; 防止引导程序不够512字节，而复制下面的代码到1扇区内
db 512 dup (0)

;--------------------- 主程序 ---------------------
main:
	jmp main_start
	menu1		db '1)reset pc',0
	menu2		db '2)start system',0
	menu3		db '3)clock',0
	menu4		db '4)set clock',0
    	menu_addr	dw menu1-main+7e00h, menu2-main+7e00h, menu3-main+7e00h, menu4-main+7e00h
	timestr		db 'yy/mm/dd hh:mm:ss',0
	timeaddr	db 9,8,7,4,2,0
    	strbuffer	db 100 dup (0)
	
main_start:
    mov ax,0
    mov ds,ax

    call clr_src
    call show_menu
    call choose_item


choose_item:
    mov si,strbuffer-main+7e00h
    call getstr

    cmp byte ptr [si],'1'
    je item1
    cmp byte ptr [si],'2'
    je item2
    cmp byte ptr [si],'3'
    je item3
    cmp byte ptr [si],'4'
    je item4
    jmp main_start 

item1:
    mov bx,0ffffh
    push bx
    mov bx,0
    push bx
    retf
	
item2: 
    mov bx,0
    mov es,bx
    mov bx,7c00h

    ;读取硬盘c_0面，0道，1扇区到0:7c00h
	mov dl,80h
	mov dh,0
	mov ch,0
	mov cl,1
	mov al,1
	mov ah,2
	int 13h

    mov bx,0
    push bx
    mov bx,7c00h
    push bx
    retf

item3:
    call setnewint9
    call show_dt
    jmp main_start

item4:
    call clr_src
    mov si,strbuffer-main+7e00h
    call getstr
    call set_dt
    jmp main_start

;显示主程序菜单
show_menu:
    push bx
    push es
    push si
    push cx
    push di

    mov bx,0b800h
    mov es,bx
    mov bx,160*10+32*2 
    mov di,menu_addr-main+7e00h
    mov cx,4

show_menu_s1:
    mov si,[di]
    call show_str
    add di,2
    add bx,160
    loop show_menu_s1

    pop di
    pop cx
    pop si
    pop es
    pop bx
    ret

;清屏
clr_src:
    push bx
    push cx
    push es
    mov bx,0b800h
    mov es,bx
    mov bx,0 
    mov cx,2000
clr_src_s1:
    mov byte ptr es:[bx],' '
    add bx,2
    loop clr_src_s1
    pop es
    pop cx
    pop bx
    ret

; 显示字符串，字符串以0结束
; ds:si指向字符串开头
; es:bx指向显存开始，对应屏幕上的位置
show_str:
    push si
    push cx
    push es
    push bx
show_str_s1:
    mov cl,[si]
    cmp cl,0
    je show_str_ret
    mov es:[bx],cl
    add bx,2
    inc si
    jmp show_str_s1
show_str_ret:
    pop bx
    pop es
    pop cx
    pop si
    ret
	
; 接受字符串输入
; ds:si指向字符栈空间
getstr:
    push ax
    push dx
    push es
    push di

    mov ax,0b800h
    mov es,ax
    mov di,160*14+32*2 
    call setcur

    mov dx,0
	
getstrs:
    mov ah,0
    int 16h 
    cmp al,20h
    jb nochar
    cmp al,7eh
    ja nochar 
    mov ah,0
    call charstack 
    mov ah,2
    call charstack 
    jmp getstrs

nochar:
    cmp ah,0eh 
    je backspace
    cmp ah,1ch 
    je enter
    jmp getstrs
	
backspace:
    mov ah,1
    call charstack 
    mov ah,2
    call charstack
    jmp getstrs

enter:
    mov al,0 
    mov ah,0
    call charstack
    mov ah,2
    call charstack

    pop di
    pop es
    pop dx
    pop ax
    ret
	
; 字符入栈、出栈、显示功能
; ah=功能号，0入栈，1出栈，2显示
; ds:si指向字符栈空间
; dx=字符栈栈指针
; 0号功能，al=入栈字符
; 1号功能，al=返回的字符
; 2号功能，es:di指向屏幕位置
charstack: jmp short charstart
table      dw charpush-main+7e00h,charpop-main+7e00h,charshow-main+7e00h
charstart:
    push bx
    push di
    push es

    cmp ah,2 
    ja sret
    mov bl,ah
    mov bh,0
    add bx,bx 
    jmp word ptr table-main+7e00h[bx]

charpush:
    mov bx,dx
    mov [si][bx],al
    inc dx
    jmp sret

charpop:
    cmp dx,0
    je sret
    dec dx
    mov bx,dx
    mov al,[si][bx]
    jmp sret

charshow:
    mov bx,0
charshows:
    cmp bx,dx
    jne noempey
    mov byte ptr es:[di],' '
    call setcur
    jmp sret

noempey:
    mov al,[si][bx]
    mov es:[di],al
    mov byte ptr es:[di+2],' '
    inc bx
    add di,2
    jmp charshows

sret:
    pop es
    pop di
    pop bx
    ret

setcur:
    push ax
    push dx

    mov ax,di
    mov dh,160
    div dh
    mov dh,al 
    mov al,ah
    mov ah,0
    mov dl,2
    div dl
    mov dl,al
    mov ah,2 
    mov bh,0 
    int 10h

    pop dx
    pop ax
    ret

show_dt:
    call get_dt
    call delay
    jmp show_dt
    ret

setnewint9:
    push es
    push bx
    mov bx,0
    mov es,bx
    cli
    mov word ptr es:[9*4],204h
    mov word ptr es:[9*4+2],0
    sti
    pop bx
    pop es
    ret

; 获取CMOS中的系统时间
; ds:si从cmos对应地址取日期时间，ds:di转换后的日期时间字符串
get_dt:
    push si
    push di
    push cx
    push ax
    push es
    push bx

    mov si,timeaddr-main+7e00h
    mov di,timestr-main+7e00h
    mov cx,6
get_dt_s1:
    mov bx,cx
    mov al,[si]
    out 70h,al
    in al,71h
    mov ah,al
    mov cl,4
    shr ah,cl
    and al,00001111b
    add ah,30h
    add al,30h
    xchg ah,al
    mov [di],ax
    add di,3
    inc si
    mov cx,bx
    loop get_dt_s1

    mov bx,0b800h
    mov es,bx
    mov bx,0
    mov si,timestr-main+7e00h
    call show_str

    pop bx
    pop es
    pop ax
    pop cx
    pop di
    pop si
    ret

delay:
    push ax
    push dx
    mov dx,6000h 
    mov ax,0
delays1:
    sub ax,1
    sbb dx,0
    cmp ax,0
    jne delays1
    cmp dx,0
    jne delays1
    pop dx
    pop ax
    ret

set_dt:
    push si
    push di
    push cx
    push ax
    push bx

    mov di,timeaddr-main+7e00h
    mov cx,6
set_dt_s1:
    mov ax,[si]
    sub ah,30h
    sub al,30h
    and ah,00001111b
    mov bx,cx
    mov cl,4
    shl al,cl
    or al,ah
    mov cx,bx
    mov ah,al
    mov al,[di]
    out 70h,al
    mov al,ah
    out 71h,al
    inc di
    add si,3
    loop set_dt_s1

    pop bx
    pop ax
    pop cx
    pop di
    pop si
    ret

db 1024 dup (0)
code ends
end start
