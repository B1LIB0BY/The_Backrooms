
IDEAL
MODEL small
STACK 100h
P386


MAX_BMP_WIDTH = 320
MAX_BMP_HEIGHT = 200

SMALL_BMP_HEIGHT = 5 ;40
SMALL_BMP_WIDTH = 5 ;40


DATASEG
; -----------------------------------------------------------------------------------------------------------------------------------

;random 
 
    d1 dw ?
    temp_for_slime db ?
;delay
    delay_cx dw 20

;sounder
    temp dw 4
    stor dw ?
; pixeldraw
	xplace dw  281
	yplace dw 173
	color db 11 
	dir db 80
    bg_color db 255
    color_black db 77
    color_white db 55

; draw_obstacle_line

    xplace_2 dw 121
    yplace_2 dw 130 
    color_2 db 89
    wheredir dw 1
; second one
    xplace_3 dw 100
    yplace_3 dw 30
    wheredir3 dw 1
    color_3 db 40

; thirdone
    xplace_4 dw 240
    yplace_4 dw 19
    wheredir4 dw 1
    color_4 db 55

;slime 

    slime_dir_y dw 0 ;0 - goup, 1- godown
    slime_dir_x dw 0 ;0 - goright, 1 - goleft

; draw_finish_line
    i dw 0
    x dw 160
    y dw 100
    finish_color db 111
;BMP vars

    img_for_ex db 'map1.bmp',0                 ;image
    img_slime db 'slime.bmp',0                 ;slime
    img_slime_b db 'slime_b.bmp', 0                ;slime_black
    img_homescr db 'homescr.bmp', 0            ;home screen 
    img_abtme db 'about_me.bmp', 0             ;about me screen
    img_modes db 'modes.bmp', 0                ;modes select screen
    img_bldot db 'bldot.bmp', 0            ;black dot for the sensetivity
    img_won db 'won.bmp', 0                ;won screen
    img_lost db 'lost.bmp', 0              ;lost the game
    img_chest db 'with.bmp', 0             ;bmp of the chest
    img_chest_c db 'without', 0            ;bmp of the chest without treasure
    img_opts db 'options.bmp', 0            ;option for the chest
    img_bridge db 'bridge.bmp', 0           ;bridge
    img_rdy db 'ready.bmp', 0

;Other bmp vars for bmp procs

    OneBmpLine  db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
    ScreenLineMax   db MAX_BMP_WIDTH dup (0)  ; One Color line read buffer

    ;BMP File data
    FileHandle  dw ?
    Header      db 54 dup(0)
    Palette     db 400h dup (0)

    BmpFileErrorMsg     db 'Error At Opening Bmp File .', 0dh, 0ah,'$'
    ErrorFile           db 0
    BB db "BB..",'$'

    BmpLeft dw ?
    BmpTop dw ?
    BmpColSize dw ?
    BmpRowSize dw ?	

;line_for_home_screen
    line_corx dw 100
    line_cory dw 105
    line_color db 15

;line_for_modes
    linem_corx dw 100
    linem_cory dw 95
    linem_color db 15

;temps
    temp_bld dw ?
    temp_bld2 dw ?

    temp_slime_left dw ?
    temp_slime_top dw ?

    temp_corx dw ?
    temp_cory dw ?

;open txt file to read and write from it
    filename db 'testfile.txt',0
    filehandle2 dw ?
    Buffer db ''
    Message db ?
    ErrorMsg db 'not working', 10, 13,'$'
    counter dw 0
; need for chest
    xplace_chst dw 210
    yplace_chst dw 160
    color_chst db 55
    chest_chck db 0
    chest_1 db 0
    chest_2 db 0

;back the the game color pixels
    xplace_back dw 0
    yplace_back dw 0
    color_back db ?


;-------------------------------------------------------------------------------------------------	


;====================================================================================================================================

CODESEG
;====================================================================================================================================



; input :
;   1.BmpLeft offset from left (where to start draw the picture) 
;   2. BmpTop offset from top
;   3. BmpColSize picture width , 
;   4. BmpRowSize bmp height 
;   5. dx offset to file name with zero at the end 
proc OpenShowBmp
    push cx
    push bx


    call OpenBmpFile
    cmp [ErrorFile],1
    je @@ExitProc


    call ReadBmpHeader

    ; from  here assume bx is global param with file handle. 
    call ReadBmpPalette

    call CopyBmpPalette

    call ShowBMP


    call CloseBmpFile

