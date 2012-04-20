
       ; Allocate memory for sinetable
;        mov     eax,m1
;        call    getmem                  ; Alloc mem
;        jc      quitnow
;        mov     sintab,eax
;        add     eax,sinetab_length
;        mov     costab,eax
;        call    generate_taylor_sinetab

;       call    WobblePicPart
;        call    FlagPart

;       cmp     DebugFlag,0
;       jnz     quitnow

;keywt:  in      al,60h
;        cmp     al,1
;        jnz     keywt


;-------------------------------------------------------------------------------
;.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.
;                         -+*+- Wobble Pic Part -+*+-
;.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.oO0Oo.
;-------------------------------------------------------------------------------

WobblePicPart proc near
        pushad


        mov     ecx,32
PaletteLoop2_2:
        push    ecx
        lea     edi,logo5+224*3
        lea     esi,TmpPal
        mov     ecx,32*3
DecLoop_2:
        mov     al,byte ptr [esi]
        cmp     al,byte ptr [edi]
        jae     NoZero_2
        inc     byte ptr [esi]
NoZero_2:
        inc     esi
        inc     edi
        loop    DecLoop_2

        lea     esi,TmpPal
        mov     dx,3c8h
        mov     al,224
        out     dx,al
        inc     dx
        mov     ecx,32*3
paletteloop3_2:
        nop
        nop
        outsb
        loop    paletteloop3_2
        call    sync
        pop     ecx
        loop    PaletteLoop2_2

        ; Alloc mem for sin+costable
        mov     eax,sinetab_length2*5
        call    GetMem
        jc      AMS_Errorhandler
        mov     SinTab2,eax
        call    generate_taylor_sinetab2

        ; And alloc memory for TempScr
        mov     eax,m2
        call    getmem
        jc      ams_errorhandler
        add     eax,160                 ; One empty line at top
        mov     TempScr,eax

        ; Alloc TempScr3
        mov     eax,m4
        call    getmem
        jc      ams_errorhandler
        add     eax,160                 ; One empty line at top
        mov     TempScr3,eax


        ; Just wobble it!
@@wobble:
        call    WobblePic
        inc     WobbleCounter

        cmp     WobbleCounter,200
        jnz     @@not150
        add     YwobbleSpeed1,1*4
@@not150:
        cmp     WobbleCounter,210
        jnz     @@not160
        add     YwobbleSpeed1,2*4
@@not160:
        cmp     WobbleCounter,220
        jnz     @@not170
        add     YwobbleSpeed1,2*4
@@not170:
        cmp     WobbleCounter,230
        jnz     @@not180
        add     YwobbleSpeed1,2*4
@@not180:

@@noupdate:
        cmp     DebugFlag,0
        jnz     @@ut

        cmp     WobbleCounter,1940
        jz      @@ut

        in      al,60h
        cmp     al,1
        jnz     @@wobble

@@ut:
        popad
        ret
        endp

WobbleCounter   dd      0

;-------------------------------------------------------------------------------
;                          -+*+- Wobble Picture -+*+-
;-------------------------------------------------------------------------------
; Wobble in Screen X and Screen Y
Xwobbleptr      dd      0
Ywobbleptr      dd      0

; Wobble in Z for both different X and Y positions
ZXwobbleptr     dd      0
ZYwobbleptr     dd      0

; Speeds
ZXwobbleSpeed1  dd      9*4     ; 9*4
ZXwobbleSpeed2  dd      7*4    ;11*4

YwobbleSpeed1   dd      0*4     ;15*4
YwobbleSpeed2   dd      19*4     ;21*4

ZYwobbleSpeed1  dd      2*4     ;15*4
ZYwobbleSpeed2  dd      1*4     ;17*4

WobblePic proc  near
        pushad

        mov     esi,ScreenPic       ; Get pointer to picture
        mov     edi,TempScr
        mov     ebp,Sintab2          ; Point at sinetable

        add     esi,(320*40)

        ;* Do ZX wobble *
        mov     eax,ZXwobbleptr
        mov     ebx,ZXwobbleSpeed1
        add     ZXwobbleptr,ebx
        and     ZXwobbleptr,16383

        xor     ebx,ebx                 ; Picture offset ptr
        mov     ecx,160                 ; Half screen only
