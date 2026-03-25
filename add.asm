includelib legacy_stdio_definitions.lib
includelib ucrt.lib
includelib kernel32.lib
includelib user32.lib
GRIDPOS  STRUCT
    x dd 0
    y dd 0

GRIDPOS  ENDS

SNAKE STRUCT
    pos GRIDPOS <>
    snakeSize dd 3
    snakeTurnPoses dd 625 dup(0)
    turnDir dd 0
    dead db 0
    pad db 3 dup(0)
SNAKE ENDS
EXTERN printf:PROC
EXTERN system:PROC
EXTERN Sleep:PROC
extrn ExitProcess:proc
EXTERN sprintf:PROC
extrn GetCursorPos:proc
extern GetProcessHeap:PROC
extern rand:PROC
extern srand:PROC
extern GetTickCount:PROC
extern HeapAlloc:PROC
extern GetAsyncKeyState:PROC
.data
clsCmd db "cls", 0
blankP db "  ",0
borderP db "? ",0
snakeP db "# ",0
foodP db "@ ",0
newlineP db 13,10,0
MAP_SIZE EQU 25
ALIGN 8
hHeap dq 0
player SNAKE <<15,15>>

foodpos GRIDPOS  <10,10>


buffer db 32 dup(0)


fmt db "%d %d ",10,0