@@ExitProc:
    pop bx
    pop cx
    ret
endp OpenShowBmp




; input dx filename to open
proc OpenBmpFile    near                         
    mov ah, 3Dh
    xor al, al
    int 21h
    jc @@ErrorAtOpen
    mov [FileHandle], ax
    jmp @@ExitProc

@@ErrorAtOpen:
    mov [ErrorFile],1
@@ExitProc: 
    ret
endp OpenBmpFile






proc CloseBmpFile near
    mov ah,3Eh
    mov bx, [FileHandle]
    int 21h
    ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader  near                    
    push cx
    push dx

    mov ah,3fh
    mov bx, [FileHandle]
    mov cx,54
    mov dx,offset Header
    int 21h

    pop dx
    pop cx
    ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
                         ; 4 bytes for each color BGR + null)           
    push cx
    push dx

    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h

    pop dx
    pop cx

    ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette     near                    

    push cx
    push dx

    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0  ; black first                         
    out dx,al ;3C8h
    inc dx    ;3C9h
CopyNextColor:
    mov al,[si+2]       ; Red               
    shr al,2            ; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).             
    out dx,al                       
    mov al,[si+1]       ; Green.                
    shr al,2            
    out dx,al                           
    mov al,[si]         ; Blue.             
    shr al,2            
    out dx,al                           
    add si,4            ; Point to next color.  (4 bytes for each color BGR + null)             

    loop CopyNextColor

    pop dx
    pop cx

    ret
endp CopyBmpPalette


proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
    push cx

    mov ax, 0A000h
    mov es, ax

    mov cx,[BmpRowSize]

    mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
    xor dx,dx
    mov si,4
    div si
    mov bp,dx

    mov dx,[BmpLeft]

@@NextLine:
    push cx
    push dx

    mov di,cx  ; Current Row at the small bmp (each time -1)
    add di,[BmpTop] ; add the Y on entire screen


    ; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
    mov cx,di
    shl cx,6
    shl di,8
    add di,cx
    add di,dx

    ; small Read one line
    mov ah,3fh
    mov cx,[BmpColSize]  
    add cx,bp  ; extra  bytes to each row must be divided by 4
    mov dx,offset ScreenLineMax
    int 21h
    ; Copy one line into video memory
    cld ; Clear direction flag, for movsb
    mov cx,[BmpColSize]  
    mov si,offset ScreenLineMax
    rep movsb ; Copy line to the screen

    pop dx
    pop cx

    loop @@NextLine

    pop cx
    ret
endp ShowBMP 

proc Print_final
	push dx
	

	call OpenShowBmp
	
	pop dx
	ret
endp Print_final

PROC Sounder

    mov al,10110110b         ;load control הכנה לטעון
    out 43h,al             ;send a new countdown value
    mov ax,[stor]              ;tone frequency
    out 42h,al    ;send LSB
    mov al,ah    ;move MSB to AL
    out 42h,al    ;save it
    in al,61h               ;get port 61 state
    or al,00000011b           ;turn on speaker
    out 61h,al    ;speaker on now
    call Delay_sounder    ;pause
    and al,11111100b            ;clear speaker enable
    out 61h,al    ;speaker off now

ret
ENDP sounder
PROC Delay_sounder

    mov ah,00h    ;function 0 - get system timer tick
    int 01Ah             ;call ROM BIOS time-of-day services
    add dx,[temp]            ;add our delay value to DX
    mov bx,dx    ;store result in BX
    pozz:
    int 01Ah            ;call ROM BIOS time-of-day services
    cmp dx,bx    ;has the delay duration passed?
    jl pozz            ;no, so go check again

ret
ENDP Delay_sounder

PROC Win_sound

    mov ax, 5000
    mov stor,ax
    mov [temp],5
    call sounder
    mov temp,1
    call delay

    mov ax, 4000
    mov stor,ax
    mov [temp],4
    call sounder
    mov temp,1
    call delay
    mov ax, 3000
    mov stor,ax
    mov [temp],3
    call sounder
    mov temp,1
    call delay
    mov ax, 2000
    mov stor,ax
    mov [temp],2
    call sounder



    ret
ENDP Win_sound

