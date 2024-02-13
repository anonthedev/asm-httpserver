section .text
    global _start
    
    _start:
        mov rax, 41
        mov rdi, 2
        mov rsi, 1
        mov rdx, 6
        syscall
        mov [socket], rax

        push    rbp
        mov     rbp,rsp
        push    dword 0
        push    dword 0x0100007F
        push    word  0x8813
        push    word  2
        mov     [socketAddr],rsp
        add     rsp,12
        pop     rbp

        mov     rax,54
        mov     rdi,[socket]
        mov     rsi,1
        mov     rdx,2
        mov     r10,socketOn
        mov     r8,dword 32
        syscall
        cmp     rax,0
        jne     closeServer

        ; Binding
        mov rax, 49
        mov rdi, [socket]
        mov rsi, [socketAddr]
        mov rdx, dword 32
        syscall
        cmp rax,0
        jne closeServer

        mov rax, 1
        mov rdi, 1          
        mov rsi, listeningMsg
        mov rdx, 25
        syscall
        mov rax, 50
        mov rdi, [socket]
        mov rsi, 8
        syscall

    serverAcc:
        mov rax, 43
        mov rdi, [socket]
        mov rsi, dword 0
        mov rdx, dword 0
        syscall
        cmp rax, 0
        jle closeServer
        mov [client], rax

        mov rax, 0
        mov rdi, [client]
        mov rsi, reqBuff
        mov rdx, buffLen
        syscall
        mov [reqLen], rax

        mov rax, 1
        mov rdi, 1
        mov rsi, reqBuff
        mov rdx, [reqLen]
        syscall

        mov rax, 2
        mov rdi, fileName
        mov rsi, 0
        syscall
        cmp rax, 0
        jle closeClient
        mov [filePtr], rax
        mov rcx, qword 0

    sendHeaders:
        mov rax, 1
        mov rdi, [client]
        mov rsi, http200
        mov rdx, http200Len
        syscall

    readHTML:
        mov rax, 0
        mov rdi, [filePtr]
        mov rsi, resBuff
        mov rdx, buffLen
        syscall
        cmp rax, 1
        jl closeClient
        mov rcx, rax

        mov rax, 1
        mov rdi, [client]
        mov rsi, resBuff
        mov rdx, rcx
        syscall
        jmp readHTML
    
    closeClient:
        mov rax, 3
        mov rdi, [client]
        syscall
        jmp serverAcc

    closeServer:
        mov rax, 3
        mov rdi, [socket]
        syscall
        xor rax, rax

    _exit:
        pop rbp
        mov rdi, rax
        mov rax, 60
        syscall

section .data
    socket dq 0
    socketOn dw 1
    client dq 0
    fileName db "index.html", 0h
    filePtr db 0
    reqLen dw 0
    buffLen equ 512
    reqBuff TIMES buffLen db 0
    resBuff TIMES buffLen db 0

    listeningMsg:
        db "Listening on port 5000...", 0ah
    listeningMsgLen equ $ - listeningMsg

    http200:
        db      "HTTP/1.1 200 OK",                      0ah
        db      "Date: xxx, xx xxx xxxx xx:xx:xx xxx",  0ah
        db      "Server: HTTP-ASM64",                   0ah
        db      "Content-Type: text/html",              0ah,0ah,0h
    http200Len  equ     $ - http200

    http404:     
        db      "HTTP/1.1 404 Not Found",               0ah
        db      "Date: xxx, xx xxx xxxx xx:xx:xx xxx",  0ah
        db      "Server: HTTP-ASM64",                   0ah
        db      "Content-Type: text/html",              0ah,0ah,0
    http404Len  equ     $ - http404

Section .bss
    socketAddr resq 2