.code
drawMapASM PROC; list shadow padding

    push rdi

    sub rsp, 0c8h + 20h +8
                      ;mov qword ptr [rsp+20h],

    xor edi, edi
    loop_map_1:
        cmp edi, 25 ; index to 25
        jge done
        mov rcx, hHeap
        test rcx, rcx
        jz heap_bad
        sub rsp, 20h ; alloc mem

        mov rcx, hHeap
        xor edx, edx; dwFlags to 0
        mov r8d, 64h; mem want to allocate
        call HeapAlloc; allocating
        xor r10d,r10d

        add rsp, 20h; free mem

        mov r11, rax; moving heap pointer to r11
        loop_map_2:
            cmp r10, 25 ; index is 25 or greater
            jl continue_map_2 ; done
            mov qword ptr [rsp+20h+rdi*8h], r11
            inc rdi
            jmp loop_map_1

            continue_map_2:
                mov dword ptr [r11+r10*4],0
                cmp r10, 0 ; if index is not 0 skip to after fill
                jne check_1
                mov dword ptr [r11+r10*4],1 ; in heap
                jmp final_done

            check_1:
                cmp r10,24
                jne check_2
                mov dword ptr [r11+r10*4],1 ; in heap
                jmp final_done
            check_2:
                cmp rdi, 0
                jne check_3
                mov dword ptr [r11+r10*4],1 ; in heap
                jmp final_done
            check_3:
                cmp rdi, 24
                jne final_done
                mov dword ptr [r11+r10*4],1 ; in heap
            final_done:
                inc r10
                jmp loop_map_2

     done:
     xor rdi,rdi
     snake_body:
     mov r8d, player.pos.x

     mov rcx, [rsp+20h+r8*8] ;loads value of map[x]
     mov r8d, player.pos.y
     lea rdx, [rcx+r8*4] ; load address of map[x][y]


     mov ecx, player.pos.x
     cmp ecx, 0
     je snake_check_1
     cmp ecx,24
     je snake_check_1
     mov ecx, player.pos.y

     cmp ecx, 0
     je snake_check_1

     cmp ecx, 24
     je snake_check_1

     jmp snake_done_2 ; skip if not 0 or 24 for x,y
     
     snake_check_1:
     mov player.dead, 1
     ret
     sub rsp, 28h
     mov ecx,1000
     call Sleep
     add rsp, 28h

     snake_done_2:
     mov ecx, player.snakeSize



     mov dword ptr[rdx], 2
     mov ecx, foodpos.x    ;start check if is on food

     mov r10d, player.pos.x

     cmp ecx, r10d    ; if x==x
     je ate_check_1
     jmp ate_done 
     ate_check_1:
     mov ecx, player.pos.y
     mov r10d, foodpos.y
     cmp ecx,r10d
     jne ate_done
     inc player.snakeSize

     sub rsp, 28h          ;random gen for x
     call GetTickCount
     add rsp,28h

     mov ecx, eax

     sub rsp, 28h
     call srand            
     add rsp, 28h

     sub rsp, 28h
     call rand
     add rsp,28h

     xor edx,edx
     mov ecx,23
     div ecx
     inc edx            ;shifting 0,22-> 1,23
     mov foodpos.x, edx ;changing food pos to remainder

     sub rsp,28h         ;random gen for y
     call rand
     add rsp,28h
     xor edx,edx
     mov ecx,23
     div ecx
     inc edx
     mov foodpos.y,edx  ;remainder in y
   

     

     ate_done:
     mov rdi,1
     push r12
     push r13
     xor r12,r12 ;xPos

     xor r13,r13 ;yPos
     snake_tracing:
 
     mov ecx, player.snakeSize
     cmp edi,ecx
     jge snake_fill_done
     lea rdx, player
     lea rdx, [rdx + SNAKE.snakeTurnPoses]
     mov ecx, [rdx+rdi*4] ; gets poses[]

     cmp ecx, 0
     jne pos_check_1
     dec r12
     jmp snake_fill_pt_2

     pos_check_1:
     cmp ecx,1
     jne pos_check_2
     inc r12
     jmp snake_fill_pt_2

     pos_check_2:
     cmp ecx,3
     jne pos_check_3
     dec r13
     jmp snake_fill_pt_2

     pos_check_3:
     cmp ecx,2
     jne snake_fill_pt_2
     inc r13

     snake_fill_pt_2:
     mov ecx,player.pos.x

     sub ecx,r12d

     mov rdx, [rsp+30h+rcx*8] ; r12+r13 =+16 ~ 30h != 20h
     mov ecx, player.pos.y
     sub ecx, r13d

     cmp dword ptr [rdx+rcx*4],2  ; if map[snake.pos.x-xPos][snake.pos.y-yPos] == 2 
     jne snake_loop_end
     mov BYTE PTR player.dead,1
     ret
     sub rsp, 28h
     mov rcx,1000
     call Sleep
     add rsp, 28h
     snake_loop_end:

     mov ecx,player.pos.x

     sub ecx,r12d

     mov rdx, [rsp+30h+rcx*8]
     mov ecx, player.pos.y
     sub ecx, r13d
     mov dword ptr [rdx+rcx*4],2
     inc rdi
     jmp snake_tracing

     snake_fill_done:
     mov ecx, foodpos.x

     mov r8d, foodpos.y

     mov rdx, [rsp+30h+rcx*8]
     mov ecx, [rdx+r8*4]
     lea r10, [rdx+r8*4]
     cmp ecx, 2
     jne after_while
     inc foodpos.x
     mov ecx, foodpos.x
     cmp ecx, 24
     jl food_check_1
     mov foodpos.x,1
     inc foodpos.y
     food_check_1:
     mov ecx, foodpos.y
     cmp ecx,24
     jl food_check_2
     mov foodpos.y, 1 

     food_check_2:
     jmp snake_fill_done
     after_while:
     mov dword ptr [r10],3

     lea rcx, clsCmd
     sub rsp,20h
     call system
     add rsp,20h

     
    xor r12,r12
     final_print_loop:
        
        xor r13,r13
        cmp r12,25
        jge done_printing
        final_print_loop_1:
        mov rax, [rsp+30h+r12*8]
        mov eax, dword ptr [rax+r13*4]

        lea rcx, blankP
        cmp eax, 0
        je print_st

        lea rcx, borderP
        cmp eax,1
        je print_st
        lea rcx, snakeP
        cmp eax,2
        je print_st
        lea rcx, foodP
        cmp eax,3
        je print_st
        jmp afterprintt

        print_st:       
        sub rsp, 20h
        call printf
        add rsp, 20h
        afterprintt:

        inc r13
        cmp r13,24
        jle final_print_loop_1
        inc r12
        lea rcx, newlineP
       
        sub rsp, 20h
        call printf
        add rsp, 20h

        jmp final_print_loop


    done_printing:

      pop r13
      pop r12

     add rsp, 0c8h + 20h +8
     pop rdi
   
     ret
    heap_bad:
    mov foodpos.x, 999
    ret