PROC closechest_sound
    mov ax, 9000
    mov stor,ax
    mov [temp],3
    call sounder
    mov temp,1
    call delay
    mov ax, 12000
    mov stor,ax
    mov [temp],2
    call sounder
    mov temp,1
    call delay
    mov ax, 7000
    mov stor,ax
    mov [temp],7
    call sounder
    ret
ENDP closechest_sound

PROC Lose_sound

    mov ax, 4000
    mov stor,ax
    mov [temp],4
    call sounder
    mov temp,1
    call delay

    mov ax, 5000
    mov stor,ax
    mov [temp],5
    call sounder
    mov temp,1
    call delay
    mov ax, 6000
    mov stor,ax
    mov [temp],6
    call sounder
    mov temp,1
    call delay
    mov ax, 7000
    mov stor,ax
    mov [temp],7
    call sounder
    ret
ENDP Lose_sound

PROC start_game

    lea dx, [img_rdy]
    mov [BmpColSize], 320d
    mov [BmpRowSize], 200d
    call Print_final

    mov ax, 8000
    mov stor,ax
    mov [temp],11
    call sounder
    mov temp,2
    call delay
    mov ax, 6000
    mov stor,ax
    mov [temp],11
    call sounder
    mov temp,2
    call delay
    mov ax, 4000
    mov stor,ax
    mov [temp],11
    call sounder
    ret


ENDP start_game



proc OpenFile
    ; Open file for reading and writing
    mov ah, 3Dh
    mov al, 2
    mov dx, offset filename
    int 21h
    jc openerror
    mov [filehandle2], ax
    ret
    openerror :
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h
    ret
endp OpenFile

proc WriteToFile
    ; Write message to file
    mov ah,40h
    mov bx, [filehandle2]
    mov cx,1
    lea dx, [Message]
    int 21h
    ret
endp WriteToFile

proc ReadFile
    ; Read file
    mov ah,3Fh
    mov bx, [filehandle2]
    mov cx, 1
    lea dx, [buffer]
    int 21h
    ret
endp ReadFile

proc CloseFile
    ; Close file
    mov ah,3Eh
    mov bx, [filehandle2]
    int 21h
    ret
endp CloseFile

PROC save_the_frame
    ; Process file
    mov [Message], 49 ;the acsuall message
    call OpenFile
    forloop5:

        mov cx, [xplace_back]
        mov dx, [yplace_back]
        mov ah,0dh        ; checks what is the color of the point cx dx
        int 10h

        mov [Message], al
        mov cx, 0

        mov ah, 42h
        mov al, 01h
        mov bx, [filehandle2]
        mov dx, 0
        int 21h

        call WriteToFile
        cmp [xplace_back], 320
        je resertthecounter
        inc [xplace_back]


        jmp forloop5
        resertthecounter:
            mov [xplace_back], 0
            cmp [yplace_back], 200
            je exit_proc5
            inc [yplace_back]
            jmp forloop5
        exit_proc5:
        call CloseFile
        ret
ENDP save_the_frame

PROC print_the_saved_frame

    mov ax, 13h
    int 10h
    
    mov [xplace_back], 0
    mov [yplace_back], 0
    call OpenFile
    forloop1:
        mov cx, 0

        call ReadFile
        mov al, [buffer]
        mov [color_back], al
        call pixel_back_to_game
        call Delay4

        mov cx, 0

        mov ah, 42h
        mov al, 01h
        mov bx, [filehandle2]
        mov dx, 0
        int 21h

        cmp [xplace_back], 320
        je resertthecounter1
        inc [xplace_back]


        jmp forloop1
        resertthecounter1:
            mov [xplace_back], 0
            cmp [yplace_back], 200
            je exit_proc3
            inc [yplace_back]
            jmp forloop1
    exit_proc3:
    call CloseFile

    ret
ENDP print_the_saved_frame

PROC chest_open
    call Win_sound

    call save_the_frame
    lea dx, [img_opts]
    mov [BmpColSize], 320d
    mov [BmpRowSize], 200d
    mov [BmpTop], 0
    mov [BmpLeft], 0
    call Print_final
    waitforinput7:
        mov ah, 0
        int 16h

        cmp ah, 4
        je back_to_the_game

        cmp ah, 2           ;check if i pressed 1
        je pressed_1

        cmp ah, 3
        je pressed_2

        jmp waitforinput7
    pressed_1:
        mov [chest_1], 1
        jmp back_to_the_game
    pressed_2:
        mov [chest_2], 1
        jmp back_to_the_game
    back_to_the_game:
        call clear_screen
        call print_the_saved_frame
        call delay
        call closechest_sound
    ret
