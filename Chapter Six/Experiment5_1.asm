assume cs:code,ds:data,ss:stack

data segment
  dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
data ends

stack segment
  dw 0,0,0,0,0,0,0,0
stack ends

code segment

start:  mov ax,stack
        mov ss,ax
        mov sp,16

        mov ax,data
        mov ds,ax

        push ds:[0]
        push ds:[2]
        pop ds:[2]
        pop ds:[0]
        mov ax,4c00h
        int 21h

code ends

end start
;CPU执行程序，程序返回前，data段中的数据为0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
;CPU执行程序，程序返回前，cs=076ch、ss=076bh、ds=076ah
;设程序加载后，code段的段地址为X,则data段的段地址为X-2,stack段的段地址为X-1