drawMapASM ENDP
updateSnakeASM PROC
    mov eax, player.turnDir

    cmp eax,0
    jne turn_1
    dec player.pos.x
    jmp reverse_loop

    turn_1:
    cmp eax,1
    jne turn_3
    inc player.pos.x
    jmp reverse_loop

    turn_3:
    cmp eax,3
    jne turn_2
    dec player.pos.y
    jmp reverse_loop

    turn_2:
    cmp eax,2
    jne reverse_loop
    inc player.pos.y

    reverse_loop:
  
    mov eax, player.snakeSize
    lea rdx, player
    lea rdx, [rdx+SNAKE.snakeTurnPoses]

    start_reverse_loop:   
    cmp eax,0
    jl ending_update
    mov ecx, eax
    inc ecx
    mov r8d,[rdx+rax*4] 
    mov [rdx+rcx*4], r8d    ;pos[i+1] = pos [i] shifts to right
    dec eax
    jmp start_reverse_loop

    ending_update:
    mov eax, player.turnDir
    mov dword ptr [rdx],eax
    ret



updateSnakeASM ENDP
processInputASM PROC
    mov rcx, 'W'
    sub rsp,20h
    call GetAsyncKeyState
    add rsp, 20h
    
    mov cx, ax
    and cx, 1
    cmp cx,1
    jl elif_1
    cmp player.turnDir,1
    je done
    mov player.turnDir,0
    mov player.snakeTurnPoses,0
    jmp done
    
    elif_1:

    mov rcx, 'S'
    sub rsp,20h
    call GetAsyncKeyState
    add rsp, 20h
    mov cx, ax
    and cx, 1
    cmp cx,1
    jl elif_2
    cmp player.turnDir,0
    je done
    mov player.turnDir,1
    mov player.snakeTurnPoses,1
    jmp done

    elif_2:
    mov rcx, 'D'
    sub rsp,20h
    call GetAsyncKeyState
    add rsp, 20h
    mov cx, ax
    and cx, 1
    cmp cx,1
    jl elif_3
    cmp player.turnDir,3
    je done
    mov player.turnDir,2
    mov player.snakeTurnPoses,2
    jmp done

    elif_3:
    mov rcx, 'A'
    sub rsp,20h
    call GetAsyncKeyState
    add rsp, 20h
    mov cx, ax
    and cx, 1
    cmp cx,1
    jl done
    cmp player.turnDir,2
    je done
    mov player.turnDir,3
    mov player.snakeTurnPoses,3
    jmp done

    done:
    ret


processInputASM ENDP

addNumbers PROC  ; FIXX PRINT PLAYER IT IS BROKEN IN THE DRAW AND CAUSES UNNESSISARY SLEEP
    sub rsp, 28h
    call GetProcessHeap
    mov hHeap, rax
    add rsp, 28h
    loop_start:
        sub rsp, 20h
        call GetTickCount
        add rsp, 20h
        push r12
        mov r12, rax

        sub rsp, 20h
        call updateSnakeASM
        add rsp, 20h

        sub rsp, 20h
        call drawMapASM
        add rsp, 20h
        
        sub rsp, 20h
        call processInputASM
        add rsp, 20h
        
        sub rsp, 20h
        call GetTickCount
        add rsp, 20h
        sub rax, r12

        sub rsp,20h
        mov ecx, 150 
        call Sleep
        add rsp,20h
  
        pop r12
    
        
        jmp loop_start

    ret
addNumbers ENDP

END