ENDP chest_open

PROC GraphicsMode

    mov ax, 13h
    int 10h
    ret

ENDP GraphicsMode

PROC Random_1 ;Random Proc:
    push ax 
    push dx

    mov ah, 2ch
    int 21h ;
    mov ax, dx ; DL = houonders of seconds , Dh = seconds
    and ax, 0fh ;guard the last 4 bits of DL
    mov [d1] ,ax

    jmp lemmestarthere
    newNum1:
        mov [d1],1
        mov [BmpLeft], 215
        mov [BmpTop], 110
        jmp exit_proc
    newNum2:
        mov [d1],2
        mov [BmpLeft], 40
        mov [BmpTop], 116
        jmp exit_proc
    newNum3:
        mov [d1],3
        mov [BmpLeft], 132
        mov [BmpTop], 155
        jmp exit_proc
    lemmestarthere:
        cmp [d1],5
        jle newNum1
        cmp [d1],10
        jle newNum2
        cmp [d1],15
        jle newNum3
    
    exit_proc:

    pop dx
    pop ax
    ret
ENDP Random_1

PROC clear_screen ;clearing the screen to all black
    push ax
    push bx
    push cx
    push dx

    mov ax,0600h
    mov bh,0
    mov cx,0h
    mov dx,184fh
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax

    ret
ENDP

proc Delay
	mov cx,0FFFFh
LoopLong:
	push cx
	mov cx, 20
LoopShort:
	loop LoopShort
	pop cx
	loop LoopLong
	ret
endp Delay	

proc Delay2
	mov cx,0FFFFh
LoopLong2:
	push cx
	mov cx, [delay_cx]
LoopShort2:
	loop LoopShort2
	pop cx
	loop LoopLong2
	ret
endp Delay2

proc Delay3
	mov cx,0FFFFh
LoopLong3:
	push cx
	mov cx, 2
LoopShort3:
	loop LoopShort3
	pop cx
	loop LoopLong3
	ret
endp Delay3

proc Delay4
	;mov cx,0FFFFh
	push cx
	mov cx, 2000
LoopShort4:
	loop LoopShort4
	pop cx
	ret
endp Delay4

proc pixel
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [xplace]
	mov dx, [yplace]
	mov al, [color]
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel

proc pixel2
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [xplace_2]
	mov dx, [yplace_2]
	mov al, [color_2] 
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel2

proc pixel3
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [xplace_3]
	mov dx, [yplace_3]
	mov al, [color_3] 
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel3

proc pixel4
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [xplace_4]
	mov dx, [yplace_4]
	mov al, [color_4] 
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel4

proc pixel_line_homescr
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [line_corx]
	mov dx, [line_cory]
	mov al, [line_color]
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel_line_homescr

PROC pixel_line_modes
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [linem_corx]
	mov dx, [linem_cory]
	mov al, [linem_color]
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
ENDP pixel_line_modes

proc pixel_back_to_game
	push bx 
	push cx 
	push dx
	 
	mov bh,0h 
	mov cx, [xplace_back]
	mov dx, [yplace_back]
	mov al, [color_back]
	mov ah, 0ch
	int 10h 
	 
	pop dx
	pop cx
	pop bx
	ret
endp pixel_back_to_game

PROC draw_finish_line

    mov [color], 111
    mov dx, 0
    loop1:
        add [yplace], 20
        call pixel
        sub [yplace], 20
        call pixel 
        inc [xplace]
        inc dx
        cmp dx, 25
        jne loop1

    sub [xplace], 25
    mov dx, 0
    loop2:
        add [xplace], 24
        call pixel
        sub [xplace], 24
        call pixel
        inc [yplace]
        inc dx
        cmp dx, 20
        jne loop2
    mov [color], 11
    ret
ENDP draw_finish_line


PROC draw_first

    forloop2: 
        cmp [xplace_2], 131
        je change

        cmp [xplace_2], 121
        je change2

        cmp [wheredir], 1
        je draw_pixel 

        cmp [wheredir], 0
        je delete_pixel

        change:
            mov [wheredir], 0
            dec [xplace_2]
            jmp exit4
        change2:
            mov [wheredir], 1
            inc [xplace_2]
            jmp exit4
        draw_pixel:
            mov [color_2], 0
            call pixel2
            inc [xplace_2]
            jmp exit4
        delete_pixel:
            mov [color_2], 255
            call pixel2
            dec [xplace_2]
            jmp exit4
        exit4:
        ret