@@nxtZX:
        push    ecx
        add     ebx,[ebp+eax]           ; Add sinus to offsetptr
        mov     edx,ebx
        sar     edx,16

        push    esi
        push    edi
        add     esi,edx                 ; Add X offset
        mov     ecx,100                 ; Height of display field
@@doY:  mov     dl,[esi]                ; Get pixel
        mov     [edi],dl                ; Set pixel
        add     esi,320
        add     edi,160
        loop    @@doY
        pop     edi
        pop     esi

        ; Increase the sinus ptr
        add     eax,ZXwobbleSpeed2
        and     eax,16383

        inc     edi                     ; Next screen coord
        pop     ecx
        loop    @@nxtZX


        ;* Do ZY wobble *
        mov     edi,TempScr3
        add     edi,160
        mov     esi,TempScr

        mov     eax,ZYwobbleptr
        mov     ebx,ZYwobbleSpeed1
        add     ZYwobbleptr,ebx
        and     ZYwobbleptr,16383

        xor     ebx,ebx                 ; Picture offset ptr
        mov     ecx,100                 ; Half screen only
@@nxtZY:
        push    ecx
        add     ebx,[ebp+eax]           ; Add sinus to offsetptr
        mov     ecx,ebx
        sar     ecx,16
        and     ecx,127
;        imul    ecx,160         ; *** Optimize later! ***
        shl     ecx,6
        lea     ecx,[ecx+ecx*4]
        sar     ecx,1

        push    esi
        add     esi,ecx                 ; Add X offset
        mov     ecx,160/4               ; Width of display field
@@doX:
        rep     movsd
        pop     esi

        ; Increase the sinus ptr
        add     eax,ZYwobbleSpeed2
        and     eax,16383

        pop     ecx
        loop    @@nxtZY


        ;* Do X wobble *
        mov     edi,TempScr
        mov     esi,TempScr3

        mov     eax,Ywobbleptr
        mov     ebx,YwobbleSpeed1
        add     Ywobbleptr,ebx
        and     Ywobbleptr,16383

        xor     ebx,ebx                 ; Picture offset ptr
        xor     edx,edx
        mov     ecx,100                 ; Half screen only
@@nxtY:
        push    ecx
        add     ebx,[ebp+eax]           ; Add sinus to offsetptr
        mov     edx,ebx
        sar     edx,16
        jns     @@ok
        neg     edx
@@ok:
        push    esi
        add     esi,edx                 ; Add X offset
        mov     ecx,160/4               ; Width of display field
        rep     movsd
        pop     esi

        ; Increase the sinus ptr
        add     eax,YwobbleSpeed2
        and     eax,16383

        add     esi,160
        pop     ecx
        loop    @@nxtY

        ;* Make four spiffy copies of the tempscr on the real screen *
        mov     esi,TempScr
        move    edi,0a0000h

        mov     ebp,(199*320)+319
        mov     edx,199*320     ; Lower offset
        mov     ecx,WobbleHeight
@@nxtrow:
        push    ecx
        mov     ebx,319         ; Right offset

        mov     ecx,160
@@copypixel:
        mov     al,[esi]        ; Get pixel
        mov     [edi],al        ; Set upper left
        mov     [edi+ebx],al    ; Set upper right
        mov     [edi+edx],al
        mov     [edi+ebp],al

        inc     esi
        inc     edi
        sub     ebx,2
        sub     ebp,2
        loop    @@copypixel

        sub     ebp,160*2
        add     edi,160         ; Step to next row
        sub     edx,2*320
        pop     ecx
        loop    @@nxtrow

        cmp     wobbleheight,100
        jz      @@noadd
        inc     WobbleHeight
@@noadd:
        popad
        ret
        endp

WobbleHeight    dd      1

;-------------------------------------------------------------------------------
;                     -+*+- Variables and such shit -+*+-
;-------------------------------------------------------------------------------

; Allocations
M1=sinetab_length*5     ; For sine tables
M2=160*102              ; For Tempscr (2 additional empty lines at top+bottom)
M3=320*200              ; For Tempscr 2
M4=160*102              ; For TempScr3

TempScr dd      0
TempScr2 dd     0
TempScr3 dd     0

; Some flags
NoClear db      0