ENDP draw_first

PROC draw_second

    forloop3: 
        cmp [yplace_3], 50
        je change3

        cmp [yplace_3], 30
        je change31

        cmp [wheredir3], 1
        je draw_pixel3

        cmp [wheredir3], 0
        je delete_pixel3

        change3:
            mov [wheredir3], 0
            dec [yplace_3]
            jmp exit5
        change31:
            mov [wheredir3], 1
            inc [yplace_3]
            jmp exit5
        draw_pixel3:
            mov [color_3], 0
            call pixel3
            inc [yplace_3]
            jmp exit5
        delete_pixel3:
            mov [color_3], 255
            call pixel3
            dec [yplace_3]
            jmp exit5
        exit5:
        ret

ENDP draw_second

PROC draw_third

    forloop4: 
        cmp [xplace_4], 252
        je change4

        cmp [xplace_4], 233
        je change42

        cmp [wheredir4], 1
        je draw_pixel4

        cmp [wheredir4], 0
        je delete_pixel4

        change4:
            mov [wheredir4], 0
            dec [xplace_4]
            jmp exit5
        change42:
            mov [wheredir4], 1
            inc [xplace_4]
            jmp exit5
        draw_pixel4:
            mov [color_4], 0
            call pixel4
            inc [xplace_4]
            jmp exit5
        delete_pixel4:
            mov [color_4], 255
            call pixel4
            dec [xplace_4]
            jmp exit6
        exit6:
        ret

ENDP draw_third

PROC check_dir

    mov cx, [BmpLeft]
    add cx, 7
    mov dx, [BmpTop]
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_right
    cmp al, [color_chst]
    je change_right

    mov cx, [BmpLeft]
    add cx, 7
    mov dx, [BmpTop]
    add dx, 7
    sub dx, 1
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_right
    cmp al, [color_chst]
    je change_right

    mov cx, [BmpLeft]
    sub cx, 1
    mov dx, [BmpTop]
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_left
    cmp al, [color_chst]
    je change_left

    mov cx, [BmpLeft]
    sub cx, 1
    mov dx, [BmpTop]
    add dx, 7
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_left
    cmp al, [color_chst]
    je change_left

    mov cx, [BmpLeft]
    mov dx, [BmpTop]
    add dx, 8
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_down
    cmp al, [color_chst]
    je change_down

    mov cx, [BmpLeft]
    mov dx, [BmpTop]
    add dx, 8
    add cx, 6
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_down
    cmp al, [color_chst]
    je change_down

    mov cx, [BmpLeft]
    mov dx, [BmpTop]
    sub dx, 1
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_up
    cmp al, [color_chst]
    je change_up

    mov cx, [BmpLeft]
    mov dx, [BmpTop]
    sub dx, 1
    add cx, 6
    mov ah,0dh        ; checks what is the color of the point cx dx
    int 10h
    cmp al, 255
    je change_up
    cmp al, [color_chst]
    je change_up


    jmp exit_dir_slime
    
    exit_dir_slime:
    ret
ENDP check_dir

PROC change_up
    mov [slime_dir_y], 1
    ret
ENDP change_up
PROC change_down
    mov [slime_dir_y], 0
    ret
ENDP change_down
PROC change_right
    mov [slime_dir_x], 1
    ret
ENDP change_right
PROC change_left
    mov [slime_dir_x], 0
    ret
ENDP change_left

PROC print_slime

    cmp [chest_2], 1
    jne regular
    lea dx, [img_bridge]
    mov [BmpColSize], 14d
    mov [BmpRowSize], 30d

    mov ax, [BmpLeft]
    mov [temp_corx], ax
    mov ax, [BmpTop]
    mov [temp_cory], ax

    mov [BmpTop], 63
    mov [BmpLeft], 160
    call Print_final
    mov [chest_2], 0

    mov ax, [temp_corx]
    mov [BmpLeft], ax
    mov ax, [temp_cory]
    mov [BmpTop], ax

    regular:
    lea dx, [img_slime_b]
    mov [BmpColSize], 6
    mov [BmpRowSize], 7
    cmp [chest_1], 1
    je exit_slime_chst
    call Print_final
    call check_dir


    cmp [slime_dir_x], 0
    je slime_go_right

    cmp [slime_dir_x], 1
    je slime_go_left

    slime_go_right:
        cmp [slime_dir_y], 0
        je slime_go_right_up
        jmp slime_go_right_down
    slime_go_left:
        cmp [slime_dir_y], 0
        je slime_go_left_up
        jmp slime_go_left_down
    slime_go_right_up:
        inc [BmpLeft]
        dec[BmpTop]
        jmp exit_slime
    slime_go_right_down:
        inc [BmpLeft]
        inc [BmpTop]
        jmp exit_slime
    slime_go_left_up:
        dec [BmpLeft]
        dec [BmpTop]
        jmp exit_slime
    slime_go_left_down:
        dec [BmpLeft]
        inc [BmpTop]
        jmp exit_slime


    exit_slime:
        lea dx, [img_slime]
        call Print_final
        ret
    exit_slime_chst:
    call Print_final
    ret
ENDP print_slime

PROC print_line_homescr
    push cx
    push ax
    bloop:
        call pixel_line_homescr 
        inc [line_corx]
        cmp [line_corx], 220
        jne bloop
    inc [line_cory] 
    dec [line_corx]
    cloop:
        call pixel_line_homescr
        dec [line_corx]
        cmp [line_corx], 98
        jne cloop
    exit_p:
    dec [line_cory]
    pop ax
    pop cx
    ret
ENDP print_line_homescr

PROC print_line_modes
    push cx
    push ax
    bloopm:
        call pixel_line_modes
        inc [linem_corx]
        cmp [linem_corx], 220
        jne bloopm
    inc [linem_cory] 
    dec [linem_corx]
    cloopm:
        call pixel_line_modes
        dec [linem_corx]
        cmp [linem_corx], 98
        jne cloopm
    exit_pm:
    dec [linem_cory]
    pop ax
    pop cx
    ret
ENDP print_line_modes



PROC eazy_mode

    call start_game
    lea dx, [img_for_ex]
    call Print_final
    call draw_finish_line
    mov [xplace], 24
    mov [yplace], 27

	forloop:

        mov cx, [xplace]
        mov dx, [yplace]
        mov ah,0dh        ; checks what is the color of the point cx dx
        int 10h

		cmp al, [finish_color]
		jz call_win_screen

        cmp al, 11 
        jz call_lose_screen
		
        cmp al, [bg_color]
        jz call_lose_screen

		call pixel

        mov ah,1             
		int 16h          
        jz afterinput ;this is gonna check if i pressed something.

        mov ah,0              ;function 0 - wait for keypress
		int 16h              ;call ROM BIOS keyboard services

        mov [dir],ah
    afterinput:
        call Delay2

        mov ah,[dir]

		cmp ah, 72
		je moveup

		cmp ah, 80
		je movedown

		cmp ah, 75
		je moveleft

		cmp ah, 77
		je moveright

		jmp forloop

		moveup:
			dec [yplace]
            mov [dir], 72
			jmp forloop
		movedown:
			inc [yplace]
            mov [dir], 80
			jmp forloop
		moveleft:
			dec [xplace]
            mov [dir], 75
			jmp forloop	
		moveright:
			inc [xplace]
            mov [dir], 77
			jmp forloop
        call_win_screen:
            call won_screen
        call_lose_screen:
            jmp lost_screen

    ret
ENDP eazy_mode

PROC medium_mode
    call start_game
    lea dx, [img_for_ex]
    call Print_final
    call draw_finish_line

    mov [xplace], 24
    mov [yplace], 27

	forloop_medium:

        mov cx, [xplace]
        mov dx, [yplace]
        mov ah,0dh        ; checks what is the color of the point cx dx
        int 10h

		cmp al, [finish_color]
		jz call_win_screen_medium

        cmp al, 11 
        jz call_lose_screen_medium
		
        cmp al, [bg_color]
        jz call_lose_screen_medium

		call pixel

        mov ah,1             
		int 16h          
        jz afterinput_medium ;this is gonna check if i pressed something.

        mov ah,0              ;function 0 - wait for keypress
		int 16h              ;call ROM BIOS keyboard services

        mov [dir],ah
    afterinput_medium:

        call draw_first
        call draw_second
        call draw_third
        call Delay2

        mov ah,[dir]

		cmp ah, 72
		je moveup_medium

		cmp ah, 80
		je movedown_medium

		cmp ah, 75
		je moveleft_medium

		cmp ah, 77
		je moveright_medium

		jmp forloop_medium

		moveup_medium:
			dec [yplace]
            mov [dir], 72
			jmp forloop_medium
		movedown_medium:
			inc [yplace]
            mov [dir], 80
			jmp forloop_medium
		moveleft_medium:
			dec [xplace]
            mov [dir], 75
			jmp forloop_medium
		moveright_medium:
			inc [xplace]
            mov [dir], 77
			jmp forloop_medium
        call_win_screen_medium:
            call won_screen
        call_lose_screen_medium:
            call lost_screen

    ret
ENDP medium_mode

PROC hard_mode


    mov [chest_chck], 0
    mov [chest_1], 0

    call start_game
    lea dx, [img_for_ex]
    call Print_final
    call draw_finish_line

    lea dx, [img_chest] ;print the chest!
    mov [BmpColSize], 18d
    mov [BmpRowSize], 14d
    mov [BmpLeft], 210
    mov [BmpTop], 160
    call Print_final


    mov [xplace], 24
    mov [yplace], 27

    call Random_1

	forloop_hard:

        mov cx, [xplace]
        mov dx, [yplace]
        mov ah,0dh        ; checks what is the color of the point cx dx
        int 10h

		cmp al, [finish_color]
		jz call_win_screen_hard

        cmp al, 11 
        jz call_lose_screen_hard
		
        cmp al, [bg_color]
        jz call_lose_screen_hard

        cmp al, 115
        jz call_lose_screen_hard

        cmp al, [color_chst]; change the color for the chest
        jz call_chest_open

		call pixel

        mov ah,1             
		int 16h          
        jz afterinput_hard ;this is gonna check if i pressed something.

        mov ah,0              ;function 0 - wait for keypress
		int 16h              ;call ROM BIOS keyboard services

        mov [dir],ah
    afterinput_hard:

        call draw_first
        call draw_second
        call draw_third
        call print_slime
        call Delay2

        mov ah,[dir]

		cmp ah, 72
		je moveup_hard

		cmp ah, 80
		je movedown_hard

		cmp ah, 75
		je moveleft_hard

		cmp ah, 77
		je moveright_hard

		jmp forloop_hard

		moveup_hard:
			dec [yplace]
            mov [dir], 72
			jmp forloop_hard
		movedown_hard:
			inc [yplace]
            mov [dir], 80
			jmp forloop_hard
		moveleft_hard:
			dec [xplace]
            mov [dir], 75
			jmp forloop_hard
		moveright_hard:
			inc [xplace]
            mov [dir], 77
			jmp forloop_hard
        call_win_screen_hard:
            call won_screen
        call_lose_screen_hard:
            call lost_screen
        call_chest_open:
            cmp [chest_chck], 1
            je call_lose_screen_hard
            mov [chest_chck], 1
            mov dx, [BmpTop]
            mov [temp_slime_top], dx
            mov dx, [BmpLeft]
            mov [temp_slime_left], dx
            call chest_open
            mov [dir], 75
            mov [xplace], 241
            mov [yplace], 98
            mov dx, [temp_slime_left]
            mov [BmpLeft], dx
            mov dx, [temp_slime_top]
            mov [BmpTop], dx
            jmp afterinput_hard

    ret

ENDP hard_mode

PROC won_screen
    mov [BmpColSize], 320d
    mov [BmpRowSize], 200d
    mov [BmpLeft], 0
    mov [BmpTop], 0
    lea dx, [img_won]
    call Print_final 

    call Win_sound
    waitforinput4:
        mov ah, 0
        int 16h
        
        cmp ah, 45
        je home_screen

        cmp ah, 16
        je exit
        
        jmp waitforinput4
ENDP won_screen

PROC lost_screen
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320d
    mov [BmpRowSize], 200d       
    lea dx, [img_lost]
    call Print_final

    call Lose_sound
    waitforinput5:
        mov ah, 0
        int 16h

        cmp ah, 45
        je home_screen

        cmp ah, 16
        je exit
        
        jmp waitforinput5
ENDP lost_screen

PROC about_me_proc
    lea dx, [img_abtme]
    call Print_final
    waitforinput2: 
        mov ah, 0
        int 16h
        cmp ah, 1
        je call_back_to_home_screen
        jmp waitforinput2
    call_back_to_home_screen:
        call home_screen
ENDP about_me_proc

PROC select_mode_proc
    mov [i], 0
    mov [x], 160
    mov [y], 100

	mov [xplace], 281
	mov [yplace], 173
    mov [dir], 80

    mov [xplace_back], 0
    mov [yplace_back], 0

    mov [delay_cx], 20

    mov [slime_dir_y] ,0 ;0 - goup, 1- godown
    mov [slime_dir_x] ,0 ;0 - goright, 1 - goleft

    lea dx, [img_modes]
    call Print_final
    mov [BmpLeft], 294
    mov [BmpTop], 97
    waitforinput3:
        mov ax, [BmpLeft]
        mov [temp_bld], ax
        mov ax, [BmpTop]
        mov [temp_bld2], ax

        mov [BmpLeft], 0
        mov [BmpTop], 0
        call clear_screen
        mov [BmpColSize], 320d
        mov [BmpRowSize], 200d    
        lea dx, [img_modes]
        call Print_final



        mov ax, [temp_bld]
        mov [BmpLeft], ax
        mov ax, [temp_bld2]
        mov [BmpTop], ax
        mov [BmpColSize], 6d
        mov [BmpRowSize], 6d
        lea dx, [img_bldot]
        call Print_final
        call print_line_modes

        mov ah, 0
        int 16h

        cmp ah, 1
        je home_screen

        cmp ah, 72
        je up_movem

        cmp ah, 80
        je down_movem

        cmp ah, 28
        je selectedm

        cmp ah, 49
        je inc_the_dot

        cmp ah, 50
        je dec_the_dot

        jmp waitforinput3

        up_movem:
            cmp [linem_cory], 95
            je up_downm
            sub [linem_cory], 50
            jmp waitforinput3
        down_movem:
            cmp [linem_cory], 195
            je down_upm
            add [linem_cory], 50
            jmp waitforinput3
        up_downm:
            add [linem_cory], 100
            jmp waitforinput3
        down_upm:
            sub [linem_cory], 100
            jmp waitforinput3
        inc_the_dot:
            cmp [BmpTop], 37
            je waitforinput3
            sub [BmpTop], 5
            dec [delay_cx]
            jmp waitforinput3
        dec_the_dot:
            cmp [BmpTop], 162
            je waitforinput3
            add [BmpTop], 5
            inc [delay_cx]
            jmp waitforinput3
        selectedm:
            mov [BmpColSize], 320d
            mov [BmpRowSize], 200d 
            mov [BmpLeft], 0
            mov [BmpTop], 0
            cmp [linem_cory], 95
            je eazy_mode

            cmp [linem_cory], 145
            je medium_mode

            cmp [linem_cory], 195
            je hard_mode

    ret
ENDP select_mode_proc

PROC home_screen
    push dx
    ; ;creating the file named 'testfile.txt'
    ; mov ah ,3Ch
    ; lea dx, [filename]
    ; int 21h
    lea dx, [img_homescr]
    mov [BmpLeft], 0
    mov [BmpTop], 0
    mov [BmpColSize], 320d
    mov [BmpRowSize], 200d
    call Print_final
    waitforinput:
        call clear_screen
        call Print_final
        call print_line_homescr
        mov ah, 0
        int 16h ;read one key from the user
        
        cmp ah, 72
        je up_move

        cmp ah, 80
        je down_move

        cmp ah, 28
        je selected 
        
        jmp waitforinput
    up_move:
        cmp [line_cory], 105
        je up_down
        sub [line_cory], 45
        jmp waitforinput
    down_move:
        cmp [line_cory], 195
        je down_up
        add [line_cory], 45
        jmp waitforinput
    up_down:
        add [line_cory], 90
        jmp waitforinput
    down_up:
        sub [line_cory], 90
        jmp waitforinput
    selected:
        cmp [line_cory], 105
        je select_mode_proc
        
        cmp [line_cory], 150
        je about_me_proc

        cmp [line_cory], 195
        je exit
    pop dx
    ret
ENDP home_screen

start:
	mov ax, @data
	mov ds, ax

    call clear_screen
    call GraphicsMode
    call home_screen
	

exit:
    call clear_screen
	mov ax, 4c00h
	int 21h
END start